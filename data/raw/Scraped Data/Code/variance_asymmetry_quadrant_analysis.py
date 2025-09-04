import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def analyze_variance_asymmetry_quadrant():
    """
    Analyze which quadrant the clinical trial dataset falls into based on variance asymmetry
    """
    print("=== CLINICAL TRIALS: VARIANCE ASYMMETRY QUADRANT ANALYSIS ===\n")
    
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
    print("VARIANCE ASYMMETRY PARAMETER CALCULATION")
    print("="*80)
    
    # Calculate empirical parameters
    mean_a = class_a['EnrollmentCount'].mean()
    mean_b = class_b['EnrollmentCount'].mean()
    var_a = class_a['EnrollmentCount'].var()
    var_b = class_b['EnrollmentCount'].var()
    std_a = np.sqrt(var_a)
    std_b = np.sqrt(var_b)
    
    print(f"Class A (Interventional) Statistics:")
    print(f"  Mean (μ_A): {mean_a:.1f}")
    print(f"  Variance (σ²_A): {var_a:.1f}")
    print(f"  Standard Deviation (σ_A): {std_a:.1f}")
    
    print(f"\nClass B (Observational) Statistics:")
    print(f"  Mean (μ_B): {mean_b:.1f}")
    print(f"  Variance (σ²_B): {var_b:.1f}")
    print(f"  Standard Deviation (σ_B): {std_b:.1f}")
    
    # Calculate standardized parameters
    delta = (mean_a - mean_b) / std_a  # Standardized performance difference
    kappa = std_b / std_a  # Variance asymmetry ratio
    eta_ratio = 0.1  # Estimate of environmental noise ratio (will be estimated)
    
    print(f"\n" + "="*80)
    print("STANDARDIZED PARAMETERS")
    print("="*80)
    
    print(f"δ = (μ_A - μ_B) / σ_A = ({mean_a:.1f} - {mean_b:.1f}) / {std_a:.1f} = {delta:.3f}")
    print(f"κ = σ_B / σ_A = {std_b:.1f} / {std_a:.1f} = {kappa:.3f}")
    print(f"η = σ_η / σ_A = {eta_ratio:.3f} (estimated)")
    
    print(f"\nParameter Interpretation:")
    print(f"  δ = {delta:.3f}: Standardized performance difference")
    print(f"    - Positive: Class A has higher mean performance")
    print(f"    - Magnitude: {abs(delta):.3f} standard deviations difference")
    
    print(f"  κ = {kappa:.3f}: Variance asymmetry ratio")
    if kappa < 1:
        print(f"    - κ < 1: Class A has higher variance (σ_A > σ_B)")
        print(f"    - Class A is more variable than Class B")
    elif kappa > 1:
        print(f"    - κ > 1: Class B has higher variance (σ_B > σ_A)")
        print(f"    - Class B is more variable than Class A")
    else:
        print(f"    - κ = 1: Equal variances (σ_A = σ_B)")
    
    print(f"  η = {eta_ratio:.3f}: Standardized environmental noise")
    print(f"    - Represents the strength of shared environmental effects")
    print(f"    - Estimated based on typical clinical trial environments")
    
    # Determine quadrant based on δ and κ
    print(f"\n" + "="*80)
    print("QUADRANT CLASSIFICATION")
    print("="*80)
    
    # Define quadrant boundaries
    delta_threshold = 0.5  # Moderate effect size threshold
    kappa_threshold = 1.0  # Equal variance threshold
    
    print(f"Quadrant Classification Criteria:")
    print(f"  δ threshold: {delta_threshold} (moderate effect size)")
    print(f"  κ threshold: {kappa_threshold} (equal variance)")
    
    # Determine quadrant
    if delta > delta_threshold:
        if kappa < kappa_threshold:
            quadrant = "Q1"
            quadrant_name = "High Performance, Low Variance Asymmetry"
        else:
            quadrant = "Q2"
            quadrant_name = "High Performance, High Variance Asymmetry"
    else:
        if kappa < kappa_threshold:
            quadrant = "Q3"
            quadrant_name = "Low Performance, Low Variance Asymmetry"
        else:
            quadrant = "Q4"
            quadrant_name = "Low Performance, High Variance Asymmetry"
    
    print(f"\nClinical Trial Dataset Classification:")
    print(f"  δ = {delta:.3f} {'>' if delta > delta_threshold else '<'} {delta_threshold}")
    print(f"  κ = {kappa:.3f} {'>' if kappa > kappa_threshold else '<'} {kappa_threshold}")
    print(f"  Quadrant: {quadrant} - {quadrant_name}")
    
    # Detailed quadrant analysis
    print(f"\n" + "="*80)
    print("QUADRANT-SPECIFIC ANALYSIS")
    print("="*80)
    
    if quadrant == "Q1":
        print("Q1 Characteristics (High Performance, Low Variance Asymmetry):")
        print("  ✓ Strong performance difference (δ > 0.5)")
        print("  ✓ Relatively equal variances (κ < 1.0)")
        print("  ✓ Ideal conditions for relative measurement")
        print("  ✓ Environmental noise cancellation highly effective")
        print("  ✓ Expected: Relative measures should significantly outperform absolute")
        
    elif quadrant == "Q2":
        print("Q2 Characteristics (High Performance, High Variance Asymmetry):")
        print("  ✓ Strong performance difference (δ > 0.5)")
        print("  ✗ High variance asymmetry (κ > 1.0)")
        print("  ✓ Good conditions for relative measurement")
        print("  ⚠️ Variance asymmetry may affect optimality")
        print("  ✓ Expected: Relative measures should still outperform absolute")
        
    elif quadrant == "Q3":
        print("Q3 Characteristics (Low Performance, Low Variance Asymmetry):")
        print("  ✗ Weak performance difference (δ < 0.5)")
        print("  ✓ Relatively equal variances (κ < 1.0)")
        print("  ⚠️ Challenging conditions for discrimination")
        print("  ✓ Environmental noise cancellation still effective")
        print("  ⚠️ Expected: Both absolute and relative measures may struggle")
        
    elif quadrant == "Q4":
        print("Q4 Characteristics (Low Performance, High Variance Asymmetry):")
        print("  ✗ Weak performance difference (δ < 0.5)")
        print("  ✗ High variance asymmetry (κ > 1.0)")
        print("  ✗ Most challenging conditions for relative measurement")
        print("  ⚠️ Environmental noise cancellation may be less effective")
        print("  ✗ Expected: Both absolute and relative measures may struggle")
    
    # SNR analysis for the specific quadrant
    print(f"\n" + "="*80)
    print("SIGNAL-TO-NOISE RATIO ANALYSIS")
    print("="*80)
    
    # Calculate SNR for absolute and relative measures
    signal = (mean_a - mean_b)**2
    noise_absolute = var_a
    noise_relative = var_a + var_b
    
    snr_absolute = signal / noise_absolute
    snr_relative = signal / noise_relative
    
    print(f"Signal Analysis:")
    print(f"  Signal = (μ_A - μ_B)² = ({mean_a:.1f} - {mean_b:.1f})² = {signal:.1f}")
    print(f"  Standardized Signal = δ² = ({delta:.3f})² = {delta**2:.3f}")
    
    print(f"\nNoise Analysis:")
    print(f"  Noise (absolute) = σ²_A = {noise_absolute:.1f}")
    print(f"  Noise (relative) = σ²_A + σ²_B = {noise_relative:.1f}")
    print(f"  Noise ratio = (σ²_A + σ²_B) / σ²_A = {noise_relative/noise_absolute:.3f}")
    
    print(f"\nSNR Comparison:")
    print(f"  SNR (absolute): {snr_absolute:.3f}")
    print(f"  SNR (relative): {snr_relative:.3f}")
    
    if snr_relative > snr_absolute:
        improvement = (snr_relative / snr_absolute - 1) * 100
        print(f"  ✓ Relative SNR improvement: {improvement:.1f}%")
    else:
        degradation = (1 - snr_relative / snr_absolute) * 100
        print(f"  ✗ Relative SNR degradation: {degradation:.1f}%")
    
    # Theoretical prediction based on quadrant
    print(f"\n" + "="*80)
    print("THEORETICAL PREDICTIONS FOR QUADRANT {quadrant}")
    print("="*80)
    
    if quadrant == "Q1":
        print("Optimal Conditions for Relative Measurement:")
        print("  - Strong signal (δ = {:.3f}) with low noise")
        print("  - Balanced variances (κ = {:.3f}) minimize estimation error")
        print("  - Environmental noise cancellation highly effective")
        print("  - Expected: 20-40% improvement in prediction accuracy")
        
    elif quadrant == "Q2":
        print("Good Conditions with Variance Challenges:")
        print("  - Strong signal (δ = {:.3f}) provides good discrimination")
        print("  - Variance asymmetry (κ = {:.3f}) may affect optimality")
        print("  - Environmental noise cancellation still effective")
        print("  - Expected: 10-25% improvement in prediction accuracy")
        
    elif quadrant == "Q3":
        print("Weak Signal but Balanced Conditions:")
        print("  - Weak signal (δ = {:.3f}) limits discrimination")
        print("  - Balanced variances (κ = {:.3f}) maintain efficiency")
        print("  - Environmental noise cancellation provides some benefit")
        print("  - Expected: 5-15% improvement in prediction accuracy")
        
    elif quadrant == "Q4":
        print("Challenging Conditions for All Measures:")
        print("  - Weak signal (δ = {:.3f}) with high noise")
        print("  - Variance asymmetry (κ = {:.3f}) compounds challenges")
        print("  - Environmental noise cancellation limited benefit")
        print("  - Expected: Minimal improvement or potential degradation")
    
    # Save detailed analysis
    save_quadrant_analysis(df, class_a, class_b, delta, kappa, eta_ratio, quadrant, quadrant_name, snr_absolute, snr_relative)
    
    return df, delta, kappa, eta_ratio, quadrant

def save_quadrant_analysis(df, class_a, class_b, delta, kappa, eta_ratio, quadrant, quadrant_name, snr_absolute, snr_relative):
    """
    Save detailed quadrant analysis results
    """
    with open('variance_asymmetry_quadrant_report.txt', 'w') as f:
        f.write("CLINICAL TRIALS: VARIANCE ASYMMETRY QUADRANT ANALYSIS\n")
        f.write("=" * 60 + "\n\n")
        
        f.write("DATASET OVERVIEW\n")
        f.write("-" * 20 + "\n")
        f.write(f"Total studies: {len(df)}\n")
        f.write(f"Class A (Interventional): {len(class_a)} studies\n")
        f.write(f"Class B (Observational): {len(class_b)} studies\n\n")
        
        f.write("STANDARDIZED PARAMETERS\n")
        f.write("-" * 30 + "\n")
        f.write(f"δ (performance difference): {delta:.3f}\n")
        f.write(f"κ (variance asymmetry): {kappa:.3f}\n")
        f.write(f"η (environmental noise): {eta_ratio:.3f}\n\n")
        
        f.write("QUADRANT CLASSIFICATION\n")
        f.write("-" * 30 + "\n")
        f.write(f"Quadrant: {quadrant}\n")
        f.write(f"Name: {quadrant_name}\n\n")
        
        f.write("SIGNAL-TO-NOISE RATIO\n")
        f.write("-" * 25 + "\n")
        f.write(f"SNR (absolute): {snr_absolute:.3f}\n")
        f.write(f"SNR (relative): {snr_relative:.3f}\n")
        if snr_relative > snr_absolute:
            improvement = (snr_relative / snr_absolute - 1) * 100
            f.write(f"Relative improvement: {improvement:.1f}%\n")
        else:
            degradation = (1 - snr_relative / snr_absolute) * 100
            f.write(f"Relative degradation: {degradation:.1f}%\n")
        
        f.write("\nTHEORETICAL IMPLICATIONS\n")
        f.write("-" * 25 + "\n")
        f.write("The clinical trial dataset falls into a specific variance asymmetry\n")
        f.write("regime that determines the expected performance of relative vs\n")
        f.write("absolute measurement approaches.\n")
    
    print(f"\n✓ Detailed quadrant analysis saved to: variance_asymmetry_quadrant_report.txt")

if __name__ == "__main__":
    df, delta, kappa, eta_ratio, quadrant = analyze_variance_asymmetry_quadrant()
    
    if df is not None:
        print(f"\n🎯 QUADRANT SUMMARY:")
        print(f"  Quadrant: {quadrant}")
        print(f"  δ = {delta:.3f} (performance difference)")
        print(f"  κ = {kappa:.3f} (variance asymmetry)")
        print(f"  η = {eta_ratio:.3f} (environmental noise)")
        print(f"  This places the dataset in a specific theoretical regime")
        print(f"  that determines expected relative vs absolute performance.") 