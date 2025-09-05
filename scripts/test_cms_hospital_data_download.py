#!/usr/bin/env python3
"""
Test downloading actual CMS hospital data from the catalog
Focus on Hospital-Acquired Condition Measures which has direct download links
"""

import requests
import pandas as pd
import zipfile
import io
import time

def test_hac_measures_download():
    """Test downloading Hospital-Acquired Condition Measures data"""
    print("🏥 Testing Hospital-Acquired Condition Measures Download")
    print("=" * 60)
    
    # URL from the catalog - this looks like the most recent data
    url = "https://data.cms.gov/sites/default/files/2025-08/8c6e6d4f-0a74-49bc-b0d9-bfc06c1cff01/HAC%20MEASURE%20PROVIDER%20FILE%202025.csv"
    
    try:
        print(f"🔗 Downloading: {url}")
        response = requests.get(url, timeout=30)
        print(f"Status: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', 'Unknown')}")
        print(f"Content-Length: {len(response.content)} bytes")
        
        if response.status_code == 200:
            # Try to read as CSV
            try:
                # Save to file first
                filename = "data/raw/cms_hac_measures_2025.csv"
                with open(filename, 'wb') as f:
                    f.write(response.content)
                print(f"✅ Downloaded to: {filename}")
                
                # Try to read with pandas
                df = pd.read_csv(filename)
                print(f"📊 CSV loaded successfully:")
                print(f"   Rows: {len(df)}")
                print(f"   Columns: {len(df.columns)}")
                print(f"   Column names: {list(df.columns)}")
                
                # Look for hospital-specific data
                if 'Provider ID' in df.columns or 'Provider_ID' in df.columns:
                    provider_col = 'Provider ID' if 'Provider ID' in df.columns else 'Provider_ID'
                    unique_providers = df[provider_col].nunique()
                    print(f"🏥 Unique providers: {unique_providers}")
                    
                    # Look for our target hospitals
                    mayo_id = 240001  # Mayo Clinic
                    cleveland_id = 360001  # Cleveland Clinic
                    
                    mayo_data = df[df[provider_col] == mayo_id]
                    cleveland_data = df[df[provider_col] == cleveland_id]
                    
                    print(f"🏥 Mayo Clinic (ID: {mayo_id}): {len(mayo_data)} records")
                    print(f"🏥 Cleveland Clinic (ID: {cleveland_id}): {len(cleveland_data)} records")
                    
                    if len(mayo_data) > 0:
                        print(f"   Mayo data columns: {list(mayo_data.columns)}")
                        print(f"   Mayo sample data:")
                        print(mayo_data.head())
                    
                    if len(cleveland_data) > 0:
                        print(f"   Cleveland data columns: {list(cleveland_data.columns)}")
                        print(f"   Cleveland sample data:")
                        print(cleveland_data.head())
                
                # Look for quality measures
                measure_cols = [col for col in df.columns if 'measure' in col.lower() or 'rate' in col.lower() or 'score' in col.lower()]
                if measure_cols:
                    print(f"📈 Quality measure columns found: {measure_cols}")
                
                return df
                
            except Exception as e:
                print(f"❌ CSV parsing error: {str(e)}")
                # Try to read as text to see what we got
                print(f"📄 Content preview: {response.text[:500]}...")
                return None
        
        else:
            print(f"❌ Download failed: {response.status_code}")
            return None
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def test_other_hospital_datasets():
    """Test other hospital datasets from the catalog"""
    print("\n🏥 Testing Other Hospital Datasets")
    print("=" * 60)
    
    # Test AHRQ Patient Safety Indicator data
    ahrq_url = "https://data.cms.gov/sites/default/files/2020-09/Provider-Level_Measure_Rates_for_AHRQ_Patient_Safety_Indicator_11__PSI-11___-_2016.csv"
    
    try:
        print(f"🔗 Testing AHRQ PSI-11 data: {ahrq_url}")
        response = requests.get(ahrq_url, timeout=30)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            filename = "data/raw/cms_ahrq_psi11_2016.csv"
            with open(filename, 'wb') as f:
                f.write(response.content)
            print(f"✅ Downloaded to: {filename}")
            
            # Try to read with pandas
            df = pd.read_csv(filename)
            print(f"📊 AHRQ PSI-11 data:")
            print(f"   Rows: {len(df)}")
            print(f"   Columns: {len(df.columns)}")
            print(f"   Column names: {list(df.columns)}")
            
            return df
        else:
            print(f"❌ Download failed: {response.status_code}")
            return None
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def analyze_hospital_data_for_sef(df, dataset_name):
    """Analyze hospital data for SEF framework compatibility"""
    print(f"\n🔬 Analyzing {dataset_name} for SEF Framework Compatibility")
    print("=" * 60)
    
    if df is None:
        print("❌ No data to analyze")
        return
    
    print(f"📊 Dataset: {dataset_name}")
    print(f"   Rows: {len(df)}")
    print(f"   Columns: {len(df.columns)}")
    
    # Look for provider/hospital identification
    provider_cols = [col for col in df.columns if 'provider' in col.lower() or 'hospital' in col.lower() or 'facility' in col.lower()]
    print(f"🏥 Provider identification columns: {provider_cols}")
    
    # Look for quality measures
    measure_cols = [col for col in df.columns if any(keyword in col.lower() for keyword in ['measure', 'rate', 'score', 'indicator', 'outcome'])]
    print(f"📈 Quality measure columns: {measure_cols}")
    
    # Look for temporal data
    time_cols = [col for col in df.columns if any(keyword in col.lower() for keyword in ['year', 'date', 'period', 'quarter'])]
    print(f"📅 Temporal columns: {time_cols}")
    
    # Check for SEF framework requirements
    print(f"\n🎯 SEF Framework Compatibility Assessment:")
    
    # Check for paired measurements (two hospitals on same metrics)
    if provider_cols and measure_cols:
        print(f"✅ Has provider identification and quality measures")
        
        # Check for multiple providers
        provider_col = provider_cols[0]
        unique_providers = df[provider_col].nunique()
        print(f"✅ {unique_providers} unique providers found")
        
        if unique_providers >= 2:
            print(f"✅ Sufficient providers for competitive comparison")
            
            # Check for multiple measures
            if len(measure_cols) >= 2:
                print(f"✅ {len(measure_cols)} quality measures available")
                print(f"✅ Suitable for SEF framework validation")
            else:
                print(f"⚠️ Only {len(measure_cols)} quality measures - may be limited")
        else:
            print(f"❌ Insufficient providers for competitive comparison")
    else:
        print(f"❌ Missing provider identification or quality measures")
    
    # Check data quality
    print(f"\n📊 Data Quality Assessment:")
    missing_data = df.isnull().sum()
    high_missing = missing_data[missing_data > len(df) * 0.2]
    if len(high_missing) > 0:
        print(f"⚠️ High missing data columns: {list(high_missing.index)}")
    else:
        print(f"✅ No columns with >20% missing data")
    
    return {
        'dataset_name': dataset_name,
        'rows': len(df),
        'columns': len(df.columns),
        'providers': df[provider_cols[0]].nunique() if provider_cols else 0,
        'measures': len(measure_cols),
        'sef_compatible': provider_cols and measure_cols and len(measure_cols) >= 2
    }

def main():
    print("🏥 CMS Hospital Data Download and Analysis")
    print("=" * 60)
    print("Testing direct download of hospital performance data from CMS catalog")
    print("Focus: Hospital-Acquired Condition Measures and AHRQ Patient Safety Indicators")
    
    # Test HAC measures download
    hac_df = test_hac_measures_download()
    hac_analysis = analyze_hospital_data_for_sef(hac_df, "HAC Measures 2025")
    
    # Test AHRQ PSI-11 download
    ahrq_df = test_other_hospital_datasets()
    ahrq_analysis = analyze_hospital_data_for_sef(ahrq_df, "AHRQ PSI-11 2016")
    
    # Summary
    print("\n" + "=" * 60)
    print("🎯 SUMMARY OF FINDINGS:")
    print("=" * 60)
    
    for analysis in [hac_analysis, ahrq_analysis]:
        if analysis:
            print(f"\n📊 {analysis['dataset_name']}:")
            print(f"   Rows: {analysis['rows']}")
            print(f"   Providers: {analysis['providers']}")
            print(f"   Measures: {analysis['measures']}")
            print(f"   SEF Compatible: {'✅ Yes' if analysis['sef_compatible'] else '❌ No'}")
    
    print(f"\n🚀 NEXT STEPS:")
    print(f"1. Review downloaded datasets for SEF framework application")
    print(f"2. Identify best datasets for Mayo Clinic vs Cleveland Clinic comparison")
    print(f"3. Apply SEF framework to compatible datasets")
    print(f"4. Document findings for integration with SAIL data (when available)")

if __name__ == "__main__":
    main()