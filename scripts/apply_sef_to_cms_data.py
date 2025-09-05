#!/usr/bin/env python3
"""
Apply SEF framework to real CMS hospital data
Focus on Mayo Clinic vs Cleveland Clinic comparison using HAC measures
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import shapiro, kstest, normaltest
import warnings
warnings.filterwarnings('ignore')

def load_cms_data():
    """Load the CMS HAC measures data"""
    print("📊 Loading CMS Hospital-Acquired Condition Measures Data")
    print("=" * 60)
    
    try:
        df = pd.read_csv('data/raw/cms_hac_measures_2025.csv')
        print(f"✅ Data loaded successfully:")
        print(f"   Rows: {len(df)}")
        print(f"   Columns: {list(df.columns)}")
        
        # Filter for Mayo Clinic and Cleveland Clinic
        mayo_id = 240001
        cleveland_id = 360001
        
        mayo_data = df[df['Provider_ID'] == mayo_id].copy()
        cleveland_data = df[df['Provider_ID'] == cleveland_id].copy()
        
        print(f"\n🏥 Hospital Data:")
        print(f"   Mayo Clinic (ID: {mayo_id}): {len(mayo_data)} records")
        print(f"   Cleveland Clinic (ID: {cleveland_id}): {len(cleveland_data)} records")
        
        return df, mayo_data, cleveland_data
    
    except Exception as e:
        print(f"❌ Error loading data: {str(e)}")
        return None, None, None

def analyze_hospital_measures(mayo_data, cleveland_data):
    """Analyze the quality measures for both hospitals"""
    print("\n🔬 Analyzing Hospital Quality Measures")
    print("=" * 60)
    
    # Get unique measures
    mayo_measures = mayo_data['Measure'].unique()
    cleveland_measures = cleveland_data['Measure'].unique()
    common_measures = set(mayo_measures) & set(cleveland_measures)
    
    print(f"📈 Measures Analysis:")
    print(f"   Mayo Clinic measures: {len(mayo_measures)}")
    print(f"   Cleveland Clinic measures: {len(cleveland_measures)}")
    print(f"   Common measures: {len(common_measures)}")
    print(f"   Common measure names: {list(common_measures)}")
    
    # Create comparison dataframe
    comparison_data = []
    
    for measure in common_measures:
        mayo_rate = mayo_data[mayo_data['Measure'] == measure]['Rate'].iloc[0]
        cleveland_rate = cleveland_data[cleveland_data['Measure'] == measure]['Rate'].iloc[0]
        
        comparison_data.append({
            'Measure': measure,
            'Mayo_Rate': mayo_rate,
            'Cleveland_Rate': cleveland_rate,
            'Difference': mayo_rate - cleveland_rate,
            'Relative_Difference': (mayo_rate - cleveland_rate) / cleveland_rate if cleveland_rate != 0 else np.nan
        })
    
    comparison_df = pd.DataFrame(comparison_data)
    print(f"\n📊 Comparison Summary:")
    print(comparison_df)
    
    return comparison_df

def test_normality_and_log_transform(data, measure_name):
    """Test normality and apply log transformation if needed"""
    print(f"\n📊 Testing Normality for {measure_name}")
    print("-" * 40)
    
    # Remove any NaN values
    clean_data = data.dropna()
    
    if len(clean_data) < 3:
        print(f"❌ Insufficient data for normality testing: {len(clean_data)} values")
        return data, False, False
    
    # Test normality
    shapiro_stat, shapiro_p = shapiro(clean_data)
    ks_stat, ks_p = kstest(clean_data, 'norm', args=(clean_data.mean(), clean_data.std()))
    dagostino_stat, dagostino_p = normaltest(clean_data)
    
    print(f"📈 Normality Tests:")
    print(f"   Shapiro-Wilk: statistic={shapiro_stat:.4f}, p-value={shapiro_p:.4f}")
    print(f"   Kolmogorov-Smirnov: statistic={ks_stat:.4f}, p-value={ks_p:.4f}")
    print(f"   D'Agostino K²: statistic={dagostino_stat:.4f}, p-value={dagostino_p:.4f}")
    
    is_normal = all(p > 0.05 for p in [shapiro_p, ks_p, dagostino_p])
    print(f"   Is Normal: {'✅ Yes' if is_normal else '❌ No'}")
    
    # Apply log transformation if not normal
    log_transformed = False
    if not is_normal and (clean_data > 0).all():
        print(f"🔄 Applying log transformation...")
        log_data = np.log(clean_data)
        
        # Test normality of log-transformed data
        log_shapiro_stat, log_shapiro_p = shapiro(log_data)
        log_ks_stat, log_ks_p = kstest(log_data, 'norm', args=(log_data.mean(), log_data.std()))
        log_dagostino_stat, log_dagostino_p = normaltest(log_data)
        
        print(f"📈 Log-Transformed Normality Tests:")
        print(f"   Shapiro-Wilk: statistic={log_shapiro_stat:.4f}, p-value={log_shapiro_p:.4f}")
        print(f"   Kolmogorov-Smirnov: statistic={log_ks_stat:.4f}, p-value={log_ks_p:.4f}")
        print(f"   D'Agostino K²: statistic={log_dagostino_stat:.4f}, p-value={log_dagostino_p:.4f}")
        
        log_is_normal = all(p > 0.05 for p in [log_shapiro_p, log_ks_p, log_dagostino_p])
        print(f"   Log-Transformed Is Normal: {'✅ Yes' if log_is_normal else '❌ No'}")
        
        if log_is_normal:
            log_transformed = True
            return log_data, is_normal, log_transformed
    
    return clean_data, is_normal, log_transformed

def calculate_sef_parameters(mayo_data, cleveland_data, measure_name):
    """Calculate SEF framework parameters"""
    print(f"\n🎯 Calculating SEF Parameters for {measure_name}")
    print("-" * 40)
    
    # Test normality and apply transformations
    mayo_clean, mayo_normal, mayo_log = test_normality_and_log_transform(mayo_data, f"Mayo {measure_name}")
    cleveland_clean, cleveland_normal, cleveland_log = test_normality_and_log_transform(cleveland_data, f"Cleveland {measure_name}")
    
    # Use log-transformed data if it improved normality
    if mayo_log and cleveland_log:
        print("🔄 Using log-transformed data for SEF calculation")
        mayo_final = mayo_clean
        cleveland_final = cleveland_clean
    else:
        mayo_final = mayo_clean
        cleveland_final = cleveland_clean
    
    # Calculate basic statistics
    mayo_mean = mayo_final.mean()
    mayo_std = mayo_final.std()
    cleveland_mean = cleveland_final.mean()
    cleveland_std = cleveland_final.std()
    
    print(f"📊 Statistics:")
    print(f"   Mayo: mean={mayo_mean:.4f}, std={mayo_std:.4f}")
    print(f"   Cleveland: mean={cleveland_mean:.4f}, std={cleveland_std:.4f}")
    
    # Calculate SEF parameters
    delta = abs(mayo_mean - cleveland_mean)  # Signal separation
    kappa = (cleveland_std ** 2) / (mayo_std ** 2) if mayo_std != 0 else np.inf  # Variance ratio
    
    print(f"🎯 SEF Parameters:")
    print(f"   δ (Signal Separation): {delta:.4f}")
    print(f"   κ (Variance Ratio): {kappa:.4f}")
    
    # Calculate correlation (if we have multiple data points)
    if len(mayo_final) > 1 and len(cleveland_final) > 1:
        # For this analysis, we'll use the correlation between the two hospitals
        # In practice, this would be environmental correlation
        correlation, correlation_p = stats.pearsonr(mayo_final, cleveland_final)
        print(f"   ρ (Correlation): {correlation:.4f} (p={correlation_p:.4f})")
    else:
        # Single data point - assume no correlation for now
        correlation = 0.0
        print(f"   ρ (Correlation): {correlation:.4f} (assumed - single data point)")
    
    return {
        'delta': delta,
        'kappa': kappa,
        'rho': correlation,
        'mayo_mean': mayo_mean,
        'mayo_std': mayo_std,
        'cleveland_mean': cleveland_mean,
        'cleveland_std': cleveland_std,
        'mayo_log': mayo_log,
        'cleveland_log': cleveland_log
    }

def calculate_sef_improvement(params):
    """Calculate SEF improvement using the framework formula"""
    print(f"\n🚀 Calculating SEF Improvement")
    print("-" * 40)
    
    delta = params['delta']
    kappa = params['kappa']
    rho = params['rho']
    
    # Calculate SNR for independent measurement (baseline)
    mayo_var = params['mayo_std'] ** 2
    cleveland_var = params['cleveland_std'] ** 2
    snr_independent = (delta ** 2) / (mayo_var + cleveland_var)
    
    # Calculate SNR for relative measurement (with correlation)
    relative_var = mayo_var + cleveland_var - 2 * rho * params['mayo_std'] * params['cleveland_std']
    snr_relative = (delta ** 2) / relative_var if relative_var > 0 else np.inf
    
    # Calculate SEF
    sef = snr_relative / snr_independent if snr_independent > 0 else np.inf
    
    print(f"📊 SNR Calculations:")
    print(f"   SNR Independent: {snr_independent:.4f}")
    print(f"   SNR Relative: {snr_relative:.4f}")
    print(f"   SEF Improvement: {sef:.4f}")
    
    # Interpret results
    if sef > 1.1:
        print(f"✅ Significant SEF improvement: {sef:.2f}x")
    elif sef > 1.0:
        print(f"⚠️ Marginal SEF improvement: {sef:.2f}x")
    else:
        print(f"❌ No SEF improvement: {sef:.2f}x")
    
    return {
        'snr_independent': snr_independent,
        'snr_relative': snr_relative,
        'sef': sef,
        'improvement_percent': (sef - 1) * 100
    }

def main():
    print("🏥 Applying SEF Framework to Real CMS Hospital Data")
    print("=" * 60)
    print("Analysis: Mayo Clinic vs Cleveland Clinic using HAC measures")
    
    # Load data
    df, mayo_data, cleveland_data = load_cms_data()
    
    if df is None:
        print("❌ Failed to load data")
        return
    
    # Analyze measures
    comparison_df = analyze_hospital_measures(mayo_data, cleveland_data)
    
    # Apply SEF framework to each measure
    sef_results = []
    
    for _, row in comparison_df.iterrows():
        measure = row['Measure']
        print(f"\n{'='*60}")
        print(f"🔬 SEF Analysis for: {measure}")
        print(f"{'='*60}")
        
        # Get data for this measure
        mayo_measure_data = mayo_data[mayo_data['Measure'] == measure]['Rate']
        cleveland_measure_data = cleveland_data[cleveland_data['Measure'] == measure]['Rate']
        
        # Calculate SEF parameters
        params = calculate_sef_parameters(mayo_measure_data, cleveland_measure_data, measure)
        
        # Calculate SEF improvement
        sef_result = calculate_sef_improvement(params)
        
        # Store results
        sef_results.append({
            'Measure': measure,
            'Mayo_Rate': row['Mayo_Rate'],
            'Cleveland_Rate': row['Cleveland_Rate'],
            'Delta': params['delta'],
            'Kappa': params['kappa'],
            'Rho': params['rho'],
            'SEF': sef_result['sef'],
            'Improvement_Percent': sef_result['improvement_percent'],
            'Log_Transformed': params['mayo_log'] and params['cleveland_log']
        })
    
    # Summary
    print(f"\n{'='*60}")
    print(f"🎯 SEF FRAMEWORK VALIDATION SUMMARY")
    print(f"{'='*60}")
    
    sef_df = pd.DataFrame(sef_results)
    print(sef_df)
    
    # Overall assessment
    avg_sef = sef_df['SEF'].mean()
    max_sef = sef_df['SEF'].max()
    min_sef = sef_df['SEF'].min()
    
    print(f"\n📊 Overall SEF Performance:")
    print(f"   Average SEF: {avg_sef:.4f}")
    print(f"   Maximum SEF: {max_sef:.4f}")
    print(f"   Minimum SEF: {min_sef:.4f}")
    
    if avg_sef > 1.1:
        print(f"✅ SEF framework shows significant improvement in healthcare quality measurement")
    elif avg_sef > 1.0:
        print(f"⚠️ SEF framework shows marginal improvement in healthcare quality measurement")
    else:
        print(f"❌ SEF framework does not show improvement in healthcare quality measurement")
    
    # Save results
    sef_df.to_csv('data/processed/cms_sef_validation_results.csv', index=False)
    print(f"\n💾 Results saved to: data/processed/cms_sef_validation_results.csv")
    
    print(f"\n🚀 NEXT STEPS:")
    print(f"1. Compare CMS results with rugby validation results")
    print(f"2. Integrate findings with SAIL data (when available)")
    print(f"3. Document multi-domain SEF framework validation")
    print(f"4. Prepare results for paper integration")

if __name__ == "__main__":
    main()
