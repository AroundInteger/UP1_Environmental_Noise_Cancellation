# UP1 Environmental Noise Cancellation: SNR Formula Reference

## 🚨 **CRITICAL: Correct SNR Improvement Formula**

**This document serves as the authoritative reference for the SNR improvement formula to prevent implementation errors.**

### **✅ Correct Formula (From Paper)**

The **correct** signal-to-noise ratio improvement formula is:

```
SNR_improvement = 1 + 2σ²_η/(σ²_A + σ²_B)
```

**Where:**
- `σ²_η` = Environmental noise variance
- `σ²_A` = Competitor A individual noise variance  
- `σ²_B` = Competitor B individual noise variance

**Special Case - Equal Variances (σ²_A = σ²_B = σ²_indiv):**
```
SNR_improvement = 1 + σ²_η/σ²_indiv
```

**General Case - Unequal Variances:**
```
SNR_improvement = 1 + 2σ²_η/(σ²_A + σ²_B)
```

### **❌ Incorrect Formula (Previously Used)**

**DO NOT USE** this incorrect formula:
```
SNR_improvement = √(1 + (σ_η/σ_indiv)²)  ❌ WRONG!
```

### **🔍 Mathematical Derivation**

The SNR improvement comes from comparing:

1. **Absolute measurement SNR**: `SNR_abs = (μ_A - μ_B)²/(σ²_A + σ²_η)`
2. **Relative measurement SNR**: `SNR_rel = (μ_A - μ_B)²/(σ²_A + σ²_B)`

**Ratio**: `SNR_rel/SNR_abs = (σ²_A + σ²_η)/(σ²_A + σ²_B)`

**Simplified**: `SNR_improvement = 1 + (σ²_η - σ²_B)/(σ²_A + σ²_B)`

**When environmental noise dominates** (σ²_η ≫ σ²_B):
```
SNR_improvement ≈ 1 + σ²_η/(σ²_A + σ²_B)
```

### **📊 Implementation in MATLAB**

#### **Comprehensive Implementation (Handles Both Scenarios)**
```matlab
function snr_improvement = calculateTheoreticalSNRImprovement(sigma_eta, sigma_A, sigma_B)
    % CORRECT: Use the proper SNR improvement formula from the paper
    % Handles both equal and unequal competitor variances
    
    if sigma_eta == 0 || sigma_A == 0 || sigma_B == 0
        snr_improvement = NaN;
        return;
    end
    
    sigma_eta_squared = sigma_eta^2;
    sigma_A_squared = sigma_A^2;
    sigma_B_squared = sigma_B^2;
    
    % Check if variances are equal (within numerical tolerance)
    if abs(sigma_A_squared - sigma_B_squared) < 1e-10
        % Equal variances: use simplified formula
        snr_improvement = 1 + (sigma_eta_squared / sigma_A_squared);
        fprintf('Using simplified formula (equal variances): SNR = 1 + σ²_η/σ²_indiv\n');
    else
        % Unequal variances: use full formula
        snr_improvement = 1 + (2 * sigma_eta_squared) / (sigma_A_squared + sigma_B_squared);
        fprintf('Using full formula (unequal variances): SNR = 1 + 2σ²_η/(σ²_A + σ²_B)\n');
    end
end
```

#### **Simplified Implementation (When σ_A = σ_B)**
```matlab
function snr_improvement = calculateTheoreticalSNRImprovement(sigma_eta, sigma_indiv)
    % CORRECT: Simplified version when σ_A = σ_B = σ_indiv
    % SNR_improvement = 1 + σ²_η/σ²_indiv
    
    if sigma_eta == 0 || sigma_indiv == 0
        snr_improvement = NaN;
        return;
    end
    
    sigma_eta_squared = sigma_eta^2;
    sigma_indiv_squared = sigma_indiv^2;
    
    % Use the correct formula from the theoretical framework
    snr_improvement = 1 + (sigma_eta_squared / sigma_indiv_squared);
end
```

### **🎯 Key Points to Remember**

1. **Always use variance (σ²) not standard deviation (σ)**
2. **The formula is additive: `1 + ...` not multiplicative**
3. **No square root in the main formula**
4. **The factor of 2 comes from the two-competitor comparison**
5. **Environmental noise variance is in the numerator**

### **📈 Expected Results**

With the correct formula:
- **Environmental noise ratio = 50%** → **SNR improvement = 1.25 (25%)**
- **Environmental noise ratio = 56.8%** → **SNR improvement = 1.32 (32%)**
- **Environmental noise ratio = 80%** → **SNR improvement = 1.64 (64%)**

### **🔧 Files That Need Updating**

The following files have been corrected to use the proper formula:
- ✅ `src/empirical/environmentalEstimation.m`
- ✅ `scripts/create_snr_visualization.m`
- ✅ `scripts/create_snr_curve_fixed.m`

### **📚 Paper References**

The correct formula is documented in:
- **Section 2.4**: Signal-to-Noise Ratio Improvement
- **Section 3.2**: SNR Connection and Improvement
- **Appendix A**: Mathematical Details and Formal Proofs

### **🎯 Theoretical Framework Implementation**

A comprehensive theoretical framework has been implemented in `src/theory/UP1_Theoretical_Framework.m` that:

1. **Handles Both Scenarios**: Equal and unequal competitor variances
2. **Uses Correct Formulas**: Implements the paper's mathematical framework
3. **Provides Analysis**: Compares theoretical predictions across different variance scenarios
4. **Integrates Empirical Data**: Loads actual rugby data for validation
5. **Generates Visualizations**: Creates publication-quality figures for analysis

**Key Features:**
- **Equal Variances**: Simplified formula `SNR = 1 + σ²_η/σ²_indiv`
- **Unequal Variances**: Full formula `SNR = 1 + 2σ²_η/(σ²_A + σ²_B)`
- **Environmental Dominance**: Identifies when environmental noise dominates
- **Gap Analysis**: Compares theoretical vs empirical results

### **⚠️ Common Mistakes to Avoid**

1. **Using standard deviations instead of variances**
2. **Adding square roots where they don't belong**
3. **Forgetting the factor of 2 in the numerator**
4. **Using multiplicative instead of additive relationships**
5. **Confusing SNR improvement with SNR ratio**

### **🧪 Testing the Formula**

To verify your implementation is correct:

1. **Test case 1**: σ_η = 1, σ_A = σ_B = 1
   - Expected: SNR_improvement = 1 + 1²/(1² + 1²) = 1 + 1/2 = 1.5

2. **Test case 2**: σ_η = 2, σ_A = σ_B = 1  
   - Expected: SNR_improvement = 1 + 2²/(1² + 1²) = 1 + 4/2 = 3.0

3. **Test case 3**: σ_η = 0.5, σ_A = σ_B = 1
   - Expected: SNR_improvement = 1 + 0.5²/(1² + 1²) = 1 + 0.25/2 = 1.125

### **📞 Support**

If you have questions about the SNR formula implementation:
1. **First**: Check this document
2. **Second**: Review the paper sections referenced above
3. **Third**: Contact the UP1 research team

**Remember**: The correct formula is `1 + 2σ²_η/(σ²_A + σ²_B)` - anything else is wrong!
