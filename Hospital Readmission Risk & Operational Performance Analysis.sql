create schema healthcare_project;
use healthcare_project;

-- Section 1 - Dataset Overview
describe patient_data;
truncate patient_data;


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

SET GLOBAL secure_file_priv='';
-- Exporting Data for Excel
SELECT 
    age,
    time_in_hospital,
    num_medications,
    number_diagnoses,
    readmitted
FROM healthcare_project.patient_data
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/patient_data.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';