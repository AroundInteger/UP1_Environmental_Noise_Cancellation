function [rugby_results, environmental_stats] = rugbyAnalysis(data, varargin)
%RUGBYANALYSIS Comprehensive rugby performance analysis using environmental noise cancellation
%
% This function implements the complete empirical validation framework for
% environmental noise cancellation theory using rugby performance data.
%
% Inputs:
%   data - Struct with fields:
%          - outcome: binary outcome variable (1 = win, 0 = loss)
%          - [metric_name]_i: absolute performance values
%          - [metric_name]_r: relative performance values
%   varargin - Optional parameters:
%              - cv_folds: number of cross-validation folds (default: 5)
%              - test_size: proportion of data for testing (default: 0.2)
%              - random_seed: random seed for reproducibility (default: 42)
%              - performance_metrics: metrics to calculate (default: {'auc', 'accuracy'})
%
% Outputs:
%   rugby_results - Struct with comprehensive analysis results
%   environmental_stats - Struct with environmental noise statistics
%
% Author: UP1 Research Team
% Date: 2024

%% Parse inputs
p = inputParser;
addParameter(p, 'cv_folds', 5, @isnumeric);
addParameter(p, 'test_size', 0.2, @isnumeric);
addParameter(p, 'random_seed', 42, @isnumeric);
addParameter(p, 'performance_metrics', {'auc', 'accuracy'}, @iscell);

parse(p, varargin{:});
cv_folds = p.Results.cv_folds;
test_size = p.Results.test_size;
random_seed = p.Results.random_seed;
performance_metrics = p.Results.performance_metrics;

%% Step 1: Data preprocessing and validation
fprintf('Step 1: Data preprocessing and validation...\n');

% Validate data structure
if ~isfield(data, 'outcome')
    error('Data must contain ''outcome'' field');
end

% Get available metrics
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

if isempty(available_metrics)
    error('No valid metrics found in data');
end

fprintf('  Found %d metrics for analysis\n', length(available_metrics));

%% Step 2: Environmental noise estimation
fprintf('Step 2: Environmental noise estimation...\n');

% Create data structure for environmental estimation
env_data = struct();
env_data.outcome = data.outcome;

% Add all available metrics (using absolute values for environmental estimation)
for i = 1:length(available_metrics)
    metric = available_metrics{i};
    abs_field = [metric '_i'];
    if isfield(data, abs_field)
        env_data.(metric) = data.(abs_field);
    end
end

% Estimate environmental and individual noise components
[sigma_eta, sigma_indiv, variance_components] = environmentalEstimation(env_data, ...
    'method', 'anova', 'confidence_level', 0.95);

% Store environmental statistics
environmental_stats = struct();
environmental_stats.sigma_eta = sigma_eta;
environmental_stats.sigma_indiv = sigma_indiv;
environmental_stats.variance_components = variance_components;
environmental_stats.environmental_ratio = variance_components.environmental_ratio;
environmental_stats.snr_improvement_theoretical = variance_components.snr_improvement_theoretical;

%% Step 3: Feature engineering and model preparation
fprintf('Step 3: Feature engineering and model preparation...\n');

% Create feature sets
[absolute_features, relative_features, combined_features, feature_names] = createFeatureSets(data, available_metrics);

% Get outcome variable
outcome = data.outcome;
if ~isnumeric(outcome) || ~all(ismember(outcome, [0, 1]))
    error('Outcome must be numeric binary values (0 or 1)');
end

% Remove rows with missing values
valid_idx = ~isnan(outcome) & ~any(isnan(absolute_features), 2) & ~any(isnan(relative_features), 2);
if sum(valid_idx) < length(outcome) * 0.5
    warning('Removing %d rows with missing values', length(outcome) - sum(valid_idx));
end

outcome = outcome(valid_idx);
absolute_features = absolute_features(valid_idx, :);
relative_features = relative_features(valid_idx, :);
combined_features = combined_features(valid_idx, :);

fprintf('  Valid samples for analysis: %d\n', length(outcome));

%% Step 4: Model training and evaluation
fprintf('Step 4: Model training and evaluation...\n');

% Train comparison models
[model_performance, model_details] = trainComparisonModels(...
    absolute_features, relative_features, combined_features, outcome, ...
    cv_folds, test_size, random_seed, performance_metrics);

%% Step 5: Performance evaluation and comparison
fprintf('Step 5: Performance evaluation and comparison...\n');

% Evaluate model performance
performance_results = evaluateModelPerformance(model_performance, performance_metrics);

%% Step 6: Environmental cancellation validation
fprintf('Step 6: Environmental cancellation validation...\n');

% Validate environmental noise cancellation hypothesis
env_cancellation = validateEnvironmentalCancellation(model_performance, environmental_stats, performance_metrics);

%% Step 7: Generate comprehensive results
fprintf('Step 7: Generating comprehensive results...\n');

% Main results structure
rugby_results = struct();
rugby_results.performance = model_performance;
rugby_results.performance_details = model_details;
rugby_results.performance_evaluation = performance_results;
rugby_results.env_cancellation = env_cancellation;
rugby_results.environmental_stats = environmental_stats;
rugby_results.feature_info = struct();
rugby_results.feature_info.n_metrics = length(available_metrics);
rugby_results.feature_info.metric_names = available_metrics;
rugby_results.feature_info.n_samples = length(outcome);
rugby_results.analysis_parameters = struct();
rugby_results.analysis_parameters.cv_folds = cv_folds;
rugby_results.analysis_parameters.test_size = test_size;
rugby_results.analysis_parameters.random_seed = random_seed;
rugby_results.analysis_parameters.performance_metrics = performance_metrics;

% Generate summary statistics
rugby_results.summary = generateAnalysisSummary(rugby_results, environmental_stats);

fprintf('  ✓ Analysis completed successfully\n');

end

%% Helper Functions

function [absolute_features, relative_features, combined_features, feature_names] = createFeatureSets(data, metrics)
%CREATEFEATURESETS Create feature matrices for analysis
    
    n_metrics = length(metrics);
    n_samples = length(data.outcome);
    
    % Initialize feature matrices
    absolute_features = zeros(n_samples, n_metrics);
    relative_features = zeros(n_samples, n_metrics);
    combined_features = zeros(n_samples, n_metrics * 2);
    feature_names = cell(1, n_metrics);
    
    feature_idx = 1;
    for i = 1:n_metrics
        metric = metrics{i};
        
        % Get absolute and relative features
        abs_field = [metric '_i'];
        rel_field = [metric '_r'];
        
        if isfield(data, abs_field) && isfield(data, rel_field)
            abs_values = data.(abs_field);
            rel_values = data.(rel_field);
            
            % Store features
            absolute_features(:, i) = abs_values;
            relative_features(:, i) = rel_values;
            combined_features(:, feature_idx) = abs_values;
            combined_features(:, feature_idx + 1) = rel_values;
            
            feature_names{i} = metric;
            feature_idx = feature_idx + 2;
        else
            warning('Missing data for metric %s', metric);
        end
    end
    
    % Remove unused columns
    absolute_features = absolute_features(:, 1:n_metrics);
    relative_features = relative_features(:, 1:n_metrics);
    combined_features = combined_features(:, 1:(n_metrics * 2));
end

function [model_performance, model_details] = trainComparisonModels(...
    absolute_features, relative_features, combined_features, outcome, ...
    cv_folds, test_size, random_seed, performance_metrics)
%TRAINCOMPARISONMODELS Train and evaluate comparison models
    
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
    comb_scores = zeros(cv_folds, n_metrics);
    
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
        abs_model = fitglm(absolute_features(train_idx, :), outcome(train_idx), 'Distribution', 'binomial');
        abs_pred = predict(abs_model, absolute_features(test_idx, :));
        abs_scores(fold, :) = calculateMetrics(abs_pred, outcome(test_idx), performance_metrics);
        
        % Train and test relative model
        rel_model = fitglm(relative_features(train_idx, :), outcome(train_idx), 'Distribution', 'binomial');
        rel_pred = predict(rel_model, relative_features(test_idx, :));
        rel_scores(fold, :) = calculateMetrics(rel_pred, outcome(test_idx), performance_metrics);
        
        % Train and test combined model
        comb_model = fitglm(combined_features(train_idx, :), outcome(train_idx), 'Distribution', 'binomial');
        comb_pred = predict(comb_model, combined_features(test_idx, :));
        comb_scores(fold, :) = calculateMetrics(comb_pred, outcome(test_idx), performance_metrics);
    end
    
    % Aggregate results across folds
    model_performance = struct();
    model_details = struct();
    
    % Absolute model
    model_performance.absolute = aggregatePerformance(abs_scores, performance_metrics);
    model_details.absolute = struct();
    model_details.absolute.scores = abs_scores;
    
    % Relative model
    model_performance.relative = aggregatePerformance(rel_scores, performance_metrics);
    model_details.relative = struct();
    model_details.relative.scores = rel_scores;
    
    % Combined model
    model_performance.combined = aggregatePerformance(comb_scores, performance_metrics);
    model_details.combined = struct();
    model_details.combined.scores = comb_scores;
end

function performance = aggregatePerformance(scores, performance_metrics)
%AGGREGATEPERFORMANCE Aggregate performance scores across folds
    
    n_metrics = length(performance_metrics);
    performance = struct();
    
    for i = 1:n_metrics
        metric = performance_metrics{i};
        performance.(metric) = struct();
        performance.(metric).mean = mean(scores(:, i));
        performance.(metric).std = std(scores(:, i));
        performance.(metric).scores = scores(:, i);
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

function performance_results = evaluateModelPerformance(model_performance, performance_metrics)
%EVALUATEMODELPERFORMANCE Evaluate and compare model performance
    
    performance_results = struct();
    
    for i = 1:length(performance_metrics)
        metric = performance_metrics{i};
        
        % Extract performance values
        abs_perf = model_performance.absolute.(metric).mean;
        rel_perf = model_performance.relative.(metric).mean;
        comb_perf = model_performance.combined.(metric).mean;
        
        % Calculate improvements
        rel_vs_abs = (rel_perf - abs_perf) / abs_perf * 100;
        comb_vs_abs = (comb_perf - abs_perf) / abs_perf * 100;
        comb_vs_rel = (comb_perf - rel_perf) / rel_perf * 100;
        
        % Store results
        performance_results.(metric) = struct();
        performance_results.(metric).absolute = abs_perf;
        performance_results.(metric).relative = rel_perf;
        performance_results.(metric).combined = comb_perf;
        performance_results.(metric).relative_vs_absolute = rel_vs_abs;
        performance_results.(metric).combined_vs_absolute = comb_vs_abs;
        performance_results.(metric).combined_vs_relative = comb_vs_rel;
    end
end

function env_cancellation = validateEnvironmentalCancellation(model_performance, environmental_stats, performance_metrics)
%VALIDATEENVIRONMENTALCANCELLATION Validate environmental noise cancellation hypothesis
    
    env_cancellation = struct();
    
    % Theoretical SNR improvement
    env_cancellation.theoretical_snr_improvement = environmental_stats.snr_improvement_theoretical;
    
    % Empirical improvement (using AUC as primary metric)
    if isfield(model_performance.absolute, 'auc') && isfield(model_performance.relative, 'auc')
        abs_auc = model_performance.absolute.auc.mean;
        rel_auc = model_performance.relative.auc.mean;
        
        if abs_auc > 0
            empirical_improvement = (rel_auc - abs_auc) / abs_auc;
        else
            empirical_improvement = 0;
        end
        
        env_cancellation.empirical_improvement = empirical_improvement;
        env_cancellation.theory_empirical_correlation = corr([env_cancellation.theoretical_snr_improvement; empirical_improvement], [1; 1]);
    else
        env_cancellation.empirical_improvement = NaN;
        env_cancellation.theory_empirical_correlation = NaN;
    end
    
    % Environmental noise ratio
    env_cancellation.environmental_ratio = environmental_stats.environmental_ratio;
    
    % Hypothesis validation
    if ~isnan(env_cancellation.empirical_improvement) && env_cancellation.empirical_improvement > 0
        env_cancellation.hypothesis_supported = true;
        env_cancellation.validation_message = 'Environmental cancellation hypothesis supported';
    else
        env_cancellation.hypothesis_supported = false;
        env_cancellation.validation_message = 'Environmental cancellation hypothesis not supported';
    end
end

function summary = generateAnalysisSummary(rugby_results, environmental_stats)
%GENERATEANALYSISSUMMARY Generate comprehensive analysis summary
    
    summary = struct();
    
    % Performance comparison
    if isfield(rugby_results.performance_evaluation, 'auc')
        summary.relative_vs_absolute = struct();
        summary.relative_vs_absolute.auc_improvement = rugby_results.performance_evaluation.auc.relative_vs_absolute;
        summary.relative_vs_absolute.accuracy_improvement = rugby_results.performance_evaluation.accuracy.relative_vs_absolute;
    end
    
    % Environmental statistics
    summary.environmental_noise_ratio = environmental_stats.environmental_ratio;
    summary.theoretical_snr_improvement = environmental_stats.snr_improvement_theoretical;
    
    % Model performance
    if isfield(rugby_results.performance, 'absolute') && isfield(rugby_results.performance.absolute, 'auc')
        summary.absolute_model_auc = rugby_results.performance.absolute.auc.mean;
        summary.relative_model_auc = rugby_results.performance.relative.auc.mean;
        summary.combined_model_auc = rugby_results.performance.combined.auc.mean;
    end
    
    % Analysis parameters
    summary.n_metrics = rugby_results.feature_info.n_metrics;
    summary.n_samples = rugby_results.feature_info.n_samples;
    summary.cv_folds = rugby_results.analysis_parameters.cv_folds;
    
    % Overall assessment
    if isfield(rugby_results.env_cancellation, 'hypothesis_supported')
        summary.hypothesis_supported = rugby_results.env_cancellation.hypothesis_supported;
        summary.validation_message = rugby_results.env_cancellation.validation_message;
    end
end
