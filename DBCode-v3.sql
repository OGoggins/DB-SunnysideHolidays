DROP DATABASE SUNNYSIDE;
CREATE DATABASE SUNNYSIDE;
\c sunnyside;

/*--------------------------*/
/*---------DATABASE---------*/
/*--------------------------*/
DROP TABLE IF EXISTS INSTALMENTS CASCADE;
DROP TABLE IF EXISTS PAYMENT CASCADE;
DROP TABLE IF EXISTS TRAVELLERS CASCADE;
DROP TABLE IF EXISTS BOOKING CASCADE; 
DROP TABLE IF EXISTS EMPLOYEE CASCADE; 
DROP TABLE IF EXISTS ROLE CASCADE; 
DROP TABLE IF EXISTS DEPARTMENT CASCADE; 
DROP TABLE IF EXISTS BRANCH_PACKAGE CASCADE; 
DROP TABLE IF EXISTS PACKAGE CASCADE; 
DROP TABLE IF EXISTS FLIGHT CASCADE; 
DROP TABLE IF EXISTS BRANCH CASCADE; 
DROP TABLE IF EXISTS HOTEL_AMENITIES CASCADE; 
DROP TABLE IF EXISTS ROOM_AMENITIES CASCADE; 
DROP TABLE IF EXISTS AMENITIES CASCADE; 
DROP TABLE IF EXISTS ROOM CASCADE; 
DROP TABLE IF EXISTS HOTEL CASCADE; 
DROP TABLE IF EXISTS CUSTOMER CASCADE; 
DROP TABLE IF EXISTS ADDRESS CASCADE; 

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
  package_pricePP DECIMAL(8, 2) NOT NULL,
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

CREATE TABLE PAYMENT (
  payment_id SERIAL PRIMARY KEY,
  booking_id INT NOT NULL,
  payment_totalPrice DECIMAL(8, 2),
  payment_amountPaid DECIMAL(8, 2),
  payment_status BOOLEAN,
    FOREIGN KEY (booking_id)
      REFERENCES BOOKING(booking_id)
      ON DELETE CASCADE
);

CREATE TABLE INSTALMENTS (
  instalments_id SERIAL PRIMARY KEY,
  payment_id INT NOT NULL,
  instalments_number INT NOT NULL,
  instalments_amountPaid DECIMAL(8, 2)
);

/*--------------------------*/
/*---------FUNCTIONS---------*/
/*--------------------------*/
CREATE OR REPLACE FUNCTION set_payment_after_booking_insert()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
AS 
$$
BEGIN
  INSERT INTO PAYMENT(booking_id, payment_status, payment_totalPrice, payment_amountPaid) VALUES (NEW.booking_id, 'FALSE', null, null);
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION update_payment_after_travellers_insert()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
AS
$$
DECLARE
  numberOfTravellers INT;
  pricePerPerson DECIMAL(6, 2);
BEGIN
  SELECT COUNT(*) INTO numberOfTravellers
  FROM TRAVELLERS t 
  WHERE t.booking_id = NEW.booking_id;

  SELECT p.package_pricePP - (p.package_pricePP * (p.package_discount / 100)) INTO pricePerPerson
  FROM BOOKING b
  JOIN PACKAGE p ON b.package_id = p.package_id
  WHERE b.booking_id = NEW.booking_id;

  UPDATE PAYMENT SET payment_totalPrice = numberOfTravellers * pricePerPerson WHERE PAYMENT.booking_id = NEW.booking_id;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION update_amountPaid_after_instalments_insert()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
AS 
$$
DECLARE
  oldAmountPaid DECIMAL(6, 2);
  newAmountPaid DECIMAL(6, 2);
  totalPrice DECIMAL(6, 2);
BEGIN
  SELECT p.payment_amountPaid INTO oldAmountPaid FROM PAYMENT p WHERE p.payment_id = NEW.payment_id;
  IF (oldAmountPaid IS NULL) THEN oldAmountPaid := 0;
  END IF;
  UPDATE PAYMENT SET payment_amountPaid = (oldAmountPaid + NEW.instalments_amountPaid) WHERE PAYMENT.payment_id = NEW.payment_id;

  SELECT p.payment_amountPaid INTO newAmountPaid FROM PAYMENT p WHERE p.payment_id = NEW.payment_id;
  SELECT p.payment_totalPrice INTO totalPrice FROM PAYMENT p WHERE p.payment_id = NEW.payment_id;
  IF (newAmountPaid >= totalPrice) THEN
  UPDATE PAYMENT SET payment_status = 'TRUE' WHERE PAYMENT.payment_id = NEW.payment_id;
  END IF;

  RETURN NEW;
END;
$$;

/*--------------------------*/
/*---------TRIGGERS---------*/
/*--------------------------*/
DROP TRIGGER IF EXISTS set_payment_after_booking_insert ON BOOKING;
CREATE TRIGGER set_payment_after_booking_insert
  AFTER INSERT ON BOOKING
  FOR EACH ROW
EXECUTE PROCEDURE set_payment_after_booking_insert();

DROP TRIGGER IF EXISTS update_payment_after_travellers_insert ON TRAVELLERS;
CREATE TRIGGER update_payment_after_travellers_insert
  AFTER INSERT ON TRAVELLERS
  FOR EACH ROW
EXECUTE PROCEDURE update_payment_after_travellers_insert();

DROP TRIGGER IF EXISTS update_amountPaid_after_instalments_insert ON INSTALMENTS;
CREATE TRIGGER update_amountPaid_after_instalments_insert
  AFTER INSERT ON INSTALMENTS
  FOR EACH ROW
EXECUTE PROCEDURE update_amountPaid_after_instalments_insert();


/*--------------------------*/
/*---------INSERTS---------*/
/*--------------------------*/

INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode)
VALUES
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
('12 Belgrave Road', null, 'Portsmouth', 'PO38 1JJ'), --11
('13 Shirrell Heath', null, 'Southampton', 'SO32 2JY'), --12
('13 Umm Suqeim 3', null, 'Dubai', '21936'), --13
('14 Crescent Rd - The Palm Jumeirah', null, 'Dubai', '29406'), --14
('15 C. de Velázquez', null, 'Madrid', '28001'), --15
('63 Springfield Road', null, 'Cambridge', 'CB60 5DF'), --16
('46 School Lane', null, 'Sunderland', 'SR32 8FV'), --17
('62 The Grove', null, 'Liverpool', 'LP68 3DY'), --18
('1 Stanhope Cottages', null, 'Porstmouth', 'PO10 6XQ'), --19
('2 Heywood Moorings', null, 'Porstmouth', 'PO24 4LA'), --20
('3 Ruskin Circus', null, 'Porstmouth', 'PO4 2SG'), --21
('4 Oval Road South', null, 'Porstmouth', 'PO16 9AW'), --22
('5 Academy Las', null, 'Porstmouth', 'PO42 1ZW'), --23
('6 Madeira Barton', null, 'Porstmouth', 'PO3 8LT'), --24
('19 Francis Laurels', null, 'Porstmouth', 'PO38 0XX'), --25
('18 Sidney Meadows', null, 'Portsmouth', 'PO2 4JP'), --26
('18 Elmtree Close', null, 'Portsmouth', 'PO19 8PN'), --27
('18 Aspen Ridgeway', null, 'Portsmouth', 'PO8 9NN'), --28
('18 Curtis Gait', null, 'Portsmouth', 'PO14 5EW'), --29
('18 Curtis By-Pass', null, 'Portsmouth', 'PO3 0EP'), --30
('19 Long Passage', null, 'Portsmouth', 'PO1 4AR'), --31
('19 Jade Row', null, 'Portsmouth', 'PO2 5BS'), --32
('19 Prospect Route', null, 'Portsmouth', 'PO3 6CT'), --33
('19 Canal Avenue', null, 'Portsmouth', 'PO4 7DU'), --34
('19 New Castle Way', null, 'Portsmouth', 'PO5 8EV'), --35
('19 Liberty Street', null, 'Portsmouth', 'PO6 9FW'), --36
('19 Central Street', null, 'Portsmouth', 'PO7 1GX'), --37
('19 Arctic Street', null, 'Portsmouth', 'PO8 2HY'), --38
('19 Ember Row', null, 'Portsmouth', 'PO9 3IZ'), --39
('19 Tower Boulevard', null, 'Portsmouth', 'PO10 4JA'), --40
('19 General Street', null, 'Portsmouth', 'PO11 5KB'), --41
('19 Medieval Row', null, 'Portsmouth', 'PO12 6LC'), --42
('19 Crown Avenue', null, 'Portsmouth', 'PO13 7MD'), --43
('19 Azure Street', null, 'Portsmouth', 'PO14 8NE'), --44
('19 Green Avenue', null, 'Portsmouth', 'PO15 9OF'), --45
('19 Congress Way', null, 'Portsmouth', 'PO16 1PG'), --46
('19 Elmwood Row', null, 'Portsmouth', 'PO17 2QH'), --47
('7 Laburnum Covert', null, 'Oxford', 'OX16 6SN'), --48
('8 Northanger Drive', null, 'Oxford', 'OX67 8RW'), --49
('9 Raleigh Avenue', null, 'Oxford', 'OX2N 6AS'), --50
('10 Middlefield Crescent', null, 'Oxford', 'OX2 2EG'), --51
('11 Stoneyfields', null, 'Oxford', 'OX4 1BA'), --52
('12 Brooklands Downs', null, 'Oxford', 'OX5 3NQ'), --53
('20 Union North', null, 'Oxford', 'OX30 9QG'), --54
('18 Harebell Heights', null, 'Oxford', 'OX15 5FY'), --55
('18 Morley Close', null, 'Oxford', 'OX31 2XD'), --56
('18 Aylesbury Promenade', null, 'Oxford', 'OX16 6EQ'), --57
('18 Hanbury Square', null, 'Oxford', 'OX7 8SQ'), --58
('18 Greenwood Lawn', null, 'Oxford', 'OX6 5JY'), --59
('19 Starlight Avenue', null, 'Oxford', 'OX1 4AR'), --60
('19 Acorn Avenue', null, 'Oxford', 'OX2 5BS'), --61
('19 Flint Passage', null, 'Oxford', 'OX3 6CT'), --62
('19 Palm Avenue', null, 'Oxford', 'OX4 7DU'), --63
('19 Lily Lane', null, 'Oxford', 'OX5 8EV'), --64
('19 Museum Avenue', null, 'Oxford', 'OX6 9FW'), --65
('19 Polygon Lane', null, 'Oxford', 'OX7 1GX'), --66
('19 Mandarin Street', null, 'Oxford', 'OX8 2HY'), --67
('19 Luna Route', null, 'Oxford', 'OX9 3IZ'), --68
('19 Duchess Way', null, 'Oxford', 'OX0 4JA'), --69
('19 Rose Lane', null, 'Oxford', 'OX1 5KB'), --70
('19 Feathers Boulevard', null, 'Oxford', 'OX2 6LC'), --71
('19 Gold Way', null, 'Oxford', 'OX3 7MD'), --72
('19 Storm Avenue', null, 'Oxford', 'OX4 8NE'), --73
('19 Noble Boulevard', null, 'Oxford', 'OX5 9OF'), --74
('19 Bay Lane', null, 'Oxford', 'OX6 1PG'), --75
('19 Congress Boulevard', null, 'Oxford', 'OX7 2QH'), --76
('13 Leven Fairway', null, 'London', 'NW14 8QH'), --77
('14 Madeira Circus', null, 'London', 'NW7 6PH'), --78
('15 Kensington Circle', null, 'London', 'NW2 4EN'), --79
('16 Hanson Dene', null, 'London', 'NW6 0BX'), --80
('17 Blake Acre', null, 'London', 'NW1 3EX'), --81
('18 Atlas Corner', null, 'London', 'NW2 8PH'), --82
('21 Woods Mill', null, 'London', 'NW7 7LN'), --83
('18 Union Oaks', null, 'London', 'NW7 6QT'), --84
('18 Bloomfield Mead', null, 'London', 'NW20 6AG'), --85
('18 Beresford Court', null, 'London', 'NW3 2DF'), --86
('18 Watling Buildings', null, 'London', 'NW3 9TX'), --87
('18 Douglas Path', null, 'London', 'NW5 5BU'), --88
('19 Snowflake Boulevard', null, 'London', 'NW7 2QH'), --89
('19 Arctic Avenue', null, 'London', 'NW6 1PG'), --90
('19 Hazelnut Street', null, 'London', 'NW5 9OF'), --91
('19 Middle Lane', null, 'London', 'NW4 8NE'), --92
('19 Gem Street', null, 'London', 'NW3 7MD'), --93
('19 Rosemary Avenue', null, 'London', 'NW2 6LC'), --94
('19 Broom Row', null, 'London', 'NW1 5KB'), --95
('19 Cavern Passage', null, 'London', 'NW0 4JA'), --96
('19 Orchid Street', null, 'London', 'NW9 3IZ'), --97
('19 Low Avenue', null, 'London', 'NW8 2HY'), --98
('19 Clarity Lane', null, 'London', 'NW7 1GX'), --99
('19 Bard Boulevard', null, 'London', 'NW6 9FW'), --100
('19 Congress Street', null, 'London', 'NW5 8EV'), --101
('19 Plaza Route', null, 'London', 'NW4 7DU'), --102
('19 Valley Avenue', null, 'London', 'NW3 6CT'), --103
('19 Orchid Avenue', null, 'London', 'NW2 5BS'), --104
('19 Crystal Street', null, 'London', 'NW1 4AR'); --105

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
('Branch Manager', 1, 120000.00, 'manages a specific branch'), --1
('Administration Manager', 1, 90000.00, 'manager of all administration'), --2
('Senior Administration Manager', 1, 80000.00, 'senior manager of all administration'), --3
('Admin', 1, 70000.00, null), --4
('R&D Manager', 2, 60000.00, 'manager of all R&D'), --5
('R&D Project Manager', 2, 55000.00, 'manager of a current R&D project'), --6
('Senior R&D Project Manager', 2, 50000.00, 'senior manager of a current R&D project'), --7
('R&D Project Coordinator', 2, 45000.00, 'Coordinates current R&D project'), --8
('R&D', 2, 40000.00, null), --8
('Marketing & Sales Manager', 3, 60000.00, 'manager of all marketing and sales'), --9
('Senior Marketing Manager', 3, 55000.00, 'senior manager of all marketing'), --10
('Senior Sales Manager', 3, 55000.00, 'senior manager of all sales'), --11
('Marketing Project Manager', 3, 50000.00, 'manager of a current marketing project'), --12
('Marketing Project Coordinator', 3, 45000.00, 'Coordinates current marketing project'), --13
('Sales Project Manager', 3, 50000.00, 'manager of a current sales project'), --14
('Sales Project Corrdinator', 3, 45000.00, 'Coordinates current sales project'), --15
('Marketing', 3, 40000.00, null), --15
('Sales', 3, 40000.00, null), --16
('HR Manager', 4, 60000.00, 'manager of all human resources'), --17
('Senior HR Manager', 4, 55000.00, 'senior manager of all human resources'), --18
('HR', 4, 40000.00, null), --19
('Customer Service Manager', 5, 60000.00, 'manager of all customer service'), --20
('Senior Customer Serive Manager', 5, 55000.00, 'senior manager of all customer service'), --21
('Customer Experience', 5, 40000.00, 'looks and reviews previous customers experience'), --22
('Customer Advocate', 5, 40000.00, 'ensures customers opinions are properly reviewed and considered'), --23
('Accoutanting & Finace Manager', 6, 60000.00, 'manager of all Accountanting & Finance'), --24
('Senior Accoutanting & Finace Manager', 6, 55000.00, 'senior manager of all Accountanting & Finance'), --25
('General Accoutant', 6, 50000.00, null), --26
('Tax Accoutant', 6, 50000.00, null), --27
('Forensic Accoutant', 6, 50000.00, null), --28
('Bookkeeping', 6, 50000.00, null); --29


INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum)
VALUES
(19, 1, 1, 'password01', 'Li', 'Wang', '1987-01-20', '+44 7700 900685'), --1 --here
(20, 1, 2, 'password02', 'Wei', 'Li', '1987-02-21', '+44 7700 900051'), --2
(21, 1, 3, 'password03', 'Fang', 'Zhang', '1987-03-22', '+44 7700 900154'), --3
(22, 1, 4, 'password04', 'Wei', 'Cheung', '1987-04-23', '+44 7700 900565'), --4
(23, 1, 5, 'password05', 'Xiuying', 'Teoh', '1987-05-24', '+44 7700 900807'), --5
(24, 1, 6, 'password06', 'Xiuying', 'Chan', '1987-06-25', '+44 7700 900956'), --6
(25, 1, 7, 'password07', 'Na', 'Yeung', '1987-07-26', '+44 7700 900398'), --7
(26, 1, 8, 'password08', 'Xiuying', 'Wong', '1987-08-27', '+44 7700 900933'), --8
(27, 1, 9, 'password09', 'Wei', 'Chiu', '1987-09-28', '+44 7700 900822'), --9
(28, 1, 10, 'password10', 'Min', 'Ng', '1987-10-29', '+44 7700 900294'), --10
(29, 1, 11, 'password11', 'Jing', 'Chow', '1987-11-01', '+44 7700 900798'), --11
(30, 1, 12, 'password12', 'Li', 'Chao', '1987-12-02', '+44 7700 900723'), --12
(31, 1, 13, 'password13', 'Qiang', 'Tsui', '1987-01-03', '+44 7700 900661'), --13
(32, 1, 14, 'password14', 'Jing', 'Chu', '1987-02-04', '+44 7700 900044'), --14
(33, 1, 15, 'password15', 'Min', 'Wu', '1987-03-05', '+44 7700 900477'), --15
(34, 1, 16, 'password16', 'Min', 'Ho', '1987-04-06', '+44 7700 900752'), --16
(35, 1, 17, 'password17', 'Lei', 'Lam', '1987-05-07', '+44 7700 900905'), --17
(36, 1, 18, 'password18', 'Jun', 'Lo', '1987-06-08', '+44 7700 900529'), --18
(37, 1, 19, 'password19', 'Yang', 'Zeng', '1987-07-09', '+44 7700 900220'), --19
(38, 1, 20, 'password20', 'Yong', 'Ze', '1987-08-10', '+44 7700 900563'), --20
(39, 1, 21, 'password21', 'Yong', 'Sung', '1987-09-11', '+44 7700 900464'), --21
(40, 1, 22, 'password22', 'Yan', 'Dang', '1987-10-12', '+44 7700 900636'), --22
(41, 1, 23, 'password23', 'Tao', 'Teng', '1987-11-13', '+44 7700 900588'), --23
(42, 1, 24, 'password24', 'Ming', 'To', '1987-12-14', '+44 7700 900300'), --24
(43, 1, 25, 'password25', 'Juan', 'Hai', '1987-01-15', '+44 7700 900513'), --25
(44, 1, 26, 'password26', 'Jie', 'Kyo', '1987-02-16', '+44 7700 900665'), --26
(45, 1, 27, 'password27', 'Xia', 'Deung', '1987-03-17', '+44 7700 900705'), --27
(46, 1, 28, 'password28', 'Gang', 'To', '1987-04-18', '+44 7700 900932'), --28
(47, 1, 29, 'password29', 'Ping', 'Tengco', '1987-05-19', '+44 7700 900472'), --29
(48, 2, 1, 'password30', 'Asahi', 'Abe', '1975-01-15', '+44 7700 000001'), --30 --here
(49, 2, 2, 'password31', 'Haru', 'Abiko', '1975-02-16', '+44 7700 000002'), --31
(50, 2, 3, 'password32', 'Akio', 'Abhuraya', '1975-03-17', '+44 7700 000003'), --32
(51, 2, 4, 'password33', 'Haruto', 'Adachi', '1975-04-18', '+44 7700 000004'), --33
(52, 2, 5, 'password34', 'Akira', 'Adachihara', '1975-05-19', '+44 7700 000005'), --34
(53, 2, 6, 'password35', 'Hinata', 'Agawa', '1975-06-20', '+44 7700 000006'), --35
(54, 2, 7, 'password36', 'Botan', 'Aguni', '1975-07-21', '+44 7700 000007'), --36
(55, 2, 8, 'password37', 'Hiroto', 'Ahane', '1975-08-22', '+44 7700 000008'), --37
(56, 2, 9, 'password38', 'Fuji', 'Aikawa', '1975-09-23', '+44 7700 000009'), --38
(57, 2, 10, 'password39', 'Itsuki', 'Aoki', '1975-10-24', '+44 7700 000010'), --39
(58, 2, 11, 'password40', 'Hiroshi', 'Aiuchi', '1975-11-25', '+44 7700 000011'), --40
(59, 2, 12, 'password41', 'Kaito', 'Amamiya', '1975-12-26', '+44 7700 000012'), --41
(60, 2, 13, 'password42', 'Jiro', 'Baba', '1975-01-27', '+44 7700 000013'), --42
(61, 2, 14, 'password43', 'Minato', 'Bando', '1975-02-28', '+44 7700 000014'), --43
(62, 2, 15, 'password44', 'Kenji', 'Bushida', '1975-03-29', '+44 7700 000015'), --44
(63, 2, 16, 'password45', 'Ren', 'Chiba', '1975-04-01', '+44 7700 000016'), --45
(64, 2, 17, 'password46', 'Kiyoshi', 'Chibana', '1975-05-02', '+44 7700 000017'), --46
(65, 2, 18, 'password47', 'Riku', 'Chisaka', '1975-06-03', '+44 7700 000018'), --47
(66, 2, 19, 'password48', 'Ichiro', 'Chinen', '1975-07-04', '+44 7700 000019'), --48
(67, 2, 20, 'password49', 'Souta', 'Daguchi', '1975-08-05', '+44 7700 000020'), --49
(68, 2, 21, 'password50', 'Aoki', 'Daigo', '1975-09-06', '+44 7700 000021'), --50
(69, 2, 22, 'password51', 'Sana', 'Date', '1975-10-07', '+44 7700 000022'), --51
(70, 2, 23, 'password52', 'Yuki', 'Matsumoto', '1997-03-13', '+44 7151 494259'), --52
(71, 2, 24, 'password53', 'Sakura', 'Yamaguchi', '1998-02-14', '+44 7700 138011'), --53
(72, 2, 25, 'password54', 'Makoto', 'Sasaki', '1999-01-15', '+44 7911 047351'), --54
(73, 2, 26, 'password55', 'Mai', 'Yoshida', '2000-12-16', '+44 7457 109021'), --55
(74, 2, 27, 'password56', 'Kenzo', 'Yamada', '1990-11-17', '+44 7502 267515'), --56
(75, 2, 28, 'password57', 'Keiko', 'Kato', '1991-10-18', '+44 7568 960607'), --57
(76, 2, 29, 'password58', 'Isamu', 'Yamamoto', '1992-09-19', '+44 7450 611544'), --58
(77, 3, 1, 'password59', 'Hiroshi', 'Kobayashi', '1993-08-20', '+44 7700 065056'), --59 --here
(78, 3, 2, 'password60', 'Hiroko', 'Nakamura', '1994-07-21', '+44 7700 170737'), --60
(79, 3, 3, 'password61', 'Hana', 'Ito', '1995-06-22', '+44 7527 941268'), --61
(80, 3, 4, 'password62', 'Emiko', 'Watanabe', '1996-05-23', '+44 7700 081750'), --62
(81, 3, 5, 'password63', 'Daiki', 'Tanaka', '1997-04-24', '+44 7700 050628'), --63
(82, 3, 6, 'password64', 'Chiyo', 'Takahashi', '1998-03-25', '+44 7911 843679'), --64
(83, 3, 7, 'password65', 'Asahi', 'Suzuki', '1999-02-26', '+44 7457 834101'), --65
(84, 3, 8, 'password66', 'Ai', 'Sato', '2000-01-27', '+44 7457 188038'), --66
(85, 3, 9, 'password67', 'Pheonix', 'Jung', '1994-09-30', '+44 7116 040128'), --67
(86, 3, 10, 'password68', 'Benjamin', 'Yun', '1993-08-29', '+44 7911 071634'), --68
(87, 3, 11, 'password69', 'Charlie', 'Cho', '1992-07-28', '+44 7911 868063'), --69
(88, 3, 12, 'password70', 'Megan', 'Choi', '1991-06-27', '+44 7149 090892'), --70
(89, 3, 13, 'password71', 'Lily', 'Kim', '1990-05-26', '+44 7130 561331'), --71
(90, 3, 14, 'password72', 'Sophie', 'Sung', '1989-04-25', '+44 7438 379111'), --72
(91, 3, 15, 'password73', 'Serina', 'Zhou', '1988-03-24', '+44 7911 087658'), --73
(92, 3, 16, 'password74', 'Marcus', 'Wu', '1987-02-23', '+44 7457 535602'), --74
(93, 3, 17, 'password75', 'Don', 'Zhao', '1986-01-22', '+44 7128 961695'), --75
(94, 3, 18, 'password76', 'Chris', 'Huang', '1985-12-21', '+44 7251 078340'), --76
(95, 3, 19, 'password77', 'Jack', 'Yang', '1984-11-20', '+44 7700 065368'), --77
(96, 3, 20, 'password78', 'Oliver', 'Chen', '1983-10-19', '+44 7399 593441'), --78
(97, 3, 21, 'password79', 'Robert', 'Liu', '1982-09-18', '+44 7455 273211'), --79
(98, 3, 22, 'password80', 'Simon', 'Zhang', '1981-08-17', '+44 7700 106905'), --80
(99, 3, 23, 'password81', 'Chase', 'Wang', '1980-07-16', '+44 7700 036784'), --81
(100, 3, 24, 'password82', 'Ross', 'Bob', '1979-06-15', '+44 7530 564682'), --82
(101, 3, 25, 'password83', 'Bob', 'Ross', '1978-05-14', '+44 7911 263170'), --83
(102, 3, 26, 'password84', 'Dolly', 'Long', '1977-04-13', '+44 7700 035056'), --84
(103, 3, 27, 'password85', 'Molly', 'Lee', '1976-03-12', '+44 7911 257623'), --85
(104, 3, 28, 'password86', 'Johnny', 'Yip', '1975-02-11', '+44 7448 610099'), --86
(105, 3, 29, 'password87', 'Jimmy', 'Yany', '1974-01-10', '+44 7184 978346'); --87




INSERT INTO BOOKING (cust_id, package_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 1),
(7, 3),
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



/*--------------------------*/
/*----------Views----------*/
/*--------------------------*/


/*--------------------------*/
/*---------Queries---------*/
/*--------------------------*/

-- Best Performing Package
SELECT
  b.package_id AS "Package Number",
  COUNT(b.package_id) AS "Most Popular Package"
FROM BOOKING b
GROUP BY b.package_id
ORDER BY "Most Popular Package" DESC
LIMIT 1;
--  Planning Time: 0.090 ms
--  Execution Time: 0.067 ms
-- changed line 434 from ((7, 2),) to (7, 3), ---- if issues happen change back but this was done so that there is a best performing package since they where all 2;

-- Details about a specific booking
SELECT
  (
    SELECT 
      CONCAT(c.cust_email, ' | ', c.cust_phoneNum) 
    FROM CUSTOMER c
    WHERE c.cust_id = b.cust_id) AS "Customer Contacts",
  b.package_id AS "Package Number",
  CONCAT(p.package_start, ' - ', p.package_end) AS "Package Time Frame",
  (
    SELECT
      CONCAT(f.flight_date, ' at ', f.flight_boarding, ' - ', f.flight_locationStart, ' to ', f.flight_locationEnd)
    FROM FLIGHT f
    WHERE f.flight_id = p.flight_id
  ) AS "Flight Information",
  (
  SELECT 
    h.hotel_name 
  FROM HOTEL h
  WHERE h.hotel_id = p.hotel_id
  ) AS "Hotel"
FROM BOOKING b
INNER JOIN PACKAGE p ON b.package_id = p.package_id
WHERE b.booking_id = 3;
--  Planning Time: 0.284 ms
--  Execution Time: 0.115 ms

