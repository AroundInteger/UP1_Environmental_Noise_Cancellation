%% Simple Digital Thread Demo for UP1
% Demonstrates basic numerical traceability without complexity

clear; close all; clc;

fprintf('=== SIMPLE DIGITAL THREAD DEMO ===\n');
fprintf('Basic numerical workflow tracking\n\n');

%% 1. Initialize Simple Digital Thread
fprintf('1. Initializing Simple Digital Thread...\n');

% Add simple digital thread to path
addpath(genpath('src'));

dt = simpleDigitalThread();

%% 2. Track Data Sources
fprintf('\n2. Tracking Data Sources...\n');

% Track raw data
dt.log_data_source('raw_rugby_data', ...
    'data/raw/4_seasons rowan.csv', ...
    'Original rugby performance data from 4 seasons');

% Track processed data
dt.log_data_source('processed_rugby_data', ...
    'data/processed/rugby_analysis_ready.csv', ...
    'Preprocessed rugby data ready for analysis');

%% 3. Log Key Parameters
fprintf('\n3. Logging Key Parameters...\n');

% Normality testing parameters
dt.log_parameter('normality_testing', 'alpha', 0.05, ...
    'Significance level for normality tests');
dt.log_parameter('normality_testing', 'threshold', 0.7, ...
    'Threshold for strong normality classification');

% Axiom validation parameters
dt.log_parameter('axiom_validation', 'test_threshold', 0.6, ...
    'Minimum score for axiom compliance');

%% 4. Simulate Some Analysis
fprintf('\n4. Simulating Analysis Steps...\n');

% Load data (simulated)
dt.log_message('ANALYSIS', 'Loading rugby dataset...');
data_size = [564, 48]; % Simulated data size
dt.log_message('ANALYSIS', sprintf('Dataset loaded: %dx%d', data_size(1), data_size(2)));

% Simulate normality assessment
dt.log_message('ANALYSIS', 'Performing normality assessment...');
kpi_count = 24; % Simulated KPI count
dt.log_message('ANALYSIS', sprintf('Assessed %d KPIs for normality', kpi_count));

% Simulate axiom validation
dt.log_message('ANALYSIS', 'Running four-axiom validation...');
valid_kpis = 18; % Simulated valid KPIs
dt.log_message('ANALYSIS', sprintf('Found %d KPIs meeting axiom requirements', valid_kpis));

%% 5. Log Results
fprintf('\n5. Logging Final Results...\n');

% Log normality assessment results
dt.log_result('normality_summary', struct('kpi_count', kpi_count, 'assessed', kpi_count), ...
    'Complete normality assessment for all KPIs');

% Log axiom validation results
dt.log_result('axiom_validation', struct('total_kpis', kpi_count, 'valid_kpis', valid_kpis), ...
    'Four-axiom validation complete');

% Log overall workflow result
dt.log_result('workflow_summary', struct('status', 'COMPLETE', 'duration_minutes', 5), ...
    'Complete UP1 workflow from data loading through axiom validation');

%% 6. Generate Report and Save
fprintf('\n6. Generating Report and Saving Session...\n');

% Display summary
dt.display_summary();

% Generate detailed report
dt.generate_simple_report();

% Save session
dt.save_session();

%% 7. Show What We've Tracked
fprintf('\n=== WHAT WE TRACKED ===\n');
fprintf('✓ Data sources (input files)\n');
fprintf('✓ Algorithm parameters (thresholds, alpha values)\n');
fprintf('✓ Analysis steps (execution log)\n');
fprintf('✓ Final results (outputs and summaries)\n');
fprintf('✓ Complete session export (for reproducibility)\n');

fprintf('\n=== BENEFITS FOR UP1 ===\n');
fprintf('• Every result can be traced to source data\n');
fprintf('• All parameters are documented\n');
fprintf('• Complete workflow is preserved\n');
fprintf('• Ready for peer review and replication\n');

fprintf('\n=== DEMO COMPLETE ===\n');
fprintf('Simple digital thread working successfully!\n');
fprintf('Session saved for reproducibility\n');
