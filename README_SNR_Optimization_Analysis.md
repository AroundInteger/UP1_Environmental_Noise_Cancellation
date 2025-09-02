# 🎯 SNR Optimization Analysis: When is SNR_R Maximized Relative to SNR_A?

## 📋 **Executive Summary**

**Answer to your question: NO, SNR_R is NOT maximized when σ_A ≈ σ_B.**

**SNR_R is MAXIMIZED when σ_B = 0 (one team has zero variance).**

**When σ_A ≈ σ_B (equal variances), SNR_R/SNR_A = 2x (good but not maximum).**

---

## 🧮 **Mathematical Framework**

### **SNR Definitions:**
```
SNR_A = |μ_A - μ_B|² / σ_A²
SNR_R = (2|μ_A - μ_B|)² / (σ_A² + σ_B²)
```

### **SNR Improvement Ratio:**
```
SNR_R/SNR_A = 4 / (1 + r²)
where r = σ_B/σ_A (variance ratio)
```

---

## 📊 **Optimization Analysis**

### **Variance Ratio vs SNR Improvement:**

| Variance Ratio (r = σ_B/σ_A) | SNR_R/SNR_A | Interpretation |
|-------------------------------|-------------|----------------|
| **0.0** | **4.00x** | **MAXIMUM (σ_B = 0)** |
| 0.5 | 3.20x | σ_B < σ_A |
| **1.0** | **2.00x** | **Equal variances** |
| 1.5 | 1.23x | σ_B > σ_A |
| 2.0 | 0.80x | σ_B > σ_A |
| **√3 ≈ 1.73** | **1.00x** | **Break-even point** |
| 3.0 | 0.40x | σ_B > σ_A |
| 5.0 | 0.15x | σ_B > σ_A |
| 10.0 | 0.04x | σ_B > σ_A |

---

## 🎯 **Key Insights**

### **1. Maximum SNR_R/SNR_A:**
- **Occurs when r = 0** (σ_B = 0)
- **SNR_R/SNR_A = 4x**
- **One team has perfect consistency** (zero variance)
- **Practically unrealistic** in real sports data

### **2. Equal Variance Case (σ_A ≈ σ_B):**
- **r = 1**
- **SNR_R/SNR_A = 2x**
- **Good improvement but NOT maximum**
- **Often assumed in theoretical analysis**

### **3. Break-even Point:**
- **r = √3 ≈ 1.73**
- **SNR_R/SNR_A = 1x**
- **Relative measures provide no advantage**
- **Avoid relative measures when r > √3**

---

## 📈 **Empirical Evidence from Rugby Data**

### **Technical KPI Analysis:**

| KPI | σ_A | σ_B | r = σ_B/σ_A | Theoretical | Empirical |
|-----|-----|-----|-------------|-------------|-----------|
| Carry | 27.23 | 28.48 | 1.05 | 1.91x | 1.85x |
| MetresMade | 111.24 | 101.55 | 0.91 | 2.18x | 1.85x |
| DefenderBeaten | 7.27 | 6.71 | 0.92 | 2.16x | 1.88x |
| Offload | 3.61 | 3.52 | 0.97 | 2.05x | 2.29x |
| Pass | 37.43 | 38.60 | 1.03 | 1.94x | 2.09x |

### **Rugby Data Summary:**
- **Mean variance ratio**: 0.98 (close to equal variances)
- **Mean theoretical improvement**: 2.05x
- **Mean empirical improvement**: 1.99x
- **All KPIs show r < √3** → Relative measures beneficial

---

## 🔍 **Mathematical Derivation**

### **Step-by-step derivation:**

```
SNR_R/SNR_A = [(2|μ_A - μ_B|)² / (σ_A² + σ_B²)] / [|μ_A - μ_B|² / σ_A²]

SNR_R/SNR_A = [4|μ_A - μ_B|² / (σ_A² + σ_B²)] × [σ_A² / |μ_A - μ_B|²]

SNR_R/SNR_A = 4σ_A² / (σ_A² + σ_B²)

Let r = σ_B/σ_A:
SNR_R/SNR_A = 4σ_A² / (σ_A² + r²σ_A²)
SNR_R/SNR_A = 4σ_A² / [σ_A²(1 + r²)]
SNR_R/SNR_A = 4 / (1 + r²)
```

### **Optimization:**
- **Maximum occurs when denominator (1 + r²) is minimized**
- **Minimum denominator = 1 when r = 0**
- **Therefore, maximum SNR_R/SNR_A = 4 when r = 0**

---

## 🎯 **Practical Implications**

### **1. When to Use Relative Measures:**
- ✅ **r < √3 ≈ 1.73** → SNR improvement guaranteed
- ✅ **r ≈ 1** (equal variances) → 2x improvement
- ✅ **r < 1** (unequal variances) → >2x improvement
- ❌ **r > √3** → Avoid relative measures

### **2. Rugby Data Analysis:**
- **All technical KPIs have r ≈ 1** (close to equal variances)
- **SNR improvements of ~2x** are expected and observed
- **Relative measures are beneficial** for rugby technical KPIs

### **3. Theoretical Framework:**
- **Equal variance assumption** (r = 1) gives 2x improvement
- **This is the "balanced" case** often used in theory
- **Real data often shows r ≈ 1** in competitive sports

---

## 🏆 **Final Answer**

### **To your question: "Is SNR_R maximized when σ_A ≈ σ_B?"**

**NO, SNR_R is NOT maximized when σ_A ≈ σ_B.**

### **Correct answers:**

1. **SNR_R is MAXIMIZED when σ_B = 0** (r = 0) → **4x improvement**
2. **When σ_A ≈ σ_B** (r = 1) → **2x improvement** (good but not maximum)
3. **Break-even point** at r = √3 ≈ 1.73 → **1x improvement**

### **Mathematical proof:**
```
SNR_R/SNR_A = 4 / (1 + r²)

Maximum when r = 0: SNR_R/SNR_A = 4 / (1 + 0) = 4x
Equal variances r = 1: SNR_R/SNR_A = 4 / (1 + 1) = 2x
```

### **Practical reality:**
- **Perfect optimization** (r = 0) is unrealistic in sports
- **Equal variances** (r = 1) is common and provides good 2x improvement
- **Rugby data shows r ≈ 1** → 2x improvement is expected and observed

---

## 📋 **Summary**

**Your intuition was close but not quite right!**

- ❌ **SNR_R is NOT maximized when σ_A ≈ σ_B**
- ✅ **SNR_R is MAXIMIZED when σ_B = 0** (unrealistic)
- ✅ **When σ_A ≈ σ_B, SNR_R/SNR_A = 2x** (good but not maximum)
- ✅ **Rugby data shows r ≈ 1** → 2x improvement is realistic and beneficial

**The mathematical framework clearly shows that maximum SNR improvement occurs when one team has zero variance, but equal variances still provide a solid 2x improvement that we observe in practice.**

---

*Analysis completed: 2024*
*Mathematical framework: SNR_R/SNR_A = 4 / (1 + r²)*
*Empirical validation: Rugby technical KPIs*
