# HealthConnect Rwanda: Healthcare Operations and Performance Analytics

**AnalystLab Africa Experience Lab | Data Analytics Track | Weeks 6 to 8**
**Author:** Olabisi Amusan | [LinkedIn](https://linkedin.com/in/amusanolabisi) | [GitHub](https://github.com/amusanolabisi)

---

## Overview

An end-to-end analytics solution for HealthConnect Rwanda, built to help executive management monitor patient care, hospital operations, financial performance and patient experience.

The project covers:
- a PostgreSQL database built from the supplied CSV datasets,
- 40 SQL tasks answering the assignment's business questions,
- an interactive Power BI dashboard (six report pages, a drill-through page and a tooltip page),
- a Week 7 testing and refinement cycle with a documented test record,
- a Week 8 final analytics and decision-support package with a cross-track validation (Data Science).

The project question: *how can HealthConnect use data and AI to reduce missed appointments and improve patient support?* The dataset has no attendance field, so missed appointments could not be measured directly. The analysis focuses on what the data does support and documents what it does not.

---

## Dashboard Preview

### 1. Executive Dashboard
![Executive Dashboard](images/images1.png)

### 2. Patient Analytics
![Patient Analytics](images/images2.png)

### 3. Clinical Analytics
![Clinical Analytics](images/images3.png)

### 4. Financial Analysis
![Financial Analysis](images/images4.png)

### 5. Operational Analytics
![Operational Analytics](images/images5.png)

### 6. Patient Experience
![Patient Experience](images/images6.png)

---

## Repository Contents

```
HealthConnect-Rwanda/
├── sql/
│   ├── 01_schema_load_validation.sql        # schema, cleaning, views, data-quality checks
│   └── 02_business_queries.sql              # the 40 SQL tasks
├── database/
│   └── healthconnect.backup                 # PostgreSQL backup (custom format)
├── powerbi/
│   ├── Healthconnect_Rwanda.pbix            # Week 6 version
│   └── Healthconnect_Rwanda_Week_7.pbix     # Week 7 refined (final) version
├── testing/
│   └── HealthConnect_Test.xlsx              # test record, issue log, cross-track sheet
├── reports/
│   ├── Business_Insights_Report.docx        # Week 6 report
│   ├── Week7_Testing_and_Refinement_Report_Final.docx
│   ├── Week8_Final_Analytics_Decision_Support_Package.pdf
│   └── HealthConnect_Final_Presentation.pdf # 14-slide final presentation
├── images/                                  # dashboard screenshots used above
├── evidence/                                # screenshots of tests and cross-track exchange
└── README.md
```

---

## Tools

- PostgreSQL 18 and pgAdmin 4 (database and SQL)
- Power BI Desktop (data model, DAX, visuals)
- Excel (test record), Python (independent calculation of expected values and statistical tests)

---

## Timeline

| Week | Focus | Main output |
|---|---|---|
| 6 | Build | Database, 40 SQL tasks, six-page Power BI dashboard, insights report |
| 7 | Test and refine | 18 dashboard tests, statistical validation, 7 issues logged, Data Science cross-track checks |
| 8 | Final integration | Final analytics and decision-support package, presentation, video |

---

## Method

1. **Database build.** Loaded the supplied CSV files into a PostgreSQL schema (`hc`) with primary and foreign keys. The six staff files were combined into one `staff` table. The Departments file was supplied twice with identical content, so one copy was used.
2. **Cleaning.** Converted dates of birth to a date type, kept "None" as a valid chronic-condition category rather than a missing value, and removed unusable or personal columns (phone numbers, emergency contacts) in Power BI.
3. **Validation.** Checked primary keys, duplicates, impossible ages (ages agree with dates of birth: 0 mismatches in 20,000), billing amounts, overpayments and cross-table links.
4. **Analysis.** Wrote 40 SQL tasks across patient, appointment, clinical and financial analysis, using views to join appointments to departments, facilities and billing.
5. **Dashboard.** Built a Power BI model with a date table and single-direction relationships, DAX measures and the report pages.
6. **Testing (Week 7).** Compared dashboard values with figures calculated independently from the source files, reconciled chart totals with KPI cards, ran statistical tests, and fixed what the tests found.

### Data model notes
- The facility used in analysis is the **department's facility**, not the FacilityID on the appointment record (see Data Quality).
- Revenue is **Payments** (money collected). Billing gives the billed amount; outstanding = billed minus collected.
- Filters flow from the date table, patients, departments and facilities down to appointments, billing, payments, claims, diagnoses and feedback.

---

## Data Quality Findings

**Checks that passed**
- No duplicate patient or appointment IDs, no impossible ages, no invalid billing amounts and no overpaid bills
- No invalid facility IDs; every appointment's doctor exists in the staff table

**Issues found**
- **Appointments are incomplete.** There are only 5,000 appointments, but billing, diagnoses and payments each have 60,000 rows. 55,000 billing records, 55,000 diagnosis records and 19,308 feedback records have no matching appointment. Facility, department and monthly analysis therefore covers appointment-linked records only (RWF 694.55M of the RWF 8.39bn collected, about 8%). Week 7 tests showed the linked records are a fair sample of the unlinked ones.
- **Facility fields disagree.** For 4,744 of 5,000 appointments, the facility on the appointment differs from the facility of its department. The department's facility is used. Staff records conflict in the same way: 1,187 of 1,250 staff have a FacilityID that differs from their DepartmentID's facility.
- **Revenue Summary does not reconcile.** It totals RWF 1.13bn, which matches neither billing (RWF 9.31bn) nor payments (RWF 8.39bn). It is not used for any KPI.
- **Bill status does not match payments.** About 90% of each bill was paid whatever its status, so outstanding is calculated as billed minus collected.
- **Phone numbers corrupted.** All were saved in scientific notation in the source and cannot be recovered.
- **Little variation in some fields.** All 2,000 beds are "Available", all patients and staff are "Active", and every patient has an insurance ID, so occupancy and insured versus uninsured comparisons are not possible.
- **Near-even distributions.** Visit types, severity levels, payment methods, insurance providers, provinces and monthly demand are all close to evenly split, which suggests the data is synthetic.

---

## Data Limitations (not supplied)

Health Facilities master data, Admissions, Laboratory Tests, Prescriptions, Referrals and an Insurance master table were not in the dataset. As a result the following could not be calculated: admission rate, length of stay, readmission, laboratory and prescription volumes, referral rate, bed occupancy, equipment availability, and revenue by province, facility type or service. Only five diagnoses exist, so a top 5 replaces the requested top 20. There is also **no attendance or no-show field**, so missed-appointment analysis is not possible on this dataset.

---

## Final KPIs (validated against the source data)

| KPI | Value |
|---|---|
| Registered patients / with a visit | 20,000 / 4,443 |
| Appointments | 5,000 (1.13 per visiting patient) |
| Facilities / doctors | 20 / 350 |
| Billed / collected | RWF 9.31bn / RWF 8.39bn (90.12%) |
| Outstanding bills | RWF 919.95M |
| Average bill | RWF 155,157 |
| Insurance claims / pending | 42,036 / 21,028 (50%) |
| Average age / chronic rate | 45 / 74.65% |
| Severe case rate | 33.31% |
| Average satisfaction | 2.99 out of 5 (40.44% rated 1 or 2, 19.70% rated 5) |

---

## Key Findings

- **Demand** is steady at 400 to 440 appointments a month, with no detectable seasonality; the forecast is flat.
- **Patients:** people aged 65 and over are the largest group (28.5%), and 74.65% have a recorded chronic condition. Gender and province are evenly balanced.
- **Finance:** 90.12% of billed revenue was collected, RWF 919.95M is outstanding, and half of the 42,036 insurance claims are still pending. 17,964 bills have no claim.
- **Clinical:** five diagnoses at about a fifth of cases each; severity splits into thirds. Severity has no strong driver (independent of diagnosis, department and visit type).
- **Operations:** beds (100 per facility) and rooms (20 per facility) are uniform. Doctor counts depend on which facility field is used (20 or 10 by department, 18 or 17 by FacilityID), so no staffing imbalance is claimed.
- **Patient experience:** satisfaction is middling across the network, and differences between facilities and departments are not statistically significant.
- **Data reliability** is the main constraint: about 92% of collected revenue cannot be linked to an appointment.

---

## Power BI Features Demonstrated

| Feature | Where |
|---|---|
| KPI cards | All pages |
| Slicers | Month, Facility, Visit type |
| Drill-through | Facility Detail page |
| Bookmarks | Financial page (trend and decomposition views) |
| Tooltips | Custom tooltip page on the revenue trend |
| Hierarchies | Facility > Department (Financial page) |
| Conditional formatting | Facility bars, matrix colour scale, table data bars |
| Maps | Patient province map |
| Matrix | Workload by visit type and department (Clinical) |
| DAX measures | Revenue, collection rate, growth, ratios, ranking, doctors by FacilityID |
| Time intelligence | Month-over-month growth, year-to-date revenue |
| Dynamic titles | Facility chart and Operations page |
| Decomposition tree | Financial page |
| Key Influencers | Clinical page |
| Forecasting | Executive page (monthly appointments) |

---

## Week 7: Testing and Refinement

Week 7 tests the Week 6 dashboard instead of rebuilding it. The Week 6 file is preserved as `Healthconnect_Rwanda.pbix`; the refined version is `Healthconnect_Rwanda_Week_7.pbix`.

**18 tests** compared dashboard values with figures calculated independently from the source files (month, visit-type and facility filters, combined filters, reset behaviour, financial and patient values, and chart reconciliations). **15 passed first time. 3 failed first time and passed after fixes (T13, T16, T17).** The full record is in `testing/HealthConnect_Test.xlsx`.

| ID | Issue | Fix |
|---|---|---|
| I1 | Payment-method donut, claims chart and comments chart disagreed with their KPI cards because a visual-level filter excluded a blank department name, dropping unlinked records | Removed the exclusion where no facility or department split is needed |
| I2 | A test measure included a (Blank) facility member holding the unlinked revenue (8.39bn instead of 694.55M) | Excluded the blank member; cross-checked with the decomposition tree |
| I3 | Doctor counts depend on the join path (staff FacilityID and DepartmentID conflict) | Added a Doctors by FacilityID measure; both counts shown and total 350 |
| I4 | Satisfaction rankings implied real differences | Added ANOVA caveats (facility p = 0.55, department p = 0.88) |
| I5 | Facility slicer does not change patient-level cards | Added an explanatory note |
| I6 | Comments chart subtitle was out of date | Updated to 21,064 responses |
| I7 | Follow-up visits do not reflect visit history (88.0% have no earlier visit) | Documented as a data limitation |

**Statistical validation:** the 5,000 appointment-linked records are a fair sample of the 60,000 bills and diagnoses (no significant differences in amounts, payment methods, status, diagnosis or severity mix); satisfaction and volumes do not differ significantly between facilities or departments; severity is independent of diagnosis (p = 0.19), department (p = 0.20) and visit type (p = 0.91); repeat visits are rare (4,443 patients made 5,000 appointments).

---

## Week 8: Final Analytics and Decision Support

The final package (`reports/Week8_Final_Analytics_Decision_Support_Package.pdf`) brings the dashboard and testing together: executive summary, final KPIs with definitions, validated findings, business insights and the decisions they support, prioritised recommendations, limitations and the cross-track record. A 14-slide presentation and an individual video accompany it.

**Video presentation:** [add link]

### Cross-track validation (Data Science)
I shared validated findings with a Data Science intern and tested her target, features and assumptions against the source tables. Her final model (ridge logistic regression, 5 features) reached a hold-out AUC of 0.467 against a 0.500 baseline and fails her own release gate, so no model is recommended for decisions. My findings did not change her model. They confirmed decisions she had already made and changed her documentation in three places: my fair-sample test means her limitation is sample size, not bias; my staff-record conflict is cited as a reason facility-based features are unreliable; and my KPIs and passing tests match her analysis. She recomputed my findings independently and they agreed.

---

## Recommendations

1. **Link every bill, payment, diagnosis and feedback record to an appointment.** About 92% of revenue is unlinked.
2. **Record attendance status** (attended, missed, cancelled) and define Follow-up visits against an earlier visit.
3. **Clear the 21,028 pending claims** and the 17,964 bills with no claim.
4. **Standardise bill status** so it reflects the amounts paid.
5. **Correct staff facility and department records,** then re-run the staffing analysis.
6. **Follow up low ratings** (40.44% rated 1 or 2) and **plan services for older and chronic-care patients.**

---

## Limitations

No attendance field; about 92% of revenue unlinked to appointments; staff facility records conflict; admissions, laboratory, prescription, referral, facility master and insurance master tables not supplied; the data looks synthetic, so differences between groups are small; validation used the same source files, so errors in the source itself would not be detected; one cross-track exchange (Data Science only).

---

## How to Run

**Option A: restore the backup**
1. Create a database named `healthconnect` in pgAdmin.
2. Right-click the database, choose Restore, and select `healthconnect.backup`.

**Option B: rebuild from the scripts**
1. Create a database named `healthconnect`.
2. Run the schema section of `01_schema_load_validation.sql` (remove the `DROP SCHEMA` line if reloading).
3. Import the CSV files in dependency order (locations, departments, staff, patients, then transactions).
4. Run `UPDATE hc.patients SET dob = to_date(dob_raw, 'MM/DD/YYYY');` after the patients import.
5. Run the views and validation block, then `02_business_queries.sql`.

**Dashboard:** open `Healthconnect_Rwanda_Week_7.pbix` and refresh against server `localhost`, database `healthconnect`.

---

## Author

**Olabisi Amusan**
Data Analyst (Power BI, DAX, SQL, Python, Excel) | Microsoft Certified: Power BI Data Analyst Associate (PL-300)
Ibadan, Nigeria
