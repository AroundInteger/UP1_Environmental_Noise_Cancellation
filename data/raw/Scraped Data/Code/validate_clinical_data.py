import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import shapiro, normaltest, jarque_bera
import json

def validate_clinical_data():
    """
    Validate clinical trial data for competitive measurement framework requirements
    """
    print("=== CLINICAL DATA VALIDATION ===\n")
    
    # Load the clinical trial data
    try:
        # Try to load the 1000+ measurement dataset first
        df = pd.read_csv('clinical_trials_1000_plus_final.csv')
        print(f"Loaded {len(df)} clinical trials from 1000+ measurement dataset")
    except FileNotFoundError:
        try:
            # Fallback to original dataset
            df = pd.read_csv('clinical_trials_diabetes_working.csv')
            print(f"Loaded {len(df)} clinical trials from original dataset")
        except FileNotFoundError:
            print("No clinical trial CSV file found. Please run create_1000_plus_dataset.py first.")
            return
    
    # Display basic data info
    print("\nData Overview:")
    print("=" * 50)
    print(f"Number of trials: {len(df)}")
    print(f"Columns: {list(df.columns)}")
    print("\nFirst few rows:")
    print(df.head())
    
    # Step 1: Check data completeness and quality
    print("\n" + "=" * 50)
    print("STEP 1: DATA COMPLETENESS AND QUALITY")
    print("=" * 50)
    
    # Check for missing values
    missing_data = df.isnull().sum()
    print(f"\nMissing values per column:")
    for col, missing in missing_data.items():
        print(f"  {col}: {missing}")
    
    # Check data types
    print(f"\nData types:")
    for col, dtype in df.dtypes.items():
        print(f"  {col}: {dtype}")
    
    # Step 2: Analyze enrollment counts (our main numerical variable)
    print("\n" + "=" * 50)
    print("STEP 2: ENROLLMENT COUNT ANALYSIS")
    print("=" * 50)
    
    # Convert enrollment counts to numeric
    enrollment_counts = pd.to_numeric(df['EnrollmentCount'], errors='coerce')
    valid_enrollments = enrollment_counts.dropna()
    
    print(f"\nEnrollment count statistics:")
    print(f"  Valid counts: {len(valid_enrollments)}")
    print(f"  Mean: {valid_enrollments.mean():.1f}")
    print(f"  Median: {valid_enrollments.median():.1f}")
    print(f"  Std: {valid_enrollments.std():.1f}")
    print(f"  Min: {valid_enrollments.min()}")
    print(f"  Max: {valid_enrollments.max()}")
    print(f"  Range: {valid_enrollments.max() - valid_enrollments.min()}")
    
    # Step 3: Test for normal distribution
    print("\n" + "=" * 50)
    print("STEP 3: NORMALITY TESTS")
    print("=" * 50)
    
    normality_results = test_normality(valid_enrollments)
    
    for test_name, result in normality_results.items():
        print(f"\n{test_name}:")
        print(f"  Statistic: {result['statistic']:.4f}")
        print(f"  P-value: {result['p_value']:.4f}")
        print(f"  Normal distribution: {'Yes' if result['p_value'] > 0.05 else 'No'}")
    
    # Step 4: Check variance computability
    print("\n" + "=" * 50)
    print("STEP 4: VARIANCE COMPUTABILITY")
    print("=" * 50)
    
    variance_analysis = analyze_variance(valid_enrollments)
    
    print(f"Variance analysis:")
    print(f"  Sample variance: {variance_analysis['sample_variance']:.2f}")
    print(f"  Coefficient of variation: {variance_analysis['cv']:.3f}")
    print(f"  Variance stable: {variance_analysis['variance_stable']}")
    print(f"  Sufficient data points: {variance_analysis['sufficient_data']}")
    
    # Step 5: Assess binary outcome prediction suitability
    print("\n" + "=" * 50)
    print("STEP 5: BINARY OUTCOME PREDICTION SUITABILITY")
    print("=" * 50)
    
    binary_analysis = assess_binary_prediction_suitability(df, valid_enrollments)
    
    print(f"Binary prediction analysis:")
    print(f"  Study types available: {binary_analysis['study_types']}")
    print(f"  Conditions available: {binary_analysis['conditions']}")
    print(f"  Can create binary outcomes: {binary_analysis['can_create_binary']}")
    print(f"  Suggested binary outcomes: {binary_analysis['suggested_outcomes']}")
    
    # Step 6: Generate visualizations
    print("\n" + "=" * 50)
    print("STEP 6: GENERATING VISUALIZATIONS")
    print("=" * 50)
    
    create_validation_plots(df, valid_enrollments, normality_results)
    
    # Step 7: Overall assessment
    print("\n" + "=" * 50)
    print("STEP 7: OVERALL ASSESSMENT")
    print("=" * 50)
    
    overall_assessment = generate_overall_assessment(normality_results, variance_analysis, binary_analysis)
    
    print(f"\nOverall assessment:")
    print(f"  Data quality score: {overall_assessment['quality_score']:.1f}/10")
    print(f"  Framework suitability: {overall_assessment['framework_suitable']}")
    print(f"  Recommendations: {overall_assessment['recommendations']}")
    
    # Save detailed report
    save_validation_report(df, normality_results, variance_analysis, binary_analysis, overall_assessment)
    
    print(f"\n✓ Validation complete! Check 'clinical_data_validation_report.txt' for details.")
    print(f"✓ Visualizations saved to 'clinical_data_validation_plots.png'")

def test_normality(data):
    """
    Test data for normal distribution using multiple tests
    """
    results = {}
    
    # Shapiro-Wilk test (most reliable for small samples)
    if len(data) >= 3 and len(data) <= 5000:
        shapiro_stat, shapiro_p = shapiro(data)
        results['Shapiro-Wilk'] = {
            'statistic': shapiro_stat,
            'p_value': shapiro_p
        }
    
    # D'Agostino K^2 test
    if len(data) >= 8:
        dagostino_stat, dagostino_p = normaltest(data)
        results["D'Agostino K²"] = {
            'statistic': dagostino_stat,
            'p_value': dagostino_p
        }
    
    # Jarque-Bera test
    if len(data) >= 8:
        jb_stat, jb_p = jarque_bera(data)
        results['Jarque-Bera'] = {
            'statistic': jb_stat,
            'p_value': jb_p
        }
    
    return results

def analyze_variance(data):
    """
    Analyze variance computability and stability
    """
    sample_variance = data.var()
    cv = data.std() / data.mean() if data.mean() != 0 else float('inf')
    
    # Check if variance is stable (CV < 1 is generally considered stable)
    variance_stable = cv < 1.0
    
    # Check if we have sufficient data points for reliable variance
    sufficient_data = len(data) >= 3
    
    return {
        'sample_variance': sample_variance,
        'cv': cv,
        'variance_stable': variance_stable,
        'sufficient_data': sufficient_data
    }

def assess_binary_prediction_suitability(df, enrollment_data):
    """
    Assess suitability for binary outcome prediction
    """
    study_types = df['StudyType'].unique().tolist()
    conditions = df['Condition'].unique().tolist()
    
    # Check if we can create meaningful binary outcomes
    can_create_binary = len(study_types) >= 2 or len(conditions) >= 2
    
    # Suggest possible binary outcomes
    suggested_outcomes = []
    
    if len(study_types) >= 2:
        suggested_outcomes.append("Interventional vs Observational")
    
    if len(conditions) >= 2:
        suggested_outcomes.append("Diabetes-related vs Other conditions")
    
    if len(enrollment_data) >= 4:
        median_enrollment = enrollment_data.median()
        suggested_outcomes.append(f"High enrollment (>={median_enrollment:.0f}) vs Low enrollment")
    
    return {
        'study_types': study_types,
        'conditions': conditions,
        'can_create_binary': can_create_binary,
        'suggested_outcomes': suggested_outcomes
    }

def create_validation_plots(df, enrollment_data, normality_results):
    """
    Create validation plots
    """
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Clinical Trial Data Validation', fontsize=16)
    
    # Plot 1: Enrollment count distribution
    axes[0, 0].hist(enrollment_data, bins=10, alpha=0.7, color='skyblue', edgecolor='black')
    axes[0, 0].set_title('Enrollment Count Distribution')
    axes[0, 0].set_xlabel('Enrollment Count')
    axes[0, 0].set_ylabel('Frequency')
    axes[0, 0].grid(True, alpha=0.3)
    
    # Plot 2: Q-Q plot for normality
    stats.probplot(enrollment_data, dist="norm", plot=axes[0, 1])
    axes[0, 1].set_title('Q-Q Plot (Normal Distribution)')
    axes[0, 1].grid(True, alpha=0.3)
    
    # Plot 3: Box plot
    axes[0, 2].boxplot(enrollment_data)
    axes[0, 2].set_title('Enrollment Count Box Plot')
    axes[0, 2].set_ylabel('Enrollment Count')
    axes[0, 2].grid(True, alpha=0.3)
    
    # Plot 4: Study type distribution
    study_type_counts = df['StudyType'].value_counts()
    axes[1, 0].bar(study_type_counts.index, study_type_counts.values, color='lightcoral')
    axes[1, 0].set_title('Study Type Distribution')
    axes[1, 0].set_ylabel('Count')
    axes[1, 0].tick_params(axis='x', rotation=45)
    
    # Plot 5: Condition distribution
    condition_counts = df['Condition'].value_counts()
    axes[1, 1].bar(range(len(condition_counts)), condition_counts.values, color='lightgreen')
    axes[1, 1].set_title('Condition Distribution')
    axes[1, 1].set_ylabel('Count')
    axes[1, 1].set_xticks(range(len(condition_counts)))
    axes[1, 1].set_xticklabels(condition_counts.index, rotation=45, ha='right')
    
    # Plot 6: Summary statistics
    axes[1, 2].axis('off')
    stats_text = f"""
    Sample Size: {len(enrollment_data)}
    Mean: {enrollment_data.mean():.1f}
    Median: {enrollment_data.median():.1f}
    Std Dev: {enrollment_data.std():.1f}
    Min: {enrollment_data.min()}
    Max: {enrollment_data.max()}
    """
    axes[1, 2].text(0.1, 0.5, stats_text, fontsize=12, verticalalignment='center')
    axes[1, 2].set_title('Summary Statistics')
    
    plt.tight_layout()
    plt.savefig('clinical_data_validation_plots.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print("  Validation plots saved to 'clinical_data_validation_plots.png'")

def generate_overall_assessment(normality_results, variance_analysis, binary_analysis):
    """
    Generate overall assessment of data suitability
    """
    quality_score = 0
    recommendations = []
    
    # Assess normality (0-3 points)
    normal_tests = 0
    for test_name, result in normality_results.items():
        if result['p_value'] > 0.05:
            normal_tests += 1
    
    if normal_tests >= 2:
        quality_score += 3
    elif normal_tests >= 1:
        quality_score += 2
        recommendations.append("Data shows some deviation from normality")
    else:
        recommendations.append("Data significantly deviates from normality - consider transformations")
    
    # Assess variance (0-3 points)
    if variance_analysis['variance_stable']:
        quality_score += 2
    else:
        recommendations.append("High variance instability - may affect framework performance")
    
    if variance_analysis['sufficient_data']:
        quality_score += 1
    else:
        recommendations.append("Insufficient data points for reliable variance estimation")
    
    # Assess binary prediction (0-4 points)
    if binary_analysis['can_create_binary']:
        quality_score += 3
    else:
        recommendations.append("Limited ability to create meaningful binary outcomes")
    
    if len(binary_analysis['suggested_outcomes']) >= 2:
        quality_score += 1
    else:
        recommendations.append("Limited binary outcome options available")
    
    # Determine framework suitability
    framework_suitable = quality_score >= 6
    
    if not recommendations:
        recommendations.append("Data appears suitable for competitive measurement framework")
    
    return {
        'quality_score': quality_score,
        'framework_suitable': framework_suitable,
        'recommendations': recommendations
    }

def save_validation_report(df, normality_results, variance_analysis, binary_analysis, overall_assessment):
    """
    Save detailed validation report
    """
    with open('clinical_data_validation_report.txt', 'w') as f:
        f.write("CLINICAL TRIAL DATA VALIDATION REPORT\n")
        f.write("=====================================\n\n")
        
        f.write("Data Source: ClinicalTrials.gov API v2.0\n")
        f.write(f"Validation Date: {pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        f.write("DATA OVERVIEW\n")
        f.write("-------------\n")
        f.write(f"Number of trials: {len(df)}\n")
        f.write(f"Columns: {', '.join(df.columns)}\n\n")
        
        f.write("NORMALITY TESTS\n")
        f.write("---------------\n")
        for test_name, result in normality_results.items():
            f.write(f"{test_name}:\n")
            f.write(f"  Statistic: {result['statistic']:.4f}\n")
            f.write(f"  P-value: {result['p_value']:.4f}\n")
            f.write(f"  Normal distribution: {'Yes' if result['p_value'] > 0.05 else 'No'}\n\n")
        
        f.write("VARIANCE ANALYSIS\n")
        f.write("-----------------\n")
        f.write(f"Sample variance: {variance_analysis['sample_variance']:.2f}\n")
        f.write(f"Coefficient of variation: {variance_analysis['cv']:.3f}\n")
        f.write(f"Variance stable: {variance_analysis['variance_stable']}\n")
        f.write(f"Sufficient data points: {variance_analysis['sufficient_data']}\n\n")
        
        f.write("BINARY PREDICTION ANALYSIS\n")
        f.write("-------------------------\n")
        f.write(f"Study types: {', '.join(binary_analysis['study_types'])}\n")
        f.write(f"Conditions: {', '.join(binary_analysis['conditions'])}\n")
        f.write(f"Can create binary outcomes: {binary_analysis['can_create_binary']}\n")
        f.write(f"Suggested outcomes: {', '.join(binary_analysis['suggested_outcomes'])}\n\n")
        
        f.write("OVERALL ASSESSMENT\n")
        f.write("------------------\n")
        f.write(f"Quality score: {overall_assessment['quality_score']:.1f}/10\n")
        f.write(f"Framework suitable: {overall_assessment['framework_suitable']}\n")
        f.write("Recommendations:\n")
        for rec in overall_assessment['recommendations']:
            f.write(f"  - {rec}\n")
    
    print("  Detailed report saved to 'clinical_data_validation_report.txt'")

if __name__ == "__main__":
    validate_clinical_data() 