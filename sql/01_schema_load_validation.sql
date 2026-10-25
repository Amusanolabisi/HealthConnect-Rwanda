-- HealthConnect Rwanda | Week 6 | Data Analytics Track
DROP SCHEMA IF EXISTS hc CASCADE;
CREATE SCHEMA hc;
SET search_path = hc;

-- ---------- Geography ----------
CREATE TABLE countries  (country_id text PRIMARY KEY, country_name text, iso2 text, iso3 text, currency text, region text);
CREATE TABLE provinces  (province_id text PRIMARY KEY, province_name text, country_id text REFERENCES countries);
CREATE TABLE districts  (district_id text PRIMARY KEY, district_name text, province_id text REFERENCES provinces);
CREATE TABLE sectors    (sector_id text PRIMARY KEY, sector_name text, district_id text REFERENCES districts);
CREATE TABLE villages   (village_id text PRIMARY KEY, village_name text, sector_id text REFERENCES sectors);
CREATE TABLE ownership_types (ownership_id text PRIMARY KEY, ownership text);

-- ---------- Facility structure ----------
CREATE TABLE departments (department_id text PRIMARY KEY, department_name text, facility_id text);
-- No Health Facilities master file was supplied, so derive facility IDs from departments
CREATE TABLE facilities  (facility_id text PRIMARY KEY);
CREATE TABLE specialties (specialty_id text PRIMARY KEY, specialty text, department_id text REFERENCES departments);
CREATE TABLE services    (service_id text PRIMARY KEY, service_name text, department_id text REFERENCES departments);
CREATE TABLE equipment   (equipment_id text PRIMARY KEY, equipment_name text, department_id text REFERENCES departments, facility_id text);
CREATE TABLE rooms       (room_id text PRIMARY KEY, department_id text REFERENCES departments, facility_id text, room_name text);
CREATE TABLE beds        (bed_id text PRIMARY KEY, room_id text REFERENCES rooms, status text);

-- ---------- Staff (6 files -> 1 table; Role distinguishes) ----------
CREATE TABLE staff (
  staff_id text PRIMARY KEY, first_name text, last_name text, role text, department text,
  specialty text, facility_id text, department_id text, years_experience int, status text);

-- ---------- Patients ----------
CREATE TABLE patients (
  patient_id text PRIMARY KEY, first_name text, last_name text, gender text, dob_raw text, age int,
  marital_status text, occupation text, education text, village_id text REFERENCES villages,
  insurance_id text, blood_group text, height_cm numeric, weight_kg numeric,
  chronic_condition text, phone_raw text, emergency_contact text, status text, bmi numeric,
  dob date);

-- ---------- Transactions ----------
CREATE TABLE appointments (
  appointment_id text PRIMARY KEY, patient_id text REFERENCES patients, doctor_id text REFERENCES staff,
  facility_id text, department_id text REFERENCES departments, appt_date date, visit_type text);
CREATE TABLE billing    (billing_id text PRIMARY KEY, appointment_id text, amount numeric, status text);
CREATE TABLE payments   (payment_id text PRIMARY KEY, billing_id text REFERENCES billing, amount_paid numeric, method text);
CREATE TABLE claims     (claim_id text PRIMARY KEY, billing_id text REFERENCES billing, provider text, claim_amount numeric, status text);
CREATE TABLE diagnoses  (diagnosis_id text PRIMARY KEY, appointment_id text, diagnosis text, severity text);
CREATE TABLE feedback   (feedback_id text PRIMARY KEY, appointment_id text, rating int, comment text);
CREATE TABLE revenue_summary (month text PRIMARY KEY, revenue numeric, appointments int);

INSERT INTO hc.facilities SELECT DISTINCT facility_id FROM hc.departments;

-- ---------- Cleaning ----------
UPDATE patients SET dob = to_date(dob_raw, 'MM/DD/YYYY');
-- 'None' is a real category (no chronic condition), not a NULL; keep it as text
UPDATE patients SET chronic_condition = COALESCE(NULLIF(TRIM(chronic_condition), ''), 'None');

-- Analysis views
CREATE VIEW v_appt AS
SELECT a.*, d.facility_id AS dept_facility_id, d.department_name,
       (a.facility_id <> d.facility_id) AS facility_mismatch
FROM appointments a JOIN departments d USING (department_id);

-- Billing that can be tied to an appointment (about 5,000 of 60,000)
CREATE VIEW v_billing_linked AS
SELECT b.billing_id, b.amount AS billed, b.status AS bill_status,
       p.amount_paid, p.method, a.appointment_id, a.patient_id,
       a.dept_facility_id AS facility_id, a.department_id, a.department_name, a.appt_date
FROM billing b
JOIN payments p USING (billing_id)
JOIN v_appt a USING (appointment_id);

CREATE VIEW v_patient_geo AS
SELECT p.*, v.village_name, s.sector_name, d.district_id, d.district_name, pr.province_id, pr.province_name
FROM patients p JOIN villages v USING (village_id) JOIN sectors s USING (sector_id)
JOIN districts d USING (district_id) JOIN provinces pr USING (province_id);

-- ---------- Validation / data quality report ----------
SELECT 'Duplicate patient IDs' AS check, COUNT(*) - COUNT(DISTINCT patient_id) AS issues FROM patients
UNION ALL SELECT 'Duplicate appointment IDs', COUNT(*) - COUNT(DISTINCT appointment_id) FROM appointments
UNION ALL SELECT 'Impossible ages (<0 or >110)', COUNT(*) FROM patients WHERE age < 0 OR age > 110
UNION ALL SELECT 'Age disagrees with DOB (>1 yr)', COUNT(*) FROM patients WHERE ABS(age - DATE_PART('year', AGE(DATE '2026-12-31', dob))) > 1
UNION ALL SELECT 'Invalid billing amounts (<=0)', COUNT(*) FROM billing WHERE amount <= 0
UNION ALL SELECT 'Billing with no appointment', COUNT(*) FROM billing b WHERE NOT EXISTS (SELECT 1 FROM appointments a WHERE a.appointment_id = b.appointment_id)
UNION ALL SELECT 'Diagnoses with no appointment', COUNT(*) FROM diagnoses d WHERE NOT EXISTS (SELECT 1 FROM appointments a WHERE a.appointment_id = d.appointment_id)
UNION ALL SELECT 'Feedback with no appointment', COUNT(*) FROM feedback f WHERE NOT EXISTS (SELECT 1 FROM appointments a WHERE a.appointment_id = f.appointment_id)
UNION ALL SELECT 'Appointment facility <> department facility', COUNT(*) FROM v_appt WHERE facility_mismatch
UNION ALL SELECT 'Invalid facility IDs in appointments', COUNT(*) FROM appointments WHERE facility_id NOT IN (SELECT facility_id FROM facilities)
UNION ALL SELECT 'Overpaid bills', COUNT(*) FROM billing b JOIN payments p USING (billing_id) WHERE p.amount_paid > b.amount
UNION ALL SELECT 'Doctor IDs not in staff', COUNT(*) FROM appointments WHERE doctor_id NOT IN (SELECT staff_id FROM staff)
UNION ALL SELECT 'Phones in scientific notation', COUNT(*) FROM patients WHERE phone_raw ILIKE '%E+%';

-- Reconciliation: Billing vs Revenue Summary
SELECT (SELECT SUM(amount) FROM billing)        AS billing_total,
       (SELECT SUM(amount_paid) FROM payments)  AS payments_total,
       (SELECT SUM(revenue) FROM revenue_summary) AS summary_total;