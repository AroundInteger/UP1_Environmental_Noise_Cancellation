function Corrected_SEF_Sensitivity_Analysis()
%CORRECTED_SEF_SENSITIVITY_ANALYSIS Corrected SEF sensitivity analysis using paired team data
%
% This script correctly applies the SEF framework to rugby data by:
% 1. Extracting paired team performances from the same matches
% 2. Calculating proper μ_A, μ_B, σ_A, σ_B, ρ parameters
% 3. Computing SEF = (1 + κ) / (1 + κ - 2*√κ*ρ) where κ = σ²_B/σ²_A
%
% Author: UP1 Research Team
% Date: 2024

fprintf('=== Corrected SEF Sensitivity Analysis ===\n\n');

%% Step 1: Load raw data with match pairing information
fprintf('Step 1: Loading raw data with match pairing...\n');
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

%% Step 2: Extract paired team data for SEF analysis
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
fprintf('  Analyzing %d metrics\n', n_metrics);

% Initialize results structure
results = struct();
results.metric_names = metric_names;
results.n_matches = n_matches;
results.n_metrics = n_metrics;

% Initialize arrays for SEF calculations
team_a_performance = zeros(n_matches, n_metrics);
team_b_performance = zeros(n_matches, n_metrics);
match_ids = zeros(n_matches, 1);
seasons = cell(n_matches, 1);

%% Step 3: Extract paired team performances for each match
fprintf('\nStep 3: Extracting paired team performances...\n');

for m = 1:n_matches
    match_id = unique_matches(m);
    match_mask = raw_data.matchid == match_id;
    match_data = raw_data(match_mask, :);
    
    if height(match_data) ~= 2
        warning('Match %d has %d teams, expected 2', match_id, height(match_data));
        continue;
    end
    
    % Store match information
    match_ids(m) = match_id;
    seasons{m} = match_data.season{1};
    
    % Extract paired team performances for each metric
    for i = 1:n_metrics
        metric = metric_names{i};
        abs_col = [metric '_i'];
        rel_col = [metric '_r'];
        
        if ismember(abs_col, raw_data.Properties.VariableNames) && ...
           ismember(rel_col, raw_data.Properties.VariableNames)
            
            % Team A performance (first team in match)
            team_a_performance(m, i) = match_data.(abs_col)(1);
            
            % Team B performance (second team in match)
            team_b_performance(m, i) = match_data.(abs_col)(2);
            
            % Verify relative calculation
            expected_rel = team_a_performance(m, i) - team_b_performance(m, i);
            actual_rel = match_data.(rel_col)(1);
            if abs(expected_rel - actual_rel) > 1e-6
                warning('Relative calculation mismatch for match %d, metric %s', match_id, metric);
            end
        else
            team_a_performance(m, i) = NaN;
            team_b_performance(m, i) = NaN;
        end
    end
    
    if mod(m, 100) == 0
        fprintf('  Processed %d/%d matches\n', m, n_matches);
    end
end

fprintf('  ✓ Extracted paired team performances for %d matches\n', n_matches);

%% Step 4: Calculate SEF for each metric
fprintf('\nStep 4: Calculating SEF for each metric...\n');

% Initialize SEF results
sef_results = struct();
sef_results.metric_names = metric_names;
sef_results.n_matches = n_matches;
sef_results.team_a_performance = team_a_performance;
sef_results.team_b_performance = team_b_performance;
sef_results.match_ids = match_ids;
sef_results.seasons = seasons;

% Calculate SEF for each metric
sef_values = zeros(n_metrics, 1);
mu_a_values = zeros(n_metrics, 1);
mu_b_values = zeros(n_metrics, 1);
sigma_a_values = zeros(n_metrics, 1);
sigma_b_values = zeros(n_metrics, 1);
rho_values = zeros(n_metrics, 1);
kappa_values = zeros(n_metrics, 1);
delta_values = zeros(n_metrics, 1);
snr_relative_values = zeros(n_metrics, 1);
snr_independent_values = zeros(n_metrics, 1);

for i = 1:n_metrics
    metric = metric_names{i};
    
    % Extract paired performances for this metric
    team_a = team_a_performance(:, i);
    team_b = team_b_performance(:, i);
    
    % Remove NaN values
    valid_mask = ~isnan(team_a) & ~isnan(team_b);
    team_a_clean = team_a(valid_mask);
    team_b_clean = team_b(valid_mask);
    
    if length(team_a_clean) < 10
        fprintf('  %s: Insufficient data (%d valid pairs)\n', metric, length(team_a_clean));
        sef_values(i) = NaN;
        continue;
    end
    
    % Calculate SEF parameters
    mu_a = mean(team_a_clean);
    mu_b = mean(team_b_clean);
    sigma_a = std(team_a_clean);
    sigma_b = std(team_b_clean);
    
    % Calculate correlation
    if sigma_a > 0 && sigma_b > 0
        rho = corr(team_a_clean, team_b_clean);
    else
        rho = 0;
    end
    
    % Calculate SEF parameters
    delta = abs(mu_a - mu_b);
    kappa = (sigma_b^2) / (sigma_a^2);
    
    % Calculate SNR values
    snr_relative = (delta^2) / (sigma_a^2 + sigma_b^2 - 2*rho*sigma_a*sigma_b);
    snr_independent = (delta^2) / (sigma_a^2 + sigma_b^2);
    
    % Calculate SEF
    if snr_independent > 0
        sef = snr_relative / snr_independent;
    else
        sef = NaN;
    end
    
    % Store results
    sef_values(i) = sef;
    mu_a_values(i) = mu_a;
    mu_b_values(i) = mu_b;
    sigma_a_values(i) = sigma_a;
    sigma_b_values(i) = sigma_b;
    rho_values(i) = rho;
    kappa_values(i) = kappa;
    delta_values(i) = delta;
    snr_relative_values(i) = snr_relative;
    snr_independent_values(i) = snr_independent;
    
    fprintf('  %s: SEF = %.3f (κ = %.3f, ρ = %.3f, δ = %.3f)\n', ...
        metric, sef, kappa, rho, delta);
end

% Store results
sef_results.sef_values = sef_values;
sef_results.mu_a_values = mu_a_values;
sef_results.mu_b_values = mu_b_values;
sef_results.sigma_a_values = sigma_a_values;
sef_results.sigma_b_values = sigma_b_values;
sef_results.rho_values = rho_values;
sef_results.kappa_values = kappa_values;
sef_results.delta_values = delta_values;
sef_results.snr_relative_values = snr_relative_values;
sef_results.snr_independent_values = snr_independent_values;

%% Step 5: Generate summary statistics
fprintf('\nStep 5: Generating summary statistics...\n');

% Calculate summary statistics
valid_sef = sef_values(~isnan(sef_values));
n_valid = length(valid_sef);

fprintf('  Valid SEF calculations: %d/%d metrics\n', n_valid, n_metrics);
fprintf('  Mean SEF: %.3f\n', mean(valid_sef));
fprintf('  Median SEF: %.3f\n', median(valid_sef));
fprintf('  Std SEF: %.3f\n', std(valid_sef));
fprintf('  Min SEF: %.3f\n', min(valid_sef));
fprintf('  Max SEF: %.3f\n', max(valid_sef));

% Store summary
sef_results.summary = struct();
sef_results.summary.n_valid = n_valid;
sef_results.summary.mean_sef = mean(valid_sef);
sef_results.summary.median_sef = median(valid_sef);
sef_results.summary.std_sef = std(valid_sef);
sef_results.summary.min_sef = min(valid_sef);
sef_results.summary.max_sef = max(valid_sef);

%% Step 6: Save results
fprintf('\nStep 6: Saving results...\n');

% Create results directory
results_dir = fullfile(project_root, 'outputs', 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Save results
results_file = fullfile(results_dir, 'corrected_sef_sensitivity_analysis.mat');
save(results_file, 'sef_results', '-v7.3');
fprintf('  ✓ Saved results: %s\n', results_file);

%% Step 7: Generate report
fprintf('\nStep 7: Generating report...\n');

report_file = fullfile(results_dir, 'corrected_sef_analysis_report.txt');
fid = fopen(report_file, 'w');

fprintf(fid, 'Corrected SEF Sensitivity Analysis Report\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));

fprintf(fid, 'DATASET OVERVIEW:\n');
fprintf(fid, '  Total matches: %d\n', n_matches);
fprintf(fid, '  Metrics analyzed: %d\n', n_metrics);
fprintf(fid, '  Valid SEF calculations: %d\n', n_valid);

fprintf(fid, '\nSEF SUMMARY STATISTICS:\n');
fprintf(fid, '  Mean SEF: %.3f\n', mean(valid_sef));
fprintf(fid, '  Median SEF: %.3f\n', median(valid_sef));
fprintf(fid, '  Std SEF: %.3f\n', std(valid_sef));
fprintf(fid, '  Min SEF: %.3f\n', min(valid_sef));
fprintf(fid, '  Max SEF: %.3f\n', max(valid_sef));

fprintf(fid, '\nMETRIC DETAILS:\n');
for i = 1:n_metrics
    if ~isnan(sef_values(i))
        fprintf(fid, '  %s: SEF = %.3f, κ = %.3f, ρ = %.3f, δ = %.3f\n', ...
            metric_names{i}, sef_values(i), kappa_values(i), rho_values(i), delta_values(i));
    end
end

fclose(fid);
fprintf('  ✓ Report generated: %s\n', report_file);

%% Final summary
fprintf('\n=== CORRECTED SEF ANALYSIS COMPLETED ===\n');
fprintf('✓ Paired team data extracted\n');
fprintf('✓ SEF calculated for %d metrics\n', n_valid);
fprintf('✓ Results saved and reported\n');
fprintf('\nKey findings:\n');
fprintf('  Mean SEF: %.3f\n', mean(valid_sef));
fprintf('  Range: %.3f - %.3f\n', min(valid_sef), max(valid_sef));
fprintf('  This represents the Signal Enhancement Factor for competitive measurement\n');

end
