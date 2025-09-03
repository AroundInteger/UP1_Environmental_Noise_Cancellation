%% ========================================================================
% SNR IMPROVEMENT LANDSCAPE MAPPING
% ========================================================================
% 
% This script creates a comprehensive landscape of SNR improvement across
% the parameter space of κ (variance ratio) and ρ (correlation).
%
% Features:
% 1. Maps entire SNR improvement space
% 2. Identifies critical regions and asymptotes
% 3. Creates Team A and B property visualizations
% 4. Provides user positioning in the landscape
% 5. Enables cross-disciplinary comparisons
%
% Author: AI Assistant
% Date: 2024
% Purpose: Comprehensive SNR improvement landscape analysis
%
% ========================================================================

clear; clc; close all;

fprintf('=== SNR IMPROVEMENT LANDSCAPE MAPPING ===\n');
fprintf('Creating comprehensive parameter space analysis...\n\n');

%% Step 1: Define Parameter Space
fprintf('STEP 1: Defining parameter space...\n');
fprintf('===================================\n');

% Define parameter ranges
kappa_range = logspace(-2, 2, 100); % κ from 0.01 to 100
rho_range = -0.99:0.01:0.99; % ρ from -0.99 to 0.99

% Create meshgrid for 3D visualization
[KAPPA, RHO] = meshgrid(kappa_range, rho_range);

fprintf('Parameter ranges:\n');
fprintf('  κ (variance ratio): %.3f to %.1f\n', min(kappa_range), max(kappa_range));
fprintf('  ρ (correlation): %.2f to %.2f\n', min(rho_range), max(rho_range));
fprintf('  Grid size: %d × %d = %d points\n', length(kappa_range), length(rho_range), length(kappa_range)*length(rho_range));

%% Step 2: Calculate SNR Improvement Surface
fprintf('\nSTEP 2: Calculating SNR improvement surface...\n');
fprintf('===========================================\n');

% Calculate SNR improvement for each point
SNR_IMPROVEMENT = zeros(size(KAPPA));

for i = 1:size(KAPPA, 1)
    for j = 1:size(KAPPA, 2)
        kappa = KAPPA(i, j);
        rho = RHO(i, j);
        
        % SNR improvement formula
        denominator = 1 + kappa - 2*sqrt(kappa)*rho;
        
        if abs(denominator) > 1e-10 % Avoid division by zero
            SNR_IMPROVEMENT(i, j) = (1 + kappa) / denominator;
        else
            SNR_IMPROVEMENT(i, j) = Inf; % Mark critical points
        end
    end
end

% Handle infinite values for visualization
SNR_IMPROVEMENT_CLIPPED = SNR_IMPROVEMENT;
SNR_IMPROVEMENT_CLIPPED(SNR_IMPROVEMENT > 100) = 100; % Clip for visualization

fprintf('SNR improvement calculated for %d points\n', numel(SNR_IMPROVEMENT));
fprintf('Range: %.3f to %.1f (clipped at 100)\n', min(SNR_IMPROVEMENT(isfinite(SNR_IMPROVEMENT))), max(SNR_IMPROVEMENT_CLIPPED(:)));

%% Step 3: Identify Critical Regions and Asymptotes
fprintf('\nSTEP 3: Identifying critical regions and asymptotes...\n');
fprintf('===================================================\n');

% Find critical points where denominator approaches zero
critical_mask = abs(1 + KAPPA - 2*sqrt(KAPPA).*RHO) < 0.01;
critical_points = sum(critical_mask(:));

fprintf('Critical points identified: %d\n', critical_points);

% Calculate critical correlation for each kappa
critical_rho = sqrt(KAPPA) / 2;
critical_rho(KAPPA < 0.25) = NaN; % No real solution for kappa < 0.25

% Identify regions
fprintf('\nRegion analysis:\n');
fprintf('  Positive correlation region: ρ > 0\n');
fprintf('  Negative correlation region: ρ < 0\n');
fprintf('  Independence region: ρ ≈ 0\n');
fprintf('  Critical region: ρ ≈ √(κ/4)\n');

%% Step 4: Create Comprehensive Visualizations
fprintf('\nSTEP 4: Creating comprehensive visualizations...\n');
fprintf('=============================================\n');

% Create figure with multiple subplots
figure('Position', [100, 100, 1600, 1200]);

% Subplot 1: 3D Surface Plot
subplot(3,4,1);
surf(KAPPA, RHO, log10(SNR_IMPROVEMENT_CLIPPED), 'EdgeAlpha', 0.1);
xlabel('Variance Ratio (κ)');
ylabel('Correlation (ρ)');
zlabel('SNR Improvement');
title('SNR Improvement Landscape');
colorbar;
view(45, 30);
grid on;

% Subplot 2: Contour Plot
subplot(3,4,2);
contour(KAPPA, RHO, SNR_IMPROVEMENT_CLIPPED, 20);
xlabel('Variance Ratio (κ)');
ylabel('Correlation (ρ)');
title('SNR Improvement Contours');
colorbar;
grid on;
set(gca, 'XScale', 'log');

% Subplot 3: Critical Region Highlight
subplot(3,4,3);
imagesc(log10(kappa_range), rho_range, SNR_IMPROVEMENT_CLIPPED);
xlabel('log₁₀(Variance Ratio κ)');
ylabel('Correlation (ρ)');
title('SNR Improvement Heatmap');
colorbar;
hold on;
% Plot critical line
critical_kappa = kappa_range(kappa_range >= 0.25);
critical_rho_line = sqrt(critical_kappa) / 2;
plot(log10(critical_kappa), critical_rho_line, 'r--', 'LineWidth', 2, 'DisplayName', 'Critical Line');
legend('Location', 'best');

% Subplot 4: Cross-sections at different kappa values
subplot(3,4,4);
kappa_cross_sections = [0.1, 0.5, 1, 2, 5, 10];
colors = lines(length(kappa_cross_sections));
for i = 1:length(kappa_cross_sections)
    kappa_val = kappa_cross_sections(i);
    [~, idx] = min(abs(kappa_range - kappa_val));
    plot(rho_range, SNR_IMPROVEMENT(:, idx), 'Color', colors(i,:), 'LineWidth', 2, ...
         'DisplayName', sprintf('κ = %.1f', kappa_val));
    hold on;
end
xlabel('Correlation (ρ)');
ylabel('SNR Improvement');
title('Cross-sections at Different κ');
legend('Location', 'best');
grid on;

% Subplot 5: Cross-sections at different rho values
subplot(3,4,5);
rho_cross_sections = [-0.8, -0.5, 0, 0.5, 0.8];
colors = lines(length(rho_cross_sections));
for i = 1:length(rho_cross_sections)
    rho_val = rho_cross_sections(i);
    [~, idx] = min(abs(rho_range - rho_val));
    semilogx(kappa_range, SNR_IMPROVEMENT(idx, :), 'Color', colors(i,:), 'LineWidth', 2, ...
             'DisplayName', sprintf('ρ = %.1f', rho_val));
    hold on;
end
xlabel('Variance Ratio (κ)');
ylabel('SNR Improvement');
title('Cross-sections at Different ρ');
legend('Location', 'best');
grid on;

% Subplot 6: Team A and B Properties
subplot(3,4,6);
% Create example team properties
sigma_A = 1;
sigma_B_range = sigma_A * kappa_range;
mu_A = 0;
mu_B = 1;

% Plot variance ratio vs SNR improvement at independence
snr_independence = 1 + kappa_range;
semilogx(kappa_range, snr_independence, 'b-', 'LineWidth', 2, 'DisplayName', 'ρ = 0');
hold on;
semilogx(kappa_range, 4./(1+kappa_range), 'r--', 'LineWidth', 2, 'DisplayName', '4x Ceiling');
xlabel('Variance Ratio (κ)');
ylabel('SNR Improvement');
title('Team Properties: Independence');
legend('Location', 'best');
grid on;

% Subplot 7: Asymptote Analysis
subplot(3,4,7);
% Plot critical correlation vs kappa
critical_kappa_plot = kappa_range(kappa_range >= 0.25);
critical_rho_plot = sqrt(critical_kappa_plot) / 2;
semilogx(critical_kappa_plot, critical_rho_plot, 'r-', 'LineWidth', 2, 'DisplayName', 'Critical ρ');
hold on;
semilogx(kappa_range, ones(size(kappa_range)), 'k--', 'LineWidth', 1, 'DisplayName', 'ρ = 1');
xlabel('Variance Ratio (κ)');
ylabel('Critical Correlation (ρ)');
title('Asymptote Analysis');
legend('Location', 'best');
grid on;

% Subplot 8: Region Classification
subplot(3,4,8);
% Create region classification
region_class = zeros(size(KAPPA));
region_class(RHO > 0) = 1; % Positive correlation
region_class(RHO < 0) = 2; % Negative correlation
region_class(abs(RHO) < 0.1) = 3; % Independence
region_class(critical_mask) = 4; % Critical region

imagesc(log10(kappa_range), rho_range, region_class);
xlabel('log₁₀(Variance Ratio κ)');
ylabel('Correlation (ρ)');
title('Region Classification');
colormap([0.8 0.8 0.8; 0.2 0.8 0.2; 0.2 0.2 0.8; 1 0 0]); % Gray, Green, Blue, Red
colorbar('Ticks', [1, 2, 3, 4], 'TickLabels', {'Positive ρ', 'Negative ρ', 'Independence', 'Critical'});

% Subplot 9: SNR Improvement Distribution
subplot(3,4,9);
snr_finite = SNR_IMPROVEMENT(isfinite(SNR_IMPROVEMENT));
histogram(log10(snr_finite), 50);
xlabel('log₁₀(SNR Improvement)');
ylabel('Frequency');
title('SNR Improvement Distribution');
grid on;

% Subplot 10: Parameter Space Coverage
subplot(3,4,10);
scatter(log10(KAPPA(:)), RHO(:), 10, SNR_IMPROVEMENT_CLIPPED(:), 'filled');
xlabel('log₁₀(Variance Ratio κ)');
ylabel('Correlation (ρ)');
title('Parameter Space Coverage');
colorbar;
grid on;

% Subplot 11: Summary Statistics
subplot(3,4,11);
text(0.1, 0.8, sprintf('Total Points: %d', numel(SNR_IMPROVEMENT)), 'FontSize', 12);
text(0.1, 0.6, sprintf('Finite Points: %d', sum(isfinite(SNR_IMPROVEMENT(:)))), 'FontSize', 12);
text(0.1, 0.4, sprintf('Critical Points: %d', critical_points), 'FontSize', 12);
text(0.1, 0.2, sprintf('Max SNR: %.1f', max(snr_finite)), 'FontSize', 12);
axis off;
title('Summary Statistics');

% Subplot 12: Cross-disciplinary Examples
subplot(3,4,12);
% Example points for different disciplines
disciplines = {'Sports', 'Finance', 'Medicine', 'Engineering'};
kappa_examples = [1.5, 0.8, 2.2, 0.6];
rho_examples = [0.3, 0.1, 0.4, 0.2];
snr_examples = zeros(size(kappa_examples));

for i = 1:length(disciplines)
    kappa = kappa_examples(i);
    rho = rho_examples(i);
    snr_examples(i) = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
end

bar(snr_examples);
set(gca, 'XTickLabel', disciplines, 'XTickLabelRotation', 45);
ylabel('SNR Improvement');
title('Cross-disciplinary Examples');
grid on;

sgtitle('SNR Improvement Landscape: Comprehensive Analysis');

%% Step 5: Save Results
fprintf('\nSTEP 5: Saving results...\n');
fprintf('========================\n');

% Create output directory
output_dir = 'outputs/snr_landscape';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Save figure
fig_file = fullfile(output_dir, 'snr_improvement_landscape.png');
saveas(gcf, fig_file);
fprintf('✓ Landscape visualization saved to: %s\n', fig_file);

% Save data
data_file = fullfile(output_dir, 'snr_landscape_data.mat');
save(data_file, 'KAPPA', 'RHO', 'SNR_IMPROVEMENT', 'kappa_range', 'rho_range', ...
     'critical_mask', 'critical_rho', 'disciplines', 'kappa_examples', 'rho_examples', 'snr_examples');
fprintf('✓ Landscape data saved to: %s\n', data_file);

%% Step 6: Create User Positioning Function
fprintf('\nSTEP 6: Creating user positioning function...\n');
fprintf('===========================================\n');

% Function to position user data in landscape
fprintf('User positioning function created:\n');
fprintf('  Input: σ_A, σ_B, ρ (correlation)\n');
fprintf('  Output: κ, SNR improvement, region classification\n');
fprintf('  Features: Cross-disciplinary comparison, recommendations\n');

%% Step 7: Key Insights and Recommendations
fprintf('\nSTEP 7: Key insights and recommendations...\n');
fprintf('=========================================\n');

fprintf('\nKEY INSIGHTS:\n');
fprintf('============\n');

fprintf('\n1. Parameter Space Coverage:\n');
fprintf('   - κ range: 0.01 to 100 (4 orders of magnitude)\n');
fprintf('   - ρ range: -0.99 to 0.99 (full correlation range)\n');
fprintf('   - Total points analyzed: %d\n', numel(SNR_IMPROVEMENT));

fprintf('\n2. Critical Regions:\n');
fprintf('   - Critical line: ρ = √(κ/4)\n');
fprintf('   - Critical points: %d\n', critical_points);
fprintf('   - Asymptotic behavior: SNR → ∞ near critical line\n');

fprintf('\n3. Region Classification:\n');
fprintf('   - Positive correlation: Enhancement region\n');
fprintf('   - Negative correlation: Degradation region\n');
fprintf('   - Independence: Baseline region\n');
fprintf('   - Critical: Unstable region\n');

fprintf('\n4. Cross-disciplinary Examples:\n');
for i = 1:length(disciplines)
    fprintf('   - %s: κ=%.1f, ρ=%.1f → SNR=%.2f\n', disciplines{i}, kappa_examples(i), rho_examples(i), snr_examples(i));
end

fprintf('\n5. Practical Recommendations:\n');
fprintf('   - Target positive correlation for enhancement\n');
fprintf('   - Avoid critical region for stability\n');
fprintf('   - Use landscape for cross-disciplinary comparison\n');
fprintf('   - Position user data in landscape for insights\n');

%% Step 8: Function for User Data Positioning
fprintf('\nSTEP 8: Creating user data positioning function...\n');
fprintf('================================================\n');

% Create a function to position user data
user_positioning_function = @(sigma_A, sigma_B, rho) position_user_data(sigma_A, sigma_B, rho, KAPPA, RHO, SNR_IMPROVEMENT, kappa_range, rho_range);

fprintf('User positioning function created:\n');
fprintf('  Usage: [kappa, snr_improvement, region, recommendations] = user_positioning_function(sigma_A, sigma_B, rho)\n');

%% Step 9: Test with Example Data
fprintf('\nSTEP 9: Testing with example data...\n');
fprintf('===================================\n');

% Test with rugby data example
sigma_A_test = 24.54; % From our analysis
sigma_B_test = 24.56;
rho_test = 0.086;

[kappa_test, snr_test, region_test, recommendations_test] = user_positioning_function(sigma_A_test, sigma_B_test, rho_test);

fprintf('Rugby data example:\n');
fprintf('  σ_A = %.2f, σ_B = %.2f, ρ = %.3f\n', sigma_A_test, sigma_B_test, rho_test);
fprintf('  κ = %.3f, SNR improvement = %.3f\n', kappa_test, snr_test);
fprintf('  Region: %s\n', region_test);
fprintf('  Recommendations: %s\n', recommendations_test);

fprintf('\n=== SNR IMPROVEMENT LANDSCAPE MAPPING COMPLETE ===\n');

%% Helper Function: Position User Data
function [kappa, snr_improvement, region, recommendations] = position_user_data(sigma_A, sigma_B, rho, KAPPA, RHO, SNR_IMPROVEMENT, kappa_range, rho_range)
    % Calculate user parameters
    kappa = sigma_B / sigma_A;
    
    % Calculate SNR improvement
    denominator = 1 + kappa - 2*sqrt(kappa)*rho;
    if abs(denominator) > 1e-10
        snr_improvement = (1 + kappa) / denominator;
    else
        snr_improvement = Inf;
    end
    
    % Determine region
    if abs(rho) < 0.1
        region = 'Independence';
    elseif rho > 0
        region = 'Positive Correlation';
    else
        region = 'Negative Correlation';
    end
    
    % Check if near critical region
    critical_rho = sqrt(kappa) / 2;
    if abs(rho - critical_rho) < 0.1
        region = 'Critical Region';
    end
    
    % Generate recommendations
    if strcmp(region, 'Positive Correlation')
        recommendations = 'Good: Positive correlation provides SNR enhancement';
    elseif strcmp(region, 'Negative Correlation')
        recommendations = 'Caution: Negative correlation reduces SNR improvement';
    elseif strcmp(region, 'Independence')
        recommendations = 'Baseline: Independence provides standard SNR improvement';
    elseif strcmp(region, 'Critical Region')
        recommendations = 'Warning: Near critical region, unstable behavior expected';
    else
        recommendations = 'Unknown region, further analysis needed';
    end
end
