function Visualize_SEF_Sensitivity()
    % Visualize SEF sensitivity analysis results
    
    fprintf('=== SEF Sensitivity Analysis Visualization ===\n');
    
    % Load sensitivity analysis results
    % Change to project root directory
    project_root = fileparts(mfilename('fullpath'));
    project_root = fileparts(project_root); % Go up one level from scripts/
    cd(project_root);
    
    try
        load('outputs/results/sef_sensitivity_analysis_results.mat');
        fprintf('✓ Loaded sensitivity analysis results\n');
    catch
        error('Please run SEF_Sensitivity_Analysis_Simple.m first to generate results');
    end
    
    % Create output directory for figures
    if ~exist('outputs/figures/sensitivity_analysis', 'dir')
        mkdir('outputs/figures/sensitivity_analysis');
    end
    
    % 1. Sample Size Sensitivity
    if isfield(results, 'sample_size')
        visualize_sample_size_sensitivity(results.sample_size);
    end
    
    % 2. Temporal Behavior
    if isfield(results, 'temporal')
        visualize_temporal_behavior(results.temporal);
    end
    
    % 3. Parameter Sensitivity
    if isfield(results, 'parameter_sensitivity')
        visualize_parameter_sensitivity(results.parameter_sensitivity);
    end
    
    % 4. Robustness Analysis
    if isfield(results, 'robustness')
        visualize_robustness_analysis(results.robustness);
    end
    
    % 5. Statistical Validation
    if isfield(results, 'validation')
        visualize_statistical_validation(results.validation);
    end
    
    % 6. Comprehensive Summary
    create_comprehensive_summary(results);
    
    fprintf('✓ All sensitivity analysis visualizations complete\n');
end

function visualize_sample_size_sensitivity(sample_results)
    % Visualize sample size sensitivity analysis
    
    fprintf('  Creating sample size sensitivity plots...\n');
    
    % Create figure
    figure('Position', [100, 100, 1200, 800]);
    
    % Subplot 1: SEF vs Sample Size with Confidence Intervals
    subplot(2, 2, 1);
    errorbar(sample_results.sample_sizes, sample_results.sef_means, ...
             sample_results.sef_stds, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    fill([sample_results.sample_sizes, fliplr(sample_results.sample_sizes)], ...
         [sample_results.sef_ci_lower, fliplr(sample_results.sef_ci_upper)], ...
         'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    xlabel('Sample Size');
    ylabel('SEF Value');
    title('SEF vs Sample Size with 95% CI');
    grid on;
    legend('Mean SEF', '95% Confidence Interval', 'Location', 'best');
    
    % Subplot 2: Convergence Analysis
    subplot(2, 2, 2);
    semilogx(sample_results.sample_sizes, sample_results.convergence, 'ro-', ...
             'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    yline(0.1, 'k--', 'LineWidth', 2, 'DisplayName', 'Convergence Threshold');
    xlabel('Sample Size (log scale)');
    ylabel('Coefficient of Variation');
    title('SEF Convergence Analysis');
    grid on;
    legend('CV', 'Convergence Threshold (0.1)', 'Location', 'best');
    
    % Subplot 3: Bootstrap Distribution for Largest Sample
    subplot(2, 2, 3);
    [max_idx, ~] = max(sample_results.sample_sizes);
    if max_idx > 0
        % Simulate bootstrap distribution for visualization
        n_bootstrap = 1000;
        sef_bootstrap = normrnd(sample_results.sef_means(end), ...
                               sample_results.sef_stds(end), n_bootstrap, 1);
        histogram(sef_bootstrap, 30, 'Normalization', 'pdf', 'FaceAlpha', 0.7);
        xline(sample_results.sef_means(end), 'r--', 'LineWidth', 2, 'DisplayName', 'Mean SEF');
        xlabel('SEF Value');
        ylabel('Probability Density');
        title(sprintf('Bootstrap Distribution (n=%d)', max_idx));
        grid on;
        legend('Bootstrap Samples', 'Mean SEF', 'Location', 'best');
    end
    
    % Subplot 4: Sample Size Requirements
    subplot(2, 2, 4);
    bar(sample_results.sample_sizes, sample_results.sef_stds, 'FaceColor', [0.2, 0.6, 0.8]);
    xlabel('Sample Size');
    ylabel('SEF Standard Deviation');
    title('SEF Stability vs Sample Size');
    grid on;
    
    % Add convergence threshold line
    hold on;
    yline(0.1 * abs(sample_results.sef_means(end)), 'r--', 'LineWidth', 2, ...
          'DisplayName', 'Stability Threshold');
    legend('SEF Std Dev', 'Stability Threshold', 'Location', 'best');
    
    % Save figure
    saveas(gcf, 'outputs/figures/sensitivity_analysis/sample_size_sensitivity.png');
    saveas(gcf, 'outputs/figures/sensitivity_analysis/sample_size_sensitivity.fig');
    
    fprintf('    ✓ Sample size sensitivity plots saved\n');
end

function visualize_temporal_behavior(temporal_results)
    % Visualize temporal behavior analysis
    
    fprintf('  Creating temporal behavior plots...\n');
    
    % Create figure
    figure('Position', [100, 100, 1200, 600]);
    
    % Subplot 1: Seasonal SEF Values
    subplot(1, 2, 1);
    if isfield(temporal_results, 'seasons') && isfield(temporal_results, 'seasonal_sef')
        % Use season strings for x-axis labels
        if isfield(temporal_results, 'season_strings')
            x_labels = temporal_results.season_strings;
        else
            x_labels = temporal_results.seasons;
        end
        
        bar(1:length(temporal_results.seasons), temporal_results.seasonal_sef, 'FaceColor', [0.8, 0.4, 0.2]);
        hold on;
        errorbar(1:length(temporal_results.seasons), temporal_results.seasonal_sef, ...
                 temporal_results.seasonal_std, 'k.', 'LineWidth', 2);
        xlabel('Season');
        ylabel('SEF Value');
        title('Seasonal SEF Values');
        set(gca, 'XTick', 1:length(temporal_results.seasons), 'XTickLabel', x_labels);
        grid on;
        
        % Add trend line
        if length(temporal_results.seasons) > 1
            p = polyfit(temporal_results.seasons, temporal_results.seasonal_sef, 1);
            trend_line = polyval(p, temporal_results.seasons);
            plot(temporal_results.seasons, trend_line, 'r--', 'LineWidth', 2, ...
                 'DisplayName', sprintf('Trend (slope=%.3f)', p(1)));
            legend('Seasonal SEF', 'Error Bars', 'Trend Line', 'Location', 'best');
        end
    end
    
    % Subplot 2: Temporal Stability Metrics
    subplot(1, 2, 2);
    if isfield(temporal_results, 'seasonal_cv')
        % Create stability metrics bar chart
        metrics = {'Seasonal CV', 'Temporal Trend'};
        values = [temporal_results.seasonal_cv, abs(temporal_results.temporal_trend)];
        colors = [0.2, 0.8, 0.4; 0.8, 0.2, 0.4];
        
        for i = 1:length(metrics)
            bar(i, values(i), 'FaceColor', colors(i, :));
            hold on;
        end
        
        xlabel('Stability Metric');
        ylabel('Value');
        title('Temporal Stability Metrics');
        set(gca, 'XTickLabel', metrics);
        grid on;
        
        % Add reference lines
        yline(0.1, 'k--', 'LineWidth', 2, 'DisplayName', 'Low Variability Threshold');
        legend('Seasonal CV', 'Temporal Trend', 'Low Variability Threshold', 'Location', 'best');
    end
    
    % Save figure
    saveas(gcf, 'outputs/figures/sensitivity_analysis/temporal_behavior.png');
    saveas(gcf, 'outputs/figures/sensitivity_analysis/temporal_behavior.fig');
    
    fprintf('    ✓ Temporal behavior plots saved\n');
end

function visualize_parameter_sensitivity(param_results)
    % Visualize parameter sensitivity analysis
    
    fprintf('  Creating parameter sensitivity plots...\n');
    
    % Create figure
    figure('Position', [100, 100, 1200, 800]);
    
    % Subplot 1: κ (Variance Ratio) Sensitivity
    subplot(2, 2, 1);
    semilogx(param_results.kappa_range, param_results.kappa_sef, 'bo-', ...
             'LineWidth', 2, 'MarkerSize', 6);
    xlabel('κ (Variance Ratio)');
    ylabel('SEF Value');
    title('SEF Sensitivity to κ (Variance Ratio)');
    grid on;
    
    % Add baseline reference
    if isfield(param_results, 'baseline_sef')
        yline(param_results.baseline_sef, 'r--', 'LineWidth', 2, 'DisplayName', 'Baseline SEF');
        legend('SEF vs κ', 'Baseline SEF', 'Location', 'best');
    end
    
    % Subplot 2: ρ (Correlation) Sensitivity
    subplot(2, 2, 2);
    plot(param_results.rho_range, param_results.rho_sef, 'go-', ...
         'LineWidth', 2, 'MarkerSize', 6);
    xlabel('ρ (Correlation)');
    ylabel('SEF Value');
    title('SEF Sensitivity to ρ (Correlation)');
    grid on;
    
    % Add baseline reference
    if isfield(param_results, 'baseline_sef')
        yline(param_results.baseline_sef, 'r--', 'LineWidth', 2, 'DisplayName', 'Baseline SEF');
        legend('SEF vs ρ', 'Baseline SEF', 'Location', 'best');
    end
    
    % Subplot 3: Parameter Space Heatmap
    subplot(2, 2, 3);
    if isfield(param_results, 'parameter_space')
        imagesc(log10(param_results.parameter_space.kappa(1, :)), ...
                param_results.parameter_space.rho(:, 1), ...
                param_results.parameter_space.sef);
        colorbar;
        xlabel('log₁₀(κ)');
        ylabel('ρ');
        title('SEF Parameter Space Heatmap');
        
        % Add contour lines
        hold on;
        contour(log10(param_results.parameter_space.kappa), ...
                param_results.parameter_space.rho, ...
                param_results.parameter_space.sef, 10, 'k-', 'LineWidth', 0.5);
    end
    
    % Subplot 4: Sensitivity Indices
    subplot(2, 2, 4);
    if isfield(param_results, 'kappa_sensitivity') && isfield(param_results, 'rho_sensitivity')
        sensitivity_data = [param_results.kappa_sensitivity, param_results.rho_sensitivity];
        bar(sensitivity_data, 'FaceColor', [0.6, 0.2, 0.8]);
        xlabel('Parameter');
        ylabel('Sensitivity Index');
        title('Parameter Sensitivity Indices');
        set(gca, 'XTickLabel', {'κ (Variance Ratio)', 'ρ (Correlation)'});
        grid on;
        
        % Add reference line for high sensitivity
        yline(0.5, 'r--', 'LineWidth', 2, 'DisplayName', 'High Sensitivity Threshold');
        legend('Sensitivity Index', 'High Sensitivity Threshold', 'Location', 'best');
    end
    
    % Save figure
    saveas(gcf, 'outputs/figures/sensitivity_analysis/parameter_sensitivity.png');
    saveas(gcf, 'outputs/figures/sensitivity_analysis/parameter_sensitivity.fig');
    
    fprintf('    ✓ Parameter sensitivity plots saved\n');
end

function visualize_robustness_analysis(robustness_results)
    % Visualize robustness analysis
    
    fprintf('  Creating robustness analysis plots...\n');
    
    % Create figure
    figure('Position', [100, 100, 1200, 600]);
    
    % Subplot 1: Outlier Sensitivity
    subplot(1, 3, 1);
    if isfield(robustness_results, 'outlier_analysis')
        plot(robustness_results.outlier_analysis.thresholds, ...
             robustness_results.outlier_analysis.sef_values, 'ro-', ...
             'LineWidth', 2, 'MarkerSize', 8);
        xlabel('Outlier Removal Threshold');
        ylabel('SEF Value');
        title('Outlier Sensitivity');
        grid on;
        
        % Add sensitivity value
        text(0.5, 0.9, sprintf('Sensitivity: %.3f', ...
             robustness_results.outlier_analysis.sensitivity), ...
             'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    % Subplot 2: Noise Sensitivity
    subplot(1, 3, 2);
    if isfield(robustness_results, 'noise_analysis')
        plot(robustness_results.noise_analysis.noise_levels, ...
             robustness_results.noise_analysis.sef_values, 'go-', ...
             'LineWidth', 2, 'MarkerSize', 8);
        xlabel('Noise Level');
        ylabel('SEF Value');
        title('Noise Sensitivity');
        grid on;
        
        % Add sensitivity value
        text(0.5, 0.9, sprintf('Sensitivity: %.3f', ...
             robustness_results.noise_analysis.sensitivity), ...
             'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    % Subplot 3: Missing Data Sensitivity
    subplot(1, 3, 3);
    if isfield(robustness_results, 'missing_data_analysis')
        plot(robustness_results.missing_data_analysis.missing_fractions, ...
             robustness_results.missing_data_analysis.sef_values, 'bo-', ...
             'LineWidth', 2, 'MarkerSize', 8);
        xlabel('Missing Data Fraction');
        ylabel('SEF Value');
        title('Missing Data Sensitivity');
        grid on;
        
        % Add sensitivity value
        text(0.5, 0.9, sprintf('Sensitivity: %.3f', ...
             robustness_results.missing_data_analysis.sensitivity), ...
             'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    % Save figure
    saveas(gcf, 'outputs/figures/sensitivity_analysis/robustness_analysis.png');
    saveas(gcf, 'outputs/figures/sensitivity_analysis/robustness_analysis.fig');
    
    fprintf('    ✓ Robustness analysis plots saved\n');
end

function visualize_statistical_validation(validation_results)
    % Visualize statistical validation results
    
    fprintf('  Creating statistical validation plots...\n');
    
    % Create figure
    figure('Position', [100, 100, 1200, 600]);
    
    % Subplot 1: Cross-Validation Results
    subplot(1, 2, 1);
    if isfield(validation_results, 'cv_results') && isfield(validation_results.cv_results, 'k_fold')
        cv_data = validation_results.cv_results.k_fold;
        bar(1:length(cv_data.fold_sef), cv_data.fold_sef, 'FaceColor', [0.8, 0.4, 0.2]);
        hold on;
        errorbar(1:length(cv_data.fold_sef), cv_data.fold_sef, ...
                 cv_data.fold_std, 'k.', 'LineWidth', 2);
        xlabel('Fold');
        ylabel('SEF Value');
        title('K-Fold Cross-Validation Results');
        grid on;
        
        % Add mean line
        yline(cv_data.mean_sef, 'r--', 'LineWidth', 2, 'DisplayName', 'Mean SEF');
        legend('Fold SEF', 'Error Bars', 'Mean SEF', 'Location', 'best');
    end
    
    % Subplot 2: Statistical Significance
    subplot(1, 2, 2);
    if isfield(validation_results, 'significance')
        % Create significance visualization
        sig_data = validation_results.significance;
        
        % Bar chart for significance metrics
        metrics = {'P-value', 'Effect Size'};
        values = [sig_data.p_value, abs(sig_data.effect_size)];
        colors = [0.8, 0.2, 0.2; 0.2, 0.8, 0.2];
        
        for i = 1:length(metrics)
            bar(i, values(i), 'FaceColor', colors(i, :));
            hold on;
        end
        
        xlabel('Statistical Metric');
        ylabel('Value');
        title('Statistical Significance Analysis');
        set(gca, 'XTickLabel', metrics);
        grid on;
        
        % Add significance threshold
        yline(0.05, 'k--', 'LineWidth', 2, 'DisplayName', 'α = 0.05');
        legend('P-value', 'Effect Size', 'α = 0.05', 'Location', 'best');
        
        % Add significance text
        if sig_data.significant
            text(0.5, 0.9, 'SIGNIFICANT', 'Units', 'normalized', ...
                 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'green');
        else
            text(0.5, 0.9, 'NOT SIGNIFICANT', 'Units', 'normalized', ...
                 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'red');
        end
    end
    
    % Save figure
    saveas(gcf, 'outputs/figures/sensitivity_analysis/statistical_validation.png');
    saveas(gcf, 'outputs/figures/sensitivity_analysis/statistical_validation.fig');
    
    fprintf('    ✓ Statistical validation plots saved\n');
end

function create_comprehensive_summary(results)
    % Create comprehensive summary visualization
    
    fprintf('  Creating comprehensive summary...\n');
    
    % Create figure
    figure('Position', [100, 100, 1400, 1000]);
    
    % Create a comprehensive dashboard
    subplot(3, 3, 1);
    if isfield(results, 'sample_size')
        plot(results.sample_size.sample_sizes, results.sample_size.sef_means, 'bo-', ...
             'LineWidth', 2, 'MarkerSize', 6);
        xlabel('Sample Size');
        ylabel('SEF Value');
        title('Sample Size Sensitivity');
        grid on;
    end
    
    subplot(3, 3, 2);
    if isfield(results, 'temporal') && isfield(results.temporal, 'seasonal_sef')
        bar(results.temporal.seasons, results.temporal.seasonal_sef, 'FaceColor', [0.8, 0.4, 0.2]);
        xlabel('Season');
        ylabel('SEF Value');
        title('Temporal Behavior');
        grid on;
    end
    
    subplot(3, 3, 3);
    if isfield(results, 'parameter_sensitivity')
        sensitivity_data = [results.parameter_sensitivity.kappa_sensitivity, ...
                           results.parameter_sensitivity.rho_sensitivity];
        bar(sensitivity_data, 'FaceColor', [0.6, 0.2, 0.8]);
        xlabel('Parameter');
        ylabel('Sensitivity Index');
        title('Parameter Sensitivity');
        set(gca, 'XTickLabel', {'κ', 'ρ'});
        grid on;
    end
    
    subplot(3, 3, 4);
    if isfield(results, 'robustness') && isfield(results.robustness, 'outlier_analysis')
        plot(results.robustness.outlier_analysis.thresholds, ...
             results.robustness.outlier_analysis.sef_values, 'ro-', 'LineWidth', 2);
        xlabel('Outlier Threshold');
        ylabel('SEF Value');
        title('Outlier Sensitivity');
        grid on;
    end
    
    subplot(3, 3, 5);
    if isfield(results, 'robustness') && isfield(results.robustness, 'noise_analysis')
        plot(results.robustness.noise_analysis.noise_levels, ...
             results.robustness.noise_analysis.sef_values, 'go-', 'LineWidth', 2);
        xlabel('Noise Level');
        ylabel('SEF Value');
        title('Noise Sensitivity');
        grid on;
    end
    
    subplot(3, 3, 6);
    if isfield(results, 'validation') && isfield(results.validation, 'significance')
        sig_data = results.validation.significance;
        bar([sig_data.p_value, abs(sig_data.effect_size)], 'FaceColor', [0.2, 0.8, 0.4]);
        xlabel('Metric');
        ylabel('Value');
        title('Statistical Significance');
        set(gca, 'XTickLabel', {'P-value', 'Effect Size'});
        grid on;
    end
    
    subplot(3, 3, 7);
    if isfield(results, 'validation') && isfield(results.validation, 'confidence_intervals')
        ci_data = results.validation.confidence_intervals;
        errorbar(1, ci_data.mean_sef, ci_data.std_sef, 'bo', 'LineWidth', 2, 'MarkerSize', 8);
        hold on;
        plot([0.8, 1.2], [ci_data.ci_95(1), ci_data.ci_95(1)], 'r--', 'LineWidth', 2);
        plot([0.8, 1.2], [ci_data.ci_95(2), ci_data.ci_95(2)], 'r--', 'LineWidth', 2);
        xlim([0.7, 1.3]);
        ylabel('SEF Value');
        title('95% Confidence Interval');
        grid on;
    end
    
    subplot(3, 3, 8);
    if isfield(results, 'validation') && isfield(results.validation, 'model_comparison')
        model_data = results.validation.model_comparison;
        comparison_data = [model_data.sef, model_data.standardized_diff, model_data.cohens_d];
        bar(comparison_data, 'FaceColor', [0.4, 0.6, 0.8]);
        xlabel('Method');
        ylabel('Value');
        title('Model Comparison');
        set(gca, 'XTickLabel', {'SEF', 'Std Diff', 'Cohen''s d'});
        grid on;
    end
    
    subplot(3, 3, 9);
    % Summary text
    text(0.1, 0.9, 'SEF Sensitivity Analysis Summary', 'FontSize', 16, 'FontWeight', 'bold');
            if isfield(results, 'sample_size') && results.sample_size.min_sample_size < Inf
            text(0.1, 0.8, sprintf('Sample Size Convergence: Yes (n=%d)', results.sample_size.min_sample_size), 'FontSize', 12);
        else
            text(0.1, 0.8, 'Sample Size Convergence: No', 'FontSize', 12);
        end
    if isfield(results, 'temporal') && results.temporal.seasonal_cv < 0.2
        text(0.1, 0.7, 'Temporal Stability: Good', 'FontSize', 12);
    else
        text(0.1, 0.7, 'Temporal Stability: Poor', 'FontSize', 12);
    end
    if isfield(results, 'parameter_sensitivity') && ...
       max(results.parameter_sensitivity.kappa_sensitivity, results.parameter_sensitivity.rho_sensitivity) < 0.5
        text(0.1, 0.6, 'Parameter Sensitivity: Low', 'FontSize', 12);
    else
        text(0.1, 0.6, 'Parameter Sensitivity: High', 'FontSize', 12);
    end
    if isfield(results, 'validation') && results.validation.significance.significant
        text(0.1, 0.5, 'Statistical Significance: Yes', 'FontSize', 12);
    else
        text(0.1, 0.5, 'Statistical Significance: No', 'FontSize', 12);
    end
    if isfield(results, 'robustness') && ...
       max([results.robustness.outlier_analysis.sensitivity, ...
            results.robustness.noise_analysis.sensitivity]) < 0.3
        text(0.1, 0.4, 'Robustness: Good', 'FontSize', 12);
    else
        text(0.1, 0.4, 'Robustness: Poor', 'FontSize', 12);
    end
    
    % Save figure
    saveas(gcf, 'outputs/figures/sensitivity_analysis/comprehensive_summary.png');
    saveas(gcf, 'outputs/figures/sensitivity_analysis/comprehensive_summary.fig');
    
    fprintf('    ✓ Comprehensive summary saved\n');
end
