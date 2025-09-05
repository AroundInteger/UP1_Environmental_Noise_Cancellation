#!/usr/bin/env python3
"""
Explore Government Open Data sources for SEF framework validation
Focus on public sector performance metrics, competitive measurement
"""

import requests
import json
import time
import pandas as pd
from io import StringIO

def explore_data_gov_uk():
    """Explore UK Government Open Data portal"""
    print("🔍 Exploring UK Government Open Data")
    print("=" * 50)
    
    # UK Government Open Data portal
    url = "https://data.gov.uk/api/3/action/package_list"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            packages = data.get('result', [])
            print(f"📊 Found {len(packages)} datasets available")
            
            # Look for performance-related datasets
            performance_keywords = ['performance', 'efficiency', 'quality', 'outcome', 'metric', 'kpi', 'benchmark']
            performance_datasets = []
            
            for package in packages[:100]:  # Check first 100
                if any(keyword in package.lower() for keyword in performance_keywords):
                    performance_datasets.append(package)
            
            print(f"🏆 Found {len(performance_datasets)} performance-related datasets:")
            for dataset in performance_datasets[:10]:  # Show first 10
                print(f"   - {dataset}")
            
            # Get details for a specific performance dataset
            if performance_datasets:
                explore_specific_dataset(performance_datasets[0])
            
        else:
            print(f"❌ API request failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def explore_specific_dataset(dataset_name):
    """Explore a specific dataset for performance data"""
    print(f"\n🔍 Exploring Dataset: {dataset_name}")
    print("-" * 50)
    
    # Get dataset details
    url = f"https://data.gov.uk/api/3/action/package_show"
    params = {'id': dataset_name}
    
    try:
        response = requests.get(url, params=params, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            dataset_info = data.get('result', {})
            
            print(f"📊 Dataset Information:")
            print(f"   Title: {dataset_info.get('title', 'Unknown')}")
            print(f"   Description: {dataset_info.get('notes', 'No description')[:200]}...")
            print(f"   Organization: {dataset_info.get('organization', {}).get('title', 'Unknown')}")
            
            # Look for resources (data files)
            resources = dataset_info.get('resources', [])
            print(f"   Resources: {len(resources)}")
            
            for resource in resources[:5]:  # Show first 5
                name = resource.get('name', 'Unknown')
                format_type = resource.get('format', 'Unknown')
                url = resource.get('url', 'No URL')
                print(f"      - {name} ({format_type}): {url}")
            
            # Try to download the first CSV resource
            csv_resources = [r for r in resources if r.get('format', '').lower() == 'csv']
            if csv_resources:
                download_csv_data(dataset_name, csv_resources[0])
        
        else:
            print(f"❌ Dataset request failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def download_csv_data(dataset_name, resource):
    """Download and analyze CSV data"""
    print(f"\n📥 Downloading CSV Data: {resource.get('name', 'Unknown')}")
    print("-" * 50)
    
    url = resource.get('url', '')
    if not url:
        print("❌ No URL available")
        return None
    
    try:
        response = requests.get(url, timeout=30)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            print(f"✅ Data downloaded successfully!")
            print(f"Content-Type: {response.headers.get('content-type', 'Unknown')}")
            print(f"Content-Length: {len(response.content)} bytes")
            
            # Try to parse as CSV
            try:
                df = pd.read_csv(StringIO(response.text))
                print(f"📊 CSV loaded successfully:")
                print(f"   Rows: {len(df)}")
                print(f"   Columns: {len(df.columns)}")
                print(f"   Column names: {list(df.columns)}")
                
                # Look for competitive measurement data
                competitive_cols = [col for col in df.columns if any(keyword in col.lower() for keyword in 
                                    ['performance', 'efficiency', 'quality', 'outcome', 'metric', 'score', 'rate', 'percentage'])]
                
                if competitive_cols:
                    print(f"🏆 Competitive measurement columns: {competitive_cols}")
                    
                    # Show sample data
                    print(f"\n📊 Sample data:")
                    print(df[competitive_cols].head())
                
                # Save the data
                filename = f"data/raw/gov_uk_{dataset_name.replace(' ', '_')}.csv"
                df.to_csv(filename, index=False)
                print(f"💾 Data saved to: {filename}")
                
                return df
                
            except Exception as e:
                print(f"❌ CSV parsing failed: {str(e)}")
                print(f"📄 Content preview: {response.text[:500]}...")
                
                # Try to save as text file
                filename = f"data/raw/gov_uk_{dataset_name.replace(' ', '_')}.txt"
                with open(filename, 'w') as f:
                    f.write(response.text)
                print(f"💾 Raw data saved to: {filename}")
        
        else:
            print(f"❌ Download failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    return None

def explore_usa_data_gov():
    """Explore USA Data.gov portal"""
    print("\n🔍 Exploring USA Data.gov Portal")
    print("=" * 50)
    
    # USA Data.gov API
    url = "https://catalog.data.gov/api/3/action/package_list"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            packages = data.get('result', [])
            print(f"📊 Found {len(packages)} datasets available")
            
            # Look for performance-related datasets
            performance_keywords = ['performance', 'efficiency', 'quality', 'outcome', 'metric', 'kpi', 'benchmark']
            performance_datasets = []
            
            for package in packages[:100]:  # Check first 100
                if any(keyword in package.lower() for keyword in performance_keywords):
                    performance_datasets.append(package)
            
            print(f"🏆 Found {len(performance_datasets)} performance-related datasets:")
            for dataset in performance_datasets[:10]:  # Show first 10
                print(f"   - {dataset}")
            
        else:
            print(f"❌ API request failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def explore_canada_open_data():
    """Explore Canada Open Data portal"""
    print("\n🔍 Exploring Canada Open Data Portal")
    print("=" * 50)
    
    # Canada Open Data API
    url = "https://open.canada.ca/data/en/api/3/action/package_list"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            packages = data.get('result', [])
            print(f"📊 Found {len(packages)} datasets available")
            
            # Look for performance-related datasets
            performance_keywords = ['performance', 'efficiency', 'quality', 'outcome', 'metric', 'kpi', 'benchmark']
            performance_datasets = []
            
            for package in packages[:100]:  # Check first 100
                if any(keyword in package.lower() for keyword in performance_keywords):
                    performance_datasets.append(package)
            
            print(f"🏆 Found {len(performance_datasets)} performance-related datasets:")
            for dataset in performance_datasets[:10]:  # Show first 10
                print(f"   - {dataset}")
            
        else:
            print(f"❌ API request failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def main():
    print("🚀 Government Open Data Exploration")
    print("=" * 60)
    print("Goal: Find public sector performance data for SEF framework validation")
    print("Focus: Government performance metrics, public service outcomes")
    
    # Explore different government open data portals
    explore_data_gov_uk()
    explore_usa_data_gov()
    explore_canada_open_data()
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Analyze downloaded government performance data")
    print("2. Apply SEF framework to public sector data")
    print("3. Compare with other data sources")
    print("4. Document findings for SAIL integration")

if __name__ == "__main__":
    main()
