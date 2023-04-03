create database dbms_project2;
use dbms_project2;

create table patient (patient_id varchar(5) primary key,
                      patient_name varchar(20) not null,
                      patient_dob date not null,
                      patient_sex char(1),
                      patient_address varchar(50) not null,
                      total_duration numeric(2),
                      patient_status varchar(10) not null,
                      staff_id varchar(4),
                      foreign key(staff_id) references backend_staff(staff_id));
desc patient;
alter table patient drop column installation1;
alter table patient drop column installation2;

create table parents (parent_id varchar(5),
                      parent_name varchar(20) not null,
                      parent_phone numeric(10) not null,
                      parent_email varchar(30),
                      patient_id varchar(5),
                      foreign key(patient_id) references patient(patient_id),
                      primary key (parent_id, patient_id));
desc parents;

create table doctors (doc_id varchar(4) primary key,
					  doc_name varchar(20) not null,
                      doc_email varchar(30),
                      doc_phone numeric(10) not null,
                      doc_qualification varchar(15) not null,
                      doc_yoe numeric(2) not null,
                      doc_cost numeric(6) not null,
                      doc_target numeric(3) not null,
                      doc_date_of_joining date not null,
                      staff_id varchar(4),
                      foreign key(staff_id) references backend_staff(staff_id));
desc doctors;

create table programs (program_code varchar(4) primary key,
                       program_name varchar(70) not null,
                       proogram_cost numeric(5) not null);
desc programs;
alter table programs rename column proogram_cost to program_cost;

create table tests (test_id varchar(4) primary key,
					test_name varchar(70) not null,
                    test_cost numeric(5) not null);
desc tests;

create table branches (branch_name varchar(10) primary key,
					   branch_max_patient numeric(3) not null,
                       branch_patient_target numeric(3) not null,
                       branch_address varchar(50) not null);
desc branches;

create table backend_staff (staff_id varchar(4) primary key,
                            staff_name varchar(20) not null,
                            staff_email varchar(30),
                            staff_dept varchar(10) not null,
                            staff_sal numeric(5) not null,
                            staff_joining_date date not null);
desc backend_staff;

create table phone_num (staff_id varchar(4),
                        foreign key(staff_id) references backend_staff(staff_id),
                        staff_phone numeric(10),
                        primary key (staff_id, staff_phone));
desc phone_num;

-- relations

create table takes (test_id varchar(4),
					foreign key(test_id) references tests(test_id),
                    patient_id varchar(5),
                    foreign key(patient_id) references patient(patient_id),
                    test_date date not null,
                    primary key (test_id, patient_id, test_date));
desc takes;

create table enrolls (program_code varchar(4),
                      foreign key(program_code) references programs(program_code),
                      patient_id varchar(5),
                      foreign key(patient_id) references patient(patient_id),
                      date_of_enrollment date not null,
                      primary key (program_code, patient_id, date_of_enrollment));
desc enrolls;
alter table enrolls add column installation1 numeric(5) not null;
alter table enrolls add column installation2 numeric(5);
alter table enrolls rename column installation1 to installment1;
alter table enrolls rename column installation2 to installment2;

create table consults (branch_name varchar(10),
                       foreign key(branch_name) references branches(branch_name),
                       doc_id varchar(4),
                       foreign key(doc_id) references doctors(doc_id),
                       patient_id varchar(5),
                       foreign key(patient_id) references patient(patient_id),
                       date_of_visit date not null,
                       primary key (branch_name, doc_id, patient_id, date_of_visit));
desc consults;

create table requires (program_code varchar(4),
                       foreign key(program_code) references programs(program_code),
                       test_id varchar(4),
                       foreign key	(test_id) references tests(test_id),
                       primary key (program_code, test_id));
desc requires;


#changes done after importing excel

delete from enrolls where patient_id="C714";
INSERT INTO takes VALUES ('BASC', 'C563', '2018-11-11');
update doctors
set doc_target=2 
where doc_id="D129";
INSERT INTO consults VALUES ('GRGNW', 'D123', 'C098', '2019-01-12');
insert into consults values('DADAR', 'D009', 'C454', '2017-09-17');
insert into enrolls (program_code, patient_id, date_of_enrollment, installment1) values ("P105", "C006", "2023-04-03", 9600);
insert into enrolls (program_code, patient_id, date_of_enrollment, installment1) values ("P103", "C347", "2023-04-03", 2000);
insert into requires values ('P104', 'ADOS');

