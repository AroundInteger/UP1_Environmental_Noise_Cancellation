%% ========================================================================
% DEMO USER ANALYSIS PIPELINE - NON-INTERACTIVE VERSION
% ========================================================================
% 
% This script demonstrates the Interactive Data Analysis Pipeline
% using sample data. It shows how the pipeline works without
% requiring user input.
%
% Author: AI Assistant
% Date: 2024
% Purpose: Demonstrate user analysis pipeline
%
% ========================================================================

clear; clc; close all;

fprintf('=== DEMO: USER DATA ANALYSIS PIPELINE ===\n');
fprintf('Demonstrating the Interactive Data Analysis Pipeline\n');
fprintf('using sample rugby data...\n\n');

%% Step 1: Load Sample Data
fprintf('STEP 1: Loading sample data...\n');
fprintf('==============================\n');

try
    % Load sample rugby data
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    file_path = fullfile(project_root, 'data', 'raw', 'S20Isolated.csv');
    data = readtable(file_path);
    fprintf('✓ Sample rugby data loaded: %d rows, %d columns\n', height(data), width(data));
    
    % Show column preview
    fprintf('\nColumn preview:\n');
    for i = 1:min(5, width(data))
        fprintf('  %d. %s\n', i, data.Properties.VariableNames{i});
    end
    if width(data) > 5
        fprintf('  ... and %d more columns\n', width(data) - 5);
    end
    
catch ME
    fprintf('✗ Error loading sample data: %s\n', ME.message);
    fprintf('Please ensure the sample data file exists.\n');
    return;
end

%% Step 2: Run Analysis
fprintf('\nSTEP 2: Running comprehensive analysis...\n');
fprintf('==========================================\n');

% Set up configuration for automated analysis
config = struct();
config.output_dir = 'outputs/demo_analysis';
config.save_figures = true;
config.verbose = true;
config.user_file = file_path;

% Run the analysis pipeline
try
    runDemoAnalysis(data, config);
    fprintf('\n✓ Analysis completed successfully!\n');
catch ME
    fprintf('\n✗ Error during analysis: %s\n', ME.message);
    return;
end

%% Step 3: Display Results
fprintf('\nSTEP 3: Analysis Results\n');
fprintf('========================\n');

% Load and display results
results_file = fullfile(config.output_dir, 'analysis_report.mat');
if exist(results_file, 'file')
    load(results_file, 'report');
    
    fprintf('\nENVIRONMENTAL NOISE ANALYSIS:\n');
    fprintf('Environmental Noise Level: %s\n', report.environmental_analysis.noise_level);
    fprintf('Environmental Noise Ratio (η): %.3f\n', report.environmental_analysis.eta);
    fprintf('Team Correlation: %.3f\n', report.environmental_analysis.team_correlation);
    fprintf('Environmental Effects Detected: %s\n', string(report.environmental_analysis.has_environmental_effects));
    
    fprintf('\nMEASUREMENT STRATEGY RECOMMENDATIONS:\n');
    fprintf('Primary Strategy: %s\n', report.decision_results.primary_strategy);
    fprintf('Expected Improvement: %.1f%%\n', report.decision_results.expected_improvement);
    fprintf('Confidence Level: %.1f%%\n', report.decision_results.confidence_level*100);
    
    fprintf('\nDETAILED METRIC ANALYSIS:\n');
    for i = 1:length(report.strategy_results.metric)
        fprintf('  %s: %s (%.2fx improvement, %.1f%% confidence)\n', ...
                report.strategy_results.metric{i}, ...
                report.strategy_results.recommendation{i}, ...
                report.strategy_results.snr_improvement(i), ...
                report.strategy_results.confidence(i)*100);
    end
    
    fprintf('\nSUMMARY:\n');
    fprintf('Metrics Analyzed: %d\n', report.summary.n_metrics_analyzed);
    fprintf('Average SNR Improvement: %.2fx\n', report.summary.avg_snr_improvement);
    fprintf('Maximum SNR Improvement: %.2fx\n', report.summary.max_snr_improvement);
    fprintf('Relative Measures Recommended: %d/%d\n', ...
            report.summary.relative_measures_recommended, report.summary.n_metrics_analyzed);
    
else
    fprintf('Results file not found. Please check the analysis output.\n');
end

%% Step 4: Next Steps
fprintf('\nSTEP 4: Next Steps\n');
fprintf('==================\n');

fprintf('1. Review the detailed report in: %s\n', config.output_dir);
fprintf('2. Check the visualization: %s/analysis_visualization.png\n', config.output_dir);
fprintf('3. Read the text report: %s/analysis_report.txt\n', config.output_dir);
fprintf('4. Try the interactive version with your own data\n');
fprintf('5. Explore the theoretical framework in our documentation\n\n');

fprintf('This demo shows how the pipeline:\n');
fprintf('- Automatically detects environmental noise\n');
fprintf('- Determines optimal measurement strategies\n');
fprintf('- Provides clear recommendations with confidence levels\n');
fprintf('- Generates comprehensive visualizations and reports\n\n');

fprintf('Ready to analyze your own data? Use scripts/Run_User_Analysis.m\n');
fprintf('Thank you for exploring the Interactive Data Analysis Pipeline!\n');

%% Helper Function
function runDemoAnalysis(data, config)
    % Run the demo analysis pipeline
    
    % Add paths
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    cd(project_root);
    addpath(genpath('src'));
    
    % Create output directory
    if ~exist(config.output_dir, 'dir')
        mkdir(config.output_dir);
    end
    
    %% Data Structure Analysis
    fprintf('Analyzing data structure...\n');
    
    % Identify potential columns
    team_candidates = {};
    outcome_candidates = {};
    metric_candidates = {};
    
    for i = 1:width(data)
        col_name = data.Properties.VariableNames{i};
        col_data = data.(col_name);
        
        % Check for team/group identifiers
        if iscategorical(col_data) || iscell(col_data) || isstring(col_data)
            unique_vals = unique(col_data);
            if length(unique_vals) >= 2 && length(unique_vals) <= 20
                team_candidates{end+1} = col_name;
            end
        end
        
        % Check for outcome variables
        if iscategorical(col_data) || iscell(col_data) || isstring(col_data)
            unique_vals = unique(col_data);
            if length(unique_vals) == 2
                outcome_candidates{end+1} = col_name;
            end
        end
        
        % Check for metric variables (numeric)
        if isnumeric(col_data) && ~all(isnan(col_data))
            metric_candidates{end+1} = col_name;
        end
    end
    
    % Auto-select columns
    if ~isempty(team_candidates)
        team_col = team_candidates{1};
    else
        team_col = 'Team_Stats_for'; % Default for rugby data
    end
    
    if ~isempty(outcome_candidates)
        outcome_col = outcome_candidates{1};
    else
        outcome_col = 'Match_Outcome'; % Default
    end
    
    % Select good metrics (exclude obvious non-performance metrics)
    good_metrics = {'Carry', 'MetresMade', 'DefenderBeaten', 'Offload', 'Pass', 'Tackle'};
    metric_cols = {};
    for i = 1:length(good_metrics)
        if any(strcmp(metric_candidates, good_metrics{i}))
            metric_cols{end+1} = good_metrics{i};
        end
    end
    
    % If no good metrics found, use first 5
    if isempty(metric_cols)
        metric_cols = metric_candidates(1:min(5, length(metric_candidates)));
    end
    
    fprintf('Selected columns:\n');
    fprintf('  Team: %s\n', team_col);
    fprintf('  Outcome: %s\n', outcome_col);
    fprintf('  Metrics: %s\n', strjoin(metric_cols, ', '));
    
    %% Environmental Noise Analysis
    fprintf('Analyzing environmental noise...\n');
    
    env_analysis = analyzeEnvironmentalNoise(data, team_col, outcome_col, metric_cols);
    
    %% Strategy Analysis
    fprintf('Analyzing measurement strategies...\n');
    
    strategy_results = struct();
    strategy_results.metric = {};
    strategy_results.sigma_A = [];
    strategy_results.sigma_B = [];
    strategy_results.variance_ratio = [];
    strategy_results.snr_improvement = [];
    strategy_results.recommendation = {};
    strategy_results.confidence = [];
    
    for i = 1:length(metric_cols)
        metric = metric_cols{i};
        
        [sigma_A, sigma_B, r, snr_improvement, recommendation, confidence] = ...
            analyzeMetric(data, team_col, outcome_col, metric);
        
        strategy_results.metric{end+1} = metric;
        strategy_results.sigma_A(end+1) = sigma_A;
        strategy_results.sigma_B(end+1) = sigma_B;
        strategy_results.variance_ratio(end+1) = r;
        strategy_results.snr_improvement(end+1) = snr_improvement;
        strategy_results.recommendation{end+1} = recommendation;
        strategy_results.confidence(end+1) = confidence;
    end
    
    %% Decision Framework
    fprintf('Applying decision framework...\n');
    
    decision_results = applyDecisionFramework(strategy_results, env_analysis);
    
    %% Create Report
    fprintf('Generating report...\n');
    
    report = struct();
    report.timestamp = datestr(now);
    report.analysis_type = 'Demo User Data Analysis';
    report.data_info = struct();
    report.data_info.n_rows = height(data);
    report.data_info.n_cols = width(data);
    report.data_info.file_path = config.user_file;
    
    report.environmental_analysis = env_analysis;
    report.strategy_results = strategy_results;
    report.decision_results = decision_results;
    
    % Summary statistics
    report.summary = struct();
    report.summary.n_metrics_analyzed = length(strategy_results.metric);
    report.summary.avg_snr_improvement = mean(strategy_results.snr_improvement);
    report.summary.max_snr_improvement = max(strategy_results.snr_improvement);
    report.summary.relative_measures_recommended = sum(strcmp({strategy_results.recommendation{:}}, 'Use relative measures'));
    report.summary.absolute_measures_recommended = sum(strcmp({strategy_results.recommendation{:}}, 'Use absolute measures'));
    report.summary.avg_confidence = mean(strategy_results.confidence);
    
    % Save report
    report_file = fullfile(config.output_dir, 'analysis_report.mat');
    save(report_file, 'report');
    
    % Generate text report
    text_report_file = fullfile(config.output_dir, 'analysis_report.txt');
    generateTextReport(report, text_report_file);
    
    % Create visualization
    if config.save_figures
        createAnalysisVisualization(strategy_results, env_analysis, decision_results, config.output_dir);
    end
end

function env_analysis = analyzeEnvironmentalNoise(data, team_col, outcome_col, metric_cols)
    % Analyze environmental noise in the data
    
    if ~isempty(metric_cols)
        metric = metric_cols{1};
        
        % Get unique teams
        unique_teams = unique(data.(team_col));
        if length(unique_teams) >= 2
            team1_data = data(strcmp(data.(team_col), unique_teams{1}), metric);
            team2_data = data(strcmp(data.(team_col), unique_teams{2}), metric);
            
            % Extract numeric data
            team1_data = team1_data.(metric);
            team2_data = team2_data.(metric);
            
            % For environmental noise detection, we'll use a simplified approach
            % Calculate correlation only if we have matched data points
            if length(team1_data) > 1 && length(team2_data) > 1
                % Use minimum length for correlation
                min_len = min(length(team1_data), length(team2_data));
                if min_len > 1
                    team_correlation = corr(team1_data(1:min_len), team2_data(1:min_len));
                else
                    team_correlation = 0;
                end
            else
                team_correlation = 0;
            end
        else
            team_correlation = 0;
        end
        
        % Estimate environmental noise ratio
        if abs(team_correlation) > 0.3
            eta = abs(team_correlation);
            has_environmental_effects = true;
        else
            eta = 0;
            has_environmental_effects = false;
        end
        
        % Determine noise level
        if eta < 0.1
            noise_level = 'Very Low';
        elseif eta < 0.3
            noise_level = 'Low';
        elseif eta < 0.5
            noise_level = 'Moderate';
        elseif eta < 0.7
            noise_level = 'High';
        else
            noise_level = 'Very High';
        end
    else
        eta = 0;
        team_correlation = 0;
        has_environmental_effects = false;
        noise_level = 'Very Low';
    end
    
    env_analysis = struct();
    env_analysis.eta = eta;
    env_analysis.team_correlation = team_correlation;
    env_analysis.has_environmental_effects = has_environmental_effects;
    env_analysis.noise_level = noise_level;
end

function [sigma_A, sigma_B, r, snr_improvement, recommendation, confidence] = analyzeMetric(data, team_col, outcome_col, metric)
    % Analyze a specific metric
    
    % Get unique teams
    unique_teams = unique(data.(team_col));
    if length(unique_teams) < 2
        error('Need at least 2 teams for analysis');
    end
    
    % Calculate team-specific statistics
    team1_data = data(strcmp(data.(team_col), unique_teams{1}), metric);
    team2_data = data(strcmp(data.(team_col), unique_teams{2}), metric);
    
    % Extract numeric data and remove missing values
    team1_data = team1_data.(metric);
    team2_data = team2_data.(metric);
    team1_data = team1_data(~isnan(team1_data));
    team2_data = team2_data(~isnan(team2_data));
    
    if length(team1_data) < 3 || length(team2_data) < 3
        % Insufficient data
        sigma_A = NaN;
        sigma_B = NaN;
        r = NaN;
        snr_improvement = NaN;
        recommendation = 'Insufficient data';
        confidence = 0;
        return;
    end
    
    % Calculate standard deviations
    sigma_A = std(team1_data);
    sigma_B = std(team2_data);
    
    % Calculate variance ratio
    r = sigma_B / sigma_A;
    
    % Calculate SNR improvement
    snr_improvement = 4 / (1 + r^2);
    
    % Determine recommendation
    if r < sqrt(3)
        recommendation = 'Use relative measures';
        confidence = 0.8;
    else
        recommendation = 'Use absolute measures';
        confidence = 0.8;
    end
    
    % Adjust confidence based on data quality
    min_samples = min(length(team1_data), length(team2_data));
    if min_samples < 10
        confidence = confidence * 0.7;
    elseif min_samples < 20
        confidence = confidence * 0.9;
    end
end

function decision_results = applyDecisionFramework(strategy_results, env_analysis)
    % Apply decision framework to provide overall recommendations
    
    % Count recommendations
    relative_count = sum(strcmp({strategy_results.recommendation{:}}, 'Use relative measures'));
    absolute_count = sum(strcmp({strategy_results.recommendation{:}}, 'Use absolute measures'));
    
    % Determine primary strategy
    if relative_count > absolute_count
        primary_strategy = 'Relative measures';
        expected_improvement = mean(strategy_results.snr_improvement(strcmp({strategy_results.recommendation{:}}, 'Use relative measures'))) * 100 - 100;
    else
        primary_strategy = 'Absolute measures';
        expected_improvement = 0; % No improvement expected
    end
    
    % Calculate confidence level
    confidence_level = mean(strategy_results.confidence);
    
    % Create detailed recommendations
    detailed_recommendations = {};
    for i = 1:length(strategy_results.metric)
        rec = struct();
        rec.metric = strategy_results.metric{i};
        rec.strategy = strategy_results.recommendation{i};
        rec.confidence = strategy_results.confidence(i);
        detailed_recommendations{end+1} = rec;
    end
    
    decision_results = struct();
    decision_results.primary_strategy = primary_strategy;
    decision_results.expected_improvement = expected_improvement;
    decision_results.confidence_level = confidence_level;
    decision_results.detailed_recommendations = detailed_recommendations;
end

function createAnalysisVisualization(strategy_results, env_analysis, decision_results, output_dir)
    % Create comprehensive visualization
    
    figure('Position', [100, 100, 1400, 1000]);
    
    % Subplot 1: SNR improvement by metric
    subplot(2,3,1);
    bar(strategy_results.snr_improvement);
    xlabel('Metric');
    ylabel('SNR Improvement');
    title('SNR Improvement by Metric');
    set(gca, 'XTickLabel', strategy_results.metric, 'XTickLabelRotation', 45);
    yline(1, 'r--', 'No Improvement');
    yline(4, 'g--', 'Maximum (4x)');
    grid on;
    
    % Subplot 2: Variance ratios
    subplot(2,3,2);
    bar(strategy_results.variance_ratio);
    xlabel('Metric');
    ylabel('Variance Ratio (r)');
    title('Variance Ratios by Metric');
    set(gca, 'XTickLabel', strategy_results.metric, 'XTickLabelRotation', 45);
    yline(sqrt(3), 'r--', 'Break-even (√3)');
    grid on;
    
    % Subplot 3: Environmental noise analysis
    subplot(2,3,3);
    pie([env_analysis.eta, 1-env_analysis.eta], {'Environmental Noise', 'Independent Variation'});
    title(sprintf('Environmental Noise Level: %s', env_analysis.noise_level));
    
    % Subplot 4: Decision framework
    subplot(2,3,4);
    relative_count = sum(strcmp({strategy_results.recommendation{:}}, 'Use relative measures'));
    absolute_count = sum(strcmp({strategy_results.recommendation{:}}, 'Use absolute measures'));
    bar([relative_count, absolute_count]);
    xlabel('Strategy');
    ylabel('Number of Metrics');
    title('Recommended Strategies');
    set(gca, 'XTickLabel', {'Relative', 'Absolute'});
    grid on;
    
    % Subplot 5: Confidence levels
    subplot(2,3,5);
    bar(strategy_results.confidence * 100);
    xlabel('Metric');
    ylabel('Confidence (%)');
    title('Confidence Levels by Metric');
    set(gca, 'XTickLabel', strategy_results.metric, 'XTickLabelRotation', 45);
    yline(80, 'r--', 'High Confidence');
    grid on;
    
    % Subplot 6: Summary
    subplot(2,3,6);
    text(0.1, 0.8, sprintf('Primary Strategy: %s', decision_results.primary_strategy), 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.6, sprintf('Expected Improvement: %.1f%%', decision_results.expected_improvement), 'FontSize', 12);
    text(0.1, 0.4, sprintf('Confidence Level: %.1f%%', decision_results.confidence_level*100), 'FontSize', 12);
    text(0.1, 0.2, sprintf('Environmental Noise: %s', env_analysis.noise_level), 'FontSize', 12);
    axis off;
    title('Analysis Summary');
    
    sgtitle('Demo: User Data Analysis Results');
    
    % Save figure
    fig_file = fullfile(output_dir, 'analysis_visualization.png');
    saveas(gcf, fig_file);
end

function generateTextReport(report, filename)
    % Generate human-readable text report
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'DEMO USER DATA ANALYSIS REPORT\n');
    fprintf(fid, '==============================\n\n');
    
    fprintf(fid, 'Analysis Date: %s\n', report.timestamp);
    fprintf(fid, 'Data File: %s\n', report.data_info.file_path);
    fprintf(fid, 'Data: %d rows, %d columns\n\n', report.data_info.n_rows, report.data_info.n_cols);
    
    fprintf(fid, 'ENVIRONMENTAL NOISE ANALYSIS\n');
    fprintf(fid, '============================\n');
    fprintf(fid, 'Environmental Noise Level: %s\n', report.environmental_analysis.noise_level);
    fprintf(fid, 'Environmental Noise Ratio (η): %.3f\n', report.environmental_analysis.eta);
    fprintf(fid, 'Team Correlation: %.3f\n', report.environmental_analysis.team_correlation);
    fprintf(fid, 'Environmental Effects Detected: %s\n\n', string(report.environmental_analysis.has_environmental_effects));
    
    fprintf(fid, 'MEASUREMENT STRATEGY ANALYSIS\n');
    fprintf(fid, '=============================\n');
    for i = 1:length(report.strategy_results.metric)
        fprintf(fid, '%s:\n', report.strategy_results.metric{i});
        fprintf(fid, '  σ_A = %.2f, σ_B = %.2f\n', report.strategy_results.sigma_A(i), report.strategy_results.sigma_B(i));
        fprintf(fid, '  Variance Ratio (r) = %.3f\n', report.strategy_results.variance_ratio(i));
        fprintf(fid, '  SNR Improvement = %.2fx\n', report.strategy_results.snr_improvement(i));
        fprintf(fid, '  Recommendation = %s\n', report.strategy_results.recommendation{i});
        fprintf(fid, '  Confidence = %.1f%%\n\n', report.strategy_results.confidence(i)*100);
    end
    
    fprintf(fid, 'DECISION FRAMEWORK RESULTS\n');
    fprintf(fid, '==========================\n');
    fprintf(fid, 'Primary Strategy: %s\n', report.decision_results.primary_strategy);
    fprintf(fid, 'Expected Improvement: %.1f%%\n', report.decision_results.expected_improvement);
    fprintf(fid, 'Confidence Level: %.1f%%\n\n', report.decision_results.confidence_level*100);
    
    fprintf(fid, 'SUMMARY STATISTICS\n');
    fprintf(fid, '==================\n');
    fprintf(fid, 'Metrics Analyzed: %d\n', report.summary.n_metrics_analyzed);
    fprintf(fid, 'Average SNR Improvement: %.2fx\n', report.summary.avg_snr_improvement);
    fprintf(fid, 'Maximum SNR Improvement: %.2fx\n', report.summary.max_snr_improvement);
    fprintf(fid, 'Relative Measures Recommended: %d\n', report.summary.relative_measures_recommended);
    fprintf(fid, 'Absolute Measures Recommended: %d\n', report.summary.absolute_measures_recommended);
    fprintf(fid, 'Average Confidence: %.1f%%\n', report.summary.avg_confidence*100);
    
    fclose(fid);
end
