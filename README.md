# Hospital Readmission Risk Analysis

## Project Overview

Hospital readmissions are a critical healthcare quality metric, often indicating gaps in patient recovery, discharge planning, or follow-up care.

This project analyses **101,766 hospital encounters** to identify the key drivers behind **30-day patient readmissions**.

The workflow combines:

* **SQL** for data cleaning and cohort analysis
* **Excel** for structured aggregation
* **Tableau** for executive-level visualization

The objective is to move beyond descriptive analysis and **quantify which factors most strongly influence readmission risk**.

---

## Dataset

**Dataset:** Diabetes 130-US Hospitals Dataset (1999–2008)

| Metric              | Value      |
| ------------------- | ---------- |
| Total Encounters    | 101,766    |
| Unique Patients     | 71,518     |
| 30-Day Readmissions | 11,357     |
| Readmission Rate    | **11.16%** |

---

## Data Preparation

### 1. Readmission Label Cleaning

The `readmitted` column contained hidden characters (`\r`). These were removed using SQL string functions to ensure accurate filtering.

---

### 2. Binary Readmission Flag

A consistent analytical metric was created:

```sql
CASE
WHEN TRIM(readmitted) = '<30' THEN 1
ELSE 0
END AS readmission_flag
```

Readmission rate is computed as:

```sql
AVG(readmission_flag)
```

---

### 3. Feature Engineering

To enable cohort-based analysis:

* **Medication Band**

  * Low (<10)
  * Medium (10–20)
  * High (>20)

* **Diagnosis Complexity**

  * Low (≤3)
  * Medium (4–7)
  * High (≥8)

* **Length of Stay**

  * Short (≤3 days)
  * Medium (4–7 days)
  * Long (>7 days)

---

## Analytical Approach

The analysis focuses on identifying **drivers of readmission risk** using:

* Cohort segmentation
* Baseline comparison
* Absolute and relative risk changes
* Driver ranking

---

## Key Findings

### 1. Readmission Rate by Age

* Peak readmission observed in **20–30 age group (~14%)**
* Rates remain elevated across older groups (~11–12%)

**Insight:** Readmission risk rises after early adulthood and remains consistently high across later age groups.

---

### 2. Length of Stay Impact

| Days | Readmission Rate |
| ---- | ---------------- |
| 1    | 8.18%            |
| 5    | 12.03%           |
| 10   | 14.35%           |

* Relative increase: **~75% vs baseline (1-day stay)**

**Insight:** Longer hospital stays are strongly associated with higher readmission risk.

---

### 3. Medication Load Impact

| Band   | Readmission Rate |
| ------ | ---------------- |
| Low    | 8.83%            |
| Medium | 11.32%           |
| High   | 12.78%           |

* Relative increase: **~44.7% vs low medication group**

**Insight:** Higher medication load correlates with increased readmission probability, indicating treatment complexity.

---

### 4. Diagnosis Complexity Impact

| Group  | Readmission Trend |
| ------ | ----------------- |
| Low    | ~7%               |
| Medium | ~9–11%            |
| High   | ~12–17%           |

* Relative increase: **~76% vs low complexity group**

**Insight:** Multimorbidity is one of the strongest predictors of readmission risk.

---

## Driver Ranking

| Factor               | Relative Increase |
| -------------------- | ----------------- |
| Diagnosis Complexity | **~76%**          |
| Length of Stay       | **~75%**          |
| Medication Load      | **~45%**          |

### Final Insight

Diagnosis complexity and length of stay are the **primary drivers of readmission risk**, both contributing significantly higher impact than medication load.

---

## Tableau Dashboard

🔗 **[View Interactive Dashboard](https://public.tableau.com/views/HospitalReadmissionRiskAnalysis_17729544247920/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

---

## Dashboard Features

* KPI Overview (Total Encounters, Readmission Rate)
* Readmission trends by age and length of stay
* Cohort analysis for medication load and diagnosis complexity
* Driver ranking visual
* Executive summary for quick decision-making

---

## Tools Used

| Tool    | Purpose                                             |
| ------- | --------------------------------------------------- |
| SQL     | Data cleaning, cohort analysis, risk quantification |
| Excel   | Intermediate aggregation                            |
| Tableau | Dashboard and visualization                         |

---

## Business Implications

* Prioritise **high-risk patients (complex diagnoses, long stays)**
* Improve **discharge planning for complex cases**
* Allocate **follow-up care resources more effectively**
* Reduce avoidable readmissions through targeted interventions

---

## Conclusion

This project demonstrates the ability to:

* Perform structured cohort analysis
* Quantify risk using baseline comparisons
* Identify and rank key drivers
* Translate analysis into actionable insights
* Build executive-level dashboards

---
