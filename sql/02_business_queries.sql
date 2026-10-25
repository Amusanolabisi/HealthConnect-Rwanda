SET search_path = hc;

-- ===== PATIENT ANALYSIS =====
-- 1
SELECT * FROM patients;
-- 2
SELECT gender, COUNT(*) AS patients FROM patients GROUP BY gender;
-- 3
SELECT province_name, COUNT(*) AS patients FROM v_patient_geo GROUP BY province_name ORDER BY patients DESC;
-- 4
SELECT patient_id, first_name, last_name, age FROM patients WHERE age > 65 ORDER BY age DESC;
-- 5
SELECT patient_id, first_name, last_name, chronic_condition FROM patients WHERE chronic_condition <> 'None';
-- 6 (every patient carries an InsuranceID; confirm with the data owner whether any code means "uninsured")
SELECT patient_id, first_name, last_name, insurance_id FROM patients WHERE insurance_id IS NOT NULL;
-- 7
SELECT blood_group, COUNT(*) AS patients FROM patients GROUP BY blood_group ORDER BY patients DESC;
-- 8
(SELECT 'Youngest' AS which, patient_id, first_name, last_name, age FROM patients ORDER BY age ASC, dob DESC LIMIT 1)
UNION ALL
(SELECT 'Oldest', patient_id, first_name, last_name, age FROM patients ORDER BY age DESC, dob ASC LIMIT 1);
-- 9 (phones were truncated by scientific notation in the source, so these are not true duplicates)
SELECT phone_raw, COUNT(*) AS n FROM patients GROUP BY phone_raw HAVING COUNT(*) > 1 ORDER BY n DESC;
-- 10
SELECT ROUND(AVG(age), 1) AS avg_age FROM patients;

-- ===== APPOINTMENT ANALYSIS =====
-- 11
SELECT TO_CHAR(appt_date, 'YYYY-MM') AS month, COUNT(*) AS appointments FROM appointments GROUP BY 1 ORDER BY 1;
-- 12 / 19 (facility = department's facility)
SELECT dept_facility_id AS facility_id, COUNT(*) AS appointments, COUNT(DISTINCT patient_id) AS unique_patients
FROM v_appt GROUP BY 1 ORDER BY appointments DESC;
-- 13
SELECT department_name, COUNT(*) AS appointments FROM v_appt GROUP BY 1 ORDER BY appointments DESC;
-- 14
SELECT s.staff_id, s.first_name, s.last_name, s.specialty, COUNT(*) AS appointments
FROM appointments a JOIN staff s ON s.staff_id = a.doctor_id
GROUP BY 1,2,3,4 ORDER BY appointments DESC LIMIT 20;
-- 15 Referral patterns: no Referrals table supplied; cannot be answered
-- 16
SELECT COUNT(*) AS emergency_appointments FROM appointments WHERE visit_type = 'Emergency';
-- 17
SELECT ROUND((SELECT COUNT(*) FROM appointments)::numeric / 
(SELECT COUNT(*) FROM staff WHERE role = 'Doctor'), 2) AS avg_appts_per_doctor;
-- 18 (province of the patient's home village)
SELECT g.province_name, COUNT(*) AS appointments
FROM appointments a JOIN v_patient_geo g USING (patient_id) GROUP BY 1 ORDER BY appointments DESC;
-- 20 (no time-of-day in the data, so peak periods are by month and weekday)
SELECT TO_CHAR(appt_date,'Day') AS weekday, COUNT(*) AS consultations
FROM appointments WHERE visit_type = 'Consultation' GROUP BY 1, EXTRACT(ISODOW FROM appt_date) 
ORDER BY EXTRACT(ISODOW FROM appt_date);
SELECT TO_CHAR(appt_date,'YYYY-MM') AS month, COUNT(*) AS consultations
FROM appointments WHERE visit_type = 'Consultation' GROUP BY 1 ORDER BY consultations DESC;

-- ===== CLINICAL ANALYSIS =====
-- 21 (only 5 distinct diagnoses exist, so a Top 20 isn't possible)
SELECT diagnosis, COUNT(*) AS cases FROM diagnoses GROUP BY 1 ORDER BY cases DESC;
-- 22, 23, 24, 26, 27, 28, 29: need Lab Tests, Prescriptions, Admissions, Referrals tables, which were not supplied
-- 25
SELECT severity, COUNT(*) AS cases, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) 
AS pct FROM diagnoses GROUP BY 1 ORDER BY cases DESC;
-- 25b Severity by diagnosis (appointment-linked only)
SELECT diagnosis, severity, COUNT(*) FROM diagnoses GROUP BY 1,2 ORDER BY 1,3 DESC;
-- 30
SELECT department_name, visit_type, COUNT(*) AS appointments
FROM v_appt GROUP BY 1,2 ORDER BY 1, appointments DESC;

-- ===== FINANCIAL ANALYSIS (appointment-linked billing only) =====
-- 31
SELECT facility_id, SUM(billed) AS billed, SUM(amount_paid) AS collected FROM v_billing_linked 
GROUP BY 1 ORDER BY collected DESC;
-- 32
SELECT department_name, SUM(billed) AS billed, SUM(amount_paid) AS collected FROM v_billing_linked 
GROUP BY 1 ORDER BY collected DESC;
-- 33 Revenue by service: Services only link to departments, with no appointment-to-service key; cannot be answered directly
-- 34
SELECT provider, COUNT(*) AS claims, SUM(claim_amount) AS claim_value,
       ROUND(100.0*COUNT(*) FILTER (WHERE status='Approved')/COUNT(*),1) AS approval_rate_pct
FROM claims GROUP BY 1 ORDER BY claim_value DESC;
-- 35 (all billing, 60,000 rows)
SELECT b.status, COUNT(*) AS bills, SUM(b.amount - p.amount_paid) AS outstanding
FROM billing b JOIN payments p USING (billing_id) GROUP BY 1 ORDER BY outstanding DESC;
-- 36
SELECT ROUND(AVG(amount),2) AS avg_billing FROM billing;
-- 37 (from billing linked to appointments)
SELECT TO_CHAR(appt_date,'YYYY-MM') AS month, SUM(amount_paid) AS revenue FROM v_billing_linked 
GROUP BY 1 ORDER BY 1;
-- 38
SELECT method, COUNT(*) AS payments, SUM(amount_paid) AS total FROM payments GROUP BY 1 ORDER BY total DESC;
-- 39
SELECT facility_id, SUM(amount_paid) AS revenue FROM v_billing_linked GROUP BY 1 ORDER BY revenue DESC LIMIT 10;
-- 40
SELECT facility_id, SUM(amount_paid) AS revenue, ROUND(AVG(billed),0) AS avg_bill,
       ROUND(100.0*SUM(amount_paid)/SUM(billed),1) AS collection_rate_pct,
       RANK() OVER (ORDER BY SUM(amount_paid) DESC) AS revenue_rank
FROM v_billing_linked GROUP BY 1 ORDER BY revenue_rank;