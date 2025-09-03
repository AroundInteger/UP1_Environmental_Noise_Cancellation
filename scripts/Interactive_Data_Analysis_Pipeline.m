%% ========================================================================
% INTERACTIVE DATA ANALYSIS PIPELINE
% ========================================================================
% 
% This script provides a user-friendly pipeline for analyzing any dataset
% to determine optimal measurement strategies (relative vs absolute).
% 
% Key Features:
% 1. Automatic environmental noise detection (η)
% 2. Optimal measurement strategy determination
% 3. SNR improvement predictions
% 4. Clear decision guidance with visualizations
% 5. Comprehensive analysis report
%
% Usage:
% 1. Load your data (CSV format)
% 2. Specify team/group columns
% 3. Run analysis
% 4. Get comprehensive results and recommendations
%
% Author: AI Assistant
% Date: 2024
% Purpose: User-friendly data analysis pipeline
%
% ========================================================================

%% Setup and Configuration
clear; clc; close all;

% Add paths
script_dir = fileparts(mfilename('fullpath'));
project_root = fullfile(script_dir, '..');
cd(project_root);
addpath(genpath('src'));

% Configuration
config = struct();
config.output_dir = 'outputs/user_analysis';
config.save_figures = true;
config.verbose = true;
config.interactive = true;

% Create output directory
if ~exist(config.output_dir, 'dir')
    mkdir(config.output_dir);
end

fprintf('=== INTERACTIVE DATA ANALYSIS PIPELINE ===\n');
fprintf('Script: %s\n', mfilename);
fprintf('Date: %s\n', datestr(now));
fprintf('Project Root: %s\n', project_root);
fprintf('Output Directory: %s\n', config.output_dir);
fprintf('\n');

%% Step 1: Data Loading Interface
fprintf('STEP 1: Data loading interface...\n');

fprintf('\n=== DATA LOADING OPTIONS ===\n');
fprintf('1. Load from CSV file\n');
fprintf('2. Use sample rugby data (for demonstration)\n');
fprintf('3. Generate synthetic data (for testing)\n\n');

% Interactive data selection
if config.interactive
    choice = input('Select option (1-3): ');
else
    choice = 2; % Default to sample data for demonstration
end

switch choice
    case 1
        % Load user data
        fprintf('Please provide the path to your CSV file:\n');
        if config.interactive
            file_path = input('File path: ', 's');
        else
            file_path = 'data/raw/S20Isolated.csv'; % Default for demo
        end
        
        try
            user_data = readtable(file_path);
            fprintf('✓ Data loaded successfully: %d rows, %d columns\n', height(user_data), width(user_data));
        catch ME
            error('Failed to load data: %s', ME.message);
        end
        
    case 2
        % Use sample rugby data
        fprintf('Loading sample rugby data...\n');
        try
            user_data = readtable('data/raw/S20Isolated.csv');
            fprintf('✓ Sample rugby data loaded: %d rows, %d columns\n', height(user_data), width(user_data));
        catch ME
            error('Sample data not found: %s', ME.message);
        end
        
    case 3
        % Generate synthetic data
        fprintf('Generating synthetic data...\n');
        user_data = generateSyntheticData();
        fprintf('✓ Synthetic data generated: %d rows, %d columns\n', height(user_data), width(user_data));
        
    otherwise
        error('Invalid choice. Please select 1, 2, or 3.');
end

%% Step 2: Data Structure Analysis
fprintf('\nSTEP 2: Analyzing data structure...\n');

fprintf('\nData Structure Analysis:\n');
fprintf('=======================\n');

% Display column information
fprintf('Available columns:\n');
for i = 1:min(10, width(user_data))
    fprintf('  %d. %s\n', i, user_data.Properties.VariableNames{i});
end
if width(user_data) > 10
    fprintf('  ... and %d more columns\n', width(user_data) - 10);
end

% Identify potential team/group columns
team_candidates = {};
outcome_candidates = {};
metric_candidates = {};

for i = 1:width(user_data)
    col_name = user_data.Properties.VariableNames{i};
    col_data = user_data.(col_name);
    
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

fprintf('\nDetected column types:\n');
fprintf('Team/Group candidates: %s\n', strjoin(team_candidates, ', '));
fprintf('Outcome candidates: %s\n', strjoin(outcome_candidates, ', '));
fprintf('Metric candidates: %s\n', strjoin(metric_candidates(1:min(5, length(metric_candidates))), ', '));

%% Step 3: Interactive Column Selection
fprintf('\nSTEP 3: Interactive column selection...\n');

% Select team column
if config.interactive && ~isempty(team_candidates)
    fprintf('\nSelect team/group column:\n');
    for i = 1:length(team_candidates)
        fprintf('  %d. %s\n', i, team_candidates{i});
    end
    team_choice = input('Team column (number): ');
    team_col = team_candidates{team_choice};
else
    % Auto-select or use default
    if ~isempty(team_candidates)
        team_col = team_candidates{1};
    else
        team_col = 'Team_Stats_for'; % Default for rugby data
    end
end

% Select outcome column
if config.interactive && ~isempty(outcome_candidates)
    fprintf('\nSelect outcome column:\n');
    for i = 1:length(outcome_candidates)
        fprintf('  %d. %s\n', i, outcome_candidates{i});
    end
    outcome_choice = input('Outcome column (number): ');
    outcome_col = outcome_candidates{outcome_choice};
else
    % Auto-select or use default
    if ~isempty(outcome_candidates)
        outcome_col = outcome_candidates{1};
    else
        outcome_col = 'Match_Outcome'; % Default
    end
end

% Select metric columns
if config.interactive && ~isempty(metric_candidates)
    fprintf('\nSelect metric columns (enter numbers separated by commas):\n');
    for i = 1:min(10, length(metric_candidates))
        fprintf('  %d. %s\n', i, metric_candidates{i});
    end
    if length(metric_candidates) > 10
        fprintf('  ... and %d more\n', length(metric_candidates) - 10);
    end
    metric_choice = input('Metric columns: ', 's');
    metric_indices = str2num(metric_choice);
    metric_cols = metric_candidates(metric_indices);
else
    % Auto-select first 5 metrics
    metric_cols = metric_candidates(1:min(5, length(metric_candidates)));
end

fprintf('\nSelected columns:\n');
fprintf('  Team: %s\n', team_col);
fprintf('  Outcome: %s\n', outcome_col);
fprintf('  Metrics: %s\n', strjoin(metric_cols, ', '));

%% Step 4: Environmental Noise Detection
fprintf('\nSTEP 4: Environmental noise detection...\n');

fprintf('\nEnvironmental Noise Analysis:\n');
fprintf('============================\n');

% Analyze data structure for environmental noise
env_analysis = analyzeEnvironmentalNoise(user_data, team_col, outcome_col, metric_cols);

fprintf('Environmental Noise Assessment:\n');
fprintf('------------------------------\n');
fprintf('η (environmental noise ratio): %.3f\n', env_analysis.eta);
fprintf('Environmental noise level: %s\n', env_analysis.noise_level);
fprintf('Correlation between teams: %.3f\n', env_analysis.team_correlation);
fprintf('Environmental effects detected: %s\n', string(env_analysis.has_environmental_effects));

%% Step 5: Optimal Measurement Strategy Analysis
fprintf('\nSTEP 5: Optimal measurement strategy analysis...\n');

fprintf('\nMeasurement Strategy Analysis:\n');
fprintf('==============================\n');

% Analyze each metric
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
    
    fprintf('\nAnalyzing %s:\n', metric);
    
    % Calculate team-specific statistics
    [sigma_A, sigma_B, r, snr_improvement, recommendation, confidence] = ...
        analyzeMetric(user_data, team_col, outcome_col, metric);
    
    % Store results
    strategy_results.metric{end+1} = metric;
    strategy_results.sigma_A(end+1) = sigma_A;
    strategy_results.sigma_B(end+1) = sigma_B;
    strategy_results.variance_ratio(end+1) = r;
    strategy_results.snr_improvement(end+1) = snr_improvement;
    strategy_results.recommendation{end+1} = recommendation;
    strategy_results.confidence(end+1) = confidence;
    
    fprintf('  σ_A = %.2f, σ_B = %.2f\n', sigma_A, sigma_B);
    fprintf('  r = σ_B/σ_A = %.3f\n', r);
    fprintf('  SNR improvement: %.2fx\n', snr_improvement);
    fprintf('  Recommendation: %s\n', recommendation);
    fprintf('  Confidence: %.1f%%\n', confidence*100);
end

%% Step 6: Decision Framework Application
fprintf('\nSTEP 6: Decision framework application...\n');

fprintf('\nDecision Framework Results:\n');
fprintf('==========================\n');

% Apply decision framework
decision_results = applyDecisionFramework(strategy_results, env_analysis);

fprintf('Overall Recommendation:\n');
fprintf('----------------------\n');
fprintf('Primary strategy: %s\n', decision_results.primary_strategy);
fprintf('Expected improvement: %.1f%%\n', decision_results.expected_improvement);
fprintf('Confidence level: %.1f%%\n', decision_results.confidence_level*100);

fprintf('\nDetailed Recommendations:\n');
fprintf('------------------------\n');
for i = 1:length(decision_results.detailed_recommendations)
    rec = decision_results.detailed_recommendations{i};
    fprintf('  %s: %s (%.1f%% confidence)\n', rec.metric, rec.strategy, rec.confidence*100);
end

%% Step 7: Visualization Generation
fprintf('\nSTEP 7: Generating visualizations...\n');

if config.save_figures
    % Create comprehensive visualization
    createAnalysisVisualization(strategy_results, env_analysis, decision_results, config.output_dir);
    fprintf('✓ Visualizations saved to: %s\n', config.output_dir);
end

%% Step 8: Report Generation
fprintf('\nSTEP 8: Generating comprehensive report...\n');

% Create comprehensive analysis report
report = createAnalysisReport(user_data, env_analysis, strategy_results, decision_results, config);

% Save report
report_file = fullfile(config.output_dir, 'analysis_report.mat');
save(report_file, 'report');
fprintf('✓ Analysis report saved to: %s\n', report_file);

% Generate text report
text_report_file = fullfile(config.output_dir, 'analysis_report.txt');
generateTextReport(report, text_report_file);
fprintf('✓ Text report saved to: %s\n', text_report_file);

%% Step 9: Final Summary
fprintf('\nSTEP 9: Final summary...\n');

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Environmental Noise Level: %s (η = %.3f)\n', env_analysis.noise_level, env_analysis.eta);
fprintf('Primary Strategy: %s\n', decision_results.primary_strategy);
fprintf('Expected Improvement: %.1f%%\n', decision_results.expected_improvement);
fprintf('Confidence Level: %.1f%%\n', decision_results.confidence_level*100);

fprintf('\nKey Findings:\n');
fprintf('------------\n');
fprintf('1. Environmental noise is %s\n', env_analysis.noise_level);
fprintf('2. %d/%d metrics recommend relative measures\n', ...
        sum(strcmp({strategy_results.recommendation{:}}, 'Use relative measures')), length(metric_cols));
fprintf('3. Average SNR improvement: %.2fx\n', mean(strategy_results.snr_improvement));
fprintf('4. Maximum possible improvement: %.2fx\n', max(strategy_results.snr_improvement));

fprintf('\nNext Steps:\n');
fprintf('----------\n');
fprintf('1. Review detailed recommendations in the report\n');
fprintf('2. Implement suggested measurement strategies\n');
fprintf('3. Monitor performance improvements\n');
fprintf('4. Consider environmental noise management if applicable\n');

fprintf('\n=== PIPELINE COMPLETE ===\n');
fprintf('Script completed successfully at: %s\n', datestr(now));
fprintf('All outputs saved to: %s\n', config.output_dir);

%% Helper Functions

function synthetic_data = generateSyntheticData()
    % Generate synthetic data for testing
    n_matches = 50;
    n_teams = 4;
    
    % Create synthetic data structure
    match_ids = repmat(1:n_matches, 2, 1);
    match_ids = match_ids(:);
    
    teams = {'Team_A', 'Team_B', 'Team_C', 'Team_D'};
    team_assignments = repmat(teams(1:2), 1, n_matches);
    
    % Generate synthetic metrics
    carries = 100 + 20*randn(2*n_matches, 1);
    metres = 500 + 100*randn(2*n_matches, 1);
    tackles = 20 + 5*randn(2*n_matches, 1);
    
    % Generate outcomes (slightly biased toward first team)
    outcomes = cell(2*n_matches, 1);
    for i = 1:n_matches
        if rand > 0.5
            outcomes{2*i-1} = 'Win';
            outcomes{2*i} = 'Loss';
        else
            outcomes{2*i-1} = 'Loss';
            outcomes{2*i} = 'Win';
        end
    end
    
    % Create table
    synthetic_data = table(match_ids, team_assignments', outcomes, carries, metres, tackles, ...
                          'VariableNames', {'Match_ID', 'Team', 'Outcome', 'Carries', 'Metres', 'Tackles'});
end

function env_analysis = analyzeEnvironmentalNoise(data, team_col, outcome_col, metric_cols)
    % Analyze environmental noise in the data
    
    % Calculate team correlation for first metric
    if ~isempty(metric_cols)
        metric = metric_cols{1};
        
        % Get unique teams
        unique_teams = unique(data.(team_col));
        if length(unique_teams) >= 2
            team1_data = data(data.(team_col) == unique_teams(1), metric);
            team2_data = data(data.(team_col) == unique_teams(2), metric);
            
            % Calculate correlation
            if length(team1_data) > 1 && length(team2_data) > 1
                team_correlation = corr(team1_data, team2_data, 'rows', 'complete');
            else
                team_correlation = 0;
            end
        else
            team_correlation = 0;
        end
        
        % Estimate environmental noise ratio
        % This is a simplified estimation - in practice, more sophisticated methods would be used
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
    team1_data = data(data.(team_col) == unique_teams(1), metric);
    team2_data = data(data.(team_col) == unique_teams(2), metric);
    
    % Remove missing values
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
    
    sgtitle('Interactive Data Analysis Pipeline Results');
    
    % Save figure
    fig_file = fullfile(output_dir, 'analysis_visualization.png');
    saveas(gcf, fig_file);
end

function report = createAnalysisReport(data, env_analysis, strategy_results, decision_results, config)
    % Create comprehensive analysis report
    
    report = struct();
    report.timestamp = datestr(now);
    report.analysis_type = 'Interactive Data Analysis Pipeline';
    report.data_info = struct();
    report.data_info.n_rows = height(data);
    report.data_info.n_cols = width(data);
    report.data_info.columns = data.Properties.VariableNames;
    
    report.environmental_analysis = env_analysis;
    report.strategy_results = strategy_results;
    report.decision_results = decision_results;
    report.config = config;
    
    % Calculate summary statistics
    report.summary = struct();
    report.summary.n_metrics_analyzed = length(strategy_results.metric);
    report.summary.avg_snr_improvement = mean(strategy_results.snr_improvement);
    report.summary.max_snr_improvement = max(strategy_results.snr_improvement);
    report.summary.relative_measures_recommended = sum(strcmp({strategy_results.recommendation{:}}, 'Use relative measures'));
    report.summary.absolute_measures_recommended = sum(strcmp({strategy_results.recommendation{:}}, 'Use absolute measures'));
    report.summary.avg_confidence = mean(strategy_results.confidence);
end

function generateTextReport(report, filename)
    % Generate human-readable text report
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'INTERACTIVE DATA ANALYSIS PIPELINE REPORT\n');
    fprintf(fid, '========================================\n\n');
    
    fprintf(fid, 'Analysis Date: %s\n', report.timestamp);
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
