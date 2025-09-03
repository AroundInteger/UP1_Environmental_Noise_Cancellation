# 📊 **Data Format Guide for Interactive Analysis Pipeline**

## 📋 **Required CSV Format**

The Interactive Data Analysis Pipeline requires CSV files with specific column types. Here's the complete format specification:

### **Essential Columns**

#### **1. Team/Group Identifier Column**
- **Purpose**: Identifies different teams, groups, or competitors
- **Format**: Text/String (e.g., "Team A", "Team B", "Company X", "Group 1")
- **Requirements**: 
  - Must have at least 2 unique values
  - Should have reasonable number of groups (2-20 recommended)
  - Each row represents one observation for one team/group

#### **2. Outcome Column**
- **Purpose**: Binary outcomes for comparison
- **Format**: Text/String with exactly 2 unique values
- **Examples**: 
  - "Win"/"Loss"
  - "Success"/"Failure" 
  - "High"/"Low"
  - "Pass"/"Fail"
  - "1"/"0"

#### **3. Metric Columns**
- **Purpose**: Numeric performance measures to analyze
- **Format**: Numeric (integers or decimals)
- **Requirements**:
  - Must be numeric data
  - Should represent performance indicators
  - Avoid obvious scoring metrics (goals, points, etc.)
  - Focus on technical/process metrics

### **Optional Columns**

#### **4. Match/Event Identifier**
- **Purpose**: Groups observations from the same event
- **Format**: Text/String or Numeric
- **Examples**: Match ID, Game ID, Event ID, Session ID

#### **5. Date/Time Columns**
- **Purpose**: Temporal information
- **Format**: Date/DateTime or Text
- **Examples**: "2024-01-15", "Q1-2024", "Session 1"

#### **6. Additional Context Columns**
- **Purpose**: Additional information for analysis
- **Format**: Any (Text, Numeric, Categorical)
- **Examples**: Venue, Weather, Conditions, etc.

## 📝 **CSV Structure Example**

```csv
Team,Match_ID,Outcome,Carries,Metres,Tackles,Passes,Offloads,Date,Venue
Team_A,Match_001,Win,45,320,28,156,8,2024-01-15,Home
Team_B,Match_001,Loss,38,280,32,142,6,2024-01-15,Away
Team_A,Match_002,Loss,42,290,25,148,7,2024-01-22,Away
Team_B,Match_002,Win,48,350,30,162,9,2024-01-22,Home
Team_A,Match_003,Win,50,380,27,170,10,2024-01-29,Home
Team_B,Match_003,Loss,35,260,35,138,5,2024-01-29,Away
```

## 🎯 **Best Practices**

### **Data Quality**
- **No missing values** in essential columns
- **Consistent naming** conventions
- **Proper data types** (numeric for metrics, text for identifiers)
- **Reasonable sample sizes** (minimum 10 observations per team)

### **Metric Selection**
- **Avoid obvious scoring metrics** (goals, points, scores)
- **Focus on technical metrics** (carries, passes, tackles, etc.)
- **Include process indicators** (efficiency, accuracy, consistency)
- **Consider environmental factors** (weather, venue, conditions)

### **Team/Group Structure**
- **Balanced representation** across teams
- **Consistent team names** throughout dataset
- **Reasonable number of teams** (2-20 recommended)
- **Sufficient observations** per team (minimum 10)

## 🔍 **Data Validation Checklist**

Before running the pipeline, ensure your data has:

- [ ] **Team/Group column** with 2+ unique values
- [ ] **Outcome column** with exactly 2 unique values
- [ ] **Numeric metric columns** (3+ recommended)
- [ ] **No missing values** in essential columns
- [ ] **Consistent data types** across columns
- [ ] **Reasonable sample sizes** (10+ observations per team)
- [ ] **Proper CSV formatting** (comma-separated, UTF-8 encoding)

## 📊 **Example Datasets**

### **Sports Analytics**
- **Rugby**: Carries, Metres, Tackles, Passes, Offloads
- **Football**: Possession, Shots, Passes, Interceptions
- **Basketball**: Assists, Rebounds, Steals, Blocks

### **Business Analytics**
- **Sales**: Calls, Meetings, Proposals, Conversions
- **Marketing**: Impressions, Clicks, Engagement, Reach
- **Operations**: Efficiency, Quality, Speed, Accuracy

### **Healthcare Analytics**
- **Treatment**: Sessions, Duration, Compliance, Outcomes
- **Patient Care**: Visits, Tests, Procedures, Recovery
- **Clinical**: Measurements, Assessments, Interventions

## 🚀 **Getting Started**

1. **Prepare your data** in the required CSV format
2. **Validate data quality** using the checklist above
3. **Run the pipeline** with your data file
4. **Review recommendations** and implement strategies
5. **Monitor improvements** and validate results

## 📞 **Support**

If you need help with data formatting:
- **Check the examples** in this guide
- **Use the validation checklist** above
- **Review the demo data** for reference
- **Contact support** for specific questions

---

**Ready to analyze your data? Follow this format guide and run the Interactive Data Analysis Pipeline!** 🚀
