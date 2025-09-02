function setup_environment()
%SETUP_ENVIRONMENT Add all necessary paths for UP1 project
%
% This function adds all required source paths to MATLAB's search path
% so that the UP1 functions can be accessed from anywhere.
%
% Usage:
%   setup_environment
%
% Author: UP1 Research Team
% Date: 2024

fprintf('Setting up UP1 project environment...\n');

% Get the project root directory
if exist('OCTAVE_VERSION', 'builtin')
    % Octave
    project_root = fileparts(mfilename('fullpath'));
    project_root = fileparts(project_root);
else
    % MATLAB
    project_root = fileparts(mfilename('fullpath'));
    project_root = fileparts(project_root);
end

fprintf('Project root: %s\n', project_root);

% Add source paths
paths_to_add = {
    fullfile(project_root, 'src');
    fullfile(project_root, 'src', 'empirical');
    fullfile(project_root, 'src', 'theory');
    fullfile(project_root, 'src', 'utils');
    fullfile(project_root, 'src', 'supplementary');
    fullfile(project_root, 'analysis', 'main_paper');
    fullfile(project_root, 'analysis', 'supplementary');
    fullfile(project_root, 'tests');
    fullfile(project_root, 'scripts');
};

% Add each path
for i = 1:length(paths_to_add)
    path_to_add = paths_to_add{i};
    if exist(path_to_add, 'dir')
        addpath(path_to_add);
        fprintf('  ✓ Added: %s\n', path_to_add);
    else
        fprintf('  ⚠ Path not found: %s\n', path_to_add);
    end
end

% Verify key functions are accessible
fprintf('\nVerifying function accessibility...\n');

try
    % Test if key functions are accessible
    if exist('rugbyAnalysis', 'file') == 2
        fprintf('  ✓ rugbyAnalysis function accessible\n');
    else
        fprintf('  ✗ rugbyAnalysis function not accessible\n');
    end
    
    if exist('environmentalEstimation', 'file') == 2
        fprintf('  ✓ environmentalEstimation function accessible\n');
    else
        fprintf('  ✗ environmentalEstimation function not accessible\n');
    end
    
    if exist('kpiComparison', 'file') == 2
        fprintf('  ✓ kpiComparison function accessible\n');
    else
        fprintf('  ✗ kpiComparison function not accessible\n');
    end
    
catch ME
    fprintf('  ✗ Error checking function accessibility: %s\n', ME.message);
end

fprintf('\nEnvironment setup complete!\n');
fprintf('You can now run UP1 functions from any directory.\n');
fprintf('\nExample usage:\n');
fprintf('  % Load data\n');
fprintf('  rugby_data = readtable(''data/raw/4_seasons rowan.csv'');\n');
fprintf('  \n');
fprintf('  % Run analysis\n');
fprintf('  [results, env_stats] = rugbyAnalysis(rugby_data);\n');
fprintf('  \n');
fprintf('  % Run KPI comparison\n');
fprintf('  [kpi_results, kpi_details] = kpiComparison(rugby_data);\n');

end
