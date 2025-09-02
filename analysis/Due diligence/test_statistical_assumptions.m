function test_statistical_assumptions(relativeData, isolatedData, kpiList)
% Test statistical assumptions required for relativization framework
    
    fprintf('  Testing normality and independence assumptions...\n');
    
    normality_results = struct();
    independence_results = struct();
    
    for i = 1:min(5, length(kpiList))
        kpi = kpiList{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi))
            continue;
        end
        
        R = relativeData.(kpi);
        R = R(~isnan(R));
        
        if length(R) < 20
            continue;
        end
        
        % Test normality using multiple tests
        [h_jb, p_jb] = jbtest(R); % Jarque-Bera test
        [h_ks, p_ks] = kstest(R); % Kolmogorov-Smirnov test
        [h_sw, p_sw] = swtest(R); % Shapiro-Wilk test (if available)
        
        normality_results.(kpi) = struct('jarque_bera_h', h_jb, 'jarque_bera_p', p_jb, ...
                                        'ks_h', h_ks, 'ks_p', p_ks);
        
        % Test for autocorrelation (independence over time)
        if length(R) > 10
            [acf, lags, bounds] = autocorr(R, 'NumLags', min(10, floor(length(R)/4)));
            significant_lags = sum(abs(acf(2:end)) > bounds(2:end, 2));
            independence_results.(kpi) = struct('significant_lags', significant_lags, ...
                                               'total_lags', length(acf)-1);
        end
        
        fprintf('    %s: Normal (JB p=%.3f, KS p=%.3f), Independence (%d/%d significant lags)\n', ...
                kpi, p_jb, p_ks, ...
                independence_results.(kpi).significant_lags, ...
                independence_results.(kpi).total_lags);
    end
    
    % Overall assessment
    if ~isempty(fieldnames(normality_results))
        % Count how many KPIs pass normality tests
        normal_count = 0;
        independent_count = 0;
        total_count = 0;
        
        for kpi = fieldnames(normality_results)'
            kpi_name = kpi{1};
            % Pass if p-value > 0.05 for at least one test
            passes_normal = normality_results.(kpi_name).jarque_bera_p > 0.05 || ...
                           normality_results.(kpi_name).ks_p > 0.05;
            normal_count = normal_count + passes_normal;
            
            if isfield(independence_results, kpi_name)
                % Pass if less than 25% of lags are significant
                passes_independent = independence_results.(kpi_name).significant_lags / ...
                                   independence_results.(kpi_name).total_lags < 0.25;
                independent_count = independent_count + passes_independent;
            end
            
            total_count = total_count + 1;
        end
        
        fprintf('  Statistical assumptions summary:\n');
        fprintf('    Normality: %.1f%% of KPIs (%d/%d)\n', ...
                normal_count/total_count*100, normal_count, total_count);
        fprintf('    Independence: %.1f%% of KPIs (%d/%d)\n', ...
                independent_count/total_count*100, independent_count, total_count);
    end
end

function compare_predictive_performance(relativeData, isolatedData, kpiList)
% Compare predictive performance of relative vs absolute metrics
    
    fprintf('  Comparing predictive performance...\n');
    
    performance_results = struct();
    
    % Select top KPIs for detailed analysis
    top_kpis = {'Tries', 'DefenderBeaten', 'Tackle', 'CleanBreaks', 'Total_Penalty_Conceded'};
    
    for i = 1:length(top_kpis)
        kpi = top_kpis{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi)) || ...
           ~any(strcmp(isolatedData.Properties.VariableNames, kpi))
            continue;
        end
        
        % Prepare relative data
        R = relativeData.(kpi);
        R_outcomes = relativeData.Match_Outcome;
        valid_rel = ~isnan(R) & ~ismissing(R_outcomes);
        R = R(valid_rel);
        R_outcomes = R_outcomes(valid_rel);
        
        % Prepare absolute data
        X = isolatedData.(kpi);
        X_outcomes = isolatedData.Match_Outcome;
        valid_abs = ~isnan(X) & ~ismissing(X_outcomes);
        X = X(valid_abs);
        X_outcomes = X_outcomes(valid_abs);
        
        if length(R) < 20 || length(X) < 20
            continue;
        end
        
        % Convert outcomes to binary (1 for win, 0 for loss)
        y_rel = double(strcmp(R_outcomes, 'W'));
        y_abs = double(strcmp(X_outcomes, 'W'));
        
        % Calculate AUC-ROC for both metrics
        try
            % Relative metric AUC
            [~, ~, ~, auc_rel] = perfcurve(y_rel, R, 1);
            
            % Absolute metric AUC  
            [~, ~, ~, auc_abs] = perfcurve(y_abs, X, 1);
            
            % Calculate separability metrics from paper
            sep_rel = calculate_separability(R, y_rel);
            sep_abs = calculate_separability(X, y_abs);
            
            % Calculate information content
            info_rel = calculate_information_content(sep_rel);
            info_abs = calculate_information_content(sep_abs);
            
            performance_results.(kpi) = struct(...
                'auc_rel', auc_rel, 'auc_abs', auc_abs, ...
                'sep_rel', sep_rel, 'sep_abs', sep_abs, ...
                'info_rel', info_rel, 'info_abs', info_abs);
            
            fprintf('    %s: AUC(Rel=%.3f, Abs=%.3f), Sep(Rel=%.3f, Abs=%.3f), Info(Rel=%.3f, Abs=%.3f)\n', ...
                    kpi, auc_rel, auc_abs, sep_rel, sep_abs, info_rel, info_abs);
            
        catch ME
            fprintf('    %s: Error in performance calculation - %s\n', kpi, ME.message);
        end
    end
    
    % Calculate overall improvements
    if ~isempty(fieldnames(performance_results))
        auc_improvements = [];
        sep_improvements = [];
        info_improvements = [];
        
        for kpi = fieldnames(performance_results)'
            kpi_name = kpi{1};
            res = performance_results.(kpi_name);
            
            if ~isnan(res.auc_rel) && ~isnan(res.auc_abs) && res.auc_abs > 0
                auc_improvements(end+1) = (res.auc_rel - res.auc_abs) / res.auc_abs * 100;
            end
            
            if ~isnan(res.sep_rel) && ~isnan(res.sep_abs) && res.sep_abs > 0
                sep_improvements(end+1) = (res.sep_rel - res.sep_abs) / res.sep_abs * 100;
            end
            
            if ~isnan(res.info_rel) && ~isnan(res.info_abs) && res.info_abs > 0
                info_improvements(end+1) = (res.info_rel - res.info_abs) / res.info_abs * 100;
            end
        end
        
        fprintf('  Average improvements (relative vs absolute):\n');
        if ~isempty(auc_improvements)
            fprintf('    AUC-ROC: %.1f%% improvement\n', mean(auc_improvements));
        end
        if ~isempty(sep_improvements)
            fprintf('    Separability: %.1f%% improvement\n', mean(sep_improvements));
        end
        if ~isempty(info_improvements)
            fprintf('    Information Content: %.1f%% improvement\n', mean(info_improvements));
        end
    end
end

function sep = calculate_separability(metric_values, outcomes)
% Calculate separability metric S = Φ(d/2) from the paper
    
    wins = outcomes == 1;
    losses = outcomes == 0;
    
    if sum(wins) < 2 || sum(losses) < 2
        sep = NaN;
        return;
    end
    
    mu_win = mean(metric_values(wins));
    mu_loss = mean(metric_values(losses));
    sigma_win = std(metric_values(wins));
    sigma_loss = std(metric_values(losses));
    
    % Pooled standard deviation
    sigma_pooled = sqrt((sigma_win^2 + sigma_loss^2) / 2);
    
    if sigma_pooled == 0
        sep = NaN;
        return;
    end
    
    % Effect size d = 2|μ_A - μ_B| / σ_pooled
    d = 2 * abs(mu_win - mu_loss) / sigma_pooled;
    
    % Separability S = Φ(d/2)
    sep = normcdf(d/2);
end

function info = calculate_information_content(separability)
% Calculate information content I = 1 - H(S) from the paper
    
    if isnan(separability) || separability <= 0 || separability >= 1
        info = NaN;
        return;
    end
    
    % Binary entropy H(p) = -p*log2(p) - (1-p)*log2(1-p)
    p = separability;
    if p == 0 || p == 1
        entropy = 0;
    else
        entropy = -p*log2(p) - (1-p)*log2(1-p);
    end
    
    % Information content I = 1 - H(S)
    info = 1 - entropy;
end

function generate_summary_report(relativeData, isolatedData, kpiList)
% Generate comprehensive summary report of the relativization analysis
    
    fprintf('  Generating summary report...\n');
    
    % Create summary structure
    summary = struct();
    summary.timestamp = datetime('now');
    summary.num_matches = height(relativeData) / 2;
    summary.num_kpis_tested = length(kpiList);
    
    % Axiom satisfaction summary
    summary.axioms = struct();
    summary.axioms.invariance = 'See individual KPI results';
    summary.axioms.ordinal_consistency = 'See individual KPI results';
    summary.axioms.scaling = 'See individual KPI results';
    summary.axioms.optimality = 'See SNR improvement analysis';
    
    % Performance summary
    if evalin('base', 'exist(''snr_results'', ''var'')')
        snr_results = evalin('base', 'snr_results');
        kpi_names = fieldnames(snr_results);
        
        if ~isempty(kpi_names)
            improvements = [];
            for i = 1:length(kpi_names)
                improvements(i) = snr_results.(kpi_names{i}).improvement;
            end
            
            summary.performance.mean_snr_improvement = mean(improvements);
            summary.performance.median_snr_improvement = median(improvements);
            summary.performance.kpis_with_improvement = sum(improvements > 1.0);
            summary.performance.total_kpis_tested = length(improvements);
        end
    end
    
    % Environmental noise estimation
    summary.noise_analysis = estimate_environmental_noise(relativeData, isolatedData, kpiList);
    
    % Recommendations
    summary.recommendations = generate_recommendations(summary);
    
    % Save results
    save('rugby_relativization_results.mat', 'summary', 'relativeData', 'isolatedData');
    
    fprintf('  Summary report saved to rugby_relativization_results.mat\n');
    
    % Display key findings
    fprintf('\n  KEY FINDINGS:\n');
    if isfield(summary.performance, 'mean_snr_improvement')
        fprintf('    - Average SNR improvement: %.2fx\n', summary.performance.mean_snr_improvement);
        fprintf('    - KPIs showing improvement: %d/%d (%.1f%%)\n', ...
                summary.performance.kpis_with_improvement, ...
                summary.performance.total_kpis_tested, ...
                summary.performance.kpis_with_improvement/summary.performance.total_kpis_tested*100);
    end
    
    if isfield(summary.noise_analysis, 'estimated_noise_ratio')
        fprintf('    - Estimated environmental noise ratio: %.3f\n', ...
                summary.noise_analysis.estimated_noise_ratio);
    end
    
    fprintf('    - Framework applicability: %s\n', summary.recommendations.applicability);
end

function noise_analysis = estimate_environmental_noise(relativeData, isolatedData, kpiList)
% Estimate the environmental noise ratio σ_η/σ_indiv from the data
    
    noise_ratios = [];
    
    for i = 1:min(5, length(kpiList))
        kpi = kpiList{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi)) || ...
           ~any(strcmp(isolatedData.Properties.VariableNames, kpi))
            continue;
        end
        
        % Get data
        R = relativeData.(kpi);
        X = isolatedData.(kpi);
        
        % Remove NaN values
        R = R(~isnan(R));
        X = X(~isnan(X));
        
        if length(R) < 10 || length(X) < 10
            continue;
        end
        
        % Estimate noise components
        % σ_R^2 = σ_A^2 + σ_B^2 (individual variations)
        sigma_R = std(R);
        
        % σ_X^2 = σ_indiv^2 + σ_η^2 (individual + environmental)
        sigma_X = std(X);
        
        % Assuming σ_A ≈ σ_B ≈ σ_indiv, then σ_R ≈ √2 * σ_indiv
        sigma_indiv_est = sigma_R / sqrt(2);
        
        % Estimate environmental noise: σ_η^2 = σ_X^2 - σ_indiv^2
        sigma_eta_squared = max(0, sigma_X^2 - sigma_indiv_est^2);
        sigma_eta_est = sqrt(sigma_eta_squared);
        
        % Noise ratio
        if sigma_indiv_est > 0
            noise_ratio = sigma_eta_est / sigma_indiv_est;
            noise_ratios(end+1) = noise_ratio;
        end
    end
    
    noise_analysis = struct();
    if ~isempty(noise_ratios)
        noise_analysis.estimated_noise_ratio = mean(noise_ratios);
        noise_analysis.noise_ratio_std = std(noise_ratios);
        noise_analysis.kpis_analyzed = length(noise_ratios);
    else
        noise_analysis.estimated_noise_ratio = NaN;
        noise_analysis.note = 'Insufficient data for noise estimation';
    end
end

function recommendations = generate_recommendations(summary)
% Generate practical recommendations based on the analysis
    
    recommendations = struct();
    
    % Determine overall applicability
    if isfield(summary.performance, 'kpis_with_improvement') && ...
       isfield(summary.performance, 'total_kpis_tested')
        
        improvement_rate = summary.performance.kpis_with_improvement / ...
                          summary.performance.total_kpis_tested;
        
        if improvement_rate >= 0.6
            recommendations.applicability = 'HIGHLY RECOMMENDED';
            recommendations.reason = 'Majority of KPIs show SNR improvement from relativization';
        elseif improvement_rate >= 0.4
            recommendations.applicability = 'MODERATELY RECOMMENDED';
            recommendations.reason = 'Some KPIs show improvement, selective application advised';
        else
            recommendations.applicability = 'LIMITED BENEFIT';
            recommendations.reason = 'Few KPIs show consistent improvement';
        end
    else
        recommendations.applicability = 'INSUFFICIENT DATA';
        recommendations.reason = 'Unable to determine effectiveness from available data';
    end
    
    % Specific recommendations
    recommendations.specific = {};
    
    if isfield(summary.noise_analysis, 'estimated_noise_ratio') && ...
       ~isnan(summary.noise_analysis.estimated_noise_ratio)
        
        noise_ratio = summary.noise_analysis.estimated_noise_ratio;
        
        if noise_ratio > 0.3
            recommendations.specific{end+1} = ...
                'High environmental noise detected - relativization strongly advised';
        elseif noise_ratio > 0.1
            recommendations.specific{end+1} = ...
                'Moderate environmental noise - relativization moderately beneficial';
        else
            recommendations.specific{end+1} = ...
                'Low environmental noise - limited relativization benefit expected';
        end
    end
    
    recommendations.specific{end+1} = ...
        'Focus on KPIs showing consistent directional effects (tries, tackles, etc.)';
    recommendations.specific{end+1} = ...
        'Consider match context factors when interpreting results';
    recommendations.specific{end+1} = ...
        'Validate findings with larger datasets when possible';
end

% Shapiro-Wilk test implementation (simplified version)
function [H, p] = swtest(x)
% Simplified Shapiro-Wilk test for normality
    
    n = length(x);
    if n < 3 || n > 5000
        H = NaN;
        p = NaN;
        return;
    end
    
    % Sort the data
    x_sorted = sort(x);
    
    % Calculate test statistic (simplified)
    mean_x = mean(x);
    numerator = sum((x_sorted - mean_x).^2);
    
    if numerator == 0
        H = 0;
        p = 1;
        return;
    end
    
    % Approximate W statistic
    W = 1 - (sum((x_sorted - mean_x).^2) - (sum(x_sorted - mean_x))^2/n) / sum((x_sorted - mean_x).^2);
    
    % Approximate p-value (very rough approximation)
    if W > 0.95
        p = 0.5;
        H = 0;
    elseif W > 0.90
        p = 0.1;
        H = 0;
    else
        p = 0.01;
        H = 1;
    end
end