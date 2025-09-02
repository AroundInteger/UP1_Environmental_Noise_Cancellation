function Explore_Unequal_Variances()
    %EXPLORE_UNEQUAL_VARIANCES Explore consequences of unequal variances in environmental noise cancellation
    
    fprintf('=== EXPLORING UNEQUAL VARIANCES IN ENVIRONMENTAL NOISE CANCELLATION ===\n');
    fprintf('Timestamp: %s\n\n', datestr(now));
    
    % Base parameters
    n_samples = 1000;
    mu_A = 1012;
    mu_B = 1015;
    sigma_eta = 30;  % Environmental noise
    upset_prob = 0.05;
    
    % Test different variance scenarios
    variance_scenarios = [
        1, 1;      % Equal variances (baseline)
        1, 2;      % 2:1 ratio
        1, 5;      % 5:1 ratio
        1, 10;     % 10:1 ratio
        2, 1;      % 1:2 ratio
        5, 1;      % 1:5 ratio
        10, 1;     % 1:10 ratio
    ];
    
    fprintf('Testing %d variance scenarios:\n', size(variance_scenarios, 1));
    for i = 1:size(variance_scenarios, 1)
        fprintf('  %d. σ_A = %.1f, σ_B = %.1f (ratio: %.1f:1)\n', i, variance_scenarios(i,1), variance_scenarios(i,2), variance_scenarios(i,2)/variance_scenarios(i,1));
    end
    fprintf('\n');
    
    % Store results
    results = struct();
    results.scenarios = variance_scenarios;
    results.var_A = zeros(size(variance_scenarios, 1), 1);
    results.var_B = zeros(size(variance_scenarios, 1), 1);
    results.var_R = zeros(size(variance_scenarios, 1), 1);
    results.var_reduction = zeros(size(variance_scenarios, 1), 1);
    results.snr_improvement = zeros(size(variance_scenarios, 1), 1);
    results.auc_improvement = zeros(size(variance_scenarios, 1), 1);
    results.theory_validated = false(size(variance_scenarios, 1), 1);
    
    % Test each scenario
    for i = 1:size(variance_scenarios, 1)
        sigma_A = variance_scenarios(i, 1);
        sigma_B = variance_scenarios(i, 2);
        
        fprintf('=== SCENARIO %d: σ_A = %.1f, σ_B = %.1f ===\n', i, sigma_A, sigma_B);
        
        % Generate data
        [X_A, X_B, R, Y] = generateDataWithUnequalVariances(n_samples, mu_A, mu_B, sigma_A, sigma_B, sigma_eta, upset_prob);
        
        % Analyze variances
        var_A = var(X_A);
        var_B = var(X_B);
        var_R = var(R);
        
        % Calculate theoretical predictions
        theoretical_var_A = sigma_A^2 + sigma_eta^2;
        theoretical_var_B = sigma_B^2 + sigma_eta^2;
        theoretical_var_R = sigma_A^2 + sigma_B^2;
        
        % Calculate improvements
        var_reduction = (var_A - var_R) / var_A;
        theoretical_var_reduction = (theoretical_var_A - theoretical_var_R) / theoretical_var_A;
        
        % Calculate SNR improvements
        signal = (mu_A - mu_B)^2;
        snr_A = signal / var_A;
        snr_B = signal / var_B;
        snr_R = signal / var_R;
        snr_improvement = snr_R / ((snr_A + snr_B) / 2);
        
        theoretical_snr_A = signal / theoretical_var_A;
        theoretical_snr_B = signal / theoretical_var_B;
        theoretical_snr_R = signal / theoretical_var_R;
        theoretical_snr_improvement = theoretical_snr_R / ((theoretical_snr_A + theoretical_snr_B) / 2);
        
        % Test prediction performance
        [auc_A, auc_B, auc_R] = testPredictionPerformance(X_A, X_B, R, Y);
        auc_improvement = (auc_R - max(auc_A, auc_B)) / max(auc_A, auc_B);
        theory_validated = auc_improvement > 0.05;  % 5% improvement threshold
        
        % Store results
        results.var_A(i) = var_A;
        results.var_B(i) = var_B;
        results.var_R(i) = var_R;
        results.var_reduction(i) = var_reduction;
        results.snr_improvement(i) = snr_improvement;
        results.auc_improvement(i) = auc_improvement;
        results.theory_validated(i) = theory_validated;
        
        % Display results
        fprintf('Empirical Results:\n');
        fprintf('  var_A: %.2f (theoretical: %.2f)\n', var_A, theoretical_var_A);
        fprintf('  var_B: %.2f (theoretical: %.2f)\n', var_B, theoretical_var_B);
        fprintf('  var_R: %.2f (theoretical: %.2f)\n', var_R, theoretical_var_R);
        fprintf('  Variance reduction: %.1f%% (theoretical: %.1f%%)\n', var_reduction*100, theoretical_var_reduction*100);
        fprintf('  SNR improvement: %.2f-fold (theoretical: %.2f-fold)\n', snr_improvement, theoretical_snr_improvement);
        fprintf('  AUC improvement: %.1f%%\n', auc_improvement*100);
        fprintf('  Theory validated: %s\n', string(theory_validated));
        fprintf('\n');
    end
    
    % Generate summary analysis
    generateSummaryAnalysis(results);
    
    % Create visualizations
    createVisualizations(results, variance_scenarios);
    
    fprintf('=== EXPLORATION COMPLETED ===\n');
end

function [X_A, X_B, R, Y] = generateDataWithUnequalVariances(n, mu_A, mu_B, sigma_A, sigma_B, sigma_eta, upset_prob)
    %GENERATEDATAWITHUNEQUALVARIANCES Generate data with unequal variances
    
    % Generate individual variations with different variances
    eps_A = sigma_A * randn(n, 1);
    eps_B = sigma_B * randn(n, 1);
    
    % Generate shared environmental noise
    eta = sigma_eta * randn(n, 1);
    
    % Generate absolute measures (with environmental noise)
    X_A = mu_A + eps_A + eta;
    X_B = mu_B + eps_B + eta;
    
    % Generate relative measures (environmental noise cancels out)
    R = X_A - X_B;
    
    % Generate outcomes
    Y = (R > 0);
    
    % Add upsets
    upsets = rand(n, 1) < upset_prob;
    Y(upsets) = ~Y(upsets);
end

function [auc_A, auc_B, auc_R] = testPredictionPerformance(X_A, X_B, R, Y)
    %TESTPREDICTIONPERFORMANCE Test prediction performance for all measures
    
    % Test absolute measures
    try
        b_A = glmfit(X_A, Y, 'binomial');
        probs_A = glmval(b_A, X_A, 'logit');
        [~, ~, ~, auc_A] = perfcurve(Y, probs_A, 1);
    catch
        auc_A = 0.5;
    end
    
    try
        b_B = glmfit(X_B, Y, 'binomial');
        probs_B = glmval(b_B, X_B, 'logit');
        [~, ~, ~, auc_B] = perfcurve(Y, probs_B, 1);
    catch
        auc_B = 0.5;
    end
    
    % Test relative measures
    try
        b_R = glmfit(R, Y, 'binomial');
        probs_R = glmval(b_R, R, 'logit');
        [~, ~, ~, auc_R] = perfcurve(Y, probs_R, 1);
    catch
        auc_R = 0.5;
    end
end

function generateSummaryAnalysis(results)
    %GENERATESUMMARYANALYSIS Generate summary analysis of results
    
    fprintf('=== SUMMARY ANALYSIS ===\n');
    
    % Find best and worst scenarios
    [max_var_reduction, best_var_idx] = max(results.var_reduction);
    [min_var_reduction, worst_var_idx] = min(results.var_reduction);
    
    [max_snr_improvement, best_snr_idx] = max(results.snr_improvement);
    [min_snr_improvement, worst_snr_idx] = min(results.snr_improvement);
    
    [max_auc_improvement, best_auc_idx] = max(results.auc_improvement);
    [min_auc_improvement, worst_auc_idx] = min(results.auc_improvement);
    
    fprintf('Variance Reduction Analysis:\n');
    fprintf('  Best: %.1f%% (scenario %d)\n', max_var_reduction*100, best_var_idx);
    fprintf('  Worst: %.1f%% (scenario %d)\n', min_var_reduction*100, worst_var_idx);
    fprintf('  Range: %.1f%%\n', (max_var_reduction - min_var_reduction)*100);
    
    fprintf('\nSNR Improvement Analysis:\n');
    fprintf('  Best: %.2f-fold (scenario %d)\n', max_snr_improvement, best_snr_idx);
    fprintf('  Worst: %.2f-fold (scenario %d)\n', min_snr_improvement, worst_snr_idx);
    fprintf('  Range: %.2f-fold\n', max_snr_improvement - min_snr_improvement);
    
    fprintf('\nAUC Improvement Analysis:\n');
    fprintf('  Best: %.1f%% (scenario %d)\n', max_auc_improvement*100, best_auc_idx);
    fprintf('  Worst: %.1f%% (scenario %d)\n', min_auc_improvement*100, worst_auc_idx);
    fprintf('  Range: %.1f%%\n', (max_auc_improvement - min_auc_improvement)*100);
    
    % Theory validation rate
    validation_rate = mean(results.theory_validated) * 100;
    fprintf('\nTheory Validation:\n');
    fprintf('  Validation rate: %.1f%% (%d/%d scenarios)\n', validation_rate, sum(results.theory_validated), length(results.theory_validated));
    
    % Correlation analysis
    variance_ratios = results.scenarios(:,2) ./ results.scenarios(:,1);
    corr_var_ratio_snr = corr(variance_ratios, results.snr_improvement);
    corr_var_ratio_auc = corr(variance_ratios, results.auc_improvement);
    
    fprintf('\nCorrelation Analysis:\n');
    fprintf('  Variance ratio vs SNR improvement: %.3f\n', corr_var_ratio_snr);
    fprintf('  Variance ratio vs AUC improvement: %.3f\n', corr_var_ratio_auc);
    
    % Key insights
    fprintf('\nKey Insights:\n');
    if abs(corr_var_ratio_snr) < 0.1
        fprintf('  ✓ SNR improvement is robust to variance asymmetry\n');
    else
        fprintf('  ⚠ SNR improvement depends on variance asymmetry\n');
    end
    
    if validation_rate > 80
        fprintf('  ✓ Theory is robust across variance scenarios\n');
    elseif validation_rate > 50
        fprintf('  ⚠ Theory is moderately robust across variance scenarios\n');
    else
        fprintf('  ✗ Theory is sensitive to variance scenarios\n');
    end
end

function createVisualizations(results, variance_scenarios)
    %CREATEVISUALIZATIONS Create visualizations of the results
    
    figure('Position', [100, 100, 1400, 1000]);
    
    % Calculate variance ratios
    variance_ratios = variance_scenarios(:,2) ./ variance_scenarios(:,1);
    
    % Plot 1: Variance reduction vs variance ratio
    subplot(2, 3, 1);
    plot(variance_ratios, results.var_reduction*100, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('Variance Ratio (σ_B/σ_A)');
    ylabel('Variance Reduction (%)');
    title('Variance Reduction vs Variance Ratio');
    grid on;
    set(gca, 'XScale', 'log');
    
    % Plot 2: SNR improvement vs variance ratio
    subplot(2, 3, 2);
    plot(variance_ratios, results.snr_improvement, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('Variance Ratio (σ_B/σ_A)');
    ylabel('SNR Improvement (fold)');
    title('SNR Improvement vs Variance Ratio');
    grid on;
    set(gca, 'XScale', 'log');
    
    % Plot 3: AUC improvement vs variance ratio
    subplot(2, 3, 3);
    plot(variance_ratios, results.auc_improvement*100, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('Variance Ratio (σ_B/σ_A)');
    ylabel('AUC Improvement (%)');
    title('AUC Improvement vs Variance Ratio');
    grid on;
    set(gca, 'XScale', 'log');
    
    % Plot 4: Theory validation by scenario
    subplot(2, 3, 4);
    bar(1:length(results.theory_validated), double(results.theory_validated));
    xlabel('Scenario');
    ylabel('Theory Validated');
    title('Theory Validation by Scenario');
    set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.1f:1', x), variance_ratios, 'UniformOutput', false));
    ylim([0, 1.2]);
    
    % Plot 5: Comparison of improvements
    subplot(2, 3, 5);
    plot(variance_ratios, results.var_reduction*100, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
    hold on;
    plot(variance_ratios, results.auc_improvement*100, 'r-s', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('Variance Ratio (σ_B/σ_A)');
    ylabel('Improvement (%)');
    title('Variance vs AUC Improvement');
    legend('Variance Reduction', 'AUC Improvement', 'Location', 'best');
    grid on;
    set(gca, 'XScale', 'log');
    
    % Plot 6: Summary statistics
    subplot(2, 3, 6);
    stats = [mean(results.var_reduction)*100, mean(results.snr_improvement), mean(results.auc_improvement)*100, mean(results.theory_validated)*100];
    bar(stats);
    set(gca, 'XTickLabel', {'Var Reduction (%)', 'SNR Improvement (fold)', 'AUC Improvement (%)', 'Theory Validated (%)'});
    title('Average Performance Across Scenarios');
    ylabel('Value');
    grid on;
    
    sgtitle('Environmental Noise Cancellation: Unequal Variances Analysis', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    output_path = fullfile(project_root, 'outputs', 'corrected_validation_pipeline', 'unequal_variances_analysis.png');
    saveas(gcf, output_path);
    fprintf('  Visualizations saved to: %s\n', output_path);
end
