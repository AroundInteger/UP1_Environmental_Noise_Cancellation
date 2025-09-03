%% ========================================================================
% CREATE EXAMPLE FORMATTED DATASET
% ========================================================================
% 
% This script creates a properly formatted example dataset from the
% larger rugby dataset, following the required CSV format for the
% Interactive Data Analysis Pipeline.
%
% Author: AI Assistant
% Date: 2024
% Purpose: Create example dataset in required format
%
% ========================================================================

clear; clc;

fprintf('=== CREATING EXAMPLE FORMATTED DATASET ===\n');
fprintf('Converting large rugby dataset to required format...\n\n');

%% Load Original Data
fprintf('STEP 1: Loading original dataset...\n');
try
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_dir, '..');
    data_path = fullfile(project_root, 'data', 'raw', '4_seasons rowan.csv');
    data = readtable(data_path);
    fprintf('✓ Original dataset loaded: %d rows, %d columns\n', height(data), width(data));
catch ME
    error('Failed to load original dataset: %s', ME.message);
end

%% Create Formatted Dataset
fprintf('\nSTEP 2: Creating formatted dataset...\n');

% Initialize formatted table
formatted_data = table();

% Essential columns
formatted_data.Team = data.team;
formatted_data.Match_ID = data.matchid;
formatted_data.Outcome = data.outcome;

% Technical metrics (avoiding obvious scoring metrics)
formatted_data.Carries = data.carries_i;
formatted_data.Metres_Made = data.metres_made_i;
formatted_data.Defenders_Beaten = data.defenders_beaten_i;
formatted_data.Offloads = data.offloads_i;
formatted_data.Passes = data.passes_i;
formatted_data.Tackles = data.tackles_i;
formatted_data.Clean_Breaks = data.clean_breaks_i;
formatted_data.Turnovers_Won = data.turnovers_won_i;
formatted_data.Rucks_Won = data.rucks_won_i;
formatted_data.Lineout_Throws_Won = data.lineout_throws_won_i;

% Additional context columns
formatted_data.Season = data.season;
formatted_data.Match_Location = data.match_location;

fprintf('✓ Formatted dataset created: %d rows, %d columns\n', height(formatted_data), width(formatted_data));

%% Data Quality Check
fprintf('\nSTEP 3: Data quality check...\n');

% Check essential columns
unique_teams = unique(formatted_data.Team);
unique_outcomes = unique(formatted_data.Outcome);

fprintf('Teams found: %d\n', length(unique_teams));
fprintf('Outcomes found: %s\n', strjoin(string(unique_outcomes), ', '));

% Check for missing values
missing_essential = sum(ismissing(formatted_data(:, {'Team', 'Match_ID', 'Outcome'})));
fprintf('Missing values in essential columns: %d\n', sum(missing_essential));

% Check metric columns
metric_cols = {'Carries', 'Metres_Made', 'Defenders_Beaten', 'Offloads', 'Passes', 'Tackles', 'Clean_Breaks', 'Turnovers_Won', 'Rucks_Won', 'Lineout_Throws_Won'};
missing_metrics = sum(ismissing(formatted_data(:, metric_cols)));
fprintf('Missing values in metric columns: %d\n', sum(missing_metrics));

%% Save Formatted Dataset
fprintf('\nSTEP 4: Saving formatted dataset...\n');

try
    output_path = fullfile(project_root, 'data', 'raw', 'Example_Formatted_Dataset.csv');
    writetable(formatted_data, output_path);
    fprintf('✓ Formatted dataset saved to: data/raw/Example_Formatted_Dataset.csv\n');
catch ME
    error('Failed to save formatted dataset: %s', ME.message);
end

%% Display Sample Data
fprintf('\nSTEP 5: Sample data preview...\n');
fprintf('Columns: %s\n', strjoin(formatted_data.Properties.VariableNames, ', '));
fprintf('\nFirst 5 rows:\n');
disp(formatted_data(1:5, :));

%% Summary Statistics
fprintf('\nSTEP 6: Summary statistics...\n');

% Team distribution
team_counts = groupsummary(formatted_data, 'Team', @height);
fprintf('\nTeam distribution:\n');
disp(team_counts);

% Outcome distribution
outcome_counts = groupsummary(formatted_data, 'Outcome', @height);
fprintf('\nOutcome distribution:\n');
disp(outcome_counts);

% Season distribution
season_counts = groupsummary(formatted_data, 'Season', @height);
fprintf('\nSeason distribution:\n');
disp(season_counts);

%% Data Format Validation
fprintf('\nSTEP 7: Data format validation...\n');

% Check data types
fprintf('Data types:\n');
for i = 1:width(formatted_data)
    col_name = formatted_data.Properties.VariableNames{i};
    col_type = class(formatted_data.(col_name));
    fprintf('  %s: %s\n', col_name, col_type);
end

% Validate requirements
fprintf('\nValidation checklist:\n');
fprintf('✓ Team column: %d unique values\n', length(unique_teams));
fprintf('✓ Outcome column: %d unique values\n', length(unique_outcomes));
fprintf('✓ Metric columns: %d numeric columns\n', length(metric_cols));
fprintf('✓ Sample size: %d total observations\n', height(formatted_data));
fprintf('✓ Data quality: %d missing values in essential columns\n', sum(missing_essential));

if length(unique_teams) >= 2 && length(unique_outcomes) == 2 && sum(missing_essential) == 0
    fprintf('\n🎉 DATASET VALIDATION PASSED!\n');
    fprintf('The formatted dataset meets all requirements for the Interactive Data Analysis Pipeline.\n');
else
    fprintf('\n⚠️  DATASET VALIDATION ISSUES DETECTED!\n');
    fprintf('Please review the data format requirements.\n');
end

%% Create Documentation
fprintf('\nSTEP 8: Creating documentation...\n');

% Create dataset description
doc_content = sprintf(['# Example Formatted Dataset\n\n' ...
    '## Dataset Information\n' ...
    '- **Source**: 4 seasons rugby data\n' ...
    '- **Rows**: %d\n' ...
    '- **Columns**: %d\n' ...
    '- **Teams**: %d\n' ...
    '- **Seasons**: %s\n\n' ...
    '## Column Descriptions\n\n' ...
    '### Essential Columns\n' ...
    '- **Team**: Team identifier (%d unique teams)\n' ...
    '- **Match_ID**: Match identifier\n' ...
    '- **Outcome**: Match outcome (%s)\n\n' ...
    '### Technical Metrics\n' ...
    '- **Carries**: Number of ball carries\n' ...
    '- **Metres_Made**: Total metres gained\n' ...
    '- **Defenders_Beaten**: Number of defenders beaten\n' ...
    '- **Offloads**: Number of offloads\n' ...
    '- **Passes**: Number of passes\n' ...
    '- **Tackles**: Number of tackles\n' ...
    '- **Clean_Breaks**: Number of clean breaks\n' ...
    '- **Turnovers_Won**: Number of turnovers won\n' ...
    '- **Rucks_Won**: Number of rucks won\n' ...
    '- **Lineout_Throws_Won**: Number of lineout throws won\n\n' ...
    '### Context Columns\n' ...
    '- **Season**: Season identifier\n' ...
    '- **Match_Location**: Home/Away indicator\n\n' ...
    '## Usage\n' ...
    'This dataset is ready for use with the Interactive Data Analysis Pipeline.\n' ...
    'Run: `scripts/Demo_User_Analysis_Pipeline.m` with this dataset.\n'], ...
    height(formatted_data), width(formatted_data), length(unique_teams), ...
    strjoin(string(unique(formatted_data.Season)), ', '), ...
    length(unique_teams), strjoin(string(unique_outcomes), ', '));

% Save documentation
doc_path = fullfile(project_root, 'data', 'raw', 'Example_Formatted_Dataset_README.md');
fid = fopen(doc_path, 'w');
fprintf(fid, '%s', doc_content);
fclose(fid);

fprintf('✓ Documentation created: data/raw/Example_Formatted_Dataset_README.md\n');

%% Final Summary
fprintf('\n=== FORMATTING COMPLETE ===\n');
fprintf('Formatted dataset: data/raw/Example_Formatted_Dataset.csv\n');
fprintf('Documentation: data/raw/Example_Formatted_Dataset_README.md\n');
fprintf('Ready for use with Interactive Data Analysis Pipeline!\n');

fprintf('\nTo test the formatted dataset:\n');
fprintf('1. Update the demo script to use: data/raw/Example_Formatted_Dataset.csv\n');
fprintf('2. Run: scripts/Demo_User_Analysis_Pipeline.m\n');
fprintf('3. Compare results with the original analysis\n');
