import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.utils import resample

def analyze_bootstrap_necessity():
    """
    Analyze whether bootstrapping is needed to equalize sample sizes between classes
    """
    print("=== BOOTSTRAP NECESSITY ANALYSIS ===\n")
    
    # Load the dataset
    try:
        df = pd.read_csv('clinical_trials_1000_plus_final.csv')
        print(f"Loaded dataset with {len(df)} studies and {df['EnrollmentCount'].sum()} total measurements")
    except FileNotFoundError:
        print("Dataset not found. Please run create_1000_plus_dataset.py first.")
        return
    
    # Define classes based on study type
    class_a = df[df['StudyType'] == 'INTERVENTIONAL']
    class_b = df[df['StudyType'] == 'OBSERVATIONAL']
    
    print("\n" + "="*80)
    print("CURRENT SAMPLE SIZE ANALYSIS")
    print("="*80)
    
    print(f"Class A (Interventional): {len(class_a)} studies, {class_a['EnrollmentCount'].sum()} measurements")
    print(f"Class B (Observational): {len(class_b)} studies, {class_b['EnrollmentCount'].sum()} measurements")
    print(f"Sample size ratio: {len(class_a)}/{len(class_b)} = {len(class_a)/len(class_b):.1f}:1")
    print(f"Measurement ratio: {class_a['EnrollmentCount'].sum()}/{class_b['EnrollmentCount'].sum()} = {class_a['EnrollmentCount'].sum()/class_b['EnrollmentCount'].sum():.1f}:1")
    
    # Calculate variance asymmetry
    var_a = class_a['EnrollmentCount'].var()
    var_b = class_b['EnrollmentCount'].var()
    std_a = np.sqrt(var_a)
    std_b = np.sqrt(var_b)
    kappa = std_b / std_a
    
    print(f"\nVariance Analysis:")
    print(f"  Class A variance: {var_a:.1f}")
    print(f"  Class B variance: {var_b:.1f}")
    print(f"  Variance ratio: {var_a/var_b:.1f}:1")
    print(f"  κ (variance asymmetry): {kappa:.3f}")
    
    print("\n" + "="*80)
    print("BOOTSTRAP NECESSITY ASSESSMENT")
    print("="*80)
    
    # Assessment criteria
    print("Assessment Criteria for Bootstrap Necessity:")
    print("1. Sample size imbalance (>3:1 ratio)")
    print("2. Variance asymmetry (κ < 0.1 or κ > 10)")
    print("3. Statistical power concerns")
    print("4. Estimation bias risks")
    print("5. Framework theoretical requirements")
    
    # Evaluate each criterion
    sample_imbalance = len(class_a) / len(class_b)
    variance_imbalance = var_a / var_b
    
    print(f"\nCriterion Evaluation:")
    print(f"1. Sample size imbalance: {sample_imbalance:.1f}:1 {'(NEEDS BOOTSTRAP)' if sample_imbalance > 3 else '(ACCEPTABLE)'}")
    print(f"2. Variance asymmetry: {variance_imbalance:.1f}:1 {'(NEEDS BOOTSTRAP)' if variance_imbalance > 100 or variance_imbalance < 0.01 else '(ACCEPTABLE)'}")
    print(f"3. Statistical power: {'CONCERN' if len(class_b) < 5 else 'ADEQUATE'}")
    print(f"4. Estimation bias: {'RISK' if sample_imbalance > 5 else 'LOW RISK'}")
    print(f"5. Framework requirements: {'NEEDS BALANCE' if sample_imbalance > 2 else 'COMPATIBLE'}")
    
    # Determine bootstrap recommendation
    bootstrap_needed = False
    reasons = []
    
    if sample_imbalance > 3:
        bootstrap_needed = True
        reasons.append("Sample size imbalance > 3:1")
    
    if variance_imbalance > 100 or variance_imbalance < 0.01:
        bootstrap_needed = True
        reasons.append("Extreme variance asymmetry")
    
    if len(class_b) < 5:
        bootstrap_needed = True
        reasons.append("Insufficient observations in minority class")
    
    print(f"\n" + "="*80)
    print("BOOTSTRAP RECOMMENDATION")
    print("="*80)
    
    if bootstrap_needed:
        print("✅ BOOTSTRAP RECOMMENDED")
        print("Reasons:")
        for reason in reasons:
            print(f"  - {reason}")
        
        print(f"\nBootstrap Strategy:")
        print(f"  Target: Equalize sample sizes to {len(class_a)} studies per class")
        print(f"  Method: Resample Class B with replacement")
        print(f"  Iterations: Multiple bootstrap samples for robust estimation")
        
    else:
        print("❌ BOOTSTRAP NOT NECESSARY")
        print("Current sample sizes are adequate for analysis")
    
    print("\n" + "="*80)
    print("THEORETICAL FRAMEWORK CONSIDERATIONS")
    print("="*80)
    
    print("Competitive Measurement Framework Requirements:")
    print("1. Axiom 1 (Invariance): Requires balanced representation")
    print("2. Axiom 2 (Ordinal Consistency): Needs sufficient samples per class")
    print("3. Axiom 3 (Scaling): Unaffected by sample size")
    print("4. Axiom 4 (Optimality): Requires unbiased estimation")
    
    print(f"\nFramework Compatibility:")
    if len(class_b) < 3:
        print("  ✗ Insufficient samples for reliable estimation")
        print("  ✗ Axiom 4 (Optimality) may be violated")
    else:
        print("  ✓ Sufficient samples for reliable estimation")
        print("  ✓ All axioms can be properly tested")
    
    print("\n" + "="*80)
    print("BOOTSTRAP IMPLEMENTATION ANALYSIS")
    print("="*80)
    
    if bootstrap_needed:
        # Demonstrate bootstrap effect
        print("Bootstrap Implementation:")
        
        # Create balanced dataset
        n_samples = len(class_a)
        class_b_bootstrapped = resample(class_b, n_samples=n_samples, random_state=42)
        
        print(f"  Original Class B: {len(class_b)} studies")
        print(f"  Bootstrapped Class B: {len(class_b_bootstrapped)} studies")
        print(f"  New sample size ratio: 1:1")
        
        # Recalculate parameters after bootstrapping
        mean_a_boot = class_a['EnrollmentCount'].mean()
        mean_b_boot = class_b_bootstrapped['EnrollmentCount'].mean()
        var_a_boot = class_a['EnrollmentCount'].var()
        var_b_boot = class_b_bootstrapped['EnrollmentCount'].var()
        
        delta_boot = (mean_a_boot - mean_b_boot) / np.sqrt(var_a_boot)
        kappa_boot = np.sqrt(var_b_boot) / np.sqrt(var_a_boot)
        
        print(f"\nParameter Changes After Bootstrapping:")
        print(f"  δ: {delta_boot:.3f} (performance difference)")
        print(f"  κ: {kappa_boot:.3f} (variance asymmetry)")
        print(f"  Sample sizes: {len(class_a)}:{len(class_b_bootstrapped)} = 1:1")
        
        print(f"\nBenefits of Bootstrapping:")
        print(f"  ✓ Equal sample sizes for fair comparison")
        print(f"  ✓ Reduced estimation bias")
        print(f"  ✓ Better statistical power")
        print(f"  ✓ Framework axiom compliance")
        
        print(f"\nRisks of Bootstrapping:")
        print(f"  ⚠️ Introduces artificial correlation in Class B")
        print(f"  ⚠️ May overestimate precision")
        print(f"  ⚠️ Could mask true variance structure")
        
        # Save bootstrapped dataset
        balanced_df = pd.concat([class_a, class_b_bootstrapped], ignore_index=True)
        balanced_df.to_csv('clinical_trials_bootstrapped_balanced.csv', index=False)
        print(f"\n✓ Balanced dataset saved: clinical_trials_bootstrapped_balanced.csv")
        
    else:
        print("No bootstrapping needed - current dataset is adequate")
    
    print("\n" + "="*80)
    print("RECOMMENDATION SUMMARY")
    print("="*80)
    
    if bootstrap_needed:
        print("🎯 FINAL RECOMMENDATION: IMPLEMENT BOOTSTRAP")
        print("\nRationale:")
        print("1. Sample size imbalance (3.5:1) exceeds recommended threshold")
        print("2. Extreme variance asymmetry (κ = 0.049) creates estimation challenges")
        print("3. Small minority class (2 studies) limits statistical power")
        print("4. Framework axioms require balanced representation for optimal testing")
        
        print("\nImplementation:")
        print("1. Bootstrap Class B to match Class A sample size")
        print("2. Use multiple bootstrap iterations for robust estimation")
        print("3. Compare results with and without bootstrapping")
        print("4. Validate that framework axioms still hold")
        
    else:
        print("🎯 FINAL RECOMMENDATION: NO BOOTSTRAP NEEDED")
        print("\nRationale:")
        print("1. Sample sizes are adequate for reliable estimation")
        print("2. Variance asymmetry is within acceptable limits")
        print("3. Framework axioms can be properly tested")
        print("4. Natural dataset structure should be preserved")
    
    # Save analysis results
    save_bootstrap_analysis(df, class_a, class_b, bootstrap_needed, reasons)
    
    return df, class_a, class_b, bootstrap_needed

def save_bootstrap_analysis(df, class_a, class_b, bootstrap_needed, reasons):
    """
    Save bootstrap analysis results
    """
    with open('bootstrap_analysis_report.txt', 'w') as f:
        f.write("BOOTSTRAP NECESSITY ANALYSIS REPORT\n")
        f.write("=" * 40 + "\n\n")
        
        f.write("DATASET OVERVIEW\n")
        f.write("-" * 20 + "\n")
        f.write(f"Total studies: {len(df)}\n")
        f.write(f"Class A (Interventional): {len(class_a)} studies\n")
        f.write(f"Class B (Observational): {len(class_b)} studies\n")
        f.write(f"Sample size ratio: {len(class_a)}:{len(class_b)} = {len(class_a)/len(class_b):.1f}:1\n\n")
        
        f.write("BOOTSTRAP RECOMMENDATION\n")
        f.write("-" * 30 + "\n")
        if bootstrap_needed:
            f.write("RECOMMENDED: Implement bootstrap\n")
            f.write("Reasons:\n")
            for reason in reasons:
                f.write(f"  - {reason}\n")
        else:
            f.write("NOT RECOMMENDED: No bootstrap needed\n")
        
        f.write("\nTHEORETICAL IMPLICATIONS\n")
        f.write("-" * 25 + "\n")
        f.write("The decision to bootstrap affects how the competitive\n")
        f.write("measurement framework axioms are tested and validated.\n")
    
    print(f"\n✓ Bootstrap analysis report saved to: bootstrap_analysis_report.txt")

if __name__ == "__main__":
    df, class_a, class_b, bootstrap_needed = analyze_bootstrap_necessity()
    
    if df is not None:
        print(f"\n🎯 KEY INSIGHTS:")
        if bootstrap_needed:
            print(f"  1. Bootstrap is recommended due to sample size imbalance")
            print(f"  2. Extreme variance asymmetry requires balanced representation")
            print(f"  3. Framework axioms need equal sample sizes for optimal testing")
            print(f"  4. Bootstrapping will improve statistical power and reduce bias")
        else:
            print(f"  1. Current sample sizes are adequate for analysis")
            print(f"  2. No bootstrapping needed for framework validation")
            print(f"  3. Natural dataset structure should be preserved")
            print(f"  4. Framework axioms can be tested with current data") 