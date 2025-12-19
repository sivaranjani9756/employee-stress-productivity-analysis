use employee_stress_db;
SHOW KEYS FROM sivaranjani_employees_stress_analysis_project WHERE Key_name = 'PRIMARY';

# 🔶 SECTION 1 — Workforce Overview

-- Total number of employees in the dataset.
select count(*) as total_employee
 from sivaranjani_employees_stress_analysis_project;

-- Count of employees by department.
select coalesce(jobrole,'total') as jobrole,count(*) as emp_count_in_dept
from sivaranjani_employees_stress_analysis_project
group by jobrole
with rollup;

-- How many employees fall in Low, Medium, High stress categories?
alter table sivaranjani_employees_stress_analysis_project
add column stress_category varchar(20);

update sivaranjani_employees_stress_analysis_project
set stress_category = 
case 
when stressscore between 0 and 33 then 'low'
when stressscore between 34 and 66 then 'medium'
when stressscore between 67 and 100 then 'high'
else 'unknown'
end
where employeeid >0;

select count(*) as stress_cat_count_emp ,stress_category
from sivaranjani_employees_stress_analysis_project
group by stress_category;

-- Average productivity across the organization.Overall performance score check.
select avg(productivityscore) as overall_avg_perf
from sivaranjani_employees_stress_analysis_project;

-- Gender-wise average stress level.Are male or female employees more stressed?
update  sivaranjani_employees_stress_analysis_project
set gender=
case 
when lower(trim(gender)) in ('m','male') then 'Male'
when lower(trim(gender)) in ('f','female') then 'Female'
else 'Other'
end 
where employeeid >0;

select round(avg(stressscore),2) as avg_stress_level,gender
from siavaranjani_employees_stress_analysis_project
group by gender;

# 🔶 SECTION 2 — Stress Analysis

-- Which department has the highest average stress?
select jobrole , round(avg(stressscore),2) as avg_stress
from sivaranjani_employees_stress_analysis_project
group by jobrole
order by avg_stress desc 
limit 1; 

-- Find the top 10 most stressed employees.
select employeeid , stressscore , jobrole , burnoutrisk,productivityscore
from sivaranjani_employees_stress_analysis_project
order by stressscore desc
limit 10;

-- How does overtime hours correlate with stress?.More overtime = more stress?
select 
case 
when overtimehours = 0 then '0'
when overtimehours between 1 and 5 then '1-5'
when overtimehours between 6 and 10 then '6-10'
when overtimehours between 11 and 15 then '11-15'
when overtimehours between 16 and 20 then '16-20'
when overtimehours between 21 and 25 then '21-25'
when overtimehours between 26 and 30 then '26-30'
else '31+'
end as overtime_bucket,
count(*) as n,
round(avg(stressscore),2) as avg_stress
from sivaranjani_employees_stress_analysis_project
group by overtime_bucket
order by field (overtime_bucket,'0','1-5','6-10','11-15','16-20','21-25','26-30') ;

-- Average stress level grouped by age group (20–29, 30–39, etc.).Younger employees usually show higher burnout.
select avg(stressscore) as youngers_avg_stress_level, age 
from sivaranjani_employees_stress_analysis_project
where age in ('20-29') and ('30-39')
group by age ;

# 🔶 SECTION 3 — Productivity Analysis
-- Average productivity by department.
select jobrole, round(avg(productivityscore),2)  avg_productivity
from sivaranjani_employees_stress_analysis_project
group by jobrole
order by avg_productivity desc;

-- Relationship between SleepHours and Productivity. Does low sleep reduce performance?
select 
case 
when sleephours = 0 then '0'
when sleephours between 1 and 4 then '1-4'
when sleephours between 5 and 6 then '5-6'
when sleephours between 7 and 8 then '7-8'
else '9+'
end as sleephours_bucket,
count(*) as n,
round(avg(productivityscore),2) as avg_productivity
from sivaranjani_employees_stress_analysis_project
group by sleephours_bucket
order by field(sleephours_bucket,'0','1-4','5-6','7-8','9+');

-- Compare productivity between WFH and Office employees.
select 
case 
when productivityscore between 0 and 20 then '0-20'
when productivityscore between 21 and 45  then '21-45'
when productivityscore between 46 and 66 then '46-66'
when productivityscore between 67 and 80 then '67-80'
when productivityscore between 81 and 95 then '81-95'
else '95+'
end as productivity_bucket,
count(*) as n_emp,
round(avg(wfh_percent),2) as avg_wfh_emp
from sivaranjani_employees_stress_analysis_project
group by productivity_bucket
order by field(productivity_bucket,'0-20','21-45','46-66','67-80','81-95','95+');

-- Find employees with high productivity but high stress.Silent burnout" category — extremely important HR metric.
select employeeid, productivityscore , burnoutrisk,
stressscore 
from sivaranjani_employees_stress_analysis_project
where burnoutrisk in ('high') and 
stressscore >=67 and 
productivityscore >=70
group by employeeid
order by productivityscore desc , productivityscore 
limit 10 ;

-- Identify employees with low stress but low productivity.
select employeeid , stressscore ,
productivityscore , burnoutrisk
from sivaranjani_employees_stress_analysis_project
where burnoutrisk in ('low')and 
stressscore <= 33 and 
productivityscore <= 40
group by employeeid
order by  productivityscore asc
limit 10 ;

# 🔶 SECTION 4 — Work Patterns & Stress Drivers
-- Does working more than 9 hours daily increase stress?
select 
case 
when workhoursperweek > 45 then 'more than 9 hrs/day'
else '9 hrs/day or less'
end as work_hrs_group,
count(*) as n_emp,
round(avg(stressscore),2) as avg_stress
from sivaranjani_employees_stress_analysis_project
group by work_hrs_group;

-- Find employees with extreme overtime (>15 hours/week).
select employeeid ,jobrole,workhoursperweek,overtimehours,productivityscore
from sivaranjani_employees_stress_analysis_project
where overtimehours >15
order by overtimehours;

-- Check if tenure (experience) impacts stress.Are new joiners more stressed?
select 
case when tenureyears between 0 and 2 then  '0-2 yrs'
when tenureyears between 3 and  5 then '3-5 yrs'
when tenureyears between 6  and  8 then '6-8 yrs'
when tenureyears between 9 and  10 then '9-10 yrs'
when tenureyears > 10 then '10+ yrs '
else 'unknown'
end as experience_yrs,
count(*) as emp_count,
round(avg(stressscore),2) as avg_stress
from sivaranjani_employees_stress_analysis_project
group by experience_yrs
order by field(experience_yrs,'0-2 yrs','3-5 yrs','6-8 yrs','9-10 yrs','10+ yrs','unknown');

-- Department-wise average SleepHours. 
select jobrole , round(avg(sleephours),2) as avg_sleephours,count(*) as emp_count
from sivaranjani_employees_stress_analysis_project
where sleephours is not null
group by jobrole
order by avg_sleephours asc;

-- Identify outliers in WorkHoursPerWeek. 
-- Total rows
SET @total := (SELECT COUNT(*) 
               FROM siavaranjani_employees_stress_analysis_project
               WHERE WorkHoursPerWeek IS NOT NULL);

-- Offsets for Q1 (25%) and Q3 (75%)
SET @q1_offset := FLOOR(@total * 0.25);
SET @q3_offset := FLOOR(@total * 0.75);

-- Q1 (25th percentile)
SET @q1 := (
    SELECT WorkHoursPerWeek
    FROM siavaranjani_employees_stress_analysis_project
    WHERE WorkHoursPerWeek IS NOT NULL
    ORDER BY WorkHoursPerWeek
    LIMIT @q1_offset, 1
);

-- Q3 (75th percentile)
SET @q3 := (
    SELECT WorkHoursPerWeek
    FROM siavaranjani_employees_stress_analysis_project
    WHERE WorkHoursPerWeek IS NOT NULL
    ORDER BY WorkHoursPerWeek
    LIMIT @q3_offset, 1
);

-- Compute IQR and bounds
SET @iqr := @q3 - @q1;
SET @lower_bound := @q1 - 1.5 * @iqr;
SET @upper_bound := @q3 + 1.5 * @iqr;

-- Show the values
SELECT @q1 AS Q1,
       @q3 AS Q3,
       @iqr AS IQR,
       @lower_bound AS lower_cutoff,
       @upper_bound AS upper_cutoff;

# SECTION 5 — High-Risk Employee Identification
/* Employees with:
High stress (>= 8)
Low productivity (<= 4)
 These are potential attrition-risk employees.*/
 select employeeid, jobrole, productivityscore,stressscore
 from sivaranjani_employees_stress_analysis_project
where stressscore >=8 and productivityscore<=4 ;

/*
Employees with:
Low satisfaction level
High overtime
Low sleep hours
📌 Category: "High HR Attention Needed".*/
select employeeid,jobrole,productivityscore,overtimehours,sleephours,
case 
when overtimehours >66 then 'high overtime hours'
when sleephours <5 then 'low sleephours' else 'no need'
end as hr_attention_needed
from sivaranjani_employees_stress_analysis_project
order by productivityscore desc,overtimehours desc,sleephours asc;

-- Calculate an Employee Risk Score

-- 1) Add RiskScore column (only if not exists)
ALTER TABLE sivaranjani_employees_stress_analysis_project
ADD COLUMN  RiskScore DECIMAL(6,2);

-- 2) Compute fallback averages (used to replace NULL Stress/Sleep)
SET @avg_stress := (SELECT ROUND(AVG(CAST(StressScore AS DECIMAL(8,2))),2) 
                    FROM sivaranjani_employees_stress_analysis_project);
SET @avg_sleep  := (SELECT ROUND(AVG(CAST(SleepHours AS DECIMAL(8,2))),2) 
                    FROM sivaranjani_employees_stress_analysis_project);

-- 3) Update RiskScore using simple formula and COALESCE to handle NULLs
UPDATE sivaranjani_employees_stress_analysis_project
SET RiskScore = ROUND(
      COALESCE(CAST(StressScore AS DECIMAL(8,2)), @avg_stress) * 0.5
    + COALESCE(CAST(OvertimeHours AS DECIMAL(8,2)), 0) * 0.3
    - COALESCE(CAST(SleepHours AS DECIMAL(8,2)), @avg_sleep) * 0.2
  , 2)
WHERE EmployeeID > 0;

-- 4) Quick preview of top 10 RiskScore values
SELECT EmployeeID, JobRole, StressScore, OvertimeHours, SleepHours, RiskScore
FROM sivaranjani_employees_stress_analysis_project
ORDER BY RiskScore DESC
LIMIT 10;

SET @col_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'siavaranjani_employees_stress_analysis_project'
      AND COLUMN_NAME = 'RiskScore'
);

SET @sql := IF(@col_exists = 0,
               'ALTER TABLE siavaranjani_employees_stress_analysis_project ADD COLUMN RiskScore DECIMAL(6,2);',
               'SELECT "RiskScore column already exists";');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Identify the top 20 employees with the highest Risk Score.
select employeeid, jobrole, productivityscore,riskscore
from sivaranjani_employees_stress_analysis_project
where riskscore >67
order by riskscore desc 
limit 20;

# 🔶 SECTION 6 — Trend & Summary Insights for Reports
-- Department-level comparison between Stress vs Productivity.
-- This gives average Stress and average Productivity per job role
/* Positive value → Stress is higher than productivity
→ department is struggling / overloaded

Negative value → Productivity is higher than stress
→ department is performing well

Higher the positive number → bigger imbalance */

select jobrole,
count(*) as n_emps,
round(avg(stressscore),2) as avg_stress,
round(avg(productivityscore),2) as avg_productivity,
round(avg(stressscore) - avg(productivityscore),2) as stress_minus_productivity
from sivaranjani_employees_stress_analysis_project
where stressscore is not null or productivityscore is not null
group by jobrole
order by stress_minus_productivity;

-- Correlation table output using SQL (if numeric values).
select
round( ( avg(sleephours * stressscore) - avg(sleephours)*avg(stressscore) ) /
( stddev_pop(sleephours) * stddev_pop(stressscore)),2) as pearson_sleep_stress,
round( ( avg(workhoursperweek * stressscore) - avg(workhoursperweek)*avg(stressscore) )/
( stddev_pop(workhoursperweek) * stddev_pop(stressscore) ),2) as pearson_workhoursperweek_stress,
round( ( avg(wfh_percent * stressscore) - avg(wfh_percent)*avg(stressscore) )/
( stddev_pop(wfh_percent) * stddev_pop(stressscore) ),2) as pearson_wfh_percent_stress,
round( ( avg(productivityscore * stressscore) - avg(productivityscore) *avg(stressscore) )/
( stddev_pop(productivityscore) * stddev_pop(stressscore) ),2) as perason_productivity_stress
from sivaranjani_employees_stress_analysis_project
where stressscore is not null;

-- Avg Work-Life Balance Score by department.
# compute max BreaksPerDay into a variable first
set @max_breaks := (select ifnull(max(breaksperday),1) 
from sivaranjani_employees_stress_analysis_project);
# department average WorkLifeBalanceScore
select jobrole,
count(*) as n_emps,
round(avg( (100-coalesce(workloadindex,50))*0.5 
+ (coalesce(breaksperday,0) / @max_breaks * 100) *0.2
+ coalesce(wfh_percent,0)*0.3
),2) as avg_work_life_balance
from sivaranjani_employees_stress_analysis_project
group by jobrole
order by avg_work_life_balance;

-- Does WFH reduce stress statistically?
select wfhcategory,
count(*) as n,
round(avg(stressscore),2) as avg_stress,
round(stddev_pop(stressscore),2) as sd_stress
from sivaranjani_employees_stress_analysis_project
where stressscore is not null
group by wfhcategory
order by avg_stress;
# Correlation between WFH_percent and StressScore
select 
round( ( avg(wfh_percent * stressscore) - avg(wfh_percent) * avg(stressscore) ) / 
( stddev_pop(wfh_percent) * stddev_pop(stressscore) ),2)as pearson_wfh_stress
from sivaranjani_employees_stress_analysis_project
where wfh_percent is not null and stressscore is not null;

-- Top 10 happiest employees (highest satisfaction & productivity)
select employeeid,jobrole,productivityscore,managerrating,
round( productivityscore * 0.6 + coalesce(managerrating * 0.4),2 ) as happiness_score
from sivaranjani_employees_stress_analysis_project
where productivityscore is not null
order by happiness_score desc
limit 10;








