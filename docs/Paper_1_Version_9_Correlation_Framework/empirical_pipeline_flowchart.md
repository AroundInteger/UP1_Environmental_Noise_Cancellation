# Empirical Processing Pipeline Flowchart

```mermaid
flowchart TD
    %% Data Input Phase
    A[Raw Data Collection<br/>Professional rugby data<br/>Multiple seasons] --> B[Data Standardization<br/>Normalization across<br/>measurement scales]
    B --> C[Quality Assessment<br/>Completeness and<br/>consistency validation]
    C --> D{Quality<br/>OK?}
    D -->|No| B
    D -->|Yes| E[Match-Level Aggregation<br/>Team performance metrics<br/>calculation]
    
    %% Statistical Validation Phase
    E --> F[Statistical Validation<br/>Pipeline]
    F --> G[Normality Testing<br/>Shapiro-Wilk and<br/>Kolmogorov-Smirnov tests]
    G --> H{Normal<br/>Distribution?}
    H -->|No| I[Data Transformation<br/>Log-transformation<br/>or other methods]
    I --> G
    H -->|Yes| J[Correlation Analysis<br/>Pairwise deletion<br/>methodology]
    J --> K[Variance Structure<br/>Analysis<br/>κ = σ²_B/σ²_A calculation]
    K --> L[SNR Calculation<br/>Signal-to-noise ratio<br/>computation]
    
    %% Framework Validation Phase
    L --> M[Framework Validation<br/>Theoretical prediction<br/>testing]
    M --> N[Prediction Accuracy<br/>Empirical vs theoretical<br/>comparison]
    N --> O[Cross-Domain Validation<br/>Multi-domain<br/>applicability testing]
    O --> P[Results & Reports<br/>Final output<br/>generation]
    
    %% Decision Points
    J --> Q{ρ > 0.05?}
    Q -->|No| R[Framework Not<br/>Applicable]
    Q -->|Yes| K
    
    %% Styling
    classDef dataInput fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef preprocessing fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef analysis fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef validation fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef output fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef decision fill:#fff9c4,stroke:#f57f17,stroke-width:2px
    classDef error fill:#ffebee,stroke:#d32f2f,stroke-width:2px
    
    class A dataInput
    class B,C,E preprocessing
    class F,G,J,K,L analysis
    class M,N,O validation
    class P output
    class D,H,Q decision
    class I,R error
```

## Key Features

- **13 Processing Stages:** Complete workflow visualization
- **Decision Points:** Quality checks, normality testing, correlation validation
- **Feedback Loops:** Data transformation and reprocessing pathways
- **Color-Coded Stages:** Different colors for each pipeline phase
- **Professional Layout:** Clean, academic-style appearance

## Integration Options

1. **GitHub:** Renders automatically in Markdown files
2. **Overleaf:** Can be exported as SVG/PNG and included
3. **Documentation:** Embedded directly in README files
4. **Presentations:** Easy to export for slides
