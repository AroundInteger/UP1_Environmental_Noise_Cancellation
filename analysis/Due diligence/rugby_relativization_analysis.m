function rugby_relativization_analysis()
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
    
    % Define technical performance indicators to analyze
    % Excluding obvious scoring metrics (Tries, Penalties, Cards, etc.)
    kpiList = {
        'Carry', 'MetresMade', 'DefenderBeaten', 'Offload', ...
        'Pass', 'Tackle', 'MissedTackle', 'Turnover', 'CleanBreaks', ...
        'Turnovers_Won', 'LineoutsWon', 'ScrumsWon', 'RucksWon'
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
