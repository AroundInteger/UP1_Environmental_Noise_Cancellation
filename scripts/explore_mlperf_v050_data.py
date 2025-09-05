#!/usr/bin/env python3
"""
Explore MLPerf v0.5.0 data directory
Focus on finding actual benchmark results data
"""

import requests
import json
import time
import pandas as pd
from io import StringIO

def explore_mlperf_v050_directory():
    """Explore the v0.5.0 directory for benchmark data"""
    print("🔍 Exploring MLPerf v0.5.0 Directory")
    print("=" * 50)
    
    # Explore the v0.5.0 directory
    v050_url = "https://api.github.com/repos/mlcommons/training_results_v0.5/contents/v0.5.0"
    
    try:
        response = requests.get(v050_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"📁 v0.5.0 directory contents ({len(data)} items):")
            
            for item in data[:10]:  # Show first 10
                name = item.get('name', 'Unknown')
                item_type = item.get('type', 'Unknown')
                size = item.get('size', 'Unknown')
                print(f"   - {name} ({item_type}, {size} bytes)")
            
            # Look for benchmark or results directories
            benchmark_dirs = [item for item in data if item.get('type') == 'dir' and 
                            any(keyword in item.get('name', '').lower() for keyword in 
                                ['benchmark', 'result', 'submission', 'data'])]
            
            if benchmark_dirs:
                print(f"\n📊 Found {len(benchmark_dirs)} potential benchmark directories:")
                for dir_item in benchmark_dirs:
                    print(f"   - {dir_item.get('name')}")
                
                # Explore the first benchmark directory
                if benchmark_dirs:
                    explore_benchmark_directory(benchmark_dirs[0])
            
            # Look for CSV or data files
            data_files = [item for item in data if item.get('type') == 'file' and 
                         any(keyword in item.get('name', '').lower() for keyword in 
                             ['csv', 'json', 'data', 'result'])]
            
            if data_files:
                print(f"\n📄 Found {len(data_files)} potential data files:")
                for file_item in data_files:
                    print(f"   - {file_item.get('name')}")
                
                # Try to download the first data file
                if data_files:
                    download_data_file(data_files[0])
        
        else:
            print(f"❌ v0.5.0 directory not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def explore_benchmark_directory(benchmark_dir):
    """Explore a specific benchmark directory"""
    print(f"\n🔍 Exploring Benchmark Directory: {benchmark_dir.get('name')}")
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
                             ['csv', 'json', 'data', 'result', 'log'])]
            
            if data_files:
                print(f"\n📄 Found {len(data_files)} data files:")
                for file_item in data_files:
                    print(f"   - {file_item.get('name')}")
                
                # Try to download the first data file
                if data_files:
                    download_data_file(data_files[0])
        
        else:
            print(f"❌ Directory not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def download_data_file(file_item):
    """Download and analyze a data file"""
    print(f"\n📥 Downloading Data File: {file_item.get('name')}")
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
                                    ['time', 'accuracy', 'performance', 'score', 'result', 'benchmark', 'latency', 'throughput'])]
                
                if competitive_cols:
                    print(f"🏆 Competitive measurement columns: {competitive_cols}")
                    
                    # Show sample data
                    print(f"\n📊 Sample data:")
                    print(df[competitive_cols].head())
                
                # Save the data
                filename = f"data/raw/mlperf_{file_item.get('name')}"
                df.to_csv(filename, index=False)
                print(f"💾 Data saved to: {filename}")
                
                return df
                
            except Exception as e:
                print(f"❌ CSV parsing failed: {str(e)}")
                print(f"📄 Content preview: {response.text[:500]}...")
                
                # Try to save as text file
                filename = f"data/raw/mlperf_{file_item.get('name')}.txt"
                with open(filename, 'w') as f:
                    f.write(response.text)
                print(f"💾 Raw data saved to: {filename}")
        
        else:
            print(f"❌ Download failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    return None

def main():
    print("🚀 MLPerf v0.5.0 Data Exploration")
    print("=" * 60)
    print("Goal: Find actual benchmark results data for SEF framework validation")
    print("Focus: Competitive measurement data, performance comparisons")
    
    explore_mlperf_v050_directory()
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Analyze downloaded MLPerf data")
    print("2. Identify competitive measurement scenarios")
    print("3. Apply SEF framework to MLPerf data")
    print("4. Compare with CMS and other data sources")

if __name__ == "__main__":
    main()
