import requests
import pandas as pd
import json

# Simple test of ClinicalTrials.gov API v2.0 to understand the structure

def test_api_structure():
    """
    Test different API calls to understand the new v2.0 structure
    """
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    # Test 1: Basic call with minimal parameters
    print("=== Test 1: Basic API call ===")
    try:
        response = requests.get(base_url)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response keys: {list(data.keys())}")
            print(f"Response structure: {json.dumps(data, indent=2)[:500]}...")
        else:
            print(f"Error response: {response.text[:200]}")
    except Exception as e:
        print(f"Exception: {e}")
    
    # Test 2: Try with just a query parameter
    print("\n=== Test 2: With query parameter ===")
    try:
        params = {'query': 'diabetes'}
        response = requests.get(base_url, params=params)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response keys: {list(data.keys())}")
            if 'studies' in data:
                print(f"Number of studies: {len(data['studies'])}")
                if len(data['studies']) > 0:
                    print(f"First study keys: {list(data['studies'][0].keys())}")
        else:
            print(f"Error response: {response.text[:200]}")
    except Exception as e:
        print(f"Exception: {e}")
    
    # Test 3: Try with size parameter
    print("\n=== Test 3: With size parameter ===")
    try:
        params = {'query': 'diabetes', 'size': 5}
        response = requests.get(base_url, params=params)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response keys: {list(data.keys())}")
            if 'studies' in data:
                print(f"Number of studies: {len(data['studies'])}")
                # Save to CSV if we got data
                if len(data['studies']) > 0:
                    df = pd.DataFrame(data['studies'])
                    df.to_csv('clinical_trials_diabetes_simple.csv', index=False)
                    print(f"Saved {len(df)} studies to clinical_trials_diabetes_simple.csv")
                    print("\nFirst few records:")
                    print(df.head())
        else:
            print(f"Error response: {response.text[:200]}")
    except Exception as e:
        print(f"Exception: {e}")

def fetch_simple_trials(condition="diabetes", n=5):
    """
    Simple fetch function based on what we learn from the tests
    """
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    params = {
        'query': condition,
        'size': n
    }
    
    try:
        response = requests.get(base_url, params=params)
        
        if response.status_code == 200:
            data = response.json()
            
            if 'studies' in data and len(data['studies']) > 0:
                df = pd.DataFrame(data['studies'])
                filename = f"clinical_trials_{condition}_simple.csv"
                df.to_csv(filename, index=False)
                print(f"Successfully saved {len(df)} studies to {filename}")
                return df
            else:
                print("No studies found in response")
                return None
        else:
            print(f"API call failed with status {response.status_code}")
            print(f"Response: {response.text[:200]}")
            return None
            
    except Exception as e:
        print(f"Exception: {e}")
        return None

if __name__ == "__main__":
    print("=== ClinicalTrials.gov API v2.0 Structure Test ===\n")
    
    # First, explore the API structure
    test_api_structure()
    
    print("\n" + "="*50)
    print("=== Simple Fetch Test ===")
    
    # Then try a simple fetch
    df = fetch_simple_trials("diabetes", 5)
    
    if df is not None:
        print(f"\nSuccessfully fetched {len(df)} diabetes studies")
        print("Data columns:", list(df.columns))
    else:
        print("\nFailed to fetch studies") 