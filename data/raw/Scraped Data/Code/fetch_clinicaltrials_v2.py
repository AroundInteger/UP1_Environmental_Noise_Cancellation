import requests
import pandas as pd
import json

# Fetch a small subset of clinical trials using the new ClinicalTrials.gov API v2.0

def fetch_trials_v2(condition="diabetes", n=10):
    """
    Fetch clinical trials using the new ClinicalTrials.gov API v2.0
    """
    # New API v2.0 endpoint for searching studies
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    # Query parameters for the new API
    params = {
        'query.term': condition,
        'pageSize': n,
        'page': 1,
        'fields': 'NCTId,Condition,InterventionName,PrimaryOutcomeMeasure,EnrollmentCount,StudyType'
    }
    
    try:
        print(f"Fetching {n} studies for condition: {condition}")
        print(f"URL: {base_url}")
        print(f"Params: {params}")
        
        response = requests.get(base_url, params=params)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response keys: {list(data.keys())}")
            
            # Extract studies from the response
            if 'studies' in data:
                studies = data['studies']
                print(f"Found {len(studies)} studies")
                
                # Convert to DataFrame
                df = pd.DataFrame(studies)
                
                # Save to CSV
                filename = f"clinical_trials_{condition}_v2.csv"
                df.to_csv(filename, index=False)
                print(f"Saved {filename} with {len(df)} records")
                
                # Display first few records
                if len(df) > 0:
                    print("\nFirst few records:")
                    print(df.head())
                
                return df
            else:
                print("No 'studies' key found in response")
                print(f"Available keys: {list(data.keys())}")
                return None
                
        else:
            print(f"Error: {response.status_code}")
            print(f"Response text: {response.text[:500]}")
            return None
            
    except Exception as e:
        print(f"Exception occurred: {e}")
        return None

def fetch_trials_alternative(condition="diabetes", n=10):
    """
    Alternative approach using the studies endpoint with different parameters
    """
    # Try alternative endpoint structure
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    # Alternative query format
    params = {
        'query': condition,
        'pageSize': n,
        'page': 1
    }
    
    try:
        print(f"\nTrying alternative approach for condition: {condition}")
        response = requests.get(base_url, params=params)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response structure: {list(data.keys())}")
            
            # Try to extract studies
            studies = data.get('studies', [])
            if studies:
                df = pd.DataFrame(studies)
                filename = f"clinical_trials_{condition}_alt.csv"
                df.to_csv(filename, index=False)
                print(f"Saved {filename} with {len(df)} records")
                return df
            else:
                print("No studies found in response")
                return None
        else:
            print(f"Alternative approach failed: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"Alternative approach exception: {e}")
        return None

if __name__ == "__main__":
    print("=== ClinicalTrials.gov API v2.0 Test ===\n")
    
    # Try the main approach
    df1 = fetch_trials_v2("diabetes", 5)
    
    # If that fails, try alternative approach
    if df1 is None:
        print("\nTrying alternative approach...")
        df2 = fetch_trials_alternative("diabetes", 5)
        
        if df2 is None:
            print("\nBoth approaches failed. The API structure may have changed.")
            print("Please check the latest ClinicalTrials.gov API documentation.") 