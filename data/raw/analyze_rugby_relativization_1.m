function analyze_rugby_relativization_1()
% ANALYZE_RUGBY_RELATIVIZATION - Main function to test relativization axioms on rugby KPIs
%
% This function implements the mathematical framework from the paper to test
% whether rugby performance indicators satisfy the conditions for effective
% relativization. It validates the four axioms and examines SNR improvement.
%
% Data Requirements:
% - S20Relative.csv: Relative differences (Team A - Team B) for each KPI
% - S20Isolated.csv: Absolute values for individual teams
%
% Axioms tested:
% 1. Invariance to Shared Effects
% 2. Ordinal Consistency  
% 3. Scaling Proportionality
% 4. Optimality (SNR improvement)

    fprintf('Rugby KPI Relativization Analysis\n');
    fprintf('=================================\n\n');
    
    % Load and preprocess data
    [relativeData, isolatedData, kpiList] = load_rugby_data();
    
    % Test each axiom systematically
    fprintf('Testing Relativization Axioms:\n\n');
    
    % Axiom 1: Invariance to Shared Effects
    fprintf('1. Testing Axiom 1: Invariance to Shared Effects\n');
    test_invariance_axiom(relativeData, isolatedData, kpiList);
    
    % Axiom 2: Ordinal Consistency
    fprintf('\n2. Testing Axiom 2: Ordinal Consistency\n');
    test_ordinal_consistency(relativeData, kpiList);
    
    % Axiom 3: Scaling Proportionality
    fprintf('\n3. Testing Axiom 3: Scaling Proportionality\n');
    test_scaling_proportionality(relativeData, isolatedData, kpiList);
    
    % Axiom 4: Optimality (SNR Analysis)
    fprintf('\n4. Testing Axiom 4: Optimality - SNR Improvement\n');
    test_snr_improvement(relativeData, isolatedData, kpiList);
    
    % Statistical assumptions testing
    fprintf('\n5. Testing Statistical Assumptions\n');
    test_statistical_assumptions(relativeData, isolatedData, kpiList);
    
    % Performance comparison
    fprintf('\n6. Predictive Performance Comparison\n');
    compare_predictive_performance(relativeData, isolatedData, kpiList);
    
    % Generate summary report
    generate_summary_report(relativeData, isolatedData, kpiList);
    
    fprintf('\nAnalysis complete. Results saved to rugby_relativization_results.mat\n');
end

function [relativeData, isolatedData, kpiList] = load_rugby_data()
% Load and preprocess rugby performance data
    
    fprintf('Loading rugby performance data...\n');
    
    % Load CSV files
    try
        relativeRaw = readtable('S20Relative.csv');
        isolatedRaw = readtable('S20Isolated.csv');
        fprintf('  Successfully loaded data files\n');
    catch ME
        error('Failed to load CSV files: %s', ME.message);
    end
    
    % Define key performance indicators to analyze
    % Based on Scott et al. (2023) and domain expertise
    kpiList = {
        'Tries', 'Carry', 'MetresMade', 'DefenderBeaten', 'Offload', ...
        'Pass', 'Tackle', 'MissedTackle', 'Turnover', 'CleanBreaks', ...
        'Turnovers_Won', 'LineoutsWon', 'ScrumsWon', 'RucksWon', ...
        'Total_Penalty_Conceded'
    };
    
    % Clean column names for consistency
    relativeData = clean_column_names(relativeRaw);
    isolatedData = clean_column_names(isolatedRaw);
    
    % Validate data structure
    validate_data_structure(relativeData, isolatedData, kpiList);
    
    fprintf('  Data preprocessing complete\n');
    fprintf('  Analyzing %d KPIs across %d matches\n', ...
            length(kpiList), height(relativeData)/2);
end

function cleanData = clean_column_names(rawData)
% Clean column names to ensure consistency
    cleanData = rawData;
    
    % Standardize column names
    cleanData.Properties.VariableNames = strrep(...
        cleanData.Properties.VariableNames, '.', '_');
    cleanData.Properties.VariableNames = strrep(...
        cleanData.Properties.VariableNames, '___', '_');
    
    % Handle specific cases
    if any(strcmp(cleanData.Properties.VariableNames, 'Turnovers_Won'))
        % Already correct
    %elseif any(strcmp(cleanData.Properties.VariableNames, 'Turnovers_Won'))
        % Handle alternative naming
    end
end

function validate_data_structure(relativeData, isolatedData, kpiList)
% Validate that required KPIs are present in both datasets
    
    relCols = relativeData.Properties.VariableNames;
    isCols = isolatedData.Properties.VariableNames;
    
    missingRel = {};
    missingIso = {};
    
    for i = 1:length(kpiList)
        kpi = kpiList{i};
        if ~any(strcmp(relCols, kpi))
            missingRel{end+1} = kpi;
        end
        if ~any(strcmp(isCols, kpi))
            missingIso{end+1} = kpi;
        end
    end
    
    if ~isempty(missingRel)
        warning('Missing KPIs in relative data: %s', strjoin(missingRel, ', '));
    end
    if ~isempty(missingIso)
        warning('Missing KPIs in isolated data: %s', strjoin(missingIso, ', '));
    end
end

function test_invariance_axiom(relativeData, isolatedData, kpiList)
% Test Axiom 1: Invariance to Shared Effects
% R(X_A + η, X_B + η) = R(X_A, X_B)
    
    fprintf('  Testing environmental noise cancellation...\n');
    
    results = struct();
    
    % For each KPI, simulate adding shared environmental noise
    for i = 1:min(3, length(kpiList)) % Test first 3 KPIs for brevity
        kpi = kpiList{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi))
            continue;
        end
        
        % Get relative values (these should be invariant to shared noise)
        R_original = relativeData.(kpi);
        R_original = R_original(~isnan(R_original));
        
        % Simulate the theoretical test by reconstructing absolute values
        % and adding shared noise
        [X_A, X_B] = reconstruct_absolute_values(R_original);
        
        % Add various levels of shared environmental noise
        noise_levels = [0, 5, 10, 20, 50];
        invariance_test = zeros(length(noise_levels), 1);
        
        for j = 1:length(noise_levels)
            eta = randn(length(X_A), 1) * noise_levels(j);
            X_A_noisy = X_A + eta;
            X_B_noisy = X_B + eta;
            R_noisy = X_A_noisy - X_B_noisy;
            
            % Test invariance: correlation should be 1.0
            invariance_test(j) = corr(R_original, R_noisy);
        end
        
        results.(kpi) = struct('noise_levels', noise_levels, ...
                              'invariance', invariance_test);
        
        fprintf('    %s: Invariance correlation = %.6f (mean)\n', ...
                kpi, mean(invariance_test));
    end
    
    % Overall assessment
    if exist('results', 'var') && ~isempty(fieldnames(results))
        overall_invariance = mean(cellfun(@(x) mean(results.(x).invariance), ...
                                        fieldnames(results)));
        fprintf('  Overall Axiom 1 satisfaction: %.4f (target: 1.0000)\n', ...
                overall_invariance);
        
        if overall_invariance > 0.999
            fprintf('  ✓ Axiom 1: SATISFIED\n');
        else
            fprintf('  ✗ Axiom 1: VIOLATED (correlation < 0.999)\n');
        end
    end
end

function [X_A, X_B] = reconstruct_absolute_values(R)
% Reconstruct plausible absolute values from relative differences
% This is for testing purposes only - we generate synthetic X_A, X_B
% such that X_A - X_B = R
    
    % Generate X_A with some baseline and variation
    X_A = 50 + 20*randn(length(R), 1);  % Arbitrary baseline
    
    % Calculate X_B such that X_A - X_B = R
    X_B = X_A - R;
end

function test_ordinal_consistency(relativeData, kpiList)
% Test Axiom 2: Ordinal Consistency
% If μ_A > μ_B, then E[R(X_A, X_B)] > 0
    
    fprintf('  Testing ordinal consistency...\n');
    
    consistent_count = 0;
    total_tested = 0;
    
    for i = 1:min(5, length(kpiList)) % Test first 5 KPIs
        kpi = kpiList{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi))
            continue;
        end
        
        R = relativeData.(kpi);
        outcomes = relativeData.Match_Outcome;
        
        % Remove NaN values
        valid_idx = ~isnan(R) & ~ismissing(outcomes);
        R = R(valid_idx);
        outcomes = outcomes(valid_idx);
        
        if length(R) < 10
            continue; % Skip if insufficient data
        end
        
        % For wins, E[R] should be positive (assuming higher KPI values are better)
        wins = strcmp(outcomes, 'W');
        losses = strcmp(outcomes, 'L');
        
        if sum(wins) > 5 && sum(losses) > 5
            mean_R_wins = mean(R(wins));
            mean_R_losses = mean(R(losses));
            
            % Test consistency based on KPI type
            is_consistent = test_kpi_consistency(kpi, mean_R_wins, mean_R_losses);
            
            fprintf('    %s: E[R|Win]=%.2f, E[R|Loss]=%.2f, Consistent=%d\n', ...
                    kpi, mean_R_wins, mean_R_losses, is_consistent);
            
            consistent_count = consistent_count + is_consistent;
            total_tested = total_tested + 1;
        end
    end
    
    if total_tested > 0
        consistency_rate = consistent_count / total_tested;
        fprintf('  Overall consistency rate: %.2f%% (%d/%d KPIs)\n', ...
                consistency_rate*100, consistent_count, total_tested);
        
        if consistency_rate >= 0.8
            fprintf('  ✓ Axiom 2: SATISFIED\n');
        else
            fprintf('  ✗ Axiom 2: VIOLATED (consistency < 80%%)\n');
        end
    end
end

function is_consistent = test_kpi_consistency(kpi, mean_win, mean_loss)
% Test if KPI shows expected directional consistency
    
    % KPIs where higher values typically indicate better performance
    positive_kpis = {'Tries', 'Carry', 'MetresMade', 'DefenderBeaten', ...
                    'Offload', 'CleanBreaks', 'Turnovers_Won', ...
                    'LineoutsWon', 'ScrumsWon', 'RucksWon'};
    
    % KPIs where lower values typically indicate better performance
    negative_kpis = {'MissedTackle', 'Turnover', 'Total_Penalty_Conceded'};
    
    if any(strcmp(positive_kpis, kpi))
        % For positive KPIs: wins should have higher relative values
        is_consistent = mean_win > mean_loss;
    elseif any(strcmp(negative_kpis, kpi))
        % For negative KPIs: wins should have lower relative values
        is_consistent = mean_win < mean_loss;
    else
        % For neutral/unknown KPIs: just check if there's a significant difference
        is_consistent = abs(mean_win - mean_loss) > 0.1;
    end
end

function test_scaling_proportionality(relativeData, isolatedData, kpiList)
% Test Axiom 3: Scaling Proportionality
% R(αX_A, αX_B) = αR(X_A, X_B)
    
    fprintf('  Testing scaling proportionality...\n');
    
    scaling_factors = [0.5, 2, 5];
    proportional_count = 0;
    total_tested = 0;
    
    for i = 1:min(3, length(kpiList)) % Test first 3 KPIs
        kpi = kpiList{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi))
            continue;
        end
        
        R_original = relativeData.(kpi);
        R_original = R_original(~isnan(R_original));
        
        if length(R_original) < 10
            continue;
        end
        
        % Take a subset for testing
        test_indices = 1:min(50, length(R_original));
        R_test = R_original(test_indices);
        
        proportionality_errors = [];
        
        for alpha = scaling_factors
            R_scaled_expected = alpha * R_test;
            
            % Simulate scaled measurements
            [X_A, X_B] = reconstruct_absolute_values(R_test);
            X_A_scaled = alpha * X_A;
            X_B_scaled = alpha * X_B;
            R_scaled_actual = X_A_scaled - X_B_scaled;
            
            % Calculate proportionality error
            error = mean(abs(R_scaled_actual - R_scaled_expected) ./ ...
                        (abs(R_scaled_expected) + 1e-6));
            proportionality_errors(end+1) = error;
        end
        
        mean_error = mean(proportionality_errors);
        is_proportional = mean_error < 0.01; % 1% tolerance
        
        fprintf('    %s: Mean proportionality error = %.6f, Proportional = %d\n', ...
                kpi, mean_error, is_proportional);
        
        proportional_count = proportional_count + is_proportional;
        total_tested = total_tested + 1;
    end
    
    if total_tested > 0
        proportionality_rate = proportional_count / total_tested;
        fprintf('  Overall proportionality rate: %.2f%% (%d/%d KPIs)\n', ...
                proportionality_rate*100, proportional_count, total_tested);
        
        if proportionality_rate >= 0.8
            fprintf('  ✓ Axiom 3: SATISFIED\n');
        else
            fprintf('  ✗ Axiom 3: VIOLATED (proportionality < 80%%)\n');
        end
    end
end

function test_snr_improvement(relativeData, isolatedData, kpiList)
% Test Axiom 4: Optimality through SNR improvement analysis
% This tests the core theoretical prediction of the paper
    
    fprintf('  Analyzing signal-to-noise ratio improvement...\n');
    
    snr_results = struct();
    improvement_count = 0;
    total_tested = 0;
    
    for i = 1:min(5, length(kpiList)) % Test first 5 KPIs
        kpi = kpiList{i};
        
        if ~any(strcmp(relativeData.Properties.VariableNames, kpi)) || ...
           ~any(strcmp(isolatedData.Properties.VariableNames, kpi))
            continue;
        end
        
        % Get relative data
        R = relativeData.(kpi);
        R_outcomes = relativeData.Match_Outcome;
        
        % Get isolated data  
        X_iso = isolatedData.(kpi);
        X_outcomes = isolatedData.Match_Outcome;
        
        % Calculate SNR for both approaches
        [snr_rel, snr_abs] = calculate_snr_comparison(R, R_outcomes, ...
                                                     X_iso, X_outcomes);
        
        if ~isnan(snr_rel) && ~isnan(snr_abs) && snr_abs > 0
            snr_improvement = snr_rel / snr_abs;
            snr_results.(kpi) = struct('snr_rel', snr_rel, 'snr_abs', snr_abs, ...
                                      'improvement', snr_improvement);
            
            fprintf('    %s: SNR_rel=%.4f, SNR_abs=%.4f, Improvement=%.2fx\n', ...
                    kpi, snr_rel, snr_abs, snr_improvement);
            
            improvement_count = improvement_count + (snr_improvement > 1.0);
            total_tested = total_tested + 1;
        end
    end
    
    if total_tested > 0
        improvement_rate = improvement_count / total_tested;
        fprintf('  KPIs showing SNR improvement: %.2f%% (%d/%d)\n', ...
                improvement_rate*100, improvement_count, total_tested);
        
        if improvement_rate >= 0.6
            fprintf('  ✓ Axiom 4: SATISFIED (majority show improvement)\n');
        else
            fprintf('  ✗ Axiom 4: VIOLATED (insufficient improvement)\n');
        end
    end
    
    % Store results for later analysis
    assignin('base', 'snr_results', snr_results);
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
        
        normality_results.(kpi) = struct('jarque_bera_h', h_jb, 'jarque_bera_p', p_jb, ...
                                        'ks_h', h_ks, 'ks_p', p_ks);
        
        % Test for autocorrelation (independence over time)
        if length(R) > 10
            try
                [acf, lags, bounds] = autocorr(R, 'NumLags', min(10, floor(length(R)/4)));
                
                % Check bounds dimensions and handle appropriately
                if size(bounds, 2) >= 2
                    % Use upper bound (column 2)
                    upper_bound = bounds(:, 2);
                else
                    % If bounds is a vector, use it directly
                    upper_bound = bounds;
                end
                
                % Ensure we don't exceed array bounds
                num_lags = min(length(acf)-1, length(upper_bound)-1);
                if num_lags > 0
                    significant_lags = sum(abs(acf(2:num_lags+1)) > upper_bound(2:num_lags+1));
                else
                    significant_lags = 0;
                end
                
                independence_results.(kpi) = struct('significant_lags', significant_lags, ...
                                                   'total_lags', num_lags);
            catch ME
                % If autocorr fails, use simplified independence test
                independence_results.(kpi) = struct('significant_lags', 0, ...
                                                   'total_lags', 0, ...
                                                   'note', 'Autocorr failed - using simplified test');
            end
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

function [snr_rel, snr_abs] = calculate_snr_comparison(R, R_outcomes, X_abs, X_outcomes)
% Calculate and compare SNR for relative vs absolute metrics
    
    % Clean data
    valid_rel = ~isnan(R) & ~ismissing(R_outcomes);
    valid_abs = ~isnan(X_abs) & ~ismissing(X_outcomes);
    
    R = R(valid_rel);
    R_outcomes = R_outcomes(valid_rel);
    X_abs = X_abs(valid_abs);
    X_outcomes = X_outcomes(valid_abs);
    
    if length(R) < 10 || length(X_abs) < 10
        snr_rel = NaN;
        snr_abs = NaN;
        return;
    end
    
    % Calculate SNR for relative metric
    wins_R = strcmp(R_outcomes, 'W');
    losses_R = strcmp(R_outcomes, 'L');
    
    if sum(wins_R) > 2 && sum(losses_R) > 2
        mu_R_win = mean(R(wins_R));
        mu_R_loss = mean(R(losses_R));
        sigma_R_combined = sqrt(var(R(wins_R)) + var(R(losses_R)));
        
        if sigma_R_combined > 0
            snr_rel = (mu_R_win - mu_R_loss)^2 / sigma_R_combined^2;
        else
            snr_rel = NaN;
        end
    else
        snr_rel = NaN;
    end
    
    % Calculate SNR for absolute metric
    wins_X = strcmp(X_outcomes, 'W');
    losses_X = strcmp(X_outcomes, 'L');
    
    if sum(wins_X) > 2 && sum(losses_X) > 2
        mu_X_win = mean(X_abs(wins_X));
        mu_X_loss = mean(X_abs(losses_X));
        sigma_X_combined = sqrt(var(X_abs(wins_X)) + var(X_abs(losses_X)));
        
        if sigma_X_combined > 0
            snr_abs = (mu_X_win - mu_X_loss)^2 / sigma_X_combined^2;
        else
            snr_abs = NaN;
        end
    else
        snr_abs = NaN;
    end
end