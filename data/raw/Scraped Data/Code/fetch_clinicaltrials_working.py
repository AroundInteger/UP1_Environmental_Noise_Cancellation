import requests
import pandas as pd
import json

# Working script for ClinicalTrials.gov API v2.0
# Based on successful basic API call

def fetch_trials_working(condition="diabetes", n=10):
    """
    Fetch clinical trials using the working API v2.0 approach
    """
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    try:
        print(f"Fetching studies from ClinicalTrials.gov API v2.0...")
        print(f"Will filter for condition: {condition}")
        
        # Basic API call that works
        response = requests.get(base_url)
        
        if response.status_code == 200:
            data = response.json()
            
            if 'studies' in data:
                studies = data['studies']
                print(f"Retrieved {len(studies)} studies from API")
                
                # Filter studies for the condition
                filtered_studies = []
                for study in studies:
                    # Check if condition appears in the study data
                    study_text = json.dumps(study).lower()
                    if condition.lower() in study_text:
                        filtered_studies.append(study)
                        if len(filtered_studies) >= n:
                            break
                
                print(f"Found {len(filtered_studies)} studies matching '{condition}'")
                
                if filtered_studies:
                    # Extract key information from each study
                    extracted_data = []
                    for study in filtered_studies:
                        study_info = extract_study_info(study)
                        if study_info:
                            extracted_data.append(study_info)
                    
                    # Convert to DataFrame
                    df = pd.DataFrame(extracted_data)
                    
                    # Save to CSV
                    filename = f"clinical_trials_{condition}_working.csv"
                    df.to_csv(filename, index=False)
                    print(f"Saved {len(df)} studies to {filename}")
                    
                    # Display sample
                    if len(df) > 0:
                        print("\nSample data:")
                        print(df.head())
                        print(f"\nColumns: {list(df.columns)}")
                    
                    return df
                else:
                    print(f"No studies found matching '{condition}'")
                    return None
            else:
                print("No 'studies' key in response")
                return None
        else:
            print(f"API call failed: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"Exception: {e}")
        return None

def extract_study_info(study):
    """
    Extract relevant information from a study object
    """
    try:
        # Navigate the nested structure to extract key fields
        protocol = study.get('protocolSection', {})
        identification = protocol.get('identificationModule', {})
        conditions = protocol.get('conditionsModule', {})
        interventions = protocol.get('interventionsModule', {})
        design = protocol.get('designModule', {})
        
        # Extract basic info
        nct_id = identification.get('nctId', 'Unknown')
        
        # Extract conditions
        condition_list = conditions.get('conditions', [])
        condition_text = ', '.join(condition_list) if condition_list else 'Unknown'
        
        # Extract interventions
        intervention_list = interventions.get('interventions', [])
        intervention_names = []
        for intervention in intervention_list:
            name = intervention.get('name', '')
            if name:
                intervention_names.append(name)
        intervention_text = ', '.join(intervention_names) if intervention_names else 'Unknown'
        
        # Extract study type
        study_type = design.get('studyType', 'Unknown')
        
        # Extract enrollment info
        enrollment_info = design.get('enrollmentInfo', {})
        enrollment_count = enrollment_info.get('count', 'Unknown')
        
        # Create study info dictionary
        study_info = {
            'NCTId': nct_id,
            'Condition': condition_text,
            'InterventionName': intervention_text,
            'StudyType': study_type,
            'EnrollmentCount': enrollment_count
        }
        
        return study_info
        
    except Exception as e:
        print(f"Error extracting study info: {e}")
        return None

def fetch_all_conditions_sample():
    """
    Fetch a sample of studies across different conditions for testing
    """
    conditions = ['diabetes', 'cancer', 'hypertension', 'depression']
    
    for condition in conditions:
        print(f"\n{'='*50}")
        print(f"Fetching studies for: {condition}")
        print(f"{'='*50}")
        
        df = fetch_trials_working(condition, 5)
        
        if df is not None:
            print(f"Successfully fetched {len(df)} {condition} studies")
        else:
            print(f"No {condition} studies found")

if __name__ == "__main__":
    print("=== ClinicalTrials.gov API v2.0 Working Script ===\n")
    
    # Test with diabetes
    df = fetch_trials_working("diabetes", 5)
    
    if df is not None:
        print(f"\n✓ Successfully fetched {len(df)} diabetes studies")
        print("✓ Data saved to CSV for MATLAB integration")
    else:
        print("\n✗ Failed to fetch diabetes studies")
        
        # Try other conditions
        print("\nTrying other conditions...")
        fetch_all_conditions_sample() 