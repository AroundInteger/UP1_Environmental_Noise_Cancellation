%% Test Axiom Validation for UP1 Environmental Noise Cancellation
% This script demonstrates how to validate KPIs against the 4 axioms
% that ensure effective environmental noise cancellation

clear; clc; close all;

fprintf('=== UP1 Axiom Validation Test ===\n\n');

%% Load Data
fprintf('Loading rugby analysis data...\n');

% Get the script directory and navigate to project root
script_dir = fileparts(mfilename('fullpath'));
project_root = fullfile(script_dir, '..');
cd(project_root);
fprintf('Changed to project directory: %s\n', pwd);

% Add source directories to MATLAB path
addpath(genpath('src'));
fprintf('Added source directories to MATLAB path\n');

try
    % Load the processed rugby data
    data_file = 'data/processed/rugby_analysis_ready.mat';
    if exist(data_file, 'file')
        load(data_file);
        fprintf('✓ Loaded data from %s\n', data_file);
    else
        error('Data file not found: %s', data_file);
    end
catch ME
    fprintf('✗ Error loading data: %s\n', ME.message);
    return;
end

%% Prepare Data for Axiom Validation
fprintf('\nPreparing data for axiom validation...\n');

% Check what data we have
fprintf('Available data fields:\n');
data_fields = fieldnames(analysis_data);
for i = 1:length(data_fields)
    field = data_fields{i};
    if isnumeric(analysis_data.(field))
        fprintf('  %s: %s [%d x %d]\n', field, class(analysis_data.(field)), ...
                size(analysis_data.(field), 1), size(analysis_data.(field), 2));
    else
        fprintf('  %s: %s\n', field, class(analysis_data.(field)));
    end
end

% Create data structure for axiom validation
validation_data = struct();
validation_data.outcome = analysis_data.outcome_binary;

% Add absolute features
if isfield(analysis_data, 'absolute_features') && isfield(analysis_data, 'absolute_feature_names')
    for i = 1:length(analysis_data.absolute_feature_names)
        metric_name = analysis_data.absolute_feature_names{i};
        validation_data.(metric_name) = analysis_data.absolute_features(:, i);
    end
    fprintf('✓ Added %d absolute features\n', length(analysis_data.absolute_feature_names));
end

% Add relative features
if isfield(analysis_data, 'relative_features') && isfield(analysis_data, 'relative_feature_names')
    for i = 1:length(analysis_data.relative_feature_names)
        metric_name = analysis_data.relative_feature_names{i};
        validation_data.(metric_name) = analysis_data.relative_features(:, i);
    end
    fprintf('✓ Added %d relative features\n', length(analysis_data.relative_feature_names));
end

% Add environmental factors if available
if isfield(analysis_data, 'season')
    validation_data.season = analysis_data.season;
    fprintf('✓ Added season as environmental factor\n');
end

if isfield(analysis_data, 'team')
    validation_data.team = analysis_data.team;
    fprintf('✓ Added team as environmental factor\n');
end

%% Run Axiom Validation
fprintf('\nRunning axiom validation...\n');

try
    % Run the axiom validation with default parameters
    [axiom_results, kpi_ranking, validation_summary] = axiomValidation(validation_data, ...
        'confidence_level', 0.95, ...
        'test_threshold', 0.6, ...  % More reasonable threshold for real-world data
        'verbose', true);
    
    fprintf('\n✓ Axiom validation completed successfully!\n');
    
catch ME
    fprintf('✗ Error during axiom validation: %s\n', ME.message);
    fprintf('Error details:\n');
    disp(getReport(ME, 'extended'));
    return;
end

%% Analyze Results
fprintf('\n=== DETAILED ANALYSIS ===\n');

% Display top performing KPIs
fprintf('\nTop 5 KPIs by Axiom Compliance:\n');
fprintf('Rank | KPI Name                    | Overall Score | Compliant Axioms | Status\n');
fprintf('-----|------------------------------|---------------|------------------|--------\n');
for i = 1:min(5, length(kpi_ranking.ranked_metrics))
    kpi = kpi_ranking.ranked_metrics{i};
    score = kpi_ranking.overall_scores(i);
    compliant = kpi_ranking.compliant_counts(i);
    
    if score >= 0.8
        status = 'Excellent';
    elseif score >= 0.7
        status = 'Good';
    elseif score >= 0.6
        status = 'Fair';
    else
        status = 'Poor';
    end
    
    fprintf('%4d | %-28s | %13.3f | %16d | %s\n', ...
            i, kpi, score, compliant, status);
end

% Display axiom-specific performance
fprintf('\nAxiom Performance Summary:\n');
axiom_names = {'Invariance to Shared Effects', 'Ordinal Consistency', 'Scaling Proportionality', 'Statistical Optimality'};
axiom_result_fields = {'axiom1', 'axiom2', 'axiom3', 'axiom4'};
axiom_stats_fields = {'Invariance_to_Shared_Effects', 'Ordinal_Consistency', 'Scaling_Proportionality', 'Statistical_Optimality'};
for a = 1:4
    stats_field = axiom_stats_fields{a};
    result_field = axiom_result_fields{a};
    stats = validation_summary.axiom_statistics.(stats_field);
    fprintf('  %s:\n', axiom_names{a});
    fprintf('    Average Score: %.3f ± %.3f\n', stats.mean, stats.std);
    fprintf('    Compliance: %.1f%% (%d/%d KPIs)\n', ...
            stats.compliant_percentage, stats.compliant_count, validation_summary.total_kpis);
    
    % Find best and worst KPIs for this axiom
    best_score = 0;
    worst_score = 1;
    best_kpi = '';
    worst_kpi = '';
    
    for m = 1:length(kpi_ranking.ranked_metrics)
        kpi = kpi_ranking.ranked_metrics{m};
        axiom_score = axiom_results.(kpi).(result_field).score;
        
        if axiom_score > best_score
            best_score = axiom_score;
            best_kpi = kpi;
        end
        if axiom_score < worst_score
            worst_score = axiom_score;
            worst_kpi = kpi;
        end
    end
    
    fprintf('    Best: %s (%.3f)\n', best_kpi, best_score);
    fprintf('    Worst: %s (%.3f)\n', worst_kpi, worst_score);
    fprintf('\n');
end

%% Generate Recommendations
fprintf('=== RECOMMENDATIONS ===\n');

% Overall recommendations
fprintf('\nOverall Status: %s\n', validation_summary.recommendations.overall_status);
fprintf('Message: %s\n', validation_summary.recommendations.overall_message);

% Priority and approach
fprintf('\nImprovement Strategy:\n');
fprintf('  Priority: %s\n', validation_summary.recommendations.improvement_strategy.priority);
fprintf('  Approach: %s\n', validation_summary.recommendations.improvement_strategy.approach);

% Next steps
fprintf('\nRecommended Next Steps:\n');
for i = 1:length(validation_summary.recommendations.improvement_strategy.next_steps)
    fprintf('  %d. %s\n', i, validation_summary.recommendations.improvement_strategy.next_steps{i});
end

%% Detailed KPI Analysis
fprintf('\n=== DETAILED KPI ANALYSIS ===\n');

% Analyze each KPI in detail
for i = 1:min(3, length(kpi_ranking.ranked_metrics))  % Top 3 KPIs
    kpi = kpi_ranking.ranked_metrics{i};
    fprintf('\n--- %s (Rank %d) ---\n', kpi, i);
    
    % Overall performance
    overall = axiom_results.(kpi).overall;
    fprintf('Overall Score: %.3f (%d/4 axioms compliant)\n', ...
            overall.score, overall.compliant_axioms);
    
    % Individual axiom scores
    fprintf('Individual Axiom Scores:\n');
    for a = 1:4
        axiom = sprintf('axiom%d', a);
        axiom_data = axiom_results.(kpi).(axiom);
        if axiom_data.compliant
            status = '✓';
        else
            status = '✗';
        end
        fprintf('  %s: %.3f %s\n', axiom_names{a}, axiom_data.score, status);
    end
    
    % Detailed analysis for non-compliant axioms
    fprintf('\nAreas for Improvement:\n');
    improvement_count = 0;
    for a = 1:4
        axiom = sprintf('axiom%d', a);
        axiom_data = axiom_results.(kpi).(axiom);
        
        if ~axiom_data.compliant
            improvement_count = improvement_count + 1;
            fprintf('  %s: Score %.3f (threshold: %.3f)\n', ...
                    axiom_names{a}, axiom_data.score, validation_summary.test_threshold);
            
            % Show specific details
            if isstruct(axiom_data.details) && isfield(axiom_data.details, 'methods_used')
                fprintf('    Methods used: %s\n', strjoin(axiom_data.details.methods_used, ', '));
            end
        end
    end
    
    if improvement_count == 0
        fprintf('  All axioms are compliant! ✓\n');
    end
end

%% Save Results
fprintf('\n=== SAVING RESULTS ===\n');

% Create output directory if it doesn't exist
output_dir = 'outputs/axiom_validation';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Save detailed results
output_file = fullfile(output_dir, 'axiom_validation_results.mat');
save(output_file, 'axiom_results', 'kpi_ranking', 'validation_summary', 'validation_data');
fprintf('✓ Saved detailed results to: %s\n', output_file);

% Generate summary report
report_file = fullfile(output_dir, 'axiom_validation_report.txt');
fid = fopen(report_file, 'w');

fprintf(fid, 'UP1 Axiom Validation Report\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));
fprintf(fid, 'Summary:\n');
fprintf(fid, '  Total KPIs: %d\n', validation_summary.total_kpis);
fprintf(fid, '  Overall Compliance: %.1f%% (%d/%d KPIs)\n', ...
        validation_summary.overall_compliance.compliant_percentage, ...
        validation_summary.overall_compliance.compliant_count, ...
        validation_summary.total_kpis);
fprintf(fid, '  Test Threshold: %.3f\n', validation_summary.test_threshold);

fprintf(fid, '\nTop Performing KPIs:\n');
for i = 1:length(validation_summary.top_kpis.names)
    fprintf(fid, '  %d. %s: %.3f (%d/4 axioms compliant)\n', ...
            i, validation_summary.top_kpis.names{i}, ...
            validation_summary.top_kpis.scores(i), ...
            validation_summary.top_kpis.compliant_axioms(i));
end

fprintf(fid, '\nRecommendations:\n');
fprintf(fid, '  Overall Status: %s\n', validation_summary.recommendations.overall_status);
fprintf(fid, '  %s\n', validation_summary.recommendations.overall_message);
fprintf(fid, '  Priority: %s\n', validation_summary.recommendations.improvement_strategy.priority);
fprintf(fid, '  Approach: %s\n', validation_summary.recommendations.improvement_strategy.approach);

fclose(fid);
fprintf('✓ Generated summary report: %s\n', report_file);

%% Final Summary
fprintf('\n=== VALIDATION COMPLETE ===\n');
fprintf('Successfully validated %d KPIs against the 4 axioms\n', validation_summary.total_kpis);
fprintf('Overall compliance: %.1f%% (%d/%d KPIs)\n', ...
        validation_summary.overall_compliance.compliant_percentage, ...
        validation_summary.overall_compliance.compliant_count, ...
        validation_summary.total_kpis);

if validation_summary.overall_compliance.compliant_percentage >= 80
    fprintf('🎉 Excellent! Most KPIs comply with the axioms.\n');
elseif validation_summary.overall_compliance.compliant_percentage >= 60
    fprintf('👍 Good performance with room for improvement.\n');
else
    fprintf('⚠️  Attention needed: Many KPIs need improvement.\n');
end

fprintf('\nResults saved to: %s\n', output_dir);
fprintf('Use these results to optimize KPIs for environmental noise cancellation.\n');
