# Example Formatted Dataset

## Dataset Information
- **Source**: 4 seasons rugby data
- **Rows**: 1128
- **Columns**: 15
- **Teams**: 16
- **Seasons**: 21/22, 22/23, 23/24, 24/25

## Column Descriptions

### Essential Columns
- **Team**: Team identifier (16 unique teams)
- **Match_ID**: Match identifier
- **Outcome**: Match outcome (loss, win)

### Technical Metrics
- **Carries**: Number of ball carries
- **Metres_Made**: Total metres gained
- **Defenders_Beaten**: Number of defenders beaten
- **Offloads**: Number of offloads
- **Passes**: Number of passes
- **Tackles**: Number of tackles
- **Clean_Breaks**: Number of clean breaks
- **Turnovers_Won**: Number of turnovers won
- **Rucks_Won**: Number of rucks won
- **Lineout_Throws_Won**: Number of lineout throws won

### Context Columns
- **Season**: Season identifier
- **Match_Location**: Home/Away indicator

## Usage
This dataset is ready for use with the Interactive Data Analysis Pipeline.
Run: `scripts/Demo_User_Analysis_Pipeline.m` with this dataset.
