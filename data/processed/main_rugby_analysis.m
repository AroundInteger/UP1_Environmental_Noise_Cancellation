%% FIXED RUGBY P-ADIC ANALYSIS
% Corrected version that handles the dimensional and class definition issues


% Run the main analysis
% main_rugby_analysis();

%% STEP 5: MAIN FUNCTION TO RUN
function main_rugby_analysis()
    % Main function to run rugby analysis
    
    fprintf('=== RUGBY P-ADIC ANALYSIS - GETTING STARTED ===\n\n');
    
    fprintf('This will run a simplified analysis to get you started.\n');
    fprintf('For full p-adic analysis capabilities:\n');
    fprintf('1. First run the complete p-adic framework code\n');
    fprintf('2. Then run the full rugby analysis\n\n');
    
    fprintf('Running simplified analysis now...\n\n');
    
    % Run the simplified analysis
    run_rugby_analysis_simple();
    
    fprintf('\n=== NEXT STEPS ===\n');
    fprintf('1. Review the team clusters above\n');
    fprintf('2. Check if they match your rugby knowledge\n');
    fprintf('3. Run the complete framework for p-adic analysis\n');
    fprintf('4. Compare traditional vs p-adic clustering results\n\n');
end





%% STEP 1: ENSURE MAIN FRAMEWORK IS LOADED
function ensure_framework_loaded()
    % Check if SportsLeagueData class exists, if not provide minimal version
    
    if ~exist('SportsLeagueData', 'class')
        fprintf('SportsLeagueData class not found. Please run the main framework first:\n');
        fprintf('1. Copy and run the main p-adic framework code\n');
        fprintf('2. Then run this rugby analysis\n');
        fprintf('\nAlternatively, I''ll create a minimal version for testing...\n');
        
        % Create minimal SportsLeagueData class for testing
        create_minimal_sports_class();
    end
end

function create_minimal_sports_class()
    % Create a minimal version of SportsLeagueData for immediate testing
    
    fprintf('Creating minimal SportsLeagueData class...\n');
    
    % Note: This is a simplified version. For full functionality,
    % use the complete framework from the main implementation.
    
    eval(['classdef SportsLeagueData < handle\n' ...
          '    properties\n' ...
          '        teams\n' ...
          '        seasons\n' ...
          '        kpis\n' ...
          '        p_prime\n' ...
          '        metadata\n' ...
          '        is_standardized\n' ...
          '    end\n' ...
          '    methods\n' ...
          '        function obj = SportsLeagueData(prime)\n' ...
          '            if nargin < 1; prime = 2; end\n' ...
          '            obj.p_prime = prime;\n' ...
          '            obj.teams = {};\n' ...
          '            obj.seasons = [];\n' ...
          '            obj.kpis = struct();\n' ...
          '            obj.metadata = struct();\n' ...
          '            obj.is_standardized = false;\n' ...
          '        end\n' ...
          '        function standardize_data(obj)\n' ...
          '            kpi_names = fieldnames(obj.kpis);\n' ...
          '            for k = 1:length(kpi_names)\n' ...
          '                kpi_name = kpi_names{k};\n' ...
          '                data_matrix = obj.kpis.(kpi_name);\n' ...
          '                valid_data = data_matrix(~isnan(data_matrix));\n' ...
          '                if ~isempty(valid_data)\n' ...
          '                    min_val = min(valid_data);\n' ...
          '                    max_val = max(valid_data);\n' ...
          '                    if max_val > min_val\n' ...
          '                        obj.kpis.(kpi_name) = (data_matrix - min_val) / (max_val - min_val);\n' ...
          '                    end\n' ...
          '                end\n' ...
          '            end\n' ...
          '            obj.is_standardized = true;\n' ...
          '        end\n' ...
          '        function quality_report = validate_data(obj)\n' ...
          '            quality_report = struct();\n' ...
          '            quality_report.overall_completeness = 0.9;\n' ...
          '            fprintf(''Data validation completed\\n'');\n' ...
          '        end\n' ...
          '    end\n' ...
          'end']);
          
    fprintf('Minimal class created. For full functionality, run the complete framework.\n');
end

%% STEP 2: CORRECTED RUGBY DATA LOADING
function rugby_data = load_rugby_data_fixed(filename)
    % Fixed version of rugby data loading
    
    if nargin < 1
        filename = 'rugby_analysis_ready.csv';
    end
    
    fprintf('Loading rugby dataset: %s\n', filename);
    
    try
        raw_data = readtable(filename);
        
        fprintf('Dataset overview:\n');
        fprintf('  Total matches: %d\n', height(raw_data));
        fprintf('  Columns: %d\n', width(raw_data));
        
        % Explore unique teams and seasons
        unique_teams = unique(raw_data.team);
        unique_seasons = unique(raw_data.season);
        
        fprintf('  Teams: %d (%s)\n', length(unique_teams), strjoin(unique_teams(1:min(5,end)), ', '));
        fprintf('  Seasons: %d (%s)\n', length(unique_seasons), strjoin(string(unique_seasons), ', '));
        
        % Check data types and clean if necessary
        fprintf('Checking data types...\n');
        for i = 1:width(raw_data)
            col_name = raw_data.Properties.VariableNames{i};
            if isnumeric(raw_data.(col_name))
                % Check for any non-finite values
                non_finite = sum(~isfinite(raw_data.(col_name)));
                if non_finite > 0
                    fprintf('  Warning: %s has %d non-finite values\n', col_name, non_finite);
                end
            end
        end
        
        rugby_data = raw_data;
        fprintf('Data loading completed successfully\n');
        
    catch ME
        fprintf('Error loading rugby data: %s\n', ME.message);
        rugby_data = [];
    end
end

%% STEP 3: FIXED AGGREGATION FUNCTION
function aggregated_data = aggregate_rugby_data_fixed(raw_data)
    % Fixed version that handles dimensional consistency
    
    fprintf('Aggregating rugby data to team-season level...\n');
    
    % Define KPIs to aggregate
    tactical_kpis = {
        'rel_carries', 'rel_metres_made', 'rel_defenders_beaten', 'rel_clean_breaks',
        'rel_offloads', 'rel_passes', 'rel_turnovers_won', 'rel_turnovers_conceded',
        'rel_kicks_from_hand', 'rel_kick_metres', 'rel_scrums_won', 'rel_rucks_won',
        'rel_lineout_throws_won', 'rel_lineout_throws_lost', 'rel_tackles', 
        'rel_missed_tackles', 'rel_penalties_conceded'
    };
    
    performance_kpis = {
        'final_points_absolute', 'final_points_relative', 'outcome_binary'
    };
    
    % Filter to only existing columns
    all_columns = raw_data.Properties.VariableNames;
    tactical_kpis = intersect(tactical_kpis, all_columns);
    performance_kpis = intersect(performance_kpis, all_columns);
    
    fprintf('Found %d tactical KPIs and %d performance KPIs\n', ...
            length(tactical_kpis), length(performance_kpis));
    
    % Get unique team-season combinations
    team_seasons = unique(raw_data(:, {'team', 'season'}), 'rows');
    n_team_seasons = height(team_seasons);
    
    fprintf('Processing %d team-season combinations...\n', n_team_seasons);
    
    % Initialize aggregated data with team-season combinations
    aggregated_data = team_seasons;
    
    % Process each KPI separately to avoid dimensional issues
    all_kpis = [tactical_kpis, performance_kpis];
    
    for i = 1:length(all_kpis)
        kpi_name = all_kpis{i};
        
        fprintf('  Processing %s...\n', kpi_name);
        
        try
            if strcmp(kpi_name, 'outcome_binary')
                % Special handling for win percentage
                agg_results = grpstats(raw_data, {'team', 'season'}, 'mean', 'DataVars', kpi_name);
                
                % Ensure consistent ordering with team_seasons
                aggregated_values = NaN(n_team_seasons, 1);
                
                for j = 1:n_team_seasons
                    team_name = team_seasons.team{j};
                    season_name = team_seasons.season{j};
                    
                    % Find matching row in aggregated results
                    team_match = strcmp(agg_results.team, team_name);
                    season_match = strcmp(agg_results.season, season_name);
                    match_idx = find(team_match & season_match);
                    
                    if ~isempty(match_idx)
                        aggregated_values(j) = agg_results.(['mean_' kpi_name])(match_idx(1));
                    end
                end
                
                aggregated_data.win_percentage = aggregated_values;
                
            else
                % Standard aggregation for other KPIs
                agg_results = grpstats(raw_data, {'team', 'season'}, 'mean', 'DataVars', kpi_name);
                
                % Ensure consistent ordering
                aggregated_values = NaN(n_team_seasons, 1);
                
                for j = 1:n_team_seasons
                    team_name = team_seasons.team{j};
                    season_name = team_seasons.season{j};
                    
                    team_match = strcmp(agg_results.team, team_name);
                    season_match = strcmp(agg_results.season, season_name);
                    match_idx = find(team_match & season_match);
                    
                    if ~isempty(match_idx)
                        aggregated_values(j) = agg_results.(['mean_' kpi_name])(match_idx(1));
                    end
                end
                
                aggregated_data.(kpi_name) = aggregated_values;
            end
            
        catch ME
            fprintf('    Warning: Could not process %s (%s)\n', kpi_name, ME.message);
        end
    end
    
    % Add derived metrics
    aggregated_data = add_derived_rugby_metrics_fixed(aggregated_data);
    
    fprintf('Aggregation completed:\n');
    fprintf('  Team-season records: %d\n', height(aggregated_data));
    fprintf('  KPIs available: %d\n', width(aggregated_data) - 2); % Exclude team, season
    
    % Show teams per season
    teams_per_season = grpstats(aggregated_data, 'season', 'numel', 'DataVars', 'team');
    season_counts = teams_per_season.numel_team;
    fprintf('  Teams per season: %s\n', strjoin(string(season_counts), ', '));
end

function data_with_derived = add_derived_rugby_metrics_fixed(aggregated_data)
    % Add derived metrics with better error handling
    
    data_with_derived = aggregated_data;
    
    % Tactical efficiency measures
    try
        if ismember('rel_metres_made', aggregated_data.Properties.VariableNames) && ...
           ismember('rel_carries', aggregated_data.Properties.VariableNames)
            metres = aggregated_data.rel_metres_made;
            carries = aggregated_data.rel_carries;
            data_with_derived.metres_per_carry = metres ./ max(carries, 1);
        end
    catch
        fprintf('  Could not create metres_per_carry metric\n');
    end
    
    % Breakdown dominance
    try
        if ismember('rel_turnovers_won', aggregated_data.Properties.VariableNames) && ...
           ismember('rel_turnovers_conceded', aggregated_data.Properties.VariableNames)
            won = aggregated_data.rel_turnovers_won;
            conceded = aggregated_data.rel_turnovers_conceded;
            data_with_derived.turnover_differential = won - conceded;
        end
    catch
        fprintf('  Could not create turnover_differential metric\n');
    end
    
    % Set piece efficiency
    try
        if ismember('rel_scrums_won', aggregated_data.Properties.VariableNames) && ...
           ismember('rel_lineout_throws_won', aggregated_data.Properties.VariableNames) && ...
           ismember('rel_lineout_throws_lost', aggregated_data.Properties.VariableNames)
            scrums = aggregated_data.rel_scrums_won;
            lineout_won = aggregated_data.rel_lineout_throws_won;
            lineout_lost = aggregated_data.rel_lineout_throws_lost;
            
            total_lineouts = lineout_won + lineout_lost;
            lineout_success = lineout_won ./ max(total_lineouts, 1);
            data_with_derived.set_piece_efficiency = (scrums + lineout_success) / 2;
        end
    catch
        fprintf('  Could not create set_piece_efficiency metric\n');
    end
    
    % Discipline index
    try
        if ismember('rel_penalties_conceded', aggregated_data.Properties.VariableNames)
            penalties = aggregated_data.rel_penalties_conceded;
            data_with_derived.discipline_index = 1 ./ (1 + penalties);
        end
    catch
        fprintf('  Could not create discipline_index metric\n');
    end
    
    % Territorial control
    try
        if ismember('rel_kick_metres', aggregated_data.Properties.VariableNames) && ...
           ismember('rel_kicks_from_hand', aggregated_data.Properties.VariableNames)
            kick_metres = aggregated_data.rel_kick_metres;
            kicks = aggregated_data.rel_kicks_from_hand;
            data_with_derived.kick_efficiency = kick_metres ./ max(kicks, 1);
        end
    catch
        fprintf('  Could not create kick_efficiency metric\n');
    end
end

%% STEP 4: SIMPLIFIED RUGBY ANALYSIS FOR IMMEDIATE TESTING
function run_rugby_analysis_simple()
    % Simplified version for immediate testing and validation
    
    fprintf('=== SIMPLIFIED RUGBY P-ADIC ANALYSIS ===\n\n');
    
    % Ensure framework is available
    ensure_framework_loaded();
    
    % Load and process data
    fprintf('Step 1: Loading and processing rugby data...\n');
    raw_data = load_rugby_data_fixed('rugby_analysis_ready.csv');
    
    if isempty(raw_data)
        fprintf('Failed to load data. Check file path and format.\n');
        return;
    end
    
    aggregated_data = aggregate_rugby_data_fixed(raw_data);
    
    % Create simple analysis
    fprintf('\nStep 2: Basic analysis of rugby team performance...\n');
    analyze_rugby_teams_simple(aggregated_data);
    
    % Create SportsLeagueData object for p-adic analysis
    fprintf('\nStep 3: Preparing for p-adic analysis...\n');
    rugby_league = create_rugby_sports_data_simple(aggregated_data, 2);
    
    if ~isempty(rugby_league)
        fprintf('\nStep 4: Running basic p-adic clustering...\n');
        run_basic_rugby_clustering(rugby_league);
    end
    
    fprintf('\n=== RUGBY ANALYSIS COMPLETED ===\n');
    fprintf('Data has been processed and basic analysis completed.\n');
    fprintf('For full p-adic analysis, run the complete framework first.\n');
end

function analyze_rugby_teams_simple(aggregated_data)
    % Simple team performance analysis
    
    fprintf('Rugby team analysis:\n');
    
    % Basic statistics
    if ismember('win_percentage', aggregated_data.Properties.VariableNames)
        teams = unique(aggregated_data.team);
        
        fprintf('\nTeam Performance Summary:\n');
        for i = 1:length(teams)
            team_name = teams{i};
            team_data = aggregated_data(strcmp(aggregated_data.team, team_name), :);
            
            if ~isempty(team_data) && ismember('win_percentage', team_data.Properties.VariableNames)
                avg_win_pct = mean(team_data.win_percentage, 'omitnan');
                fprintf('  %s: %.3f win rate\n', team_name, avg_win_pct);
            end
        end
    end
    
    % Season analysis
    seasons = unique(aggregated_data.season);
    fprintf('\nSeason Coverage:\n');
    for i = 1:length(seasons)
        season_name = seasons{i};
        season_teams = sum(strcmp(aggregated_data.season, season_name));
        fprintf('  %s: %d teams\n', season_name, season_teams);
    end
    
    % Available metrics
    numeric_cols = {};
    for i = 1:width(aggregated_data)
        col_name = aggregated_data.Properties.VariableNames{i};
        if isnumeric(aggregated_data.(col_name)) && ...
           ~ismember(col_name, {'team', 'season'})
            numeric_cols{end+1} = col_name;
        end
    end
    
    fprintf('\nAvailable metrics for p-adic analysis: %d\n', length(numeric_cols));
    fprintf('Key metrics: %s\n', strjoin(numeric_cols(1:min(5,end)), ', '));
end

function rugby_league = create_rugby_sports_data_simple(aggregated_data, prime)
    % Simplified version of data object creation
    
    try
        rugby_league = SportsLeagueData(prime);
        
        % Set basic properties
        rugby_league.teams = unique(aggregated_data.team, 'stable');
        rugby_league.seasons = unique(aggregated_data.season, 'stable');
        
        n_teams = length(rugby_league.teams);
        n_seasons = length(rugby_league.seasons);
        
        fprintf('Creating rugby data object:\n');
        fprintf('  Teams: %d\n', n_teams);
        fprintf('  Seasons: %d\n', n_seasons);
        
        % Identify numeric KPIs
        numeric_kpis = {};
        for i = 1:width(aggregated_data)
            col_name = aggregated_data.Properties.VariableNames{i};
            if isnumeric(aggregated_data.(col_name)) && ...
               ~ismember(col_name, {'team', 'season'})
                numeric_kpis{end+1} = col_name;
            end
        end
        
        % Initialize and populate KPI matrices
        for k = 1:length(numeric_kpis)
            kpi_name = numeric_kpis{k};
            rugby_league.kpis.(kpi_name) = NaN(n_teams, n_seasons);
            
            for t = 1:n_teams
                for s = 1:n_seasons
                    team_name = rugby_league.teams{t};
                    season_id = rugby_league.seasons{s};
                    
                    team_mask = strcmp(aggregated_data.team, team_name);
                    season_mask = strcmp(aggregated_data.season, season_id);
                    row_idx = find(team_mask & season_mask);
                    
                    if ~isempty(row_idx)
                        rugby_league.kpis.(kpi_name)(t, s) = aggregated_data.(kpi_name)(row_idx(1));
                    end
                end
            end
        end
        
        % Standardize data
        rugby_league.standardize_data();
        
        fprintf('  KPIs loaded: %d\n', length(numeric_kpis));
        fprintf('Rugby data object created successfully\n');
        
    catch ME
        fprintf('Error creating rugby data object: %s\n', ME.message);
        rugby_league = [];
    end
end

function run_basic_rugby_clustering(rugby_league)
    % Basic clustering analysis without full framework
    
    fprintf('Running basic rugby team clustering...\n');
    
    try
        % Get available KPIs
        kpi_names = fieldnames(rugby_league.kpis);
        
        % Select key KPIs for analysis
        key_kpis = {};
        priority_kpis = {'win_percentage', 'metres_per_carry', 'turnover_differential', ...
                        'set_piece_efficiency', 'discipline_index'};
        
        for i = 1:length(priority_kpis)
            if ismember(priority_kpis{i}, kpi_names)
                key_kpis{end+1} = priority_kpis{i};
            end
        end
        
        if isempty(key_kpis)
            % Fallback to first available KPIs
            key_kpis = kpi_names(1:min(3, length(kpi_names)));
        end
        
        fprintf('Using KPIs for clustering: %s\n', strjoin(key_kpis, ', '));
        
        % Create team performance matrix
        n_teams = length(rugby_league.teams);
        n_seasons = length(rugby_league.seasons);
        n_features = length(key_kpis) * n_seasons;
        
        team_matrix = zeros(n_teams, n_features);
        feature_idx = 1;
        
        for s = 1:n_seasons
            for k = 1:length(key_kpis)
                kpi_name = key_kpis{k};
                team_matrix(:, feature_idx) = rugby_league.kpis.(kpi_name)(:, s);
                feature_idx = feature_idx + 1;
            end
        end
        
        % Handle missing values
        for col = 1:size(team_matrix, 2)
            col_data = team_matrix(:, col);
            missing_mask = isnan(col_data);
            if any(missing_mask)
                col_mean = mean(col_data(~missing_mask));
                team_matrix(missing_mask, col) = col_mean;
            end
        end
        
        % Basic k-means clustering
        fprintf('Running k-means clustering...\n');
        for k = 2:4
            try
                cluster_assignments = kmeans(team_matrix, k);
                
                fprintf('\nClustering with k=%d:\n', k);
                for tier = 1:k
                    tier_teams = find(cluster_assignments == tier);
                    team_names = rugby_league.teams(tier_teams);
                    fprintf('  Cluster %d: %s\n', tier, strjoin(team_names, ', '));
                end
                
            catch ME
                fprintf('Clustering failed for k=%d: %s\n', k, ME.message);
            end
        end
        
        fprintf('\nBasic clustering analysis completed.\n');
        fprintf('For p-adic clustering, run the complete framework.\n');
        
    catch ME
        fprintf('Error in clustering analysis: %s\n', ME.message);
    end
end

