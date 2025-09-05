# SEF Sensitivity Analysis Implementation Guide

## 🎯 **Overview**
This guide provides step-by-step instructions for implementing and running the comprehensive SEF sensitivity analysis using our current rugby dataset.

## 📋 **Prerequisites**
- MATLAB R2019b or later
- Rugby dataset: `data/processed/rugby_analysis_ready.mat`
- Required toolboxes: Statistics and Machine Learning Toolbox

## 🚀 **Quick Start**

### **Step 1: Run Sensitivity Analysis**
```matlab
% Navigate to project directory
cd /path/to/UP1_Environmental_Noise_Cancellation

% Run comprehensive sensitivity analysis
run('scripts/SEF_Sensitivity_Analysis.m')
```

### **Step 2: Generate Visualizations**
```matlab
% Generate all sensitivity analysis plots
run('scripts/Visualize_SEF_Sensitivity.m')
```

### **Step 3: Review Results**
- Results saved to: `outputs/results/sef_sensitivity_analysis_results.mat`
- Figures saved to: `outputs/figures/sensitivity_analysis/`
- Console output provides real-time progress and summary

---

## 🔬 **Detailed Analysis Components**

### **1. Sample Size Sensitivity Analysis**

#### **What it tests:**
- SEF stability across different sample sizes (10, 25, 50, 100, 200, 500, 1000+ matches)
- Bootstrap confidence intervals for SEF estimates
- Convergence analysis to identify minimum sample size

#### **Key outputs:**
- `sample_results.sef_means`: Mean SEF for each sample size
- `sample_results.sef_stds`: Standard deviation of SEF estimates
- `sample_results.convergence`: Coefficient of variation (CV) for each sample size
- `sample_results.min_sample_size`: Minimum sample size for convergence (CV < 0.1)

#### **Interpretation:**
- **CV < 0.1**: SEF estimates are stable and reliable
- **CV > 0.1**: SEF estimates are unstable, need more data
- **Convergence**: Identifies minimum data requirements for reliable SEF

### **2. Temporal/Longitudinal Analysis**

#### **What it tests:**
- SEF behavior across 4 seasons of rugby data
- Seasonal stability and temporal trends
- Rolling window analysis for temporal patterns

#### **Key outputs:**
- `temporal_results.seasonal_sef`: SEF values for each season
- `temporal_results.seasonal_cv`: Coefficient of variation across seasons
- `temporal_results.temporal_trend`: Linear trend in seasonal SEF values

#### **Interpretation:**
- **Low seasonal CV**: SEF is stable across time periods
- **High seasonal CV**: SEF varies significantly across seasons
- **Trend analysis**: Identifies increasing/decreasing SEF over time

### **3. Parameter Sensitivity Analysis**

#### **What it tests:**
- SEF sensitivity to κ (variance ratio) across range 0.1 to 10
- SEF sensitivity to ρ (correlation) across range -1 to +1
- Parameter space mapping and interaction effects

#### **Key outputs:**
- `param_results.kappa_sensitivity`: Sensitivity index for κ parameter
- `param_results.rho_sensitivity`: Sensitivity index for ρ parameter
- `param_results.parameter_space`: Full SEF landscape across parameter space

#### **Interpretation:**
- **Sensitivity index < 0.5**: Low sensitivity, robust to parameter changes
- **Sensitivity index > 0.5**: High sensitivity, parameter estimation critical
- **Parameter space**: Visualizes SEF behavior across all parameter combinations

### **4. Robustness Testing**

#### **What it tests:**
- SEF sensitivity to outliers (0%, 1%, 5%, 10%, 20% removal)
- SEF sensitivity to noise (0%, 1%, 5%, 10%, 20% added noise)
- SEF sensitivity to missing data (0%, 1%, 5%, 10%, 20% missing)

#### **Key outputs:**
- `robustness_results.outlier_analysis.sensitivity`: Outlier sensitivity index
- `robustness_results.noise_analysis.sensitivity`: Noise sensitivity index
- `robustness_results.missing_data_analysis.sensitivity`: Missing data sensitivity index

#### **Interpretation:**
- **Sensitivity < 0.3**: Robust to data quality issues
- **Sensitivity > 0.3**: Sensitive to data quality, requires careful preprocessing
- **Comparative analysis**: Identifies which data quality issues are most critical

### **5. Statistical Validation**

#### **What it tests:**
- K-fold cross-validation (5 folds)
- Bootstrap confidence intervals (95% and 99%)
- Statistical significance testing (SEF > 1)
- Model comparison against baseline methods

#### **Key outputs:**
- `validation_results.significance.p_value`: P-value for SEF > 1
- `validation_results.confidence_intervals.ci_95`: 95% confidence interval
- `validation_results.model_comparison`: Comparison with alternative methods

#### **Interpretation:**
- **P-value < 0.05**: SEF improvement is statistically significant
- **Confidence intervals**: Quantifies uncertainty in SEF estimates
- **Model comparison**: Demonstrates SEF advantage over baseline methods

---

## 📊 **Expected Results and Interpretation**

### **Sample Size Analysis**
- **Expected**: SEF estimates should converge as sample size increases
- **Good result**: CV < 0.1 achieved with reasonable sample size (100-200 matches)
- **Poor result**: No convergence even with large sample sizes

### **Temporal Analysis**
- **Expected**: SEF should be relatively stable across seasons
- **Good result**: Seasonal CV < 0.2, minimal temporal trend
- **Poor result**: High seasonal variation, strong temporal trends

### **Parameter Sensitivity**
- **Expected**: Moderate sensitivity to both κ and ρ parameters
- **Good result**: Sensitivity indices < 0.5 for both parameters
- **Poor result**: High sensitivity (> 0.5) indicates fragile framework

### **Robustness Testing**
- **Expected**: SEF should be robust to moderate data quality issues
- **Good result**: Sensitivity indices < 0.3 for all robustness tests
- **Poor result**: High sensitivity to outliers, noise, or missing data

### **Statistical Validation**
- **Expected**: SEF > 1 should be statistically significant
- **Good result**: P-value < 0.05, narrow confidence intervals
- **Poor result**: Non-significant results, wide confidence intervals

---

## 🛠️ **Troubleshooting**

### **Common Issues:**

#### **1. Data Loading Error**
```
Error: Failed to load rugby dataset
```
**Solution**: Ensure `data/processed/rugby_analysis_ready.mat` exists and contains required fields

#### **2. Memory Issues**
```
Error: Out of memory
```
**Solution**: Reduce bootstrap samples or sample sizes in the analysis

#### **3. Convergence Issues**
```
Warning: No convergence achieved within tested sample sizes
```
**Solution**: Increase maximum sample size or adjust convergence threshold

#### **4. Statistical Significance Issues**
```
Warning: SEF improvement not statistically significant
```
**Solution**: Check data quality, increase sample size, or investigate parameter estimation

---

## 📈 **Advanced Usage**

### **Customizing Analysis Parameters**

#### **Modify Sample Sizes:**
```matlab
% In SEF_Sensitivity_Analysis.m, line ~25
sample_sizes = [10, 25, 50, 100, 200, 500, 1000, 2000]; % Add more sizes
```

#### **Adjust Convergence Threshold:**
```matlab
% In analyze_sample_size_sensitivity function, line ~70
convergence_threshold = 0.05; % Stricter threshold
```

#### **Modify Bootstrap Samples:**
```matlab
% In SEF_Sensitivity_Analysis.m, line ~26
n_bootstrap = 500; % Increase for more robust estimates
```

### **Adding Custom Analysis**

#### **Custom Sensitivity Test:**
```matlab
function custom_results = analyze_custom_sensitivity(data)
    % Your custom sensitivity analysis here
    custom_results = struct();
    % ... implementation ...
end
```

#### **Custom Visualization:**
```matlab
function visualize_custom_analysis(custom_results)
    % Your custom visualization here
    figure('Position', [100, 100, 800, 600]);
    % ... implementation ...
end
```

---

## 📋 **Output Files**

### **Results Files:**
- `outputs/results/sef_sensitivity_analysis_results.mat`: Complete analysis results
- `outputs/results/sef_sensitivity_analysis_results.txt`: Text summary report

### **Figure Files:**
- `outputs/figures/sensitivity_analysis/sample_size_sensitivity.png`: Sample size analysis
- `outputs/figures/sensitivity_analysis/temporal_behavior.png`: Temporal analysis
- `outputs/figures/sensitivity_analysis/parameter_sensitivity.png`: Parameter sensitivity
- `outputs/figures/sensitivity_analysis/robustness_analysis.png`: Robustness testing
- `outputs/figures/sensitivity_analysis/statistical_validation.png`: Statistical validation
- `outputs/figures/sensitivity_analysis/comprehensive_summary.png`: Summary dashboard

### **MATLAB Files:**
- `outputs/figures/sensitivity_analysis/*.fig`: Interactive MATLAB figures

---

## 🎯 **Success Criteria**

### **Technical Success:**
- [ ] All analysis phases complete without errors
- [ ] Results saved to specified output files
- [ ] Visualizations generated successfully
- [ ] Console output shows progress and summary

### **Scientific Success:**
- [ ] Sample size convergence achieved
- [ ] Temporal stability demonstrated
- [ ] Parameter sensitivity quantified
- [ ] Robustness to data quality issues shown
- [ ] Statistical significance established

### **Practical Success:**
- [ ] Minimum sample size requirements identified
- [ ] Data quality requirements established
- [ ] Framework limitations documented
- [ ] Best practices for SEF application defined

---

## 🔄 **Next Steps**

### **After Running Analysis:**
1. **Review Results**: Examine all output files and visualizations
2. **Identify Issues**: Look for convergence problems, high sensitivity, or non-significance
3. **Adjust Parameters**: Modify analysis parameters if needed
4. **Document Findings**: Update project documentation with results
5. **Plan Improvements**: Identify areas for framework enhancement

### **For Paper Integration:**
1. **Select Key Results**: Choose most important findings for paper
2. **Create Summary Tables**: Generate tables of key metrics
3. **Prepare Figures**: Select and refine figures for publication
4. **Write Methods Section**: Document sensitivity analysis methodology
5. **Discuss Limitations**: Address framework limitations honestly

---

**Implementation Guide Version**: 1.0  
**Last Updated**: January 2025  
**Status**: Ready for Implementation  
**Next Step**: Run the sensitivity analysis pipeline
