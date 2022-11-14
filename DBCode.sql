CREATE DATABASE SunnySideHolidays;

\c sunnysideholidays

/*--------------------------*/
/*---------DATABASE---------*/
/*--------------------------*/

CREATE TABLE HOTEL (
  ht_id SERIAL PRIMARY KEY,
  ht_name VARCHAR(50) NOT NULL,
  ht_rating CHAR(5) NOT NULL,
  ht_country CHAR(2) NOT NULL,
  ht_addressLine1 VARCHAR(150) NOT NULL,
  ht_city VARCHAR(50) NOT NULL,
  ht_postcode VARCHAR(8) NOT NULL,
  ht_phoneNum VARCHAR(20) NOT NULL UNIQUE,
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
  pk_pricePP DECIMAL(6,2) NOT NULL,
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
  cust_phoneNum VARCHAR(20) NOT NULL UNIQUE,
  cust_email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE BOOKING (
  bk_id SERIAL PRIMARY KEY,
  cust_id INT NOT NULL UNIQUE,
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
  cust_id INT NOT NULL UNIQUE,
  pay_status BOOL NOT NULL,
  pay_numInstallments INT NOT NULL,
  pay_remaining DECIMAL(6,2) NOT NULL,
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

CREATE TABLE DEPARTMENT (
  dmpt_id SERIAL PRIMARY KEY,
  dmpt_name VARCHAR(25) NOT NULL,
  dmpt_desc TEXT
);

CREATE TABLE EMPLOYEE (
  emp_id SERIAL PRIMARY KEY,
  br_id INT NOT NULL,
  dmpt_id INT,
  emp_password VARCHAR(100) NOT NULL,
  emp_fname VARCHAR(50) NOT NULL,
  emp_lname VARCHAR(50) NOT NULL,
  emp_dob DATE NOT NULL,
  emp_addressLine1 VARCHAR(150) NOT NULL,
  emp_city VARCHAR(50) NOT NULL,
  emp_postcode VARCHAR(8) NOT NULL,
  emp_phoneNum VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (br_id)
      REFERENCES BRANCH(br_id)
      ON DELETE CASCADE,
    FOREIGN KEY (dmpt_id)
      REFERENCES DEPARTMENT(dmpt_id)
      ON DELETE CASCADE
);




CREATE TABLE FULLTIME (
  emp_id INT NOT NULL UNIQUE,
  ft_bonusScheme TEXT NOT NULL,
  ft_holidayAllowance INT NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE PARTTIME (
  emp_id INT NOT NULL UNIQUE,
  pt_weeklyHours DECIMAL(5,2) NOT NULL,
  pt_hourlyRate DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE HUMAN_RESOURCES (
  emp_id INT NOT NULL UNIQUE,
  hr_onIssue BOOL NOT NULL,
  hr_sector VARCHAR(20) NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE MARKETING (
  emp_id INT NOT NULL UNIQUE,
  mk_specialism VARCHAR(20) NOT NULL,
  mk_communications VARCHAR(20) NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE SALES_PERSONAL (
  emp_id INT NOT NULL UNIQUE,
  sales_area VARCHAR(20) NOT NULL,
  sales_total INT NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE QUALITY_CONTROL (
  emp_id INT NOT NULL UNIQUE,
  qc_weekltCheck BOOL NOT NULL,
  qc_totalReports INT NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE FINANCE (
  emp_id INT NOT NULL UNIQUE,
  fin_type VARCHAR(12) NOT NULL,
  fin_onTransaction BOOL NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE SUPERVISOR (
  emp_id INT NOT NULL UNIQUE,
  supvr_bonus TEXT NOT NULL,
  supvr_startDate DATE NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE
);

CREATE TABLE DEPARTMENT_MANAGER (
  emp_id INT NOT NULL UNIQUE,
  dmpt_id INT NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES SUPERVISOR(emp_id)
      ON DELETE CASCADE,
    FOREIGN KEY (dmpt_id)
      REFERENCES DEPARTMENT(dmpt_id)
      ON DELETE CASCADE
);

CREATE TABLE BRANCH_MANAGER (
  emp_id INT NOT NULL UNIQUE,
  br_id INT NOT NULL,
    FOREIGN KEY (emp_id)
      REFERENCES SUPERVISOR(emp_id)
      ON DELETE CASCADE,
    FOREIGN KEY (br_id)
      REFERENCES BRANCH(br_id)
      ON DELETE CASCADE
);



/*--------------------------*/
/*---------INSERTS---------*/
/*--------------------------*/

INSERT INTO HOTEL (ht_name, ht_rating, ht_country, ht_addressLine1, ht_city, ht_postcode, ht_phoneNum, ht_totalRooms, ht_extraDetails)
VALUES 
('Royal Hotel', 3, 'FR', 'Belgrave Road', 'Portsmouth', 'PO38 1JJ', '01983 852186', 300, null),
('New Place Hotel', 3, 'FR', 'Shirrell Heath', 'Southampton', 'SO32 2JY', '01329 833543', 200, 'Free Wifi - Breakfast - Free Parking - Indoor Pool - Laundry Service'),
('Burj Al Arab', 6, 'AE', 'Umm Suqeim 3', 'Dubai', '21936', '+971 4 301 7777', 500, 'Free Wifi - Breakfast - Free Parking - Indoor and Outdoor Pool - Air Conditioned'),
('Atlantis Palms', 5, 'AE', 'Crescent Rd - The Palm Jumeirah', '29406', 'Dubai', '+971 4 426 2000', 500, 'Free Wifi - Breakfast - Free Parking - Indoor and Outdoor Pool - Air Conditioned'),
('Bless Hotel', 4, 'ES', 'C. de Velázquez', '28001', 'Madrid', '+34 915 75 28 00', 400, null);

INSERT INTO ROOM (ht_id, rm_type, rm_numOfRoomType, rm_extraDetails)
VALUES
(1, 'Single Room', 100, null),
(1, 'Double Room', 100, null),
(1, 'Family Room', 100, null),
(2, 'Single Room', 100, null),
(2, 'Double Room', 50, null),
(2, 'Family Room', 50, null),
(3, 'Single Room', 100, null),
(3, 'Double Room', 200, null),
(3, 'Family Room', 200, null),
(4, 'Single Room', 100, null),
(4, 'Double Room', 300, null),
(4, 'Family Room', 100, null),
(5, 'Single Room', 100, null),
(5, 'Double Room', 200, null),
(5, 'Family Room', 100, null);

INSERT INTO CUSTOMER (cust_fname, cust_lname, cust_dob, cust_addressLine1, cust_city, cust_postcode, cust_phoneNum, cust_email)
VALUES
('James', 'Smith', '1984-01-10', '11 Stoneleigh Place', 'Oxford', 'OX10 6PT', '+44 7457 471053', 'jamessmith@gmail.com'),
('Micheal', 'Lee', '1983-02-11', '12 Buckfast Street', 'Oxford', 'OX45 3AF', '+44 7700 036373' , 'micheallee@gmail.com'),
('Robert', 'Micheals', '1985-03-12', '13 Abbots Place', 'London', 'NW5 9HX', '+44 7700 132081' , 'robertmicheals@gmail.com'),
('Maria', 'Garcia', '1999-04-13', '14 Abbotswell Road', 'London', 'NW12 4SE', '+44 7501 029740' , 'mariagarcia@gmail.com'),
('David', 'Laid', '1992-05-14', '15 Herald Street', 'Portsmouth', 'PO60 6HW', '+44 7448 689182' , 'davidlaid@gmail.com'),
('Maria', 'Rodriguez', '1988-06-15', '16 Hazel Grove', 'Portsmouth', 'PO15 7JE', '+44 7457 248442' , 'mariarodriguez@gmail.com'),
('Mary', 'Johnson', '1974-07-16', '17 Corn Street', 'Oxford', 'OX20 3RA', '+44 7911 804766' , 'maryjohnson@gmail.com'),
('Johnny', 'Bob', '1986-08-17', '18 Benhill Road', 'Oxford', 'OX3 1NA', '+44 7260 070448' , 'johnnybob@gmail.com'),
('Timmy', 'Dock', '1985-07-20', '13 Castle Road', 'Oxford', 'OX33 1SP', '+44 7272 072348' , 'timmydock@gmail.com'),
('Loudred', 'Smock', '1984-06-25', '19 Lapton Road', 'Oxford', 'OX10 1EA', '+44 7235 072348' , 'lourdredsmock@gmail.com');

INSERT INTO PAYMENT (cust_id, pay_status, pay_numInstallments, pay_remaining)
VALUES
(1, 'false', 1, 0000.00),
(2, 'true', 2, 400.00),
(3, 'false', 1, 0000.00),
(4, 'true', 3, 533.00),
(5, 'false', 1, 0000.00),
(6, 'true', 4, 3750.00),
(7, 'false', 1, 0000.00),
(8, 'true', 5, 3200.00),
(9, 'false', 1, 0000.00),
(10,'true', 6, 416.00);

INSERT INTO FLIGHT (flt_locationStart, flt_locationEnd, flt_date, flt_boarding)
VALUES
('UK', 'FR', '2023-01-11', '14:00:00'),
('UK', 'FR', '2023-01-10', '20:00:00'),
('UK', 'AE', '2023-01-09', '07:00:00'),
('UK', 'AE', '2023-01-12', '12:00:00'),
('UK', 'ES', '2023-01-08', '19:00:00');

INSERT INTO PACKAGE (flt_id, ht_id, pk_start, pk_end, pk_discount, pk_carRented, pk_pricePP)
VALUES
(1, 1, '2023-01-11', '2023-02-01', 0.0, 'false', 200.00),
(2, 2, '2023-01-10', '2023-02-01', 20.0, 'true', 200.00),
(3, 3, '2023-01-09', '2023-02-01', 0.0, 'true', 1250.00),
(4, 4, '2023-01-12', '2023-02-01', 50.0, 'false', 1000.00),
(5, 5, '2023-01-08', '2023-02-01', 0.0, 'false', 500.00);

INSERT INTO BOOKING (cust_id, pk_id, bk_numChildren, bk_numAdults)
VALUES
(1, 1, 0, 2),
(2, 1, 2, 2),
(3, 2, 1, 2),
(4, 2, 0, 4),
(5, 3, 2, 4),
(6, 3, 0, 4),
(7, 3, 5, 2),
(8, 4, 2, 2),
(9, 5, 2, 2),
(10, 5, 0, 1);

INSERT INTO BRANCH (br_address, br_postcode, br_city)
VALUES
('63 Springfield Road', 'CB60 5DF', 'Cambridge'),
('46 School Lane', 'SR32 8FV', 'Sunderland'),
('62 The Grove', 'LP68 3DY', 'Liverpool');

INSERT INTO BRANCH_PACKAGE (pk_id, br_id)
VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(1, 2),
(2, 2),
(3, 2),
(4, 2),
(5, 2),
(1, 3),
(2, 3),
(3, 3),
(4, 3),
(5, 3);

INSERT INTO DEPARTMENT (dmpt_name, dmpt_desc)
VALUES
('Human_Resources', 'Deals with issues between employees.'), 
('Marketing', 'Work to advertise the company.'), 
('Sales_Personal', 'Deals with customers.'),
('Quality_Control', 'Deals with complaints from customers.'),
('Finance', 'Work with keeping the branch up to date on tax.'),
('Supervisor', 'Manages the departments or the whole branch.');

INSERT INTO EMPLOYEE (br_id, dmpt_id, emp_password, emp_fname, emp_lname, emp_dob, emp_addressLine1, emp_city, emp_postcode, emp_phoneNum)
VALUES
(1, 1, 'password99', 'Jimmy', 'Yany', '1974-01-10', '1 Stanhope Cottages', 'Porstmouth', 'PO10 6XQ', '+44 7184 978346'), --1
(1, 2, 'password98', 'Johnny', 'Yip', '1975-02-11', '2 Heywood Moorings', 'Porstmouth', 'PO24 4LA', '+44 7448 610099'), --2
(1, 3, 'password97', 'Molly', 'Lee', '1976-03-12', '3 Ruskin Circus', 'Porstmouth', 'PO4 2SG', '+44 7911 257623'), --3
(1, 4, 'password96', 'Dolly', 'Long', '1977-04-13', '4 Oval Road South', 'Porstmouth', 'PO16 9AW', '+44 7700 035056'), --4
(1, 5, 'password95', 'Bob', 'Ross', '1978-05-14', '5 Academy Las', 'Porstmouth', 'PO42 1ZW', '+44 7911 263170'), --5
(1, 6, 'password94', 'Ross', 'Bob', '1979-06-15', '6 Madeira Barton', 'Porstmouth', 'PO3 8LT', '+44 7530 564682'), --6
(2, 1, 'password92', 'Chase', 'Wang', '1980-07-16', '7 Laburnum Covert', 'Oxford', 'OX16 6SN', '+44 7700 036784'), --7
(2, 2, 'password91', 'Simon', 'Zhang', '1981-08-17', '8 Northanger Drive', 'Oxford', 'OX67 8RW', '+44 7700 106905'), --8
(2, 3, 'password90', 'Robert', 'Liu', '1982-09-18', '9 Raleigh Avenue', 'Oxford', 'OX2N 6AS', '+44 7455 273211'), --9
(2, 4, 'password89', 'Oliver', 'Chen', '1983-10-19', '10 Middlefield Crescent', 'Oxford', 'OX2 2EG', '+44 7399 593441'), --10
(2, 5, 'password88', 'Jack', 'Yang', '1984-11-20', '11 Stoneyfields', 'Oxford', 'OX4 1BA', '+44 7700 065368'), --11
(2, 6, 'password87', 'Chris', 'Huang', '1985-12-21', '12 Brooklands Downs', 'Oxford', 'OX5 3NQ', '+44 7251 078340'), --12
(3, 1, 'password85', 'Don', 'Zhao', '1986-01-22', '13 Leven Fairway', 'London', 'NW14 8QH', '+44 7128 961695'), --13
(3, 2, 'password84', 'Marcus', 'Wu', '1987-02-23', '14 Madeira Circus', 'London', 'NW7 6PH', '+44 7457 535602'), --14 
(3, 3, 'password83', 'Serina', 'Zhou', '1988-03-24', '15 Kensington Circle', 'London', 'NW2 4EN', '+44 7911 087658'), --15
(3, 4, 'password82', 'Sophie', 'Sung', '1989-04-25', '16 Hanson Dene', 'London', 'NW6 0BX', '+44 7438 379111'), --16
(3, 5, 'password81', 'Lily', 'Kim', '1990-05-26', '17 Blake Acre', 'London', 'NW1 3EX', '+44 7130 561331'), --17
(3, 6, 'password80', 'Megan', 'Choi', '1991-06-27', '18 Atlas Corner', 'London', 'NW2 8PH', '+44 7149 090892'), --18
(1, null, 'password93', 'Charlie', 'Cho', '1992-07-28', '19 Francis Laurels', 'Porstmouth', 'PO38 0XX', '+44 7911 868063'), --19
(2, null, 'password86', 'Benjamin', 'Yun', '1993-08-29', '20 Union North', 'Oxford', 'OX30 9QG', '+44 7911 071634'), --20 
(3, null, 'password79', 'Pheonix', 'Jung', '1994-09-30', '21 Woods Mill', 'London', 'NW7 7LN', '+44 7116 040128'), --21
(1, 6, 'password01', 'Ai', 'Sato', '2000-01-27', '18 Elmtree Close', 'Portsmouth', 'PO19 8PN', '+44 7457 188038'), --22
(1, 6, 'password02', 'Asahi', 'Suzuki', '1999-02-26', '18 Aspen Ridgeway', 'Portsmouth', 'PO8 9NN', '+44 7457 834101'), --23
(1, 6, 'password03', 'Chiyo', 'Takahashi', '1998-03-25', '18 Curtis Gait', 'Portsmouth', 'PO14 5EW', '+44 7911 843679'), --24
(1, 6, 'password04', 'Daiki', 'Tanaka', '1997-04-24', '18 Curtis By-Pass', 'Portsmouth', 'PO3 0EP', '+44 7700 050628'), --25
(1, 6, 'password05', 'Emiko', 'Watanabe', '1996-05-23', '18 Sidney Meadows', 'Portsmouth', 'PO2 4JP', '+44 7700 081750'), --26
(2, 6, 'password06', 'Hana', 'Ito', '1995-06-22', '18 Greenwood Lawn', 'Oxford', 'OX6 5JY', '+44 7527 941268'), --27
(2, 6, 'password07', 'Hiroko', 'Nakamura', '1994-07-21', '18 Hanbury Square', 'Oxford', 'OX7 8SQ', '+44 7700 170737'), --28
(2, 6, 'password08', 'Hiroshi', 'Kobayashi', '1993-08-20', '18 Aylesbury Promenade', 'Oxford', 'OX16 6EQ', '+44 7700 065056'), --29
(2, 6, 'password09', 'Isamu', 'Yamamoto', '1992-09-19', '18 Morley Close', 'Oxford', 'OX31 2XD', '+44 7450 611544'), --30 
(2, 6, 'password10', 'Keiko', 'Kato', '1991-10-18', '18 Harebell Heights', 'Oxford', 'OX15 5FY', '+44 7568 960607'), --31
(3, 6, 'password11', 'Kenzo', 'Yamada', '1990-11-17', '18 Douglas Path', 'London', 'NW5 5BU', '+44 7502 267515'), --32
(3, 6, 'password12', 'Mai', 'Yoshida', '2000-12-16', '18 Watling Buildings', 'London', 'NW3 9TX', '+44 7457 109021'), --33
(3, 6, 'password13', 'Makoto', 'Sasaki', '1999-01-15', '18 Beresford Court', 'London', 'NW3 2DF', '+44 7911 047351'), --34
(3, 6, 'password14', 'Sakura', 'Yamaguchi', '1998-02-14', '18 Bloomfield Mead', 'London', 'NW20 6AG', '+44 7700 138011'), --35
(3, 6, 'password15', 'Yuki', 'Matsumoto', '1997-03-13', '18 Union Oaks', 'London', 'NW7 6QT', '+44 7151 494259'); --36

INSERT INTO FULLTIME (emp_id, ft_bonusScheme, ft_holidayAllowance)
VALUES
(1, 'no bonus', 14),
(2, 'no bonus', 14),
(3, 'no bonus', 14),
(4, 'no bonus', 14),
(5, 'no bonus', 14),
(6, 'no bonus', 16),
(7, 'no bonus', 14),
(8, 'no bonus', 14),
(9, 'no bonus', 14),
(10, 'no bonus', 14),
(11, 'no bonus', 14),
(12, 'no bonus', 16),
(13, 'no bonus', 14),
(14, 'no bonus', 14),
(15, 'no bonus', 14),
(16, 'no bonus', 14),
(17, 'no bonus', 14),
(18, 'no bonus', 16);

INSERT INTO PARTTIME (emp_id, pt_weeklyHours, pt_hourlyRate)
VALUES
(19, 18, 10.50),
(20, 17, 10.00),
(21, 16, 09.50);

INSERT INTO HUMAN_RESOURCES (emp_id, hr_onIssue, hr_sector)
VALUES
(1, 'true', 'people'),
(7, 'false', 'people'),
(13, 'false', 'people');

INSERT INTO MARKETING (emp_id, mk_specialism, mk_communications)
VALUES
(2, 'digital', 'internal + external'),
(8, 'design', 'external'),
(14, 'content', 'internal');

INSERT INTO SALES_PERSONAL (emp_id, sales_area, sales_total) 
VALUES
(3, 'packages', 10),
(9, 'packages', 21),
(15, 'hotels', 31);

INSERT INTO QUALITY_CONTROL (emp_id, qc_weekltCheck, qc_totalReports)
VALUES
(4, 'true', 9),
(10, 'true', 19),
(16, 'false', 12);

INSERT INTO FINANCE (emp_id, fin_type, fin_onTransaction)
VALUES
(5, 'bookkeeping', 'true'),
(11, 'accountant', 'true'),
(17, 'accountant', 'false');

INSERT INTO SUPERVISOR (emp_id, supvr_bonus, supvr_startDate) 
VALUES
(6, 'no bonus', '1970-01-28'),
(12, 'no bonus', '1971-02-27'),
(18, 'no bonus', '1972-03-26'),
(22, 'no bonus', '1973-04-25'),
(23, 'no bonus', '1974-05-24'),
(24, 'no bonus', '1975-06-23'),
(25, 'no bonus', '1976-07-22'),
(26, 'no bonus', '1977-08-21'),
(27, 'no bonus', '1978-09-20'),
(28, 'no bonus', '1979-10-19'),
(29, 'no bonus', '1971-11-18'),
(30, 'no bonus', '1972-12-17'),
(31, 'no bonus', '1973-01-16'),
(32, 'no bonus', '1974-02-15'),
(33, 'no bonus', '1975-03-14'),
(34, 'no bonus', '1976-04-13'),
(35, 'no bonus', '1977-05-12'),
(36, 'no bonus', '1978-06-11');

INSERT INTO DEPARTMENT_MANAGER (emp_id, dmpt_id) 
VALUES
(22, 1),
(23, 2),
(24, 3),
(25, 4),
(26, 5),
(27, 1),
(28, 2),
(29, 3),
(30, 4),
(31, 5),
(32, 1),
(33, 2),
(34, 3),
(35, 4),
(36, 5);

INSERT INTO BRANCH_MANAGER (emp_id, br_id)
VALUES
(6, 1),
(12, 2),
(18, 3);
-- END

/*--------------------------*/
/*---------Queries---------*/
/*--------------------------*/

-- Total Package cost per booking
CREATE VIEW
  package_pricing AS
SELECT
  BOOKING.bk_id AS "pp_bookingNumber",
  BOOKING.cust_id AS "pp_customerNumber",
  (BOOKING.bk_numAdults + BOOKING.bk_numChildren) AS "pp_totalTourists",
  PACKAGE.pk_pricePP AS "pp_pricePerPerson",
  PACKAGE.pk_discount AS "pp_packageDiscount",
  ROUND((PACKAGE.pk_pricePP - (PACKAGE.pk_pricePP * (PACKAGE.pk_discount / 100))), 2) AS "pp_finalPricePerPerson"
FROM BOOKING
JOIN PACKAGE ON BOOKING.pk_id = PACKAGE.pk_id;

SELECT
  (
    SELECT 
      CONCAT(CUSTOMER.cust_email, ' | ', CUSTOMER.cust_phoneNum) 
    FROM CUSTOMER 
    WHERE CUSTOMER.cust_id = package_pricing."pp_customerNumber"
  ) AS "Customer Contacts",
  package_pricing."pp_totalTourists" AS "Total Tourists",
  CONCAT('£', (package_pricing."pp_totalTourists" * package_pricing."pp_finalPricePerPerson")) AS "Total Overall Cost"
FROM package_pricing;

-- SELECT
--   CUSTOMER.cust_email AS "Customer Email",
--   CUSTOMER.cust_phoneNum AS "Customer Phonenumber",
--   package_pricing."pp_totalTourists" AS "Total Tourists",
--   CONCAT('£', (package_pricing."pp_totalTourists" * package_pricing."pp_finalPricePerPerson")) AS "Total Overall Cost"
-- FROM package_pricing, CUSTOMER
-- JOIN BOOKING ON BOOKING.cust_id = CUSTOMER.cust_id
-- WHERE package_pricing."pp_bookingNumber" = BOOKING.bk_id;


-- Best Performing Package

-- Details about a specific booking

-- Package payment status

-- Other one (idk)