/*--------------------------*/
/*---------DATABASE---------*/
/*--------------------------*/

CREATE TABLE ADDRESS (
  address_id SERIAL PRIMARY KEY,
  address_line1 VARCHAR(150) NOT NULL,
  address_line2 VARCHAR(150),
  address_city VARCHAR(50) NOT NULL,
  address_postcode VARCHAR(8) NOT NULL UNIQUE
);

CREATE TABLE CUSTOMER (
  cust_id SERIAL PRIMARY KEY,
  address_id INT NOT NULL,
  cust_fname VARCHAR(50) NOT NULL,
  cust_lname VARCHAR(50) NOT NULL,
  cust_dob DATE NOT NULL,
  cust_phoneNum VARCHAR(20) NOT NULL UNIQUE,
  cust_email VARCHAR(150) NOT NULL UNIQUE,
    FOREIGN KEY (address_id)
      REFERENCES ADDRESS(address_id)
      ON DELETE CASCADE
);

CREATE TABLE PAYMENT (
  payment_id SERIAL PRIMARY KEY,
  cust_id INT NOT NULL,
  payment_status BOOLEAN NOT NULL,
    FOREIGN KEY (cust_id)
      REFERENCES CUSTOMER(cust_id)
      ON DELETE CASCADE
);

CREATE TABLE INSTALMENTS (
  instalments_id SERIAL PRIMARY KEY,
  payment_id INT NOT NULL,
  instalments_number INT NOT NULL,
  instalments_amountPaid DECIMAL(6, 2)
);

CREATE TABLE HOTEL (
  hotel_id SERIAL PRIMARY KEY,
  address_id INT NOT NULL,
  hotel_name VARCHAR(50) NOT NULL,
  hotel_rating CHAR(1) NOT NULL,
  hotel_country CHAR(2) NOT NULL,
  hotel_phoneNum VARCHAR(20) NOT NULL UNIQUE,
  hotel_totalRooms INT NOT NULL,
    FOREIGN KEY (address_id)
      REFERENCES ADDRESS(address_id)
      ON DELETE CASCADE
);

CREATE TABLE ROOM (
  room_id SERIAL PRIMARY KEY,
  hotel_id INT NOT NULL,
  room_type VARCHAR(20),
  room_numOfRoomType INT,
    FOREIGN KEY (hotel_id)
      REFERENCES HOTEL(hotel_id)
      ON DELETE CASCADE
);

CREATE TABLE AMENITIES (
  amenities_id SERIAL PRIMARY KEY,
  amenities_name VARCHAR(50) NOT NULL,
  amenities_desc TEXT
);

CREATE TABLE ROOM_AMENITIES (
  room_id INT NOT NULL,
  amenities_id INT NOT NULL,
    FOREIGN KEY (room_id)
      REFERENCES ROOM(room_id)
      ON DELETE CASCADE,
    FOREIGN KEY (amenities_id)
      REFERENCES AMENITIES(amenities_id)
      ON DELETE CASCADE
);

CREATE TABLE HOTEL_AMENITIES (
  hotel_id INT NOT NULL,
  amenities_id INT NOT NULL,
    FOREIGN KEY (hotel_id)
      REFERENCES HOTEL(hotel_id)
      ON DELETE CASCADE,
    FOREIGN KEY (amenities_id)
      REFERENCES AMENITIES(amenities_id)
      ON DELETE CASCADE
);

CREATE TABLE BRANCH (
  branch_id SERIAL PRIMARY KEY,
  address_id INT NOT NULL,
  branch_name VARCHAR(50),
    FOREIGN KEY (address_id)
      REFERENCES ADDRESS(address_id)
      ON DELETE CASCADE
);

CREATE TABLE FLIGHT (
  flight_id SERIAL PRIMARY KEY,
  flight_locationStart CHAR(2) NOT NULL,
  flight_locationEnd CHAR(2) NOT NULL,
  flight_date DATE NOT NULL,
  flight_boarding TIME NOT NULL
);

CREATE TABLE PACKAGE (
  package_id SERIAL PRIMARY KEY,
  flight_id INT NOT NULL,
  hotel_id INT NOT NULL,
  package_start DATE NOT NULL,
  package_end DATE NOT NULL,
  package_discount DECIMAL(5, 2) NOT NULL,
  package_carRented BOOLEAN NOT NULL,
  package_pricePP DECIMAL(6, 2) NOT NULL,
    FOREIGN KEY (flight_id)
      REFERENCES FLIGHT(flight_id)
      ON DELETE CASCADE,
    FOREIGN KEY (hotel_id)
      REFERENCES HOTEL(hotel_id)
      ON DELETE CASCADE
);

CREATE TABLE BRANCH_PACKAGE (
  branch_id INT NOT NULL,
  package_id INT NOT NULL,
    FOREIGN KEY (branch_id)
      REFERENCES BRANCH(branch_id)
      ON DELETE CASCADE,
    FOREIGN KEY (package_id)
      REFERENCES PACKAGE(package_id)
      ON DELETE CASCADE
);

CREATE TABLE BOOKING (
  booking_id SERIAL PRIMARY KEY,
  cust_id INT NOT NULL,
  package_id INT NOT NULL,
    FOREIGN KEY (cust_id)
      REFERENCES CUSTOMER(cust_id)
      ON DELETE CASCADE,
    FOREIGN KEY (package_id)
      REFERENCES PACKAGE(package_id)
      ON DELETE CASCADE
);

CREATE TABLE TRAVELLERS (
  traveller_id SERIAL PRIMARY KEY,
  booking_id INT NOT NULL,
  traveller_fname VARCHAR(50) NOT NULL,
  traveller_lname VARCHAR(50) NOT NULL,
  traveller_dob DATE NOT NULL,
    FOREIGN KEY (booking_id)
      REFERENCES BOOKING(booking_id)
      ON DELETE CASCADE
);

CREATE TABLE DEPARTMENT (
  dmpt_id SERIAL PRIMARY KEY,
  dmpt_name VARCHAR(25) NOT NULL UNIQUE,
  dmpt_emailSuffix VARCHAR(25) NOT NULL,
  dmpt_desc TEXT
);

CREATE TABLE ROLE (
  role_id SERIAL PRIMARY KEY,
  dmpt_id INT NOT NULL,
  role_name VARCHAR(50) NOT NULL UNIQUE,
  role_annualSalary DECIMAL(8, 2) NOT NULL,
  role_desc TEXT,
    FOREIGN KEY (dmpt_id)
        REFERENCES DEPARTMENT(dmpt_id)
        ON DELETE CASCADE
);

CREATE TABLE EMPLOYEE (
  emp_id SERIAL PRIMARY KEY,
  address_id INT NOT NULL,
  branch_id INT NOT NULL,
  role_id INT NOT NULL,
  emp_password VARCHAR(100) NOT NULL,
  emp_fname VARCHAR(50) NOT NULL,
  emp_lname VARCHAR(50) NOT NULL,
  emp_dob DATE NOT NULL,
  emp_phoneNum VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (address_id)
      REFERENCES ADDRESS(address_id)
      ON DELETE CASCADE,
    FOREIGN KEY (branch_id)
      REFERENCES BRANCH(branch_id)
      ON DELETE CASCADE,
    FOREIGN KEY (role_id)
      REFERENCES ROLE(role_id)
      ON DELETE CASCADE,
);

CREATE TABLE BRANCH_MANAGER (
  emp_id INT NOT NULL UNIQUE,
  mgr_branch_id INT,
    FOREIGN KEY (emp_id)
      REFERENCES EMPLOYEE(emp_id)
      ON DELETE CASCADE,
    FOREIGN KEY (mgr_branch_id)
      REFERENCES BRANCH(branch_id)
      ON DELETE CASCADE
);


/*--------------------------*/
/*---------INSERTS---------*/
/*--------------------------*/

INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode)
VALUES
-- customer addresses
('11 Stoneleigh Place', 'Suite 127', 'Oxford', 'OX10 6PT'), --1
('12 Buckfast Street', null, 'Oxford', 'OX45 3AF'), --2
('13 Abbots Place', null, 'London', 'NW5 9HX'), --3
('14 Abbotswell Road', 'Suite 63', 'London', 'NW12 4SE'), --4
('15 Herald Street', null, 'Portsmouth', 'PO60 6HW'), --5
('16 Hazel Grove', 'Suite 97', 'Portsmouth', 'PO15 7JE'), --6
('17 Corn Street', 'Suite 965', 'Oxford', 'OX20 3RA'), --7
('18 Benhill Road', null, 'Oxford', 'OX3 1NA'), --8
('13 Castle Road', 'Suite 12', 'Oxford', 'OX33 1SP'), --9
('19 Lapton Road', null, 'Oxford', 'OX10 1EA'), --10
-- hotel addresses
('12 Belgrave Road', null, 'Portsmouth', 'PO38 1JJ'), --11
('13 Shirrell Heath', null, 'Southampton', 'SO32 2JY'), --12
('13 Umm Suqeim 3', null, 'Dubai', '21936'), --13
('14 Crescent Rd - The Palm Jumeirah', null, 'Dubai', '29406'), --14
('15 C. de Velázquez', null, 'Madrid', '28001'), --15
-- branch addresses
('63 Springfield Road', null, 'Cambridge', 'CB60 5DF'), --16
('46 School Lane', null, 'Sunderland', 'SR32 8FV'), --17
('62 The Grove', null, 'Liverpool', 'LP68 3DY'); --18

INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email)
VALUES
(1, 'James', 'Smith', '1984-01-10', '+44 7457 471053', 'jamessmith@gmail.com'),
(2, 'Micheal', 'Lee', '1983-02-11', '+44 7700 036373' , 'micheallee@gmail.com'),
(3, 'Robert', 'Micheals', '1985-03-12', '+44 7700 132081' , 'robertmicheals@gmail.com'),
(4, 'Maria', 'Garcia', '1999-04-13', '+44 7501 029740' , 'mariagarcia@gmail.com'),
(5, 'David', 'Laid', '1992-05-14', '+44 7448 689182' , 'davidlaid@gmail.com'),
(6, 'Maria', 'Rodriguez', '1988-06-15', '+44 7457 248442' , 'mariarodriguez@gmail.com'),
(7, 'Mary', 'Johnson', '1974-07-16', '+44 7911 804766' , 'maryjohnson@gmail.com'),
(8, 'Johnny', 'Bob', '1986-08-17', '+44 7260 070448' , 'johnnybob@gmail.com'),
(9, 'Timmy', 'Dock', '1985-07-20', '+44 7272 072348' , 'timmydock@gmail.com'),
(10, 'Loudred', 'Smock', '1984-06-25', '+44 7235 072348' , 'lourdredsmock@gmail.com');


INSERT INTO HOTEL (hotel_name, address_id, hotel_rating, hotel_country, hotel_phoneNum, hotel_totalRooms)
VALUES 
('Royal Hotel', 11, 3, 'FR', '01983 852186', 300),
('New Place Hotel', 12, 3, 'FR', '01329 833543', 200),
('Burj Al Arab', 13, 6, 'AE', '+971 4 301 7777', 500),
('Atlantis Palms', 14, 5, 'AE', '+971 4 426 2000', 500),
('Bless Hotel', 15, 4, 'ES', '+34 915 75 28 00', 400);

INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType)
VALUES
(1, 'Single Room', 100), --1
(1, 'Double Room', 100), --2
(1, 'Family Room', 100), --3
(2, 'Single Room', 100), --4
(2, 'Double Room', 50), --5
(2, 'Family Room', 50), --6
(3, 'Single Room', 100), --7
(3, 'Double Room', 200), --8
(3, 'Family Room', 200), --9
(4, 'Single Room', 100), --10
(4, 'Double Room', 300), --11
(4, 'Family Room', 100), --12
(5, 'Single Room', 100), --13
(5, 'Double Room', 200), --14
(5, 'Family Room', 100); --15

INSERT INTO AMENITIES (amenities_name, amenities_desc)
VALUES
('Free Wifi', null), -- 1
('Breakfast', '08:30am - 11:30am free breakfast'), -- 2
('Lunch' , '12:00pm - 16:30pm free lunch'), -- 3
('Supper' , '17:00am - 22:00am free supper'), -- 4
('Free Parking', null), -- 5
('Indoor Pool', null), -- 6
('Outdoor Pool', null), -- 7
('Laundry Service', 'Washing machines and tumble dryers, must provide own cleaning products'), -- 8
('Air Conditioned', 'Rooms contain built-in air conditioning'), -- 9

('Single Bed', null), -- 10
('King-sized Bed', null), -- 11
('King-sized + Single Bed', null), -- 12
('Kettle', null), -- 13
('Television', null), -- 14
('Desk + Desk Chair', null), -- 15
('Couch', '2 person couch'), -- 16
('Bathroom', 'Contains toilet, shower, bath, sink, cupboard / storage'); -- 17

INSERT INTO HOTEL_AMENITIES (hotel_id, amenities_id)
VALUES
(1, 1), (1, 2), (1, 5), 
(2, 1), (2, 2), (2, 5), (2, 8),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 9),
(4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 9),
(5, 1), (5, 2), (5, 5), (5, 8);

INSERT INTO ROOM_AMENITIES (room_id, amenities_id)
VALUES
(1, 10), (1, 13), (1, 17),
(2, 11), (2, 13), (2, 17),
(3, 12), (3, 13), (3, 17),
(4, 10), (4, 13), (4, 17),
(5, 11), (5, 13), (5, 17),
(6, 12), (6, 13), (6, 17),
(7, 11), (7, 13), (7, 14), (7, 15), (7, 16), (7, 17),
(8, 11), (8, 13), (8, 14), (8, 15), (8, 16), (8, 17),
(9, 12), (9, 13), (9, 14), (9, 15), (9, 16), (9, 17),
(10, 11), (10, 13), (10, 14), (10, 15), (10, 16), (10, 17), 
(11, 11), (11, 13), (11, 14), (11, 15), (11, 16), (11, 17),
(12, 12), (12, 13), (12, 14), (12, 15), (12, 16), (12, 17),
(13, 10), (13, 13), (13, 17),
(14, 11), (14, 13), (14, 17),
(15, 12), (15, 13), (15, 17);

INSERT INTO FLIGHT (flight_locationStart, flight_locationEnd, flight_date, flight_boarding)
VALUES
('UK', 'FR', '2023-01-11', '14:00:00'),
('UK', 'FR', '2023-01-10', '20:00:00'),
('UK', 'AE', '2023-01-09', '07:00:00'),
('UK', 'AE', '2023-01-12', '12:00:00'),
('UK', 'ES', '2023-01-08', '19:00:00');

INSERT INTO PACKAGE (flight_id, hotel_id, package_start, package_end, package_discount, package_carRented, package_pricePP)
VALUES
(1, 1, '2023-01-11', '2023-02-01', 0.0, 'false', 200.00),
(2, 2, '2023-01-10', '2023-02-01', 20.0, 'true', 200.00),
(3, 3, '2023-01-09', '2023-02-01', 0.0, 'true', 1250.00),
(4, 4, '2023-01-12', '2023-02-01', 50.0, 'false', 1000.00),
(5, 5, '2023-01-08', '2023-02-01', 0.0, 'false', 500.00);

INSERT INTO BRANCH (address_id, branch_name)
VALUES
(16, 'Sunnyside Cambridge'),
(17, 'Sunnyside Sunderland'),
(18, 'Sunnyside Liverpool');

INSERT INTO BRANCH_PACKAGE (package_id, branch_id)
VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1),
(1, 2), (2, 2), (3, 2), (4, 2), (5, 2),
(1, 3), (2, 3), (3, 3), (4, 3), (5, 3);

INSERT INTO BOOKING (cust_id, package_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 1),
(7, 2),
(8, 3),
(9, 4),
(10, 5);

INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob)
VALUES
(1, 'James', 'Smith', '1984-01-10'),
(2, 'Micheal', 'Lee', '1983-02-11'), (2, 'Jennifer', 'Lee', '1983-07-01'),
(3, 'Rob', 'Sung', '1984-02-02'), (3, 'Raquel', 'Sung', '1984-10-16'), (3, 'Charis', 'Sung', '2000-09-30'), (3, 'Cieran', 'Sung', '2003-07-03'),
(4, 'Jimmy', 'Johns', '1980-02-18'), (4, 'Susan', 'Megans', '1982-07-19'), (4, 'Jimmy Jr.', 'Johns', '1999-11-10'),
(5, 'David', 'Laid', '1992-05-14'),
(6, 'Maria', 'Rodriguez', '1988-06-15'), (6, 'Elly', 'Smith', '1987-11-15'), (6, 'Margret', 'Fatcher', '1983-09-15'), (6, 'Sophie', 'Leeds', '1987-01-25'),
(7, 'Mary', 'Johnson', '1974-07-16'), (7, 'Simon', 'Johnson', '1974-06-16'),
(8, 'Johnny', 'Bob', '1986-08-17'),
(9, 'Timmy', 'Dock', '1985-07-20'),
(10, 'Loudred', 'Smock', '1984-06-25');

INSERT INTO PAYMENT (cust_id, payment_status) 
VALUES
(1, 'true'),
(2, 'true'),
(3, 'false'),
(4, 'true'),
(5, 'false'),
(6, 'false'),
(7, 'true'),
(8, 'true'),
(9, 'true'),
(10,'false');


INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid)
VALUES
(1, 1, 100.00), (1, 2, 200.00),
(2, 1, 400),
(3, 1, 1250), (3, 2, 1250), (3, 3, 1250), -- total:£5000 | paid:£3750 | remaining:£1250
(4, 1, 3000),
(5, 1, 50), (5, 2, 50), (5, 3, 50), (5, 4, 50), (5, 5, 50), (5, 6, 50), -- total:£500 | paid:£300 | remaining:£200
(6, 1, 200), (6, 2, 200), -- total:£800 | paid:£400 | remaining:£400 
(7, 1, 400),
(8, 1, 1250),
(9, 1, 1000),
(10, 1, 100); -- total:£500 | paid:£100 | remaining:£400

INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc)
VALUES
('Administration', 'admin.sunnyside.ac.uk', 'Includes management and admin'),
('Research & Development', 'rd.sunnyside.ac.uk', 'Research to gather knowlegde to create new successful packages or improve exsisting packages'),
('Marketing & Sales', 'ms.sunnyside.ac.uk', 'Responsible for promoting and creating holiday package sales'),
('Human Resources', 'hr.sunnyside.ac.uk', 'Responsible for all things worker-related'),
('Customer Service', 'cs.sunnyside.ac.uk', 'Provide direct help, advice and service directly with customers'),
('Accounting & Finance', 'af.sunnyside.ac.uk', 'Tracks revenues and expenses');

INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc)
VALUES
('Branch Manager', 1, 120000.00, null),
('Administration Manager', 1, 90000.00, null),
('Senior Administration Manager', 1, 80000.00, null),
('Admin', 1, 70000.00, null),

('R&D Manager', 2, 60000.00, null),
('R&D Project Manager', 2, 55000.00, null),
('Senior R&D Project Manager', 2, 50000.00, null),
('R&D Project Coordinator', 2, 45000.00, null),
('R&D', 2, 40000.00, null),

('Marketing & Sales Manager', 3, 60000.00, null),
('Senior Marketing Manager', 3, 55000.00, null),
('Senior Sales Manager', 3, 55000.00, null),
('Marketing Project Manager', 3, 50000.00, null),
('Marketing Project Coordinator', 3, 45000.00, null),
('Sales Project Manager', 3, 50000.00, null),
('Sales Project Corrdinator', 3, 45000.00, null),
('Marketing', 3, 40000.00, null),
('Sales', 3, 40000.00, null),

('HR Manager' 4, 60000.00, null),
('Senior HR Manager' 4, 55000.00, null),
('HR' 4, 40000.00, null),

('Customer Service Manager', 5, 60000.00, null),
('Senior Customer Serive Manager', 5, 55000.00, null),
('Customer Experience', 5, 40000.00, null),
('Customer Advocate', 5, 40000.00, null),

('Accoutanting & Finace Manager', 6, 60000.00, null),
('Senior Accoutanting & Finace Manager', 6, 55000.00, null),
('General Accoutant', 6, 50000.00, null),
('Tax Accoutant', 6, 50000.00, null),
('Forensic Accoutant', 6, 50000.00, null),
('Bookkeeping', 6, 50000.00, null);


INSERT INTO EMPLOYEE (address_id, branch_id, role_id, dmpt_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum)
VALUES
();

INSERT INTO BRANCH_MANAGER (emp_id, mgr_dmpt_id, mgr_branch_id)
VALUES
();
