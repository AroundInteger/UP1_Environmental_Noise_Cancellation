#!/usr/bin/env python3
"""
Explore PISA Education Data access
Focus on competitive measurement data for SEF framework validation
"""

import requests
import json
import time
import pandas as pd
from io import StringIO

def explore_pisa_website():
    """Explore PISA website for data access"""
    print("🔍 Exploring PISA Education Data")
    print("=" * 50)
    
    # PISA main website
    url = "https://www.oecd.org/pisa/data/"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', 'Unknown')}")
        
        if response.status_code == 200:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Look for data download links
            links = soup.find_all('a', href=True)
            data_links = [link for link in links if any(keyword in link.get('href', '').lower() 
                          for keyword in ['data', 'download', 'database', 'csv', 'excel'])]
            
            print(f"\n📊 Found {len(data_links)} potential data links:")
            for i, link in enumerate(data_links[:10]):  # Show first 10
                href = link.get('href')
                text = link.get_text().strip()
                print(f"   {i+1}. {text} -> {href}")
            
            # Look for database access
            db_mentions = soup.find_all(text=lambda text: text and 'database' in text.lower())
            if db_mentions:
                print(f"\n🗄️ Found {len(db_mentions)} database-related mentions")
            
        else:
            print(f"❌ Website not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def explore_pisa_database():
    """Explore PISA database access"""
    print("\n🔍 Exploring PISA Database Access")
    print("=" * 50)
    
    # Try different PISA database URLs
    test_urls = [
        "https://www.oecd.org/pisa/data/2018database/",
        "https://www.oecd.org/pisa/data/2015database/",
        "https://www.oecd.org/pisa/data/2012database/",
        "https://www.oecd.org/pisa/data/2009database/",
    ]
    
    for url in test_urls:
        try:
            response = requests.get(url, timeout=10)
            print(f"\n🔗 {url}")
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                from bs4 import BeautifulSoup
                soup = BeautifulSoup(response.text, 'html.parser')
                
                # Look for data download links
                links = soup.find_all('a', href=True)
                download_links = [link for link in links if any(keyword in link.get('href', '').lower() 
                                  for keyword in ['download', 'csv', 'excel', 'data', 'spss'])]
                
                if download_links:
                    print(f"   📊 Found {len(download_links)} download links:")
                    for link in download_links[:3]:  # Show first 3
                        print(f"      - {link.get('href')}")
                
                # Look for data tables
                tables = soup.find_all('table')
                if tables:
                    print(f"   📋 Found {len(tables)} data tables")
                
            else:
                print(f"   ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful

def explore_pisa_api():
    """Explore PISA API access"""
    print("\n🔍 Exploring PISA API Access")
    print("=" * 50)
    
    # Try PISA API endpoints
    api_urls = [
        "https://www.oecd.org/pisa/api/",
        "https://www.oecd.org/pisa/data/api/",
        "https://www.oecd.org/pisa/database/api/",
    ]
    
    for url in api_urls:
        try:
            response = requests.get(url, timeout=10)
            print(f"\n🔗 {url}")
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                print(f"   ✅ API accessible")
                print(f"   Content-Type: {response.headers.get('content-type', 'Unknown')}")
                print(f"   Content-Length: {len(response.content)} bytes")
                
                # Try to parse as JSON
                try:
                    data = response.json()
                    print(f"   📊 JSON response keys: {list(data.keys()) if isinstance(data, dict) else 'Not a dict'}")
                except:
                    print(f"   📄 Text response preview: {response.text[:200]}...")
            
            else:
                print(f"   ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful

def main():
    print("🚀 PISA Education Data Access Exploration")
    print("=" * 60)
    print("Goal: Find competitive measurement data for SEF framework validation")
    print("Focus: Education performance data, country comparisons, student outcomes")
    
    explore_pisa_website()
    explore_pisa_database()
    explore_pisa_api()
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Review PISA data access methods")
    print("2. Identify specific education datasets")
    print("3. Test data download and analysis")
    print("4. Apply SEF framework to PISA data")

if __name__ == "__main__":
    main()
