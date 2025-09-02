function [sigma_eta, sigma_indiv, variance_components] = environmentalEstimation(data, varargin)
%ENVIRONMENTALESTIMATION Estimate environmental and individual noise components
%
% This function estimates the environmental noise (σ_η) and individual noise (σ_indiv)
% components from performance data using various statistical methods.
%
% Inputs:
%   data - Struct with fields:
%          - season: season identifiers
%          - team: team identifiers  
%          - [metric_name]: performance values for each metric
%   varargin - Optional parameters:
%              - method: 'anova', 'mixed_effects', or 'variance_components'
%              - confidence_level: confidence level for intervals (default: 0.95)
%              - metrics: cell array of metric names to analyze (default: all available)
%
% Outputs:
%   sigma_eta - Standard deviation of environmental noise
%   sigma_indiv - Standard deviation of individual noise
%   variance_components - Struct with detailed variance analysis
%
% Author: UP1 Research Team
% Date: 2024

%% Parse inputs
p = inputParser;
addParameter(p, 'method', 'anova', @ischar);
addParameter(p, 'confidence_level', 0.95, @isnumeric);
addParameter(p, 'metrics', {}, @iscell);

parse(p, varargin{:});
method = p.Results.method;
confidence_level = p.Results.confidence_level;
requested_metrics = p.Results.metrics;

%% Get available metrics from data
available_metrics = {};
if isstruct(data)
    % Extract metric names from data structure
    data_fields = fieldnames(data);
    for i = 1:length(data_fields)
        field = data_fields{i};
        % Skip non-metric fields
        if ~ismember(field, {'season', 'team', 'match_location', 'outcome', 'outcome_binary'})
            if isnumeric(data.(field)) && length(data.(field)) > 1
                available_metrics{end+1} = field;
            end
        end
    end
end

% Use requested metrics if specified, otherwise use all available
if isempty(requested_metrics)
    metrics_to_analyze = available_metrics;
else
    % Filter to only requested metrics that exist
    metrics_to_analyze = intersect(requested_metrics, available_metrics);
    if length(metrics_to_analyze) < length(requested_metrics)
        missing = setdiff(requested_metrics, available_metrics);
        warning('Some requested metrics not found: %s', strjoin(missing, ', '));
    end
end

if isempty(metrics_to_analyze)
    error('No valid metrics found in data');
end

fprintf('Analyzing %d metrics: %s\n', length(metrics_to_analyze), strjoin(metrics_to_analyze(1:min(5, end)), ', '));
if length(metrics_to_analyze) > 5
    fprintf('  ... and %d more\n', length(metrics_to_analyze) - 5);
end

%% Estimate variance components based on method
switch lower(method)
    case 'anova'
        [sigma_eta, sigma_indiv, variance_components] = estimateVarianceANOVA(...
            data, metrics_to_analyze, confidence_level);
    case 'mixed_effects'
        [sigma_eta, sigma_indiv, variance_components] = estimateVarianceMixedEffects(...
            data, metrics_to_analyze, confidence_level);
    case 'variance_components'
        [sigma_eta, sigma_indiv, variance_components] = estimateVarianceComponents(...
            data, metrics_to_analyze, confidence_level);
    otherwise
        error('Unknown method: %s. Use ''anova'', ''mixed_effects'', or ''variance_components''', method);
end

%% Calculate additional variance metrics
variance_components.environmental_ratio = sigma_eta^2 / (sigma_eta^2 + sigma_indiv^2);
variance_components.snr_improvement_theoretical = calculateTheoreticalSNRImprovement(sigma_eta, sigma_indiv);

%% Display results
fprintf('Environmental noise estimation completed:\n');
fprintf('  σ_η: %.3f\n', sigma_eta);
fprintf('  σ_indiv: %.3f\n', sigma_indiv);
fprintf('  Environmental ratio: %.3f\n', variance_components.environmental_ratio);
fprintf('  Theoretical SNR improvement: %.3f\n', variance_components.snr_improvement_theoretical);

end

function [sigma_eta, sigma_indiv, variance_components] = estimateVarianceANOVA(data, metrics, confidence_level)
%ESTIMATEVARIANCEANOVA Estimate variance using ANOVA method
    
    fprintf('Using ANOVA method for variance estimation...\n');
    
    % Initialize storage
    n_metrics = length(metrics);
    eta_variances = zeros(n_metrics, 1);
    indiv_variances = zeros(n_metrics, 1);
    total_variances = zeros(n_metrics, 1);
    
    % Analyze each metric
    for i = 1:n_metrics
        metric = metrics{i};
        
        if ~isfield(data, metric)
            warning('Metric %s not found in dataset, skipping...', metric);
            continue;
        end
        
        % Extract metric values and grouping variables
        values = data.(metric);
        
        % Check if we have season and team information
        if isfield(data, 'season') && isfield(data, 'team')
            seasons = data.season;
            teams = data.team;
        else
            % If no grouping variables, use simple variance estimation
            warning('No grouping variables found, using simple variance estimation for %s', metric);
            valid_values = values(~isnan(values));
            if length(valid_values) > 1
                total_variances(i) = var(valid_values);
                % Assume equal split between environmental and individual
                eta_variances(i) = total_variances(i) * 0.5;
                indiv_variances(i) = total_variances(i) * 0.5;
            end
            continue;
        end
        
        % Remove NaN values
        valid_idx = ~isnan(values);
        if sum(valid_idx) < 10  % Need sufficient data
            warning('Insufficient data for metric %s, skipping...', metric);
            continue;
        end
        
        values = values(valid_idx);
        seasons = seasons(valid_idx);
        teams = teams(valid_idx);
        
        try
            % Perform one-way ANOVA for seasons (environmental effect)
            [~, season_table] = anova1(values, seasons, 'off');
            
            % Extract sum of squares from ANOVA table
            if size(season_table, 1) >= 3
                season_ss = season_table{2, 2}; % Sum of squares between groups
                season_df = season_table{2, 3}; % Degrees of freedom between groups
                error_ss = season_table{3, 2}; % Sum of squares within groups
                error_df = season_table{3, 3}; % Degrees of freedom within groups
            else
                warning('ANOVA table structure unexpected for metric %s', metric);
                continue;
            end
            
            % Perform one-way ANOVA for teams (individual effect)
            [~, team_table] = anova1(values, teams, 'off');
            
            % Extract sum of squares from ANOVA table
            if size(team_table, 1) >= 3
                team_ss = team_table{2, 2}; % Sum of squares between groups
                team_df = team_table{2, 3}; % Degrees of freedom between groups
            else
                warning('ANOVA table structure unexpected for metric %s', metric);
                continue;
            end
            
            % Calculate variance components
            n_seasons = length(unique(seasons));
            n_teams = length(unique(teams));
            n_per_group = length(values) / (n_seasons * n_teams);
            
            if n_per_group > 0
                % Environmental variance (season effect)
                eta_variances(i) = max(0, (season_ss - (n_seasons - 1) * indiv_variances(i)) / (n_seasons * n_per_group));
                
                % Individual variance (team effect)
                indiv_variances(i) = max(0, (team_ss - (n_teams - 1) * eta_variances(i)) / (n_teams * n_per_group));
                
                % Total variance
                total_variances(i) = (season_ss + team_ss + error_ss) / (length(values) - 1);
            end
            
        catch ME
            warning('ANOVA failed for metric %s: %s', metric, ME.message);
            % Fallback to simple variance estimation
            valid_values = values(~isnan(values));
            if length(valid_values) > 1
                total_variances(i) = var(valid_values);
                % Assume equal split between environmental and individual
                eta_variances(i) = total_variances(i) * 0.5;
                indiv_variances(i) = total_variances(i) * 0.5;
            end
            continue;
        end
    end
    
    % Calculate overall variances (mean across metrics)
    valid_metrics = ~isnan(eta_variances) & ~isnan(indiv_variances);
    if sum(valid_metrics) == 0
        error('No valid variance estimates obtained');
    end
    
    sigma_eta = sqrt(mean(eta_variances(valid_metrics)));
    sigma_indiv = sqrt(mean(indiv_variances(valid_metrics)));
    
    % Store detailed results
    variance_components = struct();
    variance_components.method = 'anova';
    variance_components.metrics_analyzed = metrics(valid_metrics);
    variance_components.eta_variances = eta_variances(valid_metrics);
    variance_components.indiv_variances = indiv_variances(valid_metrics);
    variance_components.total_variances = total_variances(valid_metrics);
    variance_components.confidence_level = confidence_level;
    
    % Calculate confidence intervals
    [ci_eta, ci_indiv] = calculateConfidenceIntervals(...
        eta_variances(valid_metrics), indiv_variances(valid_metrics), confidence_level);
    variance_components.confidence_intervals = struct();
    variance_components.confidence_intervals.eta = ci_eta;
    variance_components.confidence_intervals.indiv = ci_indiv;
end

function [sigma_eta, sigma_indiv, variance_components] = estimateVarianceMixedEffects(data, metrics, confidence_level)
%ESTIMATEVARIANCEMIXEDEFFECTS Estimate variance using mixed effects models
    
    fprintf('Mixed effects method not yet implemented, using ANOVA fallback...\n');
    [sigma_eta, sigma_indiv, variance_components] = estimateVarianceANOVA(data, metrics, confidence_level);
    variance_components.method = 'mixed_effects_fallback';
end

function [sigma_eta, sigma_indiv, variance_components] = estimateVarianceComponents(data, metrics, confidence_level)
%ESTIMATEVARIANCECOMPONENTS Estimate variance using variance components analysis
    
    fprintf('Variance components method not yet implemented, using ANOVA fallback...\n');
    [sigma_eta, sigma_indiv, variance_components] = estimateVarianceANOVA(data, metrics, confidence_level);
    variance_components.method = 'variance_components_fallback';
end

function [ci_eta, ci_indiv] = calculateConfidenceIntervals(eta_vars, indiv_vars, confidence_level)
%CALCULATECONFIDENCEINTERVALS Calculate confidence intervals for variance estimates
    
    alpha = 1 - confidence_level;
    
    % For environmental variance
    if length(eta_vars) > 1
        se_eta = std(eta_vars) / sqrt(length(eta_vars));
        t_crit = tinv(1 - alpha/2, length(eta_vars) - 1);
        ci_eta = [mean(eta_vars) - t_crit * se_eta, mean(eta_vars) + t_crit * se_eta];
    else
        ci_eta = [eta_vars, eta_vars];
    end
    
    % For individual variance
    if length(indiv_vars) > 1
        se_indiv = std(indiv_vars) / sqrt(length(indiv_vars));
        t_crit = tinv(1 - alpha/2, length(indiv_vars) - 1);
        ci_indiv = [mean(indiv_vars) - t_crit * se_indiv, mean(indiv_vars) + t_crit * se_indiv];
    else
        ci_indiv = [indiv_vars, indiv_vars];
    end
end

function snr_improvement = calculateTheoreticalSNRImprovement(sigma_eta, sigma_indiv)
%CALCULATETHEORETICALSNRIMPROVEMENT Calculate theoretical SNR improvement
    
    if sigma_eta == 0 || sigma_indiv == 0
        snr_improvement = NaN;
        return;
    end
    
    % CORRECTED: Theoretical SNR improvement from environmental noise cancellation
    % Formula from paper: SNR_improvement = 1 + 2σ²_η/(σ²_A + σ²_B)
    % When σ_A = σ_B = σ_indiv (equal individual variances), this becomes:
    % SNR_improvement = 1 + 2σ²_η/(2σ²_indiv) = 1 + σ²_η/σ²_indiv
    
    sigma_eta_squared = sigma_eta^2;
    sigma_indiv_squared = sigma_indiv^2;
    
    % Use the correct formula from the theoretical framework
    snr_improvement = 1 + (sigma_eta_squared / sigma_indiv_squared);
end
