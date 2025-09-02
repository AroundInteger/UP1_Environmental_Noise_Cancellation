function [axiom_results, kpi_ranking, validation_summary] = axiomValidation(data, varargin)
%AXIOMVALIDATION Validate KPIs against the 4 axioms of environmental noise cancellation
%
% This function tests each KPI in the dataset against the four fundamental axioms
% that ensure effective environmental noise cancellation:
%
% Axiom 1: Invariance to Shared Effects
% Axiom 2: Ordinal Consistency  
% Axiom 3: Scaling Proportionality
% Axiom 4: Statistical Optimality
%
% Inputs:
%   data - Struct with fields:
%          - outcome: binary outcome variable (0 or 1)
%          - [metric_name]: performance values for each metric
%   varargin - Optional parameters:
%              - confidence_level: confidence level for tests (default: 0.95)
%              - test_threshold: threshold for axiom compliance (default: 0.8)
%              - environmental_factor: environmental noise factor (default: auto-detect)
%              - verbose: display detailed results (default: true)
%
% Outputs:
%   axiom_results - Struct with detailed axiom test results for each KPI
%   kpi_ranking - Ranked list of KPIs by overall axiom compliance
%   validation_summary - Summary statistics and recommendations
%
% Author: UP1 Research Team
% Date: 2024

%% Parse inputs
p = inputParser;
addParameter(p, 'confidence_level', 0.95, @isnumeric);
addParameter(p, 'test_threshold', 0.8, @isnumeric);
addParameter(p, 'environmental_factor', [], @isnumeric);
addParameter(p, 'verbose', true, @islogical);

parse(p, varargin{:});
confidence_level = p.Results.confidence_level;
test_threshold = p.Results.test_threshold;
environmental_factor = p.Results.environmental_factor;
verbose = p.Results.verbose;

%% Setup
if verbose
    fprintf('=== UP1 Axiom Validation: Environmental Noise Cancellation ===\n\n');
    fprintf('Testing KPIs against the 4 fundamental axioms...\n\n');
end

% Get available metrics from data
available_metrics = {};
if isstruct(data)
    data_fields = fieldnames(data);
    for i = 1:length(data_fields)
        field = data_fields{i};
        % Skip non-metric fields
        if ~ismember(field, {'outcome', 'season', 'team', 'match_location'})
            if isnumeric(data.(field)) && length(data.(field)) > 1
                available_metrics{end+1} = field;
            end
        end
    end
end

if isempty(available_metrics)
    error('No valid metrics found in data');
end

n_metrics = length(available_metrics);
if verbose
    fprintf('Found %d metrics to validate:\n', n_metrics);
    fprintf('  %s\n', strjoin(available_metrics(1:min(5, end)), ', '));
    if n_metrics > 5
        fprintf('  ... and %d more\n', n_metrics - 5);
    end
    fprintf('\n');
end

%% Initialize results structure
axiom_results = struct();
kpi_ranking = struct();

%% Axiom 1: Invariance to Shared Effects
if verbose
    fprintf('Testing Axiom 1: Invariance to Shared Effects\n');
    fprintf('  Tests if KPI is unaffected by factors influencing all competitors equally\n');
end

for i = 1:n_metrics
    metric = available_metrics{i};
    if verbose
        fprintf('    Testing %s...', metric);
    end
    
    % Test invariance to shared effects
    [invariance_score, invariance_details] = testInvarianceToSharedEffects(...
        data, metric, confidence_level, environmental_factor);
    
    axiom_results.(metric).axiom1 = struct();
    axiom_results.(metric).axiom1.score = invariance_score;
    axiom_results.(metric).axiom1.details = invariance_details;
    axiom_results.(metric).axiom1.compliant = invariance_score >= test_threshold;
    
    if verbose
        if axiom_results.(metric).axiom1.compliant
            fprintf(' ✓ (%.3f)\n', invariance_score);
        else
            fprintf(' ✗ (%.3f)\n', invariance_score);
        end
    end
end

%% Axiom 2: Ordinal Consistency
if verbose
    fprintf('\nTesting Axiom 2: Ordinal Consistency\n');
    fprintf('  Tests if KPI correctly reflects true competitive ordering\n');
end

for i = 1:n_metrics
    metric = available_metrics{i};
    if verbose
        fprintf('    Testing %s...', metric);
    end
    
    % Test ordinal consistency
    [ordinal_score, ordinal_details] = testOrdinalConsistency(...
        data, metric, confidence_level);
    
    axiom_results.(metric).axiom2 = struct();
    axiom_results.(metric).axiom2.score = ordinal_score;
    axiom_results.(metric).axiom2.details = ordinal_details;
    axiom_results.(metric).axiom2.compliant = ordinal_score >= test_threshold;
    
    if verbose
        if axiom_results.(metric).axiom2.compliant
            fprintf(' ✓ (%.3f)\n', ordinal_score);
        else
            fprintf(' ✗ (%.3f)\n', ordinal_score);
        end
    end
end

%% Axiom 3: Scaling Proportionality
if verbose
    fprintf('\nTesting Axiom 3: Scaling Proportionality\n');
    fprintf('  Tests if KPI scales consistently across different measurement units\n');
end

for i = 1:n_metrics
    metric = available_metrics{i};
    if verbose
        fprintf('    Testing %s...', metric);
    end
    
    % Test scaling proportionality
    [scaling_score, scaling_details] = testScalingProportionality(...
        data, metric, confidence_level);
    
    axiom_results.(metric).axiom3 = struct();
    axiom_results.(metric).axiom3.score = scaling_score;
    axiom_results.(metric).axiom3.details = scaling_details;
    axiom_results.(metric).axiom3.compliant = scaling_score >= test_threshold;
    
    if verbose
        if axiom_results.(metric).axiom3.compliant
            fprintf(' ✓ (%.3f)\n', scaling_score);
        else
            fprintf(' ✗ (%.3f)\n', scaling_score);
        end
    end
end

%% Axiom 4: Statistical Optimality
if verbose
    fprintf('\nTesting Axiom 4: Statistical Optimality\n');
    fprintf('  Tests if KPI achieves optimal statistical properties\n');
end

for i = 1:n_metrics
    metric = available_metrics{i};
    if verbose
        fprintf('    Testing %s...', metric);
    end
    
    % Test statistical optimality
    [optimality_score, optimality_details] = testStatisticalOptimality(...
        data, metric, confidence_level);
    
    axiom_results.(metric).axiom4 = struct();
    axiom_results.(metric).axiom4.score = optimality_score;
    axiom_results.(metric).axiom4.details = optimality_details;
    axiom_results.(metric).axiom4.compliant = optimality_score >= test_threshold;
    
    if verbose
        if axiom_results.(metric).axiom4.compliant
            fprintf(' ✓ (%.3f)\n', optimality_score);
        else
            fprintf(' ✗ (%.3f)\n', optimality_score);
        end
    end
end

%% Calculate Overall Compliance Scores
if verbose
    fprintf('\nCalculating overall compliance scores...\n');
end

for i = 1:n_metrics
    metric = available_metrics{i};
    
    % Calculate overall compliance score
    scores = [axiom_results.(metric).axiom1.score, ...
              axiom_results.(metric).axiom2.score, ...
              axiom_results.(metric).axiom3.score, ...
              axiom_results.(metric).axiom4.score];
    
    overall_score = mean(scores);
    overall_compliant = overall_score >= test_threshold;
    
    % Count compliant axioms
    compliant_axioms = sum([axiom_results.(metric).axiom1.compliant, ...
                           axiom_results.(metric).axiom2.compliant, ...
                           axiom_results.(metric).axiom3.compliant, ...
                           axiom_results.(metric).axiom4.compliant]);
    
    % Store overall results
    axiom_results.(metric).overall = struct();
    axiom_results.(metric).overall.score = overall_score;
    axiom_results.(metric).overall.compliant = overall_compliant;
    axiom_results.(metric).overall.compliant_axioms = compliant_axioms;
    axiom_results.(metric).overall.individual_scores = scores;
    
    if verbose
        fprintf('  %s: Overall score = %.3f (%d/4 axioms compliant)\n', ...
                metric, overall_score, compliant_axioms);
    end
end

%% Generate KPI Ranking
if verbose
    fprintf('\nGenerating KPI ranking by axiom compliance...\n');
end

% Create ranking structure
ranking_data = zeros(n_metrics, 6); % [overall_score, axiom1, axiom2, axiom3, axiom4, compliant_axioms]
metric_names = cell(n_metrics, 1);

for i = 1:n_metrics
    metric = available_metrics{i};
    metric_names{i} = metric;
    
    ranking_data(i, :) = [axiom_results.(metric).overall.score, ...
                          axiom_results.(metric).axiom1.score, ...
                          axiom_results.(metric).axiom2.score, ...
                          axiom_results.(metric).axiom3.score, ...
                          axiom_results.(metric).axiom4.score, ...
                          axiom_results.(metric).overall.compliant_axioms];
end

% Sort by overall score (descending)
[sorted_scores, sort_idx] = sort(ranking_data(:, 1), 'descend');

% Create ranking structure
kpi_ranking.ranked_metrics = metric_names(sort_idx);
kpi_ranking.overall_scores = sorted_scores;
kpi_ranking.axiom_scores = ranking_data(sort_idx, 2:5);
kpi_ranking.compliant_counts = ranking_data(sort_idx, 6);
kpi_ranking.compliance_matrix = ranking_data(sort_idx, :);

%% Generate Validation Summary
if verbose
    fprintf('\nGenerating validation summary...\n');
end

% Calculate summary statistics
all_overall_scores = [];
for i = 1:length(available_metrics)
    metric = available_metrics{i};
    all_overall_scores = [all_overall_scores, axiom_results.(metric).overall.score];
end
all_axiom_scores = zeros(n_metrics, 4);
for i = 1:n_metrics
    metric = available_metrics{i};
    all_axiom_scores(i, :) = [axiom_results.(metric).axiom1.score, ...
                              axiom_results.(metric).axiom2.score, ...
                              axiom_results.(metric).axiom3.score, ...
                              axiom_results.(metric).axiom4.score];
end

validation_summary = struct();
validation_summary.total_kpis = n_metrics;
validation_summary.test_threshold = test_threshold;
validation_summary.confidence_level = confidence_level;

% Overall compliance statistics
validation_summary.overall_compliance = struct();
validation_summary.overall_compliance.mean = mean(all_overall_scores);
validation_summary.overall_compliance.std = std(all_overall_scores);
validation_summary.overall_compliance.min = min(all_overall_scores);
validation_summary.overall_compliance.max = max(all_overall_scores);
validation_summary.overall_compliance.compliant_count = sum(all_overall_scores >= test_threshold);
validation_summary.overall_compliance.compliant_percentage = (validation_summary.overall_compliance.compliant_count / n_metrics) * 100;

% Individual axiom statistics
validation_summary.axiom_statistics = struct();
axiom_names = {'Invariance_to_Shared_Effects', 'Ordinal_Consistency', 'Scaling_Proportionality', 'Statistical_Optimality'};
for a = 1:4
    field_name = axiom_names{a};
    validation_summary.axiom_statistics.(field_name) = struct();
    validation_summary.axiom_statistics.(field_name).mean = mean(all_axiom_scores(:, a));
    validation_summary.axiom_statistics.(field_name).std = std(all_axiom_scores(:, a));
    validation_summary.axiom_statistics.(field_name).compliant_count = sum(all_axiom_scores(:, a) >= test_threshold);
    validation_summary.axiom_statistics.(field_name).compliant_percentage = (validation_summary.axiom_statistics.(field_name).compliant_count / n_metrics) * 100;
end

% Top performing KPIs
validation_summary.top_kpis = struct();
top_n = min(5, n_metrics);
validation_summary.top_kpis.names = kpi_ranking.ranked_metrics(1:top_n);
validation_summary.top_kpis.scores = kpi_ranking.overall_scores(1:top_n);
validation_summary.top_kpis.compliant_axioms = kpi_ranking.compliant_counts(1:top_n);

% Recommendations
validation_summary.recommendations = generateRecommendations(axiom_results, validation_summary);

%% Display Results
if verbose
    displayValidationResults(validation_summary, kpi_ranking, axiom_results);
end

%% Final Summary
if verbose
    fprintf('\n=== Axiom Validation Complete ===\n');
    fprintf('Validated %d KPIs against 4 axioms\n', n_metrics);
    fprintf('Overall compliance: %.1f%% (%d/%d KPIs)\n', ...
            validation_summary.overall_compliance.compliant_percentage, ...
            validation_summary.overall_compliance.compliant_count, ...
            n_metrics);
    fprintf('Top performing KPI: %s (Score: %.3f)\n', ...
            validation_summary.top_kpis.names{1}, ...
            validation_summary.top_kpis.scores(1));
    fprintf('\nResults saved to axiom_results structure\n');
end

end

%% Helper Functions

function [score, details] = testInvarianceToSharedEffects(data, metric, confidence_level, environmental_factor)
%TESTINVARIANCE TOSHAREDEFFECTS Test if KPI is invariant to shared environmental effects
    
    % Extract metric values and outcomes
    values = data.(metric);
    outcomes = data.outcome;
    
    % Remove any NaN values
    valid_idx = ~isnan(values) & ~isnan(outcomes);
    values = values(valid_idx);
    outcomes = outcomes(valid_idx);
    
    if length(values) < 10
        score = 0;
        details = 'Insufficient data for testing';
        return;
    end
    
    % Method 1: Environmental noise correlation test
    % If environmental effects are significant, KPI should show low correlation with outcomes
    % when environmental factors are controlled
    
    % Calculate correlation between KPI and outcomes
    % Convert outcomes to numeric if needed
    outcomes_numeric = double(outcomes);
    correlation = corrcoef(values, outcomes_numeric);
    if size(correlation, 1) > 1
        kpi_outcome_corr = abs(correlation(1, 2));
    else
        kpi_outcome_corr = 0;
    end
    
    % Method 2: Variance stability test
    % KPI should maintain consistent variance across different environmental conditions
    
    % Split data into high and low environmental noise conditions
    if isempty(environmental_factor)
        % Use outcome as proxy for environmental conditions
        high_env_idx = outcomes == 1;
        low_env_idx = outcomes == 0;
    else
        % Use provided environmental factor
        env_values = data.(environmental_factor);
        env_median = median(env_values);
        high_env_idx = env_values > env_median;
        low_env_idx = env_values <= env_median;
    end
    
    if sum(high_env_idx) > 5 && sum(low_env_idx) > 5
        high_env_var = var(values(high_env_idx));
        low_env_var = var(values(low_env_idx));
        
        % Calculate variance ratio (should be close to 1 for invariance)
        if low_env_var > 0
            variance_ratio = high_env_var / low_env_var;
            variance_stability = 1 / (1 + abs(log(variance_ratio)));
        else
            variance_stability = 0;
        end
    else
        variance_stability = 0;
    end
    
    % Method 3: Environmental effect size test
    % Calculate effect size of environmental conditions on KPI
    if sum(high_env_idx) > 5 && sum(low_env_idx) > 5
        high_env_mean = mean(values(high_env_idx));
        low_env_mean = mean(values(low_env_idx));
        pooled_std = sqrt(((sum(high_env_idx) - 1) * var(values(high_env_idx)) + ...
                          (sum(low_env_idx) - 1) * var(values(low_env_idx))) / ...
                         (sum(high_env_idx) + sum(low_env_idx) - 2));
        
        if pooled_std > 0
            env_effect_size = abs(high_env_mean - low_env_mean) / pooled_std;
            env_effect_score = 1 / (1 + env_effect_size);
        else
            env_effect_score = 0;
        end
    else
        env_effect_score = 0;
    end
    
    % Combine scores (weighted average)
    score = 0.4 * (1 - kpi_outcome_corr) + 0.3 * variance_stability + 0.3 * env_effect_score;
    
    % Store details
    details = struct();
    details.correlation_with_outcome = kpi_outcome_corr;
    details.variance_stability = variance_stability;
    details.environmental_effect_score = env_effect_score;
    details.combined_score = score;
    details.methods_used = {'correlation_test', 'variance_stability', 'environmental_effect'};
end

function [score, details] = testOrdinalConsistency(data, metric, confidence_level)
%TESTORDINALCONSISTENCY Test if KPI correctly reflects true competitive ordering
    
    % Extract metric values and outcomes
    values = data.(metric);
    outcomes = data.outcome;
    
    % Remove any NaN values
    valid_idx = ~isnan(values) & ~isnan(outcomes);
    values = values(valid_idx);
    outcomes = outcomes(valid_idx);
    
    if length(values) < 10
        score = 0;
        details = 'Insufficient data for testing';
        return;
    end
    
    % Method 1: Spearman correlation test (primary method)
    % This tests if higher KPI values correlate with better outcomes
    try
        rank_corr = corr(values, outcomes_numeric, 'type', 'Spearman');
        rank_corr_score = abs(rank_corr);
    catch
        rank_corr_score = 0;
    end
    
    % Method 2: AUC-ROC test (secondary method)
    % This tests if KPI can distinguish between outcomes
    try
        [~, ~, ~, auc] = perfcurve(outcomes, values, 1);
        auc_score = auc;
    catch
        auc_score = 0.5; % Random performance
    end
    
    % Method 3: Monotonicity test
    % Check if higher KPI values generally correspond to better outcomes
    % Convert outcomes to numeric if needed
    outcomes_numeric = double(outcomes);
    sorted_indices = sortrows([values, outcomes_numeric], 1);
    sorted_outcomes = sorted_indices(:, 2);
    
    % Calculate how often higher values correspond to better outcomes
    monotonicity_score = 0;
    n_comparisons = 0;
    
    for i = 1:length(sorted_outcomes)-1
        for j = i+1:length(sorted_outcomes)
            if sorted_outcomes(j) >= sorted_outcomes(i)
                monotonicity_score = monotonicity_score + 1;
            end
            n_comparisons = n_comparisons + 1;
        end
    end
    
    if n_comparisons > 0
        monotonicity_score = monotonicity_score / n_comparisons;
    else
        monotonicity_score = 0.5;
    end
    
    % Combine scores (weighted average)
    % Give more weight to rank correlation as it's the primary test
    score = 0.5 * rank_corr_score + 0.3 * auc_score + 0.2 * monotonicity_score;
    
    % Store details
    details = struct();
    details.rank_correlation = rank_corr_score;
    details.auc_score = auc_score;
    details.monotonicity_score = monotonicity_score;
    details.combined_score = score;
    details.methods_used = {'rank_correlation', 'auc_roc', 'monotonicity'};
end

function [score, details] = testScalingProportionality(data, metric, confidence_level)
%TESTSCALINGPROPORTIONALITY Test if KPI scales consistently across different measurement units
    
    % Extract metric values and outcomes
    values = data.(metric);
    outcomes = data.outcome;
    
    % Remove any NaN values
    valid_idx = ~isnan(values) & ~isnan(outcomes);
    values = values(valid_idx);
    outcomes = outcomes(valid_idx);
    
    if length(values) < 10
        score = 0;
        details = 'Insufficient data for testing';
        return;
    end
    
    % Method 1: Scale transformation test (primary method)
    % Test if KPI maintains performance under different scales
    % This should work perfectly for linear scaling
    
    try
        [~, ~, ~, auc_original] = perfcurve(outcomes, values, 1);
        
        % Test with 2x scaling
        values_scaled_2x = values * 2;
        [~, ~, ~, auc_scaled_2x] = perfcurve(outcomes, values_scaled_2x, 1);
        scale_2x_score = 1 - abs(auc_original - auc_scaled_2x);
        
        % Test with 0.5x scaling
        values_scaled_half = values * 0.5;
        [~, ~, ~, auc_scaled_half] = perfcurve(outcomes, values_scaled_half, 1);
        scale_half_score = 1 - abs(auc_original - auc_scaled_half);
        
        % Test with additive shift (should not affect AUC)
        values_shifted = values + 100;
        [~, ~, ~, auc_shifted] = perfcurve(outcomes, values_shifted, 1);
        shift_score = 1 - abs(auc_original - auc_shifted);
        
    catch
        scale_2x_score = 0;
        scale_half_score = 0;
        shift_score = 0;
    end
    
    % Method 2: Monotonic transformation test
    % Test if KPI maintains performance under monotonic transformations
    try
        values_squared = values.^2;
        [~, ~, ~, auc_squared] = perfcurve(outcomes, values_squared, 1);
        square_score = 1 - abs(auc_original - auc_squared);
    catch
        square_score = 0;
    end
    
    % Method 3: Robustness to outliers
    % Check if KPI performance is stable when extreme values are modified
    try
        values_robust = values;
        q95 = quantile(values, 0.95);
        q05 = quantile(values, 0.05);
        values_robust(values > q95) = q95;
        values_robust(values < q05) = q05;
        
        [~, ~, ~, auc_robust] = perfcurve(outcomes, values_robust, 1);
        robustness_score = 1 - abs(auc_original - auc_robust);
    catch
        robustness_score = 0;
    end
    
    % Combine scores (weighted average)
    % Scale transformations should be nearly perfect, so weight them heavily
    scale_transformations = mean([scale_2x_score, scale_half_score, shift_score]);
    score = 0.6 * scale_transformations + 0.2 * square_score + 0.2 * robustness_score;
    
    % Store details
    details = struct();
    details.scale_2x_score = scale_2x_score;
    details.scale_half_score = scale_half_score;
    details.shift_score = shift_score;
    details.square_score = square_score;
    details.robustness_score = robustness_score;
    details.combined_score = score;
    details.methods_used = {'scale_transformations', 'monotonic_transformation', 'robustness'};
end

function [score, details] = testStatisticalOptimality(data, metric, confidence_level)
%TESTSTATISTICALOPTIMALITY Test if KPI achieves optimal statistical properties
    
    % Extract metric values and outcomes
    values = data.(metric);
    outcomes = data.outcome;
    
    % Remove any NaN values
    valid_idx = ~isnan(values) & ~isnan(outcomes);
    values = values(valid_idx);
    outcomes = outcomes(valid_idx);
    
    if length(values) < 10
        score = 0;
        details = 'Insufficient data for testing';
        return;
    end
    
    % Method 1: Information content test
    % Calculate mutual information between KPI and outcomes
    try
        % Discretize values for mutual information calculation
        n_bins = min(10, round(length(values) / 10));
        value_bins = discretize(values, n_bins);
        
        % Calculate mutual information
        mi_score = calculateMutualInformation(value_bins, outcomes);
        mi_normalized = mi_score / log(2); % Normalize to [0,1]
    catch
        mi_normalized = 0;
    end
    
    % Method 2: Effect size test
    % Calculate Cohen's d effect size
    try
        group1 = values(outcomes == 1);
        group0 = values(outcomes == 0);
        
        if length(group1) > 5 && length(group0) > 5
            pooled_std = sqrt(((length(group1) - 1) * var(group1) + ...
                              (length(group0) - 1) * var(group0)) / ...
                             (length(group1) + length(group0) - 2));
            
            if pooled_std > 0
                effect_size = abs(mean(group1) - mean(group0)) / pooled_std;
                effect_size_score = min(1, effect_size / 2); % Normalize to [0,1]
            else
                effect_size_score = 0;
            end
        else
            effect_size_score = 0;
        end
    catch
        effect_size_score = 0;
    end
    
    % Method 3: Variance efficiency test
    % KPI should have low variance relative to signal
    try
        signal_variance = var(values);
        noise_variance = var(values - smoothdata(values, 'gaussian', 5));
        
        if noise_variance > 0
            snr = signal_variance / noise_variance;
            snr_score = min(1, log10(snr + 1) / 3); % Normalize to [0,1]
        else
            snr_score = 0;
        end
    catch
        snr_score = 0;
    end
    
    % Combine scores (weighted average)
    score = 0.4 * mi_normalized + 0.3 * effect_size_score + 0.3 * snr_score;
    
    % Store details
    details = struct();
    details.mutual_information = mi_normalized;
    details.effect_size = effect_size_score;
    details.signal_noise_ratio = snr_score;
    details.combined_score = score;
    details.methods_used = {'mutual_information', 'effect_size', 'signal_noise_ratio'};
end

function mi = calculateMutualInformation(x, y)
%CALCULATEMUTUALINFORMATION Calculate mutual information between discrete variables
    
    % Get unique values
    unique_x = unique(x);
    unique_y = unique(y);
    
    n_x = length(unique_x);
    n_y = length(unique_y);
    n_total = length(x);
    
    % Calculate joint and marginal probabilities
    joint_prob = zeros(n_x, n_y);
    marginal_x = zeros(n_x, 1);
    marginal_y = zeros(n_y, 1);
    
    for i = 1:n_x
        for j = 1:n_y
            joint_prob(i, j) = sum(x == unique_x(i) & y == unique_y(j)) / n_total;
        end
        marginal_x(i) = sum(x == unique_x(i)) / n_total;
    end
    
    for j = 1:n_y
        marginal_y(j) = sum(y == unique_y(j)) / n_total;
    end
    
    % Calculate mutual information
    mi = 0;
    for i = 1:n_x
        for j = 1:n_y
            if joint_prob(i, j) > 0 && marginal_x(i) > 0 && marginal_y(j) > 0
                mi = mi + joint_prob(i, j) * log2(joint_prob(i, j) / (marginal_x(i) * marginal_y(j)));
            end
        end
    end
    
    % Ensure non-negative
    mi = max(0, mi);
end

function recommendations = generateRecommendations(axiom_results, validation_summary)
%GENERATERECOMMENDATIONS Generate actionable recommendations based on validation results
    
    recommendations = struct();
    
    % Overall recommendations
    if validation_summary.overall_compliance.compliant_percentage >= 80
        recommendations.overall_status = 'Excellent';
        recommendations.overall_message = 'Most KPIs comply with axioms. Focus on optimization.';
    elseif validation_summary.overall_compliance.compliant_percentage >= 60
        recommendations.overall_status = 'Good';
        recommendations.overall_message = 'Moderate compliance. Identify and fix non-compliant KPIs.';
    else
        recommendations.overall_status = 'Needs Improvement';
        recommendations.overall_message = 'Low compliance. Review KPI design and implementation.';
    end
    
    % Axiom-specific recommendations
    recommendations.axiom_specific = struct();
    
    axiom_names = {'axiom1', 'axiom2', 'axiom3', 'axiom4'};
    axiom_titles = {'Invariance to Shared Effects', 'Ordinal Consistency', 'Scaling Proportionality', 'Statistical Optimality'};
    
    for a = 1:4
        axiom = axiom_names{a};
        title = axiom_titles{a};
        
        % Calculate average score for this axiom
        scores = [];
        for metric = fieldnames(axiom_results)'
            scores = [scores, axiom_results.(metric{1}).(axiom).score];
        end
        
        avg_score = mean(scores);
        
        if avg_score >= 0.8
            status = 'Strong';
            message = sprintf('%s is well-implemented across KPIs.', title);
        elseif avg_score >= 0.6
            status = 'Moderate';
            message = sprintf('%s needs attention in some KPIs.', title);
        else
            status = 'Weak';
            message = sprintf('%s requires significant improvement across KPIs.', title);
        end
        
        recommendations.axiom_specific.(axiom) = struct();
        recommendations.axiom_specific.(axiom).status = status;
        recommendations.axiom_specific.(axiom).average_score = avg_score;
        recommendations.axiom_specific.(axiom).message = message;
    end
    
    % Top KPI recommendations
    recommendations.top_kpi_analysis = struct();
    recommendations.top_kpi_analysis.message = 'Focus on top-performing KPIs for environmental noise cancellation.';
    recommendations.top_kpi_analysis.implementation = 'Use top KPIs as templates for improving others.';
    
    % Improvement recommendations
    recommendations.improvement_strategy = struct();
    if validation_summary.overall_compliance.compliant_percentage < 80
        recommendations.improvement_strategy.priority = 'High';
        recommendations.improvement_strategy.approach = 'Systematic review and redesign of non-compliant KPIs';
    else
        recommendations.improvement_strategy.priority = 'Medium';
        recommendations.improvement_strategy.approach = 'Incremental optimization of existing KPIs';
    end
    
    recommendations.improvement_strategy.next_steps = {
        'Identify lowest-scoring KPIs for each axiom';
        'Analyze failure modes and root causes';
        'Implement targeted improvements';
        'Re-validate after changes';
        'Document best practices for future KPI design'
    };
end

function displayValidationResults(validation_summary, kpi_ranking, axiom_results)
%DISPLAYVALIDATIONRESULTS Display comprehensive validation results
    
    fprintf('\n=== VALIDATION RESULTS SUMMARY ===\n');
    
    % Overall statistics
    fprintf('\nOverall Compliance:\n');
    fprintf('  Total KPIs: %d\n', validation_summary.total_kpis);
    fprintf('  Compliant KPIs: %d (%.1f%%)\n', ...
            validation_summary.overall_compliance.compliant_count, ...
            validation_summary.overall_compliance.compliant_percentage);
    fprintf('  Average Score: %.3f ± %.3f\n', ...
            validation_summary.overall_compliance.mean, ...
            validation_summary.overall_compliance.std);
    
    % Individual axiom statistics
    fprintf('\nAxiom Performance:\n');
    axiom_names = {'Invariance to Shared Effects', 'Ordinal Consistency', 'Scaling Proportionality', 'Statistical Optimality'};
    axiom_fields = {'Invariance_to_Shared_Effects', 'Ordinal_Consistency', 'Scaling_Proportionality', 'Statistical_Optimality'};
    for a = 1:4
        field_name = axiom_fields{a};
        stats = validation_summary.axiom_statistics.(field_name);
        fprintf('  %s: %.1f%% compliant (Score: %.3f ± %.3f)\n', ...
                axiom_names{a}, ...
                stats.compliant_percentage, ...
                stats.mean, ...
                stats.std);
    end
    
    % Top performing KPIs
    fprintf('\nTop Performing KPIs:\n');
    for i = 1:length(validation_summary.top_kpis.names)
        kpi = validation_summary.top_kpis.names{i};
        score = validation_summary.top_kpis.scores(i);
        compliant_axioms = validation_summary.top_kpis.compliant_axioms(i);
        fprintf('  %d. %s: %.3f (%d/4 axioms compliant)\n', ...
                i, kpi, score, compliant_axioms);
    end
    
    % Recommendations
    fprintf('\nRecommendations:\n');
    fprintf('  Overall Status: %s\n', validation_summary.recommendations.overall_status);
    fprintf('  %s\n', validation_summary.recommendations.overall_message);
    fprintf('  Priority: %s\n', validation_summary.recommendations.improvement_strategy.priority);
    fprintf('  Approach: %s\n', validation_summary.recommendations.improvement_strategy.approach);
    
    fprintf('\nNext Steps:\n');
    for i = 1:length(validation_summary.recommendations.improvement_strategy.next_steps)
        fprintf('  %d. %s\n', i, validation_summary.recommendations.improvement_strategy.next_steps{i});
    end
end
