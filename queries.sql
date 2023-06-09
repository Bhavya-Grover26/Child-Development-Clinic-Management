select * from backend_staff;
select * from branches;
select * from consults;
select * from doctors;
select * from enrolls;
select * from parents;
select * from patient;
select * from phone_num;
select * from programs;
select * from requires;
select * from takes;
select * from tests;

#1. Backend Staff that interacts with patients
select distinct backend_staff.staff_id,staff_name,staff_dept
from patient, backend_staff
where patient.staff_id = backend_staff.staff_id;

#2. Third highest salary of backend staff
select *
from backend_staff
order by staff_sal desc
limit 2,1;

#3. existing female patients
select patient_id,patient_name
from patient
where patient_status="existing" and patient_sex="F";

#4. calaculate age from dob
SELECT DATE_FORMAT(NOW(), '%Y') - DATE_FORMAT(patient_dob, '%Y') - (DATE_FORMAT(NOW(), '00-%m-%d') < DATE_FORMAT(patient_dob, '00-%m-%d')) AS age, patient_name,patient_dob
from patient
order by age;

#5. patients with more than 1 parent registered 
select patient_name,  group_concat(distinct parents.parent_name) AS parent_names
from patient natural inner join parents
group by patient_id 
having count(parent_id)>1;

#6. display in ascending order no of patients in each program
SELECT enrolls.program_code, program_name,COUNT(Patient.patient_id) AS num_patients
FROM enrolls natural INNER JOIN Patient 
natural inner join programs
GROUP BY program_code
order by num_patients desc;

#7 Backend Staff name in ascending order
select * from backend_staff
order by staff_name asc;

#8 Backend Staff having more than 1 phone number 
select * from backend_staff natural inner join phone_num
where staff_id in (select staff_id from phone_num group by staff_id having count(*) > 1);

#9 Staff that has worked less than a month in a particular department
select staff_name, staff_dept, datediff(current_date(),staff_joining_date) as days_worked
from backend_staff
where datediff(current_date(),staff_joining_date) < 30;

#10 Total number of patients a doctor treats in a year in each branch
select branch_name, count(distinct patient_id) as total_patients
from consults
group by branch_name;

#11 How much a doctor is earning per day 
select doc_id, doc_name, count(patient_id), (doc_cost * count(patient_id)) as earnings_per_day
from consults natural inner join doctors
group by doc_id;

#12 Number of tests taken on a particular day
select test_date, count(test_id) as no_of_tests
from takes
group by test_date order by test_date asc;

#13 In a branch how many more patients can register
select branch_name, count(distinct patient_id) as total_patients, (branch_max_patient - count(distinct patient_id)) as remaining_capacity
from consults natural inner join branches
group by branch_name;

#14 Has the patient completed its program duration 
select patient_name, total_duration
from patient
where total_duration % 3=0 and total_duration <> 0;

#15 Display name of staff whose salary > average salary
select staff_name, staff_sal
from backend_staff
where staff_sal > (select avg(staff_sal) from backend_staff);

#16 Select the names of all patients who have a total duration that is a perfect square.
select patient_name, total_duration
from patient
where sqrt(total_duration) = round(sqrt(total_duration))
order by total_duration desc;

-- Patient id which are pallindromes
select patient_id, patient_name
from patient
where patient_id = concat('C', substr(reverse(patient_id), 1, 3));

-- total cost of tests taken by each patient
select patient_id, sum(test_cost)
from takes natural inner join tests
group by patient_id;

-- patients whose payments not completed after installment 1
select patient_id, program_code
from patient natural inner join enrolls
where patient_id in (select patient_id
					 from enrolls
                     where installment2 is not null);

-- patients who have taken more than 2 tests
select patient_id
from takes
group by patient_id
having count(patient_id) > 2;

-- % of patients who have completed their program
select concat((select count(patient_id) 
		from patient 
        where total_duration % 3 = 0 and patient_status != "new") / count(patient_id) * 100, '%') as percentage_complete
from patient;

-- no. of patients who have taken tests that cost more than avg. cost of all tests
select count(distinct patient_id) as no_of_patients
from patient natural inner join tests
where test_cost > (select avg(test_cost)
				   from tests);

-- revenue generated by each program, order by program code and display total no. of patients
select program_code, program_name, program_cost * count(patient_id) as revenue_generated, count(patient_id) as total_no_of_patients
from programs natural inner join enrolls
group by program_code;

-- revenue generated by each doctor
select doc_id, concat('Dr. ', doc_name) as doc_name, count(date_of_visit) * doc_cost as revenue_generated
from doctors natural inner join consults
group by doc_id;

-- doctors whose length of qualification > 10
select doc_id, doc_name, doc_qualification
from doctors
where length(doc_qualification) > 10; 

-- patients whose name starts with 'A'
select patient_name
from patient
where patient_name like 'A%';

-- Show payment status of all patients
select patient_id, program_code, if (installment1 + installment2 = program_cost, "FULL PAYMENT DONE", "PAYMENT PENDING") as payment_status
from programs natural inner join enrolls;

#30 Patients who have taken tests but not enrolled in any program 
select patient.patient_id, patient_name
from patient natural inner join takes
where patient.patient_id not in 
(select patient_id
from enrolls);

#31 programs that have the total cost greater than the sum of the costs of all the tests taken by a patient.
SELECT program_code, program_name, program_cost
FROM programs
WHERE program_cost > (
    SELECT SUM(test_cost)
    FROM tests
    JOIN takes ON tests.test_id = takes.test_id
    JOIN enrolls ON takes.patient_id = enrolls.patient_id
    WHERE enrolls.program_code = programs.program_code
);

#32 Display the tests that have been taken by more than 1 patients 
select tests.test_id,test_name,test_cost,count(patient_id) as num_of_patients
from tests natural inner join takes
group by tests.test_id
having count(patient_id)>1;

#33 Display all patients who have same parents 
create view sibling as 
(SELECT DISTINCT p1.patient_id, p1.patient_name, pa1.parent_id, p1.patient_dob, p1.patient_sex, p1.patient_address, p1.total_duration, p1.patient_status, p1.staff_id
FROM patient p1, patient p2, parents pa1, parents pa2
WHERE p1.patient_id <> p2.patient_id
AND pa1.parent_id = pa2.parent_id
AND pa1.patient_id = p1.patient_id
AND pa2.patient_id = p2.patient_id);
drop view sibling;
select *
from sibling;

#34. doctors who were able to complete their target 
select *
from doctors
where doc_target = 
(select count(*)
from consults
where doc_id = doctors.doc_id);

#35.No of sessions of a particular patient with a particular doctor
select doc_id,patient_id,count(patient_id) as num_of_visits
from consults 
group by patient_id, doc_id
order by num_of_visits desc;

#36. Display all programs associated with each test 
select test_id, program_code, program_name
from requires natural inner join tests 
natural inner join programs 
order by test_id;

#37. Find the date of enrollment of each patient and the no of consultations they took in 2019
select patient_name,date_of_enrollment,count(date_of_visit) as num_of_consultation
from patient natural inner join enrolls
natural inner join consults
where year(date_of_visit)=2019
group by patient_id,date_of_enrollment;

#38. find employees who have the highest salary in each of the departments.
select s.staff_dept as Department,staff_name,staff_sal
from backend_staff s inner join
(select staff_dept,max(staff_sal) as max_sal
from backend_staff
group by staff_dept ) as M
on s.staff_dept=M.staff_dept and s.staff_sal=M.max_sal
order by s.staff_sal desc;

#39. Rank the doctors based on their no of target patients (if same then give them the same rank) 
select doc_name,doc_target,dense_rank() over (order by doc_target desc) as "rank"
from doctors;

#40. Doctors charges based on their experience
select doc_yoe,avg(doc_cost/doc_yoe) as avg_cost_per_year_of_experience
from doctors
group by doc_yoe
order by doc_yoe;

#41. Per branch the cost collection 
select branch_name, sum(enrolls.installment1 + enrolls.installment2) as collection
from enrolls natural inner join consults
group by branch_name;

#42. Average earning per patient per program
select program_code,patient_id, avg(enrolls.installment1 + enrolls.installment2) as Average
from enrolls
group by program_code,patient_id;


#43. Most occurring tests
SELECT test_id, count(test_id) 
FROM takes  GROUP BY test_id 
HAVING count(test_id)=( 
SELECT max(mycount) 
FROM ( 
SELECT test_id, count(test_id) mycount 
FROM takes
GROUP BY test_id) takes );

# 44. Number of sessions a doctor takes in one day
select doc_id, count(date_of_visit)
from consults
group by doc_id,date_of_visit;

#45. Count number of sessions
select count(*) as no_of_sessions
from consults;

#46. Display number of patients who took the same test more than once
select count(patient_id), patient_id
from takes 
group by test_id, patient_id;

# 47. For doctors if years_of_experience < 5 display junior if >5 senior 
SELECT doc_name,
CASE WHEN doc_yoe < 5 THEN 'Junior'
WHEN doc_yoe >= 5 AND doc_yoe <= 10 THEN 'Senior'
ELSE 'Veteran' END AS experience_level
FROM doctors;

#48. Get the salary of previous and next employee , Salary difference of the employee compared to the next employee (using LEAD)
select staff_id, staff_name, staff_sal,
		LEAD(staff_sal) over (order by staff_sal) as sal_of_next_employee,
        LEAD(staff_sal) over (order by staff_sal) - staff_sal as sal_diff_between_next,
        LAG(staff_sal) over (order by staff_sal) as sal_of_prev_employee 
from backend_staff;

#49. Average cost of programs
select avg(program_cost) as Average_Cost
from programs;

#50. Divide in 3 NTILE groups can be created based on the program costs.
select program_code, 
ntile(3) over (order by program_cost)
from programs;

#51. Write sql query that finds out finance who earns more than hr
SELECT a.staff_name
from backend_staff a join backend_staff b
on a.staff_dept = 'Finance' and b.staff_dept = 'HR'
where a.staff_sal > b.staff_sal;

#52. Display all programs who have same test
select program_name
from programs natural inner join requires
group by test_id
having count(test_id) > 1;

#53. All programs a patient has done
select program_name,  group_concat(distinct patient.patient_name) AS patient_names
from enrolls natural inner join patient natural inner join programs
group by program_name
having count(patient_id)>1;

#54 If installment 1 < 60% of program cost then display the patient's name.
select patient_id, patient_name
from patient natural inner join enrolls natural inner join programs
where program_code in (select program_code from programs natural inner join enrolls where installation1 < (0.6*program_cost));



