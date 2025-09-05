#!/usr/bin/env python3
"""
Investigate the CMS PQDC (Provider Quality Data Center) portal
to understand how to access actual hospital performance data
"""

import requests
from bs4 import BeautifulSoup
import json
import time

def investigate_pqdc_portal():
    """Investigate the PQDC portal structure and find data access methods"""
    print("🔍 Investigating CMS PQDC Portal")
    print("=" * 50)
    
    # Test the main PQDC portal
    url = "https://data.cms.gov/provider-data/dataset/patient-safety-indicators"
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type')}")
        print(f"Content-Length: {len(response.content)} bytes")
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Look for any JavaScript or API endpoints
            scripts = soup.find_all('script')
            print(f"\n📜 Found {len(scripts)} script tags")
            
            for i, script in enumerate(scripts[:3]):  # Check first 3 scripts
                if script.string:
                    print(f"\nScript {i+1} content preview:")
                    print(script.string[:200] + "..." if len(script.string) > 200 else script.string)
            
            # Look for any data or API references
            all_text = soup.get_text()
            api_mentions = [line for line in all_text.split('\n') if 'api' in line.lower()]
            if api_mentions:
                print(f"\n🔌 API mentions found:")
                for mention in api_mentions[:3]:
                    print(f"   - {mention.strip()}")
            
            # Look for download or data access links
            links = soup.find_all('a', href=True)
            data_links = [link for link in links if any(keyword in link.get('href', '').lower() 
                          for keyword in ['download', 'data', 'csv', 'json', 'xlsx'])]
            
            if data_links:
                print(f"\n📊 Data-related links found:")
                for link in data_links[:5]:
                    print(f"   - {link.get('href')} ({link.get_text().strip()})")
            
            # Look for any form elements that might be data access
            forms = soup.find_all('form')
            if forms:
                print(f"\n📝 Found {len(forms)} forms")
                for i, form in enumerate(forms):
                    print(f"Form {i+1}: action='{form.get('action')}', method='{form.get('method')}'")
            
            # Check for any meta tags with API information
            meta_tags = soup.find_all('meta')
            api_meta = [meta for meta in meta_tags if meta.get('name') and 'api' in meta.get('name', '').lower()]
            if api_meta:
                print(f"\n🏷️ API-related meta tags:")
                for meta in api_meta:
                    print(f"   - {meta.get('name')}: {meta.get('content')}")
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def test_alternative_cms_endpoints():
    """Test alternative CMS data access methods"""
    print("\n🔍 Testing Alternative CMS Data Access Methods")
    print("=" * 50)
    
    # Test different CMS data access patterns
    test_urls = [
        "https://data.cms.gov/data.json",  # Data catalog
        "https://data.cms.gov/api/views",  # API views
        "https://data.cms.gov/provider-data",  # Provider data root
        "https://data.cms.gov/provider-data/api",  # Provider data API
        "https://data.cms.gov/provider-data/dataset",  # Dataset root
    ]
    
    for url in test_urls:
        try:
            response = requests.get(url, timeout=10)
            print(f"\n🔗 {url}")
            print(f"   Status: {response.status_code}")
            print(f"   Content-Type: {response.headers.get('content-type', 'Unknown')}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                if 'application/json' in content_type:
                    try:
                        data = response.json()
                        if isinstance(data, dict):
                            print(f"   JSON keys: {list(data.keys())}")
                        else:
                            print(f"   JSON type: {type(data)}")
                    except:
                        print("   JSON parsing failed")
                elif 'text/html' in content_type:
                    print(f"   HTML content: {len(response.text)} characters")
                else:
                    print(f"   Content preview: {response.text[:100]}...")
            else:
                print(f"   ❌ Not accessible")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        time.sleep(1)  # Be respectful

def main():
    investigate_pqdc_portal()
    test_alternative_cms_endpoints()
    
    print("\n" + "=" * 50)
    print("🎯 FINDINGS SUMMARY:")
    print("1. PQDC portal appears to be a front-end interface")
    print("2. Need to find the actual data access API or download methods")
    print("3. Alternative endpoints may provide direct data access")
    print("4. May need to explore the data.json catalog for actual datasets")

if __name__ == "__main__":
    main()
