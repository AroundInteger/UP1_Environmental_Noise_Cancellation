import pandas as pd
import numpy as np

def clean_final_dataset():
    """
    Clean the final clinical trial dataset for framework integration
    """
    print("=== CLEANING FINAL CLINICAL TRIAL DATASET ===\n")
    
    # Load the final dataset
    try:
        df = pd.read_csv('clinical_trials_final_10_studies.csv')
        print(f"Loaded dataset with {len(df)} rows")
    except FileNotFoundError:
        print("Final dataset not found. Please run fetch_final_clinical_trials.py first.")
        return
    
    # Display initial summary
    print(f"Initial measurements: {df['EnrollmentCount'].sum()}")
    print(f"Initial studies: {len(df)}")
    
    # Remove duplicates
    print("\nRemoving duplicates...")
    initial_count = len(df)
    df_clean = df.drop_duplicates(subset=['NCTId'])
    final_count = len(df_clean)
    removed_count = initial_count - final_count
    
    print(f"  Removed {removed_count} duplicate studies")
    print(f"  Remaining studies: {final_count}")
    
    # Verify data quality
    print("\nVerifying data quality...")
    
    # Check for missing values
    missing_counts = df_clean.isnull().sum()
    print(f"  Missing values: {missing_counts.sum()} total")
    
    # Check enrollment counts
    enrollment_counts = pd.to_numeric(df_clean['EnrollmentCount'], errors='coerce')
    valid_enrollments = enrollment_counts.dropna()
    
    print(f"  Valid enrollment counts: {len(valid_enrollments)}")
    print(f"  Total measurements: {int(valid_enrollments.sum())}")
    
    # Check study types
    study_types = df_clean['StudyType'].value_counts()
    print(f"  Study types: {dict(study_types)}")
    
    # Check conditions
    conditions = df_clean['Condition'].value_counts()
    print(f"  Unique conditions: {len(conditions)}")
    
    # Save cleaned dataset
    filename = 'clinical_trials_clean_final.csv'
    df_clean.to_csv(filename, index=False)
    
    print(f"\n✓ Cleaned dataset saved to: {filename}")
    print(f"✓ Final measurements: {int(valid_enrollments.sum())}")
    print(f"✓ Final studies: {len(df_clean)}")
    
    # Display final dataset summary
    print(f"\nFinal dataset summary:")
    print("=" * 50)
    print(df_clean.to_string(index=False))
    
    # Create measurement analysis
    print(f"\nMeasurement analysis:")
    print("=" * 50)
    print(f"Mean enrollment per study: {valid_enrollments.mean():.1f}")
    print(f"Median enrollment per study: {valid_enrollments.median():.1f}")
    print(f"Std enrollment per study: {valid_enrollments.std():.1f}")
    print(f"Min enrollment: {valid_enrollments.min()}")
    print(f"Max enrollment: {valid_enrollments.max()}")
    
    # Distribution analysis
    small_studies = len(valid_enrollments[valid_enrollments < 50])
    medium_studies = len(valid_enrollments[(valid_enrollments >= 50) & (valid_enrollments < 200)])
    large_studies = len(valid_enrollments[valid_enrollments >= 200])
    
    print(f"\nStudy size distribution:")
    print(f"  Small studies (<50): {small_studies}")
    print(f"  Medium studies (50-200): {medium_studies}")
    print(f"  Large studies (200+): {large_studies}")
    
    # Framework suitability assessment
    total_measurements = int(valid_enrollments.sum())
    
    print(f"\nFramework suitability:")
    print("=" * 50)
    if total_measurements >= 1000:
        print(f"✓ SUFFICIENT MEASUREMENTS: {total_measurements} >= 1000")
        print("✓ Ready for competitive measurement framework integration")
    else:
        print(f"⚠️ INSUFFICIENT MEASUREMENTS: {total_measurements} < 1000")
        print("  Consider supplementing with synthetic data")
    
    return df_clean

if __name__ == "__main__":
    clean_df = clean_final_dataset()
    
    if clean_df is not None:
        total_measurements = clean_df['EnrollmentCount'].sum()
        
        if total_measurements >= 1000:
            print(f"\n🎉 SUCCESS! Clean dataset ready with {total_measurements} measurements")
            print("Next step: Run validate_clinical_data.py on the cleaned dataset")
        else:
            print(f"\n⚠️ Dataset has {total_measurements} measurements - below target")
    else:
        print("\n✗ Failed to clean dataset") 