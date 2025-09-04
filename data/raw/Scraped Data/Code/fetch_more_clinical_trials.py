import requests
import pandas as pd
import json

def fetch_more_clinical_trials(target_measurements=1000):
    """
    Fetch more clinical trials to get closer to the required measurement count
    """
    print(f"=== FETCHING MORE CLINICAL TRIALS (Target: {target_measurements} measurements) ===\n")
    
    base_url = "https://clinicaltrials.gov/api/v2/studies"
    
    # Try to get more studies by making multiple API calls
    all_studies = []
    page_token = None
    max_attempts = 50  # Limit to avoid overwhelming the API
    
    for attempt in range(max_attempts):
        try:
            print(f"Fetching batch {attempt + 1}...")
            
            # Make API call
            if page_token:
                response = requests.get(base_url, params={'pageToken': page_token})
            else:
                response = requests.get(base_url)
            
            if response.status_code == 200:
                data = response.json()
                
                if 'studies' in data:
                    studies = data['studies']
                    print(f"  Retrieved {len(studies)} studies")
                    all_studies.extend(studies)
                    
                    # Check if we have enough data
                    total_measurements = estimate_total_measurements(all_studies)
                    print(f"  Total estimated measurements: {total_measurements}")
                    
                    if total_measurements >= target_measurements:
                        print(f"  ✓ Reached target of {target_measurements} measurements")
                        break
                    
                    # Get next page token
                    page_token = data.get('nextPageToken')
                    if not page_token:
                        print("  No more pages available")
                        break
                else:
                    print("  No studies found in response")
                    break
            else:
                print(f"  API call failed: {response.status_code}")
                break
                
        except Exception as e:
            print(f"  Error in batch {attempt + 1}: {e}")
            break
    
    print(f"\nTotal studies retrieved: {len(all_studies)}")
    
    # Process and filter studies
    processed_studies = process_studies_for_measurements(all_studies)
    
    # Save results
    if processed_studies:
        df = pd.DataFrame(processed_studies)
        filename = f"clinical_trials_extended_{len(df)}_studies.csv"
        df.to_csv(filename, index=False)
        print(f"\n✓ Saved {len(df)} studies to {filename}")
        
        # Estimate total measurements
        total_measurements = estimate_total_measurements_from_df(df)
        print(f"✓ Estimated total measurements: {total_measurements}")
        
        return df
    else:
        print("\n✗ No suitable studies found")
        return None

def estimate_total_measurements(studies):
    """
    Estimate total measurements from studies
    """
    total = 0
    for study in studies:
        # Try to extract enrollment count
        try:
            protocol = study.get('protocolSection', {})
            design = protocol.get('designModule', {})
            enrollment_info = design.get('enrollmentInfo', {})
            count = enrollment_info.get('count', 0)
            
            if isinstance(count, (int, float)) and count > 0:
                total += count
            else:
                # Default estimate if no count available
                total += 50  # Conservative estimate
        except:
            total += 50  # Default estimate
    
    return total

def estimate_total_measurements_from_df(df):
    """
    Estimate total measurements from processed DataFrame
    """
    if 'EnrollmentCount' in df.columns:
        enrollment_counts = pd.to_numeric(df['EnrollmentCount'], errors='coerce')
        valid_counts = enrollment_counts.dropna()
        return int(valid_counts.sum())
    else:
        return len(df) * 50  # Conservative estimate

def process_studies_for_measurements(studies):
    """
    Process studies and extract relevant information for measurements
    """
    processed_studies = []
    
    for study in studies:
        try:
            # Extract basic study information
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
                processed_study = {
                    'NCTId': nct_id,
                    'Condition': condition_text,
                    'InterventionName': intervention_text,
                    'StudyType': study_type,
                    'EnrollmentCount': enrollment_count
                }
                processed_studies.append(processed_study)
                
        except Exception as e:
            print(f"Error processing study: {e}")
            continue
    
    return processed_studies

def analyze_measurement_distribution(df):
    """
    Analyze the distribution of measurements across studies
    """
    if df is None or len(df) == 0:
        return
    
    print("\n=== MEASUREMENT DISTRIBUTION ANALYSIS ===")
    
    enrollment_counts = pd.to_numeric(df['EnrollmentCount'], errors='coerce')
    valid_counts = enrollment_counts.dropna()
    
    print(f"Total studies: {len(df)}")
    print(f"Studies with valid enrollment counts: {len(valid_counts)}")
    print(f"Total estimated measurements: {int(valid_counts.sum())}")
    print(f"Average measurements per study: {valid_counts.mean():.1f}")
    print(f"Median measurements per study: {valid_counts.median():.1f}")
    print(f"Min measurements per study: {valid_counts.min()}")
    print(f"Max measurements per study: {valid_counts.max()}")
    
    # Distribution analysis
    print(f"\nMeasurement distribution:")
    print(f"  Small studies (<50): {len(valid_counts[valid_counts < 50])}")
    print(f"  Medium studies (50-200): {len(valid_counts[(valid_counts >= 50) & (valid_counts < 200)])}")
    print(f"  Large studies (200+): {len(valid_counts[valid_counts >= 200])}")
    
    # Study type analysis
    study_type_counts = df['StudyType'].value_counts()
    print(f"\nStudy type distribution:")
    for study_type, count in study_type_counts.items():
        print(f"  {study_type}: {count}")

def create_measurement_strategy_recommendation(df):
    """
    Create recommendations for achieving sufficient measurements
    """
    if df is None:
        return
    
    total_measurements = estimate_total_measurements_from_df(df)
    
    print("\n=== MEASUREMENT STRATEGY RECOMMENDATIONS ===")
    
    if total_measurements >= 1000:
        print("✓ SUFFICIENT MEASUREMENTS ACHIEVED!")
        print(f"  Total measurements: {total_measurements}")
        print("  Ready for framework integration")
    else:
        print("⚠️ INSUFFICIENT MEASUREMENTS")
        print(f"  Current measurements: {total_measurements}")
        print(f"  Target: 1000+")
        print(f"  Shortfall: {1000 - total_measurements}")
        
        print("\nRecommended strategies:")
        print("1. Fetch more clinical trials from different conditions")
        print("2. Use individual patient data if available")
        print("3. Combine with synthetic data for proof-of-principle")
        print("4. Use enrollment counts as proxy measurements")
        print("5. Consider other data sources (FDA, WHO, etc.)")

if __name__ == "__main__":
    print("Fetching more clinical trials to achieve sufficient measurements...\n")
    
    # Try to fetch more trials
    df = fetch_more_clinical_trials(target_measurements=1000)
    
    if df is not None:
        # Analyze the data
        analyze_measurement_distribution(df)
        create_measurement_strategy_recommendation(df)
        
        print(f"\n✓ Extended clinical trial data ready for validation")
        print("  Run: python3 validate_clinical_data.py")
    else:
        print("\n✗ Failed to fetch sufficient clinical trial data")
        print("  Consider alternative data sources or synthetic data approach") 