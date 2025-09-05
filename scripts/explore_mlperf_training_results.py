#!/usr/bin/env python3
"""
Explore MLPerf training results data
Focus on competitive measurement data for SEF framework validation
"""

import requests
import json
import time
import pandas as pd
from io import StringIO

def explore_mlperf_training_results():
    """Explore MLPerf training results repository"""
    print("🔍 Exploring MLPerf Training Results")
    print("=" * 50)
    
    # MLPerf training results repository
    repo_url = "https://api.github.com/repos/mlcommons/training_results_v0.5"
    
    try:
        response = requests.get(repo_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            repo_data = response.json()
            print(f"Repository: {repo_data.get('name', 'Unknown')}")
            print(f"Description: {repo_data.get('description', 'No description')}")
            print(f"Stars: {repo_data.get('stargazers_count', 'Unknown')}")
            print(f"Language: {repo_data.get('language', 'Unknown')}")
            
            # Get repository contents
            contents_url = repo_data.get('contents_url', '').replace('{+path}', '')
            contents_response = requests.get(contents_url, timeout=10)
            
            if contents_response.status_code == 200:
                contents = contents_response.json()
                print(f"\n📁 Repository contents ({len(contents)} items):")
                
                for item in contents[:10]:  # Show first 10
                    name = item.get('name', 'Unknown')
                    item_type = item.get('type', 'Unknown')
                    size = item.get('size', 'Unknown')
                    print(f"   - {name} ({item_type}, {size} bytes)")
                
                # Look for results or data directories
                data_dirs = [item for item in contents if item.get('type') == 'dir' and 
                           any(keyword in item.get('name', '').lower() for keyword in 
                               ['result', 'data', 'benchmark', 'submission'])]
                
                if data_dirs:
                    print(f"\n📊 Found {len(data_dirs)} potential data directories:")
                    for dir_item in data_dirs:
                        print(f"   - {dir_item.get('name')}")
                
            else:
                print(f"❌ Could not access repository contents: {contents_response.status_code}")
        
        else:
            print(f"❌ Repository not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def explore_mlperf_benchmark_data():
    """Explore specific MLPerf benchmark data"""
    print("\n🔍 Exploring MLPerf Benchmark Data")
    print("=" * 50)
    
    # Try to access specific benchmark results
    benchmark_urls = [
        "https://raw.githubusercontent.com/mlcommons/training_results_v0.5/main/results.csv",
        "https://raw.githubusercontent.com/mlcommons/training_results_v0.5/main/data/results.csv",
        "https://raw.githubusercontent.com/mlcommons/training_results_v0.5/main/benchmark_results.csv",
    ]
    
    for url in benchmark_urls:
        try:
            response = requests.get(url, timeout=10)
            print(f"\n🔗 {url}")
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                print(f"   ✅ Data accessible!")
                print(f"   Content-Type: {response.headers.get('content-type', 'Unknown')}")
                print(f"   Content-Length: {len(response.content)} bytes")
                
                # Try to parse as CSV
                try:
                    df = pd.read_csv(StringIO(response.text))
                    print(f"   📊 CSV loaded successfully:")
                    print(f"      Rows: {len(df)}")
                    print(f"      Columns: {len(df.columns)}")
                    print(f"      Column names: {list(df.columns)}")
                    
                    # Look for competitive measurement data
                    competitive_cols = [col for col in df.columns if any(keyword in col.lower() for keyword in 
                                        ['time', 'accuracy', 'performance', 'score', 'result', 'benchmark'])]
                    
                    if competitive_cols:
                        print(f"   🏆 Competitive measurement columns: {competitive_cols}")
                    
                    return df
                    
                except Exception as e:
                    print(f"   ❌ CSV parsing failed: {str(e)}")
                    print(f"   📄 Content preview: {response.text[:200]}...")
            
            else:
                print(f"   ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful
    
    return None

def explore_mlperf_submissions():
    """Explore MLPerf submission data"""
    print("\n🔍 Exploring MLPerf Submissions")
    print("=" * 50)
    
    # Try to access submission data
    submission_urls = [
        "https://api.github.com/repos/mlcommons/training_results_v0.5/contents/submissions",
        "https://api.github.com/repos/mlcommons/training_results_v0.5/contents/results",
        "https://api.github.com/repos/mlcommons/training_results_v0.5/contents/benchmarks",
    ]
    
    for url in submission_urls:
        try:
            response = requests.get(url, timeout=10)
            print(f"\n🔗 {url}")
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                print(f"   📁 Found {len(data)} items")
                
                for item in data[:5]:  # Show first 5
                    name = item.get('name', 'Unknown')
                    item_type = item.get('type', 'Unknown')
                    print(f"      - {name} ({item_type})")
                
                # Look for specific benchmark results
                benchmark_items = [item for item in data if 'benchmark' in item.get('name', '').lower()]
                if benchmark_items:
                    print(f"   🏆 Found {len(benchmark_items)} benchmark items")
            
            else:
                print(f"   ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful

def main():
    print("🚀 MLPerf Training Results Data Access Exploration")
    print("=" * 60)
    print("Goal: Find competitive measurement data for SEF framework validation")
    print("Focus: AI benchmark results, performance comparisons, competitive metrics")
    
    explore_mlperf_training_results()
    benchmark_data = explore_mlperf_benchmark_data()
    explore_mlperf_submissions()
    
    if benchmark_data is not None:
        print("\n" + "=" * 60)
        print("🎯 BENCHMARK DATA FOUND!")
        print("=" * 60)
        print("✅ MLPerf training results data accessible")
        print("✅ Competitive measurement data available")
        print("✅ Ready for SEF framework application")
        
        # Save the data for analysis
        benchmark_data.to_csv('data/raw/mlperf_training_results.csv', index=False)
        print("💾 Data saved to: data/raw/mlperf_training_results.csv")
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Analyze MLPerf benchmark data structure")
    print("2. Identify competitive measurement scenarios")
    print("3. Apply SEF framework to MLPerf data")
    print("4. Compare with other data sources")

if __name__ == "__main__":
    main()
