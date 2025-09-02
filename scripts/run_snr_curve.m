%% Run UP1 SNR Curve Generation
% This script runs the SNR improvement curve visualization
%
% Author: UP1 Research Team
% Date: 2024

clear; clc; close all;

fprintf('Running UP1 SNR curve generation...\n\n');

% Run the SNR curve function
create_snr_curve_fixed();

fprintf('\nSNR curve generation complete! Check the outputs/figures/main_paper/ folder for SNR curves.\n');
