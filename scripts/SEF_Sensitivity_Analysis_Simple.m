function SEF_Sensitivity_Analysis_Simple()
    % SEF Framework Simplified Sensitivity Analysis
    % Works with the actual rugby data structure
    
    fprintf('=== SEF Framework Sensitivity Analysis (Simplified) ===\n');
    fprintf('Starting comprehensive sensitivity analysis...\n\n');
    
    % Prepare data first
    fprintf('--- Phase 0: Data Preparation ---\n');
    data_prepared = Prepare_Data_For_Sensitivity();
    
    % Initialize results structure
    results = struct();
    
    % Phase 1: Sample Size Sensitivity Analysis
    fprintf('\n--- Phase 1: Sample Size Sensitivity Analysis ---\n');
    results.sample_size = analyze_sample_size_sensitivity_simple(data_prepared);
    
    % Phase 2: Temporal Analysis
    fprintf('\n--- Phase 2: Temporal Analysis ---\n');
    results.temporal = analyze_temporal_behavior_simple(data_prepared);
    
    % Phase 3: Parameter Sensitivity Analysis
    fprintf('\n--- Phase 3: Parameter Sensitivity Analysis ---\n');
    results.parameter_sensitivity = analyze_parameter_sensitivity_simple(data_prepared);
    
    % Phase 4: Robustness Testing
    fprintf('\n--- Phase 4: Robustness Testing ---\n');
    results.robustness = analyze_robustness_simple(data_prepared);
    
    % Phase 5: Statistical Validation
    fprintf('\n--- Phase 5: Statistical Validation ---\n');
    results.validation = perform_statistical_validation_simple(data_prepared);
    
    % Generate comprehensive report
    fprintf('\n--- Generating Sensitivity Analysis Report ---\n');
    generate_sensitivity_report_simple(results);
    
    % Save results
    save('outputs/results/sef_sensitivity_analysis_results.mat', 'results');
    fprintf('✓ Sensitivity analysis complete. Results saved.\n');
end

function sample_results = analyze_sample_size_sensitivity_simple(data)
    % Analyze SEF sensitivity to sample size using bootstrap sampling
    
    fprintf('  Analyzing sample size sensitivity...\n');
    
    % Define sample sizes to test
    sample_sizes = [25, 50, 100, 200, 500, 1000];
    n_bootstrap = 100; % Number of bootstrap samples
    
    sample_results = struct();
    sample_results.sample_sizes = sample_sizes;
    sample_results.sef_means = zeros(size(sample_sizes));
    sample_results.sef_stds = zeros(size(sample_sizes));
    sample_results.sef_ci_lower = zeros(size(sample_sizes));
    sample_results.sef_ci_upper = zeros(size(sample_sizes));
    sample_results.convergence = zeros(size(sample_sizes));
    
    % Get all available data
    team_a_perf = data.matches.team_a_performance;
    team_b_perf = data.matches.team_b_performance;
    n_total = length(team_a_perf);
    
    for i = 1:length(sample_sizes)
        n_samples = sample_sizes(i);
        if n_samples > n_total
            n_samples = n_total;
        end
        
        % Bootstrap sampling
        sef_bootstrap = zeros(n_bootstrap, 1);
        
        for b = 1:n_bootstrap
            % Random sampling with replacement
            sample_indices = randsample(n_total, n_samples, true);
            sample_a = team_a_perf(sample_indices);
            sample_b = team_b_perf(sample_indices);
            
            % Calculate SEF for this bootstrap sample
            sef_bootstrap(b) = calculate_sef_simple(sample_a, sample_b);
        end
        
        % Calculate statistics
        sample_results.sef_means(i) = mean(sef_bootstrap);
        sample_results.sef_stds(i) = std(sef_bootstrap);
        sample_results.sef_ci_lower(i) = prctile(sef_bootstrap, 2.5);
        sample_results.sef_ci_upper(i) = prctile(sef_bootstrap, 97.5);
        
        % Convergence analysis (coefficient of variation)
        sample_results.convergence(i) = sample_results.sef_stds(i) / abs(sample_results.sef_means(i));
        
        fprintf('    Sample size %d: SEF = %.3f ± %.3f (CV = %.3f)\n', ...
                n_samples, sample_results.sef_means(i), sample_results.sef_stds(i), ...
                sample_results.convergence(i));
    end
    
    % Identify minimum sample size for convergence (CV < 0.1)
    convergence_threshold = 0.1;
    converged_indices = sample_results.convergence < convergence_threshold;
    if any(converged_indices)
        min_sample_size = sample_sizes(find(converged_indices, 1));
        sample_results.min_sample_size = min_sample_size;
        fprintf('  ✓ Minimum sample size for convergence: %d\n', min_sample_size);
    else
        sample_results.min_sample_size = NaN;
        fprintf('  ⚠ No convergence achieved within tested sample sizes\n');
    end
end

function temporal_results = analyze_temporal_behavior_simple(data)
    % Analyze SEF behavior across different time periods
    
    fprintf('  Analyzing temporal behavior...\n');
    
    temporal_results = struct();
    
    % Season-by-season analysis
    seasons = data.seasons;
    season_strings = data.season_strings;
    n_seasons = length(seasons);
    
    temporal_results.seasons = seasons;
    temporal_results.season_strings = season_strings;
    temporal_results.seasonal_sef = zeros(n_seasons, 1);
    temporal_results.seasonal_std = zeros(n_seasons, 1);
    
    team_a_perf = data.matches.team_a_performance;
    team_b_perf = data.matches.team_b_performance;
    season_data = data.matches.seasons;
    
    for s = 1:n_seasons
        season_mask = (season_data == seasons(s));
        if sum(season_mask) > 0
            season_a = team_a_perf(season_mask);
            season_b = team_b_perf(season_mask);
        else
            season_a = [];
            season_b = [];
        end
        
        if length(season_a) > 10 % Need minimum samples
            temporal_results.seasonal_sef(s) = calculate_sef_simple(season_a, season_b);
            temporal_results.seasonal_std(s) = std(season_a - season_b);
            
            fprintf('    Season %s: SEF = %.3f ± %.3f (n = %d)\n', ...
                    season_strings{s}, temporal_results.seasonal_sef(s), temporal_results.seasonal_std(s), length(season_a));
        else
            temporal_results.seasonal_sef(s) = NaN;
            temporal_results.seasonal_std(s) = NaN;
            fprintf('    Season %s: Insufficient data (n = %d)\n', season_strings{s}, length(season_a));
        end
    end
    
    % Temporal stability analysis
    valid_seasons = ~isnan(temporal_results.seasonal_sef);
    if sum(valid_seasons) > 1
        temporal_results.seasonal_cv = std(temporal_results.seasonal_sef(valid_seasons)) / mean(temporal_results.seasonal_sef(valid_seasons));
        temporal_results.temporal_trend = calculate_temporal_trend_simple(temporal_results.seasonal_sef(valid_seasons));
        
        fprintf('  ✓ Seasonal CV: %.3f, Trend: %.3f\n', ...
                temporal_results.seasonal_cv, temporal_results.temporal_trend);
    else
        temporal_results.seasonal_cv = NaN;
        temporal_results.temporal_trend = NaN;
        fprintf('  ⚠ Insufficient seasonal data for temporal analysis\n');
    end
end

function param_results = analyze_parameter_sensitivity_simple(data)
    % Analyze SEF sensitivity to κ and ρ parameters
    
    fprintf('  Analyzing parameter sensitivity...\n');
    
    param_results = struct();
    
    % Get baseline parameters
    team_a_perf = data.matches.team_a_performance;
    team_b_perf = data.matches.team_b_performance;
    
    sigma_a = std(team_a_perf);
    sigma_b = std(team_b_perf);
    rho_baseline = corr(team_a_perf, team_b_perf);
    kappa_baseline = (sigma_b^2) / (sigma_a^2);
    
    param_results.baseline_kappa = kappa_baseline;
    param_results.baseline_rho = rho_baseline;
    param_results.baseline_sef = data.sef_full;
    
    % κ (variance ratio) sensitivity
    kappa_range = logspace(-1, 1, 21); % 0.1 to 10
    param_results.kappa_range = kappa_range;
    param_results.kappa_sef = zeros(size(kappa_range));
    
    % ρ (correlation) sensitivity
    rho_range = -0.9:0.1:0.9;
    param_results.rho_range = rho_range;
    param_results.rho_sef = zeros(size(rho_range));
    
    % Test κ sensitivity
    for i = 1:length(kappa_range)
        param_results.kappa_sef(i) = (1 + kappa_range(i)) / (1 + kappa_range(i) - 2*sqrt(kappa_range(i))*rho_baseline);
    end
    
    % Test ρ sensitivity
    for i = 1:length(rho_range)
        param_results.rho_sef(i) = (1 + kappa_baseline) / (1 + kappa_baseline - 2*sqrt(kappa_baseline)*rho_range(i));
    end
    
    % Sensitivity indices
    param_results.kappa_sensitivity = calculate_sensitivity_index_simple(param_results.kappa_sef);
    param_results.rho_sensitivity = calculate_sensitivity_index_simple(param_results.rho_sef);
    
    fprintf('  ✓ κ sensitivity index: %.3f\n', param_results.kappa_sensitivity);
    fprintf('  ✓ ρ sensitivity index: %.3f\n', param_results.rho_sensitivity);
    fprintf('  ✓ Baseline κ: %.3f, ρ: %.3f, SEF: %.3f\n', kappa_baseline, rho_baseline, data.sef_full);
end

function robustness_results = analyze_robustness_simple(data)
    % Analyze SEF robustness to outliers, noise, and missing data
    
    fprintf('  Analyzing robustness...\n');
    
    robustness_results = struct();
    
    % Get baseline SEF
    team_a_perf = data.matches.team_a_performance;
    team_b_perf = data.matches.team_b_performance;
    baseline_sef = calculate_sef_simple(team_a_perf, team_b_perf);
    
    % Outlier sensitivity
    thresholds = [0, 0.05, 0.1, 0.2]; % Fraction of data to remove
    n_thresholds = length(thresholds);
    
    robustness_results.outlier_analysis = struct();
    robustness_results.outlier_analysis.thresholds = thresholds;
    robustness_results.outlier_analysis.sef_values = zeros(n_thresholds, 1);
    
    for i = 1:n_thresholds
        threshold = thresholds(i);
        if threshold == 0
            robustness_results.outlier_analysis.sef_values(i) = baseline_sef;
        else
            % Remove outliers from both arrays using the same mask
            q1_a = prctile(team_a_perf, 25);
            q3_a = prctile(team_a_perf, 75);
            iqr_a = q3_a - q1_a;
            outlier_threshold_a = q3_a + 1.5 * iqr_a;
            
            q1_b = prctile(team_b_perf, 25);
            q3_b = prctile(team_b_perf, 75);
            iqr_b = q3_b - q1_b;
            outlier_threshold_b = q3_b + 1.5 * iqr_b;
            
            outlier_mask = (team_a_perf <= outlier_threshold_a) & (team_b_perf <= outlier_threshold_b);
            cleaned_a = team_a_perf(outlier_mask);
            cleaned_b = team_b_perf(outlier_mask);
            
            if length(cleaned_a) > 10 % Need minimum samples
                robustness_results.outlier_analysis.sef_values(i) = calculate_sef_simple(cleaned_a, cleaned_b);
            else
                robustness_results.outlier_analysis.sef_values(i) = baseline_sef;
            end
        end
    end
    
    % Calculate sensitivity
    robustness_results.outlier_analysis.sensitivity = std(robustness_results.outlier_analysis.sef_values) / abs(mean(robustness_results.outlier_analysis.sef_values));
    
    % Noise sensitivity
    noise_levels = [0, 0.01, 0.05, 0.1, 0.2]; % Standard deviation of added noise
    n_levels = length(noise_levels);
    
    robustness_results.noise_analysis = struct();
    robustness_results.noise_analysis.noise_levels = noise_levels;
    robustness_results.noise_analysis.sef_values = zeros(n_levels, 1);
    
    for i = 1:n_levels
        noise_level = noise_levels(i);
        if noise_level == 0
            robustness_results.noise_analysis.sef_values(i) = baseline_sef;
        else
            noisy_a = team_a_perf + noise_level * std(team_a_perf) * randn(size(team_a_perf));
            noisy_b = team_b_perf + noise_level * std(team_b_perf) * randn(size(team_b_perf));
            robustness_results.noise_analysis.sef_values(i) = calculate_sef_simple(noisy_a, noisy_b);
        end
    end
    
    robustness_results.noise_analysis.sensitivity = std(robustness_results.noise_analysis.sef_values) / abs(mean(robustness_results.noise_analysis.sef_values));
    
    fprintf('  ✓ Outlier sensitivity: %.3f\n', robustness_results.outlier_analysis.sensitivity);
    fprintf('  ✓ Noise sensitivity: %.3f\n', robustness_results.noise_analysis.sensitivity);
end

function validation_results = perform_statistical_validation_simple(data)
    % Perform comprehensive statistical validation
    
    fprintf('  Performing statistical validation...\n');
    
    validation_results = struct();
    
    % Bootstrap test for SEF > 1
    n_bootstrap = 1000;
    sef_bootstrap = zeros(n_bootstrap, 1);
    
    team_a_perf = data.matches.team_a_performance;
    team_b_perf = data.matches.team_b_performance;
    n_total = length(team_a_perf);
    
    for i = 1:n_bootstrap
        % Bootstrap sample
        sample_indices = randsample(n_total, n_total, true);
        sample_a = team_a_perf(sample_indices);
        sample_b = team_b_perf(sample_indices);
        sef_bootstrap(i) = calculate_sef_simple(sample_a, sample_b);
    end
    
    % Calculate p-value for SEF > 1
    validation_results.significance = struct();
    validation_results.significance.p_value = sum(sef_bootstrap <= 1) / n_bootstrap;
    validation_results.significance.significant = validation_results.significance.p_value < 0.05;
    validation_results.significance.confidence_level = 0.95;
    validation_results.significance.effect_size = (mean(sef_bootstrap) - 1) / std(sef_bootstrap);
    
    % Confidence intervals
    validation_results.confidence_intervals = struct();
    validation_results.confidence_intervals.mean_sef = mean(sef_bootstrap);
    validation_results.confidence_intervals.std_sef = std(sef_bootstrap);
    validation_results.confidence_intervals.ci_95 = [prctile(sef_bootstrap, 2.5), prctile(sef_bootstrap, 97.5)];
    validation_results.confidence_intervals.ci_99 = [prctile(sef_bootstrap, 0.5), prctile(sef_bootstrap, 99.5)];
    
    if validation_results.significance.significant
        fprintf('  ✓ SEF > 1 significance: Yes (p = %.4f)\n', validation_results.significance.p_value);
    else
        fprintf('  ✓ SEF > 1 significance: No (p = %.4f)\n', validation_results.significance.p_value);
    end
    fprintf('  ✓ 95%% CI: [%.3f, %.3f]\n', ...
            validation_results.confidence_intervals.ci_95(1), validation_results.confidence_intervals.ci_95(2));
end

function sef_value = calculate_sef_simple(team_a, team_b)
    % Calculate SEF for given team performance data
    
    % Calculate means and standard deviations
    sigma_a = std(team_a);
    sigma_b = std(team_b);
    
    % Calculate correlation
    rho = corr(team_a, team_b);
    
    % Calculate κ and SEF
    if sigma_a > 0 && sigma_b > 0 && ~isnan(rho)
        kappa = (sigma_b^2) / (sigma_a^2);
        sef_value = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
    else
        sef_value = NaN;
    end
end

function trend = calculate_temporal_trend_simple(seasonal_sef)
    % Calculate temporal trend in seasonal SEF values
    
    n_seasons = length(seasonal_sef);
    if n_seasons < 2
        trend = 0;
        return;
    end
    
    % Simple linear trend
    x = (1:n_seasons)';
    p = polyfit(x, seasonal_sef, 1);
    trend = p(1); % Slope
end

function sensitivity_index = calculate_sensitivity_index_simple(sef_values)
    % Calculate sensitivity index for parameter variation
    
    % Remove NaN values
    valid_values = sef_values(~isnan(sef_values));
    
    if length(valid_values) < 2
        sensitivity_index = 0;
        return;
    end
    
    % Normalize SEF values
    sef_norm = (valid_values - min(valid_values)) / (max(valid_values) - min(valid_values));
    
    % Calculate sensitivity as the range of normalized SEF values
    sensitivity_index = max(sef_norm) - min(sef_norm);
end

function cleaned_data = remove_outliers_simple(data, threshold)
    % Remove outliers based on threshold using IQR method
    
    q1 = prctile(data, 25);
    q3 = prctile(data, 75);
    iqr = q3 - q1;
    outlier_threshold = q3 + 1.5 * iqr;
    
    % Remove outliers
    outlier_mask = data <= outlier_threshold;
    cleaned_data = data(outlier_mask);
end

function generate_sensitivity_report_simple(results)
    % Generate comprehensive sensitivity analysis report
    
    fprintf('\n=== SEF Sensitivity Analysis Report ===\n');
    
    % Sample size analysis
    if isfield(results, 'sample_size')
        fprintf('\n1. SAMPLE SIZE SENSITIVITY:\n');
        fprintf('   Minimum sample size for convergence: %d\n', results.sample_size.min_sample_size);
        if results.sample_size.min_sample_size < Inf
            fprintf('   Convergence threshold (CV < 0.1): Achieved\n');
        else
            fprintf('   Convergence threshold (CV < 0.1): Not achieved\n');
        end
    end
    
    % Temporal analysis
    if isfield(results, 'temporal')
        fprintf('\n2. TEMPORAL BEHAVIOR:\n');
        if isfield(results.temporal, 'seasonal_cv') && ~isnan(results.temporal.seasonal_cv)
            fprintf('   Seasonal coefficient of variation: %.3f\n', results.temporal.seasonal_cv);
        end
        if isfield(results.temporal, 'temporal_trend') && ~isnan(results.temporal.temporal_trend)
            fprintf('   Temporal trend: %.3f\n', results.temporal.temporal_trend);
        end
    end
    
    % Parameter sensitivity
    if isfield(results, 'parameter_sensitivity')
        fprintf('\n3. PARAMETER SENSITIVITY:\n');
        fprintf('   κ (variance ratio) sensitivity: %.3f\n', results.parameter_sensitivity.kappa_sensitivity);
        fprintf('   ρ (correlation) sensitivity: %.3f\n', results.parameter_sensitivity.rho_sensitivity);
        fprintf('   Baseline κ: %.3f, ρ: %.3f, SEF: %.3f\n', ...
                results.parameter_sensitivity.baseline_kappa, ...
                results.parameter_sensitivity.baseline_rho, ...
                results.parameter_sensitivity.baseline_sef);
    end
    
    % Robustness analysis
    if isfield(results, 'robustness')
        fprintf('\n4. ROBUSTNESS:\n');
        if isfield(results.robustness, 'outlier_analysis')
            fprintf('   Outlier sensitivity: %.3f\n', results.robustness.outlier_analysis.sensitivity);
        end
        if isfield(results.robustness, 'noise_analysis')
            fprintf('   Noise sensitivity: %.3f\n', results.robustness.noise_analysis.sensitivity);
        end
    end
    
    % Statistical validation
    if isfield(results, 'validation')
        fprintf('\n5. STATISTICAL VALIDATION:\n');
        if isfield(results.validation, 'significance')
            if results.validation.significance.significant
                fprintf('   SEF > 1 significance: Yes (p = %.4f)\n', ...
                        results.validation.significance.p_value);
            else
                fprintf('   SEF > 1 significance: No (p = %.4f)\n', ...
                        results.validation.significance.p_value);
            end
        end
        if isfield(results.validation, 'confidence_intervals')
            fprintf('   95%% CI: [%.3f, %.3f]\n', results.validation.confidence_intervals.ci_95(1), ...
                    results.validation.confidence_intervals.ci_95(2));
        end
    end
    
    fprintf('\n=== End of Sensitivity Analysis Report ===\n');
end
