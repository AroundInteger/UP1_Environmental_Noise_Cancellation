#!/usr/bin/env python3
"""
CMS Data Download and Analysis Script

We found that direct ZIP file downloads are accessible. Let's download and analyze
the CMS Program Statistics data to see what hospital data we can access.
"""

import requests
import zipfile
import pandas as pd
import io
import os
import time
from datetime import datetime

def download_cms_zip_file(url, filename):
    """
    Download a CMS ZIP file and extract its contents
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
                
                # Try to read CSV files
                csv_files = [f for f in file_list if f.endswith('.csv')]
                if csv_files:
                    print(f"\n📊 CSV files found: {len(csv_files)}")
                    for csv_file in csv_files:
                        print(f"  Analyzing: {csv_file}")
                        try:
                            # Read the CSV file
                            with zip_ref.open(csv_file) as f:
                                df = pd.read_csv(f, nrows=10)  # Read first 10 rows
                                print(f"    Shape: {df.shape}")
                                print(f"    Columns: {list(df.columns)}")
                                
                                # Look for our target hospitals
                                if 'CCN' in df.columns or 'Provider ID' in df.columns:
                                    ccn_col = 'CCN' if 'CCN' in df.columns else 'Provider ID'
                                    mayo_data = df[df[ccn_col] == '240001']
                                    cleveland_data = df[df[ccn_col] == '360001']
                                    print(f"    🏥 Mayo Clinic records: {len(mayo_data)}")
                                    print(f"    🏥 Cleveland Clinic records: {len(cleveland_data)}")
                                
                                # Show sample data
                                print(f"    Sample data:")
                                print(df.head(3).to_string())
                                
                        except Exception as e:
                            print(f"    ⚠️ Error reading CSV: {str(e)}")
                else:
                    print(f"  ❌ No CSV files found in ZIP")
            
            return True
            
        else:
            print(f"❌ Download failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"⚠️ Download error: {str(e)}")
        return False

def analyze_cms_data_structure():
    """
    Analyze the structure of CMS data to understand what's available
    """
    print("=== ANALYZING CMS DATA STRUCTURE ===")
    print("Goal: Understand what hospital data is available")
    print("=" * 60)
    
    # Test with the most recent ZIP file
    test_url = "https://data.cms.gov/sites/default/files/2023-02/CPS%20MDCR%20INPT%202021.zip"
    test_filename = "cms_inpatient_2021.zip"
    
    success = download_cms_zip_file(test_url, test_filename)
    
    if success:
        print(f"\n✅ Successfully downloaded and analyzed CMS data")
        print(f"📁 File saved as: {test_filename}")
        
        # Clean up the downloaded file
        if os.path.exists(test_filename):
            os.remove(test_filename)
            print(f"🗑️ Cleaned up temporary file: {test_filename}")
    else:
        print(f"\n❌ Failed to download CMS data")

def test_multiple_cms_datasets():
    """
    Test downloading multiple CMS datasets to see what's available
    """
    print(f"\n{'='*60}")
    print("TESTING MULTIPLE CMS DATASETS")
    print("=" * 60)
    
    # CMS datasets to test
    datasets = [
        {
            'name': 'Medicare Inpatient Hospitals 2021',
            'url': 'https://data.cms.gov/sites/default/files/2023-02/CPS%20MDCR%20INPT%202021.zip',
            'filename': 'cms_inpatient_2021.zip'
        },
        {
            'name': 'Medicare Inpatient Hospitals 2020',
            'url': 'https://data.cms.gov/sites/default/files/2022-02/CPS%20MDCR%20INPT%202020.zip',
            'filename': 'cms_inpatient_2020.zip'
        },
        {
            'name': 'Medicare Inpatient Hospitals 2018',
            'url': 'https://data.cms.gov/sites/default/files/2020-11/CPS%20MDCR%20INPT%20HOSP%20ALL%202018.zip',
            'filename': 'cms_inpatient_2018.zip'
        }
    ]
    
    successful_downloads = []
    
    for dataset in datasets:
        print(f"\n📊 Testing: {dataset['name']}")
        success = download_cms_zip_file(dataset['url'], dataset['filename'])
        
        if success:
            successful_downloads.append(dataset)
            
            # Clean up the downloaded file
            if os.path.exists(dataset['filename']):
                os.remove(dataset['filename'])
                print(f"🗑️ Cleaned up: {dataset['filename']}")
        
        time.sleep(2)  # Be respectful to the server
    
    return successful_downloads

def search_for_hospital_data():
    """
    Search for specific hospital data in CMS datasets
    """
    print(f"\n{'='*60}")
    print("SEARCHING FOR HOSPITAL DATA")
    print("=" * 60)
    
    # Download and analyze the most recent dataset
    url = "https://data.cms.gov/sites/default/files/2023-02/CPS%20MDCR%20INPT%202021.zip"
    filename = "cms_hospital_search.zip"
    
    print(f"Downloading dataset for hospital search...")
    success = download_cms_zip_file(url, filename)
    
    if success:
        print(f"\n🔍 Searching for Mayo Clinic and Cleveland Clinic data...")
        
        # Extract and search the ZIP file
        with zipfile.ZipFile(filename, 'r') as zip_ref:
            file_list = zip_ref.namelist()
            csv_files = [f for f in file_list if f.endswith('.csv')]
            
            for csv_file in csv_files:
                print(f"\n📊 Analyzing: {csv_file}")
                try:
                    with zip_ref.open(csv_file) as f:
                        df = pd.read_csv(f)
                        print(f"  Total records: {len(df)}")
                        print(f"  Columns: {list(df.columns)}")
                        
                        # Look for hospital identification columns
                        hospital_id_cols = [col for col in df.columns if any(keyword in col.lower() 
                                           for keyword in ['ccn', 'provider', 'hospital', 'id'])]
                        
                        if hospital_id_cols:
                            print(f"  Hospital ID columns: {hospital_id_cols}")
                            
                            # Search for our target hospitals
                            for col in hospital_id_cols:
                                mayo_data = df[df[col].astype(str).str.contains('240001', na=False)]
                                cleveland_data = df[df[col].astype(str).str.contains('360001', na=False)]
                                
                                if len(mayo_data) > 0:
                                    print(f"  🏥 Mayo Clinic found in {col}: {len(mayo_data)} records")
                                    print(f"    Sample data:")
                                    print(mayo_data.head(2).to_string())
                                
                                if len(cleveland_data) > 0:
                                    print(f"  🏥 Cleveland Clinic found in {col}: {len(cleveland_data)} records")
                                    print(f"    Sample data:")
                                    print(cleveland_data.head(2).to_string())
                        else:
                            print(f"  ❌ No hospital ID columns found")
                            
                except Exception as e:
                    print(f"  ⚠️ Error analyzing {csv_file}: {str(e)}")
        
        # Clean up
        if os.path.exists(filename):
            os.remove(filename)
            print(f"\n🗑️ Cleaned up: {filename}")
    
    return success

def main():
    """
    Main function to download and analyze CMS data
    """
    print("Starting CMS Data Download and Analysis...")
    print("Goal: Download and analyze CMS Program Statistics data")
    print("Focus: Find hospital data for Mayo Clinic and Cleveland Clinic")
    
    # Step 1: Analyze CMS data structure
    analyze_cms_data_structure()
    
    # Step 2: Test multiple datasets
    successful_downloads = test_multiple_cms_datasets()
    
    # Step 3: Search for hospital data
    hospital_data_found = search_for_hospital_data()
    
    print(f"\n{'='*60}")
    print("ANALYSIS SUMMARY")
    print("=" * 60)
    print(f"✅ Successful downloads: {len(successful_downloads)}")
    print(f"🏥 Hospital data found: {hospital_data_found}")
    
    if successful_downloads:
        print(f"\n🎉 SUCCESS: Found accessible CMS datasets!")
        print("Available datasets:")
        for dataset in successful_downloads:
            print(f"  - {dataset['name']}")
    else:
        print(f"\n⚠️ No successful downloads")
    
    if hospital_data_found:
        print(f"\n🎉 SUCCESS: Found hospital data!")
        print("Next steps:")
        print("1. Download full datasets")
        print("2. Extract hospital-specific data")
        print("3. Apply SEF framework")
    else:
        print(f"\n⚠️ No hospital data found")
        print("May need to investigate alternative data sources")

if __name__ == "__main__":
    main()
