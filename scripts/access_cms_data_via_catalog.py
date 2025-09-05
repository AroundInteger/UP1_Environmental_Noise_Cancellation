#!/usr/bin/env python3
"""
CMS Data Access via Catalog Script

Since direct download links aren't working, let's try accessing the data through the
CMS data catalog we found earlier: https://data.cms.gov/data.json
"""

import requests
import json
import pandas as pd
import time
from datetime import datetime

def access_cms_data_catalog():
    """
    Access the CMS data catalog to find actual data sources
    """
    print("=== ACCESSING CMS DATA CATALOG ===")
    print("Goal: Find actual data sources through the catalog")
    print("=" * 60)
    
    catalog_url = "https://data.cms.gov/data.json"
    
    try:
        print(f"Fetching catalog: {catalog_url}")
        response = requests.get(catalog_url, timeout=10)
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"✅ Catalog accessible: {len(data)} items")
                
                # Analyze the structure
                if isinstance(data, dict):
                    print(f"📋 Root keys: {list(data.keys())}")
                    
                    if 'dataset' in data:
                        datasets = data['dataset']
                        print(f"📊 Datasets available: {len(datasets)}")
                        
                        # Look for hospital-related datasets
                        hospital_datasets = []
                        for dataset in datasets:
                            title = dataset.get('title', '').lower()
                            description = dataset.get('description', '').lower()
                            
                            if any(keyword in title or keyword in description for keyword in 
                                   ['hospital', 'compare', 'quality', 'performance', 'outcome']):
                                hospital_datasets.append(dataset)
                        
                        print(f"🏥 Hospital-related datasets: {len(hospital_datasets)}")
                        
                        # Analyze each hospital dataset
                        for i, dataset in enumerate(hospital_datasets):
                            print(f"\n{i+1}. {dataset.get('title', 'No title')}")
                            print(f"   Description: {dataset.get('description', 'No description')[:100]}...")
                            print(f"   Publisher: {dataset.get('publisher', {}).get('name', 'Unknown')}")
                            
                            # Look for download links
                            if 'distribution' in dataset:
                                distributions = dataset['distribution']
                                print(f"   📥 Download options: {len(distributions)}")
                                
                                for j, dist in enumerate(distributions):
                                    print(f"     {j+1}. Format: {dist.get('format', 'Unknown')}")
                                    if 'downloadURL' in dist:
                                        print(f"        URL: {dist['downloadURL']}")
                                    if 'byteSize' in dist:
                                        print(f"        Size: {dist['byteSize']} bytes")
                                    if 'mediaType' in dist:
                                        print(f"        Media Type: {dist['mediaType']}")
                            
                            # Look for accessURL
                            if 'accessURL' in dataset:
                                print(f"   🌐 Access URL: {dataset['accessURL']}")
                        
                        return hospital_datasets
                    else:
                        print("❌ No 'dataset' key found in catalog")
                        return []
                else:
                    print("❌ Catalog data is not a dictionary")
                    return []
                    
            except json.JSONDecodeError as e:
                print(f"❌ JSON parsing failed: {str(e)}")
                return []
        else:
            print(f"❌ Catalog not accessible: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"⚠️ Error accessing catalog: {str(e)}")
        return []

def test_hospital_data_downloads(hospital_datasets):
    """
    Test downloading data from the found hospital datasets
    """
    print(f"\n{'='*60}")
    print("TESTING HOSPITAL DATA DOWNLOADS")
    print("=" * 60)
    
    working_downloads = []
    
    for dataset in hospital_datasets:
        print(f"\n🏥 Testing: {dataset.get('title', 'Unknown')}")
        
        if 'distribution' in dataset:
            for dist in dataset['distribution']:
                if 'downloadURL' in dist:
                    url = dist['downloadURL']
                    format_type = dist.get('format', 'Unknown')
                    
                    print(f"  📥 Testing: {format_type}")
                    print(f"     URL: {url}")
                    
                    try:
                        # Test with HEAD request first
                        response = requests.head(url, timeout=10)
                        print(f"     Status: {response.status_code}")
                        
                        if response.status_code == 200:
                            content_type = response.headers.get('content-type', '')
                            content_length = response.headers.get('content-length')
                            
                            print(f"     ✅ Accessible")
                            print(f"     Content-Type: {content_type}")
                            if content_length:
                                print(f"     Size: {content_length} bytes")
                            
                            # Try to download a small sample
                            if 'csv' in content_type.lower():
                                print(f"     📊 CSV data - testing sample download...")
                                try:
                                    sample_response = requests.get(url, timeout=10, stream=True)
                                    if sample_response.status_code == 200:
                                        # Read first few lines
                                        lines = []
                                        for i, line in enumerate(sample_response.iter_lines(decode_unicode=True)):
                                            if i < 5:  # First 5 lines
                                                lines.append(line)
                                            else:
                                                break
                                        
                                        print(f"     📋 Sample data (first 5 lines):")
                                        for line in lines:
                                            print(f"       {line}")
                                        
                                        working_downloads.append({
                                            'dataset': dataset.get('title', 'Unknown'),
                                            'url': url,
                                            'format': format_type,
                                            'size': content_length
                                        })
                                        
                                except Exception as e:
                                    print(f"     ⚠️ Sample download error: {str(e)}")
                            
                        else:
                            print(f"     ❌ Not accessible: {response.status_code}")
                            
                    except Exception as e:
                        print(f"     ⚠️ Error: {str(e)}")
                    
                    time.sleep(1)
    
    return working_downloads

def search_for_specific_hospitals():
    """
    Search for data specifically for our target hospitals
    """
    print(f"\n{'='*60}")
    print("SEARCHING FOR SPECIFIC HOSPITALS")
    print("=" * 60)
    
    # Our target hospitals
    target_hospitals = {
        'Mayo Clinic': 240001,
        'Cleveland Clinic': 360001
    }
    
    # Try different search approaches
    search_urls = [
        "https://data.cms.gov/provider-data/dataset/hospital-compare",
        "https://data.cms.gov/provider-data/dataset/quality-measures",
        "https://data.cms.gov/provider-data/dataset/patient-safety-indicators"
    ]
    
    for url in search_urls:
        print(f"\n🔍 Searching: {url}")
        try:
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                html_content = response.text
                print(f"  ✅ Page accessible: {len(html_content)} characters")
                
                # Look for our hospital IDs in the content
                for hospital_name, provider_id in target_hospitals.items():
                    if str(provider_id) in html_content:
                        print(f"  🏥 {hospital_name} (ID: {provider_id}) found in content")
                    else:
                        print(f"  ❌ {hospital_name} (ID: {provider_id}) not found in content")
                
                # Look for download or data access patterns
                if 'download' in html_content.lower():
                    print(f"  📥 Download references found")
                if 'csv' in html_content.lower():
                    print(f"  📊 CSV references found")
                if 'api' in html_content.lower():
                    print(f"  🔌 API references found")
                    
            else:
                print(f"  ❌ Page not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def main():
    """
    Main function to access CMS data via catalog
    """
    print("Starting CMS Data Access via Catalog...")
    print("Goal: Find and test actual data downloads for hospital data")
    
    # Step 1: Access the data catalog
    hospital_datasets = access_cms_data_catalog()
    
    if hospital_datasets:
        # Step 2: Test downloads from found datasets
        working_downloads = test_hospital_data_downloads(hospital_datasets)
        
        # Step 3: Search for specific hospitals
        search_for_specific_hospitals()
        
        print(f"\n{'='*60}")
        print("ACCESS SUMMARY")
        print("=" * 60)
        print(f"📊 Hospital datasets found: {len(hospital_datasets)}")
        print(f"✅ Working downloads: {len(working_downloads)}")
        
        if working_downloads:
            print(f"\n🎉 SUCCESS: Found working data downloads!")
            print("Working downloads:")
            for download in working_downloads:
                print(f"  - {download['dataset']} ({download['format']})")
                print(f"    URL: {download['url']}")
        else:
            print(f"\n⚠️ No working downloads found")
            print("May need to investigate alternative access methods")
    else:
        print(f"\n❌ No hospital datasets found in catalog")
        print("May need to investigate alternative data sources")
    
    print(f"\nNext steps:")
    print("1. Review working downloads")
    print("2. Test downloading full datasets")
    print("3. Extract data for specific hospitals")
    print("4. Apply SEF framework to downloaded data")

if __name__ == "__main__":
    main()
