# 2 Computational Reproducibility
## 2.1 Data Availability
The data for this study originates from an experimental survey conducted on Amazon Mechanical Turk (MTurk) in June 2018, with a preregistered replication conducted one year later. The dataset is publicly available through the American Economic Association data repository. The project includes five CSV files located in the data folder: raw_data.csv contains the original unprocessed responses from 1,387 participants; cleaned_data.csv presents the cleaned dataset after applying attention and comprehension checks, retaining 987 subjects (76% of original sample); cleaned_data_withfailedcheck.csv includes all 1,300 participants who completed the study regardless of attention checks; replication_data.csv contains data from the one-year later replication study; and cleaned_replication_data.csv provides the cleaned replication sample.

The experimental design involved 14 questions per subject—10 politicized topics, 3 neutral questions, and 1 comprehension check—generating 11,661 individual guesses and 11,443 news assessments. Subjects rated their beliefs on politicized issues (crime under Obama, upward mobility, racial discrimination, gender, refugees, climate change, gun reform, media bias, and party performance), received randomized messages classified as Pro-Party or Anti-Party news, and assessed source veracity on an 11-point scale. The cleaned datasets include all necessary variables for reproducing the main results: belief assessments, news veracity judgments, demographic characteristics, party ratings, and treatment assignments.

## 2.2 Code Availability
The original analysis employed Stata for data cleaning and statistical analysis, with code files located in the codes folder. The master workflow consists of: 0-Master.do (orchestrates the entire pipeline), 1-Cleaning.do (initial data processing), 2-CleanReplication.do (replication data preparation), 3-Analysis.do (main analyses), 4-AnalysisReplication.do (replication analyses), 5-Numbers.do (summary statistics and figures), and config_stata.do (configuration settings). These Stata files implement regression specifications using reghdfe for high-dimensional fixed effects estimation, create LaTeX tables, generate publication-ready figures, and conduct robustness checks.

The replication analysis undertaken by this project translates the Stata analyses into Python, leveraging Jupyter notebooks stored in the replication folder. The notebook suite includes: Figure_1.ipynb, Figure2.ipynb, Figure3.ipynb, and Figure4.ipynb for figure reproduction; Table_2.ipynb and Table_3.ipynb for main results tables. This dual-language approach ensures accessibility to researchers familiar with different statistical platforms while maintaining analytical consistency. Both implementations employ identical regression specifications, variable definitions, and statistical inference procedures. The code emphasizes transparency through detailed comments, explicit variable transformations, and documented assumptions underlying each analysis step.

## 2.3 Reproduction Workflow

The computational workflow follows a structured pipeline designed for transparency and verification. Users can reproduce results using either the original Stata implementation or the Python-based replication. The workflow requires approximately 30 minutes for complete execution.

### Stata Workflow

| Step | File | Purpose |
|------|------|---------|
| 1 | `config_stata.do` | Configure file paths and project settings |
| 2 | `0-Master.do` | Orchestrate the entire pipeline execution |
| 3 | `1-Cleaning.do` | Process raw responses from MTurk survey |
| 4 | `3-Analysis.do` | Generate main regression results and specifications |
| 5 | `5-Numbers.do` | Produce publication-ready tables and figures |

### Python (Pandas) Workflow

| Step | Notebook | Purpose |
|------|----------|---------|
| 1 | Load `cleaned_data.csv` | Main dataset with 987 subjects after quality checks |
| 2 | `Table_2.ipynb` | Reproduce core regression results (Pro-Party effects) |
| 3 | `Table_3.ipynb` | Reproduce belief polarization and message-following analysis |
| 4 | `Figure_1.ipynb` through `Figure4.ipynb` | Generate figure visualizations in sequence |

### Key Verification Checklist

| Verification Step | Expected Outcome |
|-------------------|------------------|
| Sample size validation | 987 non-neutral subjects after attention checks |
| Treatment balance | Pro-Party and Anti-Party conditions equally distributed |
| Fixed-effects specification | Subject, question, and round fixed effects properly absorbed |
| Coefficient validation | Effect magnitudes match published Table 2 and Table 3 |
| Standard errors | Clustered at subject level for all regressions |
| Visualization accuracy | Figures replicate published formatting and distributions |

### Data Requirements

Begin by acquiring the cleaned datasets from the `data/` folder. Use `cleaned_data.csv` for main analyses and `cleaned_replication_data.csv` to validate findings on an independent sample. Each notebook is self-contained and loads necessary CSV files independently. Researchers should document any discrepancies between original and replicated results, as these often indicate data processing differences or software-specific numerical precision variations.