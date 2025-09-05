#!/usr/bin/env python3
"""
Explore MLPerf company-specific benchmark data
Focus on competitive measurement data between Google, Intel, and NVIDIA
"""

import requests
import json
import time
import pandas as pd
from io import StringIO

def explore_company_directory(company_name):
    """Explore a specific company's benchmark data"""
    print(f"\n🔍 Exploring {company_name.upper()} Benchmark Data")
    print("=" * 50)
    
    company_url = f"https://api.github.com/repos/mlcommons/training_results_v0.5/contents/v0.5.0/{company_name}"
    
    try:
        response = requests.get(company_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"📁 {company_name} directory contents ({len(data)} items):")
            
            for item in data[:10]:  # Show first 10
                name = item.get('name', 'Unknown')
                item_type = item.get('type', 'Unknown')
                size = item.get('size', 'Unknown')
                print(f"   - {name} ({item_type}, {size} bytes)")
            
            # Look for benchmark or results directories
            benchmark_dirs = [item for item in data if item.get('type') == 'dir' and 
                            any(keyword in item.get('name', '').lower() for keyword in 
                                ['benchmark', 'result', 'submission', 'data', 'training'])]
            
            if benchmark_dirs:
                print(f"\n📊 Found {len(benchmark_dirs)} potential benchmark directories:")
                for dir_item in benchmark_dirs:
                    print(f"   - {dir_item.get('name')}")
                
                # Explore the first benchmark directory
                if benchmark_dirs:
                    explore_benchmark_directory(company_name, benchmark_dirs[0])
            
            # Look for CSV or data files
            data_files = [item for item in data if item.get('type') == 'file' and 
                         any(keyword in item.get('name', '').lower() for keyword in 
                             ['csv', 'json', 'data', 'result', 'log', 'txt'])]
            
            if data_files:
                print(f"\n📄 Found {len(data_files)} data files:")
                for file_item in data_files:
                    print(f"   - {file_item.get('name')}")
                
                # Try to download the first data file
                if data_files:
                    download_data_file(company_name, data_files[0])
        
        else:
            print(f"❌ {company_name} directory not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error exploring {company_name}: {str(e)}")

def explore_benchmark_directory(company_name, benchmark_dir):
    """Explore a specific benchmark directory for a company"""
    print(f"\n🔍 Exploring {company_name.upper()} Benchmark: {benchmark_dir.get('name')}")
    print("-" * 50)
    
    dir_url = benchmark_dir.get('url', '')
    if not dir_url:
        print("❌ No URL available for directory")
        return
    
    try:
        response = requests.get(dir_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"📁 Directory contents ({len(data)} items):")
            
            for item in data[:10]:  # Show first 10
                name = item.get('name', 'Unknown')
                item_type = item.get('type', 'Unknown')
                size = item.get('size', 'Unknown')
                print(f"   - {name} ({item_type}, {size} bytes)")
            
            # Look for CSV or data files
            data_files = [item for item in data if item.get('type') == 'file' and 
                         any(keyword in item.get('name', '').lower() for keyword in 
                             ['csv', 'json', 'data', 'result', 'log', 'txt', 'md'])]
            
            if data_files:
                print(f"\n📄 Found {len(data_files)} data files:")
                for file_item in data_files:
                    print(f"   - {file_item.get('name')}")
                
                # Try to download the first data file
                if data_files:
                    download_data_file(company_name, data_files[0])
        
        else:
            print(f"❌ Directory not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def download_data_file(company_name, file_item):
    """Download and analyze a data file"""
    print(f"\n📥 Downloading {company_name.upper()} Data: {file_item.get('name')}")
    print("-" * 50)
    
    download_url = file_item.get('download_url', '')
    if not download_url:
        print("❌ No download URL available")
        return
    
    try:
        response = requests.get(download_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            print(f"✅ File downloaded successfully!")
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
                                    ['time', 'accuracy', 'performance', 'score', 'result', 'benchmark', 'latency', 'throughput', 'speed'])]
                
                if competitive_cols:
                    print(f"🏆 Competitive measurement columns: {competitive_cols}")
                    
                    # Show sample data
                    print(f"\n📊 Sample data:")
                    print(df[competitive_cols].head())
                
                # Save the data
                filename = f"data/raw/mlperf_{company_name}_{file_item.get('name')}"
                df.to_csv(filename, index=False)
                print(f"💾 Data saved to: {filename}")
                
                return df
                
            except Exception as e:
                print(f"❌ CSV parsing failed: {str(e)}")
                print(f"📄 Content preview: {response.text[:500]}...")
                
                # Try to save as text file
                filename = f"data/raw/mlperf_{company_name}_{file_item.get('name')}.txt"
                with open(filename, 'w') as f:
                    f.write(response.text)
                print(f"💾 Raw data saved to: {filename}")
        
        else:
            print(f"❌ Download failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    return None

def main():
    print("🚀 MLPerf Company-Specific Benchmark Data Exploration")
    print("=" * 60)
    print("Goal: Find competitive measurement data between Google, Intel, and NVIDIA")
    print("Focus: Benchmark results, performance comparisons, competitive metrics")
    
    companies = ['google', 'intel', 'nvidia']
    
    for company in companies:
        explore_company_directory(company)
        time.sleep(1)  # Be respectful to GitHub API
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Analyze downloaded MLPerf company data")
    print("2. Identify competitive measurement scenarios between companies")
    print("3. Apply SEF framework to MLPerf competitive data")
    print("4. Compare with CMS and other data sources")

if __name__ == "__main__":
    main()
