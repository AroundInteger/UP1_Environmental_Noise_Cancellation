#!/usr/bin/env python3
"""
CMS Hospital Data Access Exploration Script

This script explores the CMS Hospital Compare data portal to understand:
1. Available datasets and their structure
2. Access methods (API vs direct download)
3. Data formats and requirements
4. Permission and authentication requirements

We'll do this iteratively to ensure we get it right.
"""

import requests
import json
import time
from datetime import datetime
import os

def explore_cms_data_portal():
    """
    Explore the CMS data portal to understand available datasets
    """
    print("=== CMS HOSPITAL DATA ACCESS EXPLORATION ===")
    print("Goal: Understand CMS data access without downloading data yet")
    print("=" * 60)
    
    # CMS data portal URLs to explore
    cms_urls = {
        'main_portal': 'https://data.cms.gov/provider-data/',
        'api_base': 'https://data.cms.gov/api/views',
        'hospital_compare': 'https://data.cms.gov/provider-data/dataset/hospital-compare',
        'quality_measures': 'https://data.cms.gov/provider-data/dataset/quality-measures'
    }
    
    print("Exploring CMS data portal structure...")
    
    for name, url in cms_urls.items():
        print(f"\n{name.upper()}: {url}")
        try:
            response = requests.get(url, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                print(f"  ✅ Accessible")
                # Check if it's JSON (API) or HTML (web page)
                try:
                    data = response.json()
                    print(f"  📊 JSON Response: {len(data)} items")
                    if isinstance(data, list) and len(data) > 0:
                        print(f"  📋 Sample keys: {list(data[0].keys()) if isinstance(data[0], dict) else 'Not a dict'}")
                except:
                    print(f"  🌐 HTML Response: {len(response.text)} characters")
                    # Look for dataset links in HTML
                    if 'dataset' in response.text.lower():
                        print(f"  🔍 Contains dataset references")
            else:
                print(f"  ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful to the server
    
    return cms_urls

def explore_cms_api_structure():
    """
    Explore the CMS API structure to understand available endpoints
    """
    print(f"\n{'='*60}")
    print("EXPLORING CMS API STRUCTURE")
    print("=" * 60)
    
    api_base = "https://data.cms.gov/api/views"
    
    try:
        print(f"Testing API base: {api_base}")
        response = requests.get(api_base, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"✅ API accessible: {len(data)} datasets available")
                
                # Look for hospital-related datasets
                hospital_datasets = []
                for item in data:
                    if isinstance(item, dict) and 'name' in item:
                        name = item['name'].lower()
                        if any(keyword in name for keyword in ['hospital', 'compare', 'quality', 'performance']):
                            hospital_datasets.append({
                                'name': item['name'],
                                'id': item.get('id', 'N/A'),
                                'description': item.get('description', 'N/A')[:100] + '...' if item.get('description') else 'N/A'
                            })
                
                print(f"\n🏥 HOSPITAL-RELATED DATASETS FOUND: {len(hospital_datasets)}")
                for i, dataset in enumerate(hospital_datasets[:5]):  # Show first 5
                    print(f"  {i+1}. {dataset['name']}")
                    print(f"     ID: {dataset['id']}")
                    print(f"     Description: {dataset['description']}")
                
                if len(hospital_datasets) > 5:
                    print(f"     ... and {len(hospital_datasets) - 5} more")
                
                return hospital_datasets
                
            except json.JSONDecodeError:
                print("❌ API response is not JSON")
                return []
        else:
            print(f"❌ API not accessible: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"⚠️ Error accessing API: {str(e)}")
        return []

def explore_specific_dataset(dataset_id):
    """
    Explore a specific dataset to understand its structure
    """
    print(f"\n{'='*60}")
    print(f"EXPLORING DATASET: {dataset_id}")
    print("=" * 60)
    
    # Try different API endpoints for the dataset
    endpoints = [
        f"https://data.cms.gov/api/views/{dataset_id}",
        f"https://data.cms.gov/api/views/{dataset_id}/rows.json",
        f"https://data.cms.gov/api/views/{dataset_id}/columns.json"
    ]
    
    for endpoint in endpoints:
        print(f"\nTesting: {endpoint}")
        try:
            response = requests.get(endpoint, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    print(f"  ✅ JSON Response: {len(data)} items")
                    
                    if 'rows.json' in endpoint:
                        print(f"  📊 Data rows available")
                        if isinstance(data, list) and len(data) > 0:
                            print(f"  📋 Sample row keys: {list(data[0].keys()) if isinstance(data[0], dict) else 'Not a dict'}")
                    elif 'columns.json' in endpoint:
                        print(f"  📋 Column structure available")
                        if isinstance(data, list):
                            print(f"  📊 Columns: {[col.get('name', 'N/A') for col in data[:5]]}")
                    else:
                        print(f"  📋 Dataset metadata available")
                        if isinstance(data, dict):
                            print(f"  📊 Keys: {list(data.keys())}")
                            
                except json.JSONDecodeError:
                    print(f"  ❌ Response is not JSON")
            else:
                print(f"  ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def check_data_access_requirements():
    """
    Check what requirements exist for accessing CMS data
    """
    print(f"\n{'='*60}")
    print("CHECKING DATA ACCESS REQUIREMENTS")
    print("=" * 60)
    
    # Check for authentication requirements
    test_url = "https://data.cms.gov/api/views"
    
    print("Testing authentication requirements...")
    
    # Test without authentication
    try:
        response = requests.get(test_url, timeout=10)
        print(f"Without authentication: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ No authentication required for basic access")
        elif response.status_code == 401:
            print("🔐 Authentication required")
        elif response.status_code == 403:
            print("🚫 Access forbidden - may need special permissions")
        else:
            print(f"⚠️ Unexpected status: {response.status_code}")
            
    except Exception as e:
        print(f"⚠️ Error testing access: {str(e)}")
    
    # Check for rate limiting
    print("\nTesting rate limiting...")
    try:
        responses = []
        for i in range(3):
            response = requests.get(test_url, timeout=5)
            responses.append(response.status_code)
            time.sleep(0.5)
        
        print(f"Rate limit test results: {responses}")
        if all(status == 200 for status in responses):
            print("✅ No rate limiting detected")
        else:
            print("⚠️ Possible rate limiting or access issues")
            
    except Exception as e:
        print(f"⚠️ Error testing rate limiting: {str(e)}")

def main():
    """
    Main exploration function
    """
    print("Starting CMS Hospital Data Access Exploration...")
    print("This is an iterative process to understand data access requirements.")
    print("We'll explore step by step to ensure we get it right.")
    
    # Step 1: Explore CMS data portal
    cms_urls = explore_cms_data_portal()
    
    # Step 2: Explore API structure
    hospital_datasets = explore_cms_api_structure()
    
    # Step 3: Check access requirements
    check_data_access_requirements()
    
    # Step 4: Explore specific datasets if found
    if hospital_datasets:
        print(f"\n{'='*60}")
        print("EXPLORING SPECIFIC HOSPITAL DATASETS")
        print("=" * 60)
        
        # Explore the first few datasets
        for dataset in hospital_datasets[:3]:
            if dataset['id'] != 'N/A':
                explore_specific_dataset(dataset['id'])
    
    print(f"\n{'='*60}")
    print("EXPLORATION SUMMARY")
    print("=" * 60)
    print("Next steps:")
    print("1. Review exploration results")
    print("2. Identify specific datasets for SEF framework")
    print("3. Test data download procedures")
    print("4. Implement data collection if access is confirmed")
    
    return {
        'cms_urls': cms_urls,
        'hospital_datasets': hospital_datasets,
        'exploration_complete': True
    }

if __name__ == "__main__":
    results = main()
    
    if results['exploration_complete']:
        print(f"\n🎉 CMS data access exploration complete!")
        print("Please review the results and let me know:")
        print("1. Are there any permission issues that need to be addressed?")
        print("2. Which datasets look most promising for SEF framework validation?")
        print("3. Should we proceed with data collection or need to apply for permissions?")
    else:
        print(f"\n⚠️ Exploration incomplete - please check the results above")
