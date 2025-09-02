%% Test Simple Digital Thread
% Simple test to verify the class works

clear; close all; clc;

fprintf('Testing Simple Digital Thread...\n');

% Add path
addpath(genpath('src'));

try
    % Test creation
    dt = simpleDigitalThread();
    fprintf('✓ Class created successfully\n');
    
    % Test basic functionality
    dt.log_message('TEST', 'Testing basic functionality');
    fprintf('✓ Basic logging works\n');
    
    % Test data source logging
    dt.log_data_source('test_data', 'test.csv', 'Test data file');
    fprintf('✓ Data source logging works\n');
    
    % Test parameter logging
    dt.log_parameter('test_category', 'test_param', 0.05, 'Test parameter');
    fprintf('✓ Parameter logging works\n');
    
    % Test result logging
    dt.log_result('test_result', struct('value', 42), 'Test result');
    fprintf('✓ Result logging works\n');
    
    % Test summary
    dt.display_summary();
    fprintf('✓ Summary display works\n');
    
    fprintf('\n=== ALL TESTS PASSED ===\n');
    fprintf('Simple Digital Thread is working correctly!\n');
    
catch ME
    fprintf('❌ Error: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end
