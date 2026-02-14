# creating Data Base
create database project;

# Using Data Base
use project;


-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

select * from JobDepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from salarybonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

select * from employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

select * from qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from payroll;


# Analysis Questions

# 1. EMPLOYEE INSIGHTS
# How many unique employees are currently in the system?
select count(distinct emp_id) as "total_unique_employees"
from employee;

# Which departments have the highest number of employees?
select jd.jobdept, count(e.emp_id) as "Count_of_Employees"
from employee e
join jobdepartment as jd on e.job_id = jd.job_id
group by jd.jobdept
order by Count_of_Employees desc;

# What is the average salary per department?
select jd.jobdept, avg(sb.amount) as "Average_Salary"
from jobdepartment as jd
join salarybonus as sb on jd.job_id = sb.job_id
group by jd.jobdept;

# Who are the top 5 highest-paid employees?
select e.emp_id, e.firstname, e.lastname, e.gender, sb.amount 
from employee as e
join salarybonus as sb
on e.job_id = sb.job_id
order by sb.amount desc
limit 5;

# What is the total salary expenditure across the company?
select sum(total_amount) as "total_salary_expenditure" from payroll;

# 2. JOB ROLE AND DEPARTMENT ANALYSIS

# How many different job roles exist in each department?
select jobdept, count(distinct name) as job_roles 
from jobdepartment
group by jobdept;

# What is the average salary range per department?
alter table jobdepartment
add min_salary int,
add max_salary int;

update jobdepartment
set min_salary = replace(trim(substring_index(salaryrange, "-", 1)), "$", ""),
    max_salary = replace(trim(substring_index(salaryrange, "-", -1)), "$", "");

select jobdept, 
	avg(max_salary - min_salary) as avg_salary
from jobdepartment
group by jobdept;

# Which job roles offer the highest salary?
select distinct jd.name, sb.amount from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
order by sb.amount desc
limit 7;

# Which departments have the highest total salary allocation?
select jd.jobdept, sum(sb.amount) as "Total_Salary" 
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by Total_Salary desc;


# 3. QUALIFICATION AND SKILLS ANALYSIS
# How many employees have at least one qualification listed?
select count(distinct Emp_ID) as employees_with_one_qualifications
from Qualification;

# Which positions require the most qualifications?
select position, count(qualid) as "total_qualifications"
from qualification
group by position
order by total_qualifications desc;

# Which employees have the highest number of qualifications?
select emp_id,  count(qualid) as "total_qualifications"
from qualification
group by emp_id
order by total_qualifications desc;


# 4. LEAVE AND ABSENCE PATTERNS

# Which year had the most employees taking leaves?
select year(date) as year, count(leave_id) as leave_count 
from leaves
group by year(date)
order by count(leave_id);

# What is the average number of leave days taken by its employees per department?
select jd.jobdept, avg(leave_id) as "Avg_Leaves" 
from leaves as l
join employee as e on l.emp_id = e.emp_id
join jobdepartment as jd on e.job_id = jd.job_id
group by jobdept
order by Avg_Leaves desc;

# Which employees have taken the most leaves?
select emp_id, count(leave_id) as total_leaves
from leaves
group by emp_id
order by total_leaves desc;


# What is the total number of leave days taken company-wide?
select count(*) as "total_leave_days"
from leaves;

# How do leave days correlate with payroll amounts?
select e.emp_id, count(l.leave_id) as total_leaves, p.total_amount
from Employee e
left join leaves l on e.emp_id = l.emp_id
join payroll p on e.emp_id = p.emp_id
group by e.emp_id, p.total_amount
order by total_leaves desc;


# 5. PAYROLL AND COMPENSATION ANALYSIS
#  What is the total monthly payroll processed?
select year(date) as year,
    month(date) as month,
    sum(total_amount) as total_monthly_payroll
from Payroll
group by year(date), month(date)
order by year, month;

# What is the average bonus given per department?
select jd.jobdept, avg(sb.bonus) as "Average_Bonus" 
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd.jobdept;

# Which department receives the highest total bonuses?
select jd.jobdept, sum(sb.bonus) as "total_bonus" 
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by total_bonus desc;

# What is the average value of total_amount after considering leave deductions?
select avg(total_amount) as "Avg_total_amount" from payroll;