import requests
import pandas as pd
import json

def fetch_final_trials_to_reach_target():
    """
    Fetch a few more trials to reach 1000+ measurements
    """
    print("=== FETCHING FINAL TRIALS TO REACH 1000+ MEASUREMENTS ===\n")
    
    # Load existing data
    try:
        existing_df = pd.read_csv('clinical_trials_extended_8_studies.csv')
        current_measurements = existing_df['EnrollmentCount'].sum()
        print(f"Current measurements: {current_measurements}")
        print(f"Target: 1000+")
        print(f"Need: {max(0, 1000 - current_measurements)} more measurements\n")
    except FileNotFoundError:
        print("No existing data found. Starting fresh.")
        existing_df = None
        current_measurements = 0
    
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    # Fetch additional studies
    additional_studies = []
    attempts = 0
    max_attempts = 10
    
    while attempts < max_attempts:
        try:
            print(f"Fetching additional batch {attempts + 1}...")
            
            response = requests.get(base_url)
            
            if response.status_code == 200:
                data = response.json()
                
                if 'studies' in data:
                    studies = data['studies']
                    print(f"  Retrieved {len(studies)} studies")
                    
                    # Process and add studies
                    for study in studies:
                        processed_study = extract_study_info(study)
                        if processed_study:
                            additional_studies.append(processed_study)
                            
                            # Check if we have enough
                            total_measurements = current_measurements + sum([s['EnrollmentCount'] for s in additional_studies])
                            if total_measurements >= 1000:
                                print(f"  ✓ Reached target! Total measurements: {total_measurements}")
                                break
                    
                    if total_measurements >= 1000:
                        break
                        
                else:
                    print("  No studies found in response")
                    break
            else:
                print(f"  API call failed: {response.status_code}")
                break
                
        except Exception as e:
            print(f"  Error in batch {attempts + 1}: {e}")
            break
        
        attempts += 1
    
    # Combine existing and new data
    if additional_studies:
        new_df = pd.DataFrame(additional_studies)
        
        if existing_df is not None:
            combined_df = pd.concat([existing_df, new_df], ignore_index=True)
        else:
            combined_df = new_df
        
        # Save combined data
        filename = f"clinical_trials_final_{len(combined_df)}_studies.csv"
        combined_df.to_csv(filename, index=False)
        
        total_measurements = combined_df['EnrollmentCount'].sum()
        print(f"\n✓ Final dataset created:")
        print(f"  Total studies: {len(combined_df)}")
        print(f"  Total measurements: {total_measurements}")
        print(f"  Saved to: {filename}")
        
        # Display summary
        print(f"\nFinal measurement distribution:")
        enrollment_counts = combined_df['EnrollmentCount']
        print(f"  Small studies (<50): {len(enrollment_counts[enrollment_counts < 50])}")
        print(f"  Medium studies (50-200): {len(enrollment_counts[(enrollment_counts >= 50) & (enrollment_counts < 200)])}")
        print(f"  Large studies (200+): {len(enrollment_counts[enrollment_counts >= 200])}")
        
        return combined_df
    else:
        print("\n✗ No additional studies found")
        return existing_df

def extract_study_info(study):
    """
    Extract study information for measurements
    """
    try:
        protocol = study.get('protocolSection', {})
        identification = protocol.get('identificationModule', {})
        conditions = protocol.get('conditionsModule', {})
        interventions = protocol.get('interventionsModule', {})
        design = protocol.get('designModule', {})
        
        # Get NCT ID
        nct_id = identification.get('nctId', 'Unknown')
        
        # Get conditions
        condition_list = conditions.get('conditions', [])
        condition_text = ', '.join(condition_list) if condition_list else 'Unknown'
        
        # Get interventions
        intervention_list = interventions.get('interventions', [])
        intervention_names = []
        for intervention in intervention_list:
            name = intervention.get('name', '')
            if name:
                intervention_names.append(name)
        intervention_text = ', '.join(intervention_names) if intervention_names else 'Unknown'
        
        # Get study type
        study_type = design.get('studyType', 'Unknown')
        
        # Get enrollment info
        enrollment_info = design.get('enrollmentInfo', {})
        enrollment_count = enrollment_info.get('count', 'Unknown')
        
        # Only include studies with valid enrollment counts
        if enrollment_count != 'Unknown' and enrollment_count > 0:
            return {
                'NCTId': nct_id,
                'Condition': condition_text,
                'InterventionName': intervention_text,
                'StudyType': study_type,
                'EnrollmentCount': enrollment_count
            }
        
    except Exception as e:
        return None
    
    return None

if __name__ == "__main__":
    final_df = fetch_final_trials_to_reach_target()
    
    if final_df is not None:
        total_measurements = final_df['EnrollmentCount'].sum()
        
        if total_measurements >= 1000:
            print(f"\n🎉 SUCCESS! Achieved {total_measurements} measurements")
            print("Ready for framework integration!")
        else:
            print(f"\n⚠️ Still short: {total_measurements} measurements")
            print("Consider using synthetic data to supplement")
    else:
        print("\n✗ Failed to create final dataset") 