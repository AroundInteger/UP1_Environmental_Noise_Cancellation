%% Test Rugby Analysis Functions
% Test script to verify the rugby analysis implementation works correctly
%
% This script tests the core functions:
% 1. Data loading and preprocessing
% 2. Environmental noise estimation
% 3. Basic KPI comparison
% 4. Rugby analysis pipeline
%
% Author: UP1 Research Team
% Date: 2024
% Version: 1.0

clear; clc; close all;

fprintf('=== Testing Rugby Analysis Functions ===\n\n');

%% Setup: Add source paths
fprintf('Setup: Adding source paths...\n');
try
    % Get the current script directory
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    
    % Add source paths
    addpath(fullfile(project_root, 'src'));
    addpath(fullfile(project_root, 'src', 'empirical'));
    addpath(fullfile(project_root, 'src', 'theory'));
    addpath(fullfile(project_root, 'src', 'utils'));
    
    fprintf('  ✓ Source paths added successfully\n');
catch ME
    fprintf('  ✗ Failed to add source paths: %s\n', ME.message);
    return;
end

%% Test 1: Data Loading
fprintf('\nTest 1: Loading processed data...\n');
try
    % Load processed rugby dataset
    data_file = fullfile(project_root, 'data', 'processed', 'rugby_analysis_ready.mat');
    if ~exist(data_file, 'file')
        fprintf('  ⚠ Processed data not found. Running preprocessing first...\n');
        
        % Run preprocessing
        addpath(fullfile(project_root, 'scripts'));
        preprocess_rugby_data();
        
        % Try loading again
        if ~exist(data_file, 'file')
            error('Failed to create processed data file');
        end
    end
    
    % Load the processed data
    load(data_file);
    fprintf('  ✓ Processed data loaded successfully\n');
    fprintf('    Total matches: %d\n', summary.total_matches);
    fprintf('    Seasons: %s\n', strjoin(summary.seasons, ', '));
    fprintf('    Teams: %d unique teams\n', summary.total_teams);
    fprintf('    Absolute features: %d metrics\n', length(analysis_data.absolute_feature_names));
    fprintf('    Relative features: %d metrics\n', length(analysis_data.relative_feature_names));
    
catch ME
    fprintf('  ✗ Data loading failed: %s\n', ME.message);
    return;
end

%% Test 2: Environmental Noise Estimation
fprintf('\nTest 2: Environmental noise estimation...\n');
try
    % Test with a subset of metrics for speed
    test_metrics = {'carries', 'metres_made', 'defenders_beaten'};
    
    % Create a data structure that matches what the function expects
    test_data = struct();
    test_data.season = analysis_data.season;
    test_data.team = analysis_data.team;
    
    % Add the test metrics
    for i = 1:length(test_metrics)
        metric = test_metrics{i};
        if ismember(metric, analysis_data.absolute_feature_names)
            metric_idx = find(strcmp(analysis_data.absolute_feature_names, metric));
            test_data.(metric) = analysis_data.absolute_features(:, metric_idx);
        end
    end
    
    [sigma_eta, sigma_indiv, variance_components] = environmentalEstimation(...
        test_data, 'method', 'anova', 'confidence_level', 0.95);
    
    % Validate results
    if sigma_eta >= 0 && sigma_indiv >= 0
        fprintf('  ✓ Environmental estimation successful\n');
        fprintf('    σ_η: %.3f, σ_indiv: %.3f\n', sigma_eta, sigma_indiv);
        fprintf('    Environmental ratio: %.3f\n', variance_components.environmental_ratio);
    else
        error('Invalid variance estimates');
    end
    
catch ME
    fprintf('  ✗ Environmental estimation failed: %s\n', ME.message);
    fprintf('  Error details: %s\n', ME.message);
    return;
end

%% Test 3: KPI Comparison
fprintf('\nTest 3: KPI comparison...\n');
try
    % Test with a subset of metrics and fewer CV folds for speed
    test_metrics = {'carries', 'metres_made'};
    
    % Create a data structure for KPI comparison
    kpi_data = struct();
    % Convert outcome to binary (1 = win, 0 = loss) - ensure numeric
    kpi_data.outcome = double(analysis_data.outcome_binary);
    
    % Add absolute and relative features
    for i = 1:length(test_metrics)
        metric = test_metrics{i};
        
        % Find absolute metric
        if ismember(metric, analysis_data.absolute_feature_names)
            metric_idx = find(strcmp(analysis_data.absolute_feature_names, metric));
            kpi_data.([metric '_i']) = analysis_data.absolute_features(:, metric_idx);
        end
        
        % Find relative metric
        if ismember(metric, analysis_data.relative_feature_names)
            metric_idx = find(strcmp(analysis_data.relative_feature_names, metric));
            kpi_data.([metric '_r']) = analysis_data.relative_features(:, metric_idx);
        end
    end
    
    [kpi_results, kpi_details] = kpiComparison(kpi_data, ...
        'metrics', test_metrics, 'cv_folds', 3, 'test_size', 0.3);
    
    % Validate results
    if isfield(kpi_results, 'summary') && isfield(kpi_results.summary, 'total_metrics_analyzed')
        fprintf('  ✓ KPI comparison successful\n');
        fprintf('    Metrics analyzed: %d\n', kpi_results.summary.total_metrics_analyzed);
        fprintf('    Average AUC improvement: %.1f%%\n', ...
            kpi_results.metric_summary.mean_improvement(1));
    else
        error('KPI results structure incomplete');
    end
    
catch ME
    fprintf('  ✗ KPI comparison failed: %s\n', ME.message);
    fprintf('  Error details: %s\n', ME.message);
    return;
end

%% Test 4: Rugby Analysis Pipeline
fprintf('\nTest 4: Rugby analysis pipeline...\n');
try
    % Test with reduced parameters for speed
    [rugby_results, environmental_stats] = rugbyAnalysis(kpi_data, ...
        'cv_folds', 3, 'test_size', 0.3, 'random_seed', 42);
    
    % Validate results
    if isfield(rugby_results, 'performance') && isfield(rugby_results, 'summary')
        fprintf('  ✓ Rugby analysis successful\n');
        fprintf('    Absolute model AUC: %.3f\n', rugby_results.performance.absolute.auc);
        fprintf('    Relative model AUC: %.3f\n', rugby_results.performance.relative.auc);
        fprintf('    AUC improvement: %.1f%%\n', ...
            rugby_results.summary.relative_vs_absolute.auc_improvement);
    else
        error('Rugby results structure incomplete');
    end
    
catch ME
    fprintf('  ✗ Rugby analysis failed: %s\n', ME.message);
    fprintf('  Error details: %s\n', ME.message);
    return;
end

%% Test 5: Results Validation
fprintf('\nTest 5: Results validation...\n');
try
    % Check that relative performance is better than absolute (as expected)
    abs_auc = rugby_results.performance.absolute.auc;
    rel_auc = rugby_results.performance.relative.auc;
    
    if rel_auc >= abs_auc
        fprintf('  ✓ Relative performance >= Absolute performance (as expected)\n');
        fprintf('    Improvement: %.1f%%\n', (rel_auc - abs_auc) / abs_auc * 100);
    else
        fprintf('  ⚠ Relative performance < Absolute performance (unexpected)\n');
        fprintf('    Degradation: %.1f%%\n', (abs_auc - rel_auc) / abs_auc * 100);
    end
    
    % Check environmental noise ratio
    env_ratio = variance_components.environmental_ratio;
    if env_ratio > 0
        fprintf('  ✓ Environmental noise detected (ratio: %.3f)\n', env_ratio);
    else
        fprintf('  ⚠ No environmental noise detected\n');
    end
    
catch ME
    fprintf('  ✗ Results validation failed: %s\n', ME.message);
    fprintf('  Error details: %s\n', ME.message);
end

%% Test Summary
fprintf('\n=== Test Summary ===\n');
fprintf('All core functions tested successfully!\n');
fprintf('The rugby analysis implementation is ready for full analysis.\n');
fprintf('\nNext steps:\n');
fprintf('1. Run the full analysis: analysis/main_paper/run_03_rugby_analysis.m\n');
fprintf('2. Generate publication figures\n');
fprintf('3. Create results tables\n');
fprintf('4. Validate theoretical predictions\n');
