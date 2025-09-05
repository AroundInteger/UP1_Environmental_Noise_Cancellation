function Log_Transformed_SEF_Analysis()
%LOG_TRANSFORMED_SEF_ANALYSIS SEF analysis with log-transformed KPIs
%
% This script applies log transformation to rugby KPIs and calculates SEF
% to assess whether log transformation enhances signal enhancement.
%
% Author: UP1 Research Team
% Date: 2024

fprintf('=== Log-Transformed SEF Analysis ===\n\n');

%% Step 1: Load raw data
fprintf('Step 1: Loading raw data...\n');
try
    % Get project root
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(script_dir);
    cd(project_root);
    
    % Load raw CSV data
    raw_data_file = fullfile(project_root, 'data', 'raw', '4_seasons rowan.csv');
    if ~exist(raw_data_file, 'file')
        error('Raw data file not found: %s', raw_data_file);
    end
    
    raw_data = readtable(raw_data_file);
    fprintf('  ✓ Loaded raw data: %d rows, %d columns\n', height(raw_data), width(raw_data));
    
catch ME
    fprintf('  ✗ Failed to load raw data: %s\n', ME.message);
    return;
end

%% Step 2: Extract paired team data
fprintf('\nStep 2: Extracting paired team data...\n');

% Get unique match IDs
unique_matches = unique(raw_data.matchid);
n_matches = length(unique_matches);
fprintf('  Found %d unique matches\n', n_matches);

% Define metrics to analyze
metric_names = {
    'carries', 'metres_made', 'defenders_beaten', 'clean_breaks', ...
    'offloads', 'passes', 'turnovers_conceded', 'turnovers_won', ...
    'kicks_from_hand', 'kick_metres', 'scrums_won', 'rucks_won', ...
    'lineout_throws_lost', 'lineout_throws_won', 'tackles', 'missed_tackles', ...
    'penalties_conceded', 'scrum_pens_conceded', 'lineout_pens_conceded', ...
    'general_play_pens_conceded', 'free_kicks_conceded', ...
    'ruck_maul_tackle_pen_con', 'red_cards', 'yellow_cards'
};

n_metrics = length(metric_names);

% Initialize arrays for paired team performances
team_a_performance = zeros(n_matches, n_metrics);
team_b_performance = zeros(n_matches, n_metrics);
match_ids = zeros(n_matches, 1);
seasons = cell(n_matches, 1);

% Extract paired team performances
for m = 1:n_matches
    match_id = unique_matches(m);
    match_mask = raw_data.matchid == match_id;
    match_data = raw_data(match_mask, :);
    
    if height(match_data) ~= 2
        continue;
    end
    
    % Store match information
    match_ids(m) = match_id;
    seasons{m} = match_data.season{1};
    
    % Extract paired team performances for each metric
    for i = 1:n_metrics
        metric = metric_names{i};
        abs_col = [metric '_i'];
        
        if ismember(abs_col, raw_data.Properties.VariableNames)
            team_a_performance(m, i) = match_data.(abs_col)(1);
            team_b_performance(m, i) = match_data.(abs_col)(2);
        else
            team_a_performance(m, i) = NaN;
            team_b_performance(m, i) = NaN;
        end
    end
end

fprintf('  ✓ Extracted paired team performances for %d matches\n', n_matches);

%% Step 3: Apply log transformation
fprintf('\nStep 3: Applying log transformation...\n');

% Apply log transformation: log(x + 1) to handle zeros
team_a_log = log(team_a_performance + 1);
team_b_log = log(team_b_performance + 1);

fprintf('  ✓ Applied log(x + 1) transformation to all metrics\n');

%% Step 4: Calculate SEF for log-transformed data
fprintf('\nStep 4: Calculating SEF for log-transformed data...\n');

% Initialize results
sef_log_values = zeros(n_metrics, 1);
mu_a_log_values = zeros(n_metrics, 1);
mu_b_log_values = zeros(n_metrics, 1);
sigma_a_log_values = zeros(n_metrics, 1);
sigma_b_log_values = zeros(n_metrics, 1);
rho_log_values = zeros(n_metrics, 1);
kappa_log_values = zeros(n_metrics, 1);
delta_log_values = zeros(n_metrics, 1);

for i = 1:n_metrics
    metric = metric_names{i};
    
    % Extract log-transformed paired performances
    team_a_log_clean = team_a_log(:, i);
    team_b_log_clean = team_b_log(:, i);
    
    % Remove NaN values
    valid_mask = ~isnan(team_a_log_clean) & ~isnan(team_b_log_clean);
    team_a_log_valid = team_a_log_clean(valid_mask);
    team_b_log_valid = team_b_log_clean(valid_mask);
    
    if length(team_a_log_valid) < 10
        fprintf('  %s: Insufficient data (%d valid pairs)\n', metric, length(team_a_log_valid));
        sef_log_values(i) = NaN;
        continue;
    end
    
    % Calculate SEF parameters for log-transformed data
    mu_a_log = mean(team_a_log_valid);
    mu_b_log = mean(team_b_log_valid);
    sigma_a_log = std(team_a_log_valid);
    sigma_b_log = std(team_b_log_valid);
    
    % Calculate correlation
    if sigma_a_log > 0 && sigma_b_log > 0
        rho_log = corr(team_a_log_valid, team_b_log_valid);
    else
        rho_log = 0;
    end
    
    % Calculate SEF parameters
    delta_log = abs(mu_a_log - mu_b_log);
    kappa_log = (sigma_b_log^2) / (sigma_a_log^2);
    
    % Calculate SEF
    if kappa_log > 0
        sef_log = (1 + kappa_log) / (1 + kappa_log - 2*sqrt(kappa_log)*rho_log);
    else
        sef_log = NaN;
    end
    
    % Store results
    sef_log_values(i) = sef_log;
    mu_a_log_values(i) = mu_a_log;
    mu_b_log_values(i) = mu_b_log;
    sigma_a_log_values(i) = sigma_a_log;
    sigma_b_log_values(i) = sigma_b_log;
    rho_log_values(i) = rho_log;
    kappa_log_values(i) = kappa_log;
    delta_log_values(i) = delta_log;
    
    fprintf('  %s: SEF_log = %.3f (κ = %.3f, ρ = %.3f, δ = %.3f)\n', ...
        metric, sef_log, kappa_log, rho_log, delta_log);
end

%% Step 5: Load original SEF results for comparison
fprintf('\nStep 5: Loading original SEF results for comparison...\n');

try
    load('outputs/results/corrected_sef_sensitivity_analysis.mat');
    fprintf('  ✓ Loaded original SEF results\n');
catch
    fprintf('  ✗ Could not load original SEF results\n');
    return;
end

%% Step 6: Compare log-transformed vs original SEF
fprintf('\nStep 6: Comparing log-transformed vs original SEF...\n');

% Calculate improvement ratios
improvement_ratios = sef_log_values ./ sef_results.sef_values;
valid_improvement = improvement_ratios(~isnan(improvement_ratios) & ~isnan(sef_log_values));

fprintf('  Log-transformed SEF improvement analysis:\n');
fprintf('  Mean improvement ratio: %.3f\n', mean(valid_improvement));
fprintf('  Median improvement ratio: %.3f\n', median(valid_improvement));
fprintf('  Std improvement ratio: %.3f\n', std(valid_improvement));
fprintf('  Min improvement ratio: %.3f\n', min(valid_improvement));
fprintf('  Max improvement ratio: %.3f\n', max(valid_improvement));
fprintf('  Metrics with improvement > 1.0: %d/%d\n', sum(valid_improvement > 1.0), length(valid_improvement));

%% Step 7: Generate comparison report
fprintf('\nStep 7: Generating comparison report...\n');

% Create results directory
results_dir = fullfile(project_root, 'outputs', 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Save log-transformed results
log_results = struct();
log_results.metric_names = metric_names;
log_results.sef_log_values = sef_log_values;
log_results.mu_a_log_values = mu_a_log_values;
log_results.mu_b_log_values = mu_b_log_values;
log_results.sigma_a_log_values = sigma_a_log_values;
log_results.sigma_b_log_values = sigma_b_log_values;
log_results.rho_log_values = rho_log_values;
log_results.kappa_log_values = kappa_log_values;
log_results.delta_log_values = delta_log_values;
log_results.improvement_ratios = improvement_ratios;

log_results_file = fullfile(results_dir, 'log_transformed_sef_analysis.mat');
save(log_results_file, 'log_results', '-v7.3');
fprintf('  ✓ Saved log-transformed results: %s\n', log_results_file);

% Generate comparison report
report_file = fullfile(results_dir, 'log_transformed_sef_comparison_report.txt');
fid = fopen(report_file, 'w');

fprintf(fid, 'Log-Transformed SEF Analysis Comparison Report\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));

fprintf(fid, 'SUMMARY STATISTICS:\n');
fprintf(fid, '  Original SEF - Mean: %.3f, Median: %.3f, Std: %.3f\n', ...
    mean(sef_results.sef_values), median(sef_results.sef_values), std(sef_results.sef_values));
fprintf(fid, '  Log SEF - Mean: %.3f, Median: %.3f, Std: %.3f\n', ...
    mean(sef_log_values(~isnan(sef_log_values))), median(sef_log_values(~isnan(sef_log_values))), std(sef_log_values(~isnan(sef_log_values))));
fprintf(fid, '  Improvement Ratio - Mean: %.3f, Median: %.3f, Std: %.3f\n', ...
    mean(valid_improvement), median(valid_improvement), std(valid_improvement));

fprintf(fid, '\nMETRIC COMPARISON:\n');
fprintf(fid, 'Metric Name | Original SEF | Log SEF | Improvement Ratio\n');
fprintf(fid, '--------------------------------------------------------\n');
for i = 1:n_metrics
    if ~isnan(sef_log_values(i)) && ~isnan(sef_results.sef_values(i))
        fprintf(fid, '%-20s | %11.3f | %7.3f | %15.3f\n', ...
            metric_names{i}, sef_results.sef_values(i), sef_log_values(i), improvement_ratios(i));
    end
end

fclose(fid);
fprintf('  ✓ Comparison report generated: %s\n', report_file);

%% Final summary
fprintf('\n=== LOG-TRANSFORMED SEF ANALYSIS COMPLETED ===\n');
fprintf('✓ Log transformation applied to all KPIs\n');
fprintf('✓ SEF calculated for log-transformed data\n');
fprintf('✓ Comparison with original SEF completed\n');
fprintf('\nKey findings:\n');
fprintf('  Mean improvement ratio: %.3f\n', mean(valid_improvement));
fprintf('  Metrics with improvement: %d/%d\n', sum(valid_improvement > 1.0), length(valid_improvement));
if mean(valid_improvement) > 1.0
    fprintf('  Log transformation enhances signal enhancement\n');
else
    fprintf('  Log transformation reduces signal enhancement\n');
end

end
