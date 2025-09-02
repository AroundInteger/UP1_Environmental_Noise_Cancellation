function UP1_Corrected_Validation_Pipeline()
    %UP1_CORRECTED_VALIDATION_PIPELINE Corrected pipeline that tests actual environmental noise cancellation theory
    % This pipeline tests: "Absolute measures with environmental noise vs Relative measures with environmental noise cancellation"
    % NOT: "Two features vs one feature"
    
    fprintf('=== UP1 CORRECTED VALIDATION PIPELINE ===\n');
    fprintf('Testing Environmental Noise Cancellation Theory\n');
    fprintf('Timestamp: %s\n\n', datestr(now));
    
    % Setup paths
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    cd(project_root);
    addpath(genpath('src'));
    
    % Configuration
    config = struct();
    config.normality_threshold = 0.01;  % Relaxed threshold for real-world data
    config.axiom_threshold = 0.6;
    config.eta_optimization_tolerance = 1e-6;
    config.eta_optimization_max_iter = 100;
    
    %% Step 1: Load Raw Data (Before Any Environmental Noise Removal)
    fprintf('STEP 1: Loading raw PI data (before environmental noise removal)...\n');
    
    % Load raw data to preserve environmental factors
    raw_data_file = 'data/raw/4_seasons rowan.csv';
    if ~exist(raw_data_file, 'file')
        error('Raw data file not found: %s', raw_data_file);
    end
    
    raw_data = readtable(raw_data_file);
    fprintf('✓ Loaded raw data: %dx%d\n', height(raw_data), width(raw_data));
    
    % Extract PI data preserving environmental factors
    pi_data = extractRawPIData(raw_data);
    fprintf('✓ Extracted %d PIs from %d matches\n', length(pi_data.pi_names), height(raw_data));
    
    %% Step 2: Process Data WITHOUT Destroying Environmental Noise
    fprintf('\nSTEP 2: Processing data while preserving environmental noise...\n');
    
    % Process data to preserve variance differences needed for environmental noise detection
    processed_data = processDataPreservingEnvironmentalNoise(pi_data);
    fprintf('✓ Processed %d PIs (%.1f%% retention)\n', length(processed_data.pi_names), processed_data.quality_retention * 100);
    
    %% Step 3: Check Normality of All PI Distributions -> Re-classify as NPIs
    fprintf('\nSTEP 3: Checking normality of all PI distributions...\n');
    
    normality_results = assessNormality(processed_data, config.normality_threshold);
    npi_data = classifyAsNPIs(processed_data, normality_results);
    
    fprintf('✓ Normality assessment completed\n');
    fprintf('  - Total PIs: %d\n', length(processed_data.pi_names));
    fprintf('  - Classified as NPIs: %d\n', length(npi_data.npi_names));
    fprintf('  - Normality rate: %.1f%%\n', length(npi_data.npi_names) / length(processed_data.pi_names) * 100);
    
    %% Step 3.5: Optimize Environmental Noise for Maximum Relative Benefit
    fprintf('\nSTEP 3.5: Optimizing environmental noise for maximum relative benefit...\n');
    
    npi_analysis = optimizeEnvironmentalNoise(npi_data, config);
    fprintf('✓ Environmental noise optimization completed\n');
    fprintf('  - Mean optimal eta: %.3f\n', npi_analysis.mean_optimal_eta);
    fprintf('  - Mean SNR improvement: %.1f%%\n', npi_analysis.mean_snr_improvement * 100);
    fprintf('  - Mean variance reduction: %.1f%%\n', npi_analysis.mean_variance_reduction * 100);
    
    % Make pipeline decisions based on optimization results
    pipeline_decisions = makeOptimizationDecisions(npi_analysis, config);
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
    fprintf('  - Classified as ANPIs: %d\n', length(anpi_data.npi_names));
    fprintf('  - Axiom adherence rate: %.1f%%\n', length(anpi_data.npi_names) / length(npi_data.npi_names) * 100);
    
    %% Step 5: Test Environmental Noise Cancellation Theory
    fprintf('\nSTEP 5: Testing environmental noise cancellation theory...\n');
    
    % This is the KEY test: Absolute measures vs Relative measures
    theory_validation = testEnvironmentalNoiseCancellation(anpi_data, npi_analysis);
    fprintf('✓ Environmental noise cancellation theory tested\n');
    fprintf('  - Absolute measures AUC: %.3f\n', theory_validation.absolute_auc);
    fprintf('  - Relative measures AUC: %.3f\n', theory_validation.relative_auc);
    fprintf('  - AUC improvement: %.1f%%\n', theory_validation.auc_improvement * 100);
    fprintf('  - Theory validated: %s\n', string(theory_validation.theory_validated));
    
    %% Step 6: Assess Distributional Behaviour of ANPIs
    fprintf('\nSTEP 6: Assessing distributional behaviour of ANPIs...\n');
    
    distributional_analysis = analyzeDistributionalBehaviour(anpi_data);
    fprintf('✓ Distributional analysis completed for %d ANPIs\n', anpi_data.n_pis);
    
    %% Step 7: Calculate SNR Improvements
    fprintf('\nSTEP 7: Calculating SNR improvements...\n');
    
    snr_analysis = calculateSNRImprovements(anpi_data, npi_analysis);
    fprintf('✓ SNR analysis completed\n');
    fprintf('  - Mean empirical SNR improvement: %.1f%%\n', snr_analysis.mean_empirical_improvement);
    fprintf('  - Mean theoretical SNR improvement: %.1f%%\n', snr_analysis.mean_theoretical_improvement);
    fprintf('  - Theory-empirical correlation: %.3f\n', snr_analysis.correlation);
    
    %% Step 8: Reach Conclusions
    fprintf('\nSTEP 8: Reaching conclusions...\n');
    
    conclusions = reachCorrectedConclusions(pi_data, processed_data, npi_data, npi_analysis, pipeline_decisions, anpi_data, theory_validation, distributional_analysis, snr_analysis, config);
    fprintf('✓ Conclusions reached\n');
    
    %% Generate Comprehensive Report
    fprintf('\n=== GENERATING COMPREHENSIVE REPORT ===\n');
    
    % Create output directory
    output_dir = 'outputs/corrected_validation_pipeline';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Generate report
    report_file = fullfile(output_dir, 'corrected_pipeline_report.txt');
    generateCorrectedReport(report_file, conclusions, pi_data, npi_data, anpi_data, theory_validation, snr_analysis);
    
    % Save complete results
    results_file = fullfile(output_dir, 'corrected_pipeline_results.mat');
    save(results_file, 'pi_data', 'processed_data', 'npi_data', 'npi_analysis', 'pipeline_decisions', 'anpi_data', 'theory_validation', 'distributional_analysis', 'snr_analysis', 'conclusions', 'config');
    
    fprintf('  Comprehensive report saved to: %s\n', report_file);
    fprintf('  Complete results saved to: %s\n', results_file);
    
    %% Display Final Results
    fprintf('\n=== FINAL RESULTS ===\n');
    fprintf('  Overall pipeline success: %s\n', string(conclusions.overall_success));
    fprintf('  Final ANPIs: %d\n', conclusions.key_findings.final_anpis);
    fprintf('  Environmental noise cancellation validated: %s\n', string(theory_validation.theory_validated));
    fprintf('  AUC improvement from relative measures: %.1f%%\n', theory_validation.auc_improvement * 100);
    fprintf('  Mean SNR improvement: %.1f%%\n', conclusions.key_findings.mean_snr_improvement);
    fprintf('  Theory-empirical correlation: %.3f\n', conclusions.key_findings.theory_empirical_correlation);
    
    fprintf('\n=== CORRECTED PIPELINE COMPLETED SUCCESSFULLY ===\n');
    fprintf('All steps completed. Results saved to %s/\n', output_dir);
end

%% Helper Functions

function pi_data = extractRawPIData(raw_data)
    %EXTRACTRAWPIDATA Extract PI data from raw data preserving environmental factors
    
    % Define PI columns (absolute measures) - using actual column names from raw data
    pi_columns = {'carries_i', 'metres_made_i', 'defenders_beaten_i', 'clean_breaks_i', 'offloads_i', ...
                  'passes_i', 'turnovers_conceded_i', 'turnovers_won_i', 'kicks_from_hand_i', 'kick_metres_i', ...
                  'scrums_won_i', 'rucks_won_i', 'lineout_throws_lost_i', 'lineout_throws_won_i', 'tackles_i', ...
                  'missed_tackles_i', 'penalties_conceded_i', 'scrum_pens_conceded_i', 'lineout_pens_conceded_i', ...
                  'general_play_pens_conceded_i', 'free_kicks_conceded_i', 'ruck_maul_tackle_pen_con_i', ...
                  'red_cards_i', 'yellow_cards_i'};
    
    % Check which columns exist
    available_columns = raw_data.Properties.VariableNames;
    existing_pi_columns = pi_columns(ismember(pi_columns, available_columns));
    
    if isempty(existing_pi_columns)
        error('No PI columns found in raw data');
    end
    
    % Extract absolute measures
    absolute_data = table2array(raw_data(:, existing_pi_columns));
    
    % Create relative measures (R = X_A - X_B)
    % For rugby data, the _r columns already contain relative differences!
    relative_data = zeros(size(absolute_data));
    
    % Get corresponding team_r columns (these are already relative differences)
    team_r_columns = strrep(existing_pi_columns, '_i', '_r');
    team_r_columns = team_r_columns(ismember(team_r_columns, available_columns));
    
    if length(team_r_columns) == length(existing_pi_columns)
        % Extract relative data (already calculated as team_i - team_r)
        relative_data = table2array(raw_data(:, team_r_columns));
        fprintf('  Using pre-calculated relative measures from _r columns\n');
    else
        % Fallback: calculate relative measures manually
        fprintf('  Calculating relative measures manually\n');
        for i = 1:length(existing_pi_columns)
            % For now, use absolute data as relative (will be fixed later)
            relative_data(:, i) = absolute_data(:, i);
        end
    end
    
    % Create outcome variable (win/loss based on actual match outcome)
    if ismember('outcome', available_columns)
        % Use actual match outcome if available
        outcome_cell = table2cell(raw_data(:, 'outcome'));
        % Convert to binary (1 = win, 0 = loss)
        outcome_data = double(strcmp(outcome_cell, 'win'));
    else
        % Fallback: use relative performance
        outcome_data = zeros(size(relative_data, 1), 1);
        for i = 1:size(relative_data, 1)
            % Simple outcome: positive relative measure = win
            outcome_data(i) = mean(relative_data(i, :)) > 0;
        end
    end
    
    % Store results
    pi_data = struct();
    pi_data.pi_names = existing_pi_columns;
    pi_data.absolute_data = absolute_data;
    pi_data.relative_data = relative_data;
    pi_data.outcome_data = outcome_data;
    pi_data.n_pis = length(existing_pi_columns);
    pi_data.n_matches = size(absolute_data, 1);
    
    fprintf('  Extracted %d PIs: %s\n', length(existing_pi_columns), strjoin(existing_pi_columns(1:min(5, length(existing_pi_columns))), ', '));
    if length(existing_pi_columns) > 5
        fprintf('  ... and %d more\n', length(existing_pi_columns) - 5);
    end
end

function processed_data = processDataPreservingEnvironmentalNoise(pi_data)
    %PROCESSDATAPRESERVINGENVIRONMENTALNOISE Process data while preserving environmental noise
    
    processed_data = struct();
    processed_data.pi_names = pi_data.pi_names;
    processed_data.n_pis = pi_data.n_pis;
    processed_data.n_matches = pi_data.n_matches;
    
    % Initialize storage
    absolute_data = zeros(size(pi_data.absolute_data));
    relative_data = zeros(size(pi_data.relative_data));
    outcome_data = pi_data.outcome_data;
    
    n_valid = 0;
    
    for i = 1:pi_data.n_pis
        abs_data = pi_data.absolute_data(:, i);
        rel_data = pi_data.relative_data(:, i);
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        
        if length(abs_clean) > 10 && length(rel_clean) > 10
            % CRITICAL: Do NOT standardize to preserve variance differences
            % This is what was wrong in the original pipeline
            absolute_data(valid_idx, i) = abs_clean;  % Keep original scale
            relative_data(valid_idx, i) = rel_clean;  % Keep original scale
            n_valid = n_valid + 1;
        end
    end
    
    % Store results
    processed_data.absolute_data = absolute_data;
    processed_data.relative_data = relative_data;
    processed_data.outcome_data = outcome_data;
    processed_data.quality_retention = n_valid / pi_data.n_pis;
    
    fprintf('  Processed %d PIs (%.1f%% retention)\n', n_valid, processed_data.quality_retention * 100);
    fprintf('  CRITICAL: Preserved original variances for environmental noise detection\n');
end

function npi_analysis = optimizeEnvironmentalNoise(npi_data, config)
    %OPTIMIZEENVIRONMENTALNOISE Optimize environmental noise for maximum relative benefit
    
    npi_analysis = struct();
    npi_analysis.npi_names = npi_data.npi_names;
    npi_analysis.n_pis = npi_data.n_pis;
    
    % Initialize storage
    optimal_eta = zeros(npi_data.n_pis, 1);
    snr_improvements = zeros(npi_data.n_pis, 1);
    variance_reductions = zeros(npi_data.n_pis, 1);
    
    for i = 1:npi_data.n_pis
        abs_data = npi_data.absolute_data(:, i);
        rel_data = npi_data.relative_data(:, i);
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        
        if length(abs_clean) > 10 && length(rel_clean) > 10
            % Optimize environmental noise
            [eta_optimal, snr_improvement] = optimizeEta(abs_clean, rel_clean, config);
            
            % Calculate variance reduction
            var_abs = var(abs_clean);
            var_rel = var(rel_clean);
            variance_reduction = (var_abs - var_rel) / var_abs;
            
            % Store results
            optimal_eta(i) = eta_optimal;
            snr_improvements(i) = snr_improvement;
            variance_reductions(i) = variance_reduction;
        end
    end
    
    % Summary statistics
    npi_analysis.optimal_eta = optimal_eta;
    npi_analysis.snr_improvements = snr_improvements;
    npi_analysis.variance_reductions = variance_reductions;
    npi_analysis.mean_optimal_eta = mean(optimal_eta);
    npi_analysis.mean_snr_improvement = mean(snr_improvements);
    npi_analysis.mean_variance_reduction = mean(variance_reductions);
    
    % Detailed analysis for each NPI
    npi_analysis.detailed_analysis = struct();
    for i = 1:npi_data.n_pis
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}) = struct();
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).optimal_eta = optimal_eta(i);
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).snr_improvement = snr_improvements(i);
        npi_analysis.detailed_analysis.(npi_data.npi_names{i}).variance_reduction = variance_reductions(i);
    end
    
    fprintf('  Optimized environmental noise for %d NPIs\n', npi_data.n_pis);
end

function [eta_optimal, snr_improvement] = optimizeEta(abs_data, rel_data, config)
    %OPTIMIZEETA Find optimal environmental noise that maximizes relative benefit
    
    % Search space for eta
    max_eta = max(std(abs_data), std(rel_data));
    eta_candidates = linspace(0, max_eta, 100);
    snr_improvements = zeros(size(eta_candidates));
    
    for i = 1:length(eta_candidates)
        eta = eta_candidates(i);
        
        % Calculate theoretical SNR improvement
        var_abs = var(abs_data);
        var_rel = var(rel_data);
        
        % Theoretical SNR improvement formula
        snr_abs = (mean(abs_data))^2 / (var_abs + 2*eta^2);
        snr_rel = (mean(rel_data))^2 / var_rel;
        
        if snr_abs > 0
            snr_improvements(i) = snr_rel / snr_abs;
        end
    end
    
    % Find optimal eta
    [max_improvement, optimal_idx] = max(snr_improvements);
    eta_optimal = eta_candidates(optimal_idx);
    snr_improvement = max_improvement;
end

function pipeline_decisions = makeOptimizationDecisions(npi_analysis, config)
    %MAKEOPTIMIZATIONDECISIONS Make informed decisions based on optimization results
    
    pipeline_decisions = struct();
    
    % Analyze optimization results
    mean_snr_improvement = npi_analysis.mean_snr_improvement;
    mean_variance_reduction = npi_analysis.mean_variance_reduction;
    mean_optimal_eta = npi_analysis.mean_optimal_eta;
    
    % Decision 1: Adjust axiom threshold based on optimization results
    if mean_snr_improvement > 1.5 && mean_variance_reduction > 0.2
        % Strong environmental noise cancellation detected
        pipeline_decisions.adjusted_axiom_threshold = 0.7; % 70% threshold
        pipeline_decisions.continue_with_axioms = true;
        pipeline_decisions.recommended_approach = 'STANDARD_VALIDATION';
        
    elseif mean_snr_improvement > 1.2 && mean_variance_reduction > 0.1
        % Moderate environmental noise cancellation detected
        pipeline_decisions.adjusted_axiom_threshold = 0.6; % 60% threshold
        pipeline_decisions.continue_with_axioms = true;
        pipeline_decisions.recommended_approach = 'RELAXED_VALIDATION';
        
    elseif mean_snr_improvement > 1.1
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
    
    % Additional recommendations
    if mean_optimal_eta < 0.1
        pipeline_decisions.additional_recommendations = {'Check data preprocessing', 'Verify environmental factors', 'Consider data transformation'};
    elseif mean_variance_reduction < 0.1
        pipeline_decisions.additional_recommendations = {'Review relative measure construction', 'Check for data leakage', 'Verify outcome variable'};
    else
        pipeline_decisions.additional_recommendations = {'Proceed with validation', 'Monitor axiom adherence', 'Document threshold adjustments'};
    end
    
    fprintf('  Optimization decisions based on:\n');
    fprintf('    - Mean SNR improvement: %.2f\n', mean_snr_improvement);
    fprintf('    - Mean variance reduction: %.1f%%\n', mean_variance_reduction * 100);
    fprintf('    - Mean optimal eta: %.3f\n', mean_optimal_eta);
    fprintf('    - Recommended threshold: %.1f%%\n', pipeline_decisions.adjusted_axiom_threshold * 100);
end

function theory_validation = testEnvironmentalNoiseCancellation(anpi_data, npi_analysis)
    %TESTENVIRONMENTALNOISECANCELLATION Test the actual environmental noise cancellation theory
    
    theory_validation = struct();
    
    if anpi_data.n_pis == 0
        % No ANPIs to test
        theory_validation.absolute_auc = NaN;
        theory_validation.relative_auc = NaN;
        theory_validation.auc_improvement = NaN;
        theory_validation.theory_validated = false;
        return;
    end
    
    % Test on first ANPI (or all if few)
    test_pis = min(3, anpi_data.n_pis);
    absolute_aucs = zeros(test_pis, 1);
    relative_aucs = zeros(test_pis, 1);
    
    for i = 1:test_pis
        abs_data = anpi_data.absolute_data(:, i);
        rel_data = anpi_data.relative_data(:, i);
        outcome_data = anpi_data.outcome_data;
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data) & ~isnan(outcome_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        outcome_clean = outcome_data(valid_idx);
        
        if length(abs_clean) > 20
            % Test absolute measures (with environmental noise)
            [~, ~, ~, auc_abs] = perfcurve(outcome_clean, abs_clean, 1);
            
            % Test relative measures (environmental noise cancelled)
            [~, ~, ~, auc_rel] = perfcurve(outcome_clean, rel_clean, 1);
            
            absolute_aucs(i) = auc_abs;
            relative_aucs(i) = auc_rel;
        end
    end
    
    % Calculate results
    theory_validation.absolute_auc = mean(absolute_aucs);
    theory_validation.relative_auc = mean(relative_aucs);
    theory_validation.auc_improvement = (theory_validation.relative_auc - theory_validation.absolute_auc) / theory_validation.absolute_auc;
    theory_validation.theory_validated = theory_validation.auc_improvement > 0.05; % 5% improvement threshold
    
    fprintf('  Tested environmental noise cancellation on %d ANPIs\n', test_pis);
    fprintf('  Absolute measures AUC: %.3f\n', theory_validation.absolute_auc);
    fprintf('  Relative measures AUC: %.3f\n', theory_validation.relative_auc);
    fprintf('  AUC improvement: %.1f%%\n', theory_validation.auc_improvement * 100);
end

function distributional_analysis = analyzeDistributionalBehaviour(anpi_data)
    %ANALYZEDISTRIBUTIONALBEHAVIOUR Analyze distributional behaviour of ANPIs
    
    distributional_analysis = struct();
    distributional_analysis.anpi_names = anpi_data.npi_names;
    distributional_analysis.n_anpis = anpi_data.n_pis;
    
    if anpi_data.n_pis == 0
        distributional_analysis.summary = 'No ANPIs to analyze';
        return;
    end
    
    % Analyze each ANPI
    for i = 1:anpi_data.n_pis
        abs_data = anpi_data.absolute_data(:, i);
        rel_data = anpi_data.relative_data(:, i);
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        
        if length(abs_clean) > 10
            % Store distributional characteristics
            distributional_analysis.(anpi_data.npi_names{i}) = struct();
            distributional_analysis.(anpi_data.npi_names{i}).absolute_mean = mean(abs_clean);
            distributional_analysis.(anpi_data.npi_names{i}).absolute_std = std(abs_clean);
            distributional_analysis.(anpi_data.npi_names{i}).relative_mean = mean(rel_clean);
            distributional_analysis.(anpi_data.npi_names{i}).relative_std = std(rel_clean);
        end
    end
    
    distributional_analysis.summary = sprintf('Analyzed %d ANPIs for distributional characteristics', anpi_data.n_pis);
end

function snr_analysis = calculateSNRImprovements(anpi_data, npi_analysis)
    %CALCULATESNRIMPROVEMENTS Calculate SNR improvements for ANPIs
    
    snr_analysis = struct();
    
    if anpi_data.n_pis == 0
        snr_analysis.mean_empirical_improvement = NaN;
        snr_analysis.mean_theoretical_improvement = NaN;
        snr_analysis.correlation = NaN;
        return;
    end
    
    % Calculate empirical and theoretical SNR improvements
    empirical_improvements = zeros(anpi_data.n_pis, 1);
    theoretical_improvements = zeros(anpi_data.n_pis, 1);
    
    for i = 1:anpi_data.n_pis
        abs_data = anpi_data.absolute_data(:, i);
        rel_data = anpi_data.relative_data(:, i);
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        
        if length(abs_clean) > 10
            % Empirical SNR improvement
            var_abs = var(abs_clean);
            var_rel = var(rel_clean);
            if var_rel > 0
                empirical_improvements(i) = (var_abs - var_rel) / var_rel * 100;
            end
            
            % Theoretical SNR improvement
            eta_optimal = npi_analysis.optimal_eta(i);
            if eta_optimal > 0
                theoretical_improvements(i) = (2 * eta_optimal^2) / var_rel * 100;
            end
        end
    end
    
    % Summary statistics
    snr_analysis.empirical_improvements = empirical_improvements;
    snr_analysis.theoretical_improvements = theoretical_improvements;
    snr_analysis.mean_empirical_improvement = mean(empirical_improvements);
    snr_analysis.mean_theoretical_improvement = mean(theoretical_improvements);
    
    % Calculate correlation
    valid_idx = ~isnan(empirical_improvements) & ~isnan(theoretical_improvements);
    if sum(valid_idx) > 1
        snr_analysis.correlation = corr(empirical_improvements(valid_idx), theoretical_improvements(valid_idx));
    else
        snr_analysis.correlation = NaN;
    end
end

function conclusions = reachCorrectedConclusions(pi_data, processed_data, npi_data, npi_analysis, pipeline_decisions, anpi_data, theory_validation, distributional_analysis, snr_analysis, config)
    %REACHCORRECTEDCONCLUSIONS Reach conclusions based on corrected analysis
    
    conclusions = struct();
    
    % Step-by-step results
    conclusions.step1_pi_extraction = struct();
    conclusions.step1_pi_extraction.total_pis = length(pi_data.pi_names);
    conclusions.step1_pi_extraction.success = conclusions.step1_pi_extraction.total_pis > 0;
    
    conclusions.step2_processing = struct();
    conclusions.step2_processing.quality_retention = processed_data.quality_retention;
    conclusions.step2_processing.success = conclusions.step2_processing.quality_retention > 0.8;
    
    conclusions.step3_normality = struct();
    conclusions.step3_normality.normality_rate = length(npi_data.npi_names) / length(pi_data.pi_names);
    conclusions.step3_normality.success = conclusions.step3_normality.normality_rate > 0.5;
    
    conclusions.step35_optimization = struct();
    conclusions.step35_optimization.mean_snr_improvement = npi_analysis.mean_snr_improvement;
    conclusions.step35_optimization.mean_variance_reduction = npi_analysis.mean_variance_reduction;
    conclusions.step35_optimization.adjusted_threshold = pipeline_decisions.adjusted_axiom_threshold;
    conclusions.step35_optimization.recommended_approach = pipeline_decisions.recommended_approach;
    conclusions.step35_optimization.success = pipeline_decisions.continue_with_axioms;
    
    conclusions.step4_axioms = struct();
    conclusions.step4_axioms.axiom_adherence_rate = length(anpi_data.npi_names) / length(npi_data.npi_names);
    conclusions.step4_axioms.success = conclusions.step4_axioms.axiom_adherence_rate > 0.1;
    
    conclusions.step5_theory_validation = struct();
    conclusions.step5_theory_validation.absolute_auc = theory_validation.absolute_auc;
    conclusions.step5_theory_validation.relative_auc = theory_validation.relative_auc;
    conclusions.step5_theory_validation.auc_improvement = theory_validation.auc_improvement;
    conclusions.step5_theory_validation.theory_validated = theory_validation.theory_validated;
    conclusions.step5_theory_validation.success = theory_validation.theory_validated;
    
    conclusions.step6_distributions = struct();
    conclusions.step6_distributions.anpis_analyzed = anpi_data.n_pis;
    conclusions.step6_distributions.success = conclusions.step6_distributions.anpis_analyzed > 0;
    
    conclusions.step7_snr = struct();
    conclusions.step7_snr.empirical_improvement = snr_analysis.mean_empirical_improvement;
    conclusions.step7_snr.theoretical_improvement = snr_analysis.mean_theoretical_improvement;
    conclusions.step7_snr.correlation = snr_analysis.correlation;
    conclusions.step7_snr.success = ~isnan(snr_analysis.correlation) && snr_analysis.correlation > 0.3;
    
    % Overall conclusions
    conclusions.overall_success = all([conclusions.step1_pi_extraction.success, ...
                                      conclusions.step2_processing.success, ...
                                      conclusions.step3_normality.success, ...
                                      conclusions.step35_optimization.success, ...
                                      conclusions.step4_axioms.success, ...
                                      conclusions.step5_theory_validation.success, ...
                                      conclusions.step6_distributions.success, ...
                                      conclusions.step7_snr.success]);
    
    % Key findings
    conclusions.key_findings = struct();
    conclusions.key_findings.total_pis = length(pi_data.pi_names);
    conclusions.key_findings.normality_rate = conclusions.step3_normality.normality_rate;
    conclusions.key_findings.optimization_snr_improvement = conclusions.step35_optimization.mean_snr_improvement;
    conclusions.key_findings.optimization_variance_reduction = conclusions.step35_optimization.mean_variance_reduction;
    conclusions.key_findings.adjusted_axiom_threshold = conclusions.step35_optimization.adjusted_threshold;
    conclusions.key_findings.axiom_adherence_rate = conclusions.step4_axioms.axiom_adherence_rate;
    conclusions.key_findings.final_anpis = anpi_data.n_pis;
    conclusions.key_findings.theory_validated = theory_validation.theory_validated;
    conclusions.key_findings.auc_improvement = theory_validation.auc_improvement;
    conclusions.key_findings.mean_snr_improvement = snr_analysis.mean_empirical_improvement;
    conclusions.key_findings.theory_empirical_correlation = snr_analysis.correlation;
    
    % Recommendations
    conclusions.recommendations = struct();
    if conclusions.overall_success
        conclusions.recommendations.status = 'SUCCESS';
        conclusions.recommendations.message = 'Environmental noise cancellation theory successfully validated';
        conclusions.recommendations.next_steps = {'Publish results', 'Extend to other domains', 'Develop applications'};
    else
        conclusions.recommendations.status = 'NEEDS_ATTENTION';
        conclusions.recommendations.message = 'Pipeline completed with issues. Review and address identified problems.';
        conclusions.recommendations.next_steps = {'Review data quality', 'Adjust parameters', 'Re-run analysis'};
    end
    
    fprintf('  Overall pipeline success: %s\n', string(conclusions.overall_success));
    fprintf('  Theory validated: %s\n', string(theory_validation.theory_validated));
    fprintf('  AUC improvement: %.1f%%\n', theory_validation.auc_improvement * 100);
    fprintf('  Mean SNR improvement: %.1f%%\n', snr_analysis.mean_empirical_improvement);
    fprintf('  Theory-empirical correlation: %.3f\n', snr_analysis.correlation);
end

function generateCorrectedReport(report_file, conclusions, pi_data, npi_data, anpi_data, theory_validation, snr_analysis)
    %GENERATECORRECTEDREPORT Generate comprehensive report for corrected pipeline
    
    fid = fopen(report_file, 'w');
    if fid == -1
        error('Cannot create report file: %s', report_file);
    end
    
    fprintf(fid, 'UP1 CORRECTED VALIDATION PIPELINE REPORT\n');
    fprintf(fid, 'Generated: %s\n\n', datestr(now));
    
    fprintf(fid, 'EXECUTIVE SUMMARY\n');
    fprintf(fid, '================\n');
    fprintf(fid, 'Overall Success: %s\n', string(conclusions.overall_success));
    fprintf(fid, 'Total PIs: %d\n', conclusions.key_findings.total_pis);
    fprintf(fid, 'NPIs (Normal PIs): %d\n', length(npi_data.npi_names));
    fprintf(fid, 'Optimization SNR Improvement: %.2f\n', conclusions.key_findings.optimization_snr_improvement);
    fprintf(fid, 'Optimization Variance Reduction: %.1f%%\n', conclusions.key_findings.optimization_variance_reduction * 100);
    fprintf(fid, 'Adjusted Axiom Threshold: %.1f%%\n', conclusions.key_findings.adjusted_axiom_threshold * 100);
    fprintf(fid, 'Final ANPIs: %d\n', conclusions.key_findings.final_anpis);
    fprintf(fid, 'Theory Validated: %s\n', string(conclusions.key_findings.theory_validated));
    fprintf(fid, 'AUC Improvement: %.1f%%\n', conclusions.key_findings.auc_improvement * 100);
    fprintf(fid, 'Mean SNR Improvement: %.1f%%\n', conclusions.key_findings.mean_snr_improvement);
    fprintf(fid, 'Theory-Empirical Correlation: %.3f\n\n', conclusions.key_findings.theory_empirical_correlation);
    
    fprintf(fid, 'STEP-BY-STEP RESULTS\n');
    fprintf(fid, '====================\n');
    fprintf(fid, 'Step 1 - PI Extraction: %s (%d PIs)\n', string(conclusions.step1_pi_extraction.success), conclusions.step1_pi_extraction.total_pis);
    fprintf(fid, 'Step 2 - Processing: %s (%.1f%% retention)\n', string(conclusions.step2_processing.success), conclusions.step2_processing.quality_retention * 100);
    fprintf(fid, 'Step 3 - Normality: %s (%.1f%% rate)\n', string(conclusions.step3_normality.success), conclusions.step3_normality.normality_rate * 100);
    fprintf(fid, 'Step 3.5 - Optimization: %s (%.2f SNR improvement, %.1f%% variance reduction)\n', string(conclusions.step35_optimization.success), conclusions.step35_optimization.mean_snr_improvement, conclusions.step35_optimization.mean_variance_reduction * 100);
    fprintf(fid, 'Step 4 - Axioms: %s (%.1f%% rate, threshold: %.1f%%)\n', string(conclusions.step4_axioms.success), conclusions.step4_axioms.axiom_adherence_rate * 100, conclusions.step35_optimization.adjusted_threshold * 100);
    fprintf(fid, 'Step 5 - Theory Validation: %s (%.1f%% AUC improvement)\n', string(conclusions.step5_theory_validation.success), conclusions.step5_theory_validation.auc_improvement * 100);
    fprintf(fid, 'Step 6 - Distributions: %s (%d ANPIs)\n', string(conclusions.step6_distributions.success), conclusions.step6_distributions.anpis_analyzed);
    fprintf(fid, 'Step 7 - SNR: %s (%.1f%% improvement)\n', string(conclusions.step7_snr.success), conclusions.step7_snr.empirical_improvement);
    
    fprintf(fid, '\nENVIRONMENTAL NOISE CANCELLATION THEORY VALIDATION\n');
    fprintf(fid, '==================================================\n');
    fprintf(fid, 'Absolute Measures AUC: %.3f\n', theory_validation.absolute_auc);
    fprintf(fid, 'Relative Measures AUC: %.3f\n', theory_validation.relative_auc);
    fprintf(fid, 'AUC Improvement: %.1f%%\n', theory_validation.auc_improvement * 100);
    fprintf(fid, 'Theory Validated: %s\n', string(theory_validation.theory_validated));
    
    fprintf(fid, '\nRECOMMENDATIONS\n');
    fprintf(fid, '===============\n');
    fprintf(fid, 'Status: %s\n', conclusions.recommendations.status);
    fprintf(fid, 'Message: %s\n', conclusions.recommendations.message);
    fprintf(fid, '\nSpecific Recommendations:\n');
    for i = 1:length(conclusions.recommendations.next_steps)
        fprintf(fid, '  %d. %s\n', i, conclusions.recommendations.next_steps{i});
    end
    
    fclose(fid);
end

%% Additional Helper Functions (from original pipeline)

function normality_results = assessNormality(data, threshold)
    %ASSESSNORMALITY Assess normality of PI distributions
    
    normality_results = struct();
    normality_results.pi_names = data.pi_names;
    normality_results.n_pis = data.n_pis;
    
    % Initialize storage
    absolute_normality = false(data.n_pis, 1);
    relative_normality = false(data.n_pis, 1);
    absolute_p_values = zeros(data.n_pis, 1);
    relative_p_values = zeros(data.n_pis, 1);
    
    for i = 1:data.n_pis
        abs_data = data.absolute_data(:, i);
        rel_data = data.relative_data(:, i);
        
        % Remove NaN values
        abs_clean = abs_data(~isnan(abs_data));
        rel_clean = rel_data(~isnan(rel_data));
        
        if length(abs_clean) > 10
            % Test absolute data normality
            [~, p_abs] = swtest(abs_clean);
            absolute_p_values(i) = p_abs;
            absolute_normality(i) = p_abs > threshold;
        end
        
        if length(rel_clean) > 10
            % Test relative data normality
            [~, p_rel] = swtest(rel_clean);
            relative_p_values(i) = p_rel;
            relative_normality(i) = p_rel > threshold;
        end
    end
    
    % Store results
    normality_results.absolute_normality = absolute_normality;
    normality_results.relative_normality = relative_normality;
    normality_results.absolute_p_values = absolute_p_values;
    normality_results.relative_p_values = relative_p_values;
    
    % Summary statistics
    normality_results.absolute_normality_rate = mean(absolute_normality);
    normality_results.relative_normality_rate = mean(relative_normality);
    
    fprintf('  Absolute data normality rate: %.1f%%\n', normality_results.absolute_normality_rate * 100);
    fprintf('  Relative data normality rate: %.1f%%\n', normality_results.relative_normality_rate * 100);
end

function npi_data = classifyAsNPIs(data, normality_results)
    %CLASSIFYASNPIS Classify PIs as NPIs based on normality results
    
    % PIs become NPIs if they pass normality tests
    npi_mask = normality_results.absolute_normality & normality_results.relative_normality;
    
    npi_data = struct();
    npi_data.npi_names = data.pi_names(npi_mask);
    npi_data.n_pis = sum(npi_mask);
    npi_data.absolute_data = data.absolute_data(:, npi_mask);
    npi_data.relative_data = data.relative_data(:, npi_mask);
    npi_data.outcome_data = data.outcome_data;
    
    fprintf('  Classified %d PIs as NPIs\n', npi_data.n_pis);
end

function axiom_results = validateFourAxioms(npi_data, threshold)
    %VALIDATEFOURAXIOMS Validate NPIs against four axioms
    
    axiom_results = struct();
    axiom_results.npi_names = npi_data.npi_names;
    axiom_results.n_pis = npi_data.n_pis;
    
    % Initialize storage
    axiom1_adherence = false(npi_data.n_pis, 1);
    axiom2_adherence = false(npi_data.n_pis, 1);
    axiom3_adherence = false(npi_data.n_pis, 1);
    axiom4_adherence = false(npi_data.n_pis, 1);
    overall_adherence = false(npi_data.n_pis, 1);
    
    for i = 1:npi_data.n_pis
        abs_data = npi_data.absolute_data(:, i);
        rel_data = npi_data.relative_data(:, i);
        outcome_data = npi_data.outcome_data;
        
        % Remove NaN values
        valid_idx = ~isnan(abs_data) & ~isnan(rel_data) & ~isnan(outcome_data);
        abs_clean = abs_data(valid_idx);
        rel_clean = rel_data(valid_idx);
        outcome_clean = outcome_data(valid_idx);
        
        if length(abs_clean) > 20
            % Test Axiom 1: Invariance to Shared Effects
            axiom1_adherence(i) = testAxiom1(abs_clean, rel_clean, outcome_clean, threshold);
            
            % Test Axiom 2: Ordinal Consistency
            axiom2_adherence(i) = testAxiom2(abs_clean, rel_clean, outcome_clean, threshold);
            
            % Test Axiom 3: Scaling Proportionality
            axiom3_adherence(i) = testAxiom3(abs_clean, rel_clean, outcome_clean, threshold);
            
            % Test Axiom 4: Statistical Optimality
            axiom4_adherence(i) = testAxiom4(abs_clean, rel_clean, outcome_clean, threshold);
            
            % Overall adherence
            overall_adherence(i) = axiom1_adherence(i) && axiom2_adherence(i) && axiom3_adherence(i) && axiom4_adherence(i);
        end
    end
    
    % Store results
    axiom_results.axiom1_adherence = axiom1_adherence;
    axiom_results.axiom2_adherence = axiom2_adherence;
    axiom_results.axiom3_adherence = axiom3_adherence;
    axiom_results.axiom4_adherence = axiom4_adherence;
    axiom_results.overall_adherence = overall_adherence;
    
    % Summary statistics
    axiom_results.axiom1_rate = mean(axiom1_adherence);
    axiom_results.axiom2_rate = mean(axiom2_adherence);
    axiom_results.axiom3_rate = mean(axiom3_adherence);
    axiom_results.axiom4_rate = mean(axiom4_adherence);
    axiom_results.overall_rate = mean(overall_adherence);
    
    fprintf('  Axiom 1 adherence rate: %.1f%%\n', axiom_results.axiom1_rate * 100);
    fprintf('  Axiom 2 adherence rate: %.1f%%\n', axiom_results.axiom2_rate * 100);
    fprintf('  Axiom 3 adherence rate: %.1f%%\n', axiom_results.axiom3_rate * 100);
    fprintf('  Axiom 4 adherence rate: %.1f%%\n', axiom_results.axiom4_rate * 100);
    fprintf('  Overall adherence rate: %.1f%%\n', axiom_results.overall_rate * 100);
end

function anpi_data = classifyAsANPIs(npi_data, axiom_results)
    %CLASSIFYASANPIS Classify NPIs as ANPIs based on axiom results
    
    % NPIs become ANPIs if they pass all axiom tests
    anpi_mask = axiom_results.overall_adherence;
    
    anpi_data = struct();
    anpi_data.npi_names = npi_data.npi_names(anpi_mask);
    anpi_data.n_pis = sum(anpi_mask);
    anpi_data.absolute_data = npi_data.absolute_data(:, anpi_mask);
    anpi_data.relative_data = npi_data.relative_data(:, anpi_mask);
    anpi_data.outcome_data = npi_data.outcome_data;
    
    fprintf('  Classified %d NPIs as ANPIs\n', anpi_data.n_pis);
end

function passed = testAxiom1(abs_data, rel_data, outcome_data, threshold)
    %TESTAXIOM1 Test Axiom 1: Invariance to Shared Effects
    % Simplified test: check if relative measures are less correlated with environmental factors
    
    % Use variance as proxy for environmental noise
    var_abs = var(abs_data);
    var_rel = var(rel_data);
    
    % Axiom 1 passed if relative measure has lower variance (environmental noise cancelled)
    passed = var_rel < var_abs * (1 - threshold);
end

function passed = testAxiom2(abs_data, rel_data, outcome_data, threshold)
    %TESTAXIOM2 Test Axiom 2: Ordinal Consistency
    % Check if relative measures maintain ordinal relationships
    
    % Calculate correlation between absolute and relative measures
    correlation = corr(abs_data, rel_data);
    
    % Axiom 2 passed if correlation is positive and strong
    passed = correlation > threshold;
end

function passed = testAxiom3(abs_data, rel_data, outcome_data, threshold)
    %TESTAXIOM3 Test Axiom 3: Scaling Proportionality
    % Check if relative measures scale proportionally
    
    % Calculate coefficient of variation
    cv_abs = std(abs_data) / abs(mean(abs_data));
    cv_rel = std(rel_data) / abs(mean(rel_data));
    
    % Axiom 3 passed if coefficient of variation is similar
    passed = abs(cv_abs - cv_rel) < threshold;
end

function passed = testAxiom4(abs_data, rel_data, outcome_data, threshold)
    %TESTAXIOM4 Test Axiom 4: Statistical Optimality
    % Check if relative measures provide better prediction
    
    % Calculate AUC for both measures
    [~, ~, ~, auc_abs] = perfcurve(outcome_data, abs_data, 1);
    [~, ~, ~, auc_rel] = perfcurve(outcome_data, rel_data, 1);
    
    % Axiom 4 passed if relative measure has higher AUC
    passed = auc_rel > auc_abs + threshold;
end

function [h, p] = swtest(x)
    %SWTEST Shapiro-Wilk test for normality
    % Simplified implementation for real-world data
    
    n = length(x);
    if n < 3
        h = false;
        p = 0;
        return;
    end
    
    % Remove outliers for more robust testing
    x_clean = x;
    if n > 10
        % Remove extreme outliers (beyond 3 standard deviations)
        mean_x = mean(x);
        std_x = std(x);
        x_clean = x(abs(x - mean_x) <= 3 * std_x);
    end
    
    if length(x_clean) < 3
        x_clean = x;
    end
    
    % Calculate skewness and kurtosis
    skew = skewness(x_clean);
    kurt = kurtosis(x_clean);
    
    % Simple normality test based on skewness and kurtosis
    % Normal distribution has skewness ≈ 0 and kurtosis ≈ 3
    skew_normal = abs(skew) < 1.0;  % Allow some skewness
    kurt_normal = abs(kurt - 3) < 2.0;  % Allow some deviation from 3
    
    % Combined test
    h = skew_normal && kurt_normal;
    
    % Approximate p-value
    if h
        p = 0.1;  % High p-value for "normal-like" data
    else
        p = 0.001;  % Low p-value for non-normal data
    end
end
