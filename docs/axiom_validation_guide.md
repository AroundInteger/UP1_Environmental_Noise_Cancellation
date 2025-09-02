# UP1 Axiom Validation Guide
## Environmental Noise Cancellation Framework

---

## **🎯 Overview**

This guide explains how to use the **Axiom Validation System** to identify KPIs that adhere to the 4 fundamental axioms of environmental noise cancellation. This system is essential for UP1 research, ensuring that selected performance metrics will effectively eliminate shared environmental factors.

---

## **📚 The 4 Axioms**

### **Axiom 1: Invariance to Shared Effects**
- **Definition**: KPI is unaffected by factors influencing all competitors equally
- **Test Methods**:
  - Environmental noise correlation test
  - Variance stability across environmental conditions
  - Environmental effect size analysis
- **Score Range**: 0.0 (highly sensitive) to 1.0 (completely invariant)

### **Axiom 2: Ordinal Consistency**
- **Definition**: KPI correctly reflects true competitive ordering
- **Test Methods**:
  - AUC-ROC performance analysis
  - Spearman rank correlation
  - Ordinal prediction accuracy
- **Score Range**: 0.0 (random ordering) to 1.0 (perfect ordering)

### **Axiom 3: Scaling Proportionality**
- **Definition**: KPI scales consistently across different measurement units
- **Test Methods**:
  - Scale transformation tests (2x, 0.5x)
  - Coefficient of variation consistency
  - Range stability analysis
- **Score Range**: 0.0 (scale-dependent) to 1.0 (scale-invariant)

### **Axiom 4: Statistical Optimality**
- **Definition**: KPI achieves optimal statistical properties
- **Test Methods**:
  - Mutual information content
  - Effect size analysis (Cohen's d)
  - Signal-to-noise ratio efficiency
- **Score Range**: 0.0 (poor statistical properties) to 1.0 (optimal properties)

---

## **🚀 Quick Start**

### **1. Basic Usage**
```matlab
% Load your data
data = load('your_data.mat');

% Run axiom validation
[axiom_results, kpi_ranking, validation_summary] = axiomValidation(data);
```

### **2. Advanced Usage with Parameters**
```matlab
% Customize validation parameters
[axiom_results, kpi_ranking, validation_summary] = axiomValidation(data, ...
    'confidence_level', 0.99, ...        % Higher confidence
    'test_threshold', 0.8, ...          % Stricter compliance threshold
    'environmental_factor', 'season', ... % Specify environmental factor
    'verbose', false);                   % Quiet mode
```

---

## **📊 Data Requirements**

### **Required Fields**
- **`outcome`**: Binary outcome variable (0 or 1)
- **`[metric_name]**: Performance values for each KPI/metric

### **Optional Fields**
- **`season`**: Season identifier (environmental factor)
- **`team`**: Team identifier (environmental factor)
- **`match_location`**: Location identifier (environmental factor)

### **Data Format Example**
```matlab
% Example data structure
data = struct();
data.outcome = [1; 0; 1; 0; 1];           % Binary outcomes
data.points_scored = [25; 18; 30; 15; 28]; % KPI 1
data.tries_scored = [3; 2; 4; 1; 4];      % KPI 2
data.conversions = [2; 1; 3; 1; 3];       % KPI 3
data.season = [1; 1; 2; 2; 2];            % Environmental factor
```

---

## **🔧 Function Reference**

### **Main Function: `axiomValidation`**

#### **Inputs**
- **`data`** (required): Struct containing KPI data and outcomes
- **`confidence_level`** (optional): Confidence level for tests (default: 0.95)
- **`test_threshold`** (optional): Threshold for axiom compliance (default: 0.8)
- **`environmental_factor`** (optional): Environmental noise factor (default: auto-detect)
- **`verbose`** (optional): Display detailed results (default: true)

#### **Outputs**
- **`axiom_results`**: Detailed axiom test results for each KPI
- **`kpi_ranking`**: Ranked list of KPIs by overall axiom compliance
- **`validation_summary`**: Summary statistics and recommendations

---

## **📈 Understanding Results**

### **Overall Compliance Score**
- **0.8 - 1.0**: Excellent compliance (use for environmental noise cancellation)
- **0.7 - 0.8**: Good compliance (minor improvements needed)
- **0.6 - 0.7**: Fair compliance (moderate improvements needed)
- **0.0 - 0.6**: Poor compliance (significant improvements needed)

### **Individual Axiom Scores**
Each axiom is scored independently, allowing you to identify specific areas for improvement.

### **KPI Ranking**
KPIs are automatically ranked by overall compliance, helping you select the best metrics for your analysis.

---

## **🎯 Practical Applications**

### **1. KPI Selection for Environmental Noise Cancellation**
```matlab
% Find KPIs that excel at environmental noise cancellation
excellent_kpis = {};
for i = 1:length(kpi_ranking.ranked_metrics)
    kpi = kpi_ranking.ranked_metrics{i};
    if axiom_results.(kpi).overall.score >= 0.8
        excellent_kpis{end+1} = kpi;
    end
end

fprintf('Excellent KPIs for environmental noise cancellation:\n');
fprintf('  %s\n', strjoin(excellent_kpis, '\n  '));
```

### **2. Identify Improvement Areas**
```matlab
% Find KPIs that need improvement in specific axioms
for i = 1:length(kpi_ranking.ranked_metrics)
    kpi = kpi_ranking.ranked_metrics{i};
    
    % Check Axiom 1 (Invariance to Shared Effects)
    if axiom_results.(kpi).axiom1.score < 0.7
        fprintf('%s needs improvement in environmental invariance (score: %.3f)\n', ...
                kpi, axiom_results.(kpi).axiom1.score);
    end
end
```

### **3. Compare Absolute vs. Relative KPIs**
```matlab
% Analyze performance differences between absolute and relative KPIs
absolute_scores = [];
relative_scores = [];

for i = 1:length(kpi_ranking.ranked_metrics)
    kpi = kpi_ranking.ranked_metrics{i};
    score = axiom_results.(kpi).overall.score;
    
    if contains(kpi, 'relative') || contains(kpi, 'diff')
        relative_scores = [relative_scores, score];
    else
        absolute_scores = [absolute_scores, score];
    end
end

fprintf('Absolute KPIs: %.3f ± %.3f\n', mean(absolute_scores), std(absolute_scores));
fprintf('Relative KPIs: %.3f ± %.3f\n', mean(relative_scores), std(relative_scores));
```

---

## **🔍 Detailed Analysis Examples**

### **Example 1: Comprehensive KPI Assessment**
```matlab
% Load and validate data
[axiom_results, kpi_ranking, validation_summary] = axiomValidation(data);

% Display comprehensive results
fprintf('=== COMPREHENSIVE KPI ASSESSMENT ===\n\n');

% Overall performance
fprintf('Overall Compliance: %.1f%% (%d/%d KPIs)\n', ...
        validation_summary.overall_compliance.compliant_percentage, ...
        validation_summary.overall_compliance.compliant_count, ...
        validation_summary.total_kpis);

% Top performers
fprintf('\nTop 3 KPIs:\n');
for i = 1:3
    kpi = kpi_ranking.ranked_metrics{i};
    score = kpi_ranking.overall_scores(i);
    fprintf('  %d. %s: %.3f\n', i, kpi, score);
end

% Axiom-specific analysis
fprintf('\nAxiom Performance:\n');
axiom_names = {'Invariance', 'Ordinal', 'Scaling', 'Statistical'};
for a = 1:4
    field = sprintf('axiom%d', a);
    stats = validation_summary.axiom_statistics.(field);
    fprintf('  %s: %.1f%% compliant (%.3f ± %.3f)\n', ...
            axiom_names{a}, stats.compliant_percentage, stats.mean, stats.std);
end
```

### **Example 2: Environmental Factor Analysis**
```matlab
% Analyze how environmental factors affect KPI performance
environmental_factors = {'season', 'team', 'location'};

for factor = environmental_factors
    if isfield(data, factor{1})
        fprintf('\nAnalyzing environmental factor: %s\n', factor{1});
        
        % Run validation with specific environmental factor
        [results, ~, summary] = axiomValidation(data, ...
            'environmental_factor', factor{1}, ...
            'verbose', false);
        
        % Analyze invariance to this factor
        invariance_scores = [];
        for kpi = fieldnames(results)'
            invariance_scores = [invariance_scores, results.(kpi{1}).axiom1.score];
        end
        
        fprintf('  Average invariance score: %.3f ± %.3f\n', ...
                mean(invariance_scores), std(invariance_scores));
        fprintf('  KPIs most invariant to %s:\n', factor{1});
        
        % Find top 3 most invariant KPIs
        [~, idx] = sort(invariance_scores, 'descend');
        for i = 1:3
            kpi = fieldnames(results){idx(i)};
            score = invariance_scores(idx(i));
            fprintf('    %s: %.3f\n', kpi, score);
        end
    end
end
```

---

## **📋 Best Practices**

### **1. Data Preparation**
- Ensure clean, complete data with no missing values
- Normalize KPIs to similar scales when possible
- Include relevant environmental factors
- Use consistent measurement units

### **2. Threshold Selection**
- **Research applications**: Use 0.8 threshold for strict compliance
- **Development/testing**: Use 0.7 threshold for initial assessment
- **Exploratory analysis**: Use 0.6 threshold to identify promising KPIs

### **3. Interpretation**
- Focus on overall compliance scores for KPI selection
- Use individual axiom scores to identify improvement areas
- Consider environmental factors specific to your domain
- Validate results with domain expertise

### **4. Iterative Improvement**
- Start with existing KPIs to establish baseline
- Identify lowest-scoring axioms for targeted improvement
- Test modified KPIs to measure improvement
- Document successful modifications for future use

---

## **🚨 Common Issues and Solutions**

### **Issue 1: "No valid metrics found in data"**
**Cause**: Data structure doesn't contain numeric KPI fields
**Solution**: Ensure data contains numeric arrays for each KPI

### **Issue 2: Low invariance scores across all KPIs**
**Cause**: Strong environmental effects in the data
**Solution**: Consider using relative measures (R = X_A - X_B) or environmental correction

### **Issue 3: Poor scaling proportionality scores**
**Cause**: KPIs with inconsistent units or ranges
**Solution**: Normalize KPIs to similar scales or use dimensionless ratios

### **Issue 4: Low statistical optimality scores**
**Cause**: KPIs with poor signal-to-noise ratios
**Solution**: Improve measurement precision or use aggregated metrics

---

## **📊 Output Files**

The system generates several output files:

### **1. MATLAB Data File** (`axiom_validation_results.mat`)
- Complete validation results
- Detailed scores and analysis
- Raw data for further analysis

### **2. Text Report** (`axiom_validation_report.txt`)
- Human-readable summary
- Key findings and recommendations
- Actionable next steps

### **3. Console Output**
- Real-time validation progress
- Immediate results and insights
- Interactive analysis capabilities

---

## **🔬 Advanced Features**

### **1. Custom Environmental Factors**
```matlab
% Use custom environmental factor
[results, ~, ~] = axiomValidation(data, ...
    'environmental_factor', 'custom_factor');
```

### **2. Batch Processing**
```matlab
% Process multiple datasets
datasets = {'dataset1.mat', 'dataset2.mat', 'dataset3.mat'};
all_results = struct();

for i = 1:length(datasets)
    data = load(datasets{i});
    [results, ~, ~] = axiomValidation(data, 'verbose', false);
    all_results.(sprintf('dataset_%d', i)) = results;
end
```

### **3. Comparative Analysis**
```matlab
% Compare different KPI sets
baseline_results = axiomValidation(baseline_data);
improved_results = axiomValidation(improved_data);

% Calculate improvement
improvement = improved_results.overall_score - baseline_results.overall_score;
fprintf('Overall improvement: %.3f\n', improvement);
```

---

## **📚 Related Documentation**

- **SNR Formula Reference**: `docs/SNR_Formula_Reference.md`
- **Empirical Validation Guide**: `docs/empirical_validation_implementation.md`
- **MATLAB Codebase Structure**: `matlab_codebase_structure.md`

---

## **🎯 Summary**

The **Axiom Validation System** is a powerful tool for UP1 research that:

1. **Automatically tests** KPIs against the 4 fundamental axioms
2. **Ranks KPIs** by environmental noise cancellation effectiveness
3. **Identifies improvement areas** for specific axioms
4. **Provides actionable recommendations** for optimization
5. **Ensures theoretical compliance** with environmental noise cancellation framework

By using this system, you can confidently select KPIs that will effectively eliminate shared environmental factors and achieve the theoretical SNR improvements predicted by the UP1 framework.

**Next Steps**: Run the test script (`scripts/test_axiom_validation.m`) to validate your KPIs and identify the best candidates for environmental noise cancellation analysis.
