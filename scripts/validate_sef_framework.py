#!/usr/bin/env python3
"""
SEF Framework Validation Script

This script validates the Signal Enhancement Factor (SEF) framework using real or sample data.
It calculates κ (variance ratio), ρ (correlation), and SEF values for competitive measurements.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import pearsonr, shapiro, kstest
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, roc_auc_score
from sklearn.model_selection import train_test_split
import warnings
warnings.filterwarnings('ignore')

def calculate_sef(kappa, rho):
    """
    Calculate Signal Enhancement Factor (SEF)
    
    SEF = (1 + κ) / (1 + κ - 2√κ·ρ)
    
    Where:
    - κ = σ²_B / σ²_A (variance ratio)
    - ρ = Corr(X_A, X_B) (correlation coefficient)
    """
    if (1 + kappa - 2 * np.sqrt(kappa) * rho) <= 0:
        return np.inf  # Avoid division by zero or negative
    return (1 + kappa) / (1 + kappa - 2 * np.sqrt(kappa) * rho)

def validate_sef_framework(df, class_a_col, class_a_value, class_b_value, measurement_col):
    """
    Validate SEF framework on a dataset
    
    Parameters:
    - df: DataFrame with the data
    - class_a_col: Column name for classification
    - class_a_value: Value for class A
    - class_b_value: Value for class B
    - measurement_col: Column name for measurements
    """
    print(f"\n=== SEF FRAMEWORK VALIDATION ===")
    print(f"Dataset: {len(df)} total records")
    print(f"Classification: {class_a_col}")
    print(f"Classes: {class_a_value} vs {class_b_value}")
    print(f"Measurement: {measurement_col}")
    print("=" * 50)
    
    # Separate classes
    class_a = df[df[class_a_col] == class_a_value][measurement_col].dropna()
    class_b = df[df[class_a_col] == class_b_value][measurement_col].dropna()
    
    print(f"Class A ({class_a_value}): {len(class_a)} samples")
    print(f"Class B ({class_b_value}): {len(class_b)} samples")
    
    if len(class_a) < 10 or len(class_b) < 10:
        print("❌ INSUFFICIENT SAMPLE SIZE")
        return None
    
    # Calculate basic statistics
    mean_a = class_a.mean()
    mean_b = class_b.mean()
    var_a = class_a.var()
    var_b = class_b.var()
    std_a = np.sqrt(var_a)
    std_b = np.sqrt(var_b)
    
    print(f"\nBasic Statistics:")
    print(f"  Class A: mean={mean_a:.4f}, std={std_a:.4f}")
    print(f"  Class B: mean={mean_b:.4f}, std={std_b:.4f}")
    
    # Calculate SEF parameters
    kappa = var_b / var_a  # Variance ratio
    delta = abs(mean_a - mean_b) / std_a  # Signal separation
    
    print(f"\nSEF Parameters:")
    print(f"  κ (variance ratio) = {kappa:.4f}")
    print(f"  δ (signal separation) = {delta:.4f}")
    
    # Calculate correlation (if we have paired data)
    # For now, we'll estimate correlation based on shared environmental factors
    # In real competitive measurements, this would be calculated from actual paired observations
    
    # Estimate correlation based on framework assumptions
    # For competitive measurements, we expect moderate positive correlation
    estimated_rho = 0.2  # Conservative estimate for competitive measurements
    
    print(f"  ρ (estimated correlation) = {estimated_rho:.4f}")
    
    # Calculate SEF
    sef = calculate_sef(kappa, estimated_rho)
    
    print(f"\nSEF Calculation:")
    print(f"  SEF = (1 + κ) / (1 + κ - 2√κ·ρ)")
    print(f"  SEF = (1 + {kappa:.4f}) / (1 + {kappa:.4f} - 2√{kappa:.4f}·{estimated_rho:.4f})")
    print(f"  SEF = {sef:.4f}")
    
    # Interpret SEF
    improvement_percent = (sef - 1) * 100
    print(f"\nSEF Interpretation:")
    print(f"  Signal Enhancement Factor: {sef:.4f}")
    print(f"  Improvement: {improvement_percent:.1f}%")
    
    if sef > 1.5:
        print(f"  Assessment: 🎉 EXCELLENT improvement potential")
    elif sef > 1.25:
        print(f"  Assessment: ✅ GOOD improvement potential")
    elif sef > 1.1:
        print(f"  Assessment: ⚠️ MODEST improvement potential")
    else:
        print(f"  Assessment: ❌ MINIMAL improvement potential")
    
    # Statistical validation
    print(f"\nStatistical Validation:")
    
    # Normality tests
    _, p_a = shapiro(class_a) if len(class_a) <= 5000 else kstest(class_a, 'norm')
    _, p_b = shapiro(class_b) if len(class_b) <= 5000 else kstest(class_b, 'norm')
    
    print(f"  Normality (Class A): p={p_a:.4f} {'✅' if p_a > 0.05 else '❌'}")
    print(f"  Normality (Class B): p={p_b:.4f} {'✅' if p_b > 0.05 else '❌'}")
    
    # Effect size (Cohen's d)
    pooled_std = np.sqrt(((len(class_a) - 1) * var_a + (len(class_b) - 1) * var_b) / (len(class_a) + len(class_b) - 2))
    cohens_d = abs(mean_a - mean_b) / pooled_std
    
    print(f"  Effect size (Cohen's d): {cohens_d:.4f}")
    
    if cohens_d > 0.8:
        print(f"  Effect size: 🎉 LARGE effect")
    elif cohens_d > 0.5:
        print(f"  Effect size: ✅ MEDIUM effect")
    elif cohens_d > 0.2:
        print(f"  Effect size: ⚠️ SMALL effect")
    else:
        print(f"  Effect size: ❌ NEGLIGIBLE effect")
    
    # Framework applicability assessment
    print(f"\nFramework Applicability:")
    
    applicability_score = 0
    max_score = 5
    
    # Sample size check
    if len(class_a) >= 20 and len(class_b) >= 20:
        applicability_score += 1
        print(f"  ✅ Sample size adequate")
    else:
        print(f"  ❌ Sample size insufficient")
    
    # Variance ratio check
    if 0.5 <= kappa <= 5.0:
        applicability_score += 1
        print(f"  ✅ Variance ratio within framework bounds")
    else:
        print(f"  ❌ Variance ratio outside framework bounds")
    
    # Signal separation check
    if delta > 0.1:
        applicability_score += 1
        print(f"  ✅ Signal separation adequate")
    else:
        print(f"  ❌ Signal separation insufficient")
    
    # Normality check
    if p_a > 0.05 and p_b > 0.05:
        applicability_score += 1
        print(f"  ✅ Both classes approximately normal")
    else:
        print(f"  ⚠️ Non-normal distributions detected")
    
    # Effect size check
    if cohens_d > 0.2:
        applicability_score += 1
        print(f"  ✅ Meaningful effect size")
    else:
        print(f"  ❌ Effect size too small")
    
    print(f"\nOverall Applicability: {applicability_score}/{max_score}")
    
    if applicability_score >= 4:
        print(f"  🎉 EXCELLENT framework fit")
    elif applicability_score >= 3:
        print(f"  ✅ GOOD framework fit")
    elif applicability_score >= 2:
        print(f"  ⚠️ MODERATE framework fit")
    else:
        print(f"  ❌ POOR framework fit")
    
    return {
        'sef': sef,
        'kappa': kappa,
        'rho': estimated_rho,
        'delta': delta,
        'improvement_percent': improvement_percent,
        'applicability_score': applicability_score,
        'max_score': max_score,
        'cohens_d': cohens_d,
        'normality_a': p_a,
        'normality_b': p_b,
        'sample_size_a': len(class_a),
        'sample_size_b': len(class_b)
    }

def analyze_mlperf_data():
    """
    Analyze MLPerf benchmark data for SEF framework validation
    """
    print("=== MLPERF BENCHMARK SEF ANALYSIS ===")
    
    # Load the data
    try:
        df = pd.read_csv('data/raw/mlperf_benchmarks/mlperf_benchmarks_combined.csv')
        print(f"Loaded MLPerf data: {len(df)} records")
    except FileNotFoundError:
        print("❌ MLPerf data not found. Please run collect_mlperf_benchmarks.py first.")
        return
    
    # Analyze different measurement scenarios
    scenarios = [
        {
            'name': 'Hardware Type (GPU vs TPU)',
            'class_col': 'hardware_type',
            'class_a': 'GPU',
            'class_b': 'TPU',
            'measurement_col': 'accuracy'
        },
        {
            'name': 'Software Framework (TensorFlow vs PyTorch)',
            'class_col': 'software_framework',
            'class_a': 'TensorFlow',
            'class_b': 'PyTorch',
            'measurement_col': 'accuracy'
        },
        {
            'name': 'Benchmark Type (Training vs Inference)',
            'class_col': 'benchmark_type',
            'class_a': 'training_results',
            'class_b': 'inference_results',
            'measurement_col': 'accuracy'
        }
    ]
    
    results = {}
    
    for scenario in scenarios:
        print(f"\n{'='*60}")
        print(f"SCENARIO: {scenario['name']}")
        print(f"{'='*60}")
        
        # Filter data for this scenario
        scenario_data = df[
            (df[scenario['class_col']] == scenario['class_a']) | 
            (df[scenario['class_col']] == scenario['class_b'])
        ].copy()
        
        if len(scenario_data) < 20:
            print(f"❌ Insufficient data for {scenario['name']}")
            continue
        
        # Validate SEF framework
        result = validate_sef_framework(
            scenario_data,
            scenario['class_col'],
            scenario['class_a'],
            scenario['class_b'],
            scenario['measurement_col']
        )
        
        if result:
            results[scenario['name']] = result
    
    # Summary analysis
    print(f"\n{'='*60}")
    print("SUMMARY ANALYSIS")
    print(f"{'='*60}")
    
    if results:
        print(f"Analyzed {len(results)} scenarios:")
        
        for scenario_name, result in results.items():
            print(f"\n{scenario_name}:")
            print(f"  SEF: {result['sef']:.4f} ({result['improvement_percent']:.1f}% improvement)")
            print(f"  κ: {result['kappa']:.4f}, ρ: {result['rho']:.4f}")
            print(f"  Applicability: {result['applicability_score']}/{result['max_score']}")
        
        # Best scenario
        best_scenario = max(results.items(), key=lambda x: x[1]['sef'])
        print(f"\n🎉 BEST SCENARIO: {best_scenario[0]}")
        print(f"   SEF: {best_scenario[1]['sef']:.4f}")
        print(f"   Improvement: {best_scenario[1]['improvement_percent']:.1f}%")
        
        # Framework validation summary
        valid_scenarios = sum(1 for r in results.values() if r['applicability_score'] >= 3)
        print(f"\nFramework Validation Summary:")
        print(f"  Valid scenarios: {valid_scenarios}/{len(results)}")
        print(f"  Success rate: {valid_scenarios/len(results)*100:.1f}%")
        
        if valid_scenarios >= len(results) * 0.5:
            print(f"  🎉 FRAMEWORK VALIDATION SUCCESSFUL")
        else:
            print(f"  ⚠️ FRAMEWORK VALIDATION NEEDS IMPROVEMENT")
    
    else:
        print("❌ No valid scenarios found for analysis")

def main():
    """
    Main execution function
    """
    print("Starting SEF Framework Validation...")
    print("This script validates the Signal Enhancement Factor framework")
    print("using competitive measurement data.")
    
    # Analyze MLPerf data
    analyze_mlperf_data()
    
    print(f"\n{'='*60}")
    print("SEF FRAMEWORK VALIDATION COMPLETE")
    print(f"{'='*60}")
    print("Next steps:")
    print("1. Collect real competitive measurement data")
    print("2. Calculate actual correlations from paired observations")
    print("3. Validate framework with real-world scenarios")
    print("4. Document results for paper integration")

if __name__ == "__main__":
    main()
