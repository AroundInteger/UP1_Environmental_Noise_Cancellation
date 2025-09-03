%% Visualize SNR Improvement Duality
% This script visualizes the profound duality between κ (global) and ρ (elemental)
% parameters in the SNR improvement mechanism

clear; clc; close all;

%% 1. Parameter Space Visualization
fprintf('🔬 SNR Improvement Duality Analysis\n');
fprintf('=====================================\n\n');

% Define parameter ranges
kappa_range = linspace(0.1, 4, 50);
rho_range = linspace(0, 0.9, 50);

% Create meshgrid
[KAPPA, RHO] = meshgrid(kappa_range, rho_range);

% Calculate SNR improvement
SNR_improvement = (1 + KAPPA) ./ (1 + KAPPA - 2*sqrt(KAPPA).*RHO);

%% 2. Create Comprehensive Visualization
figure('Position', [100, 100, 1200, 800]);

% Subplot 1: 3D Surface showing duality
subplot(2, 3, 1);
surf(KAPPA, RHO, SNR_improvement, 'EdgeAlpha', 0.3);
xlabel('κ (Global Distribution Parameter)');
ylabel('ρ (Elemental Interaction Parameter)');
zlabel('SNR Improvement');
title('SNR Improvement Duality');
colorbar;
view(45, 30);

% Subplot 2: Contour plot showing parameter roles
subplot(2, 3, 2);
contour(KAPPA, RHO, SNR_improvement, 20);
xlabel('κ (Global Distribution Parameter)');
ylabel('ρ (Elemental Interaction Parameter)');
title('Parameter Role Visualization');
colorbar;
grid on;

% Subplot 3: κ effect (global parameter)
subplot(2, 3, 3);
rho_fixed = 0.5;
kappa_effect = (1 + kappa_range) ./ (1 + kappa_range - 2*sqrt(kappa_range)*rho_fixed);
plot(kappa_range, kappa_effect, 'b-', 'LineWidth', 2);
xlabel('κ (Global Distribution Parameter)');
ylabel('SNR Improvement');
title(sprintf('Global Parameter Effect (ρ = %.1f)', rho_fixed));
grid on;

% Subplot 4: ρ effect (elemental parameter)
subplot(2, 3, 4);
kappa_fixed = 1.0;
rho_effect = (1 + kappa_fixed) ./ (1 + kappa_fixed - 2*sqrt(kappa_fixed)*rho_range);
plot(rho_range, rho_effect, 'r-', 'LineWidth', 2);
xlabel('ρ (Elemental Interaction Parameter)');
ylabel('SNR Improvement');
title(sprintf('Elemental Parameter Effect (κ = %.1f)', kappa_fixed));
grid on;

% Subplot 5: Interaction term visualization
subplot(2, 3, 5);
interaction_term = 2*sqrt(KAPPA).*RHO;
contour(KAPPA, RHO, interaction_term, 15);
xlabel('κ (Global Distribution Parameter)');
ylabel('ρ (Elemental Interaction Parameter)');
title('Interaction Term: 2√κρ');
colorbar;
grid on;

% Subplot 6: Parameter hierarchy visualization
subplot(2, 3, 6);
% Show how κ sets the ceiling and ρ determines realization
kappa_ceiling = 1 + kappa_range;
rho_realization = rho_range;
plot(kappa_range, kappa_ceiling, 'b-', 'LineWidth', 2, 'DisplayName', 'κ Ceiling');
hold on;
plot(rho_realization, 1 + rho_realization, 'r-', 'LineWidth', 2, 'DisplayName', 'ρ Realization');
xlabel('Parameter Value');
ylabel('Improvement Factor');
title('Parameter Hierarchy');
legend('Location', 'best');
grid on;

sgtitle('SNR Improvement Duality: Global vs Elemental Parameters', 'FontSize', 16, 'FontWeight', 'bold');

%% 3. Mathematical Analysis
fprintf('📊 Mathematical Analysis of Duality:\n');
fprintf('====================================\n\n');

fprintf('SNR Improvement Formula:\n');
fprintf('SNR_improvement = (1 + κ) / (1 + κ - 2√κρ)\n\n');

fprintf('Parameter Roles:\n');
fprintf('• κ (Global Distribution Parameter):\n');
fprintf('  - Definition: κ = σ²_B/σ²_A\n');
fprintf('  - Role: Sets baseline improvement potential\n');
fprintf('  - Scope: Global distribution property\n');
fprintf('  - Interpretation: Competitive asymmetry at system level\n\n');

fprintf('• ρ (Elemental Interaction Parameter):\n');
fprintf('  - Definition: ρ = Cov(X_A, X_B)/(σ_A σ_B)\n');
fprintf('  - Role: Determines realization of potential\n');
fprintf('  - Scope: Elemental interaction property\n');
fprintf('  - Interpretation: Element-level correlation structure\n\n');

%% 4. Duality Analysis
fprintf('🔍 Duality Analysis:\n');
fprintf('===================\n\n');

fprintf('1. Global vs Elemental Distinction:\n');
fprintf('   • κ operates at GLOBAL distribution level\n');
fprintf('   • ρ operates at ELEMENTAL interaction level\n');
fprintf('   • Together they create complete description\n\n');

fprintf('2. Mathematical Interaction:\n');
fprintf('   • κ sets theoretical ceiling\n');
fprintf('   • ρ determines actual realization\n');
fprintf('   • √κρ term shows their coupling\n\n');

fprintf('3. Parameter Hierarchy:\n');
fprintf('   • κ is higher-level distribution property\n');
fprintf('   • ρ is lower-level element property\n');
fprintf('   • Interaction occurs at mathematical level\n\n');

%% 5. Numerical Examples
fprintf('📈 Numerical Examples:\n');
fprintf('=====================\n\n');

% Example 1: Equal variances, high correlation
kappa1 = 1.0; rho1 = 0.8;
improvement1 = (1 + kappa1) / (1 + kappa1 - 2*sqrt(kappa1)*rho1);
fprintf('Example 1: κ = %.1f, ρ = %.1f\n', kappa1, rho1);
fprintf('  SNR Improvement = %.2f\n', improvement1);
fprintf('  κ contribution: %.2f (global ceiling)\n', 1 + kappa1);
fprintf('  ρ contribution: %.2f (elemental realization)\n', rho1);
fprintf('  Interaction: %.2f\n\n', 2*sqrt(kappa1)*rho1);

% Example 2: Unequal variances, moderate correlation
kappa2 = 2.0; rho2 = 0.5;
improvement2 = (1 + kappa2) / (1 + kappa2 - 2*sqrt(kappa2)*rho2);
fprintf('Example 2: κ = %.1f, ρ = %.1f\n', kappa2, rho2);
fprintf('  SNR Improvement = %.2f\n', improvement2);
fprintf('  κ contribution: %.2f (global ceiling)\n', 1 + kappa2);
fprintf('  ρ contribution: %.2f (elemental realization)\n', rho2);
fprintf('  Interaction: %.2f\n\n', 2*sqrt(kappa2)*rho2);

% Example 3: Extreme case
kappa3 = 0.1; rho3 = 0.9;
improvement3 = (1 + kappa3) / (1 + kappa3 - 2*sqrt(kappa3)*rho3);
fprintf('Example 3: κ = %.1f, ρ = %.1f (Extreme case)\n', kappa3, rho3);
fprintf('  SNR Improvement = %.2f\n', improvement3);
fprintf('  κ contribution: %.2f (global ceiling)\n', 1 + kappa3);
fprintf('  ρ contribution: %.2f (elemental realization)\n', rho3);
fprintf('  Interaction: %.2f\n\n', 2*sqrt(kappa3)*rho3);

%% 6. Save Results
fprintf('💾 Saving Results...\n');
saveas(gcf, 'outputs/snr_duality_analysis.png');
fprintf('   Saved: outputs/snr_duality_analysis.png\n\n');

%% 7. Summary
fprintf('🎯 Summary of Duality Insight:\n');
fprintf('=============================\n\n');
fprintf('The SNR improvement mechanism exhibits a profound duality:\n\n');
fprintf('• κ (Global Distribution Parameter):\n');
fprintf('  - Sets the theoretical ceiling for improvement\n');
fprintf('  - Operates at the system/distribution level\n');
fprintf('  - Determines baseline competitive asymmetry\n\n');
fprintf('• ρ (Elemental Interaction Parameter):\n');
fprintf('  - Determines realization of the ceiling\n');
fprintf('  - Operates at the element/interaction level\n');
fprintf('  - Captures specific correlation structure\n\n');
fprintf('• Mathematical Interaction:\n');
fprintf('  - √κρ term shows coupling between levels\n');
fprintf('  - Complete description requires both parameters\n');
fprintf('  - Elegant separation of global vs elemental effects\n\n');
fprintf('This duality reveals the deep mathematical structure underlying\n');
fprintf('competitive measurement and provides insight into how global\n');
fprintf('system properties and elemental interactions combine to create\n');
fprintf('emergent improvement effects.\n\n');

fprintf('✅ Analysis Complete!\n');
