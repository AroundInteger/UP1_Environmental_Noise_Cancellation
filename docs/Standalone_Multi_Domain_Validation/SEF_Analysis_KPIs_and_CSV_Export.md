# SEF Analysis: KPIs Analyzed and CSV Export Summary

## 🎯 **KPIs Analyzed in SEF Sensitivity Analysis**

### **Rugby Performance KPIs (24 Total)**

The SEF framework was applied to **24 rugby performance indicators** across both absolute and relative measurements:

#### **Ball Handling & Attack KPIs:**
1. **Carries** - Number of ball carries
2. **Metres Made** - Total metres gained with ball
3. **Defenders Beaten** - Number of defenders beaten
4. **Clean Breaks** - Number of clean line breaks
5. **Offloads** - Number of offloads made
6. **Passes** - Total number of passes

#### **Turnover & Possession KPIs:**
7. **Turnovers Conceded** - Number of turnovers conceded
8. **Turnovers Won** - Number of turnovers won

#### **Kicking KPIs:**
9. **Kicks from Hand** - Number of kicks from hand
10. **Kick Metres** - Total metres gained from kicks

#### **Set Piece KPIs:**
11. **Scrums Won** - Number of scrums won
12. **Rucks Won** - Number of rucks won
13. **Lineout Throws Lost** - Number of lineout throws lost
14. **Lineout Throws Won** - Number of lineout throws won

#### **Defensive KPIs:**
15. **Tackles** - Total number of tackles made
16. **Missed Tackles** - Number of missed tackles
17. **Ruck/Maul Tackle Pen** - Number of ruck/maul tackles made

#### **Disciplinary KPIs:**
18. **Penalties Conceded** - Number of penalties conceded
19. **Scrum Pens Conceded** - Number of scrum penalties conceded
20. **Lineout Pens Conceded** - Number of lineout penalties conceded
21. **General Play Pens Conceded** - Number of general play penalties conceded
22. **Free Kicks Conceded** - Number of free kicks conceded
23. **Red Cards** - Number of red cards received
24. **Yellow Cards** - Number of yellow cards received

### **Data Structure:**
- **Absolute Features**: Raw performance metrics for each team
- **Relative Features**: Performance metrics relative to opponent
- **Temporal Coverage**: 4 seasons (2021/22, 2022/23, 2023/24, 2024/25)
- **Sample Size**: 1,128 matches across 16 teams
- **SEF Analysis**: Applied to team A vs team B performance pairs

---

## 📊 **CSV Export Files Generated**

### **1. Sample Size Sensitivity Results** (`sample_size_sensitivity_results.csv`)
**Columns:**
- `sample_size`: Tested sample sizes (25, 50, 100, 200, 500, 1000)
- `sef_mean`: Mean SEF value for each sample size
- `sef_std`: Standard deviation of SEF estimates
- `sef_ci_lower`: 95% confidence interval lower bound
- `sef_ci_upper`: 95% confidence interval upper bound
- `coefficient_of_variation`: CV for convergence analysis
- `converged`: Boolean indicating if CV < 0.1 threshold met

**Key Finding**: Minimum sample size for convergence = 50 matches

### **2. Temporal Analysis Results** (`temporal_analysis_results.csv`)
**Columns:**
- `season`: Season string (e.g., '21/22', '22/23')
- `season_id`: Numeric season identifier
- `sef_value`: SEF value for each season
- `sef_std`: Standard deviation for each season
- `sample_size`: Number of matches per season

**Key Finding**: Seasonal CV = 0.022 (extremely stable across seasons)

### **3. Parameter Sensitivity Results** (`parameter_sensitivity_results.csv`)
**Columns:**
- `parameter_value`: κ or ρ parameter value
- `sef_value`: SEF value at that parameter setting
- `parameter_type`: 'kappa' or 'rho'

**Key Finding**: Both κ and ρ show maximum sensitivity (index = 1.000)

### **4. Robustness Analysis Results** (`robustness_analysis_results.csv`)
**Columns:**
- `threshold`: Outlier removal or noise addition threshold
- `sef_value`: SEF value at that threshold
- `test_type`: 'outlier_removal' or 'noise_addition'
- `sensitivity_index`: Overall sensitivity index for the test

**Key Finding**: Extremely robust (outlier sensitivity = 0.008, noise sensitivity = 0.003)

### **5. Statistical Validation Results** (`statistical_validation_results.csv`)
**Columns:**
- `test_type`: 'bootstrap_significance'
- `p_value`: P-value for SEF > 1 test
- `significant`: Boolean significance result
- `effect_size`: Effect size measure
- `confidence_level`: 0.95
- `mean_sef`: Mean SEF from bootstrap
- `std_sef`: Standard deviation from bootstrap
- `ci_95_lower`: 95% CI lower bound
- `ci_95_upper`: 95% CI upper bound
- `ci_99_lower`: 99% CI lower bound
- `ci_99_upper`: 99% CI upper bound

**Key Finding**: Highly significant (p < 0.0001), 95% CI [1.314, 1.396]

### **6. Sensitivity Analysis Summary** (`sensitivity_analysis_summary.csv`)
**Columns:**
- `metric`: Metric name
- `value`: Metric value
- `description`: Human-readable description

**Key Metrics:**
- Minimum sample size: 50
- Seasonal CV: 0.022
- Temporal trend: -0.003
- Kappa sensitivity: 1.000
- Rho sensitivity: 1.000
- Outlier sensitivity: 0.008
- Noise sensitivity: 0.003
- P-value: 0.0000
- Mean SEF: 1.353
- 95% CI: [1.314, 1.396]

### **7. KPI Analysis Details** (`kpi_analysis_details.csv`)
**Columns:**
- `kpi_name`: KPI identifier
- `kpi_type`: 'absolute' or 'relative'
- `description`: Human-readable KPI description

**Content**: Complete list of all 24 rugby performance KPIs with descriptions

### **8. Dataset Information** (`dataset_information.csv`)
**Columns:**
- `property`: Dataset property name
- `value`: Property value
- `description`: Property description

**Key Information:**
- Total matches: 1,128
- Total seasons: 4
- Total teams: 16
- Season range: 2021/22-2024/25
- Team A mean: 112.774 ± 28.169
- Team B mean: 361.718 ± 115.399
- Correlation: 0.565
- Baseline SEF: 1.352

---

## 🎯 **Key Findings Summary**

### **SEF Framework Performance:**
- **Mean SEF**: 1.353 (35.3% improvement over baseline)
- **Statistical Significance**: p < 0.0001 (highly significant)
- **Confidence Interval**: [1.314, 1.396] (narrow, reliable)
- **Temporal Stability**: CV = 0.022 (extremely stable)

### **Data Requirements:**
- **Minimum Sample Size**: 50 matches
- **Recommended Sample Size**: 100+ matches
- **Temporal Coverage**: 4+ seasons for stability assessment
- **Team Diversity**: 16+ teams for robust parameter estimation

### **Robustness Characteristics:**
- **Outlier Tolerance**: Extremely robust (sensitivity = 0.008)
- **Noise Tolerance**: Extremely robust (sensitivity = 0.003)
- **Parameter Sensitivity**: High (requires accurate κ and ρ estimation)

### **Rugby-Specific Insights:**
- **24 Performance KPIs** analyzed across multiple game aspects
- **4 Seasons** of data providing temporal stability validation
- **1,128 Matches** providing robust statistical power
- **16 Teams** providing sufficient diversity for parameter estimation

---

## 📁 **File Locations**

### **CSV Files:**
- Location: `outputs/csv/`
- Format: Standard CSV with headers
- Compatibility: Excel, R, Python, MATLAB, etc.

### **MATLAB Files:**
- Location: `outputs/results/`
- Format: `.mat` files for MATLAB analysis
- Content: Complete analysis results and prepared data

### **Visualizations:**
- Location: `outputs/figures/sensitivity_analysis/`
- Format: PNG and FIG files
- Content: 6 comprehensive analysis plots

---

## 🚀 **Usage Recommendations**

### **For Data Analysis:**
1. **Use CSV files** for cross-platform analysis (R, Python, Excel)
2. **Use MAT files** for MATLAB-specific analysis
3. **Reference KPI details** for understanding performance metrics
4. **Check dataset information** for data quality assessment

### **For Research Publication:**
1. **Sample size results** support minimum data requirements
2. **Temporal analysis** demonstrates framework stability
3. **Robustness testing** validates real-world applicability
4. **Statistical validation** provides significance evidence

### **For Framework Implementation:**
1. **Parameter sensitivity** guides estimation requirements
2. **Sample size requirements** inform data collection planning
3. **Robustness characteristics** support quality assurance
4. **KPI descriptions** aid metric selection and interpretation

---

**Export Version**: 1.0  
**Last Updated**: January 2025  
**Status**: Complete  
**Files Generated**: 8 CSV files + 6 visualizations + 2 MAT files
