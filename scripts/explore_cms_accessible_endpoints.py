#!/usr/bin/env python3
"""
Explore CMS accessible endpoints to find actual data download methods
Focus on quality measures that are accessible and contain hospital-specific data
"""

import requests
import json
from bs4 import BeautifulSoup
import time

def test_endpoint_content(url, description):
    """Test what content is actually available at accessible endpoints"""
    print(f"\n🔍 Testing: {description}")
    print(f"URL: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', 'Unknown')}")
        print(f"Content-Length: {len(response.content)} bytes")
        
        if response.status_code == 200:
            content = response.text
            
            # Check if it's HTML (likely a data portal page)
            if 'text/html' in response.headers.get('content-type', ''):
                print("📄 HTML content detected - likely a data portal page")
                
                # Look for download links or data access information
                soup = BeautifulSoup(content, 'html.parser')
                
                # Look for download links
                download_links = soup.find_all('a', href=True)
                csv_links = [link for link in download_links if 'csv' in link.get('href', '').lower()]
                json_links = [link for link in download_links if 'json' in link.get('href', '').lower()]
                xlsx_links = [link for link in download_links if 'xlsx' in link.get('href', '').lower()]
                
                if csv_links:
                    print(f"📊 Found {len(csv_links)} CSV download links:")
                    for link in csv_links[:3]:  # Show first 3
                        print(f"   - {link.get('href')}")
                
                if json_links:
                    print(f"📊 Found {len(json_links)} JSON download links:")
                    for link in json_links[:3]:  # Show first 3
                        print(f"   - {link.get('href')}")
                
                if xlsx_links:
                    print(f"📊 Found {len(xlsx_links)} Excel download links:")
                    for link in xlsx_links[:3]:  # Show first 3
                        print(f"   - {link.get('href')}")
                
                # Look for data tables or API information
                tables = soup.find_all('table')
                if tables:
                    print(f"📋 Found {len(tables)} data tables")
                
                # Look for API documentation or data access info
                api_mentions = soup.find_all(text=lambda text: text and 'api' in text.lower())
                if api_mentions:
                    print(f"🔌 Found {len(api_mentions)} API-related mentions")
                
                # Show first 200 characters of content for context
                print(f"📝 Content preview: {content[:200]}...")
                
            elif 'application/json' in response.headers.get('content-type', ''):
                print("📊 JSON content detected")
                try:
                    data = response.json()
                    print(f"JSON structure: {list(data.keys()) if isinstance(data, dict) else 'List/Array'}")
                    print(f"JSON preview: {str(data)[:200]}...")
                except:
                    print("❌ Could not parse JSON")
            
            elif 'text/csv' in response.headers.get('content-type', ''):
                print("📊 CSV content detected")
                print(f"CSV preview: {content[:200]}...")
            
            else:
                print(f"📄 Other content type: {response.headers.get('content-type')}")
                print(f"Content preview: {content[:200]}...")
        
        else:
            print(f"❌ Not accessible: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def main():
    print("🔍 Exploring CMS Accessible Endpoints")
    print("=" * 60)
    
    # Test the accessible endpoints we found
    endpoints_to_test = [
        ("https://data.cms.gov/provider-data/dataset/patient-safety-indicators", "Patient Safety Indicators"),
        ("https://data.cms.gov/provider-data/dataset/hospital-acquired-conditions", "Hospital Acquired Conditions"),
        ("https://data.cms.gov/provider-data/dataset/readmission-rates", "Readmission Rates"),
        ("https://data.cms.gov/provider-data/dataset/mortality-rates", "Mortality Rates"),
        ("https://data.cms.gov/provider-data/dataset/patient-experience-measures", "Patient Experience Measures"),
        ("https://data.cms.gov/provider-data/dataset/hospital-compare", "Hospital Compare"),
    ]
    
    for url, description in endpoints_to_test:
        test_endpoint_content(url, description)
        time.sleep(1)  # Be respectful to the server
    
    print("\n" + "=" * 60)
    print("🎯 NEXT STEPS:")
    print("1. Review accessible endpoints and their content")
    print("2. Identify actual data download methods")
    print("3. Test hospital-specific data access")
    print("4. Implement data collection for SEF framework validation")

if __name__ == "__main__":
    main()
