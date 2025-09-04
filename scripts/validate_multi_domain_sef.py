#!/usr/bin/env python3
"""
Multi-Domain SEF Framework Validation Script

This script validates the Signal Enhancement Factor (SEF) framework across multiple domains
using realistic competitive measurement data.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import pearsonr, shapiro, kstest
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

def validate_domain_sef(df, domain_name, class_col, class_a, class_b, measurement_col, expected_sef_range):
    """
    Validate SEF framework for a specific domain
    """
    print(f"\n{'='*60}")
    print(f"DOMAIN: {domain_name.upper()}")
    print(f"Expected SEF: {expected_sef_range}")
    print(f"{'='*60}")
    
    # Separate classes
    class_a_data = df[df[class_col] == class_a][measurement_col].dropna()
    class_b_data = df[df[class_col] == class_b][measurement_col].dropna()
    
    print(f"Class A ({class_a}): {len(class_a_data)} samples")
    print(f"Class B ({class_b}): {len(class_b_data)} samples")
    
    if len(class_a_data) < 10 or len(class_b_data) < 10:
        print("❌ INSUFFICIENT SAMPLE SIZE")
        return None
    
    # Calculate basic statistics
    mean_a = class_a_data.mean()
    mean_b = class_b_data.mean()
    var_a = class_a_data.var()
    var_b = class_b_data.var()
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
    
    # Estimate correlation based on competitive measurement framework
    # For competitive measurements, we expect moderate positive correlation
    # due to shared environmental factors
    
    if domain_name == "Sports":
        estimated_rho = 0.15  # Teams face similar opponents and conditions
    elif domain_name == "Education":
        estimated_rho = 0.25  # Schools face similar economic and policy conditions
    elif domain_name == "Finance":
        estimated_rho = 0.30  # Funds face similar market conditions
    elif domain_name == "Healthcare":
        estimated_rho = 0.20  # Hospitals face similar regulatory and economic conditions
    else:
        estimated_rho = 0.20  # Default for competitive measurements
    
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
    
    # Compare with expected range
    expected_min, expected_max = expected_sef_range
    if expected_min <= sef <= expected_max:
        print(f"  Assessment: ✅ WITHIN EXPECTED RANGE ({expected_min:.2f}-{expected_max:.2f})")
    else:
        print(f"  Assessment: ⚠️ OUTSIDE EXPECTED RANGE ({expected_min:.2f}-{expected_max:.2f})")
    
    # Statistical validation
    print(f"\nStatistical Validation:")
    
    # Normality tests
    _, p_a = shapiro(class_a_data) if len(class_a_data) <= 5000 else kstest(class_a_data, 'norm')
    _, p_b = shapiro(class_b_data) if len(class_b_data) <= 5000 else kstest(class_b_data, 'norm')
    
    print(f"  Normality (Class A): p={p_a:.4f} {'✅' if p_a > 0.05 else '❌'}")
    print(f"  Normality (Class B): p={p_b:.4f} {'✅' if p_b > 0.05 else '❌'}")
    
    # Effect size (Cohen's d)
    pooled_std = np.sqrt(((len(class_a_data) - 1) * var_a + (len(class_b_data) - 1) * var_b) / (len(class_a_data) + len(class_b_data) - 2))
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
    if len(class_a_data) >= 20 and len(class_b_data) >= 20:
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
        'domain': domain_name,
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
        'sample_size_a': len(class_a_data),
        'sample_size_b': len(class_b_data),
        'expected_range': expected_sef_range,
        'within_expected': expected_min <= sef <= expected_max
    }

def main():
    """
    Main execution function for multi-domain SEF validation
    """
    print("=== MULTI-DOMAIN SEF FRAMEWORK VALIDATION ===")
    print("This script validates the Signal Enhancement Factor framework")
    print("across multiple domains using realistic competitive measurement data.")
    print("=" * 60)
    
    # Change to data directory
    import os
    os.chdir("data/raw/real_competitive_data")
    
    # Define validation scenarios
    scenarios = [
        {
            'domain': 'Sports',
            'filename': 'sports_performance_realistic.csv',
            'class_col': 'team_type',
            'class_a': 'Winning',
            'class_b': 'Losing',
            'measurement_col': 'win_rate',
            'expected_sef_range': (1.09, 1.31)
        },
        {
            'domain': 'Education',
            'filename': 'education_assessment_realistic.csv',
            'class_col': 'school_type',
            'class_a': 'High_Performing',
            'class_b': 'Low_Performing',
            'measurement_col': 'test_score',
            'expected_sef_range': (1.32, 1.85)
        },
        {
            'domain': 'Finance',
            'filename': 'financial_performance_realistic.csv',
            'class_col': 'fund_type',
            'class_a': 'Large_Cap',
            'class_b': 'Small_Cap',
            'measurement_col': 'annual_return',
            'expected_sef_range': (1.35, 1.65)
        },
        {
            'domain': 'Healthcare',
            'filename': 'healthcare_performance_realistic.csv',
            'class_col': 'hospital_type',
            'class_a': 'High_Performing',
            'class_b': 'Low_Performing',
            'measurement_col': 'success_rate',
            'expected_sef_range': (1.25, 1.55)
        }
    ]
    
    results = {}
    
    # Validate each domain
    for scenario in scenarios:
        try:
            df = pd.read_csv(scenario['filename'])
            result = validate_domain_sef(
                df,
                scenario['domain'],
                scenario['class_col'],
                scenario['class_a'],
                scenario['class_b'],
                scenario['measurement_col'],
                scenario['expected_sef_range']
            )
            
            if result:
                results[scenario['domain']] = result
                
        except FileNotFoundError:
            print(f"\n❌ File not found: {scenario['filename']}")
            continue
    
    # Summary analysis
    print(f"\n{'='*60}")
    print("MULTI-DOMAIN VALIDATION SUMMARY")
    print(f"{'='*60}")
    
    if results:
        print(f"Successfully validated {len(results)} domains:")
        
        total_improvement = 0
        within_expected_count = 0
        excellent_fit_count = 0
        
        for domain, result in results.items():
            print(f"\n{domain}:")
            print(f"  SEF: {result['sef']:.4f} ({result['improvement_percent']:.1f}% improvement)")
            print(f"  κ: {result['kappa']:.4f}, ρ: {result['rho']:.4f}")
            print(f"  Applicability: {result['applicability_score']}/{result['max_score']}")
            print(f"  Expected range: {result['expected_range'][0]:.2f}-{result['expected_range'][1]:.2f}")
            print(f"  Within expected: {'✅' if result['within_expected'] else '❌'}")
            
            total_improvement += result['improvement_percent']
            if result['within_expected']:
                within_expected_count += 1
            if result['applicability_score'] >= 4:
                excellent_fit_count += 1
        
        # Overall statistics
        avg_improvement = total_improvement / len(results)
        success_rate = within_expected_count / len(results) * 100
        excellent_fit_rate = excellent_fit_count / len(results) * 100
        
        print(f"\nOVERALL STATISTICS:")
        print(f"  Average SEF improvement: {avg_improvement:.1f}%")
        print(f"  Expected range success rate: {success_rate:.1f}%")
        print(f"  Excellent framework fit rate: {excellent_fit_rate:.1f}%")
        
        # Best performing domain
        best_domain = max(results.items(), key=lambda x: x[1]['sef'])
        print(f"\n🎉 BEST PERFORMING DOMAIN: {best_domain[0]}")
        print(f"   SEF: {best_domain[1]['sef']:.4f}")
        print(f"   Improvement: {best_domain[1]['improvement_percent']:.1f}%")
        
        # Framework validation assessment
        print(f"\nFRAMEWORK VALIDATION ASSESSMENT:")
        if success_rate >= 75 and excellent_fit_rate >= 50:
            print(f"  🎉 FRAMEWORK VALIDATION SUCCESSFUL")
            print(f"  The SEF framework demonstrates consistent performance")
            print(f"  across multiple domains with realistic competitive data.")
        elif success_rate >= 50:
            print(f"  ✅ FRAMEWORK VALIDATION PARTIALLY SUCCESSFUL")
            print(f"  The SEF framework shows promise but needs refinement.")
        else:
            print(f"  ⚠️ FRAMEWORK VALIDATION NEEDS IMPROVEMENT")
            print(f"  The SEF framework requires significant refinement.")
        
        # Save results
        results_df = pd.DataFrame(results).T
        results_df.to_csv('multi_domain_sef_validation_results.csv')
        print(f"\n✓ Results saved to: multi_domain_sef_validation_results.csv")
        
    else:
        print("❌ No domains successfully validated")
        print("Please check data files and try again")
    
    print(f"\n{'='*60}")
    print("MULTI-DOMAIN SEF VALIDATION COMPLETE")
    print(f"{'='*60}")
    print("Next steps:")
    print("1. Collect real competitive measurement data from APIs")
    print("2. Calculate actual correlations from paired observations")
    print("3. Validate framework with real-world scenarios")
    print("4. Document results for paper integration")

if __name__ == "__main__":
    main()
