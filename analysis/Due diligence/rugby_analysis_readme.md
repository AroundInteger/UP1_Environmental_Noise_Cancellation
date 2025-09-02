# Rugby KPI Relativization Analysis Framework

This MATLAB framework implements the mathematical theory from the paper "Relative Advantage: Quantifying Performance in Noisy Competitive Settings" to analyze whether rugby Key Performance Indicators (KPIs) satisfy the conditions for effective relativization.

## Overview

The framework tests whether rugby performance metrics adhere to the four fundamental axioms required for successful relativization:

1. **Invariance to Shared Effects**: R(X_A + η, X_B + η) = R(X_A, X_B)
2. **Ordinal Consistency**: If μ_A > μ_B, then E[R(X_A, X_B)] > 0
3. **Scaling Proportionality**: R(αX_A, αX_B) = αR(X_A, X_B)  
4. **Optimality**: SNR improvement through environmental noise cancellation

## Data Requirements

The analysis requires two CSV files:

- **S20Relative.csv**: Contains relative differences (Team A - Team B) for each KPI
- **S20Isolated.csv**: Contains absolute values for individual teams

### Expected Data Structure

Both files should contain rugby performance indicators including:
- `Tries`, `Carry`, `MetresMade`, `DefenderBeaten`
- `Pass`, `Tackle`, `MissedTackle`, `Turnover`
- `CleanBreaks`, `Turnovers_Won`, `LineoutsWon`
- `ScrumsWon`, `RucksWon`, `Total_Penalty_Conceded`
- `Match_Outcome` (W/L), `Home_or_Away` (H/A)

## Key Functions

### Main Analysis Function
```matlab
analyze_rugby_relativization()
```
Runs the complete analysis pipeline, testing all axioms and generating results.

### Core Testing Functions

1. **test_invariance_axiom()**: Tests environmental noise cancellation
2. **test_ordinal_consistency()**: Validates directional relationships
3. **test_scaling_proportionality()**: Verifies linear scaling properties
4. **test_snr_improvement()**: Analyzes signal-to-noise ratio improvements

### Statistical Validation
```matlab
test_statistical_assumptions()
```
Tests normality and independence assumptions using:
- Jarque-Bera test for normality
- Kolmogorov-Smirnov test for distribution fit
- Autocorrelation analysis for independence

### Performance Comparison
```matlab
compare_predictive_performance()
```
Compares relative vs absolute metrics using:
- AUC-ROC analysis
- Separability metrics (S = Φ(d/2))
- Information content (I = 1 - H(S))

## Theoretical Framework

The analysis implements the mathematical framework from the paper:

### Signal-to-Noise Ratio Improvement
```
SNR_improvement = (σ_A² + σ_η²)/(σ_A² + σ_B²) ≈ 1 + σ_η²/(σ_A² + σ_B²)
```

### Separability Metric
```
S = Φ(d/2) where d = 2|μ_A - μ_B|/√(σ_A² + σ_B²)
```

### Information Content
```
I = 1 - H(S) where H(p) = -p·log₂(p) - (1-p)·log₂(1-p)
```

## Expected Outputs

### Console Output
- Real-time progress of axiom testing
- Statistical test results for each KPI
- Performance comparison metrics
- Overall framework applicability assessment

### Saved Results
- `rugby_relativization_results.mat`: Complete analysis results
- Summary structure with:
  - Axiom satisfaction rates
  - SNR improvements per KPI
  - Environmental noise estimates
  - Practical recommendations

## Interpretation Guidelines

### Axiom Satisfaction Thresholds
- **Invariance**: Correlation > 0.999 with added noise
- **Ordinal Consistency**: >80% of KPIs show expected directional effects
- **Scaling**: Mean proportionality error < 1%
- **Optimality**: Majority of KPIs show SNR improvement > 1.0

### Environmental Noise Assessment
The framework estimates the noise ratio σ_η/σ_indiv:
- **High noise** (>0.3): Strong relativization benefits expected
- **Moderate noise** (0.1-0.3): Moderate benefits
- **Low noise** (<0.1): Limited benefits

### Performance Improvement Expectations
Based on theory, expect:
- **High noise scenarios**: 15-25% AUC improvement
- **Moderate noise scenarios**: 5-15% improvement  
- **Low noise scenarios**: <5% improvement

## Usage Instructions

1. **Prepare Data**: Ensure CSV files are in the MATLAB working directory
2. **Run Analysis**: Execute `analyze_rugby_relativization()`
3. **Review Results**: Check console output and saved results file
4. **Interpret Findings**: Use guidelines above to assess framework applicability

## Practical Applications

### When Relativization is Recommended
- High environmental noise ratio (>0.3)
- Majority of KPIs show ordinal consistency
- SNR improvements exceed 1.5x for key metrics

### KPI-Specific Considerations
- **Tries, Clean Breaks**: Typically show strong relativization benefits
- **Tackles, Passes**: May show moderate benefits due to match context
- **Penalty Conceded**: Often benefits significantly from relativization

### Match Context Factors
The framework accounts for:
- Home/away effects
- Match conditions (weather, referee, etc.)
- Team strength disparities
- Seasonal variations

## Limitations and Considerations

1. **Sample Size**: Requires minimum 20 observations per KPI for reliable results
2. **Data Quality**: Results depend on accurate, complete data recording
3. **Normality Assumption**: Some KPIs may violate normality assumptions
4. **Temporal Independence**: Assumes matches are independent observations

## Technical Requirements

- MATLAB R2018b or later
- Statistics and Machine Learning Toolbox
- Signal Processing Toolbox (for autocorrelation analysis)

## References

This framework implements the theoretical foundation from:
"Relative Advantage: Quantifying Performance in Noisy Competitive Settings" - Mathematical framework for environmental noise cancellation through relativization in competitive performance measurement.

## Contact and Support

For questions about the theoretical framework or implementation details, refer to the original paper's mathematical derivations and proofs in Sections 2-3.