function Analyze_Log_Transformation_Results()
%ANALYZE_LOG_TRANSFORMATION_RESULTS Analyze which KPIs benefit from log-transformation
%
% This script analyzes the log-transformation results to identify which
% KPIs show significant SEF improvement with log transformation.
%
% Author: UP1 Research Team
% Date: 2024

fprintf('=== Log-Transformation SEF Improvement Analysis ===\n\n');

%% Load results
fprintf('Loading results...\n');
try
    % Get project root
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(script_dir);
    cd(project_root);
    
    load('outputs/results/log_transformed_sef_analysis.mat');
    load('outputs/results/corrected_sef_sensitivity_analysis.mat');
    fprintf('  ✓ Results loaded successfully\n');
catch ME
    fprintf('  ✗ Failed to load results: %s\n', ME.message);
    return;
end

%% Analyze log-transformation improvements
fprintf('\nAnalyzing log-transformation improvements...\n');

% Create comparison table
n_metrics = length(log_results.metric_names);
comparison_data = struct();
comparison_data.metric_names = log_results.metric_names;
comparison_data.original_sef = sef_results.sef_values;
comparison_data.log_sef = log_results.sef_log_values;
comparison_data.improvement_ratio = log_results.improvement_ratios;
comparison_data.pct_change = (log_results.improvement_ratios - 1) * 100;

% Display detailed comparison
fprintf('\nDetailed Comparison:\n');
fprintf('%-20s | %11s | %7s | %10s | %8s\n', 'Metric Name', 'Original SEF', 'Log SEF', 'Improvement', '% Change');
fprintf('%-20s-+-%11s-+-%7s-+-%10s-+-%8s\n', repmat('-', 1, 20), repmat('-', 1, 11), repmat('-', 1, 7), repmat('-', 1, 10), repmat('-', 1, 8));

for i = 1:n_metrics
    if ~isnan(comparison_data.original_sef(i)) && ~isnan(comparison_data.log_sef(i))
        fprintf('%-20s | %11.3f | %7.3f | %10.3f | %8.1f%%\n', ...
            comparison_data.metric_names{i}, ...
            comparison_data.original_sef(i), ...
            comparison_data.log_sef(i), ...
            comparison_data.improvement_ratio(i), ...
            comparison_data.pct_change(i));
    end
end

%% Calculate summary statistics
fprintf('\nSummary Statistics:\n');
valid_improvements = comparison_data.improvement_ratio(~isnan(comparison_data.improvement_ratio));
n_valid = length(valid_improvements);

fprintf('  Total metrics analyzed: %d\n', n_metrics);
fprintf('  Valid comparisons: %d\n', n_valid);
fprintf('  Mean improvement ratio: %.3f\n', mean(valid_improvements));
fprintf('  Median improvement ratio: %.3f\n', median(valid_improvements));
fprintf('  Std improvement ratio: %.3f\n', std(valid_improvements));
fprintf('  Min improvement ratio: %.3f\n', min(valid_improvements));
fprintf('  Max improvement ratio: %.3f\n', max(valid_improvements));

%% Categorize improvements
fprintf('\nImprovement Categories:\n');
improvement_1_0 = sum(valid_improvements > 1.0);
improvement_1_1 = sum(valid_improvements > 1.1);
improvement_1_2 = sum(valid_improvements > 1.2);
improvement_1_3 = sum(valid_improvements > 1.3);
improvement_1_5 = sum(valid_improvements > 1.5);

fprintf('  Metrics with improvement > 1.0: %d/%d (%.1f%%)\n', improvement_1_0, n_valid, improvement_1_0/n_valid*100);
fprintf('  Metrics with improvement > 1.1: %d/%d (%.1f%%)\n', improvement_1_1, n_valid, improvement_1_1/n_valid*100);
fprintf('  Metrics with improvement > 1.2: %d/%d (%.1f%%)\n', improvement_1_2, n_valid, improvement_1_2/n_valid*100);
fprintf('  Metrics with improvement > 1.3: %d/%d (%.1f%%)\n', improvement_1_3, n_valid, improvement_1_3/n_valid*100);
fprintf('  Metrics with improvement > 1.5: %d/%d (%.1f%%)\n', improvement_1_5, n_valid, improvement_1_5/n_valid*100);

%% Identify top performers
fprintf('\nTop Performing Metrics (Log-Transformation):\n');
[sorted_improvements, sort_idx] = sort(valid_improvements, 'descend');
top_n = min(10, length(sorted_improvements));

for i = 1:top_n
    idx = sort_idx(i);
    fprintf('  %d. %s: %.3f (%.1f%% improvement)\n', i, ...
        comparison_data.metric_names{idx}, ...
        sorted_improvements(i), ...
        (sorted_improvements(i) - 1) * 100);
end

%% Identify metrics that require log-transformation
fprintf('\nMetrics Requiring Log-Transformation (Improvement > 1.1):\n');
significant_improvement_mask = valid_improvements > 1.1;
significant_metrics = comparison_data.metric_names(significant_improvement_mask);
significant_ratios = valid_improvements(significant_improvement_mask);

if ~isempty(significant_metrics)
    for i = 1:length(significant_metrics)
        fprintf('  - %s: %.3f (%.1f%% improvement)\n', ...
            significant_metrics{i}, ...
            significant_ratios(i), ...
            (significant_ratios(i) - 1) * 100);
    end
else
    fprintf('  No metrics show significant improvement (>1.1) with log-transformation\n');
end

%% Save results
fprintf('\nSaving analysis results...\n');
save('outputs/results/log_transformation_analysis.mat', 'comparison_data', 'valid_improvements', 'significant_metrics', 'significant_ratios');

% Generate report
report_file = 'outputs/results/log_transformation_analysis_report.txt';
fid = fopen(report_file, 'w');

fprintf(fid, 'Log-Transformation SEF Improvement Analysis Report\n');
fprintf(fid, '================================================\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));

fprintf(fid, 'SUMMARY:\n');
fprintf(fid, '========\n');
fprintf(fid, 'Total metrics analyzed: %d\n', n_metrics);
fprintf(fid, 'Valid comparisons: %d\n', n_valid);
fprintf(fid, 'Mean improvement ratio: %.3f\n', mean(valid_improvements));
fprintf(fid, 'Median improvement ratio: %.3f\n', median(valid_improvements));
fprintf(fid, 'Std improvement ratio: %.3f\n', std(valid_improvements));

fprintf(fid, '\nIMPROVEMENT CATEGORIES:\n');
fprintf(fid, '======================\n');
fprintf(fid, 'Metrics with improvement > 1.0: %d/%d (%.1f%%)\n', improvement_1_0, n_valid, improvement_1_0/n_valid*100);
fprintf(fid, 'Metrics with improvement > 1.1: %d/%d (%.1f%%)\n', improvement_1_1, n_valid, improvement_1_1/n_valid*100);
fprintf(fid, 'Metrics with improvement > 1.2: %d/%d (%.1f%%)\n', improvement_1_2, n_valid, improvement_1_2/n_valid*100);
fprintf(fid, 'Metrics with improvement > 1.3: %d/%d (%.1f%%)\n', improvement_1_3, n_valid, improvement_1_3/n_valid*100);
fprintf(fid, 'Metrics with improvement > 1.5: %d/%d (%.1f%%)\n', improvement_1_5, n_valid, improvement_1_5/n_valid*100);

fprintf(fid, '\nMETRICS REQUIRING LOG-TRANSFORMATION:\n');
fprintf(fid, '=====================================\n');
if ~isempty(significant_metrics)
    for i = 1:length(significant_metrics)
        fprintf(fid, '%d. %s: %.3f (%.1f%% improvement)\n', i, ...
            significant_metrics{i}, ...
            significant_ratios(i), ...
            (significant_ratios(i) - 1) * 100);
    end
else
    fprintf(fid, 'No metrics show significant improvement (>1.1) with log-transformation\n');
end

fprintf(fid, '\nDETAILED COMPARISON:\n');
fprintf(fid, '===================\n');
fprintf(fid, '%-20s | %11s | %7s | %10s | %8s\n', 'Metric Name', 'Original SEF', 'Log SEF', 'Improvement', '% Change');
fprintf(fid, '%-20s-+-%11s-+-%7s-+-%10s-+-%8s\n', repmat('-', 1, 20), repmat('-', 1, 11), repmat('-', 1, 7), repmat('-', 1, 10), repmat('-', 1, 8));

for i = 1:n_metrics
    if ~isnan(comparison_data.original_sef(i)) && ~isnan(comparison_data.log_sef(i))
        fprintf(fid, '%-20s | %11.3f | %7.3f | %10.3f | %8.1f%%\n', ...
            comparison_data.metric_names{i}, ...
            comparison_data.original_sef(i), ...
            comparison_data.log_sef(i), ...
            comparison_data.improvement_ratio(i), ...
            comparison_data.pct_change(i));
    end
end

fclose(fid);
fprintf('  ✓ Analysis report generated: %s\n', report_file);

fprintf('\n=== Analysis Complete ===\n');
fprintf('✓ Log-transformation analysis completed\n');
fprintf('✓ Results saved and reported\n');
fprintf('✓ Metrics requiring log-transformation identified\n');

end
