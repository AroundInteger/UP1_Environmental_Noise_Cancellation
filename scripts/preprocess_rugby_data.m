function preprocess_rugby_data()
%PREPROCESS_RUGBY_DATA Preprocess raw rugby data for UP1 analysis
%
% This script processes the raw rugby CSV data and creates a clean,
% analysis-ready dataset with proper column names and data structure.
%
% Output files:
% - data/processed/rugby_analysis_ready.mat (MATLAB format)
% - data/processed/rugby_analysis_ready.csv (CSV format for verification)
%
% Author: UP1 Research Team
% Date: 2024

fprintf('=== Rugby Data Preprocessing Pipeline ===\n\n');

%% Step 1: Load raw data
fprintf('Step 1: Loading raw data...\n');
try
    % Get project root
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(script_dir);
    
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

%% Step 2: Clean and structure data
fprintf('\nStep 2: Cleaning and structuring data...\n');

% Create clean dataset structure
clean_data = struct();

% Basic match information
clean_data.season = raw_data.season;
clean_data.matchid = raw_data.matchid;
clean_data.team = raw_data.team;
clean_data.match_location = raw_data.match_location;
clean_data.outcome = raw_data.outcome;

% Convert outcome to binary (1 = win, 0 = loss)
clean_data.outcome_binary = strcmp(raw_data.outcome, 'win');

% Final scores
clean_data.final_points_absolute = raw_data.final_points_i;
clean_data.final_points_relative = raw_data.final_points_r;

%% Step 3: Extract and organize performance metrics
fprintf('  Extracting performance metrics...\n');

% Define metric categories
metric_categories = {
    'carries', 'metres_made', 'defenders_beaten', 'clean_breaks', ...
    'offloads', 'passes', 'turnovers_conceded', 'turnovers_won', ...
    'kicks_from_hand', 'kick_metres', 'scrums_won', 'rucks_won', ...
    'lineout_throws_lost', 'lineout_throws_won', 'tackles', 'missed_tackles', ...
    'penalties_conceded', 'scrum_pens_conceded', 'lineout_pens_conceded', ...
    'general_play_pens_conceded', 'free_kicks_conceded', ...
    'ruck_maul_tackle_pen_con', 'red_cards', 'yellow_cards'
};

% Extract absolute metrics (individual performance)
fprintf('    Processing absolute metrics...\n');
for i = 1:length(metric_categories)
    metric = metric_categories{i};
    abs_col = [metric '_i'];
    
    if ismember(abs_col, raw_data.Properties.VariableNames)
        clean_data.absolute.(metric) = raw_data.(abs_col);
    else
        warning('Absolute metric column not found: %s', abs_col);
        clean_data.absolute.(metric) = NaN(height(raw_data), 1);
    end
end

% Extract relative metrics (competitive differences)
fprintf('    Processing relative metrics...\n');
for i = 1:length(metric_categories)
    metric = metric_categories{i};
    rel_col = [metric '_r'];
    
    if ismember(rel_col, raw_data.Properties.VariableNames)
        clean_data.relative.(metric) = raw_data.(rel_col);
    else
        warning('Relative metric column not found: %s', rel_col);
        clean_data.relative.(metric) = NaN(height(raw_data), 1);
    end
end

%% Step 4: Data quality checks and cleaning
fprintf('\nStep 3: Data quality checks and cleaning...\n');

% Check for missing values
total_rows = height(raw_data);
missing_counts = struct();

% Check absolute metrics
fprintf('  Checking absolute metrics for missing values...\n');
for i = 1:length(metric_categories)
    metric = metric_categories{i};
    if isfield(clean_data.absolute, metric)
        missing_count = sum(isnan(clean_data.absolute.(metric)));
        if missing_count > 0
            missing_counts.absolute.(metric) = missing_count;
            fprintf('    %s: %d missing values (%.1f%%)\n', ...
                metric, missing_count, missing_count/total_rows*100);
        end
    end
end

% Check relative metrics
fprintf('  Checking relative metrics for missing values...\n');
for i = 1:length(metric_categories)
    metric = metric_categories{i};
    if isfield(clean_data.relative, metric)
        missing_count = sum(isnan(clean_data.relative.(metric)));
        if missing_count > 0
            missing_counts.relative.(metric) = missing_count;
            fprintf('    %s: %d missing values (%.1f%%)\n', ...
                metric, missing_count, missing_count/total_rows*100);
        end
    end
end

%% Step 5: Create analysis-ready matrices
fprintf('\nStep 4: Creating analysis-ready matrices...\n');

% Create feature matrices for analysis
analysis_data = struct();

% Absolute performance matrix (individual metrics)
absolute_features = [];
absolute_feature_names = {};
for i = 1:length(metric_categories)
    metric = metric_categories{i};
    if isfield(clean_data.absolute, metric)
        absolute_features = [absolute_features, clean_data.absolute.(metric)];
        absolute_feature_names{end+1} = metric;
    end
end
analysis_data.absolute_features = absolute_features;
analysis_data.absolute_feature_names = absolute_feature_names;

% Relative performance matrix (competitive differences)
relative_features = [];
relative_feature_names = {};
for i = 1:length(metric_categories)
    metric = metric_categories{i};
    if isfield(clean_data.relative, metric)
        relative_features = [relative_features, clean_data.relative.(metric)];
        relative_feature_names{end+1} = metric;
    end
end
analysis_data.relative_features = relative_features;
analysis_data.relative_feature_names = relative_feature_names;

% Basic match information
analysis_data.season = clean_data.season;
analysis_data.team = clean_data.team;
analysis_data.match_location = clean_data.match_location;
analysis_data.outcome = clean_data.outcome;
analysis_data.outcome_binary = clean_data.outcome_binary;
analysis_data.final_points_absolute = clean_data.final_points_absolute;
analysis_data.final_points_relative = clean_data.final_points_relative;

fprintf('  ✓ Created feature matrices:\n');
fprintf('    Absolute features: %d metrics\n', size(absolute_features, 2));
fprintf('    Relative features: %d metrics\n', size(relative_features, 2));

%% Step 6: Generate summary statistics
fprintf('\nStep 5: Generating summary statistics...\n');

% Dataset overview
summary = struct();
summary.total_matches = total_rows;
summary.seasons = unique(clean_data.season);
summary.teams = unique(clean_data.team);
summary.total_seasons = length(summary.seasons);
summary.total_teams = length(summary.teams);

% Performance statistics
summary.absolute_stats = struct();
summary.relative_stats = struct();

% Calculate statistics for absolute metrics
fprintf('  Calculating absolute metrics statistics...\n');
for i = 1:length(absolute_feature_names)
    metric = absolute_feature_names{i};
    values = absolute_features(:, i);
    valid_values = values(~isnan(values));
    
    if ~isempty(valid_values)
        summary.absolute_stats.(metric) = struct();
        summary.absolute_stats.(metric).mean = mean(valid_values);
        summary.absolute_stats.(metric).std = std(valid_values);
        summary.absolute_stats.(metric).min = min(valid_values);
        summary.absolute_stats.(metric).max = max(valid_values);
        summary.absolute_stats.(metric).n_valid = length(valid_values);
    end
end

% Calculate statistics for relative metrics
fprintf('  Calculating relative metrics statistics...\n');
for i = 1:length(relative_feature_names)
    metric = relative_feature_names{i};
    values = relative_features(:, i);
    valid_values = values(~isnan(values));
    
    if ~isempty(valid_values)
        summary.relative_stats.(metric) = struct();
        summary.relative_stats.(metric).mean = mean(valid_values);
        summary.relative_stats.(metric).std = std(valid_values);
        summary.absolute_stats.(metric).min = min(valid_values);
        summary.absolute_stats.(metric).max = max(valid_values);
        summary.relative_stats.(metric).n_valid = length(valid_values);
    end
end

% Win rate analysis
summary.win_rate_overall = mean(clean_data.outcome_binary);
summary.win_rate_by_season = grpstats(clean_data.outcome_binary, clean_data.season, 'mean');
summary.win_rate_by_team = grpstats(clean_data.outcome_binary, clean_data.team, 'mean');

fprintf('  ✓ Summary statistics generated\n');

%% Step 7: Save processed data
fprintf('\nStep 6: Saving processed data...\n');

% Create processed data directory if it doesn't exist
processed_dir = fullfile(project_root, 'data', 'processed');
if ~exist(processed_dir, 'dir')
    mkdir(processed_dir);
end

% Save as MATLAB file
mat_file = fullfile(processed_dir, 'rugby_analysis_ready.mat');
save(mat_file, 'analysis_data', 'clean_data', 'summary', 'metric_categories', '-v7.3');
fprintf('  ✓ Saved MATLAB file: %s\n', mat_file);

% Save as CSV for verification
csv_file = fullfile(processed_dir, 'rugby_analysis_ready.csv');
% Create a table for CSV export
export_table = table();
export_table.season = analysis_data.season;
export_table.team = analysis_data.team;
export_table.match_location = analysis_data.match_location;
export_table.outcome = analysis_data.outcome;
export_table.outcome_binary = analysis_data.outcome_binary;
export_table.final_points_absolute = analysis_data.final_points_absolute;
export_table.final_points_relative = analysis_data.final_points_relative;

% Add absolute features
for i = 1:length(absolute_feature_names)
    metric = absolute_feature_names{i};
    col_name = ['abs_' metric];
    export_table.(col_name) = analysis_data.absolute_features(:, i);
end

% Add relative features
for i = 1:length(relative_feature_names)
    metric = relative_feature_names{i};
    col_name = ['rel_' metric];
    export_table.(col_name) = analysis_data.relative_features(:, i);
end

writetable(export_table, csv_file);
fprintf('  ✓ Saved CSV file: %s\n', csv_file);

%% Step 8: Generate preprocessing report
fprintf('\nStep 7: Generating preprocessing report...\n');

report_file = fullfile(processed_dir, 'preprocessing_report.txt');
fid = fopen(report_file, 'w');

fprintf(fid, 'UP1 Rugby Data Preprocessing Report\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));

fprintf(fid, 'DATASET OVERVIEW:\n');
fprintf(fid, '  Total matches: %d\n', summary.total_matches);
fprintf(fid, '  Seasons: %s\n', strjoin(summary.seasons, ', '));
fprintf(fid, '  Total teams: %d\n', summary.total_teams);
fprintf(fid, '  Overall win rate: %.1f%%\n', summary.win_rate_overall * 100);

fprintf(fid, '\nFEATURE MATRICES:\n');
fprintf(fid, '  Absolute features: %d metrics\n', size(absolute_features, 2));
fprintf(fid, '  Relative features: %d metrics\n', size(relative_features, 2));

fprintf(fid, '\nMETRIC CATEGORIES:\n');
for i = 1:length(metric_categories)
    fprintf(fid, '  %s\n', metric_categories{i});
end

fprintf(fid, '\nDATA QUALITY:\n');
if isfield(missing_counts, 'absolute')
    fprintf(fid, '  Missing values in absolute metrics:\n');
    abs_fields = fieldnames(missing_counts.absolute);
    for i = 1:length(abs_fields)
        metric = abs_fields{i};
        count = missing_counts.absolute.(metric);
        fprintf(fid, '    %s: %d (%.1f%%)\n', metric, count, count/total_rows*100);
    end
end

fclose(fid);
fprintf('  ✓ Preprocessing report generated: %s\n', report_file);

%% Final summary
fprintf('\n=== PREPROCESSING COMPLETED ===\n');
fprintf('✓ Raw data loaded and cleaned\n');
fprintf('✓ Feature matrices created\n');
fprintf('✓ Summary statistics generated\n');
fprintf('✓ Data saved in multiple formats\n');
fprintf('✓ Preprocessing report created\n');
fprintf('\nOutput files:\n');
fprintf('  - %s\n', mat_file);
fprintf('  - %s\n', csv_file);
fprintf('  - %s\n', report_file);
fprintf('\nThe data is now ready for UP1 analysis!\n');

end
