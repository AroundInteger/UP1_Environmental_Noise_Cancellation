%% RUGBY P-ADIC ANALYSIS - MAIN SCRIPT
% Main script to run rugby p-adic analysis
% 
% Instructions:
% 1. Save this as 'rugby_padic_analysis.m'
% 2. Save the functions file as 'rugby_padic_functions.m' 
% 3. Make sure both files are in the same directory
% 4. Make sure 'rugby_analysis_ready.csv' is in the same directory
% 5. Run this script
%
% Author: P-adic Sports Analytics Team
% Date: December 2024

clear all;
close all;
clc;

%% CONFIGURATION
fprintf('=== RUGBY P-ADIC ANALYSIS ===\n\n');

% Configuration parameters
config = struct();
config.data_file = 'rugby_analysis_ready.csv';
config.prime = 2;  % Start with p=2 for binary hierarchies
config.max_clusters = 6;
config.save_results = true;
config.generate_plots = true;

% Check if required files exist
if ~exist(config.data_file, 'file')
    error('Data file %s not found. Please check the filename and path.', config.data_file);
end

if ~exist('rugby_padic_functions.m', 'file')
    error('Functions file rugby_padic_functions.m not found. Please save the functions file.');
end

fprintf('Configuration:\n');
fprintf('  Data file: %s\n', config.data_file);
fprintf('  Prime: p = %d\n', config.prime);
fprintf('  Max clusters: %d\n', config.max_clusters);
fprintf('\n');

%% STEP 1: LOAD AND EXAMINE DATA
fprintf('STEP 1: Loading rugby data...\n');

try
    raw_data = readtable(config.data_file);
    fprintf('✓ Data loaded successfully\n');
    fprintf('  Rows: %d\n', height(raw_data));
    fprintf('  Columns: %d\n', width(raw_data));
    
    % Basic data exploration
    unique_teams = unique(raw_data.team);
    unique_seasons = unique(raw_data.season);
    
    fprintf('  Teams: %d\n', length(unique_teams));
    fprintf('  Seasons: %d\n', length(unique_seasons));
    fprintf('  Team names: %s\n', strjoin(unique_teams(1:min(3,end)), ', '));
    fprintf('  Seasons: %s\n', strjoin(string(unique_seasons), ', '));
    
catch ME
    error('Failed to load data: %s', ME.message);
end

%% STEP 2: AGGREGATE TO TEAM-SEASON LEVEL
fprintf('\nSTEP 2: Aggregating data to team-season level...\n');

try
    aggregated_data = aggregate_rugby_data(raw_data);
    fprintf('✓ Data aggregation completed\n');
    fprintf('  Team-season records: %d\n', height(aggregated_data));
    fprintf('  KPIs: %d\n', width(aggregated_data) - 2); % Exclude team, season
    
catch ME
    error('Failed to aggregate data: %s', ME.message);
end

%% STEP 3: BASIC TEAM ANALYSIS
fprintf('\nSTEP 3: Basic team performance analysis...\n');

try
    team_summary = analyze_team_performance(aggregated_data);
    
    fprintf('✓ Team analysis completed\n');
    fprintf('Teams by average win rate:\n');
    
    % Sort teams by win rate
    if isfield(team_summary, 'team_stats')
        team_stats = team_summary.team_stats;
        [~, sort_idx] = sort([team_stats.avg_win_rate], 'descend');
        
        for i = 1:length(sort_idx)
            idx = sort_idx(i);
            fprintf('  %d. %s: %.3f\n', i, team_stats(idx).name, team_stats(idx).avg_win_rate);
        end
    end
    
catch ME
    warning('Basic analysis failed: %s', 'ME.message');
end

%% STEP 4: CREATE DATA MATRIX FOR CLUSTERING
fprintf('\nSTEP 4: Preparing data for clustering analysis...\n');

try
    [team_matrix, team_names, kpi_names] = create_team_matrix(aggregated_data);
    
    fprintf('✓ Team matrix created\n');
    fprintf('  Teams: %d\n', size(team_matrix, 1));
    fprintf('  Features: %d\n', size(team_matrix, 2));
    fprintf('  Key KPIs: %s\n', strjoin(kpi_names(1:min(3,end)), ', '));
    
    % Check for missing values
    missing_count = sum(isnan(team_matrix(:)));
    if missing_count > 0
        fprintf('  Warning: %d missing values found and imputed\n', missing_count);
    end
    
catch ME
    error('Failed to create team matrix: %s', 'ME.message');
end

%% STEP 5: P-ADIC CLUSTERING ANALYSIS
fprintf('\nSTEP 5: P-adic hierarchical clustering...\n');

try
    % Run p-adic clustering
    padic_results = run_padic_clustering(team_matrix, team_names, config);
    
    fprintf('✓ P-adic clustering completed\n');
    fprintf('  Optimal clusters: %d\n', padic_results.optimal_k);
    
    % Display clusters
    if padic_results.optimal_k > 0
        assignments = padic_results.cluster_assignments(:, padic_results.optimal_k);
        
        fprintf('\nP-adic Team Clusters (p=%d):\n', config.prime);
        for tier = 1:padic_results.optimal_k
            tier_teams = team_names(assignments == tier);
            fprintf('  Tier %d: %s\n', tier, strjoin(tier_teams, ', '));
        end
    end
    
catch ME
    warning('P-adic clustering failed: %s', 'ME.message');
    padic_results = struct();
end

%% STEP 6: TRADITIONAL CLUSTERING COMPARISON
fprintf('\nSTEP 6: Traditional clustering comparison...\n');

try
    % Run traditional clustering methods
    traditional_results = run_traditional_clustering(team_matrix, team_names, config);
    
    fprintf('✓ Traditional clustering completed\n');
    
    % Compare methods
    comparison_results = compare_clustering_methods(padic_results, traditional_results, team_names);
    
    fprintf('\nClustering Method Comparison:\n');
    if isfield(comparison_results, 'best_method')
        fprintf('  Best method: %s\n', comparison_results.best_method);
    end
    
    if isfield(comparison_results, 'silhouette_scores')
        scores = comparison_results.silhouette_scores;
        fprintf('  P-adic silhouette: %.3f\n', scores.padic);
        fprintf('  K-means silhouette: %.3f\n', scores.kmeans);
        fprintf('  Hierarchical silhouette: %.3f\n', scores.hierarchical);
    end
    
catch ME
    warning('Traditional clustering comparison failed: %s', 'ME.message');
    traditional_results = struct();
    comparison_results = struct();
end

%% STEP 7: STRATEGIC EVOLUTION ANALYSIS
fprintf('\nSTEP 7: Strategic evolution analysis...\n');

try
    evolution_results = analyze_strategic_evolution(aggregated_data, config);
    
    fprintf('✓ Evolution analysis completed\n');
    
    if isfield(evolution_results, 'team_patterns')
        pattern_summary = summarize_evolution_patterns(evolution_results.team_patterns);
        
        fprintf('\nStrategic Evolution Patterns:\n');
        pattern_types = fieldnames(pattern_summary);
        for i = 1:length(pattern_types)
            pattern_name = pattern_types{i};
            count = pattern_summary.(pattern_name);
            fprintf('  %s: %d teams\n', strrep(pattern_name, '_', ' '), count);
        end
    end
    
catch ME
    warning('Strategic evolution analysis failed: %s', 'ME.message');
    evolution_results = struct();
end

%% STEP 8: GENERATE VISUALIZATIONS
if config.generate_plots
    fprintf('\nSTEP 8: Generating visualizations...\n');
    
    try
        % Create clustering visualization
        if exist('padic_results', 'var') && isfield(padic_results, 'optimal_k')
            create_clustering_plots(team_matrix, team_names, padic_results, traditional_results);
            fprintf('✓ Clustering plots created\n');
        end
        
        % Create evolution visualization
        if exist('evolution_results', 'var') && ~isempty(evolution_results)
            create_evolution_plots(evolution_results);
            fprintf('✓ Evolution plots created\n');
        end
        
        % Create comparison visualization
        if exist('comparison_results', 'var') && ~isempty(comparison_results)
            create_comparison_plots(comparison_results);
            fprintf('✓ Comparison plots created\n');
        end
        
    catch ME
        warning('Visualization generation failed: %s', 'ME.message');
    end
end

%% STEP 9: SAVE RESULTS
if config.save_results
    fprintf('\nSTEP 9: Saving results...\n');
    
    try
        % Save all results to .mat file
        results = struct();
        results.config = config;
        results.raw_data = raw_data;
        results.aggregated_data = aggregated_data;
        results.team_matrix = team_matrix;
        results.team_names = team_names;
        results.kpi_names = kpi_names;
        
        if exist('padic_results', 'var')
            results.padic_results = padic_results;
        end
        if exist('traditional_results', 'var')
            results.traditional_results = traditional_results;
        end
        if exist('comparison_results', 'var')
            results.comparison_results = comparison_results;
        end
        if exist('evolution_results', 'var')
            results.evolution_results = evolution_results;
        end
        
        save('rugby_padic_analysis_results.mat', 'results');
        fprintf('✓ Results saved to rugby_padic_analysis_results.mat\n');
        
        % Generate text report
        generate_text_report(results, 'rugby_analysis_report.txt');
        fprintf('✓ Text report saved to rugby_analysis_report.txt\n');
        
    catch ME
        warning('Failed to save results: %s', 'ME.message');
    end
end

%% STEP 10: SUMMARY AND INTERPRETATION
fprintf('\n=== ANALYSIS SUMMARY ===\n');

fprintf('\nKey Findings:\n');

% Clustering insights
if exist('padic_results', 'var') && isfield(padic_results, 'optimal_k')
    fprintf('1. P-adic clustering identified %d natural tiers\n', padic_results.optimal_k);
end

% Method comparison
if exist('comparison_results', 'var') && isfield(comparison_results, 'best_method')
    fprintf('2. Best clustering method: %s\n', comparison_results.best_method);
end

% Evolution patterns
if exist('evolution_results', 'var') && isfield(evolution_results, 'team_patterns')
    n_patterns = length(unique({evolution_results.team_patterns.type}));
    fprintf('3. Strategic evolution shows %d distinct patterns\n', n_patterns);
end

fprintf('\nInterpretation Guidelines:\n');
fprintf('- Tiers should reflect rugby performance hierarchy\n');
fprintf('- P-adic advantages suggest hierarchical competitive structure\n');
fprintf('- Evolution patterns reveal strategic adaptation cycles\n');
fprintf('- Check if results match rugby domain knowledge\n');

fprintf('\nNext Steps:\n');
fprintf('1. Review clustering results for rugby validity\n');
fprintf('2. Analyze evolution patterns for coaching insights\n');
fprintf('3. Test different primes (p=3,5,7) for comparison\n');
fprintf('4. Validate findings with rugby experts\n');

fprintf('\n=== RUGBY P-ADIC ANALYSIS COMPLETED ===\n');
fprintf('Check generated files and figures for detailed results.\n');