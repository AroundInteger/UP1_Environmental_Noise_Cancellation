%% ========================================================================
% COMPREHENSIVE LOG-TRANSFORMATION ANALYSIS
% ========================================================================
% 
% This script provides a comprehensive analysis of log-transformation
% effects on KPI analysis, including:
% 1. Normality testing for original and log-transformed data
% 2. SNR improvement analysis for both versions
% 3. Interpretation of log-ratios vs. absolute differences
% 4. Recommendations for KPI selection
%
% Author: AI Assistant
% Date: 2024
% Purpose: Comprehensive log-transformation analysis
%
% ========================================================================

clear; clc; close all;

fprintf('=== COMPREHENSIVE LOG-TRANSFORMATION ANALYSIS ===\n');
fprintf('Analyzing log-transformation effects on KPI analysis...\n\n');

%% Step 1: Load Data
fprintf('STEP 1: Loading data...\n');
fprintf('======================\n');

try
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    file_path = fullfile(project_root, 'data', 'raw', 'Example_Formatted_Dataset.csv');
    data = readtable(file_path);
    fprintf('✓ Dataset loaded: %d rows, %d columns\n', height(data), width(data));
catch ME
    error('Failed to load dataset: %s', ME.message);
end

%% Step 2: Define All KPIs
fprintf('\nSTEP 2: Defining all KPIs...\n');
fprintf('============================\n');

% All metric columns
metric_cols = {'Carries', 'Metres_Made', 'Defenders_Beaten', 'Offloads', 'Passes', 'Tackles', 'Clean_Breaks', 'Turnovers_Won', 'Rucks_Won', 'Lineout_Throws_Won'};

fprintf('Analyzing %d KPIs: %s\n', length(metric_cols), strjoin(metric_cols, ', '));

%% Step 3: Comprehensive Analysis
fprintf('\nSTEP 3: Comprehensive analysis...\n');
fprintf('=================================\n');

% Initialize results structure
results = struct();
results.metric = {};
results.original_skewness = [];
results.original_kurtosis = [];
results.log_skewness = [];
results.log_kurtosis = [];
results.original_sigma_A = [];
results.original_sigma_B = [];
results.log_sigma_A = [];
results.log_sigma_B = [];
results.original_r = [];
results.log_r = [];
results.original_snr_improvement = [];
results.log_snr_improvement = [];
results.original_recommendation = {};
results.log_recommendation = {};
results.interpretation = {};
results.log_ratio_meaning = {};

fprintf('Comprehensive KPI Analysis:\n');
fprintf('Metric\t\t\tOrig r\tLog r\tOrig SNR\tLog SNR\t\tInterpretation\n');
fprintf('------\t\t\t------\t-----\t--------\t-------\t\t-------------\n');

for i = 1:length(metric_cols)
    metric = metric_cols{i};
    
    % Get unique teams
    unique_teams = unique(data.Team);
    if length(unique_teams) < 2
        continue;
    end
    
    % Get team data
    team1_data = data(strcmp(data.Team, unique_teams{1}), metric);
    team2_data = data(strcmp(data.Team, unique_teams{2}), metric);
    
    team1_data = team1_data.(metric);
    team2_data = team2_data.(metric);
    team1_data = team1_data(~isnan(team1_data));
    team2_data = team2_data(~isnan(team2_data));
    
    if length(team1_data) < 3 || length(team2_data) < 3
        continue;
    end
    
    % Calculate statistics for original data
    sigma_A_orig = std(team1_data);
    sigma_B_orig = std(team2_data);
    r_orig = sigma_B_orig / sigma_A_orig;
    snr_improvement_orig = 4 / (1 + r_orig^2);
    
    % Calculate statistics for log-transformed data
    team1_data_log = log(team1_data + 1); % Add 1 to handle zeros
    team2_data_log = log(team2_data + 1);
    
    sigma_A_log = std(team1_data_log);
    sigma_B_log = std(team2_data_log);
    r_log = sigma_B_log / sigma_A_log;
    snr_improvement_log = 4 / (1 + r_log^2);
    
    % Calculate skewness and kurtosis
    skew_orig = skewness(team1_data);
    kurt_orig = kurtosis(team1_data);
    skew_log = skewness(team1_data_log);
    kurt_log = kurtosis(team1_data_log);
    
    % Determine recommendations
    if r_orig < sqrt(3)
        rec_orig = 'Relative';
    else
        rec_orig = 'Absolute';
    end
    
    if r_log < sqrt(3)
        rec_log = 'Relative';
    else
        rec_log = 'Absolute';
    end
    
    % Determine interpretation
    if snr_improvement_log > snr_improvement_orig * 1.05 % 5% improvement threshold
        interpretation = 'Log better';
    elseif snr_improvement_log < snr_improvement_orig * 0.95 % 5% degradation threshold
        interpretation = 'Original better';
    else
        interpretation = 'Equivalent';
    end
    
    % Determine log-ratio meaning
    if strcmp(rec_log, 'Relative')
        log_ratio_meaning = 'Log-ratio R'' = log(X_A/X_B) recommended';
    else
        log_ratio_meaning = 'Log-ratio not recommended';
    end
    
    % Store results
    results.metric{end+1} = metric;
    results.original_skewness(end+1) = skew_orig;
    results.original_kurtosis(end+1) = kurt_orig;
    results.log_skewness(end+1) = skew_log;
    results.log_kurtosis(end+1) = kurt_log;
    results.original_sigma_A(end+1) = sigma_A_orig;
    results.original_sigma_B(end+1) = sigma_B_orig;
    results.log_sigma_A(end+1) = sigma_A_log;
    results.log_sigma_B(end+1) = sigma_B_log;
    results.original_r(end+1) = r_orig;
    results.log_r(end+1) = r_log;
    results.original_snr_improvement(end+1) = snr_improvement_orig;
    results.log_snr_improvement(end+1) = snr_improvement_log;
    results.original_recommendation{end+1} = rec_orig;
    results.log_recommendation{end+1} = rec_log;
    results.interpretation{end+1} = interpretation;
    results.log_ratio_meaning{end+1} = log_ratio_meaning;
    
    fprintf('%s\t\t%.3f\t%.3f\t%.2fx\t\t%.2fx\t\t%s\n', metric, r_orig, r_log, snr_improvement_orig, snr_improvement_log, interpretation);
end

%% Step 4: Summary Analysis
fprintf('\nSTEP 4: Summary analysis...\n');
fprintf('==========================\n');

if ~isempty(results.metric)
    % Count improvements
    log_better = sum(strcmp(results.interpretation, 'Log better'));
    original_better = sum(strcmp(results.interpretation, 'Original better'));
    equivalent = sum(strcmp(results.interpretation, 'Equivalent'));
    
    fprintf('\nLog-transformation effects:\n');
    fprintf('  Log-transformed better: %d/%d KPIs\n', log_better, length(results.metric));
    fprintf('  Original better: %d/%d KPIs\n', original_better, length(results.metric));
    fprintf('  Equivalent: %d/%d KPIs\n', equivalent, length(results.metric));
    
    % Count recommendations
    orig_relative = sum(strcmp(results.original_recommendation, 'Relative'));
    log_relative = sum(strcmp(results.log_recommendation, 'Relative'));
    
    fprintf('\nRecommendation changes:\n');
    fprintf('  Original data: %d/%d KPIs recommend relative measures\n', orig_relative, length(results.metric));
    fprintf('  Log-transformed: %d/%d KPIs recommend relative measures\n', log_relative, length(results.metric));
    
    % Average improvements
    fprintf('\nAverage SNR improvements:\n');
    fprintf('  Original: %.2fx\n', mean(results.original_snr_improvement));
    fprintf('  Log-transformed: %.2fx\n', mean(results.log_snr_improvement));
    
    % Best performers
    [~, best_orig_idx] = max(results.original_snr_improvement);
    [~, best_log_idx] = max(results.log_snr_improvement);
    
    fprintf('\nBest performers:\n');
    fprintf('  Original: %s (%.2fx improvement)\n', results.metric{best_orig_idx}, results.original_snr_improvement(best_orig_idx));
    fprintf('  Log-transformed: %s (%.2fx improvement)\n', results.metric{best_log_idx}, results.log_snr_improvement(best_log_idx));
    
    % Distribution analysis
    fprintf('\nDistribution analysis:\n');
    fprintf('  Original data - Average skewness: %.3f, Average kurtosis: %.3f\n', mean(results.original_skewness), mean(results.original_kurtosis));
    fprintf('  Log-transformed - Average skewness: %.3f, Average kurtosis: %.3f\n', mean(results.log_skewness), mean(results.log_kurtosis));
    
    % Log-ratio recommendations
    log_ratio_recommended = sum(strcmp(results.log_recommendation, 'Relative'));
    fprintf('\nLog-ratio recommendations:\n');
    fprintf('  %d/%d KPIs recommend log-ratios R'' = log(X_A/X_B)\n', log_ratio_recommended, length(results.metric));
    
else
    fprintf('No KPIs to analyze.\n');
end

%% Step 5: Detailed Results Table
fprintf('\nSTEP 5: Detailed results table...\n');
fprintf('=================================\n');

if ~isempty(results.metric)
    fprintf('\nDetailed Results:\n');
    fprintf('================================================================================\n');
    fprintf('Metric\t\t\tOrig r\tLog r\tOrig SNR\tLog SNR\t\tOrig Rec\tLog Rec\t\tInterpretation\n');
    fprintf('------\t\t\t------\t-----\t--------\t-------\t\t--------\t-------\t\t-------------\n');
    
    for i = 1:length(results.metric)
        fprintf('%s\t\t%.3f\t%.3f\t%.2fx\t\t%.2fx\t\t%s\t\t%s\t\t%s\n', ...
                results.metric{i}, results.original_r(i), results.log_r(i), ...
                results.original_snr_improvement(i), results.log_snr_improvement(i), ...
                results.original_recommendation{i}, results.log_recommendation{i}, ...
                results.interpretation{i});
    end
end

%% Step 6: Interpretation and Recommendations
fprintf('\nSTEP 6: Interpretation and recommendations...\n');
fprintf('============================================\n');

fprintf('\nKey insights:\n');
fprintf('1. Log-transformation: R'' = log(X_A) - log(X_B) = log(X_A/X_B)\n');
fprintf('2. Log-ratios are often more interpretable than absolute differences\n');
fprintf('3. SNR improvement formula: SNR_R''/SNR_Y = 4/(1+r''²)\n');
fprintf('4. Decision rule: Use relative measures when r'' < √3 ≈ 1.732\n');

fprintf('\nMathematical interpretation:\n');
fprintf('- Original: R = X_A - X_B (absolute difference)\n');
fprintf('- Log-transformed: R'' = log(X_A/X_B) (log-ratio)\n');
fprintf('- Log-ratios are often more meaningful for performance comparison\n');

fprintf('\nRecommendations:\n');
if ~isempty(results.metric)
    if log_better > original_better
        fprintf('✓ Log-transformation generally improves SNR for these KPIs\n');
    elseif log_better < original_better
        fprintf('⚠ Log-transformation may not always improve SNR\n');
    else
        fprintf('≈ Log-transformation has mixed effects on SNR\n');
    end
    
    if log_relative > orig_relative
        fprintf('✓ Log-transformation increases relative measure recommendations\n');
    elseif log_relative < orig_relative
        fprintf('⚠ Log-transformation decreases relative measure recommendations\n');
    else
        fprintf('≈ Log-transformation has no effect on recommendations\n');
    end
    
    fprintf('\nSpecific recommendations:\n');
    for i = 1:length(results.metric)
        if strcmp(results.interpretation{i}, 'Log better')
            fprintf('  %s: Consider log-transformation (%.2fx vs %.2fx improvement)\n', ...
                    results.metric{i}, results.log_snr_improvement(i), results.original_snr_improvement(i));
        end
    end
else
    fprintf('⚠ No KPIs to analyze\n');
end

fprintf('\nNext steps:\n');
fprintf('1. Test log-transformation for non-normal KPIs\n');
fprintf('2. Validate log-ratios R'' = log(X_A/X_B) for interpretability\n');
fprintf('3. Include log-transformed KPIs in candidate KPI pool\n');
fprintf('4. Consider log-transformation in user pipeline\n');

%% Step 7: Create Visualization
fprintf('\nSTEP 7: Creating visualization...\n');
fprintf('===============================\n');

if ~isempty(results.metric)
    figure('Position', [100, 100, 1200, 800]);
    
    % Subplot 1: SNR improvements comparison
    subplot(2,2,1);
    bar([results.original_snr_improvement; results.log_snr_improvement]');
    xlabel('KPI');
    ylabel('SNR Improvement');
    title('SNR Improvements: Original vs Log-transformed');
    legend('Original', 'Log-transformed', 'Location', 'best');
    set(gca, 'XTickLabel', results.metric, 'XTickLabelRotation', 45);
    grid on;
    
    % Subplot 2: Variance ratios comparison
    subplot(2,2,2);
    bar([results.original_r; results.log_r]');
    xlabel('KPI');
    ylabel('Variance Ratio (r)');
    title('Variance Ratios: Original vs Log-transformed');
    legend('Original', 'Log-transformed', 'Location', 'best');
    set(gca, 'XTickLabel', results.metric, 'XTickLabelRotation', 45);
    yline(sqrt(3), 'r--', 'Break-even (√3)');
    grid on;
    
    % Subplot 3: Distribution analysis
    subplot(2,2,3);
    scatter(results.original_skewness, results.original_kurtosis, 100, 'b', 'filled', 'DisplayName', 'Original');
    hold on;
    scatter(results.log_skewness, results.log_kurtosis, 100, 'r', 'filled', 'DisplayName', 'Log-transformed');
    xlabel('Skewness');
    ylabel('Kurtosis');
    title('Distribution Analysis');
    legend('Location', 'best');
    grid on;
    
    % Subplot 4: Recommendation changes
    subplot(2,2,4);
    rec_changes = zeros(length(results.metric), 1);
    for i = 1:length(results.metric)
        if strcmp(results.original_recommendation{i}, 'Relative') && strcmp(results.log_recommendation{i}, 'Relative')
            rec_changes(i) = 0; % Both relative
        elseif strcmp(results.original_recommendation{i}, 'Absolute') && strcmp(results.log_recommendation{i}, 'Relative')
            rec_changes(i) = 1; % Changed to relative
        elseif strcmp(results.original_recommendation{i}, 'Relative') && strcmp(results.log_recommendation{i}, 'Absolute')
            rec_changes(i) = -1; % Changed to absolute
        else
            rec_changes(i) = 0; % Both absolute
        end
    end
    
    bar(rec_changes);
    xlabel('KPI');
    ylabel('Recommendation Change');
    title('Recommendation Changes');
    set(gca, 'XTickLabel', results.metric, 'XTickLabelRotation', 45);
    yline(0, 'k--');
    grid on;
    
    sgtitle('Comprehensive Log-Transformation Analysis');
    
    % Save figure
    output_dir = 'outputs/log_transformation_analysis';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    fig_file = fullfile(output_dir, 'log_transformation_analysis.png');
    saveas(gcf, fig_file);
    fprintf('✓ Visualization saved to: %s\n', fig_file);
end

fprintf('\n=== COMPREHENSIVE LOG-TRANSFORMATION ANALYSIS COMPLETE ===\n');
