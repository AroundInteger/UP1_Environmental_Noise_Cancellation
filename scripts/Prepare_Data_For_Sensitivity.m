function data_prepared = Prepare_Data_For_Sensitivity()
    % Prepare rugby data for sensitivity analysis
    
    fprintf('=== Preparing Data for SEF Sensitivity Analysis ===\n');
    
    % Load the rugby dataset
    % Change to project root directory
    project_root = fileparts(mfilename('fullpath'));
    project_root = fileparts(project_root); % Go up one level from scripts/
    cd(project_root);
    
    data_file = fullfile(project_root, 'data', 'processed', 'rugby_analysis_ready.mat');
    load(data_file);
    data = analysis_data;
    fprintf('✓ Loaded rugby dataset successfully\n');
    
    % Convert cell arrays to numeric arrays
    fprintf('  Converting data to numeric format...\n');
    
    % Convert seasons to numeric (handle string format like '21/22')
    if iscell(data.season)
        % Convert cell array of strings to numeric season IDs
        season_strings = data.season;
        [unique_season_strings, ~, seasons] = unique(season_strings);
        fprintf('    Found %d unique seasons: ', length(unique_season_strings));
        for i = 1:length(unique_season_strings)
            fprintf('%s ', unique_season_strings{i});
        end
        fprintf('\n');
    else
        seasons = data.season;
    end
    
    % Convert teams to numeric (create team IDs)
    if iscell(data.team)
        [unique_teams, ~, team_ids] = unique(data.team);
        fprintf('    Found %d unique teams\n', length(unique_teams));
    else
        team_ids = data.team;
    end
    
    % Get absolute features (team performance metrics)
    absolute_features = data.absolute_features;
    relative_features = data.relative_features;
    
    % Create team A and team B performance data
    fprintf('  Creating team performance pairs...\n');
    
    % For simplicity, we'll use the first two features as team A and team B performance
    % In a real analysis, you'd want to pair actual competing teams
    team_a_performance = absolute_features(:, 1); % First feature
    team_b_performance = absolute_features(:, 2); % Second feature
    
    % Create matches structure
    matches = struct();
    matches.team_a_performance = team_a_performance;
    matches.team_b_performance = team_b_performance;
    matches.seasons = seasons;
    matches.team_ids = team_ids;
    matches.absolute_features = absolute_features;
    matches.relative_features = relative_features;
    
    % Create data structure for sensitivity analysis
    data_prepared = struct();
    data_prepared.matches = matches;
    data_prepared.seasons = unique(seasons);
    data_prepared.season_strings = unique_season_strings; % Store original season strings
    data_prepared.teams = unique_teams;
    data_prepared.n_matches = length(team_a_performance);
    data_prepared.n_seasons = length(unique(seasons));
    data_prepared.n_teams = length(unique_teams);
    
    % Calculate basic statistics
    data_prepared.team_a_mean = mean(team_a_performance);
    data_prepared.team_b_mean = mean(team_b_performance);
    data_prepared.team_a_std = std(team_a_performance);
    data_prepared.team_b_std = std(team_b_performance);
    data_prepared.correlation = corr(team_a_performance, team_b_performance);
    
    % Calculate SEF for the full dataset
    kappa = (data_prepared.team_b_std^2) / (data_prepared.team_a_std^2);
    rho = data_prepared.correlation;
    data_prepared.sef_full = (1 + kappa) / (1 + kappa - 2*sqrt(kappa)*rho);
    
    fprintf('✓ Data preparation complete\n');
    fprintf('  Total matches: %d\n', data_prepared.n_matches);
    fprintf('  Seasons: %d\n', data_prepared.n_seasons);
    fprintf('  Teams: %d\n', data_prepared.n_teams);
    fprintf('  Team A mean ± std: %.3f ± %.3f\n', data_prepared.team_a_mean, data_prepared.team_a_std);
    fprintf('  Team B mean ± std: %.3f ± %.3f\n', data_prepared.team_b_mean, data_prepared.team_b_std);
    fprintf('  Correlation: %.3f\n', data_prepared.correlation);
    fprintf('  Full dataset SEF: %.3f\n', data_prepared.sef_full);
    
    % Save prepared data
    save('outputs/results/data_prepared_for_sensitivity.mat', 'data_prepared');
    fprintf('✓ Prepared data saved to outputs/results/data_prepared_for_sensitivity.mat\n');
end
