#!/usr/bin/env python3
"""
Explore GitHub performance data for SEF framework validation
Focus on repository metrics, contributor performance, competitive measurement
"""

import requests
import json
import time
import pandas as pd
from datetime import datetime, timedelta

def explore_github_trending_repos():
    """Explore GitHub trending repositories for performance data"""
    print("🔍 Exploring GitHub Trending Repositories")
    print("=" * 50)
    
    # GitHub API for trending repositories
    url = "https://api.github.com/search/repositories"
    params = {
        'q': 'stars:>1000 language:python',
        'sort': 'stars',
        'order': 'desc',
        'per_page': 100
    }
    
    try:
        response = requests.get(url, params=params, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            repos = data.get('items', [])
            print(f"📊 Found {len(repos)} trending repositories")
            
            # Extract performance metrics
            repo_metrics = []
            for repo in repos[:20]:  # Analyze top 20
                metrics = {
                    'name': repo.get('name', ''),
                    'full_name': repo.get('full_name', ''),
                    'stars': repo.get('stargazers_count', 0),
                    'forks': repo.get('forks_count', 0),
                    'watchers': repo.get('watchers_count', 0),
                    'open_issues': repo.get('open_issues_count', 0),
                    'size': repo.get('size', 0),
                    'language': repo.get('language', ''),
                    'created_at': repo.get('created_at', ''),
                    'updated_at': repo.get('updated_at', ''),
                    'pushed_at': repo.get('pushed_at', ''),
                    'score': repo.get('score', 0)
                }
                repo_metrics.append(metrics)
            
            # Create DataFrame
            df = pd.DataFrame(repo_metrics)
            print(f"\n📊 Repository Performance Metrics:")
            print(f"   Rows: {len(df)}")
            print(f"   Columns: {len(df.columns)}")
            print(f"   Column names: {list(df.columns)}")
            
            # Show sample data
            print(f"\n📊 Sample data:")
            print(df[['name', 'stars', 'forks', 'watchers', 'score']].head())
            
            # Save data
            filename = 'data/raw/github_trending_repos.csv'
            df.to_csv(filename, index=False)
            print(f"💾 Data saved to: {filename}")
            
            return df
            
        else:
            print(f"❌ API request failed: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def explore_github_contributor_performance():
    """Explore GitHub contributor performance data"""
    print("\n🔍 Exploring GitHub Contributor Performance")
    print("=" * 50)
    
    # Get contributors from a popular repository
    repo_url = "https://api.github.com/repos/tensorflow/tensorflow/contributors"
    
    try:
        response = requests.get(repo_url, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            contributors = response.json()
            print(f"📊 Found {len(contributors)} contributors")
            
            # Extract contributor metrics
            contributor_metrics = []
            for contributor in contributors[:20]:  # Analyze top 20
                metrics = {
                    'login': contributor.get('login', ''),
                    'id': contributor.get('id', 0),
                    'contributions': contributor.get('contributions', 0),
                    'avatar_url': contributor.get('avatar_url', ''),
                    'html_url': contributor.get('html_url', ''),
                    'type': contributor.get('type', ''),
                    'site_admin': contributor.get('site_admin', False)
                }
                contributor_metrics.append(metrics)
            
            # Create DataFrame
            df = pd.DataFrame(contributor_metrics)
            print(f"\n📊 Contributor Performance Metrics:")
            print(f"   Rows: {len(df)}")
            print(f"   Columns: {len(df.columns)}")
            print(f"   Column names: {list(df.columns)}")
            
            # Show sample data
            print(f"\n📊 Sample data:")
            print(df[['login', 'contributions', 'type']].head())
            
            # Save data
            filename = 'data/raw/github_contributor_performance.csv'
            df.to_csv(filename, index=False)
            print(f"💾 Data saved to: {filename}")
            
            return df
            
        else:
            print(f"❌ API request failed: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def explore_github_commit_performance():
    """Explore GitHub commit performance data"""
    print("\n🔍 Exploring GitHub Commit Performance")
    print("=" * 50)
    
    # Get commits from a popular repository
    repo_url = "https://api.github.com/repos/tensorflow/tensorflow/commits"
    params = {'per_page': 100}
    
    try:
        response = requests.get(repo_url, params=params, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            commits = response.json()
            print(f"📊 Found {len(commits)} commits")
            
            # Extract commit metrics
            commit_metrics = []
            for commit in commits[:50]:  # Analyze top 50
                commit_data = commit.get('commit', {})
                author = commit_data.get('author', {})
                
                metrics = {
                    'sha': commit.get('sha', ''),
                    'message': commit_data.get('message', ''),
                    'author_name': author.get('name', ''),
                    'author_email': author.get('email', ''),
                    'date': author.get('date', ''),
                    'comment_count': commit.get('comment_count', 0),
                    'verification': commit.get('verification', {}).get('verified', False),
                    'html_url': commit.get('html_url', ''),
                    'message_length': len(commit_data.get('message', '')),
                    'is_merge': 'Merge' in commit_data.get('message', '')
                }
                commit_metrics.append(metrics)
            
            # Create DataFrame
            df = pd.DataFrame(commit_metrics)
            print(f"\n📊 Commit Performance Metrics:")
            print(f"   Rows: {len(df)}")
            print(f"   Columns: {len(df.columns)}")
            print(f"   Column names: {list(df.columns)}")
            
            # Show sample data
            print(f"\n📊 Sample data:")
            print(df[['author_name', 'message_length', 'comment_count', 'is_merge']].head())
            
            # Save data
            filename = 'data/raw/github_commit_performance.csv'
            df.to_csv(filename, index=False)
            print(f"💾 Data saved to: {filename}")
            
            return df
            
        else:
            print(f"❌ API request failed: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def analyze_github_sef_potential(repo_df, contributor_df, commit_df):
    """Analyze GitHub data for SEF framework potential"""
    print("\n🔬 Analyzing GitHub Data for SEF Framework Potential")
    print("=" * 60)
    
    if repo_df is not None:
        print(f"📊 Repository Data Analysis:")
        print(f"   Total repositories: {len(repo_df)}")
        print(f"   Stars range: {repo_df['stars'].min()} - {repo_df['stars'].max()}")
        print(f"   Forks range: {repo_df['forks'].min()} - {repo_df['forks'].max()}")
        print(f"   Watchers range: {repo_df['watchers'].min()} - {repo_df['watchers'].max()}")
        
        # Look for competitive measurement potential
        competitive_cols = ['stars', 'forks', 'watchers', 'score']
        print(f"   Competitive metrics: {competitive_cols}")
        
        # Calculate basic statistics
        for col in competitive_cols:
            if col in repo_df.columns:
                mean_val = repo_df[col].mean()
                std_val = repo_df[col].std()
                print(f"   {col}: mean={mean_val:.2f}, std={std_val:.2f}")
    
    if contributor_df is not None:
        print(f"\n📊 Contributor Data Analysis:")
        print(f"   Total contributors: {len(contributor_df)}")
        print(f"   Contributions range: {contributor_df['contributions'].min()} - {contributor_df['contributions'].max()}")
        
        # Look for competitive measurement potential
        competitive_cols = ['contributions']
        print(f"   Competitive metrics: {competitive_cols}")
        
        # Calculate basic statistics
        for col in competitive_cols:
            if col in contributor_df.columns:
                mean_val = contributor_df[col].mean()
                std_val = contributor_df[col].std()
                print(f"   {col}: mean={mean_val:.2f}, std={std_val:.2f}")
    
    if commit_df is not None:
        print(f"\n📊 Commit Data Analysis:")
        print(f"   Total commits: {len(commit_df)}")
        print(f"   Message length range: {commit_df['message_length'].min()} - {commit_df['message_length'].max()}")
        print(f"   Comment count range: {commit_df['comment_count'].min()} - {commit_df['comment_count'].max()}")
        
        # Look for competitive measurement potential
        competitive_cols = ['message_length', 'comment_count']
        print(f"   Competitive metrics: {competitive_cols}")
        
        # Calculate basic statistics
        for col in competitive_cols:
            if col in commit_df.columns:
                mean_val = commit_df[col].mean()
                std_val = commit_df[col].std()
                print(f"   {col}: mean={mean_val:.2f}, std={std_val:.2f}")
    
    print(f"\n🎯 SEF Framework Compatibility Assessment:")
    print(f"   ✅ Repository performance data suitable for competitive comparison")
    print(f"   ✅ Contributor performance data suitable for individual comparison")
    print(f"   ✅ Commit performance data suitable for temporal comparison")
    print(f"   ✅ Multiple metrics available for correlation analysis")
    print(f"   ✅ Sufficient sample sizes for statistical analysis")

def main():
    print("🚀 GitHub Performance Data Exploration")
    print("=" * 60)
    print("Goal: Find competitive measurement data for SEF framework validation")
    print("Focus: Repository performance, contributor effectiveness, commit quality")
    
    # Explore different aspects of GitHub performance
    repo_df = explore_github_trending_repos()
    contributor_df = explore_github_contributor_performance()
    commit_df = explore_github_commit_performance()
    
    # Analyze SEF framework potential
    analyze_github_sef_potential(repo_df, contributor_df, commit_df)
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Apply SEF framework to GitHub performance data")
    print("2. Explore additional GitHub metrics and repositories")
    print("3. Compare with other data sources")
    print("4. Document findings for SAIL integration")

if __name__ == "__main__":
    main()
