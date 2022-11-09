CREATE DATABASE SunnySideHolidays;

\c sunnysideholidays

CREATE TABLE HOTEL (
    ht_id SERIAL PRIMARY KEY,
    ht_name VARCHAR(50) NOT NULL,
    ht_rating CHAR(5) NOT NULL,
    ht_country CHAR(2) NOT NULL,
    ht_addressLine1 VARCHAR(150) NOT NULL,
    ht_city VARCHAR(50) NOT NULL,
    ht_postcode VARCHAR(8) NOT NULL,
    ht_phoneNum VARCHAR(20) NOT NULL,
    ht_totalRooms INT NOT NULL,
    ht_extraDetails TEXT 
);

CREATE TABLE ROOM (
    rm_id SERIAL PRIMARY KEY,
    ht_id INT NOT NULL,
    rm_type VARCHAR(20) NOT NULL,
    rm_numOfRoomType INT NOT NULL,
    rm_extraDetails TEXT,
        FOREIGN KEY (ht_id)
            REFERENCES HOTEL(ht_id)
            ON DELETE CASCADE
);



CREATE TABLE FLIGHT (
    flt_id SERIAL PRIMARY KEY,
    flt_locationStart CHAR(2) NOT NULL,
    flt_locationEnd CHAR(2) NOT NULL,
    flt_date DATE NOT NULL,
    flt_boarding TIME NOT NULL
);

CREATE TABLE PACKAGE (
    pk_id SERIAL PRIMARY KEY,
    flt_id INT NOT NULL,
    ht_id INT NOT NULL,
    pk_start DATE NOT NULL,
    pk_end DATE NOT NULL,
    pk_discount DECIMAL(5,2) NOT NULL,
    pk_carRented BOOL NOT NULL,
    pk_pricePP DECIMAL(5,2) NOT NULL,
        FOREIGN KEY (flt_id)
            REFERENCES FLIGHT(flt_id)
            ON DELETE CASCADE,
        FOREIGN KEY (ht_id)
            REFERENCES HOTEL(ht_id)
            ON DELETE CASCADE
);

CREATE TABLE CUSTOMER (
    cust_id SERIAL PRIMARY KEY,
    cust_fname VARCHAR(50) NOT NULL,
    cust_lname VARCHAR(50) NOT NULL,
    cust_dob DATE NOT NULL,
    cust_addressLine1 VARCHAR(150) NOT NULL,
    cust_city VARCHAR(50) NOT NULL,
    cust_postcode VARCHAR(8) NOT NULL,
    cust_phoneNum VARCHAR(20) NOT NULL,
    cust_email VARCHAR(150) NOT NULL
);

CREATE TABLE BOOKING (
    bk_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL,
    pk_id INT NOT NULL,
    bk_numChildren INT NOT NULL,
    bk_numAdults INT NOT NULL,
         FOREIGN KEY (cust_id)
            REFERENCES CUSTOMER(cust_id)
            ON DELETE CASCADE,
        FOREIGN KEY (pk_id)
            REFERENCES PACKAGE(pk_id)
            ON DELETE CASCADE
);

CREATE TABLE PAYMENT (
    pay_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL,
    pay_status BOOL NOT NULL,
    pay_numInstallments INT NOT NULL,
    pay_remaining DECIMAL(5,2) NOT NULL,
        FOREIGN KEY (cust_id)
            REFERENCES CUSTOMER(cust_id)
            ON DELETE CASCADE
);

CREATE TABLE BRANCH (
    br_id SERIAL PRIMARY KEY,
    br_address VARCHAR(150) NOT NULL,
    br_postcode VARCHAR(8) NOT NULL,
    br_city VARCHAR(50) NOT NULL
);

CREATE TABLE BRANCH_PACKAGE (
    pk_id INT NOT NULL,
    br_id INT NOT NULL,
        FOREIGN KEY (pk_id)
            REFERENCES PACKAGE(pk_id)
            ON DELETE CASCADE,
         FOREIGN KEY (br_id)
            REFERENCES BRANCH(br_id)
            ON DELETE CASCADE
);

CREATE TABLE EMPLOYEE (
    emp_id SERIAL PRIMARY KEY,
    br_id INT NOT NULL,
    dmpt_id INT NOT NULL,
    emp_password VARCHAR(100) NOT NULL,
    emp_fname VARCHAR(50) NOT NULL,
    emp_lname VARCHAR(50) NOT NULL,
    emp_dob DATE NOT NULL,
    emp_addressLine1 VARCHAR(150) NOT NULL,
    emp_city VARCHAR(50) NOT NULL,
    emp_postcode VARCHAR(8) NOT NULL,
    emp_phoneNum VARCHAR(20) NOT NULL
        FOREIGN KEY (br_id)
            REFERENCES BRANCH(br_id)
            ON DELETE CASCADE,
        FOREIGN KEY (dmpt_id)
            REFERENCES DEPARTMENT(dmpt_id)
            ON DELETE CASCADE
);

CREATE TABLE DEPARTMENT (
    dmpt_id SERIAL PRIMARY KEY,
    dmpt_name VARCHAR(25) NOT NULL,
    dmpt_desc TEXT
);


CREATE TABLE FULLTIME (
    emp_id INT NOT NULL,
    ft_bonusScheme TEXT NOT NULL,
    ft_holidayAllowance INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);
-- talk about hourly rate and where it falls 
-- talk about data in tables eg full and part time
CREATE TABLE PARTTIME (
    emp_id INT NOT NULL,
    pt_weeklyHours DECIMAL(5,2) NOT NULL,
    pt_hourlyRate DECIMAL(5,2) NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);

CREATE TABLE HUMAN_RESOURCES (
    emp_id INT NOT NULL,
    hr_onIssue BOOL NOT NULL,
    hr_sector VARCHAR(20) NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);

CREATE TABLE MARKETING (
    emp_id INT NOT NULL,
    mk_specialism VARCHAR(20) NOT NULL,
    mk_communications VARCHAR(20) NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE

);

CREATE TABLE SALES_PERSONAL (
    emp_id INT NOT NULL,
    sales_area VARCHAR(20) NOT NULL,
    sales_total INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);

CREATE TABLE QUALITY_CONTROL (
    emp_id INT NOT NULL,
    qc_weekltCheck BOOL NOT NULL,
    qc_totalReports INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);

CREATE TABLE FINANCE (
    emp_id INT NOT NULL,
    fin_type VARCHAR(12) NOT NULL,
    fin_onTransaction BOOL NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);

CREATE TABLE SUPERVISOR (
    emp_id INT NOT NULL,
    supvr_bonus INT NOT NULL,
    supvr_startDate DATE NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE
);

CREATE TABLE DEPARTMENT_MANAGER (
    emp_id INT NOT NULL,
    dmpt_id INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES SUPERVISOR(emp_id)
            ON DELETE CASCADE,
        FOREIGN KEY (dmpt_id)
            REFERENCES DEPARTMENT(dmpt_id)
            ON DELETE CASCADE
);

CREATE TABLE BRANCH_MANAGER (
    emp_id INT NOT NULL,
    br_id INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES SUPERVISOR(emp_id)
            ON DELETE CASCADE,
        FOREIGN KEY (br_id)
            REFERENCES BRANCH(br_id)
            ON DELETE CASCADE
);




-- INSERTS 


INSERT INTO HOTEL (ht_name, ht_rating, ht_country, ht_addressLine1, ht_city, ht_postcode, ht_phoneNum, ht_totalRooms, ht_extraDetails)
VALUES 
    ('Octopus',3,'Fi','waya island','Fiji','ZE1 0AA','1172051731',52,'pool - catered - room service available'),
    ('Jamersons',5,'US','28 Manchester Road','SUTTON','SM1 5CW','0763613484',32,'non catered - room service - 24 hour security'),
    ('Badrutts palace',5,'Sw','Via Serlas 27','St. Moritz','SM1 5CW','0763613484',32,'non catered - room service - 24 hour security')
;

INSERT INTO ROOM (ht_id, rm_type,rm_numOfRoomType, rm_extraDetails)
VALUES
    
    (1,'small room','32','comes with onsweet, 2 singles,access to pool from 0700 - 1600'),
    (1,'large room','20','comes with onsweet, 2 doubles,access to pool from 0600 - 2030'),
    (2,'small room','12','comes with shared bathroom, 1 single'),
    (2,'medium room','10','comes with onsweet, 2 singles'),
    (2,'large room','10','comes with onsweet, 2 doubles')
;

INSERT INTO CUSTOMER (cust_fname, cust_lname, cust_dob, cust_addressLine1, cust_city, cust_postcode, cust_phoneNum, cust_email)
VALUES
('Jim','Bob','3-14-1967','62 Heatons Bank','Rawmarsh','S62 5RZ','7111 277692','marcelo65@hotmail.com'),
('Jack','Ram','7-29-1990','44 New Road','Nantyglo','NP23 4JT','776 533132','khalid21@gmail.com'),
('Mark','Smith','12-25-1984','51 Hullen Edge Lane','Elland','HX5 0QS','737 882501','wilfredo_schmidt55@gmail.com')
;

INSERT INTO PAYMENT (cust_id, pay_status, pay_numInstallments, pay_remaining)
VALUES
(1,'true',0,0),
(2,'false',8,2000),
(3,'false',3,300)
;

INSERT INTO FLIGHT (flt_locationStart, flt_locationEnd, flt_date, flt_boarding)
VALUES
('UK','US','6-13-2023','14:00:00'),
('UK','SW','7-24-2023','20:00:00'),
('UK','Fi','4-10-2023','07:00:00')
;

INSERT INTO PACKAGE (flt_id, ht_id, pk_start, pk_end, pk_discount, pk_carRented, pk_pricePP)
VALUES
(1,2,'6-13-2023','6-27-2023',0.0,'true',500.85),
(2,3,'7-24-2023','8-03-2023',0.0,'false',650.99),
(3,1,'4-10-2023','4-18-2023',0.0,'false',800.32)
;

INSERT INTO BOOKING (cust_id,pk_id,bk_numChildren,bk_numAdults)
VALUES
(1,1,2,2),
(2,1,0,2),
(3,2,3,2)
;

INSERT INTO BRANCH (br_address, br_postcode, br_city)
VALUES
('63 Springfield Road','CB605DF','CAMBRIDGE'),
('46 School Lane','SR328FV','SUNDERLAND'),
('62 The Grove','L863DY','LIVERPOOL')
;

INSERT INTO BRANCH_PACKAGE (pk_id, br_id)
VALUES
(1,1),
(1,2),
(1,3),
(2,1),
(2,2),
(2,3),
(3,1),
(3,2),
(3,3)
;

INSERT INTO EMPLOYEE (br_id, emp_password, emp_fname, emp_lname, emp_dob, emp_addressLine1, emp_city, emp_postcode, emp_phoneNum)
VALUES
(1,'123','Dan','Sung','12-23-2000','1 North Road','EAST CENTRAL LONDON','EC41 9GS','7700 900242'),
(1,'password','Joss','Denise','03-27-1990','7 Station Road','LLANDUDNO','LL32 5AW','7700 900621'),
(1,'fijds','Deimne','Wambdi','09-01-1986','397 The Avenue','PORTSMOUTH','PO33 5JH','07700 900755'),
(2,'hfguyw','Darya','Eustacia','10-16-2002','38 Alexander Road','COLCHESTER','CO2 8BP','07700 900160'),
(2,'djks','Siri','Killa','11-14-1975','9772 Highfield Road','DORCHESTER','DT16 3BR','07700 900111'),
(3,'password21','Ocean','Whitney','05-25-1984','84 South Street','WAKEFIELD','WF18 1KF','07700 900194')
;

INSERT INTO DEPARTMENT (dmpt_name, dmpt_desc)
VALUES
('Human_Resources','Deals with issues between employees.'), 
('Marketing','Work to advertise the company.'), 
('Sales_Personal','Deals with customers.'),
('Quality_Control','Deals with complaints from customers.'),
('Finance','Work with keeping the branch up to date on tax.'),
('Supervisor','Manages employees.'),
('Departments_Manager','Makes sure all departments are working properly.'),
('Branch_Manager','Makes sure the branch is working properly.')
;

INSERT INTO DEPARTMENT_EMPLOYEE (emp_id, dmpt_id)
VALUES
(1,3),
(2,3),
(3,6),
(4,4),
(5,5),
(6,6)
;

INSERT INTO FULLTIME (emp_id, ft_bonusScheme, ft_holidayAllowance)
VALUES
(1,'no bonus',14),
(2,'no bonus',14),
(3,'no bonus',14),
(4,'no bonus',14),
(5,'no bonus',14)
;

INSERT INTO PARTTIME (emp_id, pt_weeklyHours, pt_hourlyRate)
VALUES
(6,18,10.50)
;

INSERT INTO HUMAN_RESOURCES (emp_id, hr_onIssue, hr_sector)
VALUES
()
;

INSERT INTO MARKETING (emp_id, mk_specialism, mk_communications)
VALUES
()
;

INSERT INTO SALES_PERSONAL (emp_id, sales_area, sales_total) 
VALUES
()
;

INSERT INTO QUALITY_CONTROL (emp_id, qc_weekltCheck, qc_totalReports)
VALUES
()
;

INSERT INTO FINANCE (emp_id, fin_type, fin_onTransaction)
VALUES
()
;

INSERT INTO SUPERVISOR (emp_id, supvr_bonus, supvr_startDate) 
VALUES
()
;

INSERT INTO DEPARTMENT_MANAGER (emp_id, dmpt_id) 
VALUES
()
;

INSERT INTO BRANCH_MANAGER (emp_id, br_id)
VALUES
()
;
-- END

SELECT CUSTOMER.cust_id,cust_lname,cust_phoneNum,pay_status,pay_numInstallments,pay_remaining
FROM CUSTOMER
    INNER JOIN PAYMENT ON
    CUSTOMER.cust_id = PAYMENT.cust_id
WHERE pay_status = 'f';

SELECT CUSTOMER.cust_lname,flt_date,flt_boarding,flt_locationEnd
FROM CUSTOMER
    INNER JOIN BOOKING ON
    CUSTOMER.cust_id = BOOKING.cust_id
    INNER JOIN PACKAGE ON
    BOOKING.pk_id = PACKAGE.pk_id
    INNER JOIN FLIGHT ON
    PACKAGE.flt_id = FLIGHT.flt_id
WHERE CUSTOMER.cust_id = 1;


SELECT emp_id
FROM DEPARTMENT_EMPLOYEE 
    INNER JOIN DEPARTMENT ON
    DEPARTMENT_EMPLOYEE.dmpt_id = DEPARTMENT.dmpt_id
WHERE DEPARTMENT.dmpt_id = 1;