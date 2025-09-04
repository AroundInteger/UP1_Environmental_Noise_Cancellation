#!/usr/bin/env python3
"""
CMS Hospital Compare Performance Data Collection Script

This script collects real hospital performance data from CMS.gov for SEF framework validation.
Domain: Healthcare
Expected SEF: 1.25-1.55 (25-55% improvement from dual mechanisms)
"""

import pandas as pd
import numpy as np
import requests
import json
import time
from datetime import datetime
import os

def collect_cms_hospital_data():
    """
    Collect CMS Hospital Compare performance data for SEF framework validation
    """
    print("=== CMS HOSPITAL COMPARE DATA COLLECTION ===")
    print("Domain: Healthcare")
    print("Expected SEF: 1.25-1.55 (25-55% improvement)")
    print("=" * 50)
    
    # CMS Hospital Compare API endpoints
    base_url = "https://data.cms.gov/api/views"
    
    # Key datasets for hospital performance
    datasets = {
        'hospital_general_info': 'xubh-q36u',  # Hospital General Information
        'readmission_deaths': '5u3w-32px',     # Readmission and Death Rates
        'patient_experience': '9nw7-4fn7',     # Patient Experience Survey
        'timely_effective_care': 'y2hd-n93g',  # Timely and Effective Care
        'complications_deaths': 'yuq5-65qt',   # Complications and Deaths
        'payment_value': 'c7us-v4mf'           # Payment and Value of Care
    }
    
    collected_data = {}
    
    for dataset_name, dataset_id in datasets.items():
        print(f"\nCollecting {dataset_name}...")
        try:
            # Construct API URL
            api_url = f"{base_url}/{dataset_id}/rows.json"
            
            # Make API request
            response = requests.get(api_url, timeout=30)
            response.raise_for_status()
            
            # Parse JSON response
            data = response.json()
            
            # Extract data rows
            if 'data' in data:
                rows = data['data']
                print(f"  Retrieved {len(rows)} records")
                
                # Convert to DataFrame
                df = pd.DataFrame(rows)
                
                # Store collected data
                collected_data[dataset_name] = df
                
                # Save individual dataset
                filename = f"cms_{dataset_name}.csv"
                df.to_csv(filename, index=False)
                print(f"  Saved to: {filename}")
                
            else:
                print(f"  No data found for {dataset_name}")
                
        except Exception as e:
            print(f"  Error collecting {dataset_name}: {str(e)}")
            continue
        
        # Rate limiting
        time.sleep(1)
    
    # Combine datasets for comprehensive analysis
    if collected_data:
        combined_data = combine_cms_datasets(collected_data)
        
        # Save combined dataset
        combined_filename = "cms_hospital_combined_data.csv"
        combined_data.to_csv(combined_filename, index=False)
        print(f"\n✓ Combined dataset saved to: {combined_filename}")
        
        # Analyze dataset for SEF framework
        analyze_cms_data_for_sef(combined_data)
        
        return combined_data
    else:
        print("\n❌ No data collected successfully")
        return None

def combine_cms_datasets(collected_data):
    """
    Combine multiple CMS datasets into a comprehensive dataset
    """
    print("\nCombining CMS datasets...")
    
    # Start with hospital general info as base
    if 'hospital_general_info' in collected_data:
        base_df = collected_data['hospital_general_info'].copy()
        print(f"  Base dataset: {len(base_df)} hospitals")
    else:
        print("  No base dataset available")
        return None
    
    # Merge other datasets
    for dataset_name, df in collected_data.items():
        if dataset_name != 'hospital_general_info':
            print(f"  Merging {dataset_name}: {len(df)} records")
            # Add merge logic here based on hospital identifier
            # This would need to be customized based on actual data structure
    
    return base_df

def analyze_cms_data_for_sef(df):
    """
    Analyze CMS data for SEF framework applicability
    """
    print("\n=== CMS DATA ANALYSIS FOR SEF FRAMEWORK ===")
    
    # Basic dataset information
    print(f"Total hospitals: {len(df)}")
    print(f"Columns: {list(df.columns)}")
    
    # Identify potential measurement columns
    measurement_columns = []
    for col in df.columns:
        if any(keyword in col.lower() for keyword in ['rate', 'score', 'percentage', 'ratio', 'count']):
            measurement_columns.append(col)
    
    print(f"Potential measurement columns: {measurement_columns}")
    
    # Identify potential classification columns
    classification_columns = []
    for col in df.columns:
        if any(keyword in col.lower() for keyword in ['type', 'category', 'size', 'ownership', 'region']):
            classification_columns.append(col)
    
    print(f"Potential classification columns: {classification_columns}")
    
    # Sample data preview
    print(f"\nSample data preview:")
    print(df.head())
    
    # Data quality assessment
    print(f"\nData quality assessment:")
    print(f"  Missing values: {df.isnull().sum().sum()}")
    print(f"  Duplicate rows: {df.duplicated().sum()}")
    
    return {
        'total_hospitals': len(df),
        'measurement_columns': measurement_columns,
        'classification_columns': classification_columns,
        'data_quality': {
            'missing_values': df.isnull().sum().sum(),
            'duplicates': df.duplicated().sum()
        }
    }

def validate_cms_data_for_sef_framework(df):
    """
    Validate CMS data against SEF framework requirements
    """
    print("\n=== SEF FRAMEWORK VALIDATION ===")
    
    validation_results = {
        'sample_size': len(df) >= 1000,
        'measurement_columns': len([col for col in df.columns if any(keyword in col.lower() for keyword in ['rate', 'score', 'percentage', 'ratio', 'count'])]) > 0,
        'classification_columns': len([col for col in df.columns if any(keyword in col.lower() for keyword in ['type', 'category', 'size', 'ownership', 'region'])]) > 0,
        'data_completeness': df.isnull().sum().sum() / (len(df) * len(df.columns)) < 0.1
    }
    
    print("Validation Results:")
    for criterion, passed in validation_results.items():
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {criterion}: {status}")
    
    overall_valid = all(validation_results.values())
    print(f"\nOverall SEF Framework Compatibility: {'✅ VALID' if overall_valid else '❌ INVALID'}")
    
    return validation_results

def main():
    """
    Main execution function
    """
    print("Starting CMS Hospital Compare data collection for SEF framework validation...")
    
    # Create output directory
    os.makedirs("data/raw/cms_hospital_data", exist_ok=True)
    os.chdir("data/raw/cms_hospital_data")
    
    # Collect data
    cms_data = collect_cms_hospital_data()
    
    if cms_data is not None:
        # Validate for SEF framework
        validation_results = validate_cms_data_for_sef_framework(cms_data)
        
        if validation_results['sample_size'] and validation_results['measurement_columns']:
            print("\n🎉 SUCCESS: CMS data ready for SEF framework validation!")
            print("Next steps:")
            print("1. Process data for framework application")
            print("2. Calculate κ (variance ratio) and ρ (correlation)")
            print("3. Apply SEF framework and validate results")
        else:
            print("\n⚠️ WARNING: CMS data may not be suitable for SEF framework")
            print("Please review validation results and data quality")
    else:
        print("\n❌ FAILED: Could not collect CMS data")
        print("Please check API access and network connectivity")

if __name__ == "__main__":
    main()
