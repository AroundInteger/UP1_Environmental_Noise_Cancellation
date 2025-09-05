#!/usr/bin/env python3
"""
CMS Excel Data Analysis Script

The CMS data is available as Excel files (.xlsx). Let's download and analyze
these files to find hospital data for Mayo Clinic and Cleveland Clinic.
"""

import requests
import zipfile
import pandas as pd
import os
import time
from datetime import datetime

def download_and_analyze_cms_excel(url, filename):
    """
    Download a CMS ZIP file and analyze the Excel files inside
    """
    print(f"Downloading: {url}")
    try:
        response = requests.get(url, timeout=30)
        
        if response.status_code == 200:
            print(f"✅ Download successful: {len(response.content)} bytes")
            
            # Save the ZIP file
            with open(filename, 'wb') as f:
                f.write(response.content)
            
            print(f"📁 Saved to: {filename}")
            
            # Extract and analyze the ZIP file
            with zipfile.ZipFile(filename, 'r') as zip_ref:
                file_list = zip_ref.namelist()
                print(f"📦 ZIP contains {len(file_list)} files:")
                for file in file_list:
                    print(f"  - {file}")
                
                # Try to read Excel files
                excel_files = [f for f in file_list if f.endswith('.xlsx')]
                if excel_files:
                    print(f"\n📊 Excel files found: {len(excel_files)}")
                    for excel_file in excel_files:
                        print(f"  Analyzing: {excel_file}")
                        try:
                            # Read the Excel file
                            with zip_ref.open(excel_file) as f:
                                # Try to read all sheets
                                excel_data = pd.read_excel(f, sheet_name=None)
                                print(f"    Sheets: {list(excel_data.keys())}")
                                
                                # Analyze each sheet
                                for sheet_name, df in excel_data.items():
                                    print(f"    Sheet '{sheet_name}': {df.shape}")
                                    print(f"    Columns: {list(df.columns)}")
                                    
                                    # Look for our target hospitals
                                    hospital_found = False
                                    for col in df.columns:
                                        if any(keyword in col.lower() for keyword in ['ccn', 'provider', 'hospital', 'id']):
                                            # Search for our hospitals
                                            mayo_data = df[df[col].astype(str).str.contains('240001', na=False)]
                                            cleveland_data = df[df[col].astype(str).str.contains('360001', na=False)]
                                            
                                            if len(mayo_data) > 0:
                                                print(f"      🏥 Mayo Clinic found in {col}: {len(mayo_data)} records")
                                                hospital_found = True
                                            
                                            if len(cleveland_data) > 0:
                                                print(f"      🏥 Cleveland Clinic found in {col}: {len(cleveland_data)} records")
                                                hospital_found = True
                                    
                                    if not hospital_found:
                                        print(f"      ❌ No target hospitals found in this sheet")
                                    
                                    # Show sample data
                                    if len(df) > 0:
                                        print(f"      Sample data:")
                                        print(df.head(3).to_string())
                                
                        except Exception as e:
                            print(f"    ⚠️ Error reading Excel: {str(e)}")
                else:
                    print(f"  ❌ No Excel files found in ZIP")
            
            return True
            
        else:
            print(f"❌ Download failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"⚠️ Download error: {str(e)}")
        return False

def analyze_cms_hospital_data():
    """
    Analyze CMS hospital data to find our target hospitals
    """
    print("=== ANALYZING CMS HOSPITAL DATA ===")
    print("Goal: Find Mayo Clinic and Cleveland Clinic data")
    print("=" * 60)
    
    # Test with the most comprehensive dataset (2018 has multiple files)
    test_url = "https://data.cms.gov/sites/default/files/2020-11/CPS%20MDCR%20INPT%20HOSP%20ALL%202018.zip"
    test_filename = "cms_hospital_analysis.zip"
    
    success = download_and_analyze_cms_excel(test_url, test_filename)
    
    if success:
        print(f"\n✅ Successfully analyzed CMS hospital data")
        
        # Clean up the downloaded file
        if os.path.exists(test_filename):
            os.remove(test_filename)
            print(f"🗑️ Cleaned up temporary file: {test_filename}")
    else:
        print(f"\n❌ Failed to analyze CMS hospital data")

def test_recent_cms_data():
    """
    Test the most recent CMS data to see what's available
    """
    print(f"\n{'='*60}")
    print("TESTING RECENT CMS DATA")
    print("=" * 60)
    
    # Test the most recent dataset
    recent_url = "https://data.cms.gov/sites/default/files/2023-02/CPS%20MDCR%20INPT%202021.zip"
    recent_filename = "cms_recent_data.zip"
    
    print(f"Testing most recent CMS data (2021)...")
    success = download_and_analyze_cms_excel(recent_url, recent_filename)
    
    if success:
        print(f"\n✅ Successfully analyzed recent CMS data")
        
        # Clean up
        if os.path.exists(recent_filename):
            os.remove(recent_filename)
            print(f"🗑️ Cleaned up: {recent_filename}")
    else:
        print(f"\n❌ Failed to analyze recent CMS data")

def search_for_quality_measures():
    """
    Search for quality measures data that might be more suitable for SEF analysis
    """
    print(f"\n{'='*60}")
    print("SEARCHING FOR QUALITY MEASURES DATA")
    print("=" * 60)
    
    # Look for quality measures datasets
    quality_datasets = [
        {
            'name': 'Hospital Compare Data',
            'url': 'https://data.cms.gov/provider-data/dataset/hospital-compare',
            'description': 'Quality measures and outcomes'
        },
        {
            'name': 'Patient Safety Indicators',
            'url': 'https://data.cms.gov/provider-data/dataset/patient-safety-indicators',
            'description': 'Patient safety measures'
        },
        {
            'name': 'Hospital-Acquired Conditions',
            'url': 'https://data.cms.gov/provider-data/dataset/hospital-acquired-conditions',
            'description': 'HAC measures'
        }
    ]
    
    for dataset in quality_datasets:
        print(f"\n📊 Testing: {dataset['name']}")
        print(f"   Description: {dataset['description']}")
        print(f"   URL: {dataset['url']}")
        
        try:
            response = requests.get(dataset['url'], timeout=10)
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                html_content = response.text
                print(f"   ✅ Accessible: {len(html_content)} characters")
                
                # Look for download links or data access information
                if 'download' in html_content.lower():
                    print(f"   📥 Download references found")
                if 'csv' in html_content.lower():
                    print(f"   📊 CSV references found")
                if 'excel' in html_content.lower():
                    print(f"   📊 Excel references found")
                if 'api' in html_content.lower():
                    print(f"   🔌 API references found")
            else:
                print(f"   ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"   ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def main():
    """
    Main function to analyze CMS Excel data
    """
    print("Starting CMS Excel Data Analysis...")
    print("Goal: Find hospital data for Mayo Clinic and Cleveland Clinic")
    print("Focus: Analyze Excel files from CMS Program Statistics")
    
    # Step 1: Analyze CMS hospital data
    analyze_cms_hospital_data()
    
    # Step 2: Test recent CMS data
    test_recent_cms_data()
    
    # Step 3: Search for quality measures
    search_for_quality_measures()
    
    print(f"\n{'='*60}")
    print("ANALYSIS SUMMARY")
    print("=" * 60)
    print("Based on the analysis:")
    print("1. CMS data is available as Excel files (.xlsx)")
    print("2. Data includes hospital information and statistics")
    print("3. Need to find the right sheets and columns for our hospitals")
    print("4. Quality measures data may be available through other endpoints")
    
    print(f"\nNext steps:")
    print("1. Download and analyze Excel files for hospital data")
    print("2. Extract data for Mayo Clinic (CCN: 240001) and Cleveland Clinic (CCN: 360001)")
    print("3. Find quality measures data for SEF framework validation")
    print("4. Apply SEF framework to the extracted data")

if __name__ == "__main__":
    main()
