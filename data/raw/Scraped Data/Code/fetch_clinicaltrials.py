import requests
import pandas as pd

# Fetch a small subset of clinical trials for a given condition

def fetch_trials(condition="diabetes", n=10):
    url = (
        "https://clinicaltrials.gov/api/query/study_fields"
        "?expr={}&fields=NCTId,Condition,InterventionName,PrimaryOutcomeMeasure,EnrollmentCount,StudyType"
        "&min_rnk=1&max_rnk={}&fmt=json"
    ).format(condition, n)
    r = requests.get(url)
    try:
        data = r.json()
    except Exception as e:
        print(f"Failed to decode JSON. Status code: {r.status_code}")
        print(f"Response text: {r.text[:500]}")
        raise
    fields = data['StudyFieldsResponse']['StudyFields']
    # Convert list of dicts to DataFrame
    df = pd.DataFrame(fields)
    # Save to CSV
    df.to_csv("clinical_trials_sample.csv", index=False)
    print("Saved clinical_trials_sample.csv with {} records.".format(len(df)))

if __name__ == "__main__":
    fetch_trials() 