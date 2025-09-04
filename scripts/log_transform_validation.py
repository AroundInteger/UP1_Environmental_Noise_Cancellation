#!/usr/bin/env python3
"""
LOG_TRANSFORM_VALIDATION
Test log-transformation on scraped datasets for SEF framework

This script tests:
1. Log-transformation effects on normality
2. SEF improvements from κ mechanism alone (ρ = 0)
3. Correlation structure after transformation
4. Framework applicability with transformed data
"""

import pandas as pd
import numpy as np
import os
from scipy import stats
from scipy.stats import shapiro, kstest, normaltest
import warnings
warnings.filterwarnings('ignore')

def log_transform_validation():
    """Main log-transformation validation function"""
    
    print("=== LOG-TRANSFORMATION VALIDATION FOR SEF FRAMEWORK ===\n")
    
    # Dataset paths
    data_path = 'data/raw/scraped data/'
    datasets = [
        ('financial_market_data.csv', 'Financial Markets'),
        ('education_assessment_data.csv', 'Education Assessment'),
        ('social_media_data.csv', 'Social Media')
    ]
    
    # Skip clinical trials (insufficient sample size)
    print(f"Testing log-transformation on {len(datasets)} datasets...\n")
    
    for dataset_file, dataset_name in datasets:
        print(f"--- {dataset_name} ---")
        
        try:
            # Load dataset
            data = pd.read_csv(os.path.join(data_path, dataset_file))
            print(f"✓ Loaded: {len(data)} rows, {len(data.columns)} columns")
            
            # Get numeric columns
            numeric_data = data.select_dtypes(include=[np.number])
            
            # Get categorical column
            categorical_cols = data.select_dtypes(include=['object', 'category']).columns
            
            if len(categorical_cols) == 0:
                print("✗ No categorical column found")
                continue
            
            cat_col = categorical_cols[0]
            categories = data[cat_col].unique()
            print(f"  Categories: {', '.join(map(str, categories))}")
            
            if len(categories) < 2:
                print("✗ Insufficient categories")
                continue
            
            # Test each numeric column
            for col in numeric_data.columns:
                print(f"\n  Testing column: {col}")
                
                # Get data for each category
                data1 = numeric_data[data[cat_col] == categories[0]][col].dropna()
                data2 = numeric_data[data[cat_col] == categories[1]][col].dropna()
                
                if len(data1) < 10 or len(data2) < 10:
                    print("    ✗ Insufficient data for analysis")
                    continue
                
                print(f"    Sample sizes: {len(data1)} vs {len(data2)}")
                
                # Test original data
                print("    Original data:")
                original_valid, original_stats = test_data_quality(data1, data2, 'Original')
                
                # Test log-transformed data
                print("    Log-transformed data:")
                
                # Ensure positive values for log transformation
                min_val1 = data1.min()
                min_val2 = data2.min()
                min_val = min(min_val1, min_val2)
                
                if min_val <= 0:
                    # Add offset to make all values positive
                    offset = abs(min_val) + 1
                    data1_log = np.log(data1 + offset)
                    data2_log = np.log(data2 + offset)
                    print(f"      Applied offset: +{offset:.3f} (min value: {min_val:.3f})")
                else:
                    data1_log = np.log(data1)
                    data2_log = np.log(data2)
                
                log_valid, log_stats = test_data_quality(data1_log, data2_log, 'Log-transformed')
                
                # Calculate SEF improvements
                if original_valid and log_valid:
                    print("    SEF Analysis:")
                    analyze_sef_improvements(original_stats, log_stats, col)
                
        except Exception as e:
            print(f"✗ Error: {str(e)}")
        
        print()
    
    print("=== LOG-TRANSFORMATION VALIDATION COMPLETE ===\n")

def test_data_quality(data1, data2, data_type):
    """Test data quality for SEF framework"""
    
    valid = False
    stats_dict = {}
    
    # Test normality
    try:
        sw1_stat, sw1_p = shapiro(data1)
        sw2_stat, sw2_p = shapiro(data2)
    except:
        sw1_p, sw2_p = 0, 0
    
    print(f"      Normality (Shapiro-Wilk):")
    print(f"        Group 1: p={sw1_p:.3f}, Normal: {sw1_p > 0.05}")
    print(f"        Group 2: p={sw2_p:.3f}, Normal: {sw2_p > 0.05}")
    
    # Calculate basic statistics
    stats_dict['mean1'] = data1.mean()
    stats_dict['mean2'] = data2.mean()
    stats_dict['var1'] = data1.var()
    stats_dict['var2'] = data2.var()
    stats_dict['std1'] = data1.std()
    stats_dict['std2'] = data2.std()
    
    # Calculate variance ratio (κ)
    stats_dict['kappa'] = stats_dict['var2'] / stats_dict['var1']
    
    # Calculate correlation (simplified approach)
    try:
        min_len = min(len(data1), len(data2))
        if min_len >= 10:
            # Use first min_len values for correlation estimate
            corr_data1 = data1.iloc[:min_len]
            corr_data2 = data2.iloc[:min_len]
            correlation, p_value = stats.pearsonr(corr_data1, corr_data2)
            stats_dict['correlation'] = correlation
            stats_dict['corr_p'] = p_value
        else:
            stats_dict['correlation'] = np.nan
            stats_dict['corr_p'] = np.nan
    except:
        stats_dict['correlation'] = np.nan
        stats_dict['corr_p'] = np.nan
    
    print(f"      Statistics:")
    print(f"        Mean: {stats_dict['mean1']:.3f} vs {stats_dict['mean2']:.3f}")
    print(f"        Variance: {stats_dict['var1']:.3f} vs {stats_dict['var2']:.3f}")
    print(f"        κ (variance ratio): {stats_dict['kappa']:.3f}")
    if not np.isnan(stats_dict['correlation']):
        print(f"        Correlation: {stats_dict['correlation']:.3f} (p={stats_dict['corr_p']:.3f})")
    else:
        print(f"        Correlation: Not calculable")
    
    # Check if data is suitable for SEF analysis
    if sw1_p > 0.05 and sw2_p > 0.05:
        print(f"      ✓ Both groups are normal - suitable for SEF")
        valid = True
    else:
        print(f"      ✗ Non-normal data - may need transformation")
        valid = False
    
    return valid, stats_dict

def analyze_sef_improvements(original_stats, log_stats, col_name):
    """Analyze SEF improvements from log-transformation"""
    
    print(f"      Comparing Original vs Log-transformed:")
    
    # Calculate SEF for both cases
    # SEF = (1 + κ) / (1 + κ - 2*√κ*ρ)
    # When ρ = 0: SEF = 1 + κ
    
    # Original data SEF (assuming ρ = 0 for simplicity)
    original_sef = 1 + original_stats['kappa']
    
    # Log-transformed data SEF
    log_sef = 1 + log_stats['kappa']
    
    # Calculate improvement
    improvement = (log_sef - original_sef) / original_sef * 100
    
    print(f"        Original SEF (κ={original_stats['kappa']:.3f}): {original_sef:.3f}")
    print(f"        Log-transformed SEF (κ={log_stats['kappa']:.3f}): {log_sef:.3f}")
    print(f"        Improvement: {improvement:.1f}%")
    
    # Check if improvement is meaningful
    if improvement > 5:
        print(f"        ✓ Meaningful improvement from log-transformation")
    elif improvement > 0:
        print(f"        ~ Modest improvement from log-transformation")
    else:
        print(f"        ✗ No improvement from log-transformation")
    
    # Analyze κ optimization
    print(f"        κ Analysis:")
    print(f"          Original κ: {original_stats['kappa']:.3f}")
    print(f"          Log-transformed κ: {log_stats['kappa']:.3f}")
    
    # Optimal κ is around 1.0 for maximum SEF sensitivity
    original_kappa_distance = abs(original_stats['kappa'] - 1.0)
    log_kappa_distance = abs(log_stats['kappa'] - 1.0)
    
    print(f"          Distance from optimal (κ=1.0):")
    print(f"            Original: {original_kappa_distance:.3f}")
    print(f"            Log-transformed: {log_kappa_distance:.3f}")
    
    if log_kappa_distance < original_kappa_distance:
        print(f"          ✓ Log-transformation moves κ closer to optimal")
    else:
        print(f"          ✗ Log-transformation moves κ away from optimal")
    
    # Additional analysis for ρ = 0 case
    print(f"        ρ = 0 Analysis (κ mechanism only):")
    print(f"          This represents the baseline improvement from variance ratio alone")
    print(f"          Original baseline: {original_sef:.3f}x improvement")
    print(f"          Log-transformed baseline: {log_sef:.3f}x improvement")
    
    if log_sef > original_sef:
        print(f"          ✓ Log-transformation improves κ mechanism effectiveness")
    else:
        print(f"          ✗ Log-transformation reduces κ mechanism effectiveness")

if __name__ == "__main__":
    log_transform_validation()
