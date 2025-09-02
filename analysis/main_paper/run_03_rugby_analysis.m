%% UP1 Rugby Analysis: Environmental Noise Cancellation Validation
% Main script for empirical validation of environmental noise cancellation theory
% using rugby performance data across 4 seasons
%
% This script implements the complete empirical validation framework:
% 1. Data loading and preprocessing
% 2. Environmental noise estimation
% 3. KPI comparison (absolute vs relative)
% 4. Performance validation and statistical testing
% 5. Results generation and saving
%
% Author: UP1 Research Team
% Date: 2024
% Version: 1.0

clear; clc; close all;

%% Setup: Add source paths
fprintf('Setting up UP1 project environment...\n');
try
    % Get the current script directory and add source paths
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..', '..');
    
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

%% Configuration
fprintf('\n=== UP1 Rugby Analysis: Environmental Noise Cancellation Validation ===\n\n');

% Analysis parameters
config.cv_folds = 10;           % Cross-validation folds
config.test_size = 0.2;         % Test set proportion
config.random_seed = 42;        % Random seed for reproducibility
config.confidence_level = 0.95; % Confidence level for statistical tests

% Output settings
config.save_results = true;
config.output_dir = '../../outputs/results/';
config.figures_dir = '../../outputs/figures/main_paper/';

% Create output directories if they don't exist
if config.save_results
    if ~exist(config.output_dir, 'dir')
        mkdir(config.output_dir);
    end
    if ~exist(config.figures_dir, 'dir')
        mkdir(config.figures_dir);
    end
end

%% Step 1: Data Loading and Preprocessing
fprintf('Step 1: Loading processed rugby data...\n');

% Load processed rugby dataset
data_file = '../../data/processed/rugby_analysis_ready.mat';
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

%% Step 2: Environmental Noise Estimation
fprintf('\nStep 2: Environmental noise estimation...\n');

% Create data structure for environmental estimation
env_data = struct();
env_data.season = analysis_data.season;
env_data.team = analysis_data.team;

% Add all available metrics
for i = 1:length(analysis_data.absolute_feature_names)
    metric = analysis_data.absolute_feature_names{i};
    env_data.(metric) = analysis_data.absolute_features(:, i);
end

% Estimate environmental and individual noise components
[sigma_eta, sigma_indiv, variance_components] = environmentalEstimation(...
    env_data, 'method', 'anova', 'confidence_level', config.confidence_level);

% Display results
fprintf('  Environmental noise estimation results:\n');
fprintf('    σ_η (environmental): %.3f\n', sigma_eta);
fprintf('    σ_indiv (individual): %.3f\n', sigma_indiv);
fprintf('    Environmental ratio: %.3f\n', variance_components.environmental_ratio);
fprintf('    Theoretical SNR improvement: %.3f\n', variance_components.snr_improvement_theoretical);

%% Step 3: KPI Comparison Analysis
fprintf('\nStep 3: KPI comparison analysis...\n');

% Create data structure for KPI comparison
kpi_data = struct();
kpi_data.outcome = analysis_data.outcome;

% Add absolute and relative features
for i = 1:length(analysis_data.absolute_feature_names)
    metric = analysis_data.absolute_feature_names{i};
    kpi_data.([metric '_i']) = analysis_data.absolute_features(:, i);
end

for i = 1:length(analysis_data.relative_feature_names)
    metric = analysis_data.relative_feature_names{i};
    kpi_data.([metric '_r']) = analysis_data.relative_features(:, i);
end

% Ensure outcome is numeric binary
kpi_data.outcome = double(analysis_data.outcome_binary);

% Run comprehensive KPI comparison
[kpi_results, kpi_details] = kpiComparison(kpi_data, ...
    'cv_folds', config.cv_folds, ...
    'test_size', config.test_size, ...
    'random_seed', config.random_seed, ...
    'performance_metrics', {'auc', 'accuracy', 'f1_score', 'precision', 'recall'});

% Display KPI comparison results
fprintf('  KPI comparison results:\n');
fprintf('    Metrics analyzed: %d\n', kpi_results.summary.total_metrics_analyzed);
fprintf('    Average AUC improvement: %.1f%%\n', kpi_results.metric_summary.mean_improvement(1));
fprintf('    Average accuracy improvement: %.1f%%\n', kpi_results.metric_summary.mean_improvement(2));
fprintf('    Average F1 improvement: %.1f%%\n', kpi_results.metric_summary.mean_improvement(3));

%% Step 4: Comprehensive Rugby Analysis
fprintf('\nStep 4: Comprehensive rugby analysis...\n');

% Run main rugby analysis
[rugby_results, environmental_stats] = rugbyAnalysis(kpi_data, ...
    'cv_folds', config.cv_folds, ...
    'test_size', config.test_size, ...
    'random_seed', config.random_seed);

% Display comprehensive results
fprintf('  Comprehensive analysis results:\n');
if isfield(rugby_results.performance.absolute, 'auc')
    fprintf('    Absolute model AUC: %.3f\n', rugby_results.performance.absolute.auc.mean);
    fprintf('    Relative model AUC: %.3f\n', rugby_results.performance.relative.auc.mean);
    fprintf('    Combined model AUC: %.3f\n', rugby_results.performance.combined.auc.mean);
    fprintf('    Relative vs Absolute improvement: %.1f%%\n', ...
        rugby_results.summary.relative_vs_absolute.auc_improvement);
else
    fprintf('    Performance metrics not available\n');
end

%% Step 5: Statistical Validation
fprintf('\nStep 5: Statistical validation...\n');

% Perform additional statistical tests
fprintf('  Performing statistical validation...\n');

% Test environmental cancellation hypothesis
env_cancellation_test = validateEnvironmentalCancellationHypothesis(...
    rugby_results, environmental_stats, config.confidence_level);

% Test performance improvement significance
performance_significance = testPerformanceImprovementSignificance(...
    rugby_results, kpi_results, config.confidence_level);

% Display validation results
fprintf('  Statistical validation results:\n');
fprintf('    Environmental cancellation p-value: %.4f\n', env_cancellation_test.p_value);
fprintf('    Performance improvement p-value: %.4f\n', performance_significance.p_value);
if env_cancellation_test.p_value < 0.05 && performance_significance.p_value < 0.05
    significance_str = 'Yes';
else
    significance_str = 'No';
end
fprintf('    Both tests significant: %s\n', significance_str);

%% Step 6: Results Integration and Summary
fprintf('\nStep 6: Results integration and summary...\n');

% Create comprehensive results structure
comprehensive_results = struct();
comprehensive_results.analysis_timestamp = datetime('now');
comprehensive_results.config = config;
comprehensive_results.environmental_estimation = struct();
comprehensive_results.environmental_estimation.sigma_eta = sigma_eta;
comprehensive_results.environmental_estimation.sigma_indiv = sigma_indiv;
comprehensive_results.environmental_estimation.variance_components = variance_components;
comprehensive_results.kpi_comparison = kpi_results;
comprehensive_results.rugby_analysis = rugby_results;
comprehensive_results.statistical_validation = struct();
comprehensive_results.statistical_validation.environmental_cancellation = env_cancellation_test;
comprehensive_results.statistical_validation.performance_improvement = performance_significance;

% Generate executive summary
executive_summary = generateExecutiveSummary(comprehensive_results);
fprintf('  Executive summary generated\n');

%% Step 7: Save Results
if config.save_results
    fprintf('\nStep 7: Saving results...\n');
    
    % Save comprehensive results
    results_file = fullfile(config.output_dir, 'rugby_analysis_results.mat');
    save(results_file, 'comprehensive_results', '-v7.3');
    fprintf('  Saved comprehensive results to: %s\n', results_file);
    
    % Save executive summary as text
    summary_file = fullfile(config.output_dir, 'rugby_analysis_summary.txt');
    writeExecutiveSummary(executive_summary, summary_file);
    fprintf('  Saved executive summary to: %s\n', summary_file);
    
    % Save environmental estimates
    env_file = fullfile(config.output_dir, 'environmental_estimates.mat');
    save(env_file, 'sigma_eta', 'sigma_indiv', 'variance_components', '-v7.3');
    fprintf('  Saved environmental estimates to: %s\n', env_file);
end

%% Step 8: Display Final Results
fprintf('\n=== FINAL RESULTS SUMMARY ===\n');
fprintf('Environmental Noise Cancellation Validation:\n');
fprintf('  ✓ Environmental noise ratio: %.3f\n', variance_components.environmental_ratio);
fprintf('  ✓ Theoretical SNR improvement: %.3f\n', variance_components.snr_improvement_theoretical);
fprintf('  ✓ Empirical AUC improvement: %.1f%%\n', ...
    rugby_results.summary.relative_vs_absolute.auc_improvement);
if env_cancellation_test.p_value < 0.05 && performance_significance.p_value < 0.05
    significance_status = 'CONFIRMED';
else
    significance_status = 'NOT CONFIRMED';
end
fprintf('  ✓ Statistical significance: %s\n', significance_status);

fprintf('\nAnalysis completed successfully!\n');
fprintf('Results saved to: %s\n', config.output_dir);

%% Helper Functions

function env_test = validateEnvironmentalCancellationHypothesis(rugby_results, environmental_stats, confidence_level)
%VALIDATEENVIRONMENTALCANCELLATIONHYPOTHESIS Test the environmental cancellation hypothesis
    
    % Extract theoretical and empirical improvements
    theoretical_improvement = rugby_results.env_cancellation.theoretical_snr_improvement;
    empirical_improvement = rugby_results.env_cancellation.empirical_improvement;
    
    % Perform correlation test
    [r, p_value] = corr([theoretical_improvement; empirical_improvement], [1; 1]);
    
    % Store test results
    env_test = struct();
    env_test.correlation = r;
    env_test.p_value = p_value;
    env_test.theoretical_improvement = theoretical_improvement;
    env_test.empirical_improvement = empirical_improvement;
    env_test.significant = p_value < (1 - confidence_level);
end

function perf_test = testPerformanceImprovementSignificance(rugby_results, kpi_results, confidence_level)
%TESTPERFORMANCEIMPROVEMENTSIGNIFICANCE Test significance of performance improvements
    
    % Extract performance improvements
    auc_improvement = rugby_results.summary.relative_vs_absolute.auc_improvement;
    accuracy_improvement = rugby_results.summary.relative_vs_absolute.accuracy_improvement;
    
    % Perform one-sample t-test against null hypothesis of no improvement
    [h_auc, p_auc, ~, stats_auc] = ttest(auc_improvement, 0, 'Tail', 'right');
    [h_acc, p_acc, ~, stats_acc] = ttest(accuracy_improvement, 0, 'Tail', 'right');
    
    % Store test results
    perf_test = struct();
    perf_test.auc_improvement = struct();
    perf_test.auc_improvement.h = h_auc;
    perf_test.auc_improvement.p_value = p_auc;
    perf_test.auc_improvement.t_statistic = stats_auc.tstat;
    perf_test.auc_improvement.df = stats_auc.df;
    
    perf_test.accuracy_improvement = struct();
    perf_test.accuracy_improvement.h = h_acc;
    perf_test.accuracy_improvement.p_value = p_acc;
    perf_test.accuracy_improvement.t_statistic = stats_acc.tstat;
    perf_test.accuracy_improvement.df = stats_acc.df;
    
    % Overall significance
    perf_test.p_value = min(p_auc, p_acc);
    perf_test.significant = perf_test.p_value < (1 - confidence_level);
end

function summary = generateExecutiveSummary(results)
%GENERATEEXECUTIVESUMMARY Generate executive summary of results
    
    summary = struct();
    summary.title = 'UP1 Environmental Noise Cancellation: Rugby Analysis Results';
    summary.timestamp = results.analysis_timestamp;
    
    % Key findings
    summary.key_findings = struct();
    summary.key_findings.environmental_noise_ratio = ...
        results.environmental_estimation.variance_components.environmental_ratio;
    summary.key_findings.theoretical_snr_improvement = ...
        results.environmental_estimation.variance_components.snr_improvement_theoretical;
    summary.key_findings.empirical_auc_improvement = ...
        results.rugby_analysis.summary.relative_vs_absolute.auc_improvement;
    summary.key_findings.statistical_significance = ...
        results.statistical_validation.environmental_cancellation.significant && ...
        results.statistical_validation.performance_improvement.significant;
    
    % Analysis summary
    summary.analysis_summary = struct();
    summary.analysis_summary.total_metrics = ...
        results.kpi_comparison.summary.total_metrics_analyzed;
    summary.analysis_summary.cv_folds = results.config.cv_folds;
    summary.analysis_summary.confidence_level = results.config.confidence_level;
    
    % Conclusions
    summary.conclusions = struct();
    if summary.key_findings.statistical_significance
        summary.conclusions.environmental_cancellation = 'CONFIRMED';
        summary.conclusions.performance_improvement = 'SIGNIFICANT';
        summary.conclusions.theoretical_validation = 'SUCCESSFUL';
    else
        summary.conclusions.environmental_cancellation = 'NOT CONFIRMED';
        summary.conclusions.performance_improvement = 'NOT SIGNIFICANT';
        summary.conclusions.theoretical_validation = 'INCONCLUSIVE';
    end
end

function writeExecutiveSummary(summary, filename)
%WRITEEXECUTIVESUMMARY Write executive summary to text file
    
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file for writing: %s', filename);
    end
    
    % Write summary
    fprintf(fid, '%s\n', summary.title);
    fprintf(fid, 'Generated: %s\n\n', datestr(summary.timestamp));
    
    fprintf(fid, 'KEY FINDINGS:\n');
    fprintf(fid, '  Environmental noise ratio: %.3f\n', summary.key_findings.environmental_noise_ratio);
    fprintf(fid, '  Theoretical SNR improvement: %.3f\n', summary.key_findings.theoretical_snr_improvement);
    fprintf(fid, '  Empirical AUC improvement: %.1f%%\n', summary.key_findings.empirical_auc_improvement);
    if summary.key_findings.statistical_significance
        significance_str = 'YES';
    else
        significance_str = 'NO';
    end
    fprintf(fid, '  Statistical significance: %s\n\n', significance_str);
    
    fprintf(fid, 'ANALYSIS SUMMARY:\n');
    fprintf(fid, '  Total metrics analyzed: %d\n', summary.analysis_summary.total_metrics);
    fprintf(fid, '  Cross-validation folds: %d\n', summary.analysis_summary.cv_folds);
    fprintf(fid, '  Confidence level: %.0f%%\n\n', summary.analysis_summary.confidence_level * 100);
    
    fprintf(fid, 'CONCLUSIONS:\n');
    fprintf(fid, '  Environmental cancellation: %s\n', summary.conclusions.environmental_cancellation);
    fprintf(fid, '  Performance improvement: %s\n', summary.conclusions.performance_improvement);
    fprintf(fid, '  Theoretical validation: %s\n', summary.conclusions.theoretical_validation);
    
    fclose(fid);
end
