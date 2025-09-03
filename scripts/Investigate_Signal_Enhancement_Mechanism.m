%% ========================================================================
% INVESTIGATE SIGNAL ENHANCEMENT MECHANISM
% ========================================================================
% 
% This script investigates the theoretical foundation for why relative
% measures enhance discriminability when both teams are measured independently.
%
% Key Questions:
% 1. Why does R = X_A - X_B create better separation between winning/losing?
% 2. What is the theoretical mechanism behind signal enhancement?
% 3. How does this relate to the measurement model?
%
% Author: AI Assistant
% Date: 2024
% Purpose: Theoretical investigation of signal enhancement mechanism
%
% ========================================================================

clear; clc; close all;

fprintf('=== INVESTIGATING SIGNAL ENHANCEMENT MECHANISM ===\n');
fprintf('Analyzing why relative measures enhance discriminability...\n\n');

%% Step 1: Load Data and Analyze Measurement Structure
fprintf('STEP 1: Analyzing measurement structure...\n');
fprintf('==========================================\n');

try
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    file_path = fullfile(project_root, 'data', 'raw', 'Example_Formatted_Dataset.csv');
    data = readtable(file_path);
    fprintf('✓ Dataset loaded: %d rows, %d columns\n', height(data), width(data));
catch ME
    error('Failed to load dataset: %s', ME.message);
end

% Get unique teams
unique_teams = unique(data.Team);
fprintf('Teams: %s\n', strjoin(unique_teams, ', '));

% Analyze a specific metric (Carries)
metric = 'Carries';
team1_data = data(strcmp(data.Team, unique_teams{1}), metric);
team2_data = data(strcmp(data.Team, unique_teams{2}), metric);
team1_data = team1_data.(metric);
team2_data = team2_data.(metric);
team1_data = team1_data(~isnan(team1_data));
team2_data = team2_data(~isnan(team2_data));

fprintf('\nAnalyzing metric: %s\n', metric);
fprintf('Team 1 (%s): n=%d, mean=%.2f, std=%.2f\n', unique_teams{1}, length(team1_data), mean(team1_data), std(team1_data));
fprintf('Team 2 (%s): n=%d, mean=%.2f, std=%.2f\n', unique_teams{2}, length(team2_data), mean(team2_data), std(team2_data));

%% Step 2: Theoretical Analysis of Signal Enhancement
fprintf('\nSTEP 2: Theoretical analysis of signal enhancement...\n');
fprintf('==================================================\n');

% Calculate key statistics
mu_A = mean(team1_data);
mu_B = mean(team2_data);
sigma_A = std(team1_data);
sigma_B = std(team2_data);
r = sigma_B / sigma_A;

fprintf('\nKey Statistics:\n');
fprintf('  μ_A = %.2f, σ_A = %.2f\n', mu_A, sigma_A);
fprintf('  μ_B = %.2f, σ_B = %.2f\n', mu_B, sigma_B);
fprintf('  r = σ_B/σ_A = %.3f\n', r);

% Calculate SNR improvements
SNR_A = (mu_A - mu_B)^2 / (sigma_A^2 + sigma_B^2);
SNR_R = (mu_A - mu_B)^2 / (sigma_A^2 + sigma_B^2 - 2*sigma_A*sigma_B*0); % Assuming independence
SNR_improvement = SNR_R / SNR_A;

fprintf('\nSNR Analysis:\n');
fprintf('  SNR_A = %.4f\n', SNR_A);
fprintf('  SNR_R = %.4f\n', SNR_R);
fprintf('  SNR_R/SNR_A = %.4f\n', SNR_improvement);

%% Step 3: Investigate the Signal Enhancement Mechanism
fprintf('\nSTEP 3: Investigating signal enhancement mechanism...\n');
fprintf('====================================================\n');

% The key insight: Why does R = X_A - X_B enhance discriminability?
% Let's analyze this step by step

fprintf('\nSignal Enhancement Mechanism Analysis:\n');
fprintf('=====================================\n');

% 1. Absolute measure: X_A vs X_B (independent measurements)
fprintf('\n1. Absolute Measure (Independent):\n');
fprintf('   - We measure X_A and X_B independently\n');
fprintf('   - Each has its own variance: σ_A² and σ_B²\n');
fprintf('   - Total noise: σ_A² + σ_B² (assuming independence)\n');
fprintf('   - Signal: |μ_A - μ_B|\n');

% 2. Relative measure: R = X_A - X_B
fprintf('\n2. Relative Measure (Differential):\n');
fprintf('   - We measure R = X_A - X_B directly\n');
fprintf('   - Variance of R: σ_A² + σ_B² - 2*σ_A*σ_B*ρ\n');
fprintf('   - Signal: |μ_A - μ_B| (same as absolute)\n');

% 3. The key insight: Variance reduction
fprintf('\n3. Key Insight - Variance Reduction:\n');
fprintf('   - If ρ = 0 (independence): σ_R² = σ_A² + σ_B²\n');
fprintf('   - If ρ > 0 (positive correlation): σ_R² < σ_A² + σ_B²\n');
fprintf('   - If ρ < 0 (negative correlation): σ_R² > σ_A² + σ_B²\n');

% 4. Why this enhances discriminability
fprintf('\n4. Why This Enhances Discriminability:\n');
fprintf('   - SNR = Signal² / Noise\n');
fprintf('   - Signal remains the same: |μ_A - μ_B|\n');
fprintf('   - Noise can be reduced: σ_R² ≤ σ_A² + σ_B²\n');
fprintf('   - Therefore: SNR_R ≥ SNR_A\n');

%% Step 4: Empirical Validation of the Mechanism
fprintf('\nSTEP 4: Empirical validation of the mechanism...\n');
fprintf('==============================================\n');

% Calculate correlation between teams
if length(team1_data) == length(team2_data)
    correlation = corr(team1_data, team2_data);
    fprintf('\nEmpirical Correlation: ρ = %.4f\n', correlation);
    
    % Calculate actual variance of relative measure
    relative_data = team1_data - team2_data;
    sigma_R_empirical = std(relative_data);
    sigma_R_theoretical = sqrt(sigma_A^2 + sigma_B^2 - 2*sigma_A*sigma_B*correlation);
    
    fprintf('\nVariance Analysis:\n');
    fprintf('  σ_A² + σ_B² = %.2f\n', sigma_A^2 + sigma_B^2);
    fprintf('  σ_R² (theoretical) = %.2f\n', sigma_R_theoretical^2);
    fprintf('  σ_R² (empirical) = %.2f\n', sigma_R_empirical^2);
    fprintf('  Variance reduction: %.2f%%\n', (1 - sigma_R_empirical^2/(sigma_A^2 + sigma_B^2))*100);
    
    % Calculate empirical SNR
    SNR_R_empirical = (mean(relative_data))^2 / sigma_R_empirical^2;
    fprintf('\nEmpirical SNR Analysis:\n');
    fprintf('  SNR_A = %.4f\n', SNR_A);
    fprintf('  SNR_R (empirical) = %.4f\n', SNR_R_empirical);
    fprintf('  SNR improvement = %.2fx\n', SNR_R_empirical/SNR_A);
    
else
    fprintf('\nCannot calculate correlation - different sample sizes\n');
    fprintf('Team 1: %d samples, Team 2: %d samples\n', length(team1_data), length(team2_data));
end

%% Step 5: Theoretical Framework Development
fprintf('\nSTEP 5: Theoretical framework development...\n');
fprintf('==========================================\n');

fprintf('\nTheoretical Framework for Signal Enhancement:\n');
fprintf('============================================\n');

fprintf('\n1. Measurement Model:\n');
fprintf('   X_A = μ_A + ε_A\n');
fprintf('   X_B = μ_B + ε_B\n');
fprintf('   where ε_A ~ N(0, σ_A²), ε_B ~ N(0, σ_B²)\n');

fprintf('\n2. Absolute vs Relative Measures:\n');
fprintf('   Absolute: Compare X_A and X_B independently\n');
fprintf('   Relative: Compare R = X_A - X_B directly\n');

fprintf('\n3. Signal Enhancement Mechanism:\n');
fprintf('   - Signal: |μ_A - μ_B| (same for both)\n');
fprintf('   - Noise (Absolute): σ_A² + σ_B²\n');
fprintf('   - Noise (Relative): σ_A² + σ_B² - 2*σ_A*σ_B*ρ\n');
fprintf('   - Enhancement: When ρ > 0, noise is reduced\n');

fprintf('\n4. Why This Works:\n');
fprintf('   - Relative measures capture the difference directly\n');
fprintf('   - Common noise sources cancel out\n');
fprintf('   - Differential measurement reduces total variance\n');
fprintf('   - SNR = Signal²/Noise increases when noise decreases\n');

%% Step 6: Mathematical Derivation
fprintf('\nSTEP 6: Mathematical derivation...\n');
fprintf('=================================\n');

fprintf('\nMathematical Derivation of Signal Enhancement:\n');
fprintf('==============================================\n');

fprintf('\n1. Absolute Measure SNR:\n');
fprintf('   SNR_A = (μ_A - μ_B)² / (σ_A² + σ_B²)\n');

fprintf('\n2. Relative Measure SNR:\n');
fprintf('   SNR_R = (μ_A - μ_B)² / (σ_A² + σ_B² - 2*σ_A*σ_B*ρ)\n');

fprintf('\n3. SNR Improvement:\n');
fprintf('   SNR_R/SNR_A = (σ_A² + σ_B²) / (σ_A² + σ_B² - 2*σ_A*σ_B*ρ)\n');

fprintf('\n4. Special Case - Independence (ρ = 0):\n');
fprintf('   SNR_R/SNR_A = (σ_A² + σ_B²) / (σ_A² + σ_B²) = 1\n');
fprintf('   No improvement when teams are independent\n');

fprintf('\n5. Special Case - Perfect Correlation (ρ = 1):\n');
fprintf('   SNR_R/SNR_A = (σ_A² + σ_B²) / (σ_A² + σ_B² - 2*σ_A*σ_B)\n');
fprintf('   SNR_R/SNR_A = (σ_A² + σ_B²) / (σ_A - σ_B)²\n');
fprintf('   Maximum improvement when teams are perfectly correlated\n');

%% Step 7: Key Insights
fprintf('\nSTEP 7: Key insights...\n');
fprintf('=====================\n');

fprintf('\nKey Insights:\n');
fprintf('============\n');

fprintf('\n1. Signal Enhancement Requires Correlation:\n');
fprintf('   - If ρ = 0 (independence): No enhancement\n');
fprintf('   - If ρ > 0 (positive correlation): Enhancement occurs\n');
fprintf('   - If ρ < 0 (negative correlation): Degradation occurs\n');

fprintf('\n2. The Mechanism:\n');
fprintf('   - Relative measures reduce noise through correlation\n');
fprintf('   - Common noise sources cancel out in the difference\n');
fprintf('   - SNR improves because noise decreases\n');

fprintf('\n3. Why This Works for Rugby Data:\n');
fprintf('   - Teams may share common environmental factors\n');
fprintf('   - Positive correlation between team performances\n');
fprintf('   - Relative measures capture the differential performance\n');

fprintf('\n4. Theoretical Foundation:\n');
fprintf('   - Based on variance reduction through correlation\n');
fprintf('   - Mathematical framework is well-established\n');
fprintf('   - Applies to any differential measurement scenario\n');

%% Step 8: Validation with Multiple Metrics
fprintf('\nSTEP 8: Validation with multiple metrics...\n');
fprintf('==========================================\n');

metrics = {'Carries', 'Metres_Made', 'Defenders_Beaten', 'Offloads', 'Passes'};
fprintf('\nValidating mechanism across multiple metrics:\n');

for i = 1:length(metrics)
    metric = metrics{i};
    
    % Get team data
    team1_data = data(strcmp(data.Team, unique_teams{1}), metric);
    team2_data = data(strcmp(data.Team, unique_teams{2}), metric);
    team1_data = team1_data.(metric);
    team2_data = team2_data.(metric);
    team1_data = team1_data(~isnan(team1_data));
    team2_data = team2_data(~isnan(team2_data));
    
    if length(team1_data) == length(team2_data) && length(team1_data) > 3
        % Calculate correlation
        correlation = corr(team1_data, team2_data);
        
        % Calculate SNR improvement
        mu_A = mean(team1_data);
        mu_B = mean(team2_data);
        sigma_A = std(team1_data);
        sigma_B = std(team2_data);
        
        SNR_A = (mu_A - mu_B)^2 / (sigma_A^2 + sigma_B^2);
        SNR_R = (mu_A - mu_B)^2 / (sigma_A^2 + sigma_B^2 - 2*sigma_A*sigma_B*correlation);
        SNR_improvement = SNR_R / SNR_A;
        
        fprintf('  %s: ρ=%.3f, SNR improvement=%.2fx\n', metric, correlation, SNR_improvement);
    else
        fprintf('  %s: Cannot calculate (different sample sizes)\n', metric);
    end
end

fprintf('\n=== SIGNAL ENHANCEMENT MECHANISM INVESTIGATION COMPLETE ===\n');
