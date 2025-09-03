%% ========================================================================
% TEST LOG-TRANSFORMED KPIs FOR SNR IMPROVEMENT
% ========================================================================
% 
% This script tests whether log-transformed KPIs that failed normality
% tests can achieve SNR improvements through relative measures.
%
% Key insight: R' = log(X_A) - log(X_B) = log(X_A/X_B) (log-ratio)
% This often provides more meaningful interpretation than absolute differences.
%
% Author: AI Assistant
% Date: 2024
% Purpose: Test log-transformed KPIs for SNR improvement
%
% ========================================================================

clear; clc; close all;

fprintf('=== TESTING LOG-TRANSFORMED KPIs FOR SNR IMPROVEMENT ===\n');
fprintf('Testing whether log-transformed KPIs can achieve SNR improvements\n');
fprintf('through relative measures (log-ratios)...\n\n');

%% Step 1: Load Data
fprintf('STEP 1: Loading data...\n');
fprintf('======================\n');

try
    % Load the formatted dataset
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    file_path = fullfile(project_root, 'data', 'raw', 'Example_Formatted_Dataset.csv');
    data = readtable(file_path);
    fprintf('✓ Dataset loaded: %d rows, %d columns\n', height(data), width(data));
catch ME
    error('Failed to load dataset: %s', ME.message);
end

%% Step 2: Identify Non-Normal KPIs
fprintf('\nSTEP 2: Identifying non-normal KPIs...\n');
fprintf('======================================\n');

% Define all metric columns
metric_cols = {'Carries', 'Metres_Made', 'Defenders_Beaten', 'Offloads', 'Passes', 'Tackles', 'Clean_Breaks', 'Turnovers_Won', 'Rucks_Won', 'Lineout_Throws_Won'};

% Test normality for each metric
normality_results = struct();
normality_results.metric = {};
normality_results.original_p_value = [];
normality_results.original_normal = [];
normality_results.log_p_value = [];
normality_results.log_normal = [];
normality_results.improvement = {};

fprintf('Testing normality for each metric:\n');
fprintf('Metric\t\t\tOriginal p-value\tLog p-value\t\tImprovement\n');
fprintf('------\t\t\t---------------\t---------\t\t-----------\n');

for i = 1:length(metric_cols)
    metric = metric_cols{i};
    
    % Get data for this metric
    metric_data = data.(metric);
    
    % Test original data normality
    [~, p_original] = swtest(metric_data);
    
    % Test log-transformed data normality
    log_data = log(metric_data + 1); % Add 1 to handle zeros
    [~, p_log] = swtest(log_data);
    
    % Determine improvement
    if p_original < 0.05 && p_log >= 0.05
        improvement = 'Yes';
    elseif p_original < 0.05 && p_log < 0.05
        improvement = 'Partial';
    else
        improvement = 'No';
    end
    
    % Store results
    normality_results.metric{end+1} = metric;
    normality_results.original_p_value(end+1) = p_original;
    normality_results.original_normal(end+1) = p_original >= 0.05;
    normality_results.log_p_value(end+1) = p_log;
    normality_results.log_normal(end+1) = p_log >= 0.05;
    normality_results.improvement{end+1} = improvement;
    
    fprintf('%s\t\t%.4f\t\t\t%.4f\t\t\t%s\n', metric, p_original, p_log, improvement);
end

%% Step 3: Analyze Log-Transformed KPIs
fprintf('\nSTEP 3: Analyzing log-transformed KPIs...\n');
fprintf('=========================================\n');

% Focus on KPIs that improved with log transformation
improved_kpis = {};
for i = 1:length(normality_results.metric)
    if strcmp(normality_results.improvement{i}, 'Yes') || strcmp(normality_results.improvement{i}, 'Partial')
        improved_kpis{end+1} = normality_results.metric{i};
    end
end

fprintf('KPIs that improved with log transformation: %s\n', strjoin(improved_kpis, ', '));

if isempty(improved_kpis)
    fprintf('No KPIs improved with log transformation. Exiting.\n');
    return;
end

%% Step 4: Calculate SNR Improvements for Log-Transformed KPIs
fprintf('\nSTEP 4: Calculating SNR improvements for log-transformed KPIs...\n');
fprintf('================================================================\n');

log_results = struct();
log_results.metric = {};
log_results.sigma_A_original = [];
log_results.sigma_B_original = [];
log_results.sigma_A_log = [];
log_results.sigma_B_log = [];
log_results.r_original = [];
log_results.r_log = [];
log_results.snr_improvement_original = [];
log_results.snr_improvement_log = [];
log_results.recommendation_original = {};
log_results.recommendation_log = {};
log_results.interpretation = {};

fprintf('Log-transformed KPI Analysis:\n');
fprintf('Metric\t\t\tOriginal r\tLog r\t\tOriginal SNR\tLog SNR\t\tRecommendation\n');
fprintf('------\t\t\t----------\t-----\t\t------------\t-------\t\t-------------\n');

for i = 1:length(improved_kpis)
    metric = improved_kpis{i};
    
    % Get unique teams
    unique_teams = unique(data.Team);
    if length(unique_teams) < 2
        continue;
    end
    
    % Calculate team-specific statistics for original data
    team1_data_orig = data(strcmp(data.Team, unique_teams{1}), metric);
    team2_data_orig = data(strcmp(data.Team, unique_teams{2}), metric);
    
    team1_data_orig = team1_data_orig.(metric);
    team2_data_orig = team2_data_orig.(metric);
    team1_data_orig = team1_data_orig(~isnan(team1_data_orig));
    team2_data_orig = team2_data_orig(~isnan(team2_data_orig));
    
    % Calculate team-specific statistics for log-transformed data
    team1_data_log = log(team1_data_orig + 1);
    team2_data_log = log(team2_data_orig + 1);
    
    if length(team1_data_orig) < 3 || length(team2_data_orig) < 3
        continue;
    end
    
    % Calculate standard deviations
    sigma_A_orig = std(team1_data_orig);
    sigma_B_orig = std(team2_data_orig);
    sigma_A_log = std(team1_data_log);
    sigma_B_log = std(team2_data_log);
    
    % Calculate variance ratios
    r_orig = sigma_B_orig / sigma_A_orig;
    r_log = sigma_B_log / sigma_A_log;
    
    % Calculate SNR improvements
    snr_improvement_orig = 4 / (1 + r_orig^2);
    snr_improvement_log = 4 / (1 + r_log^2);
    
    % Determine recommendations
    if r_orig < sqrt(3)
        rec_orig = 'Use relative';
    else
        rec_orig = 'Use absolute';
    end
    
    if r_log < sqrt(3)
        rec_log = 'Use relative';
    else
        rec_log = 'Use absolute';
    end
    
    % Determine interpretation
    if snr_improvement_log > snr_improvement_orig
        interpretation = 'Log better';
    elseif snr_improvement_log < snr_improvement_orig
        interpretation = 'Original better';
    else
        interpretation = 'Equivalent';
    end
    
    % Store results
    log_results.metric{end+1} = metric;
    log_results.sigma_A_original(end+1) = sigma_A_orig;
    log_results.sigma_B_original(end+1) = sigma_B_orig;
    log_results.sigma_A_log(end+1) = sigma_A_log;
    log_results.sigma_B_log(end+1) = sigma_B_log;
    log_results.r_original(end+1) = r_orig;
    log_results.r_log(end+1) = r_log;
    log_results.snr_improvement_original(end+1) = snr_improvement_orig;
    log_results.snr_improvement_log(end+1) = snr_improvement_log;
    log_results.recommendation_original{end+1} = rec_orig;
    log_results.recommendation_log{end+1} = rec_log;
    log_results.interpretation{end+1} = interpretation;
    
    fprintf('%s\t\t%.3f\t\t%.3f\t\t%.2fx\t\t%.2fx\t\t%s\n', metric, r_orig, r_log, snr_improvement_orig, snr_improvement_log, interpretation);
end

%% Step 5: Summary Analysis
fprintf('\nSTEP 5: Summary analysis...\n');
fprintf('==========================\n');

if ~isempty(log_results.metric)
    fprintf('\nLog-transformation benefits:\n');
    log_better = sum(strcmp(log_results.interpretation, 'Log better'));
    original_better = sum(strcmp(log_results.interpretation, 'Original better'));
    equivalent = sum(strcmp(log_results.interpretation, 'Equivalent'));
    
    fprintf('  Log-transformed better: %d/%d KPIs\n', log_better, length(log_results.metric));
    fprintf('  Original better: %d/%d KPIs\n', original_better, length(log_results.metric));
    fprintf('  Equivalent: %d/%d KPIs\n', equivalent, length(log_results.metric));
    
    fprintf('\nAverage SNR improvements:\n');
    fprintf('  Original: %.2fx\n', mean(log_results.snr_improvement_original));
    fprintf('  Log-transformed: %.2fx\n', mean(log_results.snr_improvement_log));
    
    fprintf('\nLog-transformed KPIs with relative measures recommended:\n');
    log_relative = sum(strcmp(log_results.recommendation_log, 'Use relative'));
    fprintf('  %d/%d KPIs recommend relative measures\n', log_relative, length(log_results.metric));
    
    % Find best log-transformed KPIs
    [~, best_idx] = max(log_results.snr_improvement_log);
    fprintf('\nBest log-transformed KPI: %s (%.2fx improvement)\n', log_results.metric{best_idx}, log_results.snr_improvement_log(best_idx));
    
else
    fprintf('No log-transformed KPIs to analyze.\n');
end

%% Step 6: Interpretation and Recommendations
fprintf('\nSTEP 6: Interpretation and recommendations...\n');
fprintf('============================================\n');

fprintf('\nKey insights:\n');
fprintf('1. Log-transformation: R'' = log(X_A) - log(X_B) = log(X_A/X_B)\n');
fprintf('2. This gives log-ratios, often more interpretable than absolute differences\n');
fprintf('3. SNR improvement formula: SNR_R''/SNR_Y = 4/(1+r''²)\n');
fprintf('4. Decision rule: Use relative measures when r'' < √3 ≈ 1.732\n');

fprintf('\nRecommendations:\n');
if ~isempty(log_results.metric)
    if log_better > original_better
        fprintf('✓ Log-transformation generally improves SNR for these KPIs\n');
    else
        fprintf('⚠ Log-transformation may not always improve SNR\n');
    end
    
    if log_relative > length(log_results.metric)/2
        fprintf('✓ Most log-transformed KPIs recommend relative measures\n');
    else
        fprintf('⚠ Many log-transformed KPIs may still favor absolute measures\n');
    end
else
    fprintf('⚠ No KPIs improved with log-transformation\n');
end

fprintf('\nNext steps:\n');
fprintf('1. Consider log-transformation for non-normal KPIs\n');
fprintf('2. Test log-ratios R'' = log(X_A/X_B) for interpretability\n');
fprintf('3. Validate SNR improvements with empirical data\n');
fprintf('4. Include log-transformed KPIs in candidate KPI pool\n');

%% Helper Function
function [h, p] = swtest(x)
    % Simplified Shapiro-Wilk test
    % Returns h=1 if reject normality, h=0 if accept
    % p is the p-value
    
    try
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

fprintf('\n=== LOG-TRANSFORMED KPI ANALYSIS COMPLETE ===\n');
