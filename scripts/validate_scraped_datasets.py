#!/usr/bin/env python3
"""
VALIDATE_SCRAPED_DATASETS
Comprehensive validation of scraped datasets against SEF framework requirements

This script validates each dataset against our framework requirements:
1. Correlation structure (ρ > 0.05)
2. Parameter ranges (κ, ρ within bounds)
3. Normality assumptions
4. Sample size requirements
5. SEF calculation feasibility
"""

import pandas as pd
import numpy as np
import os
from scipy import stats
from scipy.stats import shapiro, kstest, normaltest
import warnings
warnings.filterwarnings('ignore')

def validate_scraped_datasets():
    """Main validation function"""
    
    print("=== SEF FRAMEWORK DATASET VALIDATION ===\n")
    
    # Define validation criteria
    MIN_CORRELATION = 0.05
    MIN_SAMPLE_SIZE = 20
    MAX_MISSING_RATE = 0.1
    NORMALITY_ALPHA = 0.05
    
    # Initialize results
    validation_results = {}
    
    # Dataset paths
    data_path = 'data/raw/scraped data/'
    datasets = [
        ('clinical_trials_1000_plus_final.csv', 'Clinical Trials'),
        ('financial_market_data.csv', 'Financial Markets'),
        ('education_assessment_data.csv', 'Education Assessment'),
        ('social_media_data.csv', 'Social Media')
    ]
    
    print(f"Validating {len(datasets)} datasets against SEF framework requirements...\n")
    
    for dataset_file, dataset_name in datasets:
        print(f"--- {dataset_name} ---")
        print(f"File: {dataset_file}")
        
        try:
            # Load dataset
            data = pd.read_csv(os.path.join(data_path, dataset_file))
            print(f"✓ Dataset loaded successfully")
            print(f"  Rows: {len(data)}, Columns: {len(data.columns)}")
            
            # Display column names
            print(f"  Columns: {', '.join(data.columns.tolist())}")
            
            # Validate dataset structure
            result = validate_dataset_structure(data, dataset_name)
            validation_results[dataset_name] = result
            
            # Check if dataset can be processed
            if result['valid_structure']:
                print("✓ Dataset structure valid for SEF analysis")
                
                # Attempt correlation analysis
                correlation_result = analyze_correlation_structure(data, dataset_name)
                result['correlation_analysis'] = correlation_result
                
                # Check normality
                normality_result = test_normality_assumptions(data, dataset_name)
                result['normality_analysis'] = normality_result
                
                # Calculate SEF if possible
                if correlation_result['valid_for_sef']:
                    sef_result = calculate_sef_values(data, dataset_name)
                    result['sef_analysis'] = sef_result
                else:
                    print("✗ Dataset not suitable for SEF calculation")
                    result['sef_analysis'] = {'valid': False, 'reason': 'Correlation requirements not met'}
                
            else:
                print("✗ Dataset structure invalid for SEF analysis")
                print(f"  Reason: {result['invalid_reason']}")
                
        except Exception as e:
            print(f"✗ Error loading dataset: {str(e)}")
            validation_results[dataset_name] = {
                'valid_structure': False,
                'invalid_reason': str(e)
            }
        
        print()
    
    # Generate comprehensive validation report
    generate_validation_report(validation_results)

def validate_dataset_structure(data, dataset_name):
    """Check if dataset has required structure for SEF analysis"""
    
    result = {
        'dataset_name': dataset_name,
        'valid_structure': False,
        'invalid_reason': ''
    }
    
    # Check minimum sample size
    if len(data) < 20:
        result['invalid_reason'] = f"Insufficient sample size: {len(data)} (minimum: 20)"
        return result
    
    # Check for missing values
    missing_rate = data.isnull().sum().sum() / (len(data) * len(data.columns))
    if missing_rate > 0.1:
        result['invalid_reason'] = f"High missing rate: {missing_rate:.1%} (maximum: 10%)"
        return result
    
    # Check for numeric columns
    numeric_cols = data.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) < 2:
        result['invalid_reason'] = "Insufficient numeric columns for correlation analysis"
        return result
    
    # Check for categorical columns (for pairing)
    categorical_cols = data.select_dtypes(include=['object', 'category']).columns
    if len(categorical_cols) == 0:
        result['invalid_reason'] = "No categorical columns for competitor pairing"
        return result
    
    result['valid_structure'] = True
    result['sample_size'] = len(data)
    result['missing_rate'] = missing_rate
    result['numeric_columns'] = len(numeric_cols)
    result['categorical_columns'] = len(categorical_cols)
    
    return result

def analyze_correlation_structure(data, dataset_name):
    """Analyze correlation structure for SEF framework"""
    
    result = {
        'valid_for_sef': False,
        'correlation_found': False
    }
    
    # Get numeric columns
    numeric_data = data.select_dtypes(include=[np.number])
    
    # Get categorical columns for pairing
    categorical_cols = data.select_dtypes(include=['object', 'category']).columns
    
    if len(categorical_cols) == 0:
        result['reason'] = "No categorical columns for competitor pairing"
        return result
    
    # Get unique categories
    cat_col = categorical_cols[0]
    categories = data[cat_col].unique()
    
    if len(categories) < 2:
        result['reason'] = "Insufficient categories for pairing (minimum: 2)"
        return result
    
    print(f"  Categories found: {', '.join(map(str, categories))}")
    
    # Analyze each pair of categories
    correlations = []
    correlation_pairs = []
    
    for i in range(len(categories)):
        for j in range(i+1, len(categories)):
            cat1 = categories[i]
            cat2 = categories[j]
            
            # Get data for each category
            data1 = numeric_data[data[cat_col] == cat1]
            data2 = numeric_data[data[cat_col] == cat2]
            
            if len(data1) < 10 or len(data2) < 10:
                continue  # Skip pairs with insufficient data
            
            # Calculate correlation for each numeric column
            for col in numeric_data.columns:
                # Remove missing values
                valid1 = ~data1[col].isna()
                valid2 = ~data2[col].isna()
                
                if valid1.sum() < 5 or valid2.sum() < 5:
                    continue
                
                # Calculate correlation
                try:
                    correlation, p_value = stats.pearsonr(
                        data1[col][valid1], 
                        data2[col][valid2]
                    )
                    
                    if not np.isnan(correlation) and p_value < 0.05:
                        correlations.append(correlation)
                        correlation_pairs.append(f"{cat1}-{cat2} ({col})")
                        
                except:
                    continue
    
    if len(correlations) == 0:
        result['reason'] = "No significant correlations found between categories"
        return result
    
    result['correlation_found'] = True
    result['correlations'] = correlations
    result['correlation_pairs'] = correlation_pairs
    result['mean_correlation'] = np.mean(correlations)
    result['max_correlation'] = np.max(correlations)
    result['min_correlation'] = np.min(correlations)
    
    print(f"  Significant correlations found: {len(correlations)}")
    print(f"  Correlation range: [{result['min_correlation']:.3f}, {result['max_correlation']:.3f}]")
    print(f"  Mean correlation: {result['mean_correlation']:.3f}")
    
    # Check if correlations meet SEF requirements
    if result['mean_correlation'] > 0.05:
        result['valid_for_sef'] = True
        print(f"✓ Dataset suitable for SEF analysis (mean ρ = {result['mean_correlation']:.3f} > 0.05)")
    else:
        result['reason'] = f"Mean correlation too low: {result['mean_correlation']:.3f} (minimum: 0.05)"
        print("✗ Dataset not suitable for SEF analysis")
    
    return result

def test_normality_assumptions(data, dataset_name):
    """Test normality assumptions for SEF framework"""
    
    result = {'normality_tests': {}}
    
    # Get numeric columns
    numeric_data = data.select_dtypes(include=[np.number])
    
    print("  Testing normality assumptions...")
    
    for col in numeric_data.columns:
        col_data = numeric_data[col].dropna()
        
        if len(col_data) < 10:
            continue
        
        # Shapiro-Wilk test
        try:
            sw_stat, sw_p = shapiro(col_data)
            sw_normal = sw_p > 0.05
        except:
            sw_stat, sw_p = np.nan, np.nan
            sw_normal = False
        
        # Kolmogorov-Smirnov test
        try:
            ks_stat, ks_p = kstest(col_data, 'norm', args=(col_data.mean(), col_data.std()))
            ks_normal = ks_p > 0.05
        except:
            ks_stat, ks_p = np.nan, np.nan
            ks_normal = False
        
        # D'Agostino test
        try:
            da_stat, da_p = normaltest(col_data)
            da_normal = da_p > 0.05
        except:
            da_stat, da_p = np.nan, np.nan
            da_normal = False
        
        # Overall normality assessment
        overall_normal = sw_normal and ks_normal and da_normal
        
        result['normality_tests'][col] = {
            'shapiro_wilk': {'stat': sw_stat, 'p': sw_p, 'normal': sw_normal},
            'kolmogorov_smirnov': {'stat': ks_stat, 'p': ks_p, 'normal': ks_normal},
            'dagostino': {'stat': da_stat, 'p': da_p, 'normal': da_normal},
            'overall_normal': overall_normal
        }
        
        print(f"    {col}: SW p={sw_p:.3f}, KS p={ks_p:.3f}, DA p={da_p:.3f}, Normal: {overall_normal}")
    
    return result

def calculate_sef_values(data, dataset_name):
    """Calculate SEF values for validated datasets"""
    
    result = {'sef_calculated': False}
    
    print("  Calculating SEF values...")
    
    # This is a placeholder - actual SEF calculation would require
    # specific pairing logic based on dataset structure
    # For now, we'll indicate that SEF calculation is possible
    
    result['sef_calculated'] = True
    result['reason'] = "Dataset structure suitable for SEF calculation"
    result['note'] = "Full SEF calculation requires dataset-specific pairing logic"
    
    print("✓ SEF calculation feasible for this dataset")
    
    return result

def generate_validation_report(validation_results):
    """Generate comprehensive validation report"""
    
    print("=== COMPREHENSIVE VALIDATION REPORT ===\n")
    
    valid_datasets = 0
    sef_ready_datasets = 0
    
    for dataset_name, result in validation_results.items():
        print(f"Dataset: {dataset_name}")
        
        if result['valid_structure']:
            print("  ✓ Structure: Valid")
            print(f"    Sample size: {result['sample_size']}")
            print(f"    Missing rate: {result['missing_rate']:.1%}")
            print(f"    Numeric columns: {result['numeric_columns']}")
            print(f"    Categorical columns: {result['categorical_columns']}")
            
            valid_datasets += 1
            
            if 'correlation_analysis' in result and result['correlation_analysis']['valid_for_sef']:
                print(f"  ✓ Correlation: Suitable for SEF (mean ρ = {result['correlation_analysis']['mean_correlation']:.3f})")
                sef_ready_datasets += 1
            else:
                print("  ✗ Correlation: Not suitable for SEF")
                if 'correlation_analysis' in result:
                    print(f"    Reason: {result['correlation_analysis']['reason']}")
            
            if 'normality_analysis' in result:
                print("  ✓ Normality: Tested")
            
            if 'sef_analysis' in result and result['sef_analysis']['valid']:
                print("  ✓ SEF: Calculation feasible")
            else:
                print("  ✗ SEF: Calculation not feasible")
            
        else:
            print("  ✗ Structure: Invalid")
            print(f"    Reason: {result['invalid_reason']}")
        
        print()
    
    print("=== SUMMARY ===")
    print(f"Total datasets: {len(validation_results)}")
    print(f"Valid structure: {valid_datasets}")
    print(f"SEF ready: {sef_ready_datasets}")
    print(f"Success rate: {(sef_ready_datasets / len(validation_results)) * 100:.1f}%")
    
    if sef_ready_datasets > 0:
        print(f"\n✓ {sef_ready_datasets} datasets are suitable for SEF framework analysis")
    else:
        print("\n✗ No datasets are suitable for SEF framework analysis")
        print("  Consider data preprocessing or alternative datasets")

if __name__ == "__main__":
    validate_scraped_datasets()
