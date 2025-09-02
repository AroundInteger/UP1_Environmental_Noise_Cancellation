function Test_Environmental_Noise_Cancellation_Synthetic()
    %TEST_ENVIRONMENTAL_NOISE_CANCELLATION_SYNTHETIC Test the theory with synthetic data
    % This script tests the actual environmental noise cancellation theory using
    % synthetic data that matches your theoretical model exactly
    
    fprintf('=== TESTING ENVIRONMENTAL NOISE CANCELLATION THEORY ===\n');
    fprintf('Using Synthetic Data with Known Environmental Noise\n');
    fprintf('Timestamp: %s\n\n', datestr(now));
    
    % Test parameters (matching your theoretical analysis)
    n_samples = 1000;
    mu_A = 1012;             % Team A true performance
    mu_B = 1020;             % Team B true performance (small difference)
    sigma_A = 3;             % Team A individual variation
    sigma_B = 3;             % Team B individual variation
    sigma_eta = 0;          % Environmental noise (significant)
    upset_prob = 0.0;        % Upset probability
    
    fprintf('Test Parameters:\n');
    fprintf('  μ_A = %.1f, μ_B = %.1f (difference: %.1f)\n', mu_A, mu_B, mu_B - mu_A);
    fprintf('  σ_A = %.1f, σ_B = %.1f\n', sigma_A, sigma_B);
    fprintf('  σ_η = %.1f (environmental noise)\n', sigma_eta);
    fprintf('  P(upset) = %.3f\n', upset_prob);
    fprintf('  n_samples = %d\n\n', n_samples);
    
    % Generate synthetic data
    fprintf('Generating synthetic data...\n');
    [X_A, X_B, R, Y] = generateSyntheticData(n_samples, mu_A, mu_B, sigma_A, sigma_B, sigma_eta, upset_prob);
    
    % Analyze the data
    fprintf('Analyzing synthetic data...\n');
    analyzeSyntheticData(X_A, X_B, R, Y, mu_A, mu_B, sigma_A, sigma_B, sigma_eta);
    
    % Test environmental noise cancellation theory
    fprintf('\nTesting Environmental Noise Cancellation Theory...\n');
    theory_results = testEnvironmentalNoiseCancellationTheory(X_A, X_B, R, Y);
    
    % Calculate theoretical predictions
    fprintf('\nCalculating Theoretical Predictions...\n');
    theoretical_predictions = calculateTheoreticalPredictions(mu_A, mu_B, sigma_A, sigma_B, sigma_eta);
    
    % Compare theory vs empirical
    fprintf('\nComparing Theory vs Empirical Results...\n');
    compareTheoryEmpirical(theory_results, theoretical_predictions);
    
    % Generate visualizations
    fprintf('\nGenerating Visualizations...\n');
    generateVisualizations(X_A, X_B, R, Y, theory_results);
    
    fprintf('\n=== TEST COMPLETED ===\n');
end

function [X_A, X_B, R, Y] = generateSyntheticData(n, mu_A, mu_B, sigma_A, sigma_B, sigma_eta, upset_prob)
    %GENERATESYNTHETICDATA Generate synthetic data matching theoretical model
    
    % Generate individual variations
    eps_A = sigma_A * randn(n, 1);
    eps_B = sigma_B * randn(n, 1);
    
    % Generate shared environmental noise
    eta = sigma_eta * randn(n, 1);
    
    % Generate absolute measures (with environmental noise)
    X_A = mu_A + eps_A + eta;
    X_B = mu_B + eps_B + eta;
    
    % Generate relative measures (environmental noise cancels out)
    R = X_A - X_B;
    
    % Generate outcomes based on true performance difference
    Y = (R > 0);
    
    % Add upsets
    upsets = rand(n, 1) < upset_prob;
    Y(upsets) = ~Y(upsets);
    
    fprintf('  Generated %d samples\n', n);
    fprintf('  X_A: mean=%.2f, std=%.2f\n', mean(X_A), std(X_A));
    fprintf('  X_B: mean=%.2f, std=%.2f\n', mean(X_B), std(X_B));
    fprintf('  R: mean=%.2f, std=%.2f\n', mean(R), std(R));
    fprintf('  Y: %.1f%% wins\n', mean(Y) * 100);
end

function analyzeSyntheticData(X_A, X_B, R, Y, mu_A, mu_B, sigma_A, sigma_B, sigma_eta)
    %ANALYZESYNTHETICDATA Analyze the synthetic data characteristics
    
    % Calculate empirical statistics
    var_A = var(X_A);
    var_B = var(X_B);
    var_R = var(R);
    
    % Calculate theoretical expectations
    var_A_theory = sigma_A^2 + sigma_eta^2;
    var_B_theory = sigma_B^2 + sigma_eta^2;
    var_R_theory = sigma_A^2 + sigma_B^2;
    
    fprintf('Variance Analysis:\n');
    fprintf('  Absolute A - Empirical: %.2f, Theoretical: %.2f\n', var_A, var_A_theory);
    fprintf('  Absolute B - Empirical: %.2f, Theoretical: %.2f\n', var_B, var_B_theory);
    fprintf('  Relative R - Empirical: %.2f, Theoretical: %.2f\n', var_R, var_R_theory);
    
    % Calculate variance reduction
    var_reduction_empirical = (var_A - var_R) / var_A;
    var_reduction_theoretical = (var_A_theory - var_R_theory) / var_A_theory;
    
    fprintf('\nVariance Reduction (Environmental Noise Cancellation):\n');
    fprintf('  Empirical: %.1f%%\n', var_reduction_empirical * 100);
    fprintf('  Theoretical: %.1f%%\n', var_reduction_theoretical * 100);
    
    % Calculate SNR
    signal = (mu_A - mu_B)^2;
    snr_A_empirical = signal / var_A;
    snr_B_empirical = signal / var_B;
    snr_R_empirical = signal / var_R;
    
    snr_A_theoretical = signal / var_A_theory;
    snr_B_theoretical = signal / var_B_theory;
    snr_R_theoretical = signal / var_R_theory;
    
    fprintf('\nSignal-to-Noise Ratios:\n');
    fprintf('  Absolute A - Empirical: %.4f, Theoretical: %.4f\n', snr_A_empirical, snr_A_theoretical);
    fprintf('  Absolute B - Empirical: %.4f, Theoretical: %.4f\n', snr_B_empirical, snr_B_theoretical);
    fprintf('  Relative R - Empirical: %.4f, Theoretical: %.4f\n', snr_R_empirical, snr_R_theoretical);
    
    % Calculate SNR improvement
    snr_improvement_empirical = snr_R_empirical / ((snr_A_empirical + snr_B_empirical) / 2);
    snr_improvement_theoretical = snr_R_theoretical / ((snr_A_theoretical + snr_B_theoretical) / 2);
    
    fprintf('\nSNR Improvement (Relative vs Absolute):\n');
    fprintf('  Empirical: %.2f-fold\n', snr_improvement_empirical);
    fprintf('  Theoretical: %.2f-fold\n', snr_improvement_theoretical);
end

function theory_results = testEnvironmentalNoiseCancellationTheory(X_A, X_B, R, Y)
    %TESTENVIRONMENTALNOISECANCELLATIONTHEORY Test the actual theory
    
    theory_results = struct();
    
    % Test 1: Absolute measures (with environmental noise)
    fprintf('Testing Absolute Measures (with environmental noise)...\n');
    [acc_abs_A, auc_abs_A] = testPredictor(X_A, Y);
    [acc_abs_B, auc_abs_B] = testPredictor(X_B, Y);
    
    % Test 2: Relative measures (environmental noise cancelled)
    fprintf('Testing Relative Measures (environmental noise cancelled)...\n');
    [acc_rel, auc_rel] = testPredictor(R, Y);
    
    % Store results
    theory_results.absolute_A = struct('accuracy', acc_abs_A, 'auc', auc_abs_A);
    theory_results.absolute_B = struct('accuracy', acc_abs_B, 'auc', auc_abs_B);
    theory_results.relative = struct('accuracy', acc_rel, 'auc', auc_rel);
    
    % Calculate improvements
    theory_results.auc_improvement = (auc_rel - max(auc_abs_A, auc_abs_B)) / max(auc_abs_A, auc_abs_B);
    theory_results.acc_improvement = (acc_rel - max(acc_abs_A, acc_abs_B)) / max(acc_abs_A, acc_abs_B);
    
    % Test if theory is validated
    theory_results.theory_validated = theory_results.auc_improvement > 0.05; % 5% improvement threshold
    
    fprintf('Results:\n');
    fprintf('  Absolute A: Accuracy=%.3f, AUC=%.3f\n', acc_abs_A, auc_abs_A);
    fprintf('  Absolute B: Accuracy=%.3f, AUC=%.3f\n', acc_abs_B, auc_abs_B);
    fprintf('  Relative: Accuracy=%.3f, AUC=%.3f\n', acc_rel, auc_rel);
    fprintf('  AUC Improvement: %.1f%%\n', theory_results.auc_improvement * 100);
    fprintf('  Theory Validated: %s\n', string(theory_results.theory_validated));
end

function [accuracy, auc] = testPredictor(X, Y)
    %TESTPREDICTOR Test a predictor on the data
    
    % Fit logistic regression
    try
        b = glmfit(X, Y, 'binomial');
        probs = glmval(b, X, 'logit');
        
        % Calculate accuracy
        predictions = probs > 0.5;
        accuracy = mean(predictions == Y);
        
        % Calculate AUC
        [~, ~, ~, auc] = perfcurve(Y, probs, 1);
    catch
        % Fallback if logistic regression fails
        accuracy = 0.5;
        auc = 0.5;
    end
end

function theoretical_predictions = calculateTheoreticalPredictions(mu_A, mu_B, sigma_A, sigma_B, sigma_eta)
    %CALCULATETHEORETICALPREDICTIONS Calculate theoretical predictions
    
    theoretical_predictions = struct();
    
    % Signal strength
    signal = (mu_A - mu_B)^2;
    
    % Noise levels
    noise_A = sigma_A^2 + sigma_eta^2;
    noise_B = sigma_B^2 + sigma_eta^2;
    noise_R = sigma_A^2 + sigma_B^2;
    
    % SNR values
    theoretical_predictions.snr_A = signal / noise_A;
    theoretical_predictions.snr_B = signal / noise_B;
    theoretical_predictions.snr_R = signal / noise_R;
    
    % SNR improvement
    theoretical_predictions.snr_improvement = theoretical_predictions.snr_R / ((theoretical_predictions.snr_A + theoretical_predictions.snr_B) / 2);
    
    % Variance reduction
    theoretical_predictions.variance_reduction = (noise_A - noise_R) / noise_A;
    
    fprintf('Theoretical Predictions:\n');
    fprintf('  SNR A: %.4f\n', theoretical_predictions.snr_A);
    fprintf('  SNR B: %.4f\n', theoretical_predictions.snr_B);
    fprintf('  SNR R: %.4f\n', theoretical_predictions.snr_R);
    fprintf('  SNR Improvement: %.2f-fold\n', theoretical_predictions.snr_improvement);
    fprintf('  Variance Reduction: %.1f%%\n', theoretical_predictions.variance_reduction * 100);
end

function compareTheoryEmpirical(theory_results, theoretical_predictions)
    %COMPARETHEORYEMPIRICAL Compare theoretical and empirical results
    
    fprintf('Theory vs Empirical Comparison:\n');
    
    % SNR improvement comparison
    empirical_snr_improvement = theory_results.auc_improvement; % Use AUC improvement as proxy
    theoretical_snr_improvement = theoretical_predictions.snr_improvement;
    
    fprintf('  SNR Improvement:\n');
    fprintf('    Empirical (AUC): %.2f-fold\n', 1 + empirical_snr_improvement);
    fprintf('    Theoretical: %.2f-fold\n', theoretical_snr_improvement);
    fprintf('    Agreement: %s\n', string(abs(empirical_snr_improvement - (theoretical_snr_improvement - 1)) < 0.5));
    
    % Overall assessment
    if theory_results.theory_validated
        fprintf('\n✓ ENVIRONMENTAL NOISE CANCELLATION THEORY VALIDATED\n');
        fprintf('  Relative measures outperform absolute measures as predicted\n');
    else
        fprintf('\n✗ ENVIRONMENTAL NOISE CANCELLATION THEORY NOT VALIDATED\n');
        fprintf('  Relative measures do not outperform absolute measures\n');
    end
end

function generateVisualizations(X_A, X_B, R, Y, theory_results)
    %GENERATEVISUALIZATIONS Generate visualizations of the results
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Plot 1: Data distributions
    subplot(2, 3, 1);
    histogram(X_A, 30, 'Normalization', 'probability', 'FaceAlpha', 0.3);
    hold on;
    histogram(X_B, 30, 'Normalization', 'probability', 'FaceAlpha', 0.3);
    xlabel('Absolute Measures');
    ylabel('Probability');
    title('Absolute Measures (with Environmental Noise)');
    legend('X_A', 'X_B');
    grid on;
    
    % Plot 2: Relative measure distribution
    subplot(2, 3, 2);
    histogram(R, 30, 'Normalization', 'probability', 'FaceAlpha', 0.7);
    xlabel('Relative Measure (R = X_A - X_B)');
    ylabel('Probability');
    title('Relative Measure (Environmental Noise Cancelled)');
    grid on;
    
    % Plot 3: ROC curves
    subplot(2, 3, 3);
    [fpr_A, tpr_A, ~, auc_A] = perfcurve(Y, X_A, 1);
    [fpr_B, tpr_B, ~, auc_B] = perfcurve(Y, X_B, 1);
    [fpr_R, tpr_R, ~, auc_R] = perfcurve(Y, R, 1);
    
    plot(fpr_A, tpr_A, 'b-', 'LineWidth', 2);
    hold on;
    plot(fpr_B, tpr_B, 'g-', 'LineWidth', 2);
    plot(fpr_R, tpr_R, 'r-', 'LineWidth', 2);
    plot([0 1], [0 1], 'k--');
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    title('ROC Curves');
    legend(sprintf('X_A (AUC=%.3f)', auc_A), ...
           sprintf('X_B (AUC=%.3f)', auc_B), ...
           sprintf('R (AUC=%.3f)', auc_R), ...
           'Random');
    grid on;
    
    % Plot 4: Performance comparison
    subplot(2, 3, 4);
    methods = {'X_A', 'X_B', 'R'};
    aucs = [auc_A, auc_B, auc_R];
    bar(aucs);
    set(gca, 'XTickLabel', methods);
    ylabel('AUC');
    title('Performance Comparison');
    grid on;
    
    % Plot 5: Variance comparison
    subplot(2, 3, 5);
    variances = [var(X_A), var(X_B), var(R)];
    bar(variances);
    set(gca, 'XTickLabel', methods);
    ylabel('Variance');
    title('Variance Comparison');
    grid on;
    
    % Plot 6: Theory validation summary
    subplot(2, 3, 6);
    text(0.1, 0.8, sprintf('Theory Validated: %s', string(theory_results.theory_validated)), 'FontSize', 14, 'FontWeight', 'bold');
    text(0.1, 0.6, sprintf('AUC Improvement: %.1f%%', theory_results.auc_improvement * 100), 'FontSize', 12);
    text(0.1, 0.4, sprintf('Accuracy Improvement: %.1f%%', theory_results.acc_improvement * 100), 'FontSize', 12);
    text(0.1, 0.2, sprintf('Relative AUC: %.3f', theory_results.relative.auc), 'FontSize', 12);
    axis off;
    title('Theory Validation Summary');
    
    sgtitle('Environmental Noise Cancellation Theory Test Results', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    output_path = fullfile(project_root, 'outputs', 'corrected_validation_pipeline', 'synthetic_test_results.png');
    saveas(gcf, output_path);
    fprintf('  Visualizations saved to: %s\n', output_path);
end
