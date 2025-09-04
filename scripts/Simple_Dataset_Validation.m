function Simple_Dataset_Validation()
% SIMPLE_DATASET_VALIDATION
% Quick validation of scraped datasets for SEF framework

fprintf('=== SIMPLE DATASET VALIDATION ===\n\n');

% Dataset paths
data_path = 'data/raw/scraped data/';
datasets = {
    'clinical_trials_1000_plus_final.csv', 'Clinical Trials';
    'financial_market_data.csv', 'Financial Markets';
    'education_assessment_data.csv', 'Education Assessment';
    'social_media_data.csv', 'Social Media'
};

for i = 1:length(datasets)
    dataset_file = datasets{i,1};
    dataset_name = datasets{i,2};
    
    fprintf('--- %s ---\n', dataset_name);
    
    try
        % Load dataset
        data = readtable(fullfile(data_path, dataset_file));
        fprintf('✓ Loaded: %d rows, %d columns\n', height(data), width(data));
        
        % Check sample size
        if height(data) < 20
            fprintf('✗ Insufficient sample size: %d (minimum: 20)\n', height(data));
            continue;
        end
        
        % Check for numeric columns
        numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        fprintf('  Numeric columns: %d\n', sum(numeric_cols));
        
        % Check for categorical columns
        categorical_cols = varfun(@iscategorical, data, 'OutputFormat', 'uniform');
        string_cols = varfun(@(x) isstring(x) || iscellstr(x), data, 'OutputFormat', 'uniform');
        total_cat_cols = sum(categorical_cols) + sum(string_cols);
        fprintf('  Categorical columns: %d\n', total_cat_cols);
        
        if total_cat_cols == 0
            fprintf('✗ No categorical columns for pairing\n');
            continue;
        end
        
        % Get categories
        cat_col = find(categorical_cols | string_cols, 1);
        if isempty(cat_col)
            fprintf('✗ No valid categorical column found\n');
            continue;
        end
        
        categories = unique(data{:, cat_col});
        fprintf('  Categories: %s\n', strjoin(string(categories), ', '));
        
        if length(categories) < 2
            fprintf('✗ Insufficient categories: %d (minimum: 2)\n', length(categories));
            continue;
        end
        
        % Check for correlations
        fprintf('  Checking correlations...\n');
        correlations_found = 0;
        
        % Get numeric data
        numeric_data = data(:, numeric_cols);
        
        for j = 1:length(categories)
            for k = j+1:length(categories)
                cat1 = categories(j);
                cat2 = categories(k);
                
                data1 = numeric_data(data{:, cat_col} == cat1, :);
                data2 = numeric_data(data{:, cat_col} == cat2, :);
                
                if height(data1) < 10 || height(data2) < 10
                    continue;
                end
                
                % Check each numeric column
                for col = 1:width(numeric_data)
                    col_name = numeric_data.Properties.VariableNames{col};
                    
                    try
                        % Remove missing values
                        valid1 = ~isnan(data1{:, col});
                        valid2 = ~isnan(data2{:, col});
                        
                        if sum(valid1) < 5 || sum(valid2) < 5
                            continue;
                        end
                        
                        % Calculate correlation
                        [r, p] = corrcoef(data1{valid1, col}, data2{valid2, col});
                        if size(r,1) > 1 && ~isnan(r(1,2)) && p(1,2) < 0.05
                            correlations_found = correlations_found + 1;
                            fprintf('    %s-%s (%s): r=%.3f, p=%.3f\n', ...
                                string(cat1), string(cat2), col_name, r(1,2), p(1,2));
                        end
                    catch
                        continue;
                    end
                end
            end
        end
        
        if correlations_found == 0
            fprintf('✗ No significant correlations found\n');
        else
            fprintf('✓ Found %d significant correlations\n', correlations_found);
        end
        
    catch ME
        fprintf('✗ Error: %s\n', ME.message);
    end
    
    fprintf('\n');
end

fprintf('=== VALIDATION COMPLETE ===\n');

end
