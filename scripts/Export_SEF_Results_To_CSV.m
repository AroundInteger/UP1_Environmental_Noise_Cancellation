function Export_SEF_Results_To_CSV()
    % Export SEF sensitivity analysis results to CSV files for better accessibility
    
    fprintf('=== Exporting SEF Results to CSV ===\n');
    
    % Load sensitivity analysis results
    % Change to project root directory
    project_root = fileparts(mfilename('fullpath'));
    project_root = fileparts(project_root); % Go up one level from scripts/
    cd(project_root);
    
    load('outputs/results/sef_sensitivity_analysis_results.mat');
    
    % Create output directory for CSV files
    if ~exist('outputs/csv', 'dir')
        mkdir('outputs/csv');
    end
    
    % 1. Sample Size Sensitivity Results
    fprintf('  Exporting sample size sensitivity results...\n');
    sample_size_data = struct();
    sample_size_data.sample_size = results.sample_size.sample_sizes';
    sample_size_data.sef_mean = results.sample_size.sef_means';
    sample_size_data.sef_std = results.sample_size.sef_stds';
    sample_size_data.sef_ci_lower = results.sample_size.sef_ci_lower';
    sample_size_data.sef_ci_upper = results.sample_size.sef_ci_upper';
    sample_size_data.coefficient_of_variation = results.sample_size.convergence';
    sample_size_data.converged = results.sample_size.convergence' < 0.1;
    
    sample_size_table = struct2table(sample_size_data);
    writetable(sample_size_table, 'outputs/csv/sample_size_sensitivity_results.csv');
    
    % 2. Temporal Analysis Results
    fprintf('  Exporting temporal analysis results...\n');
    
    % Calculate sample sizes for each season
    load('outputs/results/data_prepared_for_sensitivity.mat');
    
    n_seasons = length(results.temporal.seasons);
    temporal_data = struct();
    temporal_data.season = cell(n_seasons, 1);
    temporal_data.season_id = zeros(n_seasons, 1);
    temporal_data.sef_value = zeros(n_seasons, 1);
    temporal_data.sef_std = zeros(n_seasons, 1);
    temporal_data.sample_size = zeros(n_seasons, 1);
    
    for i = 1:n_seasons
        temporal_data.season{i} = results.temporal.season_strings{i};
        temporal_data.season_id(i) = results.temporal.seasons(i);
        temporal_data.sef_value(i) = results.temporal.seasonal_sef(i);
        temporal_data.sef_std(i) = results.temporal.seasonal_std(i);
        
        season_mask = (data_prepared.matches.seasons == results.temporal.seasons(i));
        temporal_data.sample_size(i) = sum(season_mask);
    end
    
    temporal_table = struct2table(temporal_data);
    writetable(temporal_table, 'outputs/csv/temporal_analysis_results.csv');
    
    % 3. Parameter Sensitivity Results
    fprintf('  Exporting parameter sensitivity results...\n');
    
    % Kappa sensitivity
    n_kappa = length(results.parameter_sensitivity.kappa_range);
    kappa_data = struct();
    kappa_data.parameter_value = results.parameter_sensitivity.kappa_range';
    kappa_data.sef_value = results.parameter_sensitivity.kappa_sef';
    kappa_data.parameter_type = repmat({'kappa'}, n_kappa, 1);
    
    % Rho sensitivity
    n_rho = length(results.parameter_sensitivity.rho_range);
    rho_data = struct();
    rho_data.parameter_value = results.parameter_sensitivity.rho_range';
    rho_data.sef_value = results.parameter_sensitivity.rho_sef';
    rho_data.parameter_type = repmat({'rho'}, n_rho, 1);
    
    % Combine parameter data
    parameter_data = struct();
    parameter_data.parameter_value = [kappa_data.parameter_value(:); rho_data.parameter_value(:)];
    parameter_data.sef_value = [kappa_data.sef_value(:); rho_data.sef_value(:)];
    parameter_data.parameter_type = [kappa_data.parameter_type(:); rho_data.parameter_type(:)];
    
    parameter_table = struct2table(parameter_data);
    writetable(parameter_table, 'outputs/csv/parameter_sensitivity_results.csv');
    
    % 4. Robustness Analysis Results
    fprintf('  Exporting robustness analysis results...\n');
    
    % Outlier sensitivity
    n_outlier = length(results.robustness.outlier_analysis.thresholds);
    outlier_data = struct();
    outlier_data.threshold = results.robustness.outlier_analysis.thresholds';
    outlier_data.sef_value = results.robustness.outlier_analysis.sef_values';
    outlier_data.test_type = repmat({'outlier_removal'}, n_outlier, 1);
    outlier_data.sensitivity_index = repmat(results.robustness.outlier_analysis.sensitivity, n_outlier, 1);
    
    % Noise sensitivity
    n_noise = length(results.robustness.noise_analysis.noise_levels);
    noise_data = struct();
    noise_data.threshold = results.robustness.noise_analysis.noise_levels';
    noise_data.sef_value = results.robustness.noise_analysis.sef_values';
    noise_data.test_type = repmat({'noise_addition'}, n_noise, 1);
    noise_data.sensitivity_index = repmat(results.robustness.noise_analysis.sensitivity, n_noise, 1);
    
    % Combine robustness data
    robustness_data = struct();
    robustness_data.threshold = [outlier_data.threshold(:); noise_data.threshold(:)];
    robustness_data.sef_value = [outlier_data.sef_value(:); noise_data.sef_value(:)];
    robustness_data.test_type = [outlier_data.test_type(:); noise_data.test_type(:)];
    robustness_data.sensitivity_index = [outlier_data.sensitivity_index(:); noise_data.sensitivity_index(:)];
    
    robustness_table = struct2table(robustness_data);
    writetable(robustness_table, 'outputs/csv/robustness_analysis_results.csv');
    
    % 5. Statistical Validation Results
    fprintf('  Exporting statistical validation results...\n');
    validation_data = struct();
    validation_data.test_type = {'bootstrap_significance'};
    validation_data.p_value = results.validation.significance.p_value;
    validation_data.significant = results.validation.significance.significant;
    validation_data.effect_size = results.validation.significance.effect_size;
    validation_data.confidence_level = results.validation.significance.confidence_level;
    validation_data.mean_sef = results.validation.confidence_intervals.mean_sef;
    validation_data.std_sef = results.validation.confidence_intervals.std_sef;
    validation_data.ci_95_lower = results.validation.confidence_intervals.ci_95(1);
    validation_data.ci_95_upper = results.validation.confidence_intervals.ci_95(2);
    validation_data.ci_99_lower = results.validation.confidence_intervals.ci_99(1);
    validation_data.ci_99_upper = results.validation.confidence_intervals.ci_99(2);
    
    validation_table = struct2table(validation_data);
    writetable(validation_table, 'outputs/csv/statistical_validation_results.csv');
    
    % 6. Summary Results
    fprintf('  Exporting summary results...\n');
    summary_data = struct();
    summary_data.metric = {'min_sample_size'; 'seasonal_cv'; 'temporal_trend'; 'kappa_sensitivity'; 'rho_sensitivity'; 'outlier_sensitivity'; 'noise_sensitivity'; 'p_value'; 'mean_sef'; 'se_95_lower'; 'ci_95_upper'};
    summary_data.value = [results.sample_size.min_sample_size; results.temporal.seasonal_cv; results.temporal.temporal_trend; results.parameter_sensitivity.kappa_sensitivity; results.parameter_sensitivity.rho_sensitivity; results.robustness.outlier_analysis.sensitivity; results.robustness.noise_analysis.sensitivity; results.validation.significance.p_value; results.validation.confidence_intervals.mean_sef; results.validation.confidence_intervals.ci_95(1); results.validation.confidence_intervals.ci_95(2)];
    summary_data.description = {'Minimum sample size for convergence'; 'Seasonal coefficient of variation'; 'Temporal trend slope'; 'Kappa parameter sensitivity index'; 'Rho parameter sensitivity index'; 'Outlier sensitivity index'; 'Noise sensitivity index'; 'P-value for SEF > 1'; 'Mean SEF value'; '95% CI lower bound'; '95% CI upper bound'};
    
    summary_table = struct2table(summary_data);
    writetable(summary_table, 'outputs/csv/sensitivity_analysis_summary.csv');
    
    % 7. KPI Analysis Details
    fprintf('  Exporting KPI analysis details...\n');
    
    % Load original data to get KPI details
    load('data/processed/rugby_analysis_ready.mat');
    data = analysis_data;
    
    % Create KPI details table
    kpi_data = struct();
    kpi_data.kpi_name = data.absolute_feature_names';
    kpi_data.kpi_type = repmat({'absolute'}, length(data.absolute_feature_names), 1);
    kpi_data.description = get_kpi_descriptions(data.absolute_feature_names);
    
    % Add relative KPIs
    relative_kpi_data = struct();
    relative_kpi_data.kpi_name = data.relative_feature_names';
    relative_kpi_data.kpi_type = repmat({'relative'}, length(data.relative_feature_names), 1);
    relative_kpi_data.description = get_kpi_descriptions(data.relative_feature_names);
    
    % Combine KPI data
    all_kpi_data = [kpi_data; relative_kpi_data];
    kpi_table = struct2table(all_kpi_data);
    writetable(kpi_table, 'outputs/csv/kpi_analysis_details.csv');
    
    % 8. Dataset Information
    fprintf('  Exporting dataset information...\n');
    dataset_info = struct();
    dataset_info.property = {'total_matches'; 'total_seasons'; 'total_teams'; 'season_range'; 'team_a_mean'; 'team_a_std'; 'team_b_mean'; 'team_b_std'; 'correlation'; 'baseline_sef'; 'analysis_date'};
    dataset_info.value = {data_prepared.n_matches; data_prepared.n_seasons; data_prepared.n_teams; '2021/22-2024/25'; data_prepared.team_a_mean; data_prepared.team_a_std; data_prepared.team_b_mean; data_prepared.team_b_std; data_prepared.correlation; data_prepared.sef_full; datestr(now)};
    dataset_info.description = {'Total number of matches analyzed'; 'Number of seasons'; 'Number of teams'; 'Season range'; 'Team A mean performance'; 'Team A standard deviation'; 'Team B mean performance'; 'Team B standard deviation'; 'Environmental correlation'; 'Baseline SEF value'; 'Analysis completion date'};
    
    dataset_table = struct2table(dataset_info);
    writetable(dataset_table, 'outputs/csv/dataset_information.csv');
    
    fprintf('✓ All CSV files exported successfully to outputs/csv/\n');
    fprintf('\nExported files:\n');
    fprintf('  - sample_size_sensitivity_results.csv\n');
    fprintf('  - temporal_analysis_results.csv\n');
    fprintf('  - parameter_sensitivity_results.csv\n');
    fprintf('  - robustness_analysis_results.csv\n');
    fprintf('  - statistical_validation_results.csv\n');
    fprintf('  - sensitivity_analysis_summary.csv\n');
    fprintf('  - kpi_analysis_details.csv\n');
    fprintf('  - dataset_information.csv\n');
end

function descriptions = get_kpi_descriptions(kpi_names)
    % Get human-readable descriptions for KPIs
    
    descriptions = cell(length(kpi_names), 1);
    
    for i = 1:length(kpi_names)
        switch kpi_names{i}
            case 'carries'
                descriptions{i} = 'Number of ball carries';
            case 'metres_made'
                descriptions{i} = 'Total metres gained with ball';
            case 'defenders_beaten'
                descriptions{i} = 'Number of defenders beaten';
            case 'clean_breaks'
                descriptions{i} = 'Number of clean line breaks';
            case 'offloads'
                descriptions{i} = 'Number of offloads made';
            case 'passes'
                descriptions{i} = 'Total number of passes';
            case 'turnovers_conced…'
                descriptions{i} = 'Number of turnovers conceded';
            case 'turnovers_won'
                descriptions{i} = 'Number of turnovers won';
            case 'kicks_from_hand'
                descriptions{i} = 'Number of kicks from hand';
            case 'kick_metres'
                descriptions{i} = 'Total metres gained from kicks';
            case 'scrums_won'
                descriptions{i} = 'Number of scrums won';
            case 'rucks_won'
                descriptions{i} = 'Number of rucks won';
            case 'lineout_throws_l…'
                descriptions{i} = 'Number of lineout throws lost';
            case 'lineout_throws_w…'
                descriptions{i} = 'Number of lineout throws won';
            case 'tackles'
                descriptions{i} = 'Total number of tackles made';
            case 'missed_tackles'
                descriptions{i} = 'Number of missed tackles';
            case 'penalties_conced…'
                descriptions{i} = 'Number of penalties conceded';
            case 'scrum_pens_conce…'
                descriptions{i} = 'Number of scrum penalties conceded';
            case 'lineout_pens_con…'
                descriptions{i} = 'Number of lineout penalties conceded';
            case 'general_play_pen…'
                descriptions{i} = 'Number of general play penalties conceded';
            case 'free_kicks_conce…'
                descriptions{i} = 'Number of free kicks conceded';
            case 'ruck_maul_tackle…'
                descriptions{i} = 'Number of ruck/maul tackles made';
            case 'red_cards'
                descriptions{i} = 'Number of red cards received';
            case 'yellow_cards'
                descriptions{i} = 'Number of yellow cards received';
            otherwise
                descriptions{i} = 'Performance metric';
        end
    end
end
