#!/usr/bin/env python3
"""
CMS Data Structure Investigation Script

The initial exploration showed that the CMS API endpoints return HTML instead of JSON.
Let's investigate the actual data structure and access methods.
"""

import requests
import json
import time
from datetime import datetime
import re

def investigate_cms_data_portal():
    """
    Investigate the actual CMS data portal structure
    """
    print("=== CMS DATA PORTAL STRUCTURE INVESTIGATION ===")
    print("Goal: Understand how to access CMS data properly")
    print("=" * 60)
    
    # Let's look at the actual HTML content to understand the structure
    portal_url = "https://data.cms.gov/provider-data/"
    
    try:
        print(f"Fetching portal content: {portal_url}")
        response = requests.get(portal_url, timeout=10)
        
        if response.status_code == 200:
            html_content = response.text
            print(f"✅ Portal accessible: {len(html_content)} characters")
            
            # Look for dataset links or API endpoints in the HTML
            print("\n🔍 Analyzing portal content...")
            
            # Look for common patterns
            patterns = {
                'dataset_links': r'href="[^"]*dataset[^"]*"',
                'api_endpoints': r'https://[^"]*api[^"]*',
                'data_downloads': r'href="[^"]*\.csv[^"]*"',
                'json_endpoints': r'href="[^"]*\.json[^"]*"'
            }
            
            for pattern_name, pattern in patterns.items():
                matches = re.findall(pattern, html_content, re.IGNORECASE)
                if matches:
                    print(f"  📋 {pattern_name}: {len(matches)} found")
                    for match in matches[:3]:  # Show first 3
                        print(f"    - {match}")
                else:
                    print(f"  ❌ {pattern_name}: None found")
            
            # Look for specific hospital-related content
            if 'hospital' in html_content.lower():
                print("  🏥 Hospital-related content found in portal")
            if 'compare' in html_content.lower():
                print("  📊 Compare-related content found in portal")
                
        else:
            print(f"❌ Portal not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"⚠️ Error accessing portal: {str(e)}")

def investigate_cms_api_alternatives():
    """
    Investigate alternative CMS API endpoints
    """
    print(f"\n{'='*60}")
    print("INVESTIGATING ALTERNATIVE CMS API ENDPOINTS")
    print("=" * 60)
    
    # Try different API endpoint patterns
    api_endpoints = [
        "https://data.cms.gov/api/views.json",
        "https://data.cms.gov/api/views?format=json",
        "https://data.cms.gov/api/views?$format=json",
        "https://data.cms.gov/api/views?$select=*",
        "https://data.cms.gov/api/views?$limit=10",
        "https://data.cms.gov/api/views?$where=name%20like%20%27%25hospital%25%27"
    ]
    
    for endpoint in api_endpoints:
        print(f"\nTesting: {endpoint}")
        try:
            response = requests.get(endpoint, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                print(f"  Content-Type: {content_type}")
                
                if 'json' in content_type.lower():
                    try:
                        data = response.json()
                        print(f"  ✅ JSON Response: {len(data)} items")
                        if isinstance(data, list) and len(data) > 0:
                            print(f"  📋 Sample keys: {list(data[0].keys()) if isinstance(data[0], dict) else 'Not a dict'}")
                    except:
                        print(f"  ❌ JSON parsing failed")
                else:
                    print(f"  🌐 Non-JSON response: {len(response.text)} characters")
            else:
                print(f"  ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def investigate_cms_data_catalog():
    """
    Investigate CMS data catalog structure
    """
    print(f"\n{'='*60}")
    print("INVESTIGATING CMS DATA CATALOG")
    print("=" * 60)
    
    # Try to find the data catalog
    catalog_urls = [
        "https://data.cms.gov/data.json",
        "https://data.cms.gov/catalog.json",
        "https://data.cms.gov/api/3/action/package_list",
        "https://data.cms.gov/api/3/action/package_search?q=hospital"
    ]
    
    for url in catalog_urls:
        print(f"\nTesting: {url}")
        try:
            response = requests.get(url, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                print(f"  Content-Type: {content_type}")
                
                if 'json' in content_type.lower():
                    try:
                        data = response.json()
                        print(f"  ✅ JSON Response: {len(data)} items")
                        
                        # Look for hospital-related datasets
                        if isinstance(data, dict):
                            if 'result' in data and isinstance(data['result'], list):
                                hospital_count = sum(1 for item in data['result'] if 'hospital' in str(item).lower())
                                print(f"  🏥 Hospital-related datasets: {hospital_count}")
                        elif isinstance(data, list):
                            hospital_count = sum(1 for item in data if 'hospital' in str(item).lower())
                            print(f"  🏥 Hospital-related datasets: {hospital_count}")
                            
                    except:
                        print(f"  ❌ JSON parsing failed")
                else:
                    print(f"  🌐 Non-JSON response: {len(response.text)} characters")
            else:
                print(f"  ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def investigate_cms_direct_downloads():
    """
    Investigate direct download options for CMS data
    """
    print(f"\n{'='*60}")
    print("INVESTIGATING CMS DIRECT DOWNLOAD OPTIONS")
    print("=" * 60)
    
    # Try to find direct download links
    download_urls = [
        "https://data.cms.gov/provider-data/dataset/hospital-compare",
        "https://data.cms.gov/provider-data/dataset/quality-measures",
        "https://data.cms.gov/provider-data/dataset/hospital-general-information"
    ]
    
    for url in download_urls:
        print(f"\nTesting: {url}")
        try:
            response = requests.get(url, timeout=10)
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                html_content = response.text
                print(f"  ✅ Page accessible: {len(html_content)} characters")
                
                # Look for download links
                download_patterns = [
                    r'href="[^"]*\.csv[^"]*"',
                    r'href="[^"]*download[^"]*"',
                    r'href="[^"]*export[^"]*"',
                    r'data-download-url="[^"]*"'
                ]
                
                for pattern in download_patterns:
                    matches = re.findall(pattern, html_content, re.IGNORECASE)
                    if matches:
                        print(f"    📥 Download links found: {len(matches)}")
                        for match in matches[:2]:  # Show first 2
                            print(f"      - {match}")
                
                # Look for specific hospital data indicators
                if 'hospital' in html_content.lower():
                    print(f"    🏥 Hospital data content found")
                if 'performance' in html_content.lower():
                    print(f"    📊 Performance data content found")
                    
            else:
                print(f"  ❌ Page not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)

def main():
    """
    Main investigation function
    """
    print("Starting CMS Data Structure Investigation...")
    print("This will help us understand how to properly access CMS data.")
    
    # Step 1: Investigate portal structure
    investigate_cms_data_portal()
    
    # Step 2: Try alternative API endpoints
    investigate_cms_api_alternatives()
    
    # Step 3: Investigate data catalog
    investigate_cms_data_catalog()
    
    # Step 4: Investigate direct downloads
    investigate_cms_direct_downloads()
    
    print(f"\n{'='*60}")
    print("INVESTIGATION SUMMARY")
    print("=" * 60)
    print("Based on this investigation:")
    print("1. CMS data portal is accessible without authentication")
    print("2. API structure may be different than expected")
    print("3. Direct download options may be available")
    print("4. Further investigation needed to find actual data access methods")
    
    print(f"\nNext steps:")
    print("1. Review investigation results")
    print("2. Determine if we need to explore specific dataset pages")
    print("3. Test actual data download procedures")
    print("4. Identify any permission requirements")

if __name__ == "__main__":
    main()
