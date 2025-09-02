%% ========================================================================
% SNR OPTIMIZATION ANALYSIS - WHEN IS SNR_R MAXIMIZED RELATIVE TO SNR_A?
% ========================================================================
% 
% This script analyzes the mathematical relationship between SNR_R and SNR_A
% to determine when relative measures provide maximum SNR improvement.
%
% Key Question: Is SNR_R maximized when σ_A ≈ σ_B?
%
% Mathematical Framework:
% SNR_A = |μ_A - μ_B|² / σ_A²
% SNR_R = (2|μ_A - μ_B|)² / (σ_A² + σ_B²)
% SNR_R/SNR_A = 4 / (1 + r²) where r = σ_B/σ_A
%
% Author: AI Assistant
% Date: 2024
% Purpose: Mathematical analysis of SNR optimization conditions
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
config.output_dir = 'outputs/snr_optimization';
config.save_figures = true;
config.verbose = true;

% Create output directory
if ~exist(config.output_dir, 'dir')
    mkdir(config.output_dir);
end

fprintf('=== SNR OPTIMIZATION ANALYSIS ===\n');
fprintf('Script: %s\n', mfilename);
fprintf('Date: %s\n', datestr(now));
fprintf('Project Root: %s\n', project_root);
fprintf('Output Directory: %s\n', config.output_dir);
fprintf('\n');

%% Step 1: Mathematical Derivation
fprintf('STEP 1: Mathematical derivation of SNR optimization...\n');

fprintf('\nMathematical Framework:\n');
fprintf('======================\n');
fprintf('Given:\n');
fprintf('  SNR_A = |μ_A - μ_B|² / σ_A²\n');
fprintf('  SNR_R = (2|μ_A - μ_B|)² / (σ_A² + σ_B²)\n\n');

fprintf('SNR improvement ratio:\n');
fprintf('  SNR_R/SNR_A = [(2|μ_A - μ_B|)² / (σ_A² + σ_B²)] / [|μ_A - μ_B|² / σ_A²]\n');
fprintf('  SNR_R/SNR_A = [4|μ_A - μ_B|² / (σ_A² + σ_B²)] × [σ_A² / |μ_A - μ_B|²]\n');
fprintf('  SNR_R/SNR_A = 4σ_A² / (σ_A² + σ_B²)\n\n');

fprintf('Let r = σ_B/σ_A (variance ratio):\n');
fprintf('  SNR_R/SNR_A = 4σ_A² / (σ_A² + r²σ_A²)\n');
fprintf('  SNR_R/SNR_A = 4σ_A² / [σ_A²(1 + r²)]\n');
fprintf('  SNR_R/SNR_A = 4 / (1 + r²)\n\n');

%% Step 2: Theoretical Analysis
fprintf('STEP 2: Theoretical analysis of optimization conditions...\n');

fprintf('\nOptimization Analysis:\n');
fprintf('=====================\n');

% Define variance ratios to analyze
r_values = [0, 0.5, 1, 1.5, 2, 3, 5, 10];
snr_improvements = 4 ./ (1 + r_values.^2);

fprintf('Variance Ratio (r = σ_B/σ_A) | SNR_R/SNR_A | Interpretation\n');
fprintf('------------------------------|-------------|---------------\n');

for i = 1:length(r_values)
    r = r_values(i);
    improvement = snr_improvements(i);
    
    if r == 0
        interpretation = 'Perfect (σ_B = 0)';
    elseif r == 1
        interpretation = 'Equal variances';
    elseif r < 1
        interpretation = 'σ_B < σ_A';
    else
        interpretation = 'σ_B > σ_A';
    end
    
    fprintf('%.1f                           | %.2fx        | %s\n', r, improvement, interpretation);
end

fprintf('\nKey Insights:\n');
fprintf('  • SNR_R/SNR_A is MAXIMIZED when r = 0 (σ_B = 0)\n');
fprintf('  • SNR_R/SNR_A = 2x when r = 1 (σ_A = σ_B)\n');
fprintf('  • SNR_R/SNR_A decreases as r increases\n');
fprintf('  • When r > √3 ≈ 1.73, SNR_R < SNR_A (relative measures worse)\n');

%% Step 3: Empirical Analysis with Rugby Data
fprintf('\nSTEP 3: Empirical analysis with rugby data...\n');

% Load rugby data
try
    isolated_data = readtable('data/raw/S20Isolated.csv');
    relative_data = readtable('data/raw/S20Relative.csv');
    fprintf('✓ Rugby data loaded successfully\n');
catch ME
    fprintf('⚠ Could not load rugby data: %s\n', ME.message);
    isolated_data = [];
    relative_data = [];
end

if ~isempty(isolated_data) && ~isempty(relative_data)
    fprintf('\nEmpirical Analysis:\n');
    fprintf('==================\n');
    
    % Technical KPIs to analyze
    technical_kpis = {'Carry', 'MetresMade', 'DefenderBeaten', 'Offload', 'Pass'};
    
    fprintf('KPI\t\t\tσ_A\t\tσ_B\t\tr=σ_B/σ_A\tSNR_R/SNR_A\tTheory\t\tEmpirical\n');
    fprintf('---\t\t\t---\t\t---\t\t---------\t----------\t------\t\t----------\n');
    
    empirical_results = struct();
    empirical_results.kpi = {};
    empirical_results.sigma_A = [];
    empirical_results.sigma_B = [];
    empirical_results.variance_ratio = [];
    empirical_results.theoretical_improvement = [];
    empirical_results.empirical_improvement = [];
    
    for i = 1:length(technical_kpis)
        kpi = technical_kpis{i};
        
        % Get data
        abs_data = isolated_data.(kpi);
        rel_data = relative_data.(kpi);
        abs_outcomes = isolated_data.Match_Outcome;
        rel_outcomes = relative_data.Match_Outcome;
        
        % Clean data
        valid_abs = ~isnan(abs_data) & ~ismissing(abs_outcomes);
        valid_rel = ~isnan(rel_data) & ~ismissing(rel_outcomes);
        
        abs_data = abs_data(valid_abs);
        abs_outcomes = abs_outcomes(valid_abs);
        rel_data = rel_data(valid_rel);
        rel_outcomes = rel_outcomes(valid_rel);
        
        wins_abs = strcmp(abs_outcomes, 'W');
        wins_rel = strcmp(rel_outcomes, 'W');
        
        if sum(wins_abs) > 2 && sum(wins_rel) > 2
            % Calculate standard deviations
            sigma_A = std(abs_data);
            sigma_B = std(abs_data(~wins_abs)); % Use losing team data as proxy for σ_B
            
            % Calculate variance ratio
            r = sigma_B / sigma_A;
            
            % Theoretical improvement
            theoretical_improvement = 4 / (1 + r^2);
            
            % Empirical improvement
            mu_abs_win = mean(abs_data(wins_abs));
            mu_abs_loss = mean(abs_data(~wins_abs));
            snr_abs = (mu_abs_win - mu_abs_loss)^2 / (sigma_A^2 + 1e-6);
            
            mu_rel_win = mean(rel_data(wins_rel));
            mu_rel_loss = mean(rel_data(~wins_rel));
            sigma_rel = std(rel_data);
            snr_rel = (mu_rel_win - mu_rel_loss)^2 / (sigma_rel^2 + 1e-6);
            
            empirical_improvement = snr_rel / snr_abs;
            
            % Store results
            empirical_results.kpi{end+1} = kpi;
            empirical_results.sigma_A(end+1) = sigma_A;
            empirical_results.sigma_B(end+1) = sigma_B;
            empirical_results.variance_ratio(end+1) = r;
            empirical_results.theoretical_improvement(end+1) = theoretical_improvement;
            empirical_results.empirical_improvement(end+1) = empirical_improvement;
            
            fprintf('%s\t\t%.2f\t\t%.2f\t\t%.2f\t\t%.2fx\t\t%.2fx\t\t%.2fx\n', ...
                    kpi, sigma_A, sigma_B, r, theoretical_improvement, empirical_improvement);
        end
    end
    
    % Calculate correlation between theoretical and empirical
    if length(empirical_results.theoretical_improvement) > 1
        correlation = corr(empirical_results.theoretical_improvement', empirical_results.empirical_improvement');
        fprintf('\nCorrelation between theoretical and empirical improvements: %.3f\n', correlation);
    end
end

%% Step 4: Optimization Conditions
fprintf('\nSTEP 4: Optimization conditions analysis...\n');

fprintf('\nOptimization Conditions:\n');
fprintf('=======================\n');

fprintf('1. MAXIMUM SNR_R/SNR_A occurs when:\n');
fprintf('   • σ_B = 0 (r = 0) → SNR_R/SNR_A = 4x\n');
fprintf('   • This means one team has zero variance (perfect consistency)\n');
fprintf('   • Practically unrealistic in real sports data\n\n');

fprintf('2. EQUAL VARIANCE CASE (σ_A = σ_B, r = 1):\n');
fprintf('   • SNR_R/SNR_A = 2x\n');
fprintf('   • This is the "balanced" case where both teams have similar variability\n');
fprintf('   • Often assumed in theoretical analysis\n\n');

fprintf('3. PRACTICAL OPTIMIZATION:\n');
fprintf('   • SNR_R/SNR_A > 1 when r < √3 ≈ 1.73\n');
fprintf('   • SNR_R/SNR_A = 1 when r = √3 ≈ 1.73\n');
fprintf('   • SNR_R/SNR_A < 1 when r > √3 ≈ 1.73\n\n');

fprintf('4. RUGBY DATA IMPLICATIONS:\n');
if exist('empirical_results', 'var') && ~isempty(empirical_results.variance_ratio)
    mean_r = mean(empirical_results.variance_ratio);
    fprintf('   • Mean variance ratio in rugby data: %.2f\n', mean_r);
    if mean_r < 1.73
        fprintf('   • Relative measures provide SNR improvement (r < √3)\n');
    else
        fprintf('   • Relative measures may not provide SNR improvement (r > √3)\n');
    end
end

%% Step 5: Visual Analysis
if config.save_figures
    fprintf('\nSTEP 5: Creating visualizations...\n');
    
    figure('Position', [100, 100, 1400, 800]);
    
    % Subplot 1: Theoretical SNR improvement vs variance ratio
    subplot(2,2,1);
    r_theory = 0:0.1:5;
    snr_theory = 4 ./ (1 + r_theory.^2);
    plot(r_theory, snr_theory, 'b-', 'LineWidth', 2);
    xlabel('Variance Ratio (r = σ_B/σ_A)');
    ylabel('SNR_R/SNR_A');
    title('Theoretical SNR Improvement vs Variance Ratio');
    grid on;
    yline(1, 'r--', 'No Improvement');
    yline(2, 'g--', 'Equal Variance (r=1)');
    xline(sqrt(3), 'k--', 'r = √3');
    legend('SNR_R/SNR_A', 'No Improvement', 'Equal Variance', 'Break-even', 'Location', 'best');
    
    % Subplot 2: Empirical vs theoretical comparison
    if exist('empirical_results', 'var') && ~isempty(empirical_results.variance_ratio)
        subplot(2,2,2);
        scatter(empirical_results.variance_ratio, empirical_results.empirical_improvement, 100, 'ro', 'filled');
        hold on;
        plot(empirical_results.variance_ratio, empirical_results.theoretical_improvement, 'b-', 'LineWidth', 2);
        xlabel('Variance Ratio (r = σ_B/σ_A)');
        ylabel('SNR Improvement');
        title('Empirical vs Theoretical SNR Improvement');
        legend('Empirical', 'Theoretical', 'Location', 'best');
        grid on;
        
        % Subplot 3: KPI-specific analysis
        subplot(2,2,3);
        bar([empirical_results.theoretical_improvement; empirical_results.empirical_improvement]');
        xlabel('KPI');
        ylabel('SNR Improvement');
        title('Theoretical vs Empirical SNR Improvements');
        set(gca, 'XTickLabel', empirical_results.kpi, 'XTickLabelRotation', 45);
        legend('Theoretical', 'Empirical', 'Location', 'best');
        grid on;
        
        % Subplot 4: Variance ratio distribution
        subplot(2,2,4);
        bar(empirical_results.variance_ratio);
        xlabel('KPI');
        ylabel('Variance Ratio (r = σ_B/σ_A)');
        title('Variance Ratios by KPI');
        set(gca, 'XTickLabel', empirical_results.kpi, 'XTickLabelRotation', 45);
        yline(1, 'g--', 'Equal Variance');
        yline(sqrt(3), 'r--', 'Break-even');
        grid on;
    end
    
    sgtitle('SNR Optimization Analysis: When is SNR_R Maximized?');
    
    % Save figure
    fig_file = fullfile(config.output_dir, 'snr_optimization_analysis.png');
    saveas(gcf, fig_file);
    fprintf('✓ Figure saved to: %s\n', fig_file);
end

%% Step 6: Generate Report
fprintf('\nSTEP 6: Generating comprehensive report...\n');

% Create report
report = struct();
report.timestamp = datestr(now);
report.analysis_type = 'SNR Optimization Analysis';
report.mathematical_framework = struct();
report.mathematical_framework.snr_ratio_formula = 'SNR_R/SNR_A = 4 / (1 + r²)';
report.mathematical_framework.optimization_condition = 'Maximum when r = 0 (σ_B = 0)';
report.mathematical_framework.equal_variance_case = 'SNR_R/SNR_A = 2x when r = 1';
report.mathematical_framework.break_even_point = 'SNR_R/SNR_A = 1 when r = √3 ≈ 1.73';

if exist('empirical_results', 'var')
    report.empirical_results = empirical_results;
    report.mean_variance_ratio = mean(empirical_results.variance_ratio);
    report.mean_theoretical_improvement = mean(empirical_results.theoretical_improvement);
    report.mean_empirical_improvement = mean(empirical_results.empirical_improvement);
end

% Save report
report_file = fullfile(config.output_dir, 'snr_optimization_report.mat');
save(report_file, 'report');
fprintf('✓ Report saved to: %s\n', report_file);

%% Step 7: Final Conclusions
fprintf('\nSTEP 7: Final conclusions...\n');

fprintf('\n=== FINAL CONCLUSIONS ===\n');
fprintf('1. MATHEMATICAL OPTIMIZATION:\n');
fprintf('   ✓ SNR_R/SNR_A = 4 / (1 + r²) where r = σ_B/σ_A\n');
fprintf('   ✓ MAXIMUM occurs when r = 0 (σ_B = 0)\n');
fprintf('   ✓ Equal variance case (r = 1) gives SNR_R/SNR_A = 2x\n');
fprintf('   ✓ Break-even point at r = √3 ≈ 1.73\n');

fprintf('\n2. ANSWER TO YOUR QUESTION:\n');
fprintf('   ✓ SNR_R is NOT maximized when σ_A ≈ σ_B\n');
fprintf('   ✓ SNR_R is MAXIMIZED when σ_B = 0 (one team has zero variance)\n');
fprintf('   ✓ When σ_A ≈ σ_B (r = 1), SNR_R/SNR_A = 2x (good but not maximum)\n');

fprintf('\n3. PRACTICAL IMPLICATIONS:\n');
fprintf('   ✓ Relative measures work best when teams have very different variances\n');
fprintf('   ✓ Equal variance case still provides 2x improvement\n');
fprintf('   ✓ Avoid relative measures when r > √3 ≈ 1.73\n');

if exist('empirical_results', 'var')
    fprintf('\n4. RUGBY DATA FINDINGS:\n');
    fprintf('   ✓ Mean variance ratio: %.2f\n', report.mean_variance_ratio);
    fprintf('   ✓ Mean theoretical improvement: %.2fx\n', report.mean_theoretical_improvement);
    fprintf('   ✓ Mean empirical improvement: %.2fx\n', report.mean_empirical_improvement);
end

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Script completed successfully at: %s\n', datestr(now));
fprintf('All outputs saved to: %s\n', config.output_dir);
