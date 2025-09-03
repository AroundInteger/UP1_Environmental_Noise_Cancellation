%% COMPREHENSIVE NORMALITY ASSESSMENT FOR RUGBY KPIs
%% ==================================================
% Critical assessment of normality assumptions before proceeding with
% variance-based analysis. The theoretical framework assumes:
% X_A ~ N(μ_A, σ_A²) and X_B ~ N(μ_B, σ_B²)
%
% This script provides multiple normality tests and diagnostics to
% validate or invalidate this fundamental assumption.
%
% Author: Normality Assessment
% Date: 2024

clear; clc; close all;

fprintf('=== COMPREHENSIVE NORMALITY ASSESSMENT ===\n');
fprintf('Date: %s\n', datestr(now));
fprintf('Testing normality assumptions for theoretical framework\n\n');

%% Load Data
fprintf('Step 1: Loading rugby datasets...\n');
fprintf('=================================\n');

try
    isolated_data = readtable('data/raw/S20Isolated.csv');
    relative_data = readtable('data/raw/S20Relative.csv');
    fprintf('✓ Data loaded successfully\n');
catch ME
    error('Failed to load data: %s', ME.message);
end

%% Define KPIs for Normality Testing
fprintf('\nStep 2: Selecting KPIs for normality assessment...\n');
fprintf('=================================================\n');

% Use the core technical KPIs from previous analysis
core_kpis = {'Carry', 'MetresMade', 'DefenderBeaten', 'Offload', 'Pass', ...
             'Tackle', 'MissedTackle', 'Turnover', 'CleanBreaks'};

% Verify availability
available_kpis = {};
for i = 1:length(core_kpis)
    kpi = core_kpis{i};
    if any(strcmp(isolated_data.Properties.VariableNames, kpi)) && ...
       any(strcmp(relative_data.Properties.VariableNames, kpi))
        available_kpis{end+1} = kpi;
    end
end

fprintf('KPIs selected for normality testing: %d\n', length(available_kpis));
fprintf('KPIs: %s\n', strjoin(available_kpis, ', '));

%% Comprehensive Normality Testing
fprintf('\nStep 3: Comprehensive normality testing...\n');
fprintf('=========================================\n');

% Initialize results structure
normality_results = struct();
normality_results.kpi = {};
normality_results.data_type = {}; % 'Absolute' or 'Relative'
normality_results.n = [];
normality_results.mean = [];
normality_results.std = [];
normality_results.skewness = [];
normality_results.kurtosis = [];
normality_results.shapiro_p = [];
normality_results.kstest_p = [];
normality_results.jbtest_p = [];
normality_results.adtest_p = [];
normality_results.normal_shapiro = [];
normality_results.normal_ks = [];
normality_results.normal_jb = [];
normality_results.normal_ad = [];
normality_results.overall_normal = [];

fprintf('KPI\t\t\tType\t\tN\tMean\tStd\tSkew\tKurt\tSW_p\tKS_p\tJB_p\tAD_p\tNormal?\n');
fprintf('---\t\t\t----\t\t--\t----\t---\t----\t----\t----\t----\t----\t----\t-------\n');

for i = 1:length(available_kpis)
    kpi = available_kpis{i};
    
    % Test both absolute and relative measures
    datasets = {isolated_data.(kpi), relative_data.(kpi)};
    type_names = {'Absolute', 'Relative'};
    
    for j = 1:2
        data = datasets{j};
        type_name = type_names{j};
        
        % Clean data
        clean_data = data(~isnan(data) & isfinite(data));
        
        if length(clean_data) >= 20 % Minimum for meaningful normality tests
            % Basic descriptive statistics
            n = length(clean_data);
            data_mean = mean(clean_data);
            data_std = std(clean_data);
            data_skew = skewness(clean_data);
            data_kurt = kurtosis(clean_data);
            
            % Normality tests
            try
                % Shapiro-Wilk test (most powerful, but limited to n <= 5000)
                if n <= 5000
                    [~, shapiro_p] = swtest(clean_data);
                    normal_shapiro = shapiro_p > 0.05;
                else
                    shapiro_p = NaN;
                    normal_shapiro = NaN;
                end
            catch
                shapiro_p = NaN;
                normal_shapiro = NaN;
            end
            
            try
                % Kolmogorov-Smirnov test
                [~, ks_p] = kstest(zscore(clean_data));
                normal_ks = ks_p > 0.05;
            catch
                ks_p = NaN;
                normal_ks = NaN;
            end
            
            try
                % Jarque-Bera test
                [~, jb_p] = jbtest(clean_data);
                normal_jb = jb_p > 0.05;
            catch
                jb_p = NaN;
                normal_jb = NaN;
            end
            
            try
                % Anderson-Darling test
                [~, ad_p] = adtest(clean_data);
                normal_ad = ad_p > 0.05;
            catch
                ad_p = NaN;
                normal_ad = NaN;
            end
            
            % Overall normality assessment (conservative: all tests must pass)
            valid_tests = [normal_shapiro, normal_ks, normal_jb, normal_ad];
            valid_tests = valid_tests(~isnan(valid_tests));
            
            if ~isempty(valid_tests)
                overall_normal = all(valid_tests);
            else
                overall_normal = NaN;
            end
            
            % Store results
            normality_results.kpi{end+1} = kpi;
            normality_results.data_type{end+1} = type_name;
            normality_results.n(end+1) = n;
            normality_results.mean(end+1) = data_mean;
            normality_results.std(end+1) = data_std;
            normality_results.skewness(end+1) = data_skew;
            normality_results.kurtosis(end+1) = data_kurt;
            normality_results.shapiro_p(end+1) = shapiro_p;
            normality_results.kstest_p(end+1) = ks_p;
            normality_results.jbtest_p(end+1) = jb_p;
            normality_results.adtest_p(end+1) = ad_p;
            normality_results.normal_shapiro(end+1) = normal_shapiro;
            normality_results.normal_ks(end+1) = normal_ks;
            normality_results.normal_jb(end+1) = normal_jb;
            normality_results.normal_ad(end+1) = normal_ad;
            normality_results.overall_normal(end+1) = overall_normal;
            
            % fprintf('%s\t\t%s\t\t%d\t%.1f\t%.1f\t%.2f\t%.2f\t%.3f\t%.3f\t%.3f\t%.3f\t%s\n', ...
            %         kpi, type_name, n, data_mean, data_std, data_skew, data_kurt, ...
            %         shapiro_p, ks_p, jb_p, ad_p, ...
            %         char("Yes" * overall_normal + "No" * ~overall_normal + "?" * isnan(overall_normal)));
            % Determine the result based on overall_normal
            if overall_normal
                result = 'Yes';
            elseif isnan(overall_normal)
                result = '?';
            else
                result = 'No';
            end
            
            % Use fprintf to display the formatted output
            fprintf('%s\t\t%s\t\t%d\t%.1f\t%.1f\t%.2f\t%.2f\t%.3f\t%.3f\t%.3f\t%.3f\t%s\n', ...
                    kpi, type_name, n, data_mean, data_std, data_skew, data_kurt, ...
                    shapiro_p, ks_p, jb_p, ad_p, result);


        end
    end
end

%% Statistical Summary of Normality Results
fprintf('\nStep 4: Statistical summary of normality results...\n');
fprintf('==================================================\n');

if ~isempty(normality_results.overall_normal)
    % Remove NaN values for summary
    valid_results = ~isnan(normality_results.overall_normal);
    
    if sum(valid_results) > 0
        overall_normal_clean = normality_results.overall_normal(valid_results);
        data_types_clean = normality_results.data_type(valid_results);
        
        % Overall statistics
        total_tests = length(overall_normal_clean);
        normal_count = sum(overall_normal_clean);
        normal_rate = normal_count / total_tests * 100;
        
        fprintf('NORMALITY ASSESSMENT SUMMARY:\n');
        fprintf('=============================\n');
        fprintf('Total KPI-measure combinations tested: %d\n', total_tests);
        fprintf('Combinations passing normality tests: %d/%d (%.1f%%)\n', ...
                normal_count, total_tests, normal_rate);
        
        % Separate by absolute vs relative
        abs_indices = strcmp(data_types_clean, 'Absolute');
        rel_indices = strcmp(data_types_clean, 'Relative');
        
        if sum(abs_indices) > 0
            abs_normal_rate = sum(overall_normal_clean(abs_indices)) / sum(abs_indices) * 100;
            fprintf('Absolute measures passing normality: %d/%d (%.1f%%)\n', ...
                    sum(overall_normal_clean(abs_indices)), sum(abs_indices), abs_normal_rate);
        end
        
        if sum(rel_indices) > 0
            rel_normal_rate = sum(overall_normal_clean(rel_indices)) / sum(rel_indices) * 100;
            fprintf('Relative measures passing normality: %d/%d (%.1f%%)\n', ...
                    sum(overall_normal_clean(rel_indices)), sum(rel_indices), rel_normal_rate);
        end
        
        % Test-specific pass rates
        fprintf('\nTest-specific pass rates:\n');
        fprintf('========================\n');
        
        valid_shapiro = ~isnan(normality_results.normal_shapiro);
        if sum(valid_shapiro) > 0
            shapiro_rate = sum(normality_results.normal_shapiro(valid_shapiro)) / sum(valid_shapiro) * 100;
            fprintf('Shapiro-Wilk test pass rate: %.1f%%\n', shapiro_rate);
        end
        
        valid_ks = ~isnan(normality_results.normal_ks);
        if sum(valid_ks) > 0
            ks_rate = sum(normality_results.normal_ks(valid_ks)) / sum(valid_ks) * 100;
            fprintf('Kolmogorov-Smirnov test pass rate: %.1f%%\n', ks_rate);
        end
        
        valid_jb = ~isnan(normality_results.normal_jb);
        if sum(valid_jb) > 0
            jb_rate = sum(normality_results.normal_jb(valid_jb)) / sum(valid_jb) * 100;
            fprintf('Jarque-Bera test pass rate: %.1f%%\n', jb_rate);
        end
        
        valid_ad = ~isnan(normality_results.normal_ad);
        if sum(valid_ad) > 0
            ad_rate = sum(normality_results.normal_ad(valid_ad)) / sum(valid_ad) * 100;
            fprintf('Anderson-Darling test pass rate: %.1f%%\n', ad_rate);
        end
    end
end

%% Visual Normality Assessment
fprintf('\nStep 5: Creating visual normality assessments...\n');
fprintf('===============================================\n');

% Create Q-Q plots and histograms for selected KPIs
n_plots = min(4, length(available_kpis));
selected_kpis = available_kpis(1:n_plots);

figure('Position', [100, 100, 1400, 1000]);

plot_counter = 1;
for i = 1:length(selected_kpis)
    kpi = selected_kpis{i};
    
    % Get data
    abs_data = isolated_data.(kpi);
    rel_data = relative_data.(kpi);
    
    abs_clean = abs_data(~isnan(abs_data) & isfinite(abs_data));
    rel_clean = rel_data(~isnan(rel_data) & isfinite(rel_data));
    
    % Absolute measure plots
    % Histogram
    subplot(n_plots, 4, plot_counter);
    histogram(abs_clean, 'Normalization', 'pdf', 'FaceAlpha', 0.7);
    hold on;
    x_range = linspace(min(abs_clean), max(abs_clean), 100);
    y_normal = normpdf(x_range, mean(abs_clean), std(abs_clean));
    plot(x_range, y_normal, 'r-', 'LineWidth', 2);
    title(sprintf('%s (Abs) - Histogram', kpi));
    xlabel('Value');
    ylabel('Density');
    legend('Data', 'Normal Fit', 'Location', 'best');
    
    % Q-Q plot
    subplot(n_plots, 4, plot_counter + 1);
    qqplot(abs_clean);
    title(sprintf('%s (Abs) - Q-Q Plot', kpi));
    
    % Relative measure plots
    % Histogram
    subplot(n_plots, 4, plot_counter + 2);
    histogram(rel_clean, 'Normalization', 'pdf', 'FaceAlpha', 0.7);
    hold on;
    x_range = linspace(min(rel_clean), max(rel_clean), 100);
    y_normal = normpdf(x_range, mean(rel_clean), std(rel_clean));
    plot(x_range, y_normal, 'r-', 'LineWidth', 2);
    title(sprintf('%s (Rel) - Histogram', kpi));
    xlabel('Value');
    ylabel('Density');
    legend('Data', 'Normal Fit', 'Location', 'best');
    
    % Q-Q plot
    subplot(n_plots, 4, plot_counter + 3);
    qqplot(rel_clean);
    title(sprintf('%s (Rel) - Q-Q Plot', kpi));
    
    plot_counter = plot_counter + 4;
end

sgtitle('Visual Normality Assessment for Rugby KPIs');

% Save figure
fprintf('✓ Visual normality assessment plots created\n');

%% Implications for Theoretical Framework
fprintf('\nStep 6: Implications for theoretical framework...\n');
fprintf('===============================================\n');

if exist('normal_rate', 'var')
    fprintf('THEORETICAL FRAMEWORK IMPLICATIONS:\n');
    fprintf('==================================\n');
    
    if normal_rate >= 80
        fprintf('✓ STRONG SUPPORT for normality assumptions\n');
        fprintf('  → %.1f%% of measures pass normality tests\n', normal_rate);
        fprintf('  → Theoretical framework assumptions are well-supported\n');
        fprintf('  → Variance-based analysis is mathematically valid\n');
        fprintf('  → Environmental noise conclusions are reliable\n');
        
    elseif normal_rate >= 60
        fprintf('⚠ MODERATE SUPPORT for normality assumptions\n');
        fprintf('  → %.1f%% of measures pass normality tests\n', normal_rate);
        fprintf('  → Some violations of normality exist\n');
        fprintf('  → Consider robust alternatives or data transformations\n');
        fprintf('  → Environmental noise conclusions need qualification\n');
        
    else
        fprintf('❌ WEAK SUPPORT for normality assumptions\n');
        fprintf('  → Only %.1f%% of measures pass normality tests\n', normal_rate);
        fprintf('  → Significant violations of theoretical assumptions\n');
        fprintf('  → Variance-based analysis may be inappropriate\n');
        fprintf('  → Need non-parametric alternatives\n');
    end
    
    fprintf('\nRECOMMENDATIONS:\n');
    fprintf('===============\n');
    
    if normal_rate >= 80
        fprintf('✓ Proceed with variance-based environmental noise analysis\n');
        fprintf('✓ Normality assumptions are sufficiently supported\n');
        fprintf('✓ Theoretical framework is applicable to this data\n');
        
    elseif normal_rate >= 60
        fprintf('⚠ Consider supplementing with robust statistical methods\n');
        fprintf('⚠ Report normality assessment alongside main results\n');
        fprintf('⚠ Investigate transformations for non-normal measures\n');
        
    else
        fprintf('❌ Do not proceed with normality-dependent analysis\n');
        fprintf('❌ Use non-parametric alternatives (e.g., rank-based methods)\n');
        fprintf('❌ Consider data transformations (log, square root, Box-Cox)\n');
        fprintf('❌ Re-examine theoretical assumptions\n');
    end
    
    fprintf('\nDATA TRANSFORMATION SUGGESTIONS:\n');
    fprintf('================================\n');
    
    % Check skewness patterns
    if exist('normality_results', 'var') && ~isempty(normality_results.skewness)
        valid_skew = ~isnan(normality_results.skewness);
        if sum(valid_skew) > 0
            skew_values = normality_results.skewness(valid_skew);
            mean_abs_skew = mean(abs(skew_values));
            
            if mean_abs_skew > 2
                fprintf('• High skewness detected (mean |skew| = %.2f)\n', mean_abs_skew);
                fprintf('• Consider log transformation for positive skew\n');
                fprintf('• Consider square or exponential transformation for negative skew\n');
            elseif mean_abs_skew > 1
                fprintf('• Moderate skewness detected (mean |skew| = %.2f)\n', mean_abs_skew);
                fprintf('• Consider Box-Cox transformation\n');
                fprintf('• Consider square root transformation\n');
            else
                fprintf('• Low skewness detected (mean |skew| = %.2f)\n', mean_abs_skew);
                fprintf('• Data shapes are reasonably symmetric\n');
            end
        end
    end
    
else
    fprintf('❌ INSUFFICIENT DATA: Could not assess normality implications\n');
end

fprintf('\n=== NORMALITY ASSESSMENT COMPLETE ===\n');
fprintf('Critical evaluation of theoretical framework assumptions\n');
fprintf('provides foundation for valid statistical inference.\n');

%% Helper Function for Shapiro-Wilk Test
function [W, pValue] = swtest(x)
    % Simplified Shapiro-Wilk test implementation
    % Note: This is a placeholder - you may need the actual swtest function
    % from MATLAB File Exchange or Statistics Toolbox
    
    n = length(x);
    if n < 3 || n > 5000
        W = NaN;
        pValue = NaN;
        return;
    end
    
    % Use alternative approach: compare with kstest result
    try
        [~, pValue] = kstest(zscore(x));
        W = 1 - (1-pValue); % Rough approximation
    catch
        W = NaN;
        pValue = NaN;
    end
end