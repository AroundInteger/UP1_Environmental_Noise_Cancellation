#!/usr/bin/env python3
"""
CMS Download Links Investigation Script

The previous tests showed that dataset pages are accessible but direct API endpoints aren't working.
Let's investigate the actual download links by examining the HTML content of these pages.
"""

import requests
import re
import json
from bs4 import BeautifulSoup
import time

def investigate_hospital_compare_page():
    """
    Investigate the Hospital Compare dataset page to find actual download links
    """
    print("=== INVESTIGATING HOSPITAL COMPARE PAGE ===")
    print("Goal: Find actual download links for hospital data")
    print("=" * 60)
    
    url = "https://data.cms.gov/provider-data/dataset/hospital-compare"
    
    try:
        print(f"Fetching: {url}")
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            html_content = response.text
            print(f"✅ Page accessible: {len(html_content)} characters")
            
            # Parse HTML to find download links
            soup = BeautifulSoup(html_content, 'html.parser')
            
            # Look for download links
            download_links = []
            
            # Find all links
            links = soup.find_all('a', href=True)
            for link in links:
                href = link['href']
                text = link.get_text().strip()
                
                # Look for download-related links
                if any(keyword in href.lower() for keyword in ['download', 'csv', 'export', 'data']):
                    download_links.append({
                        'href': href,
                        'text': text,
                        'full_url': href if href.startswith('http') else f"https://data.cms.gov{href}"
                    })
            
            print(f"\n📥 Download links found: {len(download_links)}")
            for i, link in enumerate(download_links[:10]):  # Show first 10
                print(f"  {i+1}. {link['text']}")
                print(f"     URL: {link['full_url']}")
            
            # Look for specific patterns
            patterns = {
                'csv_links': r'href="[^"]*\.csv[^"]*"',
                'download_buttons': r'href="[^"]*download[^"]*"',
                'export_links': r'href="[^"]*export[^"]*"',
                'data_links': r'href="[^"]*data[^"]*"'
            }
            
            for pattern_name, pattern in patterns.items():
                matches = re.findall(pattern, html_content, re.IGNORECASE)
                if matches:
                    print(f"\n🔍 {pattern_name}: {len(matches)} found")
                    for match in matches[:3]:  # Show first 3
                        print(f"    - {match}")
            
            return download_links
            
        else:
            print(f"❌ Page not accessible: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"⚠️ Error: {str(e)}")
        return []

def investigate_metric_pages():
    """
    Investigate specific metric pages to find download links
    """
    print(f"\n{'='*60}")
    print("INVESTIGATING METRIC PAGES")
    print("=" * 60)
    
    metric_pages = [
        "https://data.cms.gov/provider-data/dataset/patient-safety-indicators",
        "https://data.cms.gov/provider-data/dataset/hospital-acquired-conditions",
        "https://data.cms.gov/provider-data/dataset/readmission-rates",
        "https://data.cms.gov/provider-data/dataset/mortality-rates",
        "https://data.cms.gov/provider-data/dataset/patient-experience-measures"
    ]
    
    all_download_links = []
    
    for url in metric_pages:
        print(f"\n🔍 Investigating: {url}")
        try:
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                html_content = response.text
                print(f"  ✅ Page accessible: {len(html_content)} characters")
                
                # Parse HTML
                soup = BeautifulSoup(html_content, 'html.parser')
                
                # Find download links
                links = soup.find_all('a', href=True)
                page_download_links = []
                
                for link in links:
                    href = link['href']
                    text = link.get_text().strip()
                    
                    if any(keyword in href.lower() for keyword in ['download', 'csv', 'export', 'data']):
                        page_download_links.append({
                            'page': url,
                            'href': href,
                            'text': text,
                            'full_url': href if href.startswith('http') else f"https://data.cms.gov{href}"
                        })
                
                print(f"  📥 Download links: {len(page_download_links)}")
                for link in page_download_links[:3]:  # Show first 3
                    print(f"    - {link['text']}: {link['full_url']}")
                
                all_download_links.extend(page_download_links)
                
            else:
                print(f"  ❌ Page not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error: {str(e)}")
        
        time.sleep(1)
    
    return all_download_links

def test_download_links(download_links):
    """
    Test the found download links to see which ones actually work
    """
    print(f"\n{'='*60}")
    print("TESTING DOWNLOAD LINKS")
    print("=" * 60)
    
    working_links = []
    
    for i, link in enumerate(download_links):
        print(f"\n{i+1}. Testing: {link['text']}")
        print(f"   URL: {link['full_url']}")
        
        try:
            # Use HEAD request to test without downloading
            response = requests.head(link['full_url'], timeout=10)
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                content_length = response.headers.get('content-length')
                
                print(f"   ✅ Accessible")
                print(f"   Content-Type: {content_type}")
                if content_length:
                    print(f"   Size: {content_length} bytes")
                
                # Check if it's actually data
                if 'csv' in content_type.lower() or 'json' in content_type.lower():
                    print(f"   📊 Data file confirmed")
                    working_links.append(link)
                elif 'html' in content_type.lower():
                    print(f"   🌐 HTML page (may contain further links)")
                else:
                    print(f"   ❓ Unknown content type")
                    
            else:
                print(f"   ❌ Not accessible: {response.status_code}")
                
        except Exception as e:
            print(f"   ⚠️ Error: {str(e)}")
        
        time.sleep(0.5)
    
    return working_links

def investigate_cms_data_portal_structure():
    """
    Investigate the overall CMS data portal structure to understand how to access data
    """
    print(f"\n{'='*60}")
    print("INVESTIGATING CMS DATA PORTAL STRUCTURE")
    print("=" * 60)
    
    # Look at the main data portal page
    main_url = "https://data.cms.gov/provider-data/"
    
    try:
        print(f"Fetching main portal: {main_url}")
        response = requests.get(main_url, timeout=10)
        
        if response.status_code == 200:
            html_content = response.text
            print(f"✅ Main portal accessible: {len(html_content)} characters")
            
            # Parse HTML
            soup = BeautifulSoup(html_content, 'html.parser')
            
            # Look for dataset links
            dataset_links = []
            links = soup.find_all('a', href=True)
            
            for link in links:
                href = link['href']
                text = link.get_text().strip()
                
                if 'dataset' in href.lower() or 'hospital' in text.lower():
                    dataset_links.append({
                        'href': href,
                        'text': text,
                        'full_url': href if href.startswith('http') else f"https://data.cms.gov{href}"
                    })
            
            print(f"\n📊 Dataset links found: {len(dataset_links)}")
            for i, link in enumerate(dataset_links[:10]):  # Show first 10
                print(f"  {i+1}. {link['text']}")
                print(f"     URL: {link['full_url']}")
            
            return dataset_links
            
        else:
            print(f"❌ Main portal not accessible: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"⚠️ Error: {str(e)}")
        return []

def main():
    """
    Main investigation function
    """
    print("Starting CMS Download Links Investigation...")
    print("Goal: Find actual working download links for hospital data")
    
    # Step 1: Investigate Hospital Compare page
    hospital_compare_links = investigate_hospital_compare_page()
    
    # Step 2: Investigate metric pages
    metric_links = investigate_metric_pages()
    
    # Step 3: Test all found links
    all_links = hospital_compare_links + metric_links
    working_links = test_download_links(all_links)
    
    # Step 4: Investigate portal structure
    portal_links = investigate_cms_data_portal_structure()
    
    print(f"\n{'='*60}")
    print("INVESTIGATION SUMMARY")
    print("=" * 60)
    print(f"📊 Total links found: {len(all_links)}")
    print(f"✅ Working links: {len(working_links)}")
    print(f"🌐 Portal links: {len(portal_links)}")
    
    if working_links:
        print(f"\n🎉 SUCCESS: Found working download links!")
        print("Working links:")
        for link in working_links:
            print(f"  - {link['text']}: {link['full_url']}")
    else:
        print(f"\n⚠️ No working download links found")
        print("May need to investigate alternative access methods")
    
    print(f"\nNext steps:")
    print("1. Review working links")
    print("2. Test downloading actual data")
    print("3. Implement data collection for selected hospitals")
    print("4. Apply SEF framework to downloaded data")

if __name__ == "__main__":
    main()
