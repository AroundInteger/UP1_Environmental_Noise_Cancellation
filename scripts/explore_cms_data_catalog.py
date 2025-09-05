#!/usr/bin/env python3
"""
Explore the CMS data.json catalog and provider-data API
to find actual hospital performance datasets
"""

import requests
import json
import time

def explore_data_catalog():
    """Explore the main CMS data catalog"""
    print("🔍 Exploring CMS Data Catalog")
    print("=" * 40)
    
    url = "https://data.cms.gov/data.json"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Catalog type: {data.get('@type', 'Unknown')}")
            print(f"Context: {data.get('@context', 'Unknown')}")
            
            # Look for datasets
            datasets = data.get('dataset', [])
            print(f"\n📊 Found {len(datasets)} datasets in catalog")
            
            # Look for hospital or provider-related datasets
            hospital_datasets = []
            for dataset in datasets:
                title = dataset.get('title', '').lower()
                description = dataset.get('description', '').lower()
                
                if any(keyword in title or keyword in description for keyword in 
                      ['hospital', 'provider', 'quality', 'patient', 'safety', 'mortality', 'readmission']):
                    hospital_datasets.append(dataset)
            
            print(f"🏥 Found {len(hospital_datasets)} hospital/provider-related datasets:")
            
            for i, dataset in enumerate(hospital_datasets[:10]):  # Show first 10
                title = dataset.get('title', 'No title')
                description = dataset.get('description', 'No description')
                print(f"\n{i+1}. {title}")
                print(f"   Description: {description[:100]}...")
                
                # Look for download links
                distribution = dataset.get('distribution', [])
                if distribution:
                    print(f"   Download options: {len(distribution)}")
                    for dist in distribution[:2]:  # Show first 2
                        format_type = dist.get('format', 'Unknown')
                        download_url = dist.get('downloadURL', 'No URL')
                        print(f"     - {format_type}: {download_url}")
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def explore_provider_data_api():
    """Explore the provider-data API"""
    print("\n🔍 Exploring Provider Data API")
    print("=" * 40)
    
    url = "https://data.cms.gov/provider-data/api"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"API version: {data.get('version', 'Unknown')}")
            print(f"API URL: {data.get('url', 'Unknown')}")
            
            # Try to access the API URL
            api_url = data.get('url')
            if api_url:
                print(f"\n🔗 Testing API URL: {api_url}")
                try:
                    api_response = requests.get(api_url, timeout=10)
                    print(f"API Status: {api_response.status_code}")
                    print(f"API Content-Type: {api_response.headers.get('content-type', 'Unknown')}")
                    
                    if api_response.status_code == 200:
                        if 'application/json' in api_response.headers.get('content-type', ''):
                            api_data = api_response.json()
                            print(f"API Response keys: {list(api_data.keys()) if isinstance(api_data, dict) else 'Not a dict'}")
                        else:
                            print(f"API Response preview: {api_response.text[:200]}...")
                    else:
                        print(f"API not accessible: {api_response.status_code}")
                        
                except Exception as e:
                    print(f"API Error: {str(e)}")
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def test_hospital_specific_endpoints():
    """Test hospital-specific data endpoints"""
    print("\n🔍 Testing Hospital-Specific Endpoints")
    print("=" * 40)
    
    # Test different patterns for hospital-specific data
    test_patterns = [
        "https://data.cms.gov/provider-data/api/hospitals",
        "https://data.cms.gov/provider-data/api/hospital-compare",
        "https://data.cms.gov/provider-data/api/quality-measures",
        "https://data.cms.gov/provider-data/api/patient-safety",
        "https://data.cms.gov/provider-data/dataset/hospital-compare/data",
        "https://data.cms.gov/provider-data/dataset/patient-safety-indicators/data",
    ]
    
    for url in test_patterns:
        try:
            response = requests.get(url, timeout=10)
            print(f"\n🔗 {url}")
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                print(f"   Content-Type: {content_type}")
                
                if 'application/json' in content_type:
                    try:
                        data = response.json()
                        if isinstance(data, dict):
                            print(f"   JSON keys: {list(data.keys())}")
                        elif isinstance(data, list):
                            print(f"   JSON array with {len(data)} items")
                        else:
                            print(f"   JSON type: {type(data)}")
                    except:
                        print("   JSON parsing failed")
                else:
                    print(f"   Content preview: {response.text[:100]}...")
            else:
                print(f"   ❌ Not accessible")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful

def main():
    explore_data_catalog()
    explore_provider_data_api()
    test_hospital_specific_endpoints()
    
    print("\n" + "=" * 40)
    print("🎯 NEXT STEPS:")
    print("1. Review catalog datasets for hospital data")
    print("2. Test API endpoints for direct data access")
    print("3. Identify specific datasets for Mayo/Cleveland Clinic")
    print("4. Implement data collection for SEF framework validation")

if __name__ == "__main__":
    main()
