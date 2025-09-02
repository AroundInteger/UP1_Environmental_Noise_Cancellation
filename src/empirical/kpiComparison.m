function [kpi_results, kpi_details] = kpiComparison(data, varargin)
%KPICOMPARISON Compare absolute vs relative KPI performance
%
% This function systematically compares the performance of absolute vs relative
% KPIs for predicting binary outcomes (e.g., win/loss) using cross-validation.
%
% Inputs:
%   data - Struct with fields:
%          - outcome: binary outcome variable (1 = positive, 0 = negative)
%          - [metric_name]_i: absolute performance values
%          - [metric_name]_r: relative performance values
%   varargin - Optional parameters:
%              - metrics: cell array of metric names to analyze (default: all available)
%              - cv_folds: number of cross-validation folds (default: 5)
%              - test_size: proportion of data for testing (default: 0.2)
%              - random_seed: random seed for reproducibility (default: 42)
%              - performance_metrics: metrics to calculate (default: {'auc', 'accuracy'})
%
% Outputs:
%   kpi_results - Struct with aggregated comparison results
%   kpi_details - Struct with detailed results for each metric
%
% Author: UP1 Research Team
% Date: 2024

%% Parse inputs
p = inputParser;
addParameter(p, 'metrics', {}, @iscell);
addParameter(p, 'cv_folds', 5, @isnumeric);
addParameter(p, 'test_size', 0.2, @isnumeric);
addParameter(p, 'random_seed', 42, @isnumeric);
addParameter(p, 'performance_metrics', {'auc', 'accuracy'}, @iscell);

parse(p, varargin{:});
requested_metrics = p.Results.metrics;
cv_folds = p.Results.cv_folds;
test_size = p.Results.test_size;
random_seed = p.Results.random_seed;
performance_metrics = p.Results.performance_metrics;

%% Get available metrics from data
available_metrics = {};
if isstruct(data)
    data_fields = fieldnames(data);
    for i = 1:length(data_fields)
        field = data_fields{i};
        % Look for metrics with _i and _r suffixes
        if endsWith(field, '_i') && ~strcmp(field, 'outcome')
            base_metric = field(1:end-2); % Remove _i suffix
            rel_field = [base_metric '_r'];
            if ismember(rel_field, data_fields)
                available_metrics{end+1} = base_metric;
            end
        end
    end
end

% Use requested metrics if specified, otherwise use all available
if isempty(requested_metrics)
    metrics_to_analyze = available_metrics;
else
    metrics_to_analyze = intersect(requested_metrics, available_metrics);
    if length(metrics_to_analyze) < length(requested_metrics)
        missing = setdiff(requested_metrics, available_metrics);
        warning('Some requested metrics not found: %s', strjoin(missing, ', '));
    end
end

if isempty(metrics_to_analyze)
    error('No valid metrics found in data');
end

fprintf('KPI Comparison Analysis:\n');
fprintf('  Analyzing %d metrics with %d-fold cross-validation\n', length(metrics_to_analyze), cv_folds);

%% Step 1: Data preprocessing
fprintf('Step 1: Data preprocessing...\n');

% Extract outcome variable
if ~isfield(data, 'outcome')
    error('Data must contain ''outcome'' field');
end

outcome = data.outcome;
if ~isnumeric(outcome) || ~all(ismember(outcome, [0, 1]))
    error('Outcome must be numeric binary values (0 or 1)');
end

% Remove rows with missing outcomes
valid_idx = ~isnan(outcome);
if sum(valid_idx) < length(outcome)
    warning('Removing %d rows with missing outcomes', length(outcome) - sum(valid_idx));
    outcome = outcome(valid_idx);
end

n_samples = length(outcome);
fprintf('  Valid samples: %d\n', n_samples);

%% Step 2: Analyze individual metrics
fprintf('Step 2: Analyzing individual metrics...\n');

metric_results = struct();
for i = 1:length(metrics_to_analyze)
    metric = metrics_to_analyze{i};
    
    fprintf('  Analyzing metric: %s\n', metric);
    
    % Get absolute and relative features
    abs_field = [metric '_i'];
    rel_field = [metric '_r'];
    
    if ~isfield(data, abs_field) || ~isfield(data, rel_field)
        warning('Missing data for metric %s, skipping...', metric);
        continue;
    end
    
    % Extract features and remove missing values
    abs_features = data.(abs_field);
    rel_features = data.(rel_field);
    
    % Remove rows with missing features
    feature_valid_idx = ~isnan(abs_features) & ~isnan(rel_features);
    if sum(feature_valid_idx) < n_samples * 0.5  % Need at least 50% valid data
        warning('Insufficient valid data for metric %s, skipping...', metric);
        continue;
    end
    
    % Filter to valid samples
    valid_outcome = outcome(feature_valid_idx);
    valid_abs = abs_features(feature_valid_idx);
    valid_rel = rel_features(feature_valid_idx);
    
    % Perform cross-validation
    [abs_performance, rel_performance] = performCrossValidation(...
        valid_abs, valid_rel, valid_outcome, cv_folds, test_size, random_seed, performance_metrics);
    
    % Store results
    metric_results.(metric) = struct();
    metric_results.(metric).absolute = abs_performance;
    metric_results.(metric).relative = rel_performance;
    metric_results.(metric).n_samples = length(valid_outcome);
    metric_results.(metric).n_valid = sum(feature_valid_idx);
    
    % Calculate improvement
    improvement = calculateImprovement(abs_performance, rel_performance, performance_metrics);
    metric_results.(metric).improvement = improvement;
    
    fprintf('    ✓ Completed (n=%d, improvement: %.1f%%)\n', ...
        length(valid_outcome), improvement.mean_improvement(1));
end

%% Step 3: Aggregate performance comparison
fprintf('Step 3: Aggregating performance comparison...\n');

[aggregate_results, metric_summary] = compareAggregatePerformance(metric_results, performance_metrics);

%% Step 4: Statistical significance testing
fprintf('Step 4: Statistical significance testing...\n');

significance_results = performSignificanceTests(metric_results, performance_metrics);

%% Step 5: Effect size calculation
fprintf('Step 5: Calculating effect sizes...\n');

effect_sizes = calculateEffectSizes(metric_results, performance_metrics);

%% Step 6: Generate results structure
fprintf('Step 6: Generating results...\n');

% Main results
kpi_results = struct();
kpi_results.metric_results = metric_results;
kpi_results.aggregate_results = aggregate_results;
kpi_results.metric_summary = metric_summary;
kpi_results.significance_results = significance_results;
kpi_results.effect_sizes = effect_sizes;
kpi_results.analysis_parameters = struct();
kpi_results.analysis_parameters.cv_folds = cv_folds;
kpi_results.analysis_parameters.test_size = test_size;
kpi_results.analysis_parameters.random_seed = random_seed;
kpi_results.analysis_parameters.performance_metrics = performance_metrics;

% Summary statistics
kpi_results.summary = struct();
kpi_results.summary.total_metrics_analyzed = length(fieldnames(metric_results));
kpi_results.summary.performance_metrics = performance_metrics;
kpi_results.summary.cv_folds = cv_folds;
kpi_results.summary.test_size = test_size;

% Detailed results for advanced analysis
kpi_details = struct();
kpi_details.metric_details = metric_results;
kpi_details.raw_performance = struct();
kpi_details.raw_performance.absolute = extractRawPerformance(metric_results, 'absolute');
kpi_details.raw_performance.relative = extractRawPerformance(metric_results, 'relative');

fprintf('  ✓ Analysis completed successfully\n');

end

%% Helper Functions

function [abs_performance, rel_performance] = performCrossValidation(abs_features, rel_features, outcome, cv_folds, test_size, random_seed, performance_metrics)
%PERFORMCROSSVALIDATION Perform cross-validation for absolute vs relative features
    
    % Set random seed
    if ~isempty(random_seed)
        rng(random_seed);
    end
    
    n_samples = length(outcome);
    n_test = round(n_samples * test_size);
    n_train = n_samples - n_test;
    
    % Initialize storage
    n_metrics = length(performance_metrics);
    abs_scores = zeros(cv_folds, n_metrics);
    rel_scores = zeros(cv_folds, n_metrics);
    
    % Create cross-validation indices
    cv_indices = crossvalind('HoldOut', n_samples, test_size);
    
    for fold = 1:cv_folds
        % Split data
        if fold == 1
            % Use the first split
            train_idx = ~cv_indices;
            test_idx = cv_indices;
        else
            % Create new random split for additional folds
            temp_indices = crossvalind('HoldOut', n_samples, test_size);
            train_idx = ~temp_indices;
            test_idx = temp_indices;
        end
        
        % Train and test absolute model
        abs_model = fitglm(abs_features(train_idx), outcome(train_idx), 'Distribution', 'binomial');
        abs_pred = predict(abs_model, abs_features(test_idx));
        abs_scores(fold, :) = calculateMetrics(abs_pred, outcome(test_idx), performance_metrics);
        
        % Train and test relative model
        rel_model = fitglm(rel_features(train_idx), outcome(train_idx), 'Distribution', 'binomial');
        rel_pred = predict(rel_model, rel_features(test_idx));
        rel_scores(fold, :) = calculateMetrics(rel_pred, outcome(test_idx), performance_metrics);
    end
    
    % Aggregate results across folds
    abs_performance = struct();
    rel_performance = struct();
    
    for i = 1:n_metrics
        metric = performance_metrics{i};
        abs_performance.(metric) = struct();
        abs_performance.(metric).mean = mean(abs_scores(:, i));
        abs_performance.(metric).std = std(abs_scores(:, i));
        abs_performance.(metric).scores = abs_scores(:, i);
        
        rel_performance.(metric) = struct();
        rel_performance.(metric).mean = mean(rel_scores(:, i));
        rel_performance.(metric).std = std(rel_scores(:, i));
        rel_performance.(metric).scores = rel_scores(:, i);
    end
end

function metrics = calculateMetrics(predictions, actual, metric_names)
%CALCULATEMETRICS Calculate performance metrics
    
    n_metrics = length(metric_names);
    metrics = zeros(1, n_metrics);
    
    for i = 1:n_metrics
        metric = metric_names{i};
        
        switch lower(metric)
            case 'auc'
                try
                    [~, ~, ~, auc] = perfcurve(actual, predictions, 1);
                    metrics(i) = auc;
                catch
                    metrics(i) = 0.5; % Default for failed AUC calculation
                end
                
            case 'accuracy'
                pred_binary = predictions > 0.5;
                metrics(i) = mean(pred_binary == actual);
                
            case 'precision'
                pred_binary = predictions > 0.5;
                if sum(pred_binary) > 0
                    metrics(i) = sum(pred_binary & actual) / sum(pred_binary);
                else
                    metrics(i) = 0;
                end
                
            case 'recall'
                pred_binary = predictions > 0.5;
                if sum(actual) > 0
                    metrics(i) = sum(pred_binary & actual) / sum(actual);
                else
                    metrics(i) = 0;
                end
                
            case 'f1_score'
                pred_binary = predictions > 0.5;
                precision = 0;
                recall = 0;
                
                if sum(pred_binary) > 0
                    precision = sum(pred_binary & actual) / sum(pred_binary);
                end
                if sum(actual) > 0
                    recall = sum(pred_binary & actual) / sum(actual);
                end
                
                if precision + recall > 0
                    metrics(i) = 2 * (precision * recall) / (precision + recall);
                else
                    metrics(i) = 0;
                end
                
            case 'log_loss'
                % Add small epsilon to avoid log(0)
                epsilon = 1e-15;
                predictions = max(min(predictions, 1 - epsilon), epsilon);
                metrics(i) = -mean(actual .* log(predictions) + (1 - actual) .* log(1 - predictions));
                
            otherwise
                warning('Unknown metric: %s', metric);
                metrics(i) = NaN;
        end
    end
end

function improvement = calculateImprovement(abs_performance, rel_performance, performance_metrics)
%CALCULATEIMPROVEMENT Calculate improvement from absolute to relative
    
    n_metrics = length(performance_metrics);
    improvement = struct();
    improvement.absolute_values = zeros(1, n_metrics);
    improvement.relative_values = zeros(1, n_metrics);
    improvement.absolute_improvement = zeros(1, n_metrics);
    improvement.relative_improvement = zeros(1, n_metrics);
    improvement.mean_improvement = zeros(1, n_metrics);
    
    for i = 1:n_metrics
        metric = performance_metrics{i};
        
        abs_val = abs_performance.(metric).mean;
        rel_val = rel_performance.(metric).mean;
        
        improvement.absolute_values(i) = abs_val;
        improvement.relative_values(i) = rel_val;
        
        % Calculate improvements
        if abs_val > 0
            improvement.absolute_improvement(i) = (rel_val - abs_val) / abs_val * 100;
        else
            improvement.absolute_improvement(i) = 0;
        end
        
        improvement.relative_improvement(i) = rel_val - abs_val;
        improvement.mean_improvement(i) = (rel_val + abs_val) / 2;
    end
end

function [aggregate_results, metric_summary] = compareAggregatePerformance(metric_results, performance_metrics)
%COMPAREAGGREGATEPERFORMANCE Compare aggregate performance across metrics
    
    n_metrics = length(performance_metrics);
    metric_names = fieldnames(metric_results);
    n_available_metrics = length(metric_names);
    
    % Initialize storage
    aggregate_results = struct();
    metric_summary = struct();
    
    for i = 1:n_metrics
        metric = performance_metrics{i};
        
        % Collect all values for this metric
        abs_values = zeros(n_available_metrics, 1);
        rel_values = zeros(n_available_metrics, 1);
        improvements = zeros(n_available_metrics, 1);
        
        for j = 1:n_available_metrics
            metric_name = metric_names{j};
            if isfield(metric_results.(metric_name), 'improvement')
                abs_values(j) = metric_results.(metric_name).improvement.absolute_values(i);
                rel_values(j) = metric_results.(metric_name).improvement.relative_values(i);
                improvements(j) = metric_results.(metric_name).improvement.absolute_improvement(i);
            end
        end
        
        % Remove NaN values
        valid_idx = ~isnan(abs_values) & ~isnan(rel_values);
        if sum(valid_idx) > 0
            abs_values = abs_values(valid_idx);
            rel_values = rel_values(valid_idx);
            improvements = improvements(valid_idx);
            
            % Store aggregate results
            aggregate_results.(metric) = struct();
            aggregate_results.(metric).absolute_mean = mean(abs_values);
            aggregate_results.(metric).absolute_std = std(abs_values);
            aggregate_results.(metric).relative_mean = mean(rel_values);
            aggregate_results.(metric).relative_std = std(rel_values);
            aggregate_results.(metric).improvement_mean = mean(improvements);
            aggregate_results.(metric).improvement_std = std(improvements);
            aggregate_results.(metric).n_metrics = sum(valid_idx);
        end
    end
    
    % Create metric summary
    metric_summary = struct();
    metric_summary.total_metrics = n_available_metrics;
    metric_summary.performance_metrics = performance_metrics;
    
    % Calculate overall improvement across all metrics
    all_improvements = [];
    for i = 1:n_metrics
        metric = performance_metrics{i};
        if isfield(aggregate_results, metric)
            all_improvements = [all_improvements; aggregate_results.(metric).improvement_mean];
        end
    end
    
    if ~isempty(all_improvements)
        metric_summary.mean_improvement = all_improvements;
        metric_summary.overall_improvement = mean(all_improvements);
    end
end

function significance_results = performSignificanceTests(metric_results, performance_metrics)
%PERFORMSIGNIFICANCETESTS Perform statistical significance tests
    
    n_metrics = length(performance_metrics);
    metric_names = fieldnames(metric_results);
    n_available_metrics = length(metric_names);
    
    significance_results = struct();
    
    for i = 1:n_metrics
        metric = performance_metrics{i};
        
        % Collect paired differences for this metric
        differences = zeros(n_available_metrics, 1);
        
        for j = 1:n_available_metrics
            metric_name = metric_names{j};
            if isfield(metric_results.(metric_name), 'relative') && ...
               isfield(metric_results.(metric_name), 'absolute')
                
                rel_scores = metric_results.(metric_name).relative.(metric).scores;
                abs_scores = metric_results.(metric_name).absolute.(metric).scores;
                
                if length(rel_scores) == length(abs_scores)
                    differences(j) = mean(rel_scores - abs_scores);
                end
            end
        end
        
        % Remove NaN values
        valid_idx = ~isnan(differences);
        if sum(valid_idx) > 1
            valid_differences = differences(valid_idx);
            
            % Perform paired t-test
            [h, p_value, ~, stats] = ttest(valid_differences, 0);
            
            significance_results.(metric) = struct();
            significance_results.(metric).h = h;
            significance_results.(metric).p_value = p_value;
            significance_results.(metric).t_statistic = stats.tstat;
            significance_results.(metric).df = stats.df;
            significance_results.(metric).significant = p_value < 0.05;
            significance_results.(metric).n_metrics = sum(valid_idx);
        end
    end
end

function effect_sizes = calculateEffectSizes(metric_results, performance_metrics)
%CALCULATEEFFECTSIZES Calculate Cohen's d effect sizes
    
    n_metrics = length(performance_metrics);
    metric_names = fieldnames(metric_results);
    n_available_metrics = length(metric_names);
    
    effect_sizes = struct();
    
    for i = 1:n_metrics
        metric = performance_metrics{i};
        
        % Collect all scores for this metric
        all_abs_scores = [];
        all_rel_scores = [];
        
        for j = 1:n_available_metrics
            metric_name = metric_names{j};
            if isfield(metric_results.(metric_name), 'relative') && ...
               isfield(metric_results.(metric_name), 'absolute')
                
                abs_scores = metric_results.(metric_name).absolute.(metric).scores;
                rel_scores = metric_results.(metric_name).relative.(metric).scores;
                
                all_abs_scores = [all_abs_scores; abs_scores];
                all_rel_scores = [all_rel_scores; rel_scores];
            end
        end
        
        % Calculate Cohen's d
        if length(all_abs_scores) > 1 && length(all_rel_scores) > 1
            pooled_std = sqrt(((length(all_abs_scores) - 1) * var(all_abs_scores) + ...
                               (length(all_rel_scores) - 1) * var(all_rel_scores)) / ...
                              (length(all_abs_scores) + length(all_rel_scores) - 2));
            
            if pooled_std > 0
                cohens_d = (mean(all_rel_scores) - mean(all_abs_scores)) / pooled_std;
            else
                cohens_d = 0;
            end
            
            effect_sizes.(metric) = struct();
            effect_sizes.(metric).cohens_d = cohens_d;
            effect_sizes.(metric).magnitude = interpretCohensD(cohens_d);
            effect_sizes.(metric).n_abs = length(all_abs_scores);
            effect_sizes.(metric).n_rel = length(all_rel_scores);
        end
    end
end

function magnitude = interpretCohensD(cohens_d)
%INTERPRETCOHENSD Interpret Cohen's d effect size
    
    abs_d = abs(cohens_d);
    
    if abs_d < 0.2
        magnitude = 'negligible';
    elseif abs_d < 0.5
        magnitude = 'small';
    elseif abs_d < 0.8
        magnitude = 'medium';
    else
        magnitude = 'large';
    end
end

function raw_performance = extractRawPerformance(metric_results, type)
%EXTRACTRAWPERFORMANCE Extract raw performance scores for detailed analysis
    
    metric_names = fieldnames(metric_results);
    raw_performance = struct();
    
    for i = 1:length(metric_names)
        metric = metric_names{i};
        if isfield(metric_results.(metric), type)
            raw_performance.(metric) = metric_results.(metric).(type);
        end
    end
end
