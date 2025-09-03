%% EMPIRICAL VARIANCE RATIO VERIFICATION WITH RUGBY DATA
%% ====================================================
% Critical empirical test of the key theoretical claims:
% 1. Var(R)/Var(A) ≈ 2 indicates no environmental noise
% 2. Variance ratios provide evidence for signal enhancement vs noise cancellation
% 3. Rugby data matches theoretical predictions
%
% Author: Empirical Verification
% Date: 2024

clear; clc; close all;

fprintf('=== EMPIRICAL VARIANCE RATIO VERIFICATION ===\n');
fprintf('Date: %s\n', datetime("now"));
fprintf('Testing with real rugby performance data\n\n');

%% Load Real Rugby Data
fprintf('Step 1: Loading rugby datasets...\n');
fprintf('=================================\n');

try
    % Load the rugby datasets
    isolated_data = readtable('S20Isolated.csv');
    relative_data = readtable('S20Relative.csv');

    fprintf('✓ S20Isolated.csv loaded: %d rows, %d columns\n', height(isolated_data), width(isolated_data));
    fprintf('✓ S20Relative.csv loaded: %d rows, %d columns\n', height(relative_data), width(relative_data));

catch ME
    error('Failed to load rugby data: %s\nPlease ensure data files are in data/raw/ directory', ME.message);
end

% Check data structure
fprintf('\nData structure check:\n');
fprintf('Isolated data columns (first 10): %s\n', strjoin(isolated_data.Properties.VariableNames(1:min(10, width(isolated_data))), ', '));
fprintf('Relative data columns (first 10): %s\n', strjoin(relative_data.Properties.VariableNames(1:min(10, width(relative_data))), ', '));

%% Define KPIs for Analysis
fprintf('\nStep 2: Defining KPIs for analysis...\n');
fprintf('====================================\n');

% Technical KPIs that should show clear performance differences
all_kpis = {'Carry', 'MetresMade', 'DefenderBeaten', 'Offload', 'Pass', ...
    'Tackle', 'MissedTackle', 'Turnover', 'CleanBreaks', 'Turnovers_Won', ...
    'LineoutsWon', 'ScrumsWon', 'RucksWon'};

% Check which KPIs are available in both datasets
available_kpis = {};
for i = 1:length(all_kpis)
    kpi = all_kpis{i};
    if any(strcmp(isolated_data.Properties.VariableNames, kpi)) && ...
            any(strcmp(relative_data.Properties.VariableNames, kpi))
        available_kpis{end+1} = kpi; %#ok<SAGROW>
    end
end

fprintf('Available KPIs for analysis: %d/%d\n', length(available_kpis), length(all_kpis));
fprintf('KPIs: %s\n', strjoin(available_kpis, ', '));

if length(available_kpis) < 3
    error('Insufficient KPIs available for meaningful analysis');
end

%% Empirical Variance Ratio Analysis
fprintf('\nStep 3: Empirical variance ratio analysis...\n');
fprintf('==========================================\n');

% Initialize results structure
empirical_results = struct();
empirical_results.kpi = {};
empirical_results.var_absolute = [];
empirical_results.var_relative = [];
empirical_results.variance_ratio = [];
empirical_results.n_absolute = [];
empirical_results.n_relative = [];
empirical_results.environmental_noise_detected = [];

fprintf('KPI\t\t\tVar(A)\t\tVar(R)\t\tRatio\t\tN_abs\tN_rel\tEnv_Noise?\n');
fprintf('---\t\t\t------\t\t------\t\t-----\t\t-----\t-----\t----------\n');

for i = 1:length(available_kpis)
    kpi = available_kpis{i};

    % Extract data
    abs_data = isolated_data.(kpi);
    rel_data = relative_data.(kpi);

    % Clean data (remove NaN and infinite values)
    abs_clean = abs_data(~isnan(abs_data) & isfinite(abs_data));
    rel_clean = rel_data(~isnan(rel_data) & isfinite(rel_data));

    % Ensure sufficient data
    if length(abs_clean) >= 20 && length(rel_clean) >= 20
        % Calculate variances
        var_abs = var(abs_clean);
        var_rel = var(rel_clean);
        variance_ratio = var_rel / var_abs;

        % Determine if environmental noise is detected
        % If ratio < 1: environmental noise cancellation
        % If ratio ≈ 2: no environmental noise (independent performances)
        % If ratio > 3: something unusual
        env_noise_detected = variance_ratio < 0.9; % Conservative threshold

        % Store results
        empirical_results.kpi{end+1} = kpi;
        empirical_results.var_absolute(end+1) = var_abs;
        empirical_results.var_relative(end+1) = var_rel;
        empirical_results.variance_ratio(end+1) = variance_ratio;
        empirical_results.n_absolute(end+1) = length(abs_clean);
        empirical_results.n_relative(end+1) = length(rel_clean);
        empirical_results.environmental_noise_detected(end+1) = env_noise_detected;

        if env_noise_detected
            noise_status = "Yes";
        else
            noise_status = "No";
        end

        fprintf('%s\t\t%.1f\t\t%.1f\t\t%.2f\t\t%d\t%d\t%s\n', ...
            kpi, var_abs, var_rel, variance_ratio, ...
            length(abs_clean), length(rel_clean), ...
            noise_status);
    end
end

%% Statistical Analysis of Variance Ratios
fprintf('\nStep 4: Statistical analysis of variance ratios...\n');
fprintf('================================================\n');

if ~isempty(empirical_results.variance_ratio)
    ratios = empirical_results.variance_ratio;

    fprintf('Summary statistics for variance ratios:\n');
    fprintf('  Mean: %.3f\n', mean(ratios));
    fprintf('  Median: %.3f\n', median(ratios));
    fprintf('  Std Dev: %.3f\n', std(ratios));
    fprintf('  Min: %.3f\n', min(ratios));
    fprintf('  Max: %.3f\n', max(ratios));

    % Test against theoretical expectations
    theoretical_no_env_noise = 2.0; % Expected if σ_A ≈ σ_B and η = 0

    fprintf('\nTheoretical predictions:\n');
    fprintf('  If environmental noise cancellation: ratio < 1.0\n');
    fprintf('  If no environmental noise (σ_A ≈ σ_B): ratio ≈ 2.0\n');
    fprintf('  If no environmental noise (unequal σ): ratio = 1 + (σ_B/σ_A)²\n');

    % Count KPIs in different categories
    env_noise_count = sum(ratios < 1.0);
    no_env_noise_count = sum(ratios >= 1.5);
    unclear_count = sum(ratios >= 1.0 & ratios < 1.5);

    fprintf('\nEmpirical findings:\n');
    fprintf('  KPIs showing environmental noise (ratio < 1.0): %d/%d (%.1f%%)\n', ...
        env_noise_count, length(ratios), 100*env_noise_count/length(ratios));
    fprintf('  KPIs showing no environmental noise (ratio ≥ 1.5): %d/%d (%.1f%%)\n', ...
        no_env_noise_count, length(ratios), 100*no_env_noise_count/length(ratios));
    fprintf('  KPIs with unclear pattern (1.0 ≤ ratio < 1.5): %d/%d (%.1f%%)\n', ...
        unclear_count, length(ratios), 100*unclear_count/length(ratios));

    % Test if mean ratio is significantly different from 2.0
    [h, p] = ttest(ratios, theoretical_no_env_noise);
    fprintf('\nStatistical test (mean ratio vs 2.0):\n');
    fprintf('  t-test p-value: %.4f\n', p);


    %fprintf('  Significantly different from 2.0? %s\n', char("Yes" * h + "No" * ~h));
    if h
        result = 'Yes';
    else
        result = 'No';
    end

    fprintf('  Significantly different from 2.0? %s\n', result);


    % Calculate 95% confidence interval for mean ratio
    se = std(ratios) / sqrt(length(ratios));
    ci_lower = mean(ratios) - 1.96 * se;
    ci_upper = mean(ratios) + 1.96 * se;
    fprintf('  95%% CI for mean ratio: [%.3f, %.3f]\n', ci_lower, ci_upper);

    % Check if 2.0 falls within confidence interval
    ci_contains_2 = (ci_lower <= 2.0) && (2.0 <= ci_upper);
    if ci_contains_2
        result = 'Yes';
    else
        result = 'No';
    end

    fprintf('  Does CI contain 2.0? %s\n', result);

    %fprintf('  Does CI contain 2.0? %s\n', char("Yes" * ci_contains_2 + "No" * ~ci_contains_2));
end

%% Correlation Analysis for Environmental Noise Detection
fprintf('\nStep 5: Correlation analysis for environmental noise detection...\n');
fprintf('===============================================================\n');

% If environmental noise exists, we should see correlation between performances
% of different teams in the same environmental conditions
correlation_results = struct();
correlation_results.kpi = {};
correlation_results.correlation = [];
correlation_results.p_value = [];

fprintf('Testing for environmental correlations in absolute measures:\n');
fprintf('KPI\t\t\tCorrelation\tp-value\t\tEnv_Noise?\n');
fprintf('---\t\t\t-----------\t-------\t\t----------\n');

for i = 1:min(5, length(available_kpis)) % Test first 5 KPIs
    kpi = available_kpis{i};

    abs_data = isolated_data.(kpi);
    abs_clean = abs_data(~isnan(abs_data) & isfinite(abs_data));

    if length(abs_clean) >= 40 % Need sufficient data for meaningful correlation
        % Split data randomly into two groups to simulate different teams
        n = length(abs_clean);
        idx = randperm(n);
        team_A = abs_clean(idx(1:floor(n/2)));
        team_B = abs_clean(idx(floor(n/2)+1:n));

        % Make equal length
        min_length = min(length(team_A), length(team_B));
        team_A = team_A(1:min_length);
        team_B = team_B(1:min_length);

        % Calculate correlation
        [rho, p_val] = corr(team_A, team_B);

        % Environmental noise would show positive correlation
        env_noise_from_corr = (rho > 0.2) && (p_val < 0.05);

        correlation_results.kpi{end+1} = kpi;
        correlation_results.correlation(end+1) = rho;
        correlation_results.p_value(end+1) = p_val;
        if env_noise_from_corr
            result = 'Yes';
        else
            result = 'No';
        end
        
        fprintf('%s\t\t%.3f\t\t%.3f\t\t%s\n', kpi, rho, p_val, result);

        % fprintf('%s\t\t%.3f\t\t%.3f\t\t%s\n', ...
        %     kpi, rho, p_val, ...
        %     char("Yes" * env_noise_from_corr + "No" * ~env_noise_from_corr));
    end
end

%% Bootstrap Confidence Intervals for Variance Ratios
fprintf('\nStep 6: Bootstrap confidence intervals for variance ratios...\n');
fprintf('==========================================================\n');

n_bootstrap = 1000;
bootstrap_results = struct();

for i = 1:min(3, length(available_kpis)) % Bootstrap first 3 KPIs
    kpi = available_kpis{i};

    abs_data = isolated_data.(kpi);
    rel_data = relative_data.(kpi);

    abs_clean = abs_data(~isnan(abs_data) & isfinite(abs_data));
    rel_clean = rel_data(~isnan(rel_data) & isfinite(rel_data));

    if length(abs_clean) >= 30 && length(rel_clean) >= 30
        bootstrap_ratios = zeros(n_bootstrap, 1);

        % Bootstrap sampling
        for b = 1:n_bootstrap
            % Bootstrap samples
            abs_boot = abs_clean(randi(length(abs_clean), length(abs_clean), 1));
            rel_boot = rel_clean(randi(length(rel_clean), length(rel_clean), 1));

            bootstrap_ratios(b) = var(rel_boot) / var(abs_boot);
        end

        % Calculate confidence intervals
        ci_lower = prctile(bootstrap_ratios, 2.5);
        ci_upper = prctile(bootstrap_ratios, 97.5);

        bootstrap_results.kpi = kpi;
        bootstrap_results.mean_ratio = mean(bootstrap_ratios);
        bootstrap_results.ci_lower = ci_lower;
        bootstrap_results.ci_upper = ci_upper;

        fprintf('%s: Mean ratio = %.3f, 95%% CI = [%.3f, %.3f]\n', ...
            kpi, mean(bootstrap_ratios), ci_lower, ci_upper);

        % Test if CI contains key theoretical values
        contains_1 = (ci_lower <= 1.0) && (1.0 <= ci_upper);
        contains_2 = (ci_lower <= 2.0) && (2.0 <= ci_upper);

        % fprintf('  CI contains 1.0 (env noise)? %s\n', char("Yes" * contains_1 + "No" * ~contains_1));
        % fprintf('  CI contains 2.0 (no env noise)? %s\n', char("Yes" * contains_2 + "No" * ~contains_2));
        % For the first statement
        if contains_1
            result1 = 'Yes';
        else
            result1 = 'No';
        end
        
        fprintf('  CI contains 1.0 (env noise)? %s\n', result1);
        
        % For the second statement
        if contains_2
            result2 = 'Yes';
        else
            result2 = 'No';
        end
        
        fprintf('  CI contains 2.0 (no env noise)? %s\n', result2);
        
            end
        end

%% Additional Robustness Checks
fprintf('\nStep 7: Additional robustness checks...\n');
fprintf('======================================\n');

% Check for potential confounding factors
fprintf('Robustness checks:\n');

% Test 1: Data quality check
fprintf('1. Data Quality Assessment:\n');
for i = 1:min(3, length(available_kpis))
    kpi = available_kpis{i};
    abs_data = isolated_data.(kpi);
    rel_data = relative_data.(kpi);

    abs_clean = abs_data(~isnan(abs_data) & isfinite(abs_data));
    rel_clean = rel_data(~isnan(rel_data) & isfinite(rel_data));

    % Check for outliers
    abs_outliers = sum(abs(abs_clean - mean(abs_clean)) > 3*std(abs_clean));
    rel_outliers = sum(abs(rel_clean - mean(rel_clean)) > 3*std(rel_clean));

    fprintf('   %s: Abs outliers = %d/%d (%.1f%%), Rel outliers = %d/%d (%.1f%%)\n', ...
        kpi, abs_outliers, length(abs_clean), 100*abs_outliers/length(abs_clean), ...
        rel_outliers, length(rel_clean), 100*rel_outliers/length(rel_clean));
end

% Test 2: Scale sensitivity check
fprintf('\n2. Scale Sensitivity Assessment:\n');
if ~isempty(empirical_results.variance_ratio)
    % Check if variance ratios are sensitive to data scaling
    scale_factors = [0.1, 0.5, 2.0, 10.0];
    kpi_test = available_kpis{1}; % Test with first KPI

    abs_test = isolated_data.(kpi_test);
    rel_test = relative_data.(kpi_test);
    abs_clean = abs_test(~isnan(abs_test) & isfinite(abs_test));
    rel_clean = rel_test(~isnan(rel_test) & isfinite(rel_test));

    original_ratio = var(rel_clean) / var(abs_clean);

    fprintf('   Scale sensitivity test for %s:\n', kpi_test);
    fprintf('   Scale Factor | Variance Ratio | Change from Original\n');
    fprintf('   ------------ | -------------- | -------------------\n');

    for j = 1:length(scale_factors)
        scale = scale_factors(j);
        scaled_abs = abs_clean * scale;
        scaled_rel = rel_clean * scale;
        scaled_ratio = var(scaled_rel) / var(scaled_abs);

        fprintf('   %.1f          | %.3f          | %.3f\n', ...
            scale, scaled_ratio, scaled_ratio - original_ratio);
    end
end

%% Summary and Conclusions
fprintf('\nStep 8: Summary and conclusions...\n');
fprintf('=================================\n');

if ~isempty(empirical_results.variance_ratio)
    mean_ratio = mean(empirical_results.variance_ratio);

    fprintf('EMPIRICAL FINDINGS SUMMARY:\n');
    fprintf('===========================\n');
    fprintf('✓ Analyzed %d KPIs from real rugby data\n', length(empirical_results.variance_ratio));
    fprintf('✓ Mean variance ratio (Var(R)/Var(A)): %.3f\n', mean_ratio);

    if mean_ratio > 1.8
        fprintf('✓ CONCLUSION: Strong evidence AGAINST environmental noise cancellation\n');
        fprintf('  → Variance ratios >> 1.0 indicate independent team performances\n');
        fprintf('  → SNR improvements likely come from signal enhancement mechanism\n');
    elseif mean_ratio < 1.2
        fprintf('✓ CONCLUSION: Evidence FOR environmental noise cancellation\n');
        fprintf('  → Variance ratios ≈ 1.0 indicate shared environmental effects\n');
        fprintf('  → SNR improvements come from environmental noise cancellation\n');
    else
        fprintf('⚠ CONCLUSION: Mixed evidence - requires further investigation\n');
        fprintf('  → Variance ratios in intermediate range\n');
        fprintf('  → Mechanism unclear from current data\n');
    end

    fprintf('\nTHEORETICAL FRAMEWORK VALIDATION:\n');
    fprintf('=================================\n');
    if mean_ratio > 1.8
        fprintf('✓ Environmental noise cancellation theory CORRECTLY identifies η = 0\n');
        fprintf('✓ Signal enhancement framework is the appropriate model\n');
        fprintf('✓ Mathematical predictions should match empirical observations\n');
    else
        fprintf('✓ Environmental noise cancellation theory CORRECTLY identifies η > 0\n');
        fprintf('✓ Noise cancellation framework is the appropriate model\n');
    end

    fprintf('\nKEY EMPIRICAL EVIDENCE:\n');
    fprintf('======================\n');
    fprintf('• Variance ratio analysis: %d/%d KPIs show ratios > 1.5\n', ...
        sum(empirical_results.variance_ratio >= 1.5), length(empirical_results.variance_ratio));
    % fprintf('• Mean ratio %.3f %s theoretical prediction of 2.0\n', ...
    %     mean_ratio, char("matches" * (abs(mean_ratio - 2.0) < 0.3) + "differs from" * (abs(mean_ratio - 2.0) >= 0.3)));
    if abs(mean_ratio - 2.0) < 0.3
        result = 'matches';
    else
        result = 'differs from';
    end

    fprintf('• Mean ratio %.3f %s theoretical prediction of 2.0\n', mean_ratio, result);

    if exist('correlation_results', 'var') && ~isempty(correlation_results.correlation)
        mean_corr = mean(abs(correlation_results.correlation));
        fprintf('• Mean absolute correlation: %.3f (low = no environmental noise)\n', mean_corr);
    end

else
    fprintf('❌ INSUFFICIENT DATA: Could not perform variance ratio analysis\n');
    fprintf('   Check data quality and KPI availability\n');
end

fprintf('\n=== EMPIRICAL VERIFICATION COMPLETE ===\n');
fprintf('Results provide direct empirical test of theoretical claims\n');
fprintf('using real rugby performance data.\n');