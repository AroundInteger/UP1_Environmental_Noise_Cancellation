function SEF_Sensitivity_Analysis()
    % SEF Framework Comprehensive Sensitivity Analysis
    % Implements systematic testing of SEF robustness and reliability
    
    fprintf('=== SEF Framework Sensitivity Analysis ===\n');
    fprintf('Starting comprehensive sensitivity analysis...\n\n');
    
    % Load the rugby dataset
    try
        load('data/processed/rugby_analysis_ready.mat');
        data = analysis_data; % Use the correct variable name
        fprintf('✓ Loaded rugby dataset successfully\n');
    catch
        error('Failed to load rugby dataset. Please ensure data/processed/rugby_analysis_ready.mat exists');
    end
    
    % Initialize results structure
    results = struct();
    
    % Phase 1: Sample Size and Temporal Analysis
    fprintf('\n--- Phase 1: Sample Size and Temporal Analysis ---\n');
    results.sample_size = analyze_sample_size_sensitivity(data);
    results.temporal = analyze_temporal_behavior(data);
    
    % Phase 2: Parameter Sensitivity Analysis
    fprintf('\n--- Phase 2: Parameter Sensitivity Analysis ---\n');
    results.parameter_sensitivity = analyze_parameter_sensitivity(data);
    
    % Phase 3: Robustness Testing
    fprintf('\n--- Phase 3: Robustness Testing ---\n');
    results.robustness = analyze_robustness(data);
    
    % Phase 4: Statistical Validation
    fprintf('\n--- Phase 4: Statistical Validation ---\n');
    results.validation = perform_statistical_validation(data);
    
    % Generate comprehensive report
    fprintf('\n--- Generating Sensitivity Analysis Report ---\n');
    generate_sensitivity_report(results);
    
    % Save results
    save('outputs/results/sef_sensitivity_analysis_results.mat', 'results');
    fprintf('✓ Sensitivity analysis complete. Results saved.\n');
end

function sample_results = analyze_sample_size_sensitivity(data)
    % Analyze SEF sensitivity to sample size using bootstrap sampling
    
    fprintf('  Analyzing sample size sensitivity...\n');
    
    % Define sample sizes to test
    sample_sizes = [10, 25, 50, 100, 200, 500, 1000];
    n_bootstrap = 100; % Number of bootstrap samples
    
    sample_results = struct();
    sample_results.sample_sizes = sample_sizes;
    sample_results.sef_means = zeros(size(sample_sizes));
    sample_results.sef_stds = zeros(size(sample_sizes));
    sample_results.sef_ci_lower = zeros(size(sample_sizes));
    sample_results.sef_ci_upper = zeros(size(sample_sizes));
    sample_results.convergence = zeros(size(sample_sizes));
    
    % Get all available data
    all_matches = data.matches;
    n_total = height(all_matches);
    
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
            sample_data = all_matches(sample_indices, :);
            
            % Calculate SEF for this bootstrap sample
            sef_bootstrap(b) = calculate_sef_for_sample(sample_data);
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

function temporal_results = analyze_temporal_behavior(data)
    % Analyze SEF behavior across different time periods
    
    fprintf('  Analyzing temporal behavior...\n');
    
    temporal_results = struct();
    
    % Season-by-season analysis
    if isfield(data, 'seasons')
        seasons = unique(data.seasons);
        n_seasons = length(seasons);
        
        temporal_results.seasons = seasons;
        temporal_results.seasonal_sef = zeros(n_seasons, 1);
        temporal_results.seasonal_std = zeros(n_seasons, 1);
        
        for s = 1:n_seasons
            season_data = data.matches(data.seasons == seasons(s), :);
            temporal_results.seasonal_sef(s) = calculate_sef_for_sample(season_data);
            temporal_results.seasonal_std(s) = std(season_data.SEF);
            
            fprintf('    Season %d: SEF = %.3f ± %.3f\n', ...
                    seasons(s), temporal_results.seasonal_sef(s), temporal_results.seasonal_std(s));
        end
        
        % Temporal stability analysis
        temporal_results.seasonal_cv = std(temporal_results.seasonal_sef) / mean(temporal_results.seasonal_sef);
        temporal_results.temporal_trend = calculate_temporal_trend(temporal_results.seasonal_sef);
        
        fprintf('  ✓ Seasonal CV: %.3f, Trend: %.3f\n', ...
                temporal_results.seasonal_cv, temporal_results.temporal_trend);
    end
    
    % Rolling window analysis
    if isfield(data, 'dates')
        temporal_results.rolling_window = analyze_rolling_windows(data);
    end
end

function param_results = analyze_parameter_sensitivity(data)
    % Analyze SEF sensitivity to κ and ρ parameters
    
    fprintf('  Analyzing parameter sensitivity...\n');
    
    param_results = struct();
    
    % κ (variance ratio) sensitivity
    kappa_range = logspace(-1, 1, 21); % 0.1 to 10
    param_results.kappa_range = kappa_range;
    param_results.kappa_sef = zeros(size(kappa_range));
    
    % ρ (correlation) sensitivity
    rho_range = -1:0.1:1;
    param_results.rho_range = rho_range;
    param_results.rho_sef = zeros(size(rho_range));
    
    % Calculate baseline SEF
    baseline_sef = calculate_sef_for_sample(data.matches);
    param_results.baseline_sef = baseline_sef;
    
    % Test κ sensitivity
    for i = 1:length(kappa_range)
        param_results.kappa_sef(i) = calculate_sef_with_kappa(data.matches, kappa_range(i));
    end
    
    % Test ρ sensitivity
    for i = 1:length(rho_range)
        param_results.rho_sef(i) = calculate_sef_with_rho(data.matches, rho_range(i));
    end
    
    % Parameter space mapping
    param_results.parameter_space = map_parameter_space(kappa_range, rho_range);
    
    % Sensitivity indices
    param_results.kappa_sensitivity = calculate_sensitivity_index(param_results.kappa_sef, kappa_range);
    param_results.rho_sensitivity = calculate_sensitivity_index(param_results.rho_sef, rho_range);
    
    fprintf('  ✓ κ sensitivity index: %.3f\n', param_results.kappa_sensitivity);
    fprintf('  ✓ ρ sensitivity index: %.3f\n', param_results.rho_sensitivity);
end

function robustness_results = analyze_robustness(data)
    % Analyze SEF robustness to outliers, noise, and missing data
    
    fprintf('  Analyzing robustness...\n');
    
    robustness_results = struct();
    
    % Outlier sensitivity
    robustness_results.outlier_analysis = analyze_outlier_sensitivity(data);
    
    % Noise sensitivity
    robustness_results.noise_analysis = analyze_noise_sensitivity(data);
    
    % Missing data sensitivity
    robustness_results.missing_data_analysis = analyze_missing_data_sensitivity(data);
    
    fprintf('  ✓ Robustness analysis complete\n');
end

function validation_results = perform_statistical_validation(data)
    % Perform comprehensive statistical validation
    
    fprintf('  Performing statistical validation...\n');
    
    validation_results = struct();
    
    % Cross-validation
    validation_results.cv_results = perform_cross_validation(data);
    
    % Statistical significance testing
    validation_results.significance = test_sef_significance(data);
    
    % Bootstrap confidence intervals
    validation_results.confidence_intervals = calculate_bootstrap_ci(data);
    
    % Model comparison
    validation_results.model_comparison = compare_models(data);
    
    fprintf('  ✓ Statistical validation complete\n');
end

function sef_value = calculate_sef_for_sample(sample_data)
    % Calculate SEF for a given sample of data
    
    % Extract team A and team B performance
    team_a_perf = sample_data.team_a_performance;
    team_b_perf = sample_data.team_b_performance;
    
    % Calculate means and standard deviations
    mu_a = mean(team_a_perf);
    mu_b = mean(team_b_perf);
    sigma_a = std(team_a_perf);
    sigma_b = std(team_b_perf);
    
    % Calculate correlation
    rho = corr(team_a_perf, team_b_perf);
    
    % Calculate κ and SEF
    if sigma_a > 0 && sigma_b > 0
        kappa = (sigma_b^2) / (sigma_a^2);
        sef_value = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
    else
        sef_value = NaN;
    end
end

function sef_value = calculate_sef_with_kappa(data, kappa)
    % Calculate SEF with fixed κ value
    
    team_a_perf = data.team_a_performance;
    team_b_perf = data.team_b_performance;
    
    rho = corr(team_a_perf, team_b_perf);
    sef_value = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
end

function sef_value = calculate_sef_with_rho(data, rho)
    % Calculate SEF with fixed ρ value
    
    team_a_perf = data.team_a_performance;
    team_b_perf = data.team_b_performance;
    
    sigma_a = std(team_a_perf);
    sigma_b = std(team_b_perf);
    
    if sigma_a > 0 && sigma_b > 0
        kappa = (sigma_b^2) / (sigma_a^2);
        sef_value = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
    else
        sef_value = NaN;
    end
end

function trend = calculate_temporal_trend(seasonal_sef)
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

function parameter_space = map_parameter_space(kappa_range, rho_range)
    % Map SEF values across the full parameter space
    
    [K, R] = meshgrid(kappa_range, rho_range);
    SEF = zeros(size(K));
    
    for i = 1:size(K, 1)
        for j = 1:size(K, 2)
            kappa = K(i, j);
            rho = R(i, j);
            SEF(i, j) = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
        end
    end
    
    parameter_space.kappa = K;
    parameter_space.rho = R;
    parameter_space.sef = SEF;
end

function sensitivity_index = calculate_sensitivity_index(sef_values, parameter_values)
    % Calculate sensitivity index for parameter variation
    
    % Normalize SEF values
    sef_norm = (sef_values - min(sef_values)) / (max(sef_values) - min(sef_values));
    
    % Calculate sensitivity as the range of normalized SEF values
    sensitivity_index = max(sef_norm) - min(sef_norm);
end

function outlier_results = analyze_outlier_sensitivity(data)
    % Analyze SEF sensitivity to outliers
    
    outlier_results = struct();
    
    % Calculate baseline SEF
    baseline_sef = calculate_sef_for_sample(data.matches);
    
    % Test different outlier removal thresholds
    thresholds = [0, 0.01, 0.05, 0.1, 0.2]; % Fraction of data to remove
    n_thresholds = length(thresholds);
    
    outlier_results.thresholds = thresholds;
    outlier_results.sef_values = zeros(n_thresholds, 1);
    
    for i = 1:n_thresholds
        threshold = thresholds(i);
        if threshold == 0
            % No outlier removal
            outlier_results.sef_values(i) = baseline_sef;
        else
            % Remove outliers
            cleaned_data = remove_outliers(data.matches, threshold);
            outlier_results.sef_values(i) = calculate_sef_for_sample(cleaned_data);
        end
    end
    
    % Calculate sensitivity
    outlier_results.sensitivity = std(outlier_results.sef_values) / abs(mean(outlier_results.sef_values));
end

function noise_results = analyze_noise_sensitivity(data)
    % Analyze SEF sensitivity to noise
    
    noise_results = struct();
    
    % Test different noise levels
    noise_levels = [0, 0.01, 0.05, 0.1, 0.2]; % Standard deviation of added noise
    n_levels = length(noise_levels);
    
    noise_results.noise_levels = noise_levels;
    noise_results.sef_values = zeros(n_levels, 1);
    
    for i = 1:n_levels
        noise_level = noise_levels(i);
        if noise_level == 0
            % No noise
            noise_results.sef_values(i) = calculate_sef_for_sample(data.matches);
        else
            % Add noise
            noisy_data = add_noise(data.matches, noise_level);
            noise_results.sef_values(i) = calculate_sef_for_sample(noisy_data);
        end
    end
    
    % Calculate sensitivity
    noise_results.sensitivity = std(noise_results.sef_values) / abs(mean(noise_results.sef_values));
end

function missing_data_results = analyze_missing_data_sensitivity(data)
    % Analyze SEF sensitivity to missing data
    
    missing_data_results = struct();
    
    % Test different missing data fractions
    missing_fractions = [0, 0.01, 0.05, 0.1, 0.2]; % Fraction of data to remove
    n_fractions = length(missing_fractions);
    
    missing_data_results.missing_fractions = missing_fractions;
    missing_data_results.sef_values = zeros(n_fractions, 1);
    
    for i = 1:n_fractions
        missing_fraction = missing_fractions(i);
        if missing_fraction == 0
            % No missing data
            missing_data_results.sef_values(i) = calculate_sef_for_sample(data.matches);
        else
            % Remove data randomly
            incomplete_data = remove_random_data(data.matches, missing_fraction);
            missing_data_results.sef_values(i) = calculate_sef_for_sample(incomplete_data);
        end
    end
    
    % Calculate sensitivity
    missing_data_results.sensitivity = std(missing_data_results.sef_values) / abs(mean(missing_data_results.sef_values));
end

function cv_results = perform_cross_validation(data)
    % Perform cross-validation analysis
    
    cv_results = struct();
    
    % K-fold cross-validation
    k_folds = 5;
    cv_results.k_fold = perform_k_fold_cv(data, k_folds);
    
    % Time series cross-validation (if dates available)
    if isfield(data, 'dates')
        cv_results.time_series = perform_time_series_cv(data);
    end
    
    % Bootstrap validation
    cv_results.bootstrap = perform_bootstrap_validation(data);
end

function k_fold_results = perform_k_fold_cv(data, k_folds)
    % Perform K-fold cross-validation
    
    n_samples = height(data.matches);
    fold_size = floor(n_samples / k_folds);
    
    k_fold_results = struct();
    k_fold_results.fold_sef = zeros(k_folds, 1);
    k_fold_results.fold_std = zeros(k_folds, 1);
    
    for fold = 1:k_folds
        % Create fold indices
        start_idx = (fold - 1) * fold_size + 1;
        end_idx = min(fold * fold_size, n_samples);
        test_indices = start_idx:end_idx;
        train_indices = setdiff(1:n_samples, test_indices);
        
        % Calculate SEF for this fold
        fold_data = data.matches(train_indices, :);
        k_fold_results.fold_sef(fold) = calculate_sef_for_sample(fold_data);
        k_fold_results.fold_std(fold) = std(fold_data.SEF);
    end
    
    % Calculate overall statistics
    k_fold_results.mean_sef = mean(k_fold_results.fold_sef);
    k_fold_results.std_sef = std(k_fold_results.fold_sef);
    k_fold_results.cv_error = k_fold_results.std_sef / abs(k_fold_results.mean_sef);
end

function significance_results = test_sef_significance(data)
    % Test statistical significance of SEF improvements
    
    significance_results = struct();
    
    % Bootstrap test for SEF > 1
    n_bootstrap = 1000;
    sef_bootstrap = zeros(n_bootstrap, 1);
    
    for i = 1:n_bootstrap
        % Bootstrap sample
        sample_indices = randsample(height(data.matches), height(data.matches), true);
        sample_data = data.matches(sample_indices, :);
        sef_bootstrap(i) = calculate_sef_for_sample(sample_data);
    end
    
    % Calculate p-value for SEF > 1
    significance_results.p_value = sum(sef_bootstrap <= 1) / n_bootstrap;
    significance_results.significant = significance_results.p_value < 0.05;
    significance_results.confidence_level = 0.95;
    
    % Effect size
    significance_results.effect_size = (mean(sef_bootstrap) - 1) / std(sef_bootstrap);
end

function ci_results = calculate_bootstrap_ci(data)
    % Calculate bootstrap confidence intervals
    
    ci_results = struct();
    
    n_bootstrap = 1000;
    sef_bootstrap = zeros(n_bootstrap, 1);
    
    for i = 1:n_bootstrap
        sample_indices = randsample(height(data.matches), height(data.matches), true);
        sample_data = data.matches(sample_indices, :);
        sef_bootstrap(i) = calculate_sef_for_sample(sample_data);
    end
    
    % Calculate confidence intervals
    ci_results.mean_sef = mean(sef_bootstrap);
    ci_results.std_sef = std(sef_bootstrap);
    ci_results.ci_95 = [prctile(sef_bootstrap, 2.5), prctile(sef_bootstrap, 97.5)];
    ci_results.ci_99 = [prctile(sef_bootstrap, 0.5), prctile(sef_bootstrap, 99.5)];
end

function model_results = compare_models(data)
    % Compare SEF framework against alternative methods
    
    model_results = struct();
    
    % Calculate SEF
    sef_value = calculate_sef_for_sample(data.matches);
    
    % Calculate baseline metrics
    team_a_perf = data.matches.team_a_performance;
    team_b_perf = data.matches.team_b_performance;
    
    % Simple difference
    simple_diff = mean(team_a_perf - team_b_perf);
    
    % Standardized difference
    pooled_std = sqrt((var(team_a_perf) + var(team_b_perf)) / 2);
    standardized_diff = simple_diff / pooled_std;
    
    % Effect size (Cohen's d)
    cohens_d = simple_diff / pooled_std;
    
    % Store results
    model_results.sef = sef_value;
    model_results.simple_diff = simple_diff;
    model_results.standardized_diff = standardized_diff;
    model_results.cohens_d = cohens_d;
    
    % Performance comparison
    model_results.sef_advantage = sef_value / abs(standardized_diff);
end

function cleaned_data = remove_outliers(data, threshold)
    % Remove outliers based on threshold
    
    % Calculate outlier threshold
    team_a_perf = data.team_a_performance;
    team_b_perf = data.team_b_performance;
    
    % Use IQR method
    q1_a = prctile(team_a_perf, 25);
    q3_a = prctile(team_a_perf, 75);
    iqr_a = q3_a - q1_a;
    outlier_threshold_a = q3_a + 1.5 * iqr_a;
    
    q1_b = prctile(team_b_perf, 25);
    q3_b = prctile(team_b_perf, 75);
    iqr_b = q3_b - q1_b;
    outlier_threshold_b = q3_b + 1.5 * iqr_b;
    
    % Remove outliers
    outlier_mask = (team_a_perf > outlier_threshold_a) | (team_b_perf > outlier_threshold_b);
    cleaned_data = data(~outlier_mask, :);
end

function noisy_data = add_noise(data, noise_level)
    % Add noise to the data
    
    noisy_data = data;
    noisy_data.team_a_performance = data.team_a_performance + noise_level * randn(size(data.team_a_performance));
    noisy_data.team_b_performance = data.team_b_performance + noise_level * randn(size(data.team_b_performance));
end

function incomplete_data = remove_random_data(data, missing_fraction)
    % Remove random data points
    
    n_samples = height(data);
    n_remove = round(n_samples * missing_fraction);
    remove_indices = randsample(n_samples, n_remove);
    
    incomplete_data = data;
    incomplete_data(remove_indices, :) = [];
end

function generate_sensitivity_report(results)
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
        if isfield(results.temporal, 'seasonal_cv')
            fprintf('   Seasonal coefficient of variation: %.3f\n', results.temporal.seasonal_cv);
        end
        if isfield(results.temporal, 'temporal_trend')
            fprintf('   Temporal trend: %.3f\n', results.temporal.temporal_trend);
        end
    end
    
    % Parameter sensitivity
    if isfield(results, 'parameter_sensitivity')
        fprintf('\n3. PARAMETER SENSITIVITY:\n');
        fprintf('   κ (variance ratio) sensitivity: %.3f\n', results.parameter_sensitivity.kappa_sensitivity);
        fprintf('   ρ (correlation) sensitivity: %.3f\n', results.parameter_sensitivity.rho_sensitivity);
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
        if isfield(results.robustness, 'missing_data_analysis')
            fprintf('   Missing data sensitivity: %.3f\n', results.robustness.missing_data_analysis.sensitivity);
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
