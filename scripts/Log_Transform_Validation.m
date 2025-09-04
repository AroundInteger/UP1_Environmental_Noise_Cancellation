function Log_Transform_Validation()
% LOG_TRANSFORM_VALIDATION
% Test log-transformation on scraped datasets for SEF framework
%
% This script tests:
% 1. Log-transformation effects on normality
% 2. SEF improvements from κ mechanism alone (ρ = 0)
% 3. Correlation structure after transformation
% 4. Framework applicability with transformed data

fprintf('=== LOG-TRANSFORMATION VALIDATION FOR SEF FRAMEWORK ===\n\n');

% Dataset paths
data_path = 'data/raw/scraped data/';
datasets = {
    'financial_market_data.csv', 'Financial Markets';
    'education_assessment_data.csv', 'Education Assessment';
    'social_media_data.csv', 'Social Media'
};

% Skip clinical trials (insufficient sample size)
fprintf('Testing log-transformation on %d datasets...\n\n', length(datasets));

for i = 1:length(datasets)
    dataset_file = datasets{i,1};
    dataset_name = datasets{i,2};
    
    fprintf('--- %s ---\n', dataset_name);
    
    try
        % Load dataset
        data = readtable(fullfile(data_path, dataset_file));
        fprintf('✓ Loaded: %d rows, %d columns\n', height(data), width(data));
        
        % Get numeric columns
        numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        numeric_data = data(:, numeric_cols);
        
        % Get categorical column
        categorical_cols = varfun(@iscategorical, data, 'OutputFormat', 'uniform');
        string_cols = varfun(@(x) isstring(x) || iscellstr(x), data, 'OutputFormat', 'uniform');
        cat_col = find(categorical_cols | string_cols, 1);
        
        if isempty(cat_col)
            fprintf('✗ No categorical column found\n');
            continue;
        end
        
        categories = unique(data{:, cat_col});
        fprintf('  Categories: %s\n', strjoin(string(categories), ', '));
        
        if length(categories) < 2
            fprintf('✗ Insufficient categories\n');
            continue;
        end
        
        % Test each numeric column
        for col = 1:width(numeric_data)
            col_name = numeric_data.Properties.VariableNames{col};
            fprintf('\n  Testing column: %s\n', col_name);
            
            % Get data for each category
            data1 = numeric_data{data{:, cat_col} == categories(1), col};
            data2 = numeric_data{data{:, cat_col} == categories(2), col};
            
            % Remove missing values
            data1 = data1(~isnan(data1));
            data2 = data2(~isnan(data2));
            
            if length(data1) < 10 || length(data2) < 10
                fprintf('    ✗ Insufficient data for analysis\n');
                continue;
            end
            
            fprintf('    Sample sizes: %d vs %d\n', length(data1), length(data2));
            
            % Test original data
            fprintf('    Original data:\n');
            [original_valid, original_stats] = test_data_quality(data1, data2, 'Original');
            
            % Test log-transformed data
            fprintf('    Log-transformed data:\n');
            
            % Ensure positive values for log transformation
            min_val1 = min(data1);
            min_val2 = min(data2);
            min_val = min(min_val1, min_val2);
            
            if min_val <= 0
                % Add offset to make all values positive
                offset = abs(min_val) + 1;
                data1_log = log(data1 + offset);
                data2_log = log(data2 + offset);
                fprintf('      Applied offset: +%.3f (min value: %.3f)\n', offset, min_val);
            else
                data1_log = log(data1);
                data2_log = log(data2);
            end
            
            [log_valid, log_stats] = test_data_quality(data1_log, data2_log, 'Log-transformed');
            
            % Calculate SEF improvements
            if original_valid && log_valid
                fprintf('    SEF Analysis:\n');
                analyze_sef_improvements(original_stats, log_stats, col_name);
            end
            
        end
        
    catch ME
        fprintf('✗ Error: %s\n', ME.message);
    end
    
    fprintf('\n');
end

fprintf('=== LOG-TRANSFORMATION VALIDATION COMPLETE ===\n');

end

function [valid, stats] = test_data_quality(data1, data2, data_type)
% TEST_DATA_QUALITY
% Test data quality for SEF framework

valid = false;
stats = struct();

% Test normality
[sw1_h, sw1_p] = swtest(data1);
[sw2_h, sw2_p] = swtest(data2);

fprintf('      Normality (Shapiro-Wilk):\n');
fprintf('        Group 1: p=%.3f, Normal: %s\n', sw1_p, string(sw1_p > 0.05));
fprintf('        Group 2: p=%.3f, Normal: %s\n', sw2_p, string(sw2_p > 0.05));

% Calculate basic statistics
stats.mean1 = mean(data1);
stats.mean2 = mean(data2);
stats.var1 = var(data1);
stats.var2 = var(data2);
stats.std1 = std(data1);
stats.std2 = std(data2);

% Calculate variance ratio (κ)
stats.kappa = stats.var2 / stats.var1;

% Calculate correlation (if possible)
try
    % For correlation, we need paired data
    % This is a simplified approach - in practice, we'd need matched pairs
    min_len = min(length(data1), length(data2));
    if min_len >= 10
        % Use first min_len values for correlation estimate
        corr_data1 = data1(1:min_len);
        corr_data2 = data2(1:min_len);
        [r, p] = corrcoef(corr_data1, corr_data2);
        if size(r,1) > 1
            stats.correlation = r(1,2);
            stats.corr_p = p(1,2);
        else
            stats.correlation = NaN;
            stats.corr_p = NaN;
        end
    else
        stats.correlation = NaN;
        stats.corr_p = NaN;
    end
catch
    stats.correlation = NaN;
    stats.corr_p = NaN;
end

fprintf('      Statistics:\n');
fprintf('        Mean: %.3f vs %.3f\n', stats.mean1, stats.mean2);
fprintf('        Variance: %.3f vs %.3f\n', stats.var1, stats.var2);
fprintf('        κ (variance ratio): %.3f\n', stats.kappa);
if ~isnan(stats.correlation)
    fprintf('        Correlation: %.3f (p=%.3f)\n', stats.correlation, stats.corr_p);
else
    fprintf('        Correlation: Not calculable\n');
end

% Check if data is suitable for SEF analysis
if sw1_p > 0.05 && sw2_p > 0.05
    fprintf('      ✓ Both groups are normal - suitable for SEF\n');
    valid = true;
else
    fprintf('      ✗ Non-normal data - may need transformation\n');
    valid = false;
end

end

function analyze_sef_improvements(original_stats, log_stats, col_name)
% ANALYZE_SEF_IMPROVEMENTS
% Analyze SEF improvements from log-transformation

fprintf('      Comparing Original vs Log-transformed:\n');

% Calculate SEF for both cases
% SEF = (1 + κ) / (1 + κ - 2*√κ*ρ)
% When ρ = 0: SEF = 1 + κ

% Original data SEF (assuming ρ = 0 for simplicity)
original_sef = 1 + original_stats.kappa;

% Log-transformed data SEF
log_sef = 1 + log_stats.kappa;

% Calculate improvement
improvement = (log_sef - original_sef) / original_sef * 100;

fprintf('        Original SEF (κ=%.3f): %.3f\n', original_stats.kappa, original_sef);
fprintf('        Log-transformed SEF (κ=%.3f): %.3f\n', log_stats.kappa, log_sef);
fprintf('        Improvement: %.1f%%\n', improvement);

% Check if improvement is meaningful
if improvement > 5
    fprintf('        ✓ Meaningful improvement from log-transformation\n');
elseif improvement > 0
    fprintf('        ~ Modest improvement from log-transformation\n');
else
    fprintf('        ✗ No improvement from log-transformation\n');
end

% Analyze κ optimization
fprintf('        κ Analysis:\n');
fprintf('          Original κ: %.3f\n', original_stats.kappa);
fprintf('          Log-transformed κ: %.3f\n', log_stats.kappa);

% Optimal κ is around 1.0 for maximum SEF sensitivity
original_kappa_distance = abs(original_stats.kappa - 1.0);
log_kappa_distance = abs(log_stats.kappa - 1.0);

fprintf('          Distance from optimal (κ=1.0):\n');
fprintf('            Original: %.3f\n', original_kappa_distance);
fprintf('            Log-transformed: %.3f\n', log_kappa_distance);

if log_kappa_distance < original_kappa_distance
    fprintf('          ✓ Log-transformation moves κ closer to optimal\n');
else
    fprintf('          ✗ Log-transformation moves κ away from optimal\n');
end

end
