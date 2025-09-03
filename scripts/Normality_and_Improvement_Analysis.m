%% ========================================================================
% NORMALITY AND IMPROVEMENT ANALYSIS
% ========================================================================
% 
% This script provides a comprehensive analysis of:
% 1. Normality testing for original and log-transformed KPIs
% 2. SNR improvements for both versions
% 3. Clear table showing KPI, Normality, Relative improvement, Log-transformed R' improvement
%
% Author: AI Assistant
% Date: 2024
% Purpose: Comprehensive normality and improvement analysis
%
% ========================================================================

clear; clc; close all;

fprintf('=== NORMALITY AND IMPROVEMENT ANALYSIS ===\n');
fprintf('Analyzing normality and SNR improvements for all KPIs...\n\n');

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

metric_cols = {'Carries', 'Metres_Made', 'Defenders_Beaten', 'Offloads', 'Passes', 'Tackles', 'Clean_Breaks', 'Turnovers_Won', 'Rucks_Won', 'Lineout_Throws_Won'};

fprintf('Analyzing %d KPIs: %s\n', length(metric_cols), strjoin(metric_cols, ', '));

%% Step 3: Comprehensive Analysis
fprintf('\nSTEP 3: Comprehensive analysis...\n');
fprintf('=================================\n');

% Initialize results structure
results = struct();
results.metric = {};
results.original_normality = {};
results.log_normality = {};
results.normality_improvement = {};
results.original_r = [];
results.log_r = [];
results.original_snr_improvement = [];
results.log_snr_improvement = [];
results.snr_improvement_change = [];
results.original_recommendation = {};
results.log_recommendation = {};
results.recommendation_change = {};

fprintf('Analyzing each KPI...\n');

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
    
    % Test normality for original data
    [h_orig, p_orig] = testNormality(team1_data);
    if h_orig == 0
        orig_normality = 'Normal';
    else
        orig_normality = 'Non-normal';
    end
    
    % Test normality for log-transformed data
    team1_data_log = log(team1_data + 1); % Add 1 to handle zeros
    team2_data_log = log(team2_data + 1); % Add 1 to handle zeros
    [h_log, p_log] = testNormality(team1_data_log);
    if h_log == 0
        log_normality = 'Normal';
    else
        log_normality = 'Non-normal';
    end
    
    % Determine normality improvement
    if strcmp(orig_normality, 'Non-normal') && strcmp(log_normality, 'Normal')
        normality_improvement = 'Improved';
    elseif strcmp(orig_normality, 'Normal') && strcmp(log_normality, 'Non-normal')
        normality_improvement = 'Worsened';
    elseif strcmp(orig_normality, log_normality)
        normality_improvement = 'No change';
    else
        normality_improvement = 'Mixed';
    end
    
    % Calculate SNR improvements
    sigma_A_orig = std(team1_data);
    sigma_B_orig = std(team2_data);
    r_orig = sigma_B_orig / sigma_A_orig;
    snr_improvement_orig = 4 / (1 + r_orig^2);
    
    sigma_A_log = std(team1_data_log);
    sigma_B_log = std(team2_data_log);
    r_log = sigma_B_log / sigma_A_log;
    snr_improvement_log = 4 / (1 + r_log^2);
    
    % Calculate SNR improvement change
    snr_change = snr_improvement_log - snr_improvement_orig;
    snr_change_percent = (snr_change / snr_improvement_orig) * 100;
    
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
    
    % Determine recommendation change
    if strcmp(rec_orig, rec_log)
        rec_change = 'No change';
    else
        rec_change = sprintf('%s → %s', rec_orig, rec_log);
    end
    
    % Store results
    results.metric{end+1} = metric;
    results.original_normality{end+1} = orig_normality;
    results.log_normality{end+1} = log_normality;
    results.normality_improvement{end+1} = normality_improvement;
    results.original_r(end+1) = r_orig;
    results.log_r(end+1) = r_log;
    results.original_snr_improvement(end+1) = snr_improvement_orig;
    results.log_snr_improvement(end+1) = snr_improvement_log;
    results.snr_improvement_change(end+1) = snr_change_percent;
    results.original_recommendation{end+1} = rec_orig;
    results.log_recommendation{end+1} = rec_log;
    results.recommendation_change{end+1} = rec_change;
    
    fprintf('  %s: %s → %s, SNR: %.2fx → %.2fx (%.1f%% change)\n', ...
            metric, orig_normality, log_normality, snr_improvement_orig, snr_improvement_log, snr_change_percent);
end

%% Step 4: Create Comprehensive Results Table
fprintf('\nSTEP 4: Comprehensive results table...\n');
fprintf('=====================================\n');

fprintf('\nCOMPREHENSIVE RESULTS TABLE:\n');
fprintf('==============================================================================================================\n');
fprintf('KPI\t\t\tOriginal\tLog\t\tNormality\tOriginal\tLog\t\tSNR Change\tRecommendation\n');
fprintf('\t\t\tNormality\tNormality\tImprovement\tSNR\t\tSNR\t\t(%%)\t\tChange\n');
fprintf('---\t\t\t----------\t----------\t------------\t--------\t-----\t\t--------\t------------\n');

for i = 1:length(results.metric)
    fprintf('%s\t\t%s\t\t%s\t\t%s\t\t%.2fx\t\t%.2fx\t\t%.1f%%\t\t%s\n', ...
            results.metric{i}, results.original_normality{i}, results.log_normality{i}, ...
            results.normality_improvement{i}, results.original_snr_improvement(i), ...
            results.log_snr_improvement(i), results.snr_improvement_change(i), ...
            results.recommendation_change{i});
end

%% Step 5: Summary Statistics
fprintf('\nSTEP 5: Summary statistics...\n');
fprintf('============================\n');

% Normality analysis
orig_normal = sum(strcmp(results.original_normality, 'Normal'));
log_normal = sum(strcmp(results.log_normality, 'Normal'));
normality_improved = sum(strcmp(results.normality_improvement, 'Improved'));
normality_worsened = sum(strcmp(results.normality_improvement, 'Worsened'));

fprintf('\nNormality Analysis:\n');
fprintf('  Original data: %d/%d KPIs are normal\n', orig_normal, length(results.metric));
fprintf('  Log-transformed: %d/%d KPIs are normal\n', log_normal, length(results.metric));
fprintf('  Normality improved: %d/%d KPIs\n', normality_improved, length(results.metric));
fprintf('  Normality worsened: %d/%d KPIs\n', normality_worsened, length(results.metric));

% SNR improvement analysis
snr_improved = sum(results.snr_improvement_change > 5); % 5% improvement threshold
snr_worsened = sum(results.snr_improvement_change < -5); % 5% degradation threshold
snr_equivalent = length(results.metric) - snr_improved - snr_worsened;

fprintf('\nSNR Improvement Analysis:\n');
fprintf('  SNR improved (>5%%): %d/%d KPIs\n', snr_improved, length(results.metric));
fprintf('  SNR worsened (<-5%%): %d/%d KPIs\n', snr_worsened, length(results.metric));
fprintf('  SNR equivalent (±5%%): %d/%d KPIs\n', snr_equivalent, length(results.metric));

% Average improvements
avg_orig_snr = mean(results.original_snr_improvement);
avg_log_snr = mean(results.log_snr_improvement);
avg_snr_change = mean(results.snr_improvement_change);

fprintf('\nAverage SNR Improvements:\n');
fprintf('  Original: %.2fx\n', avg_orig_snr);
fprintf('  Log-transformed: %.2fx\n', avg_log_snr);
fprintf('  Average change: %.1f%%\n', avg_snr_change);

% Recommendation analysis
orig_relative = sum(strcmp(results.original_recommendation, 'Relative'));
log_relative = sum(strcmp(results.log_recommendation, 'Relative'));
rec_changed = sum(~strcmp(results.recommendation_change, 'No change'));

fprintf('\nRecommendation Analysis:\n');
fprintf('  Original: %d/%d KPIs recommend relative measures\n', orig_relative, length(results.metric));
fprintf('  Log-transformed: %d/%d KPIs recommend relative measures\n', log_relative, length(results.metric));
fprintf('  Recommendations changed: %d/%d KPIs\n', rec_changed, length(results.metric));

%% Step 6: Key Insights
fprintf('\nSTEP 6: Key insights...\n');
fprintf('======================\n');

fprintf('\nKey Findings:\n');

% Normality insights
if normality_improved > 0
    fprintf('✓ Log-transformation improved normality for %d KPIs\n', normality_improved);
else
    fprintf('⚠ Log-transformation did not improve normality for any KPIs\n');
end

% SNR insights
if snr_improved > snr_worsened
    fprintf('✓ Log-transformation generally improves SNR (%d improved vs %d worsened)\n', snr_improved, snr_worsened);
elseif snr_improved < snr_worsened
    fprintf('⚠ Log-transformation may worsen SNR (%d improved vs %d worsened)\n', snr_improved, snr_worsened);
else
    fprintf('≈ Log-transformation has mixed effects on SNR (%d improved vs %d worsened)\n', snr_improved, snr_worsened);
end

% Recommendation insights
if log_relative > orig_relative
    fprintf('✓ Log-transformation increases relative measure recommendations\n');
elseif log_relative < orig_relative
    fprintf('⚠ Log-transformation decreases relative measure recommendations\n');
else
    fprintf('≈ Log-transformation has no effect on recommendations\n');
end

% Best performers
[~, best_orig_idx] = max(results.original_snr_improvement);
[~, best_log_idx] = max(results.log_snr_improvement);
[~, best_improvement_idx] = max(results.snr_improvement_change);

fprintf('\nBest Performers:\n');
fprintf('  Best original SNR: %s (%.2fx)\n', results.metric{best_orig_idx}, results.original_snr_improvement(best_orig_idx));
fprintf('  Best log SNR: %s (%.2fx)\n', results.metric{best_log_idx}, results.log_snr_improvement(best_log_idx));
fprintf('  Best improvement: %s (%.1f%% change)\n', results.metric{best_improvement_idx}, results.snr_improvement_change(best_improvement_idx));

%% Step 7: Create Visualization
fprintf('\nSTEP 7: Creating visualization...\n');
fprintf('===============================\n');

if ~isempty(results.metric)
    figure('Position', [100, 100, 1400, 1000]);
    
    % Subplot 1: Normality comparison
    subplot(2,3,1);
    orig_norm_counts = [orig_normal, length(results.metric) - orig_normal];
    log_norm_counts = [log_normal, length(results.metric) - log_normal];
    bar([orig_norm_counts; log_norm_counts]');
    xlabel('Normality Status');
    ylabel('Number of KPIs');
    title('Normality Comparison');
    set(gca, 'XTickLabel', {'Normal', 'Non-normal'});
    legend('Original', 'Log-transformed', 'Location', 'best');
    grid on;
    
    % Subplot 2: SNR improvements comparison
    subplot(2,3,2);
    bar([results.original_snr_improvement; results.log_snr_improvement]');
    xlabel('KPI');
    ylabel('SNR Improvement');
    title('SNR Improvements: Original vs Log-transformed');
    legend('Original', 'Log-transformed', 'Location', 'best');
    set(gca, 'XTickLabel', results.metric, 'XTickLabelRotation', 45);
    grid on;
    
    % Subplot 3: SNR improvement changes
    subplot(2,3,3);
    bar(results.snr_improvement_change);
    xlabel('KPI');
    ylabel('SNR Improvement Change (%)');
    title('SNR Improvement Changes');
    set(gca, 'XTickLabel', results.metric, 'XTickLabelRotation', 45);
    yline(0, 'k--');
    grid on;
    
    % Subplot 4: Normality improvement
    subplot(2,3,4);
    norm_improvement_counts = [sum(strcmp(results.normality_improvement, 'Improved')), ...
                              sum(strcmp(results.normality_improvement, 'Worsened')), ...
                              sum(strcmp(results.normality_improvement, 'No change'))];
    bar(norm_improvement_counts);
    xlabel('Normality Change');
    ylabel('Number of KPIs');
    title('Normality Improvement');
    set(gca, 'XTickLabel', {'Improved', 'Worsened', 'No change'});
    grid on;
    
    % Subplot 5: Recommendation changes
    subplot(2,3,5);
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
    
    % Subplot 6: Summary
    subplot(2,3,6);
    text(0.1, 0.8, sprintf('Normality: %d→%d normal', orig_normal, log_normal), 'FontSize', 12);
    text(0.1, 0.6, sprintf('SNR: %.2fx→%.2fx avg', avg_orig_snr, avg_log_snr), 'FontSize', 12);
    text(0.1, 0.4, sprintf('Relative: %d→%d KPIs', orig_relative, log_relative), 'FontSize', 12);
    text(0.1, 0.2, sprintf('Best improvement: %.1f%%', max(results.snr_improvement_change)), 'FontSize', 12);
    axis off;
    title('Summary');
    
    sgtitle('Normality and Improvement Analysis');
    
    % Save figure
    output_dir = 'outputs/normality_analysis';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    fig_file = fullfile(output_dir, 'normality_and_improvement_analysis.png');
    saveas(gcf, fig_file);
    fprintf('✓ Visualization saved to: %s\n', fig_file);
end

%% Helper Function
function [h, p] = testNormality(x)
    % Test normality using multiple methods
    try
        % Try Shapiro-Wilk test first
        [h, p] = swtest(x);
    catch
        % Fallback: use skewness and kurtosis
        n = length(x);
        if n < 3
            h = 1;
            p = 0.01;
            return;
        end
        
        % Remove outliers
        x_clean = x;
        x_clean(abs(x_clean - median(x_clean)) > 3*std(x_clean)) = [];
        
        if length(x_clean) < 3
            h = 1;
            p = 0.01;
            return;
        end
        
        % Test skewness and kurtosis
        skew = skewness(x_clean);
        kurt = kurtosis(x_clean);
        
        % Simple normality test based on skewness and kurtosis
        if abs(skew) > 1 || abs(kurt - 3) > 2
            h = 1;
            p = 0.01;
        else
            h = 0;
            p = 0.1;
        end
    end
end

fprintf('\n=== NORMALITY AND IMPROVEMENT ANALYSIS COMPLETE ===\n');
