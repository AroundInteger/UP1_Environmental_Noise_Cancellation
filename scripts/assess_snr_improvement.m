%% SNR Improvement Assessment for Top-Performing KPIs
% Calculates actual SNR improvement for KPIs with highest axiom compliance
% Validates the theoretical Environmental Noise Cancellation framework

clear; close all; clc;

fprintf('=== SNR IMPROVEMENT ASSESSMENT FOR TOP KPIs ===\n');
fprintf('Empirical validation of theoretical framework\n\n');

%% 1. Load Data and Results
fprintf('1. Loading data and previous results...\n');

% Add paths
addpath(genpath('src'));

% Set up working directory
script_dir = fileparts(mfilename('fullpath'));
project_root = fullfile(script_dir, '..');
cd(project_root);
fprintf('✓ Working directory: %s\n', pwd);

% Load rugby data
data_file = 'data/processed/rugby_analysis_ready.csv';
if exist(data_file, 'file')
    data = readtable(data_file);
    fprintf('✓ Loaded rugby data: %dx%d\n', size(data, 1), size(data, 2));
else
    error('Data file not found: %s', data_file);
end

% Define top-performing KPIs based on axiom validation results
top_kpis = {'metres_made', 'kicks_from_hand', 'clean_breaks', 'scrum_pens_conceded', 'scrums_won'};
fprintf('✓ Top KPIs selected: %s\n', strjoin(top_kpis, ', '));

%% 2. Calculate SNR Improvement for Each Top KPI
fprintf('\n2. Calculating SNR improvement for top KPIs...\n');

snr_results = struct();

for k = 1:length(top_kpis)
    kpi = top_kpis{k};
    fprintf('\n--- Assessing KPI: %s ---\n', kpi);
    
    % Extract absolute and relative KPI data
    abs_col = ['abs_' kpi];
    rel_col = ['rel_' kpi];
    
    if ~ismember(abs_col, data.Properties.VariableNames) || ~ismember(rel_col, data.Properties.VariableNames)
        fprintf('  ❌ KPI columns not found, skipping\n');
        continue;
    end
    
    % Get KPI data
    X_abs = data.(abs_col);
    X_rel = data.(rel_col);
    outcomes = data.outcome_binary;
    
    % Remove any NaN values
    valid_idx = ~isnan(X_abs) & ~isnan(X_rel) & ~isnan(outcomes);
    X_abs = X_abs(valid_idx);
    X_rel = X_rel(valid_idx);
    outcomes = outcomes(valid_idx);
    
    fprintf('  Data points: %d\n', length(X_abs));
    
    %% 2.1 Calculate Absolute KPI Performance (Baseline)
    fprintf('  Calculating absolute KPI performance...\n');
    
    % Train logistic regression on absolute KPI
    try
        [B_abs, ~, stats_abs] = glmfit(X_abs, outcomes, 'binomial');
        
        % Calculate predictions and AUC for absolute KPI
        pred_abs = glmval(B_abs, X_abs, 'logit');
        [~, ~, ~, auc_abs] = perfcurve(outcomes, pred_abs, 1);
        
        fprintf('    Absolute KPI AUC: %.3f\n', auc_abs);
        
        % Calculate variance components for absolute KPI
        var_abs = var(X_abs);
        fprintf('    Absolute KPI variance: %.3f\n', var_abs);
        
    catch ME
        fprintf('    ❌ Error in absolute KPI analysis: %s\n', ME.message);
        continue;
    end
    
    %% 2.2 Calculate Relative KPI Performance
    fprintf('  Calculating relative KPI performance...\n');
    
    try
        % Train logistic regression on relative KPI
        [B_rel, ~, stats_rel] = glmfit(X_rel, outcomes, 'binomial');
        
        % Calculate predictions and AUC for relative KPI
        pred_rel = glmval(B_rel, X_rel, 'logit');
        [~, ~, ~, auc_rel] = perfcurve(outcomes, pred_rel, 1);
        
        fprintf('    Relative KPI AUC: %.3f\n', auc_rel);
        
        % Calculate variance components for relative KPI
        var_rel = var(X_rel);
        fprintf('    Relative KPI variance: %.3f\n', var_rel);
        
    catch ME
        fprintf('    ❌ Error in relative KPI analysis: %s\n', ME.message);
        continue;
    end
    
    %% 2.3 Calculate Empirical SNR Improvement
    fprintf('  Calculating empirical SNR improvement...\n');
    
    % Empirical SNR improvement (AUC-based)
    empirical_snr_improvement = (auc_rel - auc_abs) / auc_abs * 100;
    fprintf('    Empirical SNR improvement: %.1f%%\n', empirical_snr_improvement);
    
    %% 2.4 Calculate Theoretical SNR Improvement
    fprintf('  Calculating theoretical SNR improvement...\n');
    
    % Estimate environmental variance from relative measure
    % The relative measure should have lower variance due to environmental noise cancellation
    env_variance_estimate = max(0, var_abs - var_rel);
    
    % Theoretical SNR improvement formula
    if var_rel > 0
        theoretical_snr_improvement = (env_variance_estimate / var_rel) * 100;
    else
        theoretical_snr_improvement = 0;
    end
    
    fprintf('    Theoretical SNR improvement: %.1f%%\n', theoretical_snr_improvement);
    
    %% 2.5 Store Results
    snr_results.(kpi) = struct(...
        'absolute_auc', auc_abs, ...
        'relative_auc', auc_rel, ...
        'absolute_variance', var_abs, ...
        'relative_variance', var_rel, ...
        'empirical_improvement', empirical_snr_improvement, ...
        'theoretical_improvement', theoretical_snr_improvement, ...
        'data_points', length(X_abs));
    
    fprintf('  ✓ KPI assessment complete\n');
end

%% 3. Generate SNR Improvement Summary
fprintf('\n3. Generating SNR improvement summary...\n');

fprintf('\n=== SNR IMPROVEMENT SUMMARY ===\n');
fprintf('%-20s | Abs AUC | Rel AUC | Emp Imp%% | Theo Imp%% | Data Pts\n', 'KPI');
fprintf('%s\n', repmat('-', 1, 80));

kpi_names = fieldnames(snr_results);
for i = 1:length(kpi_names)
    kpi = kpi_names{i};
    result = snr_results.(kpi);
    
    fprintf('%-20s | %.3f   | %.3f   | %+6.1f%%  | %+6.1f%%  | %d\n', ...
        kpi, ...
        result.absolute_auc, ...
        result.relative_auc, ...
        result.empirical_improvement, ...
        result.theoretical_improvement, ...
        result.data_points);
end

%% 4. Statistical Analysis
fprintf('\n4. Statistical analysis of SNR improvements...\n');

% Extract improvement values
empirical_improvements = zeros(length(kpi_names), 1);
theoretical_improvements = zeros(length(kpi_names), 1);

for i = 1:length(kpi_names)
    kpi = kpi_names{i};
    result = snr_results.(kpi);
    empirical_improvements(i) = result.empirical_improvement;
    theoretical_improvements(i) = result.theoretical_improvement;
end

% Calculate statistics
mean_empirical = mean(empirical_improvements);
mean_theoretical = mean(theoretical_improvements);
std_empirical = std(empirical_improvements);
std_theoretical = std(theoretical_improvements);

fprintf('\n=== STATISTICAL SUMMARY ===\n');
fprintf('Empirical SNR Improvement:\n');
fprintf('  Mean: %.1f%% ± %.1f%%\n', mean_empirical, std_empirical);
fprintf('  Range: [%.1f%%, %.1f%%]\n', min(empirical_improvements), max(empirical_improvements));

fprintf('\nTheoretical SNR Improvement:\n');
fprintf('  Mean: %.1f%% ± %.1f%%\n', mean_theoretical, std_theoretical);
fprintf('  Range: [%.1f%%, %.1f%%]\n', min(theoretical_improvements), max(theoretical_improvements));

% Correlation between empirical and theoretical
correlation = corr(empirical_improvements, theoretical_improvements);
fprintf('\nCorrelation (Empirical vs Theoretical): %.3f\n', correlation);

%% 5. Create Visualizations
fprintf('\n5. Creating visualizations...\n');

% Figure 1: SNR Improvement Comparison
figure('Position', [100, 100, 1200, 800]);

subplot(2, 2, 1);
bar([empirical_improvements, theoretical_improvements]);
set(gca, 'XTickLabel', kpi_names, 'XTickLabelRotation', 45);
ylabel('SNR Improvement (%)');
title('SNR Improvement: Empirical vs Theoretical');
legend({'Empirical', 'Theoretical'}, 'Location', 'northeast');
grid on;

% Figure 2: AUC Comparison
subplot(2, 2, 2);
abs_aucs = zeros(length(kpi_names), 1);
rel_aucs = zeros(length(kpi_names), 1);

for i = 1:length(kpi_names)
    kpi = kpi_names{i};
    result = snr_results.(kpi);
    abs_aucs(i) = result.absolute_auc;
    rel_aucs(i) = result.relative_auc;
end

bar([abs_aucs, rel_aucs]);
set(gca, 'XTickLabel', kpi_names, 'XTickLabelRotation', 45);
ylabel('AUC');
title('Performance: Absolute vs Relative KPIs');
legend({'Absolute', 'Relative'}, 'Location', 'southeast');
grid on;

% Figure 3: Variance Comparison
subplot(2, 2, 3);
abs_vars = zeros(length(kpi_names), 1);
rel_vars = zeros(length(kpi_names), 1);

for i = 1:length(kpi_names)
    kpi = kpi_names{i};
    result = snr_results.(kpi);
    abs_vars(i) = result.absolute_variance;
    rel_vars(i) = result.relative_variance;
end

bar([abs_vars, rel_vars]);
set(gca, 'XTickLabel', kpi_names, 'XTickLabelRotation', 45);
ylabel('Variance');
title('Variance: Absolute vs Relative KPIs');
legend({'Absolute', 'Relative'}, 'Location', 'northeast');
grid on;

% Figure 4: Correlation Plot
subplot(2, 2, 4);
scatter(theoretical_improvements, empirical_improvements, 100, 'filled');
xlabel('Theoretical SNR Improvement (%)');
ylabel('Empirical SNR Improvement (%)');
title('Empirical vs Theoretical SNR Improvement');
grid on;

% Add correlation line
hold on;
p = polyfit(theoretical_improvements, empirical_improvements, 1);
x_range = [min(theoretical_improvements), max(theoretical_improvements)];
y_range = polyval(p, x_range);
plot(x_range, y_range, 'r--', 'LineWidth', 2);

% Add correlation text
text(0.1, 0.9, sprintf('r = %.3f', correlation), 'Units', 'normalized', ...
     'FontSize', 12, 'FontWeight', 'bold');

sgtitle('SNR Improvement Assessment for Top-Performing KPIs', 'FontSize', 16, 'FontWeight', 'bold');

%% 6. Save Results
fprintf('\n6. Saving results...\n');

% Save SNR results
save('snr_improvement_results.mat', 'snr_results', 'kpi_names', ...
     'empirical_improvements', 'theoretical_improvements', 'correlation');

% Generate summary report
fprintf('\n=== SUMMARY REPORT ===\n');
fprintf('SNR improvement assessment completed for %d top-performing KPIs\n', length(kpi_names));
fprintf('Results saved to: snr_improvement_results.mat\n');
fprintf('Mean empirical improvement: %.1f%%\n', mean_empirical);
fprintf('Mean theoretical improvement: %.1f%%\n', mean_theoretical);
fprintf('Correlation: %.3f\n', correlation);

if correlation > 0.7
    fprintf('✓ Strong correlation between empirical and theoretical improvements\n');
elseif correlation > 0.5
    fprintf('~ Moderate correlation between empirical and theoretical improvements\n');
else
    fprintf('⚠ Weak correlation between empirical and theoretical improvements\n');
end

fprintf('\n=== ASSESSMENT COMPLETE ===\n');
fprintf('SNR improvement validation ready for UP1 paper\n');
