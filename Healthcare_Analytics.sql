Create database Healthcare_Analytics;
use Healthcare_Analytics;

CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    City VARCHAR(50),
    Registration_Date DATE
);


CREATE TABLE Departments (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(100)
);


CREATE TABLE Doctors (
    Doctor_ID INT PRIMARY KEY,
    Doctor_Name VARCHAR(100),
    Department_ID INT,
    Experience_Years INT,
    FOREIGN KEY (Department_ID) REFERENCES Departments(Department_ID)
);


CREATE TABLE Visits (
    Visit_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_ID INT,
    Visit_Date DATE,
    Admission_Type VARCHAR(20),
    Treatment_Type VARCHAR(100),
    Billing_Amount DECIMAL(10,2),
    FOREIGN KEY (Patient_ID) REFERENCES Patients(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctors(Doctor_ID)
);

-- Data Checking 
select * from patients;
select * from doctors;
select * from departments;
select * from visits;

-- Checking data types
describe visits;
describe patients;
describe departments;
describe doctors;

-- Checking Null Values 
delete from patients where patient_name is null;

-- Checking Duplicates 
select patient_name, count(*) from patients group by patient_name having count(*) > 1;

-- There are patients with same name , lets check thier patient_id (uniquely defined)
select patient_id, count(*) from patients group by patient_id having count(*) > 1;

-- Data Manipulation - Adding new column
ALTER TABLE patients ADD age_group VARCHAR(20);

update patients set age_group = 
case
when age < 18 then "Child"
when age between 18 and 40 then "Adult"
when age between 40 and 60 then "Middle age"
else "Senior"
end;

-- Full Joins - important clause
-- "Joined 4 tables using foreign keys to create a complete healthcare dataset".

select p.patient_id, p.patient_name, p.age_group, p.gender, p.city, v.visit_date,
v.admission_type, v.treatment_type, v.billing_amount from patients p
join visits v  on p.patient_id = v.patient_id 
join doctors d on v.doctor_id = d.doctor_id
join departments dept on dept.department_id = d.department_id;

--  Aggregations 
-- extracting month 
select * , date_format(visit_date, "%y-%m") as visit_month from visits;

-- Monthly Revenue Trend
select date_format(visit_date, '%Y-%m') as month, sum(billing_amount) as total_revenue
from visits group by month order by month;

-- Gender-wise Analysis
select gender , count(*) as total_patients from patients 
group by gender order by total_patients desc;

-- Patient Count by Age Group
select age_group , count(*) as total_patients from patients group by age_group
order by total_patients desc;

-- Average Revenue per Visit
select avg(billing_amount) as avg_revenue_per_visit
from visits;

-- Highest Billing Visit
select * from visits
order by billing_amount desc limit 1;

-- Repeat vs New Patients 
select patient_id , count(*) as visit_count from visits group by patient_id 
having visit_count >1 order by visit_count asc;

-- Top 5 Cities by Patients
select city, count(*) as total_patients from patients 
group by city order by total_patients desc limit 5;

-- Revenue by Admission Type
select admission_type, sum(billing_amount) as total_revenue
from visits group by admission_type order by total_revenue desc;

-- Doctor Performance by Visits and Revenue
select d.doctor_name, count(v.visit_id) as total_visits,
sum(v.billing_amount) as total_revenue from visits v
join doctors d on v.doctor_id = d.doctor_id
group by d.doctor_name order by total_revenue desc;

-- Revenue by Department 
select dept.department_name, SUM(v.billing_amount) AS revenue from visits v
join doctors d on v.doctor_id = d.doctor_id
join departments dept on d.department_id = dept.department_id
group by dept.department_name order by  revenue desc;

--  Top Doctors by Revenue
select d.doctor_name, SUM(v.billing_amount) as revenue
from visits v join doctors d on v.doctor_id = d.doctor_id
group by  d.doctor_name order by  revenue desc;

--  Patients per Department
select dept.department_name, count(distinct v.patient_id) as patients from visits v
join doctors d on v.doctor_id = d.doctor_id
join departments dept on d.department_id = dept.department_id
group by dept.department_name order by patients desc ;

-- Visits per Department
select dept.department_name, count(v.visit_id) as total_visits from visits v
join doctors d on v.doctor_id = d.doctor_id
join departments dept on d.department_id = dept.department_id
group by  dept.department_name order by total_visits desc;

-- Window Functions 
-- Top 3 Departments
select * from 
( select dept.department_name, SUM(v.billing_amount) as revenue,
rank() over (order by  SUM(v.billing_amount) desc) as rnk from visits v
join doctors d on v.doctor_id = d.doctor_id
join departments dept on d.department_id = dept.department_id
group by  dept.department_name) t
where rnk  <= 3 ;

-- Key Insights
-- - Most patients are Adults and Middle-aged.
-- - Few departments generate most of the revenue( ENT , Oncology ,etc).
-- - Some cities have higher patient count( kolkata , Nagapur,etc).
-- - Patients are repeat visitors(no new patients). 

-- Final Conclusion 
-- - “I cleaned the data(null values , duplicates), created new columns, joined multiple tables." 
-- - "Generated healthcare insights using aggregations and window functions.”
