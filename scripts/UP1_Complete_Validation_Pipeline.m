%% UP1 Complete Validation Pipeline: From Raw PI Data to Conclusions
% Systematic assessment of Environmental Noise Cancellation theory
% 
% This script implements the complete validation workflow:
% 1. Input PI data for multiple seasons
% 2. Process PI data for standardisation
% 3. Check normality of all PI distributions -> re-classify as NPIs
% 4. Check NPIs against 4-axioms -> re-classify as ANPIs
% 5. Assess true distributional behaviour of ANPIs
% 6. Investigate empirical relativisation/SNR for all ANPIs
% 7. Reach conclusions
%
% Author: UP1 Research Team
% Date: 2024
% Version: 1.0

clear; close all; clc;

fprintf('=== UP1 COMPLETE VALIDATION PIPELINE ===\n');
fprintf('Systematic assessment of Environmental Noise Cancellation theory\n');
fprintf('Timestamp: %s\n\n', datestr(now));

%% Configuration
config = struct();
config.random_seed = 42;
config.confidence_level = 0.95;
config.normality_threshold = 0.90;  % Q-Q correlation threshold for normality
config.axiom_threshold = 0.80;      % Axiom adherence threshold
config.cv_folds = 10;
config.bootstrap_samples = 1000;

% Set random seed for reproducibility
rng(config.random_seed);

%% Step 1: Input PI Data for Multiple Seasons
fprintf('STEP 1: Loading PI data for multiple seasons...\n');

% Set up working directory
script_dir = fileparts(mfilename('fullpath'));
project_root = fullfile(script_dir, '..');
cd(project_root);
fprintf('✓ Working directory: %s\n', pwd);

% Load rugby data
data_file = 'data/processed/rugby_analysis_ready.csv';
if exist(data_file, 'file')
    raw_data = readtable(data_file);
    fprintf('✓ Loaded rugby data: %dx%d\n', size(raw_data, 1), size(raw_data, 2));
else
    error('Data file not found: %s', data_file);
end

% Extract PI data (Performance Indicators)
pi_data = extractPIData(raw_data);
fprintf('✓ Extracted %d PIs from %d matches\n', length(pi_data.pi_names), pi_data.n_matches);

%% Step 2: Process PI Data for Standardisation
fprintf('\nSTEP 2: Processing PI data for standardisation...\n');

standardised_data = standardisePIData(pi_data);
fprintf('✓ Standardised %d PIs\n', length(standardised_data.pi_names));
fprintf('✓ Data quality: %.1f%% retention\n', standardised_data.quality_retention * 100);

%% Step 3: Check Normality of All PI Distributions -> Re-classify as NPIs
fprintf('\nSTEP 3: Checking normality of all PI distributions...\n');

normality_results = assessNormality(standardised_data, config.normality_threshold);
npi_data = classifyAsNPIs(standardised_data, normality_results);

fprintf('✓ Normality assessment completed\n');
fprintf('  - Total PIs: %d\n', length(standardised_data.pi_names));
fprintf('  - Classified as NPIs: %d\n', length(npi_data.npi_names));
fprintf('  - Normality rate: %.1f%%\n', length(npi_data.npi_names) / length(standardised_data.pi_names) * 100);

%% Step 3.5: Analyze NPIs - Means and Variances for Pipeline Decisions
fprintf('\nSTEP 3.5: Analyzing NPIs - means and variances for pipeline decisions...\n');

npi_analysis = analyzeNPIDistributions(npi_data);
fprintf('✓ NPI distribution analysis completed\n');
fprintf('  - Mean absolute variance: %.3f\n', npi_analysis.mean_absolute_variance);
fprintf('  - Mean relative variance: %.3f\n', npi_analysis.mean_relative_variance);
fprintf('  - Mean variance reduction: %.1f%%\n', npi_analysis.mean_variance_reduction * 100);
fprintf('  - Environmental noise estimate: %.3f\n', npi_analysis.environmental_noise_estimate);

% Make pipeline decisions based on NPI analysis
pipeline_decisions = makePipelineDecisions(npi_analysis, config);
fprintf('✓ Pipeline decisions made:\n');
fprintf('  - Axiom threshold adjusted to: %.1f%%\n', pipeline_decisions.adjusted_axiom_threshold * 100);
fprintf('  - Continue with axiom validation: %s\n', string(pipeline_decisions.continue_with_axioms));
fprintf('  - Recommended approach: %s\n', pipeline_decisions.recommended_approach);

%% Step 4: Check NPIs Against 4-Axioms -> Re-classify as ANPIs
fprintf('\nSTEP 4: Checking NPIs against 4-axioms...\n');

axiom_results = validateFourAxioms(npi_data, pipeline_decisions.adjusted_axiom_threshold);
anpi_data = classifyAsANPIs(npi_data, axiom_results);

fprintf('✓ Four-axiom validation completed\n');
fprintf('  - Total NPIs: %d\n', length(npi_data.npi_names));
fprintf('  - Classified as ANPIs: %d\n', length(anpi_data.anpi_names));
fprintf('  - Axiom adherence rate: %.1f%%\n', length(anpi_data.anpi_names) / length(npi_data.npi_names) * 100);

%% Step 5: Assess True Distributional Behaviour of ANPIs
fprintf('\nSTEP 5: Assessing true distributional behaviour of ANPIs...\n');

distributional_analysis = analyzeDistributionalBehaviour(anpi_data);
fprintf('✓ Distributional analysis completed for %d ANPIs\n', length(anpi_data.anpi_names));

%% Step 6: Investigate Empirical Relativisation/SNR for All ANPIs
fprintf('\nSTEP 6: Investigating empirical relativisation/SNR for all ANPIs...\n');

snr_analysis = investigateEmpiricalSNR(anpi_data, config);
fprintf('✓ SNR analysis completed\n');
fprintf('  - Mean empirical SNR improvement: %.1f%%\n', snr_analysis.mean_empirical_improvement);
fprintf('  - Mean theoretical SNR improvement: %.1f%%\n', snr_analysis.mean_theoretical_improvement);
fprintf('  - Theory-empirical correlation: %.3f\n', snr_analysis.correlation);

%% Step 7: Reach Conclusions
fprintf('\nSTEP 7: Reaching conclusions...\n');

conclusions = reachConclusions(pi_data, standardised_data, npi_data, npi_analysis, pipeline_decisions, anpi_data, distributional_analysis, snr_analysis, config);
fprintf('✓ Conclusions reached\n');

%% Generate Comprehensive Report
fprintf('\n=== GENERATING COMPREHENSIVE REPORT ===\n');

generateComprehensiveReport(pi_data, npi_data, anpi_data, distributional_analysis, snr_analysis, conclusions, config);

fprintf('\n=== PIPELINE COMPLETED SUCCESSFULLY ===\n');
fprintf('All steps completed. Results saved to outputs/validation_pipeline/\n');

%% HELPER FUNCTIONS

function pi_data = extractPIData(raw_data)
    %EXTRACTPIDATA Extract Performance Indicator data from raw dataset
    
    pi_data = struct();
    
    % Get variable names
    var_names = raw_data.Properties.VariableNames;
    
    % Find PI columns (absolute and relative)
    abs_cols = var_names(contains(var_names, 'abs_'));
    rel_cols = var_names(contains(var_names, 'rel_'));
    
    % Extract base PI names
    pi_names = {};
    for i = 1:length(abs_cols)
        col_name = abs_cols{i};
        base_name = strrep(col_name, 'abs_', '');
        if any(contains(rel_cols, ['rel_' base_name]))
            pi_names{end+1} = base_name;
        end
    end
    
    pi_data.pi_names = pi_names;
    pi_data.n_matches = height(raw_data);
    
    % Extract absolute and relative data
    pi_data.absolute_data = zeros(pi_data.n_matches, length(pi_names));
    pi_data.relative_data = zeros(pi_data.n_matches, length(pi_names));
    
    for i = 1:length(pi_names)
        pi_name = pi_names{i};
        abs_col = ['abs_' pi_name];
        rel_col = ['rel_' pi_name];
        
        if ismember(abs_col, var_names) && ismember(rel_col, var_names)
            pi_data.absolute_data(:, i) = raw_data.(abs_col);
            pi_data.relative_data(:, i) = raw_data.(rel_col);
        end
    end
    
    % Extract outcomes
    if ismember('outcome_binary', var_names)
        pi_data.outcomes = raw_data.outcome_binary;
    else
        pi_data.outcomes = ones(pi_data.n_matches, 1); % Default
    end
    
    fprintf('  Extracted %d PIs: %s\n', length(pi_names), strjoin(pi_names(1:min(5, end)), ', '));
    if length(pi_names) > 5
        fprintf('  ... and %d more\n', length(pi_names) - 5);
    end
end

function standardised_data = standardisePIData(pi_data)
    %STANDARDISEPIDATA Standardise PI data for analysis
    
    standardised_data = struct();
    standardised_data.pi_names = pi_data.pi_names;
    standardised_data.n_matches = pi_data.n_matches;
    standardised_data.outcomes = pi_data.outcomes;
    
    % Standardise absolute data
    standardised_data.absolute_data = zeros(size(pi_data.absolute_data));
    standardised_data.relative_data = zeros(size(pi_data.relative_data));
    
    n_valid = 0;
    total_pis = length(pi_data.pi_names);
    
    for i = 1:total_pis
        abs_data = pi_data.absolute_data(:, i);
        rel_data = pi_data.relative_data(:, i);
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data);
        
        if sum(valid_idx) > 10 % Need sufficient data
            n_valid = n_valid + 1;
            
            % Standardise (z-score)
            abs_clean = abs_data(valid_idx);
            rel_clean = rel_data(valid_idx);
            
            standardised_data.absolute_data(valid_idx, n_valid) = (abs_clean - mean(abs_clean)) / std(abs_clean);
            standardised_data.relative_data(valid_idx, n_valid) = (rel_clean - mean(rel_clean)) / std(rel_clean);
        end
    end
    
    % Trim to valid PIs
    standardised_data.absolute_data = standardised_data.absolute_data(:, 1:n_valid);
    standardised_data.relative_data = standardised_data.relative_data(:, 1:n_valid);
    standardised_data.pi_names = standardised_data.pi_names(1:n_valid);
    
    standardised_data.quality_retention = n_valid / total_pis;
    
    fprintf('  Standardised %d PIs (%.1f%% retention)\n', n_valid, standardised_data.quality_retention * 100);
end

function normality_results = assessNormality(standardised_data, threshold)
    %ASSESSNORMALITY Assess normality of all PI distributions
    
    normality_results = struct();
    normality_results.pi_names = standardised_data.pi_names;
    normality_results.n_pis = length(standardised_data.pi_names);
    
    % Initialize results
    normality_results.absolute_normality = zeros(normality_results.n_pis, 1);
    normality_results.relative_normality = zeros(normality_results.n_pis, 1);
    normality_results.absolute_qq_corr = zeros(normality_results.n_pis, 1);
    normality_results.relative_qq_corr = zeros(normality_results.n_pis, 1);
    normality_results.absolute_skewness = zeros(normality_results.n_pis, 1);
    normality_results.relative_skewness = zeros(normality_results.n_pis, 1);
    normality_results.absolute_kurtosis = zeros(normality_results.n_pis, 1);
    normality_results.relative_kurtosis = zeros(normality_results.n_pis, 1);
    
    for i = 1:normality_results.n_pis
        abs_data = standardised_data.absolute_data(:, i);
        rel_data = standardised_data.relative_data(:, i);
        
        % Remove NaN values
        abs_clean = abs_data(~isnan(abs_data));
        rel_clean = rel_data(~isnan(rel_data));
        
        if length(abs_clean) > 10 && length(rel_clean) > 10
            % Q-Q correlation for normality assessment
            abs_qq_corr = calculateQQCorrelation(abs_clean);
            rel_qq_corr = calculateQQCorrelation(rel_clean);
            
            normality_results.absolute_qq_corr(i) = abs_qq_corr;
            normality_results.relative_qq_corr(i) = rel_qq_corr;
            
            % Normality classification
            normality_results.absolute_normality(i) = abs_qq_corr >= threshold;
            normality_results.relative_normality(i) = rel_qq_corr >= threshold;
            
            % Shape characteristics
            normality_results.absolute_skewness(i) = skewness(abs_clean);
            normality_results.relative_skewness(i) = skewness(rel_clean);
            normality_results.absolute_kurtosis(i) = kurtosis(abs_clean);
            normality_results.relative_kurtosis(i) = kurtosis(rel_clean);
        end
    end
    
    % Overall normality assessment
    normality_results.absolute_normality_rate = mean(normality_results.absolute_normality);
    normality_results.relative_normality_rate = mean(normality_results.relative_normality);
    
    fprintf('  Absolute data normality rate: %.1f%%\n', normality_results.absolute_normality_rate * 100);
    fprintf('  Relative data normality rate: %.1f%%\n', normality_results.relative_normality_rate * 100);
end

function qq_corr = calculateQQCorrelation(data)
    %CALCULATEQQCORRELATION Calculate Q-Q plot correlation for normality assessment
    
    if length(data) < 3
        qq_corr = NaN;
        return;
    end
    
    % Sort data
    sorted_data = sort(data);
    n = length(sorted_data);
    
    % Theoretical quantiles
    theoretical_quantiles = norminv((1:n) / (n + 1));
    
    % Empirical quantiles (standardised)
    empirical_quantiles = (sorted_data - mean(sorted_data)) / std(sorted_data);
    
    % Ensure both vectors are column vectors for correlation
    if size(theoretical_quantiles, 1) == 1
        theoretical_quantiles = theoretical_quantiles';
    end
    if size(empirical_quantiles, 1) == 1
        empirical_quantiles = empirical_quantiles';
    end
    
    % Calculate correlation
    qq_corr = corr(theoretical_quantiles, empirical_quantiles);
end

function npi_data = classifyAsNPIs(standardised_data, normality_results)
    %CLASSIFYASNPIS Classify PIs as NPIs based on normality assessment
    
    npi_data = struct();
    
    % Find PIs that meet normality criteria
    normal_pis = normality_results.absolute_normality & normality_results.relative_normality;
    npi_indices = find(normal_pis);
    
    npi_data.npi_names = standardised_data.pi_names(npi_indices);
    npi_data.n_pis = length(npi_indices);
    npi_data.n_matches = standardised_data.n_matches;
    npi_data.outcomes = standardised_data.outcomes;
    
    % Extract data for NPIs
    npi_data.absolute_data = standardised_data.absolute_data(:, npi_indices);
    npi_data.relative_data = standardised_data.relative_data(:, npi_indices);
    
    % Store normality characteristics
    npi_data.normality_characteristics = struct();
    npi_data.normality_characteristics.absolute_qq_corr = normality_results.absolute_qq_corr(npi_indices);
    npi_data.normality_characteristics.relative_qq_corr = normality_results.relative_qq_corr(npi_indices);
    npi_data.normality_characteristics.absolute_skewness = normality_results.absolute_skewness(npi_indices);
    npi_data.normality_characteristics.relative_skewness = normality_results.relative_skewness(npi_indices);
    
    fprintf('  Classified %d PIs as NPIs\n', npi_data.n_pis);
end

function axiom_results = validateFourAxioms(npi_data, threshold)
    %VALIDATEFOURAXIOMS Validate NPIs against the four axioms
    
    axiom_results = struct();
    axiom_results.npi_names = npi_data.npi_names;
    axiom_results.n_pis = npi_data.n_pis;
    
    % Initialize results
    axiom_results.axiom1_adherence = zeros(npi_data.n_pis, 1);
    axiom_results.axiom2_adherence = zeros(npi_data.n_pis, 1);
    axiom_results.axiom3_adherence = zeros(npi_data.n_pis, 1);
    axiom_results.axiom4_adherence = zeros(npi_data.n_pis, 1);
    axiom_results.overall_adherence = zeros(npi_data.n_pis, 1);
    
    for i = 1:npi_data.n_pis
        abs_data = npi_data.absolute_data(:, i);
        rel_data = npi_data.relative_data(:, i);
        outcomes = npi_data.outcomes;
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data) & ~isnan(outcomes);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        outcomes_clean = outcomes(valid_idx);
        
        if length(abs_clean) > 10
            % Test each axiom
            axiom1_score = testAxiom1(abs_clean, rel_clean);
            axiom2_score = testAxiom2(abs_clean, rel_clean, outcomes_clean);
            axiom3_score = testAxiom3(abs_clean, rel_clean);
            axiom4_score = testAxiom4(abs_clean, rel_clean, outcomes_clean);
            
            axiom_results.axiom1_adherence(i) = axiom1_score;
            axiom_results.axiom2_adherence(i) = axiom2_score;
            axiom_results.axiom3_adherence(i) = axiom3_score;
            axiom_results.axiom4_adherence(i) = axiom4_score;
            
            % Overall adherence (all axioms must pass)
            axiom_results.overall_adherence(i) = all([axiom1_score, axiom2_score, axiom3_score, axiom4_score] >= threshold);
        end
    end
    
    % Summary statistics
    axiom_results.axiom1_rate = mean(axiom_results.axiom1_adherence);
    axiom_results.axiom2_rate = mean(axiom_results.axiom2_adherence);
    axiom_results.axiom3_rate = mean(axiom_results.axiom3_adherence);
    axiom_results.axiom4_rate = mean(axiom_results.axiom4_adherence);
    axiom_results.overall_rate = mean(axiom_results.overall_adherence);
    
    fprintf('  Axiom 1 adherence rate: %.1f%%\n', axiom_results.axiom1_rate * 100);
    fprintf('  Axiom 2 adherence rate: %.1f%%\n', axiom_results.axiom2_rate * 100);
    fprintf('  Axiom 3 adherence rate: %.1f%%\n', axiom_results.axiom3_rate * 100);
    fprintf('  Axiom 4 adherence rate: %.1f%%\n', axiom_results.axiom4_rate * 100);
    fprintf('  Overall adherence rate: %.1f%%\n', axiom_results.overall_rate * 100);
end

function score = testAxiom1(abs_data, rel_data)
    %TESTAXIOM1 Test Axiom 1: Invariance to Shared Effects
    
    % Axiom 1: Relative measures should be invariant to shared environmental effects
    % Test: Correlation between absolute and relative measures should be low
    correlation = abs(corr(abs_data, rel_data));
    
    % Score: 1 if correlation is low (invariant), 0 if high (not invariant)
    score = 1 - correlation; % Higher score = more invariant
end

function score = testAxiom2(abs_data, rel_data, outcomes)
    %TESTAXIOM2 Test Axiom 2: Ordinal Consistency
    
    % Axiom 2: Relative measures should maintain ordinal consistency
    % Test: Spearman correlation between absolute and relative measures
    spearman_corr = abs(corr(abs_data, rel_data, 'type', 'Spearman'));
    
    % Score: 1 if high correlation (consistent ordering), 0 if low
    score = spearman_corr;
end

function score = testAxiom3(abs_data, rel_data)
    %TESTAXIOM3 Test Axiom 3: Scaling Proportionality
    
    % Axiom 3: Relative measures should be proportional to absolute measures
    % Test: Linear relationship between absolute and relative measures
    if length(abs_data) > 2
        p = polyfit(abs_data, rel_data, 1);
        predicted = polyval(p, abs_data);
        r_squared = 1 - sum((rel_data - predicted).^2) / sum((rel_data - mean(rel_data)).^2);
        score = max(0, r_squared);
    else
        score = 0;
    end
end

function score = testAxiom4(abs_data, rel_data, outcomes)
    %TESTAXIOM4 Test Axiom 4: Statistical Optimality
    
    % Axiom 4: Relative measures should provide statistical advantages
    % Test: AUC improvement when using relative vs absolute measures
    
    try
        % Calculate AUC for absolute measure
        [~, ~, ~, auc_abs] = perfcurve(outcomes, abs_data, 1);
        
        % Calculate AUC for relative measure
        [~, ~, ~, auc_rel] = perfcurve(outcomes, rel_data, 1);
        
        % Score: 1 if relative AUC > absolute AUC, 0 otherwise
        score = double(auc_rel > auc_abs);
        
    catch
        score = 0;
    end
end

function anpi_data = classifyAsANPIs(npi_data, axiom_results)
    %CLASSIFYASANPIS Classify NPIs as ANPIs based on axiom adherence
    
    anpi_data = struct();
    
    % Find NPIs that meet axiom criteria
    anpi_indices = find(axiom_results.overall_adherence);
    
    anpi_data.anpi_names = npi_data.npi_names(anpi_indices);
    anpi_data.n_pis = length(anpi_indices);
    anpi_data.n_matches = npi_data.n_matches;
    anpi_data.outcomes = npi_data.outcomes;
    
    % Extract data for ANPIs
    anpi_data.absolute_data = npi_data.absolute_data(:, anpi_indices);
    anpi_data.relative_data = npi_data.relative_data(:, anpi_indices);
    
    % Store axiom characteristics
    anpi_data.axiom_characteristics = struct();
    anpi_data.axiom_characteristics.axiom1_scores = axiom_results.axiom1_adherence(anpi_indices);
    anpi_data.axiom_characteristics.axiom2_scores = axiom_results.axiom2_adherence(anpi_indices);
    anpi_data.axiom_characteristics.axiom3_scores = axiom_results.axiom3_adherence(anpi_indices);
    anpi_data.axiom_characteristics.axiom4_scores = axiom_results.axiom4_adherence(anpi_indices);
    
    fprintf('  Classified %d NPIs as ANPIs\n', anpi_data.n_pis);
end

function npi_analysis = analyzeNPIDistributions(npi_data)
    %ANALYZENPIDISTRIBUTIONS Analyze means and variances of NPIs for pipeline decisions
    
    npi_analysis = struct();
    npi_analysis.npi_names = npi_data.npi_names;
    npi_analysis.n_pis = npi_data.n_pis;
    
    % Initialize storage
    absolute_variances = zeros(npi_data.n_pis, 1);
    relative_variances = zeros(npi_data.n_pis, 1);
    absolute_means = zeros(npi_data.n_pis, 1);
    relative_means = zeros(npi_data.n_pis, 1);
    variance_reductions = zeros(npi_data.n_pis, 1);
    
    for i = 1:npi_data.n_pis
        abs_data = npi_data.absolute_data(:, i);
        rel_data = npi_data.relative_data(:, i);
        
        % Remove NaN values
        abs_clean = abs_data(~isnan(abs_data));
        rel_clean = rel_data(~isnan(rel_data));
        
        if length(abs_clean) > 10 && length(rel_clean) > 10
            % Calculate means and variances
            absolute_means(i) = mean(abs_clean);
            relative_means(i) = mean(rel_clean);
            absolute_variances(i) = var(abs_clean);
            relative_variances(i) = var(rel_clean);
            
            % Calculate variance reduction
            if absolute_variances(i) > 0
                variance_reductions(i) = (absolute_variances(i) - relative_variances(i)) / absolute_variances(i);
            else
                variance_reductions(i) = 0;
            end
        end
    end
    
    % Store results
    npi_analysis.absolute_means = absolute_means;
    npi_analysis.relative_means = relative_means;
    npi_analysis.absolute_variances = absolute_variances;
    npi_analysis.relative_variances = relative_variances;
    npi_analysis.variance_reductions = variance_reductions;
    
    % Summary statistics
    npi_analysis.mean_absolute_mean = mean(absolute_means);
    npi_analysis.mean_relative_mean = mean(relative_means);
    npi_analysis.mean_absolute_variance = mean(absolute_variances);
    npi_analysis.mean_relative_variance = mean(relative_variances);
    npi_analysis.mean_variance_reduction = mean(variance_reductions);
    
    % Environmental noise estimation
    npi_analysis.environmental_noise_estimate = estimateEnvironmentalNoise(npi_data);
    
    % Detailed analysis for each NPI
    npi_analysis.detailed_analysis = struct();
    for i = 1:npi_data.n_pis
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}) = struct();
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).absolute_mean = absolute_means(i);
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).relative_mean = relative_means(i);
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).absolute_variance = absolute_variances(i);
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).relative_variance = relative_variances(i);
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).variance_reduction = variance_reductions(i);
    end
    
    fprintf('  Analyzed %d NPIs for distributional characteristics\n', npi_data.n_pis);
end

function env_noise = estimateEnvironmentalNoise(npi_data)
    %ESTIMATEENVIRONMENTALNOISE Estimate environmental noise from NPI data
    
    env_noise = 0;
    n_valid = 0;
    
    for i = 1:npi_data.n_pis
        abs_data = npi_data.absolute_data(:, i);
        rel_data = npi_data.relative_data(:, i);
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        
        if length(abs_clean) > 10
            % Estimate environmental noise from variance difference
            var_abs = var(abs_clean);
            var_rel = var(rel_clean);
            
            if var_abs > var_rel && var_abs > 0
                % Environmental noise contributes to absolute variance
                env_contribution = (var_abs - var_rel) / var_abs;
                env_noise = env_noise + env_contribution;
                n_valid = n_valid + 1;
            end
        end
    end
    
    if n_valid > 0
        env_noise = env_noise / n_valid;
    end
    
    env_noise = max(0, min(1, env_noise)); % Ensure 0 <= env_noise <= 1
end

function pipeline_decisions = makePipelineDecisions(npi_analysis, config)
    %MAKEPIPELINEDECISIONS Make informed decisions about pipeline continuation
    
    pipeline_decisions = struct();
    
    % Analyze variance reduction patterns
    mean_variance_reduction = npi_analysis.mean_variance_reduction;
    environmental_noise = npi_analysis.environmental_noise_estimate;
    
    % Decision 1: Adjust axiom threshold based on data quality
    if mean_variance_reduction > 0.3 && environmental_noise > 0.2
        % Strong environmental noise cancellation detected
        pipeline_decisions.adjusted_axiom_threshold = 0.7; % 70% threshold
        pipeline_decisions.continue_with_axioms = true;
        pipeline_decisions.recommended_approach = 'STANDARD_VALIDATION';
        
    elseif mean_variance_reduction > 0.1 && environmental_noise > 0.1
        % Moderate environmental noise cancellation detected
        pipeline_decisions.adjusted_axiom_threshold = 0.6; % 60% threshold
        pipeline_decisions.continue_with_axioms = true;
        pipeline_decisions.recommended_approach = 'RELAXED_VALIDATION';
        
    elseif mean_variance_reduction > 0.05
        % Weak environmental noise cancellation detected
        pipeline_decisions.adjusted_axiom_threshold = 0.5; % 50% threshold
        pipeline_decisions.continue_with_axioms = true;
        pipeline_decisions.recommended_approach = 'CONSERVATIVE_VALIDATION';
        
    else
        % No significant environmental noise cancellation detected
        pipeline_decisions.adjusted_axiom_threshold = 0.4; % 40% threshold
        pipeline_decisions.continue_with_axioms = false;
        pipeline_decisions.recommended_approach = 'INVESTIGATE_DATA_QUALITY';
    end
    
    % Decision 2: Additional recommendations
    if environmental_noise < 0.1
        pipeline_decisions.additional_recommendations = {'Check data preprocessing', 'Verify environmental factors', 'Consider data transformation'};
    elseif mean_variance_reduction < 0.1
        pipeline_decisions.additional_recommendations = {'Review relative measure construction', 'Check for data leakage', 'Verify outcome variable'};
    else
        pipeline_decisions.additional_recommendations = {'Proceed with validation', 'Monitor axiom adherence', 'Document threshold adjustments'};
    end
    
    fprintf('  Pipeline decisions based on:\n');
    fprintf('    - Mean variance reduction: %.1f%%\n', mean_variance_reduction * 100);
    fprintf('    - Environmental noise estimate: %.1f%%\n', environmental_noise * 100);
    fprintf('    - Recommended threshold: %.1f%%\n', pipeline_decisions.adjusted_axiom_threshold * 100);
end

function distributional_analysis = analyzeDistributionalBehaviour(anpi_data)
    %ANALYZEDISTRIBUTIONALBEHAVIOUR Analyze true distributional behaviour of ANPIs
    
    distributional_analysis = struct();
    distributional_analysis.anpi_names = anpi_data.anpi_names;
    distributional_analysis.n_pis = anpi_data.n_pis;
    
    % Initialize results
    distributional_analysis.absolute_distributions = cell(anpi_data.n_pis, 1);
    distributional_analysis.relative_distributions = cell(anpi_data.n_pis, 1);
    distributional_analysis.absolute_parameters = zeros(anpi_data.n_pis, 4); % mean, std, skew, kurt
    distributional_analysis.relative_parameters = zeros(anpi_data.n_pis, 4);
    distributional_analysis.distribution_fits = cell(anpi_data.n_pis, 1);
    
    for i = 1:anpi_data.n_pis
        abs_data = anpi_data.absolute_data(:, i);
        rel_data = anpi_data.relative_data(:, i);
        
        % Remove NaN values
        abs_clean = abs_data(~isnan(abs_data));
        rel_clean = rel_data(~isnan(rel_data));
        
        if length(abs_clean) > 10 && length(rel_clean) > 10
            % Store distributions
            distributional_analysis.absolute_distributions{i} = abs_clean;
            distributional_analysis.relative_distributions{i} = rel_clean;
            
            % Calculate parameters
            distributional_analysis.absolute_parameters(i, :) = [mean(abs_clean), std(abs_clean), skewness(abs_clean), kurtosis(abs_clean)];
            distributional_analysis.relative_parameters(i, :) = [mean(rel_clean), std(rel_clean), skewness(rel_clean), kurtosis(rel_clean)];
            
            % Fit distributions
            distributional_analysis.distribution_fits{i} = fitDistributions(abs_clean, rel_clean);
        end
    end
    
    fprintf('  Analyzed distributional behaviour for %d ANPIs\n', anpi_data.n_pis);
end

function fits = fitDistributions(abs_data, rel_data)
    %FITDISTRIBUTIONS Fit various distributions to data
    
    fits = struct();
    
    % Distributions to test
    distributions = {'normal', 'gamma', 'lognormal', 'exponential'};
    
    for i = 1:length(distributions)
        dist_name = distributions{i};
        
        try
            % Fit to absolute data
            fits.absolute.(dist_name) = fitDistribution(abs_data, dist_name);
            
            % Fit to relative data
            fits.relative.(dist_name) = fitDistribution(rel_data, dist_name);
            
        catch
            fits.absolute.(dist_name) = struct('params', NaN, 'loglik', -Inf, 'aic', Inf);
            fits.relative.(dist_name) = struct('params', NaN, 'loglik', -Inf, 'aic', Inf);
        end
    end
end

function fit_result = fitDistribution(data, dist_name)
    %FITDISTRIBUTION Fit a specific distribution to data
    
    fit_result = struct();
    
    try
        switch dist_name
            case 'normal'
                params = [mean(data), std(data)];
                loglik = sum(log(normpdf(data, params(1), params(2))));
                
            case 'gamma'
                if any(data <= 0)
                    params = NaN(1, 2);
                    loglik = -Inf;
                else
                    params = gamfit(data);
                    loglik = sum(log(gampdf(data, params(1), params(2))));
                end
                
            case 'lognormal'
                if any(data <= 0)
                    params = NaN(1, 2);
                    loglik = -Inf;
                else
                    params = lognfit(data);
                    loglik = sum(log(lognpdf(data, params(1), params(2))));
                end
                
            case 'exponential'
                if any(data < 0)
                    params = NaN;
                    loglik = -Inf;
                else
                    params = mean(data);
                    loglik = sum(log(exppdf(data, params)));
                end
        end
        
        fit_result.params = params;
        fit_result.loglik = loglik;
        fit_result.aic = 2 * length(params) - 2 * loglik;
        
    catch
        fit_result.params = NaN;
        fit_result.loglik = -Inf;
        fit_result.aic = Inf;
    end
end

function snr_analysis = investigateEmpiricalSNR(anpi_data, config)
    %INVESTIGATEEMPIRICALSNR Investigate empirical SNR for all ANPIs
    
    snr_analysis = struct();
    snr_analysis.anpi_names = anpi_data.anpi_names;
    snr_analysis.n_pis = anpi_data.n_pis;
    
    % Initialize results
    snr_analysis.empirical_improvements = zeros(anpi_data.n_pis, 1);
    snr_analysis.theoretical_improvements = zeros(anpi_data.n_pis, 1);
    snr_analysis.absolute_aucs = zeros(anpi_data.n_pis, 1);
    snr_analysis.relative_aucs = zeros(anpi_data.n_pis, 1);
    
    for i = 1:anpi_data.n_pis
        abs_data = anpi_data.absolute_data(:, i);
        rel_data = anpi_data.relative_data(:, i);
        outcomes = anpi_data.outcomes;
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data) & ~isnan(outcomes);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        outcomes_clean = outcomes(valid_idx);
        
        if length(abs_clean) > 10
            % Calculate empirical SNR improvement (AUC-based)
            try
                [~, ~, ~, auc_abs] = perfcurve(outcomes_clean, abs_clean, 1);
                [~, ~, ~, auc_rel] = perfcurve(outcomes_clean, rel_clean, 1);
                
                snr_analysis.absolute_aucs(i) = auc_abs;
                snr_analysis.relative_aucs(i) = auc_rel;
                snr_analysis.empirical_improvements(i) = (auc_rel - auc_abs) / auc_abs * 100;
                
            catch
                snr_analysis.absolute_aucs(i) = NaN;
                snr_analysis.relative_aucs(i) = NaN;
                snr_analysis.empirical_improvements(i) = NaN;
            end
            
            % Calculate theoretical SNR improvement
            try
                var_abs = var(abs_clean);
                var_rel = var(rel_clean);
                
                if var_rel > 0
                    snr_analysis.theoretical_improvements(i) = (var_abs - var_rel) / var_rel * 100;
                else
                    snr_analysis.theoretical_improvements(i) = 0;
                end
                
            catch
                snr_analysis.theoretical_improvements(i) = NaN;
            end
        end
    end
    
    % Summary statistics
    valid_empirical = ~isnan(snr_analysis.empirical_improvements);
    valid_theoretical = ~isnan(snr_analysis.theoretical_improvements);
    
    if sum(valid_empirical) > 0
        snr_analysis.mean_empirical_improvement = mean(snr_analysis.empirical_improvements(valid_empirical));
        snr_analysis.std_empirical_improvement = std(snr_analysis.empirical_improvements(valid_empirical));
    else
        snr_analysis.mean_empirical_improvement = NaN;
        snr_analysis.std_empirical_improvement = NaN;
    end
    
    if sum(valid_theoretical) > 0
        snr_analysis.mean_theoretical_improvement = mean(snr_analysis.theoretical_improvements(valid_theoretical));
        snr_analysis.std_theoretical_improvement = std(snr_analysis.theoretical_improvements(valid_theoretical));
    else
        snr_analysis.mean_theoretical_improvement = NaN;
        snr_analysis.std_theoretical_improvement = NaN;
    end
    
    % Correlation between theoretical and empirical
    if sum(valid_empirical & valid_theoretical) > 1
        snr_analysis.correlation = corr(snr_analysis.empirical_improvements(valid_empirical & valid_theoretical), ...
                                       snr_analysis.theoretical_improvements(valid_empirical & valid_theoretical));
    else
        snr_analysis.correlation = NaN;
    end
    
    fprintf('  Mean empirical SNR improvement: %.1f%% ± %.1f%%\n', ...
        snr_analysis.mean_empirical_improvement, snr_analysis.std_empirical_improvement);
    fprintf('  Mean theoretical SNR improvement: %.1f%% ± %.1f%%\n', ...
        snr_analysis.mean_theoretical_improvement, snr_analysis.std_theoretical_improvement);
    fprintf('  Theory-empirical correlation: %.3f\n', snr_analysis.correlation);
end

function conclusions = reachConclusions(pi_data, standardised_data, npi_data, npi_analysis, pipeline_decisions, anpi_data, distributional_analysis, snr_analysis, config)
    %REACHCONCLUSIONS Reach conclusions based on all analysis steps
    
    conclusions = struct();
    conclusions.timestamp = datetime('now');
    
    % Step-by-step conclusions
    conclusions.step1_pi_extraction = struct();
    conclusions.step1_pi_extraction.total_pis = length(pi_data.pi_names);
    conclusions.step1_pi_extraction.n_matches = pi_data.n_matches;
    conclusions.step1_pi_extraction.success = true;
    
    conclusions.step2_standardisation = struct();
    conclusions.step2_standardisation.quality_retention = standardised_data.quality_retention;
    conclusions.step2_standardisation.success = conclusions.step2_standardisation.quality_retention > 0.8;
    
    conclusions.step3_normality = struct();
    conclusions.step3_normality.normality_rate = length(npi_data.npi_names) / length(pi_data.pi_names);
    conclusions.step3_normality.success = conclusions.step3_normality.normality_rate > 0.5;
    
    conclusions.step35_npi_analysis = struct();
    conclusions.step35_npi_analysis.mean_variance_reduction = npi_analysis.mean_variance_reduction;
    conclusions.step35_npi_analysis.environmental_noise = npi_analysis.environmental_noise_estimate;
    conclusions.step35_npi_analysis.adjusted_threshold = pipeline_decisions.adjusted_axiom_threshold;
    conclusions.step35_npi_analysis.recommended_approach = pipeline_decisions.recommended_approach;
    conclusions.step35_npi_analysis.success = pipeline_decisions.continue_with_axioms;
    
    conclusions.step4_axioms = struct();
    conclusions.step4_axioms.axiom_adherence_rate = length(anpi_data.anpi_names) / length(npi_data.npi_names);
    conclusions.step4_axioms.success = conclusions.step4_axioms.axiom_adherence_rate > 0.3;
    
    conclusions.step5_distributions = struct();
    conclusions.step5_distributions.anpis_analyzed = anpi_data.n_pis;
    conclusions.step5_distributions.success = anpi_data.n_pis > 0;
    
    conclusions.step6_snr = struct();
    conclusions.step6_snr.empirical_improvement = snr_analysis.mean_empirical_improvement;
    conclusions.step6_snr.theoretical_improvement = snr_analysis.mean_theoretical_improvement;
    conclusions.step6_snr.correlation = snr_analysis.correlation;
    conclusions.step6_snr.success = ~isnan(snr_analysis.correlation) && snr_analysis.correlation > 0.5;
    
    % Overall conclusions
    conclusions.overall_success = all([conclusions.step1_pi_extraction.success, ...
                                      conclusions.step2_standardisation.success, ...
                                      conclusions.step3_normality.success, ...
                                      conclusions.step35_npi_analysis.success, ...
                                      conclusions.step4_axioms.success, ...
                                      conclusions.step5_distributions.success, ...
                                      conclusions.step6_snr.success]);
    
    % Key findings
    conclusions.key_findings = struct();
    conclusions.key_findings.total_pis = length(pi_data.pi_names);
    conclusions.key_findings.normality_rate = conclusions.step3_normality.normality_rate;
    conclusions.key_findings.npi_variance_reduction = conclusions.step35_npi_analysis.mean_variance_reduction;
    conclusions.key_findings.environmental_noise = conclusions.step35_npi_analysis.environmental_noise;
    conclusions.key_findings.adjusted_axiom_threshold = conclusions.step35_npi_analysis.adjusted_threshold;
    conclusions.key_findings.axiom_adherence_rate = conclusions.step4_axioms.axiom_adherence_rate;
    conclusions.key_findings.final_anpis = anpi_data.n_pis;
    conclusions.key_findings.empirical_snr_improvement = snr_analysis.mean_empirical_improvement;
    conclusions.key_findings.theoretical_snr_improvement = snr_analysis.mean_theoretical_improvement;
    conclusions.key_findings.theory_empirical_correlation = snr_analysis.correlation;
    
    % Recommendations
    conclusions.recommendations = generateRecommendations(conclusions);
    
    fprintf('  Overall pipeline success: %s\n', string(conclusions.overall_success));
fprintf('  Final ANPIs: %d\n', conclusions.key_findings.final_anpis);
fprintf('  NPI variance reduction: %.1f%%\n', conclusions.key_findings.npi_variance_reduction * 100);
fprintf('  Environmental noise: %.1f%%\n', conclusions.key_findings.environmental_noise * 100);
fprintf('  Adjusted axiom threshold: %.1f%%\n', conclusions.key_findings.adjusted_axiom_threshold * 100);
fprintf('  Empirical SNR improvement: %.1f%%\n', conclusions.key_findings.empirical_snr_improvement);
fprintf('  Theory-empirical correlation: %.3f\n', conclusions.key_findings.theory_empirical_correlation);
end

function recommendations = generateRecommendations(conclusions)
    %GENERATERECOMMENDATIONS Generate recommendations based on conclusions
    
    recommendations = struct();
    
    if conclusions.overall_success
        recommendations.status = 'SUCCESS';
        recommendations.message = 'Pipeline completed successfully. Results are ready for publication.';
    else
        recommendations.status = 'NEEDS_ATTENTION';
        recommendations.message = 'Pipeline completed with issues. Review and address identified problems.';
    end
    
    % Specific recommendations
    recommendations.specific = {};
    
    if conclusions.step3_normality.normality_rate < 0.5
        recommendations.specific{end+1} = 'Consider data transformation to improve normality';
    end
    
    if conclusions.step4_axioms.axiom_adherence_rate < 0.3
        recommendations.specific{end+1} = 'Review axiom validation criteria or data quality';
    end
    
    if conclusions.step6_snr.correlation < 0.5
        recommendations.specific{end+1} = 'Investigate theory-empirical gap in SNR calculations';
    end
    
    if conclusions.key_findings.final_anpis < 5
        recommendations.specific{end+1} = 'Consider relaxing criteria to increase ANPI count';
    end
end

function generateComprehensiveReport(pi_data, npi_data, anpi_data, distributional_analysis, snr_analysis, conclusions, config)
    %GENERATECOMPREHENSIVEREPORT Generate comprehensive report of all results
    
    % Create output directory
    output_dir = 'outputs/validation_pipeline';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Save all results
    save(fullfile(output_dir, 'complete_pipeline_results.mat'), ...
         'pi_data', 'npi_data', 'anpi_data', 'distributional_analysis', ...
         'snr_analysis', 'conclusions', 'config', '-v7.3');
    
    % Generate text report
    report_file = fullfile(output_dir, 'pipeline_report.txt');
    fid = fopen(report_file, 'w');
    
    fprintf(fid, 'UP1 COMPLETE VALIDATION PIPELINE REPORT\n');
    fprintf(fid, 'Generated: %s\n\n', datestr(now));
    
    fprintf(fid, 'EXECUTIVE SUMMARY\n');
    fprintf(fid, '================\n');
    fprintf(fid, 'Overall Success: %s\n', string(conclusions.overall_success));
    fprintf(fid, 'Total PIs: %d\n', conclusions.key_findings.total_pis);
    fprintf(fid, 'NPIs (Normal PIs): %d\n', length(npi_data.npi_names));
    fprintf(fid, 'NPI Variance Reduction: %.1f%%\n', conclusions.key_findings.npi_variance_reduction * 100);
    fprintf(fid, 'Environmental Noise Estimate: %.1f%%\n', conclusions.key_findings.environmental_noise * 100);
    fprintf(fid, 'Adjusted Axiom Threshold: %.1f%%\n', conclusions.key_findings.adjusted_axiom_threshold * 100);
    fprintf(fid, 'Final ANPIs: %d\n', conclusions.key_findings.final_anpis);
    fprintf(fid, 'Empirical SNR Improvement: %.1f%%\n', conclusions.key_findings.empirical_snr_improvement);
    fprintf(fid, 'Theory-Empirical Correlation: %.3f\n\n', conclusions.key_findings.theory_empirical_correlation);
    
    fprintf(fid, 'STEP-BY-STEP RESULTS\n');
    fprintf(fid, '====================\n');
    fprintf(fid, 'Step 1 - PI Extraction: %s (%d PIs)\n', string(conclusions.step1_pi_extraction.success), conclusions.step1_pi_extraction.total_pis);
    fprintf(fid, 'Step 2 - Standardisation: %s (%.1f%% retention)\n', string(conclusions.step2_standardisation.success), conclusions.step2_standardisation.quality_retention * 100);
    fprintf(fid, 'Step 3 - Normality: %s (%.1f%% rate)\n', string(conclusions.step3_normality.success), conclusions.step3_normality.normality_rate * 100);
    fprintf(fid, 'Step 3.5 - NPI Analysis: %s (%.1f%% variance reduction, %.1f%% env noise)\n', string(conclusions.step35_npi_analysis.success), conclusions.step35_npi_analysis.mean_variance_reduction * 100, conclusions.step35_npi_analysis.environmental_noise * 100);
    fprintf(fid, 'Step 4 - Axioms: %s (%.1f%% rate, threshold: %.1f%%)\n', string(conclusions.step4_axioms.success), conclusions.step4_axioms.axiom_adherence_rate * 100, conclusions.step35_npi_analysis.adjusted_threshold * 100);
    fprintf(fid, 'Step 5 - Distributions: %s (%d ANPIs)\n', string(conclusions.step5_distributions.success), conclusions.step5_distributions.anpis_analyzed);
    fprintf(fid, 'Step 6 - SNR: %s (%.1f%% improvement)\n', string(conclusions.step6_snr.success), conclusions.step6_snr.empirical_improvement);
    
    fprintf(fid, '\nRECOMMENDATIONS\n');
    fprintf(fid, '===============\n');
    fprintf(fid, 'Status: %s\n', conclusions.recommendations.status);
    fprintf(fid, 'Message: %s\n', conclusions.recommendations.message);
    
    if ~isempty(conclusions.recommendations.specific)
        fprintf(fid, '\nSpecific Recommendations:\n');
        for i = 1:length(conclusions.recommendations.specific)
            fprintf(fid, '  %d. %s\n', i, conclusions.recommendations.specific{i});
        end
    end
    
    fclose(fid);
    
    fprintf('  Comprehensive report saved to: %s\n', report_file);
    fprintf('  Complete results saved to: %s\n', fullfile(output_dir, 'complete_pipeline_results.mat'));
end
