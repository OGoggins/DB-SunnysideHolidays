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
    pk_discount DECIMAL(5,4) NOT NULL,
    pk_carRented BOOL NOT NULL,
    pk_pricePP DECIMAL(5,4) NOT NULL,
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
    pay_remaining INT NOT NULL,
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
    emp_password VARCHAR(100) NOT NULL,
    emp_fname VARCHAR(50) NOT NULL,
    emp_lname VARCHAR(50) NOT NULL,
    emp_dob DATE NOT NULL,
    emp_addressLine1 VARCHAR(150) NOT NULL,
    emp_city VARCHAR(50) NOT NULL,
    emp_postcode VARCHAR(8) NOT NULL,
    emp_phoneNum VARCHAR(20) NOT NULL
);

CREATE TABLE DEPARTMENT (
    dmpt_id SERIAL PRIMARY KEY,
    dmpt_name VARCHAR(25) NOT NULL,
    dmpt_desc TEXT
);

CREATE TABLE DEPARTMENT_EMPLOYEE (
    emp_id INT NOT NULL,
    dmpt_id INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE,
        FOREIGN KEY (dmpt_id)
            REFERENCES DEPARTMENT(dmpt_id)
            ON DELETE CASCADE
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
    pt_weeklyHours INT NOT NULL,
    pt_hourlyRate INT NOT NULL,
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
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE,
        FOREIGN KEY (dmpt_id)
            REFERENCES DEPARTMENT(dmpt_id)
            ON DELETE CASCADE
);

CREATE TABLE BRANCH_MANAGER (
    emp_id INT NOT NULL,
    br_id INT NOT NULL,
        FOREIGN KEY (emp_id)
            REFERENCES EMPLOYEE(emp_id)
            ON DELETE CASCADE,
        FOREIGN KEY (br_id)
            REFERENCES BRANCH(br_id)
            ON DELETE CASCADE
);


-- END





INSERT INTO HOTEL (ht_name,ht_rating,ht_country,ht_addressLine1,ht_city,ht_postcode,ht_phoneNum,ht_numOfRooms,ht_extraDetails)
VALUES 
    ('Crown',3,'UK','69 Church Lane ','LERWICK','ZE1 0AA','0783213984',52,'pool - catered - room service available'),
    ('Jamersons',5,'UK','28 Manchester Road','SUTTON','SM1 5CW','0763613484',32,'non catered - room service - 24 hour security')
;

INSERT INTO ROOM (ht_id,rm_type,rm_numOfRoomType,rm_extraDetails)
VALUES
    
    (1,'small room','32','comes with onsweet, 2 singles,access to pool from 0700 - 1600'),
    (1,'large room','20','comes with onsweet, 2 doubles,access to pool from 0600 - 2030'),
    (2,'small room','12','comes with shared bathroom, 1 single'),
    (2,'medium room','10','comes with onsweet, 2 singles'),
    (2,'large room','10','comes with onsweet, 2 doubles')
;