#!/usr/bin/env python3
"""
CMS Program Statistics Data Access Test Script

Based on the CPS Glossary, we now know that CMS has comprehensive hospital data
through the Program Statistics system. Let's test accessing this data.
"""

import requests
import json
import pandas as pd
import time
from datetime import datetime

def test_cms_program_statistics_access():
    """
    Test accessing CMS Program Statistics data
    """
    print("=== TESTING CMS PROGRAM STATISTICS ACCESS ===")
    print("Goal: Access hospital data through CMS Program Statistics")
    print("=" * 60)
    
    # CMS Program Statistics URLs based on the glossary
    program_stats_urls = [
        "https://data.cms.gov/provider-data/dataset/cms-program-statistics",
        "https://data.cms.gov/provider-data/dataset/medicare-inpatient-hospitals",
        "https://data.cms.gov/provider-data/dataset/medicare-outpatient-hospitals",
        "https://data.cms.gov/provider-data/dataset/hospital-quality-measures",
        "https://data.cms.gov/provider-data/dataset/patient-safety-indicators"
    ]
    
    accessible_urls = []
    
    for url in program_stats_urls:
        print(f"\nTesting: {url}")
        try:
            response = requests.get(url, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                print(f"  ✅ Accessible")
                print(f"  Content-Type: {content_type}")
                
                if 'html' in content_type.lower():
                    html_content = response.text
                    print(f"  📄 HTML content: {len(html_content)} characters")
                    
                    # Look for download links or data access information
                    if 'download' in html_content.lower():
                        print(f"  📥 Download references found")
                    if 'csv' in html_content.lower():
                        print(f"  📊 CSV references found")
                    if 'api' in html_content.lower():
                        print(f"  🔌 API references found")
                    if 'hospital' in html_content.lower():
                        print(f"  🏥 Hospital data references found")
                
                accessible_urls.append(url)
                
            else:
                print(f"  ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)
    
    return accessible_urls

def test_hospital_specific_data_access():
    """
    Test accessing data for specific hospitals using CCN numbers
    """
    print(f"\n{'='*60}")
    print("TESTING HOSPITAL-SPECIFIC DATA ACCESS")
    print("=" * 60)
    
    # Our target hospitals with CCN numbers
    hospitals = {
        'Mayo Clinic': {
            'ccn': '240001',
            'name': 'Mayo Clinic Hospital - Rochester',
            'location': 'Rochester, MN'
        },
        'Cleveland Clinic': {
            'ccn': '360001',
            'name': 'Cleveland Clinic Main Campus',
            'location': 'Cleveland, OH'
        }
    }
    
    # Test different ways to access hospital-specific data
    for hospital_name, info in hospitals.items():
        print(f"\n🏥 {hospital_name} (CCN: {info['ccn']})")
        print(f"   Location: {info['location']}")
        
        # Test different URL patterns for hospital-specific data
        test_urls = [
            f"https://data.cms.gov/provider-data/dataset/hospital-compare?ccn={info['ccn']}",
            f"https://data.cms.gov/provider-data/dataset/medicare-inpatient-hospitals?ccn={info['ccn']}",
            f"https://data.cms.gov/provider-data/dataset/patient-safety-indicators?ccn={info['ccn']}",
            f"https://data.cms.gov/api/views/hospital-compare/rows.csv?ccn={info['ccn']}",
            f"https://data.cms.gov/api/views/medicare-inpatient-hospitals/rows.csv?ccn={info['ccn']}"
        ]
        
        for url in test_urls:
            print(f"  Testing: {url}")
            try:
                response = requests.get(url, timeout=10)
                print(f"    Status: {response.status_code}")
                
                if response.status_code == 200:
                    content_type = response.headers.get('content-type', '')
                    print(f"    ✅ Accessible")
                    print(f"    Content-Type: {content_type}")
                    
                    if 'csv' in content_type.lower():
                        print(f"    📊 CSV data available")
                        # Try to read a small sample
                        try:
                            df = pd.read_csv(url, nrows=5)
                            print(f"    📋 Sample data shape: {df.shape}")
                            print(f"    📋 Columns: {list(df.columns)}")
                        except Exception as e:
                            print(f"    ⚠️ CSV parsing error: {str(e)}")
                    elif 'json' in content_type.lower():
                        print(f"    📊 JSON data available")
                    else:
                        print(f"    🌐 HTML content: {len(response.text)} characters")
                else:
                    print(f"    ❌ Not accessible: {response.status_code}")
                    
            except Exception as e:
                print(f"    ⚠️ Error: {str(e)}")
            
            time.sleep(0.5)

def test_quality_measures_access():
    """
    Test accessing quality measures data
    """
    print(f"\n{'='*60}")
    print("TESTING QUALITY MEASURES ACCESS")
    print("=" * 60)
    
    # Quality measures based on the glossary
    quality_measures = [
        "patient-safety-indicators",
        "hospital-acquired-conditions",
        "readmission-rates",
        "mortality-rates",
        "patient-experience-measures",
        "timeliness-of-care",
        "effectiveness-of-care"
    ]
    
    for measure in quality_measures:
        print(f"\n📊 Testing: {measure}")
        
        # Test different URL patterns
        test_urls = [
            f"https://data.cms.gov/provider-data/dataset/{measure}",
            f"https://data.cms.gov/api/views/{measure}/rows.csv",
            f"https://data.cms.gov/api/views/{measure}/rows.json"
        ]
        
        for url in test_urls:
            print(f"  Testing: {url}")
            try:
                response = requests.get(url, timeout=10)
                print(f"    Status: {response.status_code}")
                
                if response.status_code == 200:
                    content_type = response.headers.get('content-type', '')
                    print(f"    ✅ Accessible")
                    print(f"    Content-Type: {content_type}")
                    
                    if 'csv' in content_type.lower():
                        print(f"    📊 CSV data available")
                    elif 'json' in content_type.lower():
                        print(f"    📊 JSON data available")
                    else:
                        print(f"    🌐 HTML content: {len(response.text)} characters")
                else:
                    print(f"    ❌ Not accessible: {response.status_code}")
                    
            except Exception as e:
                print(f"    ⚠️ Error: {str(e)}")
            
            time.sleep(0.5)

def test_direct_data_downloads():
    """
    Test direct data downloads for hospital data
    """
    print(f"\n{'='*60}")
    print("TESTING DIRECT DATA DOWNLOADS")
    print("=" * 60)
    
    # Try direct download URLs based on the glossary information
    download_urls = [
        "https://data.cms.gov/sites/default/files/2023-02/CPS%20MDCR%20INPT%202021.zip",
        "https://data.cms.gov/sites/default/files/2022-02/CPS%20MDCR%20INPT%202020.zip",
        "https://data.cms.gov/sites/default/files/2021-01/CPS_MDCR_INPT_HOSP_1-10.zip",
        "https://data.cms.gov/sites/default/files/2020-11/CPS%20MDCR%20INPT%20HOSP%20ALL%202018.zip"
    ]
    
    for url in download_urls:
        print(f"\nTesting: {url}")
        try:
            # Use HEAD request to test without downloading
            response = requests.head(url, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                content_length = response.headers.get('content-length')
                
                print(f"  ✅ Accessible")
                print(f"  Content-Type: {content_type}")
                if content_length:
                    print(f"  Size: {content_length} bytes")
                
                if 'zip' in content_type.lower():
                    print(f"  📦 ZIP file available")
                elif 'csv' in content_type.lower():
                    print(f"  📊 CSV file available")
                    
            else:
                print(f"  ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def main():
    """
    Main function to test CMS Program Statistics access
    """
    print("Starting CMS Program Statistics Data Access Tests...")
    print("Based on CPS Glossary findings")
    print("Goal: Access hospital data for Mayo Clinic and Cleveland Clinic")
    
    # Step 1: Test Program Statistics access
    accessible_urls = test_cms_program_statistics_access()
    
    # Step 2: Test hospital-specific data access
    test_hospital_specific_data_access()
    
    # Step 3: Test quality measures access
    test_quality_measures_access()
    
    # Step 4: Test direct data downloads
    test_direct_data_downloads()
    
    print(f"\n{'='*60}")
    print("TEST SUMMARY")
    print("=" * 60)
    print(f"✅ Accessible Program Statistics URLs: {len(accessible_urls)}")
    
    if accessible_urls:
        print(f"\n🎉 SUCCESS: Found accessible CMS Program Statistics data!")
        print("Accessible URLs:")
        for url in accessible_urls:
            print(f"  - {url}")
    else:
        print(f"\n⚠️ No accessible Program Statistics URLs found")
        print("May need to investigate alternative access methods")
    
    print(f"\nNext steps:")
    print("1. Review accessible URLs")
    print("2. Test downloading actual data")
    print("3. Extract hospital-specific data")
    print("4. Apply SEF framework to downloaded data")

if __name__ == "__main__":
    main()
