#!/usr/bin/env python3
"""
Explore MLPerf results directories for actual benchmark data
Focus on finding competitive measurement data
"""

import requests
import json
import time
import pandas as pd
from io import StringIO

def explore_results_directory(company_name, benchmark_name):
    """Explore results directory for a specific benchmark"""
    print(f"\n🔍 Exploring {company_name.upper()} Results: {benchmark_name}")
    print("=" * 50)
    
    results_url = f"https://api.github.com/repos/mlcommons/training_results_v0.5/contents/v0.5.0/{company_name}/{benchmark_name}/results"
    
    try:
        response = requests.get(results_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"📁 Results directory contents ({len(data)} items):")
            
            for item in data[:10]:  # Show first 10
                name = item.get('name', 'Unknown')
                item_type = item.get('type', 'Unknown')
                size = item.get('size', 'Unknown')
                print(f"   - {name} ({item_type}, {size} bytes)")
            
            # Look for data files
            data_files = [item for item in data if item.get('type') == 'file' and 
                         any(keyword in item.get('name', '').lower() for keyword in 
                             ['csv', 'json', 'data', 'result', 'log', 'txt', 'md', 'out'])]
            
            if data_files:
                print(f"\n📄 Found {len(data_files)} data files:")
                for file_item in data_files:
                    print(f"   - {file_item.get('name')}")
                
                # Try to download the first data file
                if data_files:
                    download_results_file(company_name, benchmark_name, data_files[0])
        
        else:
            print(f"❌ Results directory not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def download_results_file(company_name, benchmark_name, file_item):
    """Download and analyze a results file"""
    print(f"\n📥 Downloading {company_name.upper()} Results: {file_item.get('name')}")
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
                                    ['time', 'accuracy', 'performance', 'score', 'result', 'benchmark', 'latency', 'throughput', 'speed', 'epoch', 'loss'])]
                
                if competitive_cols:
                    print(f"🏆 Competitive measurement columns: {competitive_cols}")
                    
                    # Show sample data
                    print(f"\n📊 Sample data:")
                    print(df[competitive_cols].head())
                
                # Save the data
                filename = f"data/raw/mlperf_{company_name}_{benchmark_name}_{file_item.get('name')}"
                df.to_csv(filename, index=False)
                print(f"💾 Data saved to: {filename}")
                
                return df
                
            except Exception as e:
                print(f"❌ CSV parsing failed: {str(e)}")
                print(f"📄 Content preview: {response.text[:500]}...")
                
                # Try to save as text file
                filename = f"data/raw/mlperf_{company_name}_{benchmark_name}_{file_item.get('name')}.txt"
                with open(filename, 'w') as f:
                    f.write(response.text)
                print(f"💾 Raw data saved to: {filename}")
        
        else:
            print(f"❌ Download failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    return None

def main():
    print("🚀 MLPerf Results Directory Exploration")
    print("=" * 60)
    print("Goal: Find actual benchmark results data for SEF framework validation")
    print("Focus: Competitive measurement data, performance comparisons")
    
    # Explore Intel results
    intel_benchmarks = [
        'intel_minigo_submission_private_tensorflow',
        'intel_minigo_submission_public_tensorflow',
        'intel_ncf_submission',
        'intel_resnet_submission'
    ]
    
    for benchmark in intel_benchmarks:
        explore_results_directory('intel', benchmark)
        time.sleep(1)  # Be respectful to GitHub API
    
    # Explore NVIDIA results
    nvidia_benchmarks = ['submission']
    for benchmark in nvidia_benchmarks:
        explore_results_directory('nvidia', benchmark)
        time.sleep(1)  # Be respectful to GitHub API
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Analyze downloaded MLPerf results data")
    print("2. Identify competitive measurement scenarios")
    print("3. Apply SEF framework to MLPerf data")
    print("4. Compare with CMS and other data sources")

if __name__ == "__main__":
    main()
