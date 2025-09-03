# 📊 **UP2-4 Notation Update: Complete SNR Correlation Analysis**

## 🎯 **Overview**

This document outlines the implementation of UP2-4 notation across our analysis pipeline, providing consistent mathematical notation for signal separation and variance ratios.

## 🔤 **UP2-4 Notation Definition**

### **Core Parameters:**
- **δ = |μ_A - μ_B|** (signal separation)
- **κ = σ²_B/σ²_A** (variance ratio)
- **ρ = correlation between teams**

### **Mathematical Framework:**

#### **1. Absolute Measure SNR:**
```
SNR_A = δ² / (σ_A² + σ_B²) = δ² / σ_A²(1 + κ)
```

#### **2. Relative Measure SNR (with correlation):**
```
SNR_R = δ² / (σ_A² + σ_B² - 2*σ_A*σ_B*ρ) = δ² / σ_A²(1 + κ - 2*√κ*ρ)
```

#### **3. SNR Improvement Ratio:**
```
SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)
```

## 📈 **Asymptote Analysis with UP2-4 Notation**

### **Case 1: Equal Variances (κ = 1)**
```
SNR_R/SNR_A = 1 / (1 - ρ)
```
**Asymptotes:**
- **ρ → 1**: SNR_R/SNR_A → **∞** (perfect correlation)
- **ρ → -1**: SNR_R/SNR_A → **0.5** (perfect negative correlation)
- **ρ = 0**: SNR_R/SNR_A = **1** (independence)

### **Case 2: Unequal Variances (κ ≠ 1)**
```
SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)
```

**Variance Ratio Analysis (κ = σ²_B/σ²_A):**

| κ | ρ → 1 | ρ → -1 | ρ = 0 |
|---|-------|--------|-------|
| **0.25** | 5.00 | 0.56 | 1.25 |
| **1.00** | ∞ | 0.50 | 2.00 |
| **2.25** | 13.00 | 0.52 | 3.25 |
| **4.00** | 5.00 | 0.56 | 5.00 |

## 🎯 **4x Ceiling Analysis with UP2-4 Notation**

### **Signal Enhancement Framework:**
```
SNR_R/SNR_A = 4 / (1 + κ) when ρ = 0 (independence)
```

**4x Ceiling Formula:**
- **κ = 0**: SNR_R/SNR_A = **4.00** (maximum)
- **κ = 0.25**: SNR_R/SNR_A = **3.20**
- **κ = 1.00**: SNR_R/SNR_A = **2.00**
- **κ = 2.25**: SNR_R/SNR_A = **1.23**
- **κ = 4.00**: SNR_R/SNR_A = **0.80**

### **Framework Comparison:**
- **Correlation Framework**: SNR_R/SNR_A = (1 + κ) / (1 + κ - 2*√κ*ρ)
- **Signal Enhancement Framework**: SNR_R/SNR_A = 4 / (1 + κ)
- **When ρ = 0**: Both frameworks give SNR_R/SNR_A = 1 + κ

## 📊 **Empirical Results with UP2-4 Notation**

### **Complete Team Pair Analysis:**
- **720 team-metric pairs** analyzed
- **16 teams** → **120 possible team pairs**
- **6 metrics** per team pair

### **Correlation Statistics:**
- **Mean correlation**: 0.030 ± 0.131
- **Range**: [-0.359, 0.585]
- **Positive correlations**: 413/720 (57.4%)
- **Negative correlations**: 307/720 (42.6%)

### **SNR Improvement Statistics:**
- **Mean SNR improvement**: 1.050 ± 0.156
- **Range**: [0.736, 2.271]
- **Maximum**: 2.271 (well below 4x ceiling)

## 🔍 **Key Insights with UP2-4 Notation**

### **1. Framework Distinction:**
- **Correlation framework**: SNR improvement through **noise reduction** (ρ > 0)
- **Signal enhancement framework**: SNR improvement through **variance ratio** (κ < 3)
- **Both frameworks are valid and complementary**

### **2. Asymptote Behavior:**
- **Perfect correlation (ρ → 1)**: SNR improvement → ∞ (theoretical)
- **Independence (ρ = 0)**: SNR improvement = 1 + κ
- **Negative correlation (ρ < 0)**: SNR degradation

### **3. 4x Ceiling Interpretation:**
- **Theoretical maximum** for signal enhancement framework
- **Occurs when κ = 0** (σ²_B = 0)
- **Not achievable** through correlation framework alone

## 🛠️ **Implementation Updates**

### **Files Updated:**
1. **`scripts/Complete_SNR_Correlation_Analysis.m`**
   - Updated mathematical framework with UP2-4 notation
   - Updated asymptote analysis with κ notation
   - Updated visualization labels and titles
   - Updated key insights section

### **Key Changes Made:**
- **δ = |μ_A - μ_B|** for signal separation
- **κ = σ²_B/σ²_A** for variance ratio
- **Updated all formulas** to use new notation
- **Updated visualization** to show κ instead of r
- **Updated asymptote analysis** with κ values

## 📈 **Visualization Updates**

### **Updated Plots:**
1. **Theoretical SNR ratio** for different κ values
2. **4x ceiling formula** with κ notation
3. **Asymptote analysis** with κ parameter
4. **Framework comparison** plots

### **New Labels:**
- **X-axis**: Variance Ratio (κ) instead of (r)
- **Titles**: Updated to show κ notation
- **Legends**: Show κ values instead of r values

## 🎯 **Benefits of UP2-4 Notation**

### **1. Consistency:**
- **Aligned with UP2-4 framework** notation
- **Consistent across all analyses**
- **Standardized mathematical notation**

### **2. Interpretability:**
- **δ**: Clear signal separation measure
- **κ**: Direct variance ratio (not squared)
- **ρ**: Standard correlation notation

### **3. Mathematical Clarity:**
- **Simplified formulas** with κ notation
- **Clear asymptote behavior**
- **Direct relationship to variance structure**

## 🚀 **Next Steps**

### **1. Update Additional Scripts:**
- Update other analysis scripts with UP2-4 notation
- Ensure consistency across all mathematical expressions
- Update documentation and README files

### **2. Paper Integration:**
- Use UP2-4 notation in paper sections
- Ensure mathematical consistency
- Align with UP2-4 framework terminology

### **3. Framework Extension:**
- Consider UP2-4 notation for multivariate extensions
- Maintain consistency across complexity levels
- Ensure notation scales appropriately

## 📝 **Summary**

The UP2-4 notation update provides:

1. **Consistent mathematical notation** across all analyses
2. **Clear interpretation** of signal separation (δ) and variance ratio (κ)
3. **Simplified formulas** that are easier to understand
4. **Alignment with UP2-4 framework** terminology
5. **Better asymptote analysis** with κ parameter

**This update ensures our analysis pipeline is consistent with the broader UP2-4 research framework while maintaining mathematical rigor and clarity!** 🎯

## 🔗 **Related Files**

- `scripts/Complete_SNR_Correlation_Analysis.m` - Main analysis script
- `outputs/snr_correlation_analysis/complete_snr_correlation_analysis.png` - Updated visualization
- `README_Critical_Analysis_Results.md` - Critical analysis documentation
- `README_Comprehensive_Normality_Results.md` - Normality analysis results

**The UP2-4 notation update provides a solid foundation for consistent mathematical analysis across our entire research framework!** 🚀
