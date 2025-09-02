%% Normality Assessment for KPI Validation
% Comprehensive normality testing before four-axiom validation
% Tests distributional assumptions underlying the theoretical framework

clear; close all; clc;

fprintf('=== NORMALITY ASSESSMENT FOR RUGBY KPIs ===\n');

%% Set up paths
script_dir = fileparts(mfilename('fullpath'));
project_root = fullfile(script_dir, '..');
cd(project_root);
fprintf('✓ Working directory: %s\n', pwd);

%% Load Rugby Dataset
fprintf('Loading rugby analysis data...\n');
data_file = 'data/processed/rugby_analysis_ready.csv';
if exist(data_file, 'file')
    data = readtable(data_file);
    fprintf('✓ Loaded data from %s\n', data_file);
else
    error('Data file not found: %s', data_file);
end

%% Data Structure Analysis
fprintf('\nAnalyzing data structure...\n');

% Get column names
column_names = data.Properties.VariableNames;
fprintf('Total columns: %d\n', length(column_names));

% Identify KPI columns (absolute and relative)
abs_kpi_cols = {};
rel_kpi_cols = {};

for i = 1:length(column_names)
    col = column_names{i};
    if startsWith(col, 'abs_')
        abs_kpi_cols{end+1} = col(5:end); % Remove 'abs_' prefix
    elseif startsWith(col, 'rel_')
        rel_kpi_cols{end+1} = col(5:end); % Remove 'rel_' prefix
    end
end

fprintf('Absolute KPI columns: %d\n', length(abs_kpi_cols));
fprintf('Relative KPI columns: %d\n', length(rel_kpi_cols));

% Check for matching KPIs
common_kpis = intersect(abs_kpi_cols, rel_kpi_cols);
fprintf('Common KPIs for validation: %d\n', length(common_kpis));

% Display KPI names
fprintf('\nKPIs to validate:\n');
for i = 1:min(10, length(common_kpis))
    fprintf('  %s\n', common_kpis{i});
end
if length(common_kpis) > 10
    fprintf('  ... and %d more\n', length(common_kpis) - 10);
end

%% Restructure Data for Match-Based Analysis
fprintf('\nRestructuring data for match-based analysis...\n');

% Group data by season and match to create team pairs
unique_seasons = unique(data.season);
match_data = struct();

match_count = 0;
for s = 1:length(unique_seasons)
    season = unique_seasons{s};
    season_data = data(strcmp(data.season, season), :);
    
    % Find unique teams in this season
    unique_teams = unique(season_data.team);
    
    % Create all possible team pairs (matches)
    for i = 1:length(unique_teams)
        for j = i+1:length(unique_teams)
            team1 = unique_teams{i};
            team2 = unique_teams{j};
            
            % Find data for both teams
            team1_data = season_data(strcmp(season_data.team, team1), :);
            team2_data = season_data(strcmp(season_data.team, team2), :);
            
            if ~isempty(team1_data) && ~isempty(team2_data)
                match_count = match_count + 1;
                
                % Store match data
                match_data(match_count).season = season;
                match_data(match_count).team1 = team1;
                match_data(match_count).team2 = team2;
                match_data(match_count).team1_data = team1_data;
                match_data(match_count).team2_data = team2_data;
                
                % Determine outcome (which team won)
                if team1_data.outcome_binary(1) == 1  % Take first row's outcome
                    match_data(match_count).winner = team1;
                    match_data(match_count).loser = team2;
                    match_data(match_count).outcome = 1; % Team 1 wins
                else
                    match_data(match_count).winner = team2;
                    match_data(match_count).loser = team1;
                    match_data(match_count).outcome = 0; % Team 2 wins
                end
            end
        end
    end
end

fprintf('✓ Created %d match pairs for analysis\n', match_count);

%% Normality Assessment Results Storage
normality_results = struct();
normality_summary = zeros(length(common_kpis), 6); % 6 metrics per KPI
transformation_recommendations = cell(length(common_kpis), 1);

%% Main Normality Assessment Loop
fprintf('\nStarting normality assessment...\n\n');

for k = 1:length(common_kpis)
    kpi = common_kpis{k};
    fprintf('--- Assessing KPI: %s ---\n', kpi);
    
    % Extract KPI data for all matches
    X_A = zeros(match_count, 1);
    X_B = zeros(match_count, 1);
    R = zeros(match_count, 1);
    
    for m = 1:match_count
        match = match_data(m);
        
        % Get KPI values for both teams
        abs_col = ['abs_' kpi];
        rel_col = ['rel_' kpi];
        
        % Extract first row's data for each team
        X_A(m) = match.team1_data.(abs_col)(1);
        X_B(m) = match.team2_data.(abs_col)(1);
        R(m) = match.team1_data.(rel_col)(1); % Relative measure from team1's perspective
    end
    
    % Individual team assessments
    [norm_A, trans_A] = assess_normality(X_A, [kpi '_A']);
    [norm_B, trans_B] = assess_normality(X_B, [kpi '_B']);
    
    % Combined data assessment
    X_combined = [X_A; X_B];
    [norm_combined, trans_combined] = assess_normality(X_combined, [kpi '_combined']);
    
    % Relative measure normality (CRITICAL for framework)
    [norm_relative, trans_relative] = assess_normality(R, [kpi '_relative']);
    
    % Store comprehensive results
    normality_results.(kpi) = struct(...
        'team_A', norm_A, 'team_B', norm_B, ...
        'combined', norm_combined, 'relative', norm_relative, ...
        'transformation_A', trans_A, 'transformation_B', trans_B, ...
        'transformation_relative', trans_relative);
    
    % Summary scoring (0-1 scale for each metric)
    normality_summary(k, :) = [norm_A.overall_score, norm_B.overall_score, ...
                              norm_combined.overall_score, norm_relative.overall_score, ...
                              norm_relative.sw_pvalue, norm_relative.skewness_score];
    
    % Transformation recommendation
    transformation_recommendations{k} = recommend_transformation(norm_A, norm_B, norm_relative);
    
    fprintf('  Team A Normality Score: %.3f\n', norm_A.overall_score);
    fprintf('  Team B Normality Score: %.3f\n', norm_B.overall_score);
    fprintf('  Relative Measure Score: %.3f (CRITICAL)\n', norm_relative.overall_score);
    fprintf('  Transformation Needed: %s\n\n', transformation_recommendations{k});
end

%% Generate Comprehensive Assessment Report
fprintf('=== GENERATING NORMALITY REPORT ===\n');
generate_normality_report(common_kpis, normality_results, normality_summary, transformation_recommendations);

%% Create Normality Dashboard
create_normality_dashboard(common_kpis, normality_results, normality_summary, match_data);

%% Filter KPIs for Axiom Testing
validated_kpis = filter_kpis_for_axiom_testing(common_kpis, transformation_recommendations);

%% NORMALITY ASSESSMENT FUNCTIONS

function [normality_metrics, transformation_suggestion] = assess_normality(data, data_name)
    %ASSESS_NORMALITY Comprehensive normality testing for single dataset
    %
    % Returns detailed normality metrics and transformation suggestions
    
    % Remove any infinite or NaN values
    data = data(isfinite(data));
    n = length(data);
    
    if n < 20
        warning('Sample size too small for reliable normality testing: %s', data_name);
        normality_metrics = struct('overall_score', 0);
        transformation_suggestion = 'insufficient_data';
        return;
    end
    
    %% Statistical Tests
    % Shapiro-Wilk Test (most powerful for normal alternatives)
    if n <= 5000 % SW test limitation
        try
            [sw_h, sw_p] = swtest(data, 0.05);
            sw_score = sw_p; % Higher p-value = more normal
        catch
            sw_h = NaN; sw_p = NaN; sw_score = NaN;
        end
    else
        sw_h = NaN; sw_p = NaN; sw_score = NaN;
    end
    
    % Lilliefors Test (composite normality test)
    try
        [lf_h, lf_p] = lillietest(data, 'Alpha', 0.05);
        lf_score = lf_p;
    catch
        lf_h = NaN; lf_p = NaN; lf_score = NaN;
    end
    
    % Anderson-Darling Test
    try
        [ad_h, ad_p] = adtest(data, 'Alpha', 0.05);
        ad_score = ad_p;
    catch
        ad_h = NaN; ad_p = NaN; ad_score = NaN;
    end
    
    % Kolmogorov-Smirnov Test (against estimated normal)
    try
        [ks_h, ks_p] = kstest(zscore(data), 'Alpha', 0.05);
        ks_score = ks_p;
    catch
        ks_h = NaN; ks_p = NaN; ks_score = NaN;
    end
    
    %% Descriptive Statistics
    data_mean = mean(data);
    data_std = std(data);
    data_skewness = skewness(data);
    data_kurtosis = kurtosis(data) - 3; % Excess kurtosis
    
    % Normality scores based on descriptive statistics
    skewness_score = max(0, 1 - abs(data_skewness) / 2); % Penalize |skewness| > 2
    kurtosis_score = max(0, 1 - abs(data_kurtosis) / 3); % Penalize |excess kurtosis| > 3
    
    %% Visual Assessment Metrics
    % Q-Q plot correlation (higher = more normal)
    sorted_data = sort(data);
    theoretical_quantiles = norminv((1:n) / (n + 1));
    empirical_quantiles = zscore(sorted_data);
    
    % Ensure both vectors are column vectors for correlation
    if size(theoretical_quantiles, 1) == 1
        theoretical_quantiles = theoretical_quantiles';
    end
    if size(empirical_quantiles, 1) == 1
        empirical_quantiles = empirical_quantiles';
    end
    
    qq_correlation = corr(theoretical_quantiles, empirical_quantiles);
    
    %% Overall Normality Score
    % Combine multiple metrics (weight critical tests more heavily)
    test_scores = [sw_score, lf_score, ad_score, ks_score];
    test_scores = test_scores(~isnan(test_scores));
    
    if ~isempty(test_scores)
        test_score_avg = mean(test_scores);
    else
        test_score_avg = 0;
    end
    
    overall_score = 0.4 * test_score_avg + ...        % Statistical tests (40%)
                   0.2 * skewness_score + ...          % Skewness (20%)
                   0.2 * kurtosis_score + ...          % Kurtosis (20%)
                   0.2 * abs(qq_correlation);          % Q-Q correlation (20%)
    
    %% Package Results
    normality_metrics = struct(...
        'n', n, ...
        'sw_h', sw_h, 'sw_pvalue', sw_p, 'sw_score', sw_score, ...
        'lf_h', lf_h, 'lf_pvalue', lf_p, 'lf_score', lf_score, ...
        'ad_h', ad_h, 'ad_pvalue', ad_p, 'ad_score', ad_score, ...
        'ks_h', ks_h, 'ks_pvalue', ks_p, 'ks_score', ks_score, ...
        'mean', data_mean, 'std', data_std, ...
        'skewness', data_skewness, 'kurtosis', data_kurtosis, ...
        'skewness_score', skewness_score, 'kurtosis_score', kurtosis_score, ...
        'qq_correlation', qq_correlation, ...
        'overall_score', overall_score);
    
    %% Transformation Suggestion
    if overall_score >= 0.7
        transformation_suggestion = 'none_needed';
    elseif data_skewness > 1.5 && min(data) > 0
        transformation_suggestion = 'log_transform';
    elseif data_skewness < -1.5
        transformation_suggestion = 'sqrt_transform';
    elseif abs(data_kurtosis) > 2
        transformation_suggestion = 'box_cox';
    else
        transformation_suggestion = 'consider_box_cox';
    end
end

function recommendation = recommend_transformation(norm_A, norm_B, norm_relative)
    %RECOMMEND_TRANSFORMATION Overall transformation recommendation
    %
    % Priority: Relative measure normality is most critical for framework
    
    relative_score = norm_relative.overall_score;
    min_team_score = min(norm_A.overall_score, norm_B.overall_score);
    
    if relative_score >= 0.7 && min_team_score >= 0.6
        recommendation = 'READY_FOR_AXIOMS';
    elseif relative_score >= 0.5
        recommendation = 'CONDITIONAL';
    else
        recommendation = 'TRANSFORM_REQUIRED';
    end
end

function generate_normality_report(kpi_names, normality_results, normality_summary, transformations)
    %GENERATE_NORMALITY_REPORT Comprehensive normality assessment report
    
    fprintf('\n=== NORMALITY ASSESSMENT SUMMARY ===\n');
    
    % Overall rankings by relative measure normality (most critical)
    relative_scores = normality_summary(:, 4);
    [sorted_scores, ranking_idx] = sort(relative_scores, 'descend');
    
    fprintf('\nKPI RANKING (by relative measure normality - CRITICAL for framework):\n');
    fprintf('%-20s | Team A | Team B | Relative | SW p-val | Recommendation\n', 'KPI');
    fprintf('%s\n', repmat('-', 1, 80));
    
    for i = 1:length(kpi_names)
        idx = ranking_idx(i);
        fprintf('%-20s | %.3f  | %.3f  | %.3f    | %.3f    | %s\n', ...
            kpi_names{idx}, normality_summary(idx, 1), normality_summary(idx, 2), ...
            normality_summary(idx, 4), normality_summary(idx, 5), transformations{idx});
    end
    
    % Framework readiness assessment
    fprintf('\n=== FRAMEWORK READINESS ASSESSMENT ===\n');
    ready_kpis = find(contains(transformations, 'READY_FOR_AXIOMS'));
    conditional_kpis = find(contains(transformations, 'CONDITIONAL'));
    transform_required = find(contains(transformations, 'TRANSFORM_REQUIRED'));
    
    fprintf('READY FOR AXIOM TESTING (%d): ', length(ready_kpis));
    if ~isempty(ready_kpis)
        fprintf('%s ', kpi_names{ready_kpis});
    end
    fprintf('\n');
    
    fprintf('CONDITIONAL TESTING (%d): ', length(conditional_kpis));
    if ~isempty(conditional_kpis)
        fprintf('%s ', kpi_names{conditional_kpis});
    end
    fprintf('\n');
    
    fprintf('TRANSFORMATION REQUIRED (%d): ', length(transform_required));
    if ~isempty(transform_required)
        fprintf('%s ', kpi_names{transform_required});
    end
    fprintf('\n\n');
    
    % Statistical summary
    mean_relative_score = mean(relative_scores);
    fprintf('Mean Relative Measure Normality Score: %.3f\n', mean_relative_score);
    fprintf('KPIs with Strong Normality (≥0.7): %d/%d (%.1f%%)\n', ...
        sum(relative_scores >= 0.7), length(relative_scores), ...
        100 * sum(relative_scores >= 0.7) / length(relative_scores));
end

function create_normality_dashboard(kpi_names, normality_results, normality_summary, match_data)
    %CREATE_NORMALITY_DASHBOARD Visual dashboard for normality assessment
    
    figure('Position', [50, 50, 1400, 900]);
    
    % 1. Overall Normality Scores Heatmap
    subplot(2, 3, 1);
    heatmap_data = normality_summary(:, 1:4); % Team A, Team B, Combined, Relative
    imagesc(heatmap_data');
    colormap(parula);
    colorbar;
    caxis([0, 1]);
    
    set(gca, 'XTick', 1:length(kpi_names));
    set(gca, 'XTickLabel', kpi_names);
    set(gca, 'XTickLabelRotation', 45);
    set(gca, 'YTick', 1:4);
    set(gca, 'YTickLabel', {'Team A', 'Team B', 'Combined', 'Relative'});
    
    title('Normality Scores', 'FontWeight', 'bold');
    
    % 2. Relative Measure Focus (most critical)
    subplot(2, 3, 2);
    relative_scores = normality_summary(:, 4);
    [sorted_rel, sort_idx] = sort(relative_scores, 'descend');
    
    bar(sorted_rel, 'FaceColor', [0.2, 0.6, 0.8]);
    set(gca, 'XTick', 1:length(kpi_names));
    set(gca, 'XTickLabel', kpi_names(sort_idx));
    set(gca, 'XTickLabelRotation', 45);
    
    title('Relative Measure Normality (Critical)', 'FontWeight', 'bold');
    ylabel('Normality Score');
    ylim([0, 1]);
    
    % Add threshold lines
    hold on;
    plot([0, length(kpi_names)+1], [0.7, 0.7], 'g--', 'LineWidth', 2);
    plot([0, length(kpi_names)+1], [0.5, 0.5], 'r--', 'LineWidth', 2);
    legend({'Normality Score', 'Strong Threshold', 'Weak Threshold'}, 'Location', 'northeast');
    grid on;
    
    % 3. Distribution Shape Assessment
    subplot(2, 3, 3);
    skewness_scores = normality_summary(:, 6);
    scatter(relative_scores, skewness_scores, 100, 'filled');
    xlabel('Relative Measure Normality');
    ylabel('Skewness Score');
    title('Normality vs Shape Assessment', 'FontWeight', 'bold');
    
    % Add quadrant lines
    hold on;
    plot([0.5, 0.5], [0, 1], 'k--');
    plot([0, 1], [0.5, 0.5], 'k--');
    text(0.75, 0.75, 'Good', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'g');
    text(0.25, 0.25, 'Poor', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'r');
    grid on;
    
    % 4-6. Example Q-Q plots for top 3 KPIs by relative measure normality
    top_3_idx = sort_idx(1:min(3, length(kpi_names)));
    
    for i = 1:min(3, length(kpi_names))
        subplot(2, 3, 3 + i);
        kpi_idx = top_3_idx(i);
        kpi = kpi_names{kpi_idx};
        
        % Get relative measure data
        R = zeros(length(match_data), 1);
        for m = 1:length(match_data)
            rel_col = ['rel_' kpi];
            R(m) = match_data(m).team1_data.(rel_col)(1);
        end
        
        % Q-Q plot
        qqplot(R);
        title(sprintf('%s (Relative Measure)', strrep(kpi, '_', ' ')), 'FontWeight', 'bold');
        
        % Add normality score annotation
        score = relative_scores(kpi_idx);
        text(0.05, 0.95, sprintf('Score: %.3f', score), 'Units', 'normalized', ...
             'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'white');
    end
    
    sgtitle('Normality Assessment Dashboard for Rugby KPIs', ...
            'FontSize', 16, 'FontWeight', 'bold');
end

%% Integration with Axiom Testing
function validated_kpis = filter_kpis_for_axiom_testing(kpi_names, transformations)
    %FILTER_KPIS_FOR_AXIOM_TESTING Return KPIs ready for axiom validation
    %
    % Only returns KPIs that meet normality requirements
    
    ready_indices = contains(transformations, 'READY_FOR_AXIOMS');
    conditional_indices = contains(transformations, 'CONDITIONAL');
    
    % Include both ready and conditional KPIs (with warnings)
    valid_indices = ready_indices | conditional_indices;
    validated_kpis = kpi_names(valid_indices);
    
    fprintf('\n=== FILTERED KPIs FOR AXIOM TESTING ===\n');
    fprintf('Ready: %d, Conditional: %d, Total: %d\n', ...
        sum(ready_indices), sum(conditional_indices), sum(valid_indices));
    
    if sum(valid_indices) < 0.5 * length(kpi_names)
        warning('Less than 50%% of KPIs meet normality requirements. Consider transformations.');
    end
    
    fprintf('\nKPIs ready for axiom testing:\n');
    for i = 1:length(validated_kpis)
        fprintf('  %s\n', validated_kpis{i});
    end
end

%% Helper Functions
function [h, p] = swtest(data, alpha)
    %SWTEST Shapiro-Wilk test implementation
    % Use Statistics Toolbox swtest if available, otherwise implement basic version
    
    try
        % Try to use Statistics Toolbox
        [h, p] = swtest(data, alpha);
    catch
        % Basic implementation for Shapiro-Wilk test
        n = length(data);
        if n < 3
            h = NaN; p = NaN;
            return;
        end
        
        % Sort data
        y = sort(data);
        
        % Shapiro-Wilk coefficients (approximate for n <= 50)
        if n <= 50
            % Use approximate coefficients
            a = shapiro_wilk_coeffs(n);
            if isempty(a)
                h = NaN; p = NaN;
                return;
            end
            
            % Calculate W statistic
            numerator = sum(a .* y);
            denominator = sum((y - mean(y)).^2);
            
            if denominator == 0
                W = 1;
            else
                W = (numerator^2) / (n * denominator);
            end
            
            % Approximate p-value (this is simplified)
            if W > 0.9
                p = 0.1; % Approximate
            elseif W > 0.8
                p = 0.05; % Approximate
            else
                p = 0.01; % Approximate
            end
            
            h = (p < alpha);
        else
            % For larger samples, use a different approach
            h = NaN; p = NaN;
        end
    end
end

function a = shapiro_wilk_coeffs(n)
    %SHAPIRO_WILK_COEFFS Return Shapiro-Wilk coefficients for given n
    % This is a simplified version - in practice, use exact coefficients
    
    if n <= 50
        % Approximate coefficients (simplified)
        a = ones(1, n);
        a(1) = -0.7071;
        a(n) = 0.7071;
        if n > 2
            a(2) = -0.5;
            a(n-1) = 0.5;
        end
    else
        a = [];
    end
end

%% Export Results (optional)
function export_normality_results(kpi_names, normality_summary, transformations)
    %EXPORT_NORMALITY_RESULTS Save normality assessment to files
    
    results_table = table(kpi_names', normality_summary(:,1), normality_summary(:,2), ...
                         normality_summary(:,3), normality_summary(:,4), ...
                         normality_summary(:,5), transformations', ...
                         'VariableNames', {'KPI', 'TeamA_Score', 'TeamB_Score', ...
                         'Combined_Score', 'Relative_Score', 'SW_PValue', 'Recommendation'});
    
    writetable(results_table, 'normality_assessment_results.csv');
    fprintf('\nNormality assessment exported to: normality_assessment_results.csv\n');
end

% Uncomment to export results
% export_normality_results(common_kpis, normality_summary, transformation_recommendations);

fprintf('\n=== NORMALITY ASSESSMENT COMPLETE ===\n');
fprintf('Assessed %d KPIs for normality requirements\n', length(common_kpis));
fprintf('Results ready for axiom validation filtering\n');
