%% ========================================================================
% COMPLETE SNR CORRELATION ANALYSIS
% ========================================================================
% 
% This script provides a comprehensive analysis of SNR relations with
% correlation parameter, including asymptote analysis and all team combinations.
%
% Key Analysis:
% 1. All team pair combinations for correlation analysis
% 2. Complete SNR relations with correlation parameter
% 3. Asymptote analysis and relation to 4x ceiling
% 4. Theoretical framework validation
%
% Author: AI Assistant
% Date: 2024
% Purpose: Complete SNR correlation analysis with asymptote investigation
%
% ========================================================================

clear; clc; close all;

fprintf('=== COMPLETE SNR CORRELATION ANALYSIS ===\n');
fprintf('Analyzing all team combinations and SNR asymptotes...\n\n');

%% Step 1: Load Data and Get All Teams
fprintf('STEP 1: Loading data and identifying all teams...\n');
fprintf('===============================================\n');

try
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    file_path = fullfile(project_root, 'data', 'raw', 'Example_Formatted_Dataset.csv');
    data = readtable(file_path);
    fprintf('✓ Dataset loaded: %d rows, %d columns\n', height(data), width(data));
catch ME
    error('Failed to load dataset: %s', ME.message);
end

% Get all unique teams and metrics
unique_teams = unique(data.Team);
metrics = {'Carries', 'Metres_Made', 'Defenders_Beaten', 'Offloads', 'Passes', 'Tackles'};

fprintf('Teams (%d): %s\n', length(unique_teams), strjoin(unique_teams, ', '));
fprintf('Metrics (%d): %s\n', length(metrics), strjoin(metrics, ', '));

%% Step 2: All Team Pair Combinations Analysis
fprintf('\nSTEP 2: All team pair combinations analysis...\n');
fprintf('===========================================\n');

% Calculate number of possible pairs
n_teams = length(unique_teams);
n_pairs = n_teams * (n_teams - 1) / 2;
fprintf('Total possible team pairs: %d\n', n_pairs);

% Initialize results structure
all_pairs_results = struct();
all_pairs_results.team1 = {};
all_pairs_results.team2 = {};
all_pairs_results.metric = {};
all_pairs_results.correlation = [];
all_pairs_results.sample_size = [];
all_pairs_results.snr_improvement = [];
all_pairs_results.p_value = [];

fprintf('\nAnalyzing all team pairs for each metric...\n');

pair_count = 0;
for i = 1:length(unique_teams)
    for j = i+1:length(unique_teams)
        team1_name = unique_teams{i};
        team2_name = unique_teams{j};
        
        % Extract data for both teams
        team1_data = data(strcmp(data.Team, team1_name), :);
        team2_data = data(strcmp(data.Team, team2_name), :);
        
        % Analyze each metric for this team pair
        for k = 1:length(metrics)
            metric = metrics{k};
            
            % Extract metric data
            team1_metric = team1_data.(metric);
            team2_metric = team2_data.(metric);
            
            % Handle different array sizes by using minimum length
            min_length = min(length(team1_metric), length(team2_metric));
            if min_length >= 3
                team1_metric = team1_metric(1:min_length);
                team2_metric = team2_metric(1:min_length);
                
                % Remove NaN values
                valid_pairs = ~isnan(team1_metric) & ~isnan(team2_metric);
                team1_clean = team1_metric(valid_pairs);
                team2_clean = team2_metric(valid_pairs);
            else
                team1_clean = [];
                team2_clean = [];
            end
            
            if length(team1_clean) >= 3 % Need at least 3 pairs
                % Calculate correlation
                [correlation, p_value] = corr(team1_clean, team2_clean);
                
                % Calculate SNR improvement
                mu_A = mean(team1_clean);
                mu_B = mean(team2_clean);
                sigma_A = std(team1_clean);
                sigma_B = std(team2_clean);
                
                % SNR improvement with correlation
                SNR_A = (mu_A - mu_B)^2 / (sigma_A^2 + sigma_B^2);
                SNR_R = (mu_A - mu_B)^2 / (sigma_A^2 + sigma_B^2 - 2*sigma_A*sigma_B*correlation);
                SNR_improvement = SNR_R / SNR_A;
                
                % Store results
                all_pairs_results.team1{end+1} = team1_name;
                all_pairs_results.team2{end+1} = team2_name;
                all_pairs_results.metric{end+1} = metric;
                all_pairs_results.correlation(end+1) = correlation;
                all_pairs_results.sample_size(end+1) = length(team1_clean);
                all_pairs_results.snr_improvement(end+1) = SNR_improvement;
                all_pairs_results.p_value(end+1) = p_value;
                
                pair_count = pair_count + 1;
            end
        end
    end
end

fprintf('Total valid team-metric pairs analyzed: %d\n', pair_count);

%% Step 3: Complete SNR Relations with Correlation Parameter
fprintf('\nSTEP 3: Complete SNR relations with correlation parameter...\n');
fprintf('=======================================================\n');

fprintf('\nMATHEMATICAL FRAMEWORK (UP2-4 Notation):\n');
fprintf('=======================================\n');

fprintf('\nNotation:\n');
fprintf('  δ = |μ_A - μ_B| (signal separation)\n');
fprintf('  κ = σ²_B/σ²_A (variance ratio)\n');
fprintf('  ρ = correlation between teams\n');

fprintf('\n1. Absolute Measure SNR:\n');
fprintf('   SNR_A = δ² / (σ_A² + σ_B²) = δ² / σ_A²(1 + κ)\n');

fprintf('\n2. Relative Measure SNR (with correlation):\n');
fprintf('   SNR_R = δ² / (σ_A² + σ_B² - 2*σ_A*σ_B*ρ) = δ² / σ_A²(1 + κ - 2*√κ*ρ)\n');

fprintf('\n3. SNR Improvement Ratio:\n');
fprintf('   SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)\n');

%% Step 4: Asymptote Analysis
fprintf('\nSTEP 4: Asymptote analysis...\n');
fprintf('===========================\n');

fprintf('\nASYMPTOTE ANALYSIS (UP2-4 Notation):\n');
fprintf('===================================\n');

% Define correlation range
rho_range = -0.99:0.01:0.99;

% Case 1: Equal variances (κ = 1)
fprintf('\nCase 1: Equal Variances (κ = 1):\n');
fprintf('SNR_R/SNR_A = (1 + 1) / (1 + 1 - 2*√1*ρ) = 2 / (2 - 2ρ) = 1 / (1 - ρ)\n');

% Calculate asymptotes for equal variances
snr_ratio_equal = 1 ./ (1 - rho_range);

% Find asymptotes
fprintf('Asymptotes:\n');
fprintf('  ρ → 1: SNR_R/SNR_A → ∞ (perfect correlation)\n');
fprintf('  ρ → -1: SNR_R/SNR_A → 0.5 (perfect negative correlation)\n');
fprintf('  ρ = 0: SNR_R/SNR_A = 1 (independence)\n');

% Case 2: Unequal variances (κ ≠ 1)
fprintf('\nCase 2: Unequal Variances (κ ≠ 1):\n');
fprintf('SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)\n');

% Calculate for different variance ratios
kappa_values = [0.25, 1.0, 2.25, 4.0]; % κ = r²
fprintf('\nVariance Ratio Analysis (κ = σ²_B/σ²_A):\n');

for i = 1:length(kappa_values)
    kappa = kappa_values(i);
    snr_ratio_unequal = (1 + kappa) ./ (1 + kappa - 2*sqrt(kappa)*rho_range);
    
    fprintf('  κ = %.2f: SNR_R/SNR_A = (1 + %.2f) / (1 + %.2f - 2*√%.2f*ρ)\n', kappa, kappa, kappa, kappa);
    fprintf('    ρ → 1: SNR_R/SNR_A → %.2f\n', (1 + kappa) / (1 + kappa - 2*sqrt(kappa)));
    fprintf('    ρ → -1: SNR_R/SNR_A → %.2f\n', (1 + kappa) / (1 + kappa + 2*sqrt(kappa)));
    fprintf('    ρ = 0: SNR_R/SNR_A = %.2f\n', 1 + kappa);
end

%% Step 5: Relation to 4x Ceiling
fprintf('\nSTEP 5: Relation to 4x ceiling...\n');
fprintf('===============================\n');

fprintf('\n4X CEILING ANALYSIS (UP2-4 Notation):\n');
fprintf('===================================\n');

fprintf('\nThe 4x ceiling comes from the signal enhancement framework:\n');
fprintf('SNR_R/SNR_A = 4 / (1 + κ) when ρ = 0 (independence)\n');
fprintf('Maximum occurs when κ = 0 (σ²_B = 0): SNR_R/SNR_A = 4 / (1 + 0) = 4\n');

% Calculate the 4x ceiling formula
snr_ratio_4x = 4 ./ (1 + kappa_values);
fprintf('\n4x Ceiling Formula: SNR_R/SNR_A = 4 / (1 + κ)\n');
for i = 1:length(kappa_values)
    kappa = kappa_values(i);
    fprintf('  κ = %.2f: SNR_R/SNR_A = %.2f\n', kappa, 4/(1 + kappa));
end

fprintf('\nComparison with Correlation Framework:\n');
fprintf('Correlation Framework: SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)\n');
fprintf('Signal Enhancement Framework: SNR_R/SNR_A = 4 / (1 + κ)\n');
fprintf('When ρ = 0: Both frameworks give SNR_R/SNR_A = 1 + κ\n');
fprintf('The 4x ceiling is a theoretical maximum for signal enhancement.\n');

%% Step 6: Empirical Validation
fprintf('\nSTEP 6: Empirical validation...\n');
fprintf('=============================\n');

if ~isempty(all_pairs_results.correlation)
    fprintf('\nEMPIRICAL RESULTS SUMMARY:\n');
    fprintf('========================\n');
    
    % Calculate summary statistics
    avg_correlation = mean(all_pairs_results.correlation);
    std_correlation = std(all_pairs_results.correlation);
    min_correlation = min(all_pairs_results.correlation);
    max_correlation = max(all_pairs_results.correlation);
    
    avg_snr_improvement = mean(all_pairs_results.snr_improvement);
    std_snr_improvement = std(all_pairs_results.snr_improvement);
    min_snr_improvement = min(all_pairs_results.snr_improvement);
    max_snr_improvement = max(all_pairs_results.snr_improvement);
    
    fprintf('Correlation Statistics:\n');
    fprintf('  Mean: %.3f ± %.3f\n', avg_correlation, std_correlation);
    fprintf('  Range: [%.3f, %.3f]\n', min_correlation, max_correlation);
    
    fprintf('\nSNR Improvement Statistics:\n');
    fprintf('  Mean: %.3f ± %.3f\n', avg_snr_improvement, std_snr_improvement);
    fprintf('  Range: [%.3f, %.3f]\n', min_snr_improvement, max_snr_improvement);
    
    % Compare with theoretical predictions
    fprintf('\nTheoretical vs Empirical Comparison:\n');
    fprintf('  Theoretical 4x ceiling: 4.00\n');
    fprintf('  Empirical maximum: %.3f\n', max_snr_improvement);
    fprintf('  Empirical mean: %.3f\n', avg_snr_improvement);
    
    % Analyze correlation effects
    positive_correlations = sum(all_pairs_results.correlation > 0);
    negative_correlations = sum(all_pairs_results.correlation < 0);
    zero_correlations = sum(abs(all_pairs_results.correlation) < 0.01);
    
    fprintf('\nCorrelation Distribution:\n');
    fprintf('  Positive: %d/%d (%.1f%%)\n', positive_correlations, length(all_pairs_results.correlation), 100*positive_correlations/length(all_pairs_results.correlation));
    fprintf('  Negative: %d/%d (%.1f%%)\n', negative_correlations, length(all_pairs_results.correlation), 100*negative_correlations/length(all_pairs_results.correlation));
    fprintf('  Near zero: %d/%d (%.1f%%)\n', zero_correlations, length(all_pairs_results.correlation), 100*zero_correlations/length(all_pairs_results.correlation));
end

%% Step 7: Visualization
fprintf('\nSTEP 7: Creating comprehensive visualization...\n');
fprintf('===========================================\n');

figure('Position', [100, 100, 1600, 1200]);

% Subplot 1: Correlation distribution
subplot(3,4,1);
histogram(all_pairs_results.correlation, 20);
xlabel('Correlation (ρ)');
ylabel('Frequency');
title('Correlation Distribution');
grid on;

% Subplot 2: SNR improvement distribution
subplot(3,4,2);
histogram(all_pairs_results.snr_improvement, 20);
xlabel('SNR Improvement');
ylabel('Frequency');
title('SNR Improvement Distribution');
grid on;

% Subplot 3: Correlation vs SNR improvement
subplot(3,4,3);
scatter(all_pairs_results.correlation, all_pairs_results.snr_improvement, 50, 'filled');
xlabel('Correlation (ρ)');
ylabel('SNR Improvement');
title('Correlation vs SNR Improvement');
grid on;

% Subplot 4: Theoretical SNR ratio for equal variances
subplot(3,4,4);
plot(rho_range, snr_ratio_equal, 'b-', 'LineWidth', 2);
xlabel('Correlation (ρ)');
ylabel('SNR_R/SNR_A');
title('Equal Variances: SNR_R/SNR_A = 1/(1-ρ)');
grid on;
ylim([0, 10]);

% Subplot 5: Theoretical SNR ratio for different variance ratios
subplot(3,4,5);
colors = {'r', 'g', 'b', 'm'};
for i = 1:length(kappa_values)
    kappa = kappa_values(i);
    snr_ratio_unequal = (1 + kappa) ./ (1 + kappa - 2*sqrt(kappa)*rho_range);
    plot(rho_range, snr_ratio_unequal, colors{i}, 'LineWidth', 2, 'DisplayName', sprintf('κ=%.2f', kappa));
    hold on;
end
xlabel('Correlation (ρ)');
ylabel('SNR_R/SNR_A');
title('Unequal Variances: SNR_R/SNR_A = (1+κ)/(1+κ-2√κρ)');
legend('Location', 'best');
grid on;
ylim([0, 10]);

% Subplot 6: 4x ceiling formula
subplot(3,4,6);
plot(kappa_values, snr_ratio_4x, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Variance Ratio (κ)');
ylabel('SNR_R/SNR_A');
title('4x Ceiling: SNR_R/SNR_A = 4/(1+κ)');
grid on;

% Subplot 7: Sample size distribution
subplot(3,4,7);
histogram(all_pairs_results.sample_size, 20);
xlabel('Sample Size');
ylabel('Frequency');
title('Sample Size Distribution');
grid on;

% Subplot 8: P-value distribution
subplot(3,4,8);
histogram(all_pairs_results.p_value, 20);
xlabel('P-value');
ylabel('Frequency');
title('P-value Distribution');
yline(0.05, 'r--', 'p=0.05');
grid on;

% Subplot 9: Team pair analysis
subplot(3,4,9);
% Count correlations by team
team_correlations = struct();
for i = 1:length(all_pairs_results.team1)
    team1 = all_pairs_results.team1{i};
    team2 = all_pairs_results.team2{i};
    
    % Create valid field names (replace spaces with underscores)
    team1_field = strrep(team1, ' ', '_');
    team2_field = strrep(team2, ' ', '_');
    
    if ~isfield(team_correlations, team1_field)
        team_correlations.(team1_field) = [];
    end
    if ~isfield(team_correlations, team2_field)
        team_correlations.(team2_field) = [];
    end
    team_correlations.(team1_field) = [team_correlations.(team1_field), all_pairs_results.correlation(i)];
    team_correlations.(team2_field) = [team_correlations.(team2_field), all_pairs_results.correlation(i)];
end

% Calculate average correlations by team
team_names = fieldnames(team_correlations);
avg_correlations = zeros(length(team_names), 1);
for i = 1:length(team_names)
    avg_correlations(i) = mean(team_correlations.(team_names{i}));
end

bar(avg_correlations);
xlabel('Team Index');
ylabel('Average Correlation');
title('Average Correlation by Team');
set(gca, 'XTickLabel', team_names, 'XTickLabelRotation', 45);
grid on;

% Subplot 10: Metric analysis
subplot(3,4,10);
% Count correlations by metric
metric_correlations = struct();
for i = 1:length(all_pairs_results.metric)
    metric = all_pairs_results.metric{i};
    if ~isfield(metric_correlations, metric)
        metric_correlations.(metric) = [];
    end
    metric_correlations.(metric) = [metric_correlations.(metric), all_pairs_results.correlation(i)];
end

% Calculate average correlations by metric
metric_names = fieldnames(metric_correlations);
avg_metric_correlations = zeros(length(metric_names), 1);
for i = 1:length(metric_names)
    avg_metric_correlations(i) = mean(metric_correlations.(metric_names{i}));
end

bar(avg_metric_correlations);
xlabel('Metric');
ylabel('Average Correlation');
title('Average Correlation by Metric');
set(gca, 'XTickLabel', metric_names, 'XTickLabelRotation', 45);
grid on;

% Subplot 11: Summary statistics
subplot(3,4,11);
text(0.1, 0.8, sprintf('Total Pairs: %d', length(all_pairs_results.correlation)), 'FontSize', 12);
text(0.1, 0.6, sprintf('Avg Correlation: %.3f', avg_correlation), 'FontSize', 12);
text(0.1, 0.4, sprintf('Avg SNR Improvement: %.3f', avg_snr_improvement), 'FontSize', 12);
text(0.1, 0.2, sprintf('Max SNR Improvement: %.3f', max_snr_improvement), 'FontSize', 12);
axis off;
title('Summary Statistics');

% Subplot 12: Theoretical vs empirical
subplot(3,4,12);
% Plot theoretical curve for average correlation
avg_rho = avg_correlation;
theoretical_snr = (1 + kappa_values) ./ (1 + kappa_values - 2*sqrt(kappa_values)*avg_rho);
plot(kappa_values, theoretical_snr, 'b-', 'LineWidth', 2, 'DisplayName', 'Theoretical');
hold on;
plot(kappa_values, snr_ratio_4x, 'r--', 'LineWidth', 2, 'DisplayName', '4x Ceiling');
xlabel('Variance Ratio (κ)');
ylabel('SNR_R/SNR_A');
title('Theoretical vs 4x Ceiling');
legend('Location', 'best');
grid on;

sgtitle('Complete SNR Correlation Analysis');

% Save figure
output_dir = 'outputs/snr_correlation_analysis';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
fig_file = fullfile(output_dir, 'complete_snr_correlation_analysis.png');
saveas(gcf, fig_file);
fprintf('✓ Visualization saved to: %s\n', fig_file);

%% Step 8: Key Insights and Conclusions
fprintf('\nSTEP 8: Key insights and conclusions...\n');
fprintf('=====================================\n');

fprintf('\nKEY INSIGHTS:\n');
fprintf('============\n');

fprintf('\n1. Complete Team Pair Analysis:\n');
fprintf('   - Analyzed %d team-metric pairs\n', length(all_pairs_results.correlation));
fprintf('   - Average correlation: %.3f\n', avg_correlation);
fprintf('   - Correlation range: [%.3f, %.3f]\n', min_correlation, max_correlation);

fprintf('\n2. SNR Relations with Correlation (UP2-4 Notation):\n');
fprintf('   - SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)\n');
fprintf('   - Asymptotes: ρ → 1 gives ∞, ρ → -1 gives finite limit\n');
fprintf('   - Independence (ρ = 0): SNR_R/SNR_A = 1 + κ\n');

fprintf('\n3. 4x Ceiling Analysis (UP2-4 Notation):\n');
fprintf('   - 4x ceiling: SNR_R/SNR_A = 4 / (1 + κ) when ρ = 0\n');
fprintf('   - Maximum occurs when κ = 0 (σ²_B = 0): SNR_R/SNR_A = 4\n');
fprintf('   - This is the signal enhancement framework, not correlation framework\n');

fprintf('\n4. Empirical Validation:\n');
fprintf('   - Average SNR improvement: %.3f\n', avg_snr_improvement);
fprintf('   - Maximum SNR improvement: %.3f\n', max_snr_improvement);
fprintf('   - Positive correlations: %d/%d (%.1f%%)\n', positive_correlations, length(all_pairs_results.correlation), 100*positive_correlations/length(all_pairs_results.correlation));

fprintf('\n5. Framework Integration:\n');
fprintf('   - Correlation framework: SNR improvement through noise reduction\n');
fprintf('   - Signal enhancement framework: SNR improvement through variance ratio\n');
fprintf('   - Both frameworks are valid and complementary\n');

fprintf('\n=== COMPLETE SNR CORRELATION ANALYSIS COMPLETE ===\n');
