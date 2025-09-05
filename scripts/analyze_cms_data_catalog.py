#!/usr/bin/env python3
"""
CMS Data Catalog Analysis Script

We found that https://data.cms.gov/data.json returns JSON data.
Let's analyze this to understand the actual CMS data structure.
"""

import requests
import json
import time
from datetime import datetime

def analyze_cms_data_catalog():
    """
    Analyze the CMS data catalog to understand available datasets
    """
    print("=== CMS DATA CATALOG ANALYSIS ===")
    print("Goal: Understand the actual CMS data structure")
    print("=" * 60)
    
    catalog_url = "https://data.cms.gov/data.json"
    
    try:
        print(f"Fetching CMS data catalog: {catalog_url}")
        response = requests.get(catalog_url, timeout=10)
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"✅ Catalog accessible: {len(data)} items")
                
                # Analyze the structure
                print(f"\n📋 Catalog Structure Analysis:")
                if isinstance(data, dict):
                    print(f"  Root keys: {list(data.keys())}")
                    
                    # Look for datasets
                    if 'dataset' in data:
                        datasets = data['dataset']
                        print(f"  📊 Datasets found: {len(datasets)}")
                        
                        # Analyze first few datasets
                        print(f"\n🔍 Sample Datasets:")
                        for i, dataset in enumerate(datasets[:5]):
                            print(f"  {i+1}. {dataset.get('title', 'No title')}")
                            print(f"     Description: {dataset.get('description', 'No description')[:100]}...")
                            print(f"     Publisher: {dataset.get('publisher', {}).get('name', 'Unknown')}")
                            
                            # Look for hospital-related datasets
                            title = dataset.get('title', '').lower()
                            description = dataset.get('description', '').lower()
                            if 'hospital' in title or 'hospital' in description:
                                print(f"     🏥 HOSPITAL DATASET FOUND!")
                                
                                # Look for download links
                                if 'distribution' in dataset:
                                    distributions = dataset['distribution']
                                    print(f"     📥 Download options: {len(distributions)}")
                                    for dist in distributions:
                                        if 'downloadURL' in dist:
                                            print(f"       - {dist['downloadURL']}")
                                            print(f"         Format: {dist.get('format', 'Unknown')}")
                                            print(f"         Size: {dist.get('byteSize', 'Unknown')}")
                
                elif isinstance(data, list):
                    print(f"  📊 List of {len(data)} items")
                    for i, item in enumerate(data[:3]):
                        print(f"  {i+1}. {item}")
                
                return data
                
            except json.JSONDecodeError as e:
                print(f"❌ JSON parsing failed: {str(e)}")
                return None
        else:
            print(f"❌ Catalog not accessible: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"⚠️ Error accessing catalog: {str(e)}")
        return None

def find_hospital_datasets(catalog_data):
    """
    Find hospital-related datasets in the catalog
    """
    print(f"\n{'='*60}")
    print("FINDING HOSPITAL-RELATED DATASETS")
    print("=" * 60)
    
    if not catalog_data or 'dataset' not in catalog_data:
        print("❌ No datasets found in catalog")
        return []
    
    datasets = catalog_data['dataset']
    hospital_datasets = []
    
    for dataset in datasets:
        title = dataset.get('title', '').lower()
        description = dataset.get('description', '').lower()
        
        # Look for hospital-related keywords
        hospital_keywords = ['hospital', 'compare', 'quality', 'performance', 'outcome']
        
        if any(keyword in title or keyword in description for keyword in hospital_keywords):
            hospital_datasets.append(dataset)
    
    print(f"🏥 Hospital-related datasets found: {len(hospital_datasets)}")
    
    for i, dataset in enumerate(hospital_datasets):
        print(f"\n{i+1}. {dataset.get('title', 'No title')}")
        print(f"   Description: {dataset.get('description', 'No description')[:150]}...")
        print(f"   Publisher: {dataset.get('publisher', {}).get('name', 'Unknown')}")
        
        # Check for download options
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
    
    return hospital_datasets

def test_download_urls(hospital_datasets):
    """
    Test download URLs to see if they're accessible
    """
    print(f"\n{'='*60}")
    print("TESTING DOWNLOAD URLS")
    print("=" * 60)
    
    accessible_urls = []
    
    for dataset in hospital_datasets:
        if 'distribution' in dataset:
            for dist in dataset['distribution']:
                if 'downloadURL' in dist:
                    url = dist['downloadURL']
                    format_type = dist.get('format', 'Unknown')
                    
                    print(f"\nTesting: {url}")
                    print(f"  Format: {format_type}")
                    
                    try:
                        # Test with HEAD request to avoid downloading large files
                        response = requests.head(url, timeout=10)
                        print(f"  Status: {response.status_code}")
                        
                        if response.status_code == 200:
                            print(f"  ✅ Accessible")
                            content_length = response.headers.get('content-length')
                            if content_length:
                                print(f"  📊 Size: {content_length} bytes")
                            
                            accessible_urls.append({
                                'url': url,
                                'format': format_type,
                                'dataset': dataset.get('title', 'Unknown'),
                                'size': content_length
                            })
                        else:
                            print(f"  ❌ Not accessible: {response.status_code}")
                            
                    except Exception as e:
                        print(f"  ⚠️ Error: {str(e)}")
    
    return accessible_urls

def main():
    """
    Main analysis function
    """
    print("Starting CMS Data Catalog Analysis...")
    print("This will help us understand the actual CMS data structure and access methods.")
    
    # Step 1: Analyze the data catalog
    catalog_data = analyze_cms_data_catalog()
    
    if catalog_data:
        # Step 2: Find hospital-related datasets
        hospital_datasets = find_hospital_datasets(catalog_data)
        
        if hospital_datasets:
            # Step 3: Test download URLs
            accessible_urls = test_download_urls(hospital_datasets)
            
            print(f"\n{'='*60}")
            print("ANALYSIS SUMMARY")
            print("=" * 60)
            print(f"✅ CMS data catalog accessible")
            print(f"🏥 Hospital datasets found: {len(hospital_datasets)}")
            print(f"📥 Accessible download URLs: {len(accessible_urls)}")
            
            if accessible_urls:
                print(f"\n🎉 SUCCESS: Found accessible hospital data!")
                print("Available datasets:")
                for url_info in accessible_urls:
                    print(f"  - {url_info['dataset']} ({url_info['format']})")
                    print(f"    URL: {url_info['url']}")
                
                print(f"\nNext steps:")
                print("1. Review accessible datasets")
                print("2. Test actual data download")
                print("3. Analyze data structure for SEF framework")
                print("4. Implement data collection if suitable")
            else:
                print(f"\n⚠️ No accessible download URLs found")
                print("May need to investigate alternative access methods")
        else:
            print(f"\n⚠️ No hospital-related datasets found")
            print("May need to investigate alternative data sources")
    else:
        print(f"\n❌ Could not access CMS data catalog")
        print("May need to investigate alternative access methods")

if __name__ == "__main__":
    main()
