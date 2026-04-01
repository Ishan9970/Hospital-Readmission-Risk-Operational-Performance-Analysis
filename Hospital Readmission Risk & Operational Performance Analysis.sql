create schema healthcare_project;
use healthcare_project;

-- Section 1 - Dataset Overview
describe patient_data;


select * from patient_data;


-- Total Rows
SELECT COUNT(*) 
FROM patient_data;

-- Column Structure 
DESCRIBE patient_data;

-- Readmission Distribution
SELECT readmitted, COUNT(*) FROM patient_data GROUP BY readmitted;

-- Unique Patients
SELECT COUNT(DISTINCT patient_nbr) FROM patient_data;

-- Section 2 - Missing Values Detection
SELECT 
SUM(CASE WHEN race = '?' THEN 1 ELSE 0 END) AS missing_race,
SUM(CASE WHEN weight = '?' THEN 1 ELSE 0 END) AS missing_weight,
SUM(CASE WHEN payer_code = '?' THEN 1 ELSE 0 END) AS missing_payer,
SUM(CASE WHEN medical_specialty = '?' THEN 1 ELSE 0 END) AS missing_specialty
FROM patient_data;


-- SECTION 3 — Hospital Stay Overview
SELECT time_in_hospital, COUNT(*) 
FROM patient_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;


-- SECTION 4 — Age Distribution
SELECT age, COUNT(*) 
FROM patient_data
GROUP BY age
ORDER BY age;

-- Readmission Rate by Age Group
SELECT 
age,
COUNT(*) AS total_patients,
SUM(CASE WHEN TRIM(readmitted) = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
ROUND(
SUM(CASE WHEN TRIM(readmitted) = '<30' THEN 1 ELSE 0 END) / COUNT(*) * 100,
2
) AS readmission_rate
FROM patient_data
GROUP BY age
ORDER BY age;
-- Analysis of 101,766 hospital encounters revealed that the 20–30 age group 
-- had the highest 30-day readmission rate (14.24%), while pediatric patients 
-- had the lowest (1.86%), indicating potential treatment adherence 
-- and lifestyle risk factors among young adults.


-- Readmission vs Length of Hospital Stay
SELECT 
time_in_hospital,
COUNT(*) AS total_patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
ROUND(
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) * 100,
2
) AS readmission_rate
FROM patient_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;

-- Analysis revealed a strong relationship between hospital stay duration 
-- and readmission risk, with patients hospitalized for 10 days 
-- showing a 14.35% readmission rate compared to 8.18% for 1-day stays, 
-- representing a 75% increase in readmission probability.

-- Length of Stay Risk with Baseline Comparison

WITH los_analysis AS (
SELECT 
time_in_hospital,
COUNT(*) AS patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) AS rate
FROM patient_data
GROUP BY time_in_hospital
)

SELECT 
time_in_hospital,
patients,
readmitted_30,
ROUND(rate * 100, 2) AS readmission_rate_pct,

-- Absolute difference vs baseline (1 day stay)
ROUND(
(rate - (SELECT rate FROM los_analysis WHERE time_in_hospital = 1)) * 100,
2
) AS absolute_diff_pct,
-- Relative increase %
ROUND(
((rate - (SELECT rate FROM los_analysis WHERE time_in_hospital = 1)) 
 / (SELECT rate FROM los_analysis WHERE time_in_hospital = 1)) * 100,
2
) AS relative_increase_pct

FROM los_analysis
ORDER BY time_in_hospital;

-- Patients with extended hospital stays (10 days) show a +6.17 percentage 
-- point increase in readmission risk, representing a ~75% relative increase 
-- compared to short stays (1 day baseline).


-- Clinical Workload Impact
SELECT 
CASE 
WHEN num_medications < 10 THEN 'Low'
WHEN num_medications BETWEEN 10 AND 20 THEN 'Medium'
ELSE 'High'
END AS medication_band,
COUNT(*) AS patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
ROUND(
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) * 100,
2
) AS readmission_rate
FROM patient_data
GROUP BY medication_band;

-- Patients receiving more than 20 medications exhibited a 12.78% 30-day 
-- readmission rate compared to 8.83% for patients receiving fewer than 10 
-- medications,indicating a 45% higher readmission risk associated with 
-- polypharmacy.


-- Medication Risk with Baseline Comparison

WITH med_analysis AS (
SELECT 
CASE 
WHEN num_medications < 10 THEN 'Low'
WHEN num_medications BETWEEN 10 AND 20 THEN 'Medium'
ELSE 'High'
END AS medication_band,
COUNT(*) AS patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) AS rate
FROM patient_data
GROUP BY medication_band
)

SELECT 
medication_band,
patients,
readmitted_30,
ROUND(rate * 100, 2) AS readmission_rate_pct,

-- Absolute difference vs baseline (Low)
ROUND(
(rate - (SELECT rate FROM med_analysis WHERE medication_band = 'Low')) * 100,
2
) AS absolute_diff_pct,

-- Relative increase %
ROUND(
((rate - (SELECT rate FROM med_analysis WHERE medication_band = 'Low')) 
 / (SELECT rate FROM med_analysis WHERE medication_band = 'Low')) * 100,
2
) AS relative_increase_pct

FROM med_analysis;

-- Patients in the high medication group show a +3.95 percentage 
-- point increase in readmission risk, representing a ~44.7% relative 
-- increase compared to baseline (low medication group).



-- Clinical Severity using Diagnoses Count
SELECT 
number_diagnoses,
COUNT(*) AS patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
ROUND(
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) * 100,
2
) AS readmission_rate
FROM patient_data
GROUP BY number_diagnoses
ORDER BY number_diagnoses;


-- Analysis of 101,766 hospital encounters revealed that patients with 
-- 9 diagnosed conditions experienced a 12.38% 30-day readmission rate 
-- compared to 5.94% for patients with a single diagnosis, representing 
-- a 108% increase in readmission risk due to disease complexity.

-- Diagnosis Complexity Risk with Baseline Comparison

WITH diag_group AS (
SELECT 
CASE 
WHEN number_diagnoses <= 3 THEN 'Low'
WHEN number_diagnoses BETWEEN 4 AND 7 THEN 'Medium'
ELSE 'High'
END AS diagnosis_group,
COUNT(*) AS patients,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) AS rate
FROM patient_data
GROUP BY diagnosis_group
)

SELECT 
diagnosis_group,
patients,
readmitted_30,
ROUND(rate * 100, 2) AS readmission_rate_pct,

-- Absolute difference vs baseline (Low)
ROUND(
(rate - (SELECT rate FROM diag_group WHERE diagnosis_group = 'Low')) * 100,
2
) AS absolute_diff_pct,

-- Relative increase %
ROUND(
((rate - (SELECT rate FROM diag_group WHERE diagnosis_group = 'Low')) 
 / (SELECT rate FROM diag_group WHERE diagnosis_group = 'Low')) * 100,
2
) AS relative_increase_pct

FROM diag_group;

-- Diagnosis complexity is the strongest driver of readmission 
-- risk (~76% increase), closely followed by length of stay (~75%),
-- while medication load has a comparatively lower but still significant 
-- impact (~45%).



-- FINAL: Driver Ranking Summary

WITH med_analysis AS (
SELECT 
((SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*)) -
 (SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) 
  FROM patient_data WHERE num_medications < 10))
/
(SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) 
 FROM patient_data WHERE num_medications < 10) * 100 AS risk_increase
FROM patient_data
WHERE num_medications > 20
),

los_analysis AS (
SELECT 
((SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*)) -
 (SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) 
  FROM patient_data WHERE time_in_hospital = 1))
/
(SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) 
 FROM patient_data WHERE time_in_hospital = 1) * 100 AS risk_increase
FROM patient_data
WHERE time_in_hospital = 10
),

diag_analysis AS (
SELECT 
((SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*)) -
 (SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) 
  FROM patient_data WHERE number_diagnoses <= 3))
/
(SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*) 
 FROM patient_data WHERE number_diagnoses <= 3) * 100 AS risk_increase
FROM patient_data
WHERE number_diagnoses >= 8
)

SELECT 'Diagnosis Complexity' AS factor, ROUND(risk_increase, 2) AS relative_increase_pct FROM diag_analysis
UNION ALL
SELECT 'Length of Stay', ROUND(risk_increase, 2) FROM los_analysis
UNION ALL
SELECT 'Medication Load', ROUND(risk_increase, 2) FROM med_analysis;

-- Diagnosis complexity (~76%) and length of stay (~75%) are 
-- the dominant drivers of 30-day readmission risk, while 
-- medication load (~45%) has a secondary but still meaningful impact.


SET GLOBAL secure_file_priv='';
-- FINAL EXPORT: Enriched Dataset for Analysis & Dashboard

SELECT 
    age,
    time_in_hospital,
    
    -- LOS grouping (optional but useful for Tableau)
    CASE 
        WHEN time_in_hospital <= 3 THEN 'Short Stay'
        WHEN time_in_hospital BETWEEN 4 AND 7 THEN 'Medium Stay'
        ELSE 'Long Stay'
    END AS los_group,

    num_medications,
    
    -- Medication Band
    CASE 
        WHEN num_medications < 10 THEN 'Low'
        WHEN num_medications BETWEEN 10 AND 20 THEN 'Medium'
        ELSE 'High'
    END AS medication_band,

    number_diagnoses,
    
    -- Diagnosis Group
    CASE 
        WHEN number_diagnoses <= 3 THEN 'Low'
        WHEN number_diagnoses BETWEEN 4 AND 7 THEN 'Medium'
        ELSE 'High'
    END AS diagnosis_group,

    -- Clean Readmission Flag
    CASE 
        WHEN TRIM(readmitted) = '<30' THEN 1
        ELSE 0
    END AS readmission_flag,

    readmitted

FROM healthcare_project.patient_data

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/patient_data_enriched.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';
