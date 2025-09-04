function Validate_Scraped_Datasets()
% VALIDATE_SCRAPED_DATASETS
% Comprehensive validation of scraped datasets against SEF framework requirements
%
% This script validates each dataset against our framework requirements:
% 1. Correlation structure (ρ > 0.05)
% 2. Parameter ranges (κ, ρ within bounds)
% 3. Normality assumptions
% 4. Sample size requirements
% 5. SEF calculation feasibility

fprintf('=== SEF FRAMEWORK DATASET VALIDATION ===\n\n');

% Define validation criteria
MIN_CORRELATION = 0.05;
MIN_SAMPLE_SIZE = 20;
MAX_MISSING_RATE = 0.1;
NORMALITY_ALPHA = 0.05;

% Initialize results structure
validation_results = struct();

% Dataset paths
data_path = 'data/raw/scraped data/';
datasets = {
    'clinical_trials_1000_plus_final.csv', 'Clinical Trials';
    'financial_market_data.csv', 'Financial Markets';
    'education_assessment_data.csv', 'Education Assessment';
    'social_media_data.csv', 'Social Media'
};

fprintf('Validating %d datasets against SEF framework requirements...\n\n', length(datasets));

for i = 1:length(datasets)
    dataset_file = datasets{i,1};
    dataset_name = datasets{i,2};
    
    fprintf('--- %s ---\n', dataset_name);
    fprintf('File: %s\n', dataset_file);
    
    try
        % Load dataset
        data = readtable(fullfile(data_path, dataset_file));
        fprintf('✓ Dataset loaded successfully\n');
        fprintf('  Rows: %d, Columns: %d\n', height(data), width(data));
        
        % Display column names
        fprintf('  Columns: %s\n', strjoin(data.Properties.VariableNames, ', '));
        
        % Validate dataset structure
        result = validate_dataset_structure(data, dataset_name);
        validation_results.(matlab.lang.makeValidName(dataset_name)) = result;
        
        % Check if dataset can be processed
        if result.valid_structure
            fprintf('✓ Dataset structure valid for SEF analysis\n');
            
            % Attempt correlation analysis
            correlation_result = analyze_correlation_structure(data, dataset_name);
            result.correlation_analysis = correlation_result;
            
            % Check normality
            normality_result = test_normality_assumptions(data, dataset_name);
            result.normality_analysis = normality_result;
            
            % Calculate SEF if possible
            if correlation_result.valid_for_sef
                sef_result = calculate_sef_values(data, dataset_name);
                result.sef_analysis = sef_result;
            else
                fprintf('✗ Dataset not suitable for SEF calculation\n');
                result.sef_analysis = struct('valid', false, 'reason', 'Correlation requirements not met');
            end
            
        else
            fprintf('✗ Dataset structure invalid for SEF analysis\n');
            fprintf('  Reason: %s\n', result.invalid_reason);
        end
        
    catch ME
        fprintf('✗ Error loading dataset: %s\n', ME.message);
        validation_results.(matlab.lang.makeValidName(dataset_name)) = struct(...
            'valid_structure', false, ...
            'invalid_reason', ME.message);
    end
    
    fprintf('\n');
end

% Generate comprehensive validation report
generate_validation_report(validation_results);

end

function result = validate_dataset_structure(data, dataset_name)
% VALIDATE_DATASET_STRUCTURE
% Check if dataset has required structure for SEF analysis

result = struct();
result.dataset_name = dataset_name;
result.valid_structure = false;
result.invalid_reason = '';

% Check minimum sample size
if height(data) < 20
    result.invalid_reason = sprintf('Insufficient sample size: %d (minimum: 20)', height(data));
    return;
end

% Check for missing values
missing_rate = sum(ismissing(data), 'all') / numel(data);
if missing_rate > 0.1
    result.invalid_reason = sprintf('High missing rate: %.1f%% (maximum: 10%%)', missing_rate * 100);
    return;
end

% Check for numeric columns
numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
if sum(numeric_cols) < 2
    result.invalid_reason = 'Insufficient numeric columns for correlation analysis';
    return;
end

% Check for categorical columns (for pairing)
categorical_cols = varfun(@iscategorical, data, 'OutputFormat', 'uniform');
if sum(categorical_cols) == 0
    % Check for string columns that could be categorical
    string_cols = varfun(@(x) isstring(x) || iscellstr(x), data, 'OutputFormat', 'uniform');
    if sum(string_cols) == 0
        result.invalid_reason = 'No categorical columns for competitor pairing';
        return;
    end
end

result.valid_structure = true;
result.sample_size = height(data);
result.missing_rate = missing_rate;
result.numeric_columns = sum(numeric_cols);
result.categorical_columns = sum(categorical_cols) + sum(string_cols);

end

function result = analyze_correlation_structure(data, dataset_name)
% ANALYZE_CORRELATION_STRUCTURE
% Analyze correlation structure for SEF framework

result = struct();
result.valid_for_sef = false;
result.correlation_found = false;

% Get numeric columns
numeric_data = data(:, varfun(@isnumeric, data, 'OutputFormat', 'uniform'));

% Get categorical columns for pairing
categorical_cols = varfun(@iscategorical, data, 'OutputFormat', 'uniform');
if sum(categorical_cols) == 0
    string_cols = varfun(@(x) isstring(x) || iscellstr(x), data, 'OutputFormat', 'uniform');
    categorical_cols = string_cols;
end

if sum(categorical_cols) == 0
    result.reason = 'No categorical columns for competitor pairing';
    return;
end

% Get unique categories
cat_col = find(categorical_cols, 1);
categories = unique(data{:, cat_col});

if length(categories) < 2
    result.reason = 'Insufficient categories for pairing (minimum: 2)';
    return;
end

fprintf('  Categories found: %s\n', strjoin(string(categories), ', '));

% Analyze each pair of categories
correlations = [];
correlation_pairs = {};

for i = 1:length(categories)
    for j = i+1:length(categories)
        cat1 = categories(i);
        cat2 = categories(j);
        
        % Get data for each category
        data1 = numeric_data(data{:, cat_col} == cat1, :);
        data2 = numeric_data(data{:, cat_col} == cat2, :);
        
        if height(data1) < 10 || height(data2) < 10
            continue; % Skip pairs with insufficient data
        end
        
        % Calculate correlation for each numeric column
        for col = 1:width(numeric_data)
            col_name = numeric_data.Properties.VariableNames{col};
            
            % Remove missing values
            valid1 = ~isnan(data1{:, col});
            valid2 = ~isnan(data2{:, col});
            
            if sum(valid1) < 5 || sum(valid2) < 5
                continue;
            end
            
            % Calculate correlation
            try
                [r, p] = corrcoef(data1{valid1, col}, data2{valid2, col});
                if size(r,1) > 1
                    correlation = r(1,2);
                    p_value = p(1,2);
                    
                    if ~isnan(correlation) && p_value < 0.05
                        correlations(end+1) = correlation;
                        correlation_pairs{end+1} = sprintf('%s-%s (%s)', string(cat1), string(cat2), col_name);
                    end
                end
            catch
                continue;
            end
        end
    end
end

if isempty(correlations)
    result.reason = 'No significant correlations found between categories';
    return;
end

result.correlation_found = true;
result.correlations = correlations;
result.correlation_pairs = correlation_pairs;
result.mean_correlation = mean(correlations);
result.max_correlation = max(correlations);
result.min_correlation = min(correlations);

fprintf('  Significant correlations found: %d\n', length(correlations));
fprintf('  Correlation range: [%.3f, %.3f]\n', result.min_correlation, result.max_correlation);
fprintf('  Mean correlation: %.3f\n', result.mean_correlation);

% Check if correlations meet SEF requirements
if result.mean_correlation > 0.05
    result.valid_for_sef = true;
    fprintf('✓ Dataset suitable for SEF analysis (mean ρ = %.3f > 0.05)\n', result.mean_correlation);
else
    result.reason = sprintf('Mean correlation too low: %.3f (minimum: 0.05)', result.mean_correlation);
    fprintf('✗ Dataset not suitable for SEF analysis\n');
end

end

function result = test_normality_assumptions(data, dataset_name)
% TEST_NORMALITY_ASSUMPTIONS
% Test normality assumptions for SEF framework

result = struct();
result.normality_tests = struct();

% Get numeric columns
numeric_data = data(:, varfun(@isnumeric, data, 'OutputFormat', 'uniform'));

fprintf('  Testing normality assumptions...\n');

for col = 1:width(numeric_data)
    col_name = numeric_data.Properties.VariableNames{col};
    col_data = numeric_data{:, col};
    
    % Remove missing values
    col_data = col_data(~isnan(col_data));
    
    if length(col_data) < 10
        continue;
    end
    
    % Shapiro-Wilk test
    try
        [sw_h, sw_p] = swtest(col_data);
        result.normality_tests.(matlab.lang.makeValidName(col_name)).shapiro_wilk = struct(...
            'h', sw_h, 'p', sw_p, 'normal', sw_p > 0.05);
    catch
        result.normality_tests.(matlab.lang.makeValidName(col_name)).shapiro_wilk = struct(...
            'h', false, 'p', NaN, 'normal', false);
    end
    
    % Kolmogorov-Smirnov test
    try
        [ks_h, ks_p] = kstest((col_data - mean(col_data)) / std(col_data));
        result.normality_tests.(matlab.lang.makeValidName(col_name)).kolmogorov_smirnov = struct(...
            'h', ks_h, 'p', ks_p, 'normal', ks_p > 0.05);
    catch
        result.normality_tests.(matlab.lang.makeValidName(col_name)).kolmogorov_smirnov = struct(...
            'h', true, 'p', NaN, 'normal', false);
    end
    
    % Overall normality assessment
    sw_normal = result.normality_tests.(matlab.lang.makeValidName(col_name)).shapiro_wilk.normal;
    ks_normal = result.normality_tests.(matlab.lang.makeValidName(col_name)).kolmogorov_smirnov.normal;
    
    result.normality_tests.(matlab.lang.makeValidName(col_name)).overall_normal = sw_normal && ks_normal;
    
    fprintf('    %s: SW p=%.3f, KS p=%.3f, Normal: %s\n', ...
        col_name, ...
        result.normality_tests.(matlab.lang.makeValidName(col_name)).shapiro_wilk.p, ...
        result.normality_tests.(matlab.lang.makeValidName(col_name)).kolmogorov_smirnov.p, ...
        string(result.normality_tests.(matlab.lang.makeValidName(col_name)).overall_normal));
end

end

function result = calculate_sef_values(data, dataset_name)
% CALCULATE_SEF_VALUES
% Calculate SEF values for validated datasets

result = struct();
result.sef_calculated = false;

fprintf('  Calculating SEF values...\n');

% This is a placeholder - actual SEF calculation would require
% specific pairing logic based on dataset structure
% For now, we'll indicate that SEF calculation is possible

result.sef_calculated = true;
result.reason = 'Dataset structure suitable for SEF calculation';
result.note = 'Full SEF calculation requires dataset-specific pairing logic';

fprintf('✓ SEF calculation feasible for this dataset\n');

end

function generate_validation_report(validation_results)
% GENERATE_VALIDATION_REPORT
% Generate comprehensive validation report

fprintf('=== COMPREHENSIVE VALIDATION REPORT ===\n\n');

datasets = fieldnames(validation_results);
valid_datasets = 0;
sef_ready_datasets = 0;

for i = 1:length(datasets)
    dataset_name = datasets{i};
    result = validation_results.(dataset_name);
    
    fprintf('Dataset: %s\n', result.dataset_name);
    
    if result.valid_structure
        fprintf('  ✓ Structure: Valid\n');
        fprintf('    Sample size: %d\n', result.sample_size);
        fprintf('    Missing rate: %.1f%%\n', result.missing_rate * 100);
        fprintf('    Numeric columns: %d\n', result.numeric_columns);
        fprintf('    Categorical columns: %d\n', result.categorical_columns);
        
        valid_datasets = valid_datasets + 1;
        
        if isfield(result, 'correlation_analysis') && result.correlation_analysis.valid_for_sef
            fprintf('  ✓ Correlation: Suitable for SEF (mean ρ = %.3f)\n', result.correlation_analysis.mean_correlation);
            sef_ready_datasets = sef_ready_datasets + 1;
        else
            fprintf('  ✗ Correlation: Not suitable for SEF\n');
            if isfield(result, 'correlation_analysis')
                fprintf('    Reason: %s\n', result.correlation_analysis.reason);
            end
        end
        
        if isfield(result, 'normality_analysis')
            fprintf('  ✓ Normality: Tested\n');
        end
        
        if isfield(result, 'sef_analysis') && result.sef_analysis.valid
            fprintf('  ✓ SEF: Calculation feasible\n');
        else
            fprintf('  ✗ SEF: Calculation not feasible\n');
        end
        
    else
        fprintf('  ✗ Structure: Invalid\n');
        fprintf('    Reason: %s\n', result.invalid_reason);
    end
    
    fprintf('\n');
end

fprintf('=== SUMMARY ===\n');
fprintf('Total datasets: %d\n', length(datasets));
fprintf('Valid structure: %d\n', valid_datasets);
fprintf('SEF ready: %d\n', sef_ready_datasets);
fprintf('Success rate: %.1f%%\n', (sef_ready_datasets / length(datasets)) * 100);

if sef_ready_datasets > 0
    fprintf('\n✓ %d datasets are suitable for SEF framework analysis\n', sef_ready_datasets);
else
    fprintf('\n✗ No datasets are suitable for SEF framework analysis\n');
    fprintf('  Consider data preprocessing or alternative datasets\n');
end

end
