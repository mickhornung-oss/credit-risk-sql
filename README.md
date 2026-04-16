# Credit Risk SQL Analysis

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![SQL](https://img.shields.io/badge/language-SQL-blue.svg)

SQL analysis of a credit risk dataset — risk classification, interest rate patterns, default correlation, and red-flag detection using subquery-based queries compatible with MySQL 5.7+.

> **Deutsch:** SQL-Analyse eines Kreditrisiko-Datensatzes mit Risikoklassifizierung, Zinsstruktur und Red-Flag-Erkennung.

## Business Questions Answered

1. **Risk Classification** — Distribution of high/medium/low risk loans by debt-to-income ratio
2. **Interest Rate vs. Credit Grade** — Do lower grades correlate with higher rates?
3. **Default Correlation** — Which factors most strongly predict loan default?
4. **Red Flag Detection** — Configurable thresholds for large loans at low interest rates

## Key Technical Choices

- **No CTEs (WITH clause)** — compatible with MySQL 5.7+ using derived tables / subqueries instead
- **Configurable parameters** — risk thresholds set via `@SCHWELLE_GROSSER_BETRAG` and `@SCHWELLE_NIEDRIGER_ZINS`
- **Clean separation** — raw dataset vs. SQL-ready cleaned version

## Usage

```sql
-- 1. Import the cleaned dataset
-- Use: credit_risk_dataset_sql_ready_v2.csv

-- 2. Run the analysis script
SOURCE 'SQL Abschluss.sql';
```

## Files

| File | Description |
|---|---|
| `SQL Abschluss.sql` | Main analysis script (6 business questions) |
| `credit_risk_dataset_org.csv` | Original raw dataset |
| `credit_risk_dataset_sql_ready_v2.csv` | Cleaned, SQL-ready version |
| `ProjektA_Handout_Styled.pdf` | Analysis summary |

## Tech Stack

- SQL (MySQL 5.7+ compatible)
- CSV data preparation (pandas)
