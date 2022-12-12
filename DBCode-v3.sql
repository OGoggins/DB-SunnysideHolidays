createuser -P -s -e dbadmin;
-- Password: password00
createdb dbadmin -O "dbadmin";
psql -h localhost -p 5432 -U dbadmin;

/* Or
CREATE USER dbadmin WITH SUPERUSER PASSWORD "password00";
CREATE DATABASE dbadmin OWNER dbadmin;
*/

DROP DATABASE SUNNYSIDE;
CREATE DATABASE SUNNYSIDE;
GRANT ALL PRIVILEGES ON DATABASE sunnyside TO dbadmin; 
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
/*---------INDEXES----------*/
/*--------------------------*/
CREATE INDEX cust_email_idx ON CUSTOMER(cust_email);
CREATE INDEX branch_name_idx ON BRANCH(branch_name);

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

INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('11 Stoneleigh Place', 'Suite 127', 'Oxford', 'OX10 6PT');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('12 Buckfast Street', null, 'Oxford', 'OX45 3AF');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('13 Abbots Place', null, 'London', 'NW5 9HX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('14 Abbotswell Road', 'Suite 63', 'London', 'NW12 4SE');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('15 Herald Street', null, 'Portsmouth', 'PO60 6HW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('16 Hazel Grove', 'Suite 97', 'Portsmouth', 'PO15 7JE');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('17 Corn Street', 'Suite 965', 'Oxford', 'OX20 3RA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Benhill Road', null, 'Oxford', 'OX3 1NA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('13 Castle Road', 'Suite 12', 'Oxford', 'OX33 1SP');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Lapton Road', null, 'Oxford', 'OX10 1EA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('12 Belgrave Road', null, 'Portsmouth', 'PO38 1JJ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('13 Shirrell Heath', null, 'Southampton', 'SO32 2JY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('13 Umm Suqeim 3', null, 'Dubai', '21936');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('14 Crescent Rd - The Palm Jumeirah', null, 'Dubai', '29406');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('15 C. de Velázquez', null, 'Madrid', '28001');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('63 Springfield Road', null, 'Cambridge', 'CB60 5DF');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('46 School Lane', null, 'Sunderland', 'SR32 8FV');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('62 The Grove', null, 'Liverpool', 'LP68 3DY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('1 Stanhope Cottages', null, 'Porstmouth', 'PO10 6XQ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('2 Heywood Moorings', null, 'Porstmouth', 'PO24 4LA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('3 Ruskin Circus', null, 'Porstmouth', 'PO4 2SG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('4 Oval Road South', null, 'Porstmouth', 'PO16 9AW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('5 Academy Las', null, 'Porstmouth', 'PO42 1ZW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('6 Madeira Barton', null, 'Porstmouth', 'PO3 8LT');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Francis Laurels', null, 'Porstmouth', 'PO38 0XX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Sidney Meadows', null, 'Portsmouth', 'PO2 4JP');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Elmtree Close', null, 'Portsmouth', 'PO19 8PN');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Aspen Ridgeway', null, 'Portsmouth', 'PO8 9NN');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Curtis Gait', null, 'Portsmouth', 'PO14 5EW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Curtis By-Pass', null, 'Portsmouth', 'PO3 0EP');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Long Passage', null, 'Portsmouth', 'PO1 4AR');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Jade Row', null, 'Portsmouth', 'PO2 5BS');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Prospect Route', null, 'Portsmouth', 'PO3 6CT');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Canal Avenue', null, 'Portsmouth', 'PO4 7DU');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 New Castle Way', null, 'Portsmouth', 'PO5 8EV');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Liberty Street', null, 'Portsmouth', 'PO6 9FW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Central Street', null, 'Portsmouth', 'PO7 1GX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Arctic Street', null, 'Portsmouth', 'PO8 2HY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Ember Row', null, 'Portsmouth', 'PO9 3IZ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Tower Boulevard', null, 'Portsmouth', 'PO10 4JA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 General Street', null, 'Portsmouth', 'PO11 5KB');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Medieval Row', null, 'Portsmouth', 'PO12 6LC');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Crown Avenue', null, 'Portsmouth', 'PO13 7MD');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Azure Street', null, 'Portsmouth', 'PO14 8NE');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Green Avenue', null, 'Portsmouth', 'PO15 9OF');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Congress Way', null, 'Portsmouth', 'PO16 1PG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Elmwood Row', null, 'Portsmouth', 'PO17 2QH');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('7 Laburnum Covert', null, 'Oxford', 'OX16 6SN');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('8 Northanger Drive', null, 'Oxford', 'OX67 8RW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('9 Raleigh Avenue', null, 'Oxford', 'OX2N 6AS');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('10 Middlefield Crescent', null, 'Oxford', 'OX2 2EG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('11 Stoneyfields', null, 'Oxford', 'OX4 1BA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('12 Brooklands Downs', null, 'Oxford', 'OX5 3NQ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('20 Union North', null, 'Oxford', 'OX30 9QG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Harebell Heights', null, 'Oxford', 'OX15 5FY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Morley Close', null, 'Oxford', 'OX31 2XD');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Aylesbury Promenade', null, 'Oxford', 'OX16 6EQ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Hanbury Square', null, 'Oxford', 'OX7 8SQ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Greenwood Lawn', null, 'Oxford', 'OX6 5JY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Starlight Avenue', null, 'Oxford', 'OX1 4AR');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Acorn Avenue', null, 'Oxford', 'OX2 5BS');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Flint Passage', null, 'Oxford', 'OX3 6CT');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Palm Avenue', null, 'Oxford', 'OX4 7DU');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Lily Lane', null, 'Oxford', 'OX5 8EV');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Museum Avenue', null, 'Oxford', 'OX6 9FW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Polygon Lane', null, 'Oxford', 'OX7 1GX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Mandarin Street', null, 'Oxford', 'OX8 2HY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Luna Route', null, 'Oxford', 'OX9 3IZ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Duchess Way', null, 'Oxford', 'OX0 4JA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Rose Lane', null, 'Oxford', 'OX1 5KB');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Feathers Boulevard', null, 'Oxford', 'OX2 6LC');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Gold Way', null, 'Oxford', 'OX3 7MD');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Storm Avenue', null, 'Oxford', 'OX4 8NE');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Noble Boulevard', null, 'Oxford', 'OX5 9OF');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Bay Lane', null, 'Oxford', 'OX6 1PG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Congress Boulevard', null, 'Oxford', 'OX7 2QH');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('13 Leven Fairway', null, 'London', 'NW14 8QH');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('14 Madeira Circus', null, 'London', 'NW7 6PH');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('15 Kensington Circle', null, 'London', 'NW2 4EN');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('16 Hanson Dene', null, 'London', 'NW6 0BX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('17 Blake Acre', null, 'London', 'NW1 3EX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Atlas Corner', null, 'London', 'NW2 8PH');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('21 Woods Mill', null, 'London', 'NW7 7LN');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Union Oaks', null, 'London', 'NW7 6QT');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Bloomfield Mead', null, 'London', 'NW20 6AG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Beresford Court', null, 'London', 'NW3 2DF');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Watling Buildings', null, 'London', 'NW3 9TX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('18 Douglas Path', null, 'London', 'NW5 5BU');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Snowflake Boulevard', null, 'London', 'NW7 2QH');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Arctic Avenue', null, 'London', 'NW6 1PG');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Hazelnut Street', null, 'London', 'NW5 9OF');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Middle Lane', null, 'London', 'NW4 8NE');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Gem Street', null, 'London', 'NW3 7MD');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Rosemary Avenue', null, 'London', 'NW2 6LC');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Broom Row', null, 'London', 'NW1 5KB');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Cavern Passage', null, 'London', 'NW0 4JA');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Orchid Street', null, 'London', 'NW9 3IZ');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Low Avenue', null, 'London', 'NW8 2HY');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Clarity Lane', null, 'London', 'NW7 1GX');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Bard Boulevard', null, 'London', 'NW6 9FW');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Congress Street', null, 'London', 'NW5 8EV');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Plaza Route', null, 'London', 'NW4 7DU');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Valley Avenue', null, 'London', 'NW3 6CT');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Orchid Avenue', null, 'London', 'NW2 5BS');
INSERT INTO ADDRESS (address_line1, address_line2, address_city, address_postcode) VALUES ('19 Crystal Street', null, 'London', 'NW1 4AR');

INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (1, 'James', 'Smith', '1984-01-10', '+44 7457 471053', 'jamessmith@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (2, 'Micheal', 'Lee', '1983-02-11', '+44 7700 036373' , 'micheallee@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (3, 'Robert', 'Micheals', '1985-03-12', '+44 7700 132081' , 'robertmicheals@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (4, 'Maria', 'Garcia', '1999-04-13', '+44 7501 029740' , 'mariagarcia@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (5, 'David', 'Laid', '1992-05-14', '+44 7448 689182' , 'davidlaid@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (6, 'Maria', 'Rodriguez', '1988-06-15', '+44 7457 248442' , 'mariarodriguez@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (7, 'Mary', 'Johnson', '1974-07-16', '+44 7911 804766' , 'maryjohnson@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (8, 'Johnny', 'Bob', '1986-08-17', '+44 7260 070448' , 'johnnybob@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (9, 'Timmy', 'Dock', '1985-07-20', '+44 7272 072348' , 'timmydock@gmail.com');
INSERT INTO CUSTOMER (address_id, cust_fname, cust_lname, cust_dob, cust_phoneNum, cust_email) VALUES (10, 'Loudred', 'Smock', '1984-06-25', '+44 7235 072348' , 'lourdredsmock@gmail.com');

INSERT INTO HOTEL (hotel_name, address_id, hotel_rating, hotel_country, hotel_phoneNum, hotel_totalRooms) VALUES ('Royal Hotel', 11, 3, 'FR', '01983 852186', 300);
INSERT INTO HOTEL (hotel_name, address_id, hotel_rating, hotel_country, hotel_phoneNum, hotel_totalRooms) VALUES ('New Place Hotel', 12, 3, 'FR', '01329 833543', 200);
INSERT INTO HOTEL (hotel_name, address_id, hotel_rating, hotel_country, hotel_phoneNum, hotel_totalRooms) VALUES ('Burj Al Arab', 13, 6, 'AE', '+971 4 301 7777', 500);
INSERT INTO HOTEL (hotel_name, address_id, hotel_rating, hotel_country, hotel_phoneNum, hotel_totalRooms) VALUES ('Atlantis Palms', 14, 5, 'AE', '+971 4 426 2000', 500);
INSERT INTO HOTEL (hotel_name, address_id, hotel_rating, hotel_country, hotel_phoneNum, hotel_totalRooms) VALUES ('Bless Hotel', 15, 4, 'ES', '+34 915 75 28 00', 400);

INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (1, 'Single Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (1, 'Double Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (1, 'Family Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (2, 'Single Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (2, 'Double Room', 50);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (2, 'Family Room', 50);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (3, 'Single Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (3, 'Double Room', 200);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (3, 'Family Room', 200);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (4, 'Single Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (4, 'Double Room', 300);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (4, 'Family Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (5, 'Single Room', 100);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (5, 'Double Room', 200);
INSERT INTO ROOM (hotel_id, room_type, room_numOfRoomType) VALUES (5, 'Family Room', 100);

INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Free Wifi', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Breakfast', '08:30am - 11:30am free breakfast');
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Lunch' , '12:00pm - 16:30pm free lunch');
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Supper' , '17:00am - 22:00am free supper');
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Free Parking', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Indoor Pool', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Outdoor Pool', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Laundry Service', 'Washing machines and tumble dryers, must provide own cleaning products');
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Air Conditioned', 'Rooms contain built-in air conditioning');
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Single Bed', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('King-sized Bed', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('King-sized + Single Bed', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Kettle', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Television', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Desk + Desk Chair', null);
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Couch', '2 person couch');
INSERT INTO AMENITIES (amenities_name, amenities_desc) VALUES ('Bathroom', 'Contains toilet, shower, bath, sink, cupboard / storage');

INSERT INTO HOTEL_AMENITIES (hotel_id, amenities_id) VALUES
(1, 1), (1, 2), (1, 5), (2, 1), (2, 2), (2, 5), (2, 8),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), 
(3, 9), (4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), 
(4, 7), (4, 9), (5, 1), (5, 2), (5, 5), (5, 8);

INSERT INTO ROOM_AMENITIES (room_id, amenities_id) VALUES
(1, 10), (1, 13), (1, 17), (2, 11), (2, 13), (2, 17), (3, 12), (3, 13), (3, 17), (4, 10), (4, 13), 
(4, 17), (5, 11), (5, 13), (5, 17), (6, 12), (6, 13), (6, 17), (7, 11), (7, 13), (7, 14), (7, 15), 
(7, 16), (7, 17), (8, 11), (8, 13), (8, 14), (8, 15), (8, 16), (8, 17), (9, 12), (9, 13), (9, 14), 
(9, 15), (9, 16), (9, 17), (10, 11), (10, 13), (10, 14), (10, 15), (10, 16), (10, 17), (11, 11), 
(11, 13), (11, 14), (11, 15), (11, 16), (11, 17), (12, 12), (12, 13), (12, 14), (12, 15), (12, 16), 
(12, 17), (13, 10), (13, 13), (13, 17), (14, 11), (14, 13), (14, 17), (15, 12), (15, 13), (15, 17);

INSERT INTO FLIGHT (flight_locationStart, flight_locationEnd, flight_date, flight_boarding) VALUES ('UK', 'FR', '2023-01-11', '14:00:00');
INSERT INTO FLIGHT (flight_locationStart, flight_locationEnd, flight_date, flight_boarding) VALUES ('UK', 'FR', '2023-01-10', '20:00:00');
INSERT INTO FLIGHT (flight_locationStart, flight_locationEnd, flight_date, flight_boarding) VALUES ('UK', 'AE', '2023-01-09', '07:00:00');
INSERT INTO FLIGHT (flight_locationStart, flight_locationEnd, flight_date, flight_boarding) VALUES ('UK', 'AE', '2023-01-12', '12:00:00');
INSERT INTO FLIGHT (flight_locationStart, flight_locationEnd, flight_date, flight_boarding) VALUES ('UK', 'ES', '2023-01-08', '19:00:00');

INSERT INTO PACKAGE (flight_id, hotel_id, package_start, package_end, package_discount, package_carRented, package_pricePP) VALUES (1, 1, '2023-01-11', '2023-02-01', 0.0, 'false', 200.00);
INSERT INTO PACKAGE (flight_id, hotel_id, package_start, package_end, package_discount, package_carRented, package_pricePP) VALUES (2, 2, '2023-01-10', '2023-02-01', 20.0, 'true', 200.00);
INSERT INTO PACKAGE (flight_id, hotel_id, package_start, package_end, package_discount, package_carRented, package_pricePP) VALUES (3, 3, '2023-01-09', '2023-02-01', 0.0, 'true', 1250.00);
INSERT INTO PACKAGE (flight_id, hotel_id, package_start, package_end, package_discount, package_carRented, package_pricePP) VALUES (4, 4, '2023-01-12', '2023-02-01', 50.0, 'false', 1000.00);
INSERT INTO PACKAGE (flight_id, hotel_id, package_start, package_end, package_discount, package_carRented, package_pricePP) VALUES (5, 5, '2023-01-08', '2023-02-01', 0.0, 'false', 500.00);

INSERT INTO BRANCH (address_id, branch_name) VALUES (16, 'Sunnyside Cambridge');
INSERT INTO BRANCH (address_id, branch_name) VALUES (17, 'Sunnyside Sunderland');
INSERT INTO BRANCH (address_id, branch_name) VALUES (18, 'Sunnyside Liverpool');

INSERT INTO BRANCH_PACKAGE (package_id, branch_id) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1),
(1, 2), (2, 2), (3, 2), (4, 2), (5, 2),
(1, 3), (2, 3), (3, 3), (4, 3), (5, 3);

INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc) VALUES ('Administration', 'admin.sunnyside.ac.uk', 'Includes management and admin');
INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc) VALUES ('Research & Development', 'rd.sunnyside.ac.uk', 'Research to gather knowlegde to create new successful packages or improve exsisting packages');
INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc) VALUES ('Marketing & Sales', 'ms.sunnyside.ac.uk', 'Responsible for promoting and creating holiday package sales');
INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc) VALUES ('Human Resources', 'hr.sunnyside.ac.uk', 'Responsible for all things worker-related');
INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc) VALUES ('Customer Service', 'cs.sunnyside.ac.uk', 'Provide direct help, advice and service directly with customers');
INSERT INTO DEPARTMENT (dmpt_name, dmpt_emailSuffix, dmpt_desc) VALUES ('Accounting & Finance', 'af.sunnyside.ac.uk', 'Tracks revenues and expenses');

INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Branch Manager', 1, 120000.00, 'manages a specific branch');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Administration Manager', 1, 90000.00, 'manager of all administration');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior Administration Manager', 1, 80000.00, 'senior manager of all administration');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Admin', 1, 70000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('R&D Manager', 2, 60000.00, 'manager of all R&D');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('R&D Project Manager', 2, 55000.00, 'manager of a current R&D project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior R&D Project Manager', 2, 50000.00, 'senior manager of a current R&D project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('R&D Project Coordinator', 2, 45000.00, 'Coordinates current R&D project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('R&D', 2, 40000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Marketing & Sales Manager', 3, 60000.00, 'manager of all marketing and sales');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior Marketing Manager', 3, 55000.00, 'senior manager of all marketing');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior Sales Manager', 3, 55000.00, 'senior manager of all sales');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Marketing Project Manager', 3, 50000.00, 'manager of a current marketing project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Marketing Project Coordinator', 3, 45000.00, 'Coordinates current marketing project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Sales Project Manager', 3, 50000.00, 'manager of a current sales project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Sales Project Corrdinator', 3, 45000.00, 'Coordinates current sales project');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Marketing', 3, 40000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Sales', 3, 40000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('HR Manager', 4, 60000.00, 'manager of all human resources');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior HR Manager', 4, 55000.00, 'senior manager of all human resources');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('HR', 4, 40000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Customer Service Manager', 5, 60000.00, 'manager of all customer service');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior Customer Service Manager', 5, 55000.00, 'senior manager of all customer service');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Customer Experience', 5, 40000.00, 'looks and reviews previous customers experience');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Customer Advocate', 5, 40000.00, 'ensures customers opinions are properly reviewed and considered');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Accounting & Finance Manager', 6, 60000.00, 'manager of all Accountanting & Finance');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Senior Accounting & Finance Manager', 6, 55000.00, 'senior manager of all Accountanting & Finance');
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('General Accountant', 6, 50000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Tax Accountant', 6, 50000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Forensic Accountant', 6, 50000.00, null);
INSERT INTO ROLE (role_name, dmpt_id, role_annualSalary, role_desc) VALUES ('Bookkeeping', 6, 50000.00, null);

INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (19, 1, 1, 'password01', 'Li', 'Wang', '1987-01-20', '+44 7700 900685');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (20, 1, 2, 'password02', 'Wei', 'Li', '1987-02-21', '+44 7700 900051');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (21, 1, 3, 'password03', 'Fang', 'Zhang', '1987-03-22', '+44 7700 900154');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (22, 1, 4, 'password04', 'Wei', 'Cheung', '1987-04-23', '+44 7700 900565');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (23, 1, 5, 'password05', 'Xiuying', 'Teoh', '1987-05-24', '+44 7700 900807');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (24, 1, 6, 'password06', 'Xiuying', 'Chan', '1987-06-25', '+44 7700 900956');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (25, 1, 7, 'password07', 'Na', 'Yeung', '1987-07-26', '+44 7700 900398');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (26, 1, 8, 'password08', 'Xiuying', 'Wong', '1987-08-27', '+44 7700 900933');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (27, 1, 9, 'password09', 'Wei', 'Chiu', '1987-09-28', '+44 7700 900822');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (28, 1, 10, 'password10', 'Min', 'Ng', '1987-10-29', '+44 7700 900294');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (29, 1, 11, 'password11', 'Jing', 'Chow', '1987-11-01', '+44 7700 900798');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (30, 1, 12, 'password12', 'Li', 'Chao', '1987-12-02', '+44 7700 900723');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (31, 1, 13, 'password13', 'Qiang', 'Tsui', '1987-01-03', '+44 7700 900661');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (32, 1, 14, 'password14', 'Jing', 'Chu', '1987-02-04', '+44 7700 900044');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (33, 1, 15, 'password15', 'Min', 'Wu', '1987-03-05', '+44 7700 900477');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (34, 1, 16, 'password16', 'Min', 'Ho', '1987-04-06', '+44 7700 900752');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (35, 1, 17, 'password17', 'Lei', 'Lam', '1987-05-07', '+44 7700 900905');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (36, 1, 18, 'password18', 'Jun', 'Lo', '1987-06-08', '+44 7700 900529');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (37, 1, 19, 'password19', 'Yang', 'Zeng', '1987-07-09', '+44 7700 900220');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (38, 1, 20, 'password20', 'Yong', 'Ze', '1987-08-10', '+44 7700 900563');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (39, 1, 21, 'password21', 'Yong', 'Sung', '1987-09-11', '+44 7700 900464');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (40, 1, 22, 'password22', 'Yan', 'Dang', '1987-10-12', '+44 7700 900636');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (41, 1, 23, 'password23', 'Tao', 'Teng', '1987-11-13', '+44 7700 900588');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (42, 1, 24, 'password24', 'Ming', 'To', '1987-12-14', '+44 7700 900300');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (43, 1, 25, 'password25', 'Juan', 'Hai', '1987-01-15', '+44 7700 900513');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (44, 1, 26, 'password26', 'Jie', 'Kyo', '1987-02-16', '+44 7700 900665');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (45, 1, 27, 'password27', 'Xia', 'Deung', '1987-03-17', '+44 7700 900705');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (46, 1, 28, 'password28', 'Gang', 'To', '1987-04-18', '+44 7700 900932');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (47, 1, 29, 'password29', 'Ping', 'Tengco', '1987-05-19', '+44 7700 900472');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (48, 2, 1, 'password30', 'Asahi', 'Abe', '1975-01-15', '+44 7700 000001');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (49, 2, 2, 'password31', 'Haru', 'Abiko', '1975-02-16', '+44 7700 000002');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (50, 2, 3, 'password32', 'Akio', 'Abhuraya', '1975-03-17', '+44 7700 000003');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (51, 2, 4, 'password33', 'Haruto', 'Adachi', '1975-04-18', '+44 7700 000004');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (52, 2, 5, 'password34', 'Akira', 'Adachihara', '1975-05-19', '+44 7700 000005');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (53, 2, 6, 'password35', 'Hinata', 'Agawa', '1975-06-20', '+44 7700 000006');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (54, 2, 7, 'password36', 'Botan', 'Aguni', '1975-07-21', '+44 7700 000007');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (55, 2, 8, 'password37', 'Hiroto', 'Ahane', '1975-08-22', '+44 7700 000008');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (56, 2, 9, 'password38', 'Fuji', 'Aikawa', '1975-09-23', '+44 7700 000009');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (57, 2, 10, 'password39', 'Itsuki', 'Aoki', '1975-10-24', '+44 7700 000010');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (58, 2, 11, 'password40', 'Hiroshi', 'Aiuchi', '1975-11-25', '+44 7700 000011');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (59, 2, 12, 'password41', 'Kaito', 'Amamiya', '1975-12-26', '+44 7700 000012');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (60, 2, 13, 'password42', 'Jiro', 'Baba', '1975-01-27', '+44 7700 000013');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (61, 2, 14, 'password43', 'Minato', 'Bando', '1975-02-28', '+44 7700 000014');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (62, 2, 15, 'password44', 'Kenji', 'Bushida', '1975-03-29', '+44 7700 000015');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (63, 2, 16, 'password45', 'Ren', 'Chiba', '1975-04-01', '+44 7700 000016');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (64, 2, 17, 'password46', 'Kiyoshi', 'Chibana', '1975-05-02', '+44 7700 000017');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (65, 2, 18, 'password47', 'Riku', 'Chisaka', '1975-06-03', '+44 7700 000018');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (66, 2, 19, 'password48', 'Ichiro', 'Chinen', '1975-07-04', '+44 7700 000019');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (67, 2, 20, 'password49', 'Souta', 'Daguchi', '1975-08-05', '+44 7700 000020');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (68, 2, 21, 'password50', 'Aoki', 'Daigo', '1975-09-06', '+44 7700 000021');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (69, 2, 22, 'password51', 'Sana', 'Date', '1975-10-07', '+44 7700 000022');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (70, 2, 23, 'password52', 'Yuki', 'Matsumoto', '1997-03-13', '+44 7151 494259');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (71, 2, 24, 'password53', 'Sakura', 'Yamaguchi', '1998-02-14', '+44 7700 138011');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (72, 2, 25, 'password54', 'Makoto', 'Sasaki', '1999-01-15', '+44 7911 047351');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (73, 2, 26, 'password55', 'Mai', 'Yoshida', '2000-12-16', '+44 7457 109021');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (74, 2, 27, 'password56', 'Kenzo', 'Yamada', '1990-11-17', '+44 7502 267515');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (75, 2, 28, 'password57', 'Keiko', 'Kato', '1991-10-18', '+44 7568 960607');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (76, 2, 29, 'password58', 'Isamu', 'Yamamoto', '1992-09-19', '+44 7450 611544');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (77, 3, 1, 'password59', 'Hiroshi', 'Kobayashi', '1993-08-20', '+44 7700 065056');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (78, 3, 2, 'password60', 'Hiroko', 'Nakamura', '1994-07-21', '+44 7700 170737');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (79, 3, 3, 'password61', 'Hana', 'Ito', '1995-06-22', '+44 7527 941268');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (80, 3, 4, 'password62', 'Emiko', 'Watanabe', '1996-05-23', '+44 7700 081750');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (81, 3, 5, 'password63', 'Daiki', 'Tanaka', '1997-04-24', '+44 7700 050628');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (82, 3, 6, 'password64', 'Chiyo', 'Takahashi', '1998-03-25', '+44 7911 843679');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (83, 3, 7, 'password65', 'Asahi', 'Suzuki', '1999-02-26', '+44 7457 834101');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (84, 3, 8, 'password66', 'Ai', 'Sato', '2000-01-27', '+44 7457 188038');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (85, 3, 9, 'password67', 'Pheonix', 'Jung', '1994-09-30', '+44 7116 040128');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (86, 3, 10, 'password68', 'Benjamin', 'Yun', '1993-08-29', '+44 7911 071634');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (87, 3, 11, 'password69', 'Charlie', 'Cho', '1992-07-28', '+44 7911 868063');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (88, 3, 12, 'password70', 'Megan', 'Choi', '1991-06-27', '+44 7149 090892');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (89, 3, 13, 'password71', 'Lily', 'Kim', '1990-05-26', '+44 7130 561331');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (90, 3, 14, 'password72', 'Sophie', 'Sung', '1989-04-25', '+44 7438 379111');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (91, 3, 15, 'password73', 'Serina', 'Zhou', '1988-03-24', '+44 7911 087658');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (92, 3, 16, 'password74', 'Marcus', 'Wu', '1987-02-23', '+44 7457 535602');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (93, 3, 17, 'password75', 'Don', 'Zhao', '1986-01-22', '+44 7128 961695');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (94, 3, 18, 'password76', 'Chris', 'Huang', '1985-12-21', '+44 7251 078340');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (95, 3, 19, 'password77', 'Jack', 'Yang', '1984-11-20', '+44 7700 065368');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (96, 3, 20, 'password78', 'Oliver', 'Chen', '1983-10-19', '+44 7399 593441');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (97, 3, 21, 'password79', 'Robert', 'Liu', '1982-09-18', '+44 7455 273211');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (98, 3, 22, 'password80', 'Simon', 'Zhang', '1981-08-17', '+44 7700 106905');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (99, 3, 23, 'password81', 'Chase', 'Wang', '1980-07-16', '+44 7700 036784');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (100, 3, 24, 'password82', 'Ross', 'Bob', '1979-06-15', '+44 7530 564682');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (101, 3, 25, 'password83', 'Bob', 'Ross', '1978-05-14', '+44 7911 263170');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (102, 3, 26, 'password84', 'Dolly', 'Long', '1977-04-13', '+44 7700 035056');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (103, 3, 27, 'password85', 'Molly', 'Lee', '1976-03-12', '+44 7911 257623');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (104, 3, 28, 'password86', 'Johnny', 'Yip', '1975-02-11', '+44 7448 610099');
INSERT INTO EMPLOYEE (address_id, branch_id, role_id, emp_password, emp_fname, emp_lname, emp_dob, emp_phoneNum) VALUES (105, 3, 29, 'password87', 'Jimmy', 'Yany', '1974-01-10', '+44 7184 978346');

INSERT INTO BOOKING (cust_id, package_id) VALUES (1, 1);
INSERT INTO BOOKING (cust_id, package_id) VALUES (2, 2);
INSERT INTO BOOKING (cust_id, package_id) VALUES (3, 3);
INSERT INTO BOOKING (cust_id, package_id) VALUES (4, 4);
INSERT INTO BOOKING (cust_id, package_id) VALUES (5, 5);
INSERT INTO BOOKING (cust_id, package_id) VALUES (6, 1);
INSERT INTO BOOKING (cust_id, package_id) VALUES (7, 3);
INSERT INTO BOOKING (cust_id, package_id) VALUES (8, 3);
INSERT INTO BOOKING (cust_id, package_id) VALUES (9, 4);
INSERT INTO BOOKING (cust_id, package_id) VALUES (10, 5);

INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (1, 'James', 'Smith', '1984-01-10');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (2, 'Micheal', 'Lee', '1983-02-11');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (2, 'Jennifer', 'Lee', '1983-07-01');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (3, 'Rob', 'Sung', '1984-02-02');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (3, 'Raquel', 'Sung', '1984-10-16');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (3, 'Charis', 'Sung', '2000-09-30');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (3, 'Cieran', 'Sung', '2003-07-03');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (4, 'Jimmy', 'Johns', '1980-02-18');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (4, 'Susan', 'Megans', '1982-07-19');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (4, 'Jimmy Jr.', 'Johns', '1999-11-10');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (5, 'David', 'Laid', '1992-05-14');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (6, 'Maria', 'Rodriguez', '1988-06-15');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (6, 'Elly', 'Smith', '1987-11-15');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (6, 'Margret', 'Fatcher', '1983-09-15');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (6, 'Sophie', 'Leeds', '1987-01-25');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (7, 'Mary', 'Johnson', '1974-07-16');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (7, 'Simon', 'Johnson', '1974-06-16');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (8, 'Johnny', 'Bob', '1986-08-17');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (9, 'Timmy', 'Dock', '1985-07-20');
INSERT INTO TRAVELLERS (booking_id, traveller_fname, traveller_lname, traveller_dob) VALUES (10, 'Loudred', 'Smock', '1984-06-25');

INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (1, 1, 100.00);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (1, 2, 200.00);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (2, 1, 400);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (3, 1, 1250);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (3, 2, 1250);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (3, 3, 1250);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (4, 1, 3000);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (5, 1, 50);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (5, 2, 50);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (5, 3, 50);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (5, 4, 50);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (5, 5, 50);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (5, 6, 50);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (6, 1, 200);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (6, 2, 200);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (7, 1, 400);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (8, 1, 1250);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (9, 1, 1000);
INSERT INTO INSTALMENTS (payment_id, instalments_number, instalments_amountPaid) VALUES (10, 1, 100);

/*--------------------------*/
/*---------QUERIES----------*/
/*--------------------------*/

-- QUERY 1: This shows the best performing package for the entire lifetime of the company. 
--          This is helpful to sales since they can know what package is the most likely to sell when pitched to a customer.

SELECT
  b.package_id AS "Package Number",
  COUNT(b.package_id) AS "Most Popular Package"
FROM BOOKING b
GROUP BY b.package_id
ORDER BY "Most Popular Package" DESC
LIMIT 1;

-- QUERY 2: The query shows key details about a specific booking. For instance package time frame along with flight and hotel information. 
--          This can be used for when a customer has placed an order on a holiday and needs to be reminded of key details.

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

-- QUERY 3: The query gives all employee information for a specific branch that a manager may need to access to find employee phone numbers or look at gaps in the workforce.

SELECT
  d.dmpt_name AS "Department",
  CONCAT(e.emp_fname, ' ', e.emp_lname) AS "Employee",
  r.role_name AS "Role",
  CONCAT(e.emp_id, '@', d.dmpt_emailSuffix) AS "Email Address",
  e.emp_phoneNum AS "Phone"
FROM EMPLOYEE e
INNER JOIN ROLE r USING (role_id)
INNER JOIN DEPARTMENT d USING (dmpt_id)
WHERE e.branch_id = (
  SELECT 
    b.branch_id 
  FROM BRANCH b 
  WHERE b.branch_name = 'Sunnyside Cambridge'
)
ORDER BY d.dmpt_name, e.emp_lname ASC;

-- QUERY 4: Package payment status, 
--          this query gives a way for the accounting and finance team of the company to monitor customer payments for a specific booking showing total price for that booking, current amount paid, amount remaining and the history of their payments.

SELECT
  CONCAT(cust.cust_email, ' | ', cust.cust_phoneNum) AS "Customer Contacts",
  b.booking_id AS "Booking ID",
  p.payment_id AS "Payment ID",
  (
    SELECT 
      COUNT(*) 
    FROM TRAVELLERS t 
    WHERE t.booking_id = b.booking_id
  ) AS "Number of Travellers",
  CONCAT('£', p.payment_totalPrice) AS "Total Price",
  CONCAT('£', p.payment_amountPaid) AS "Amount Paid",
  CASE
    WHEN p.payment_totalPrice - p.payment_amountPaid < 0 THEN 'N/A'
    ELSE CONCAT('£', p.payment_totalPrice - p.payment_amountPaid)
  END AS "Remaining",
  ARRAY_TO_STRING(
    ARRAY_AGG(
      CONCAT('Instalment-', i.instalments_number, ': ', '£', i.instalments_amountPaid)
    ), ', '
  ) AS "Payment History"
FROM BOOKING b
INNER JOIN CUSTOMER cust USING (cust_id)
INNER JOIN PAYMENT p USING (booking_id)
INNER JOIN INSTALMENTS i USING (payment_id)
WHERE cust.cust_email = 'robertmicheals@gmail.com'
GROUP BY 
  cust.cust_email, 
  cust.cust_phoneNum,
  b.booking_id,
  p.payment_id;


-- QUERY 5: For the final query it shows details about a specific package with key details such as cost, destination and time of leaving. 
--          This can help sales give accurate information to make sure the customer is well informed.

SELECT
  p.package_id AS "Package ID",
  CONCAT(p.package_start, ' - ', p.package_end) AS "Package Duration",
  CASE
    WHEN p.package_carRented THEN 'Yes'
    ELSE 'No'
  END AS "With Car",
  CONCAT('£', ROUND(p.package_pricePP * (1 - (p.package_discount / 100)), 2)) AS "Current Price Per Person",
  CONCAT(h.hotel_name, ' - ', a.address_city, ' - ', a.address_postcode) AS "Hotel",
  CONCAT(f.flight_locationStart, ' to ', f.flight_locationEnd) AS "Flight",
  CONCAT(f.flight_date, ' at ', f.flight_boarding) AS "Flight Time"
FROM PACKAGE p
INNER JOIN HOTEL h USING (hotel_id)
INNER JOIN FLIGHT f USING (flight_id)
INNER JOIN ADDRESS a USING (address_id)
WHERE p.package_id = 5;

/*--------------------------*/
/*----------VIEWS-----------*/
/*--------------------------*/

-- View for Query 1
CREATE VIEW best_package AS
SELECT  b.package_id        AS "Package Number",
        COUNT(b.package_id) AS "Most Popular Package"
FROM BOOKING b
GROUP BY  b.package_id
ORDER BY "Most Popular Package" DESC
LIMIT 1;

-- View for Query 2
CREATE VIEW booking_details AS
SELECT  (
          SELECT  CONCAT(c.cust_email,' | ',c.cust_phoneNum)
          FROM CUSTOMER c
          WHERE c.cust_id = b.cust_id
        )                                             AS "Customer Contacts", 
        b.package_id                                  AS "Package Number", 
        CONCAT(p.package_start, ' - ', p.package_end) AS "Package Time Frame", 
        (
          SELECT  CONCAT(f.flight_date,' at ',f.flight_boarding,' - ',f.flight_locationStart,' to ',f.flight_locationEnd)
          FROM FLIGHT f
          WHERE f.flight_id = p.flight_id 
        )                                             AS "Flight Information", 
        (
          SELECT  h.hotel_name
          FROM HOTEL h
          WHERE h.hotel_id = p.hotel_id 
        )                                             AS "Hotel"
FROM BOOKING b
INNER JOIN PACKAGE p ON b.package_id = p.package_id
WHERE b.booking_id = 3; 

-- View for Query 3
CREATE VIEW cbg_employee_info AS
SELECT  d.dmpt_name                             AS "Department",
        CONCAT(e.emp_fname,' ',e.emp_lname)     AS "Employee",
        r.role_name                             AS "Role",
        CONCAT(e.emp_id,'@',d.dmpt_emailSuffix) AS "Email Address",
        e.emp_phoneNum                          AS "Phone"
FROM EMPLOYEE e
INNER JOIN ROLE r USING (role_id)
INNER JOIN DEPARTMENT d USING (dmpt_id)
WHERE e.branch_id = (
  SELECT  b.branch_id
  FROM BRANCH b
  WHERE b.branch_name = 'Sunnyside Cambridge' 
)
ORDER BY d.dmpt_name, e.emp_lname ASC;

-- View for Query 4
CREATE VIEW package_payment_status AS
SELECT  CONCAT(cust.cust_email,' | ',cust.cust_phoneNum)                                                                       AS "Customer Contacts",
        b.booking_id                                                                                                           AS "Booking ID",
        p.payment_id                                                                                                           AS "Payment ID",
        (
          SELECT  COUNT(*)
          FROM TRAVELLERS t
          WHERE t.booking_id = b.booking_id 
        )                                                                                                                      AS "Number of Travellers", 
        CONCAT('£', p.payment_totalPrice)                                                                                      AS "Total Price",
        CONCAT('£', p.payment_amountPaid)                                                                                      AS "Amount Paid",
        CASE 
          WHEN p.payment_totalPrice - p.payment_amountPaid < 0 THEN 'N/A' 
          ELSE CONCAT('£', p.payment_totalPrice - p.payment_amountPaid) 
        END                                                                                                                    AS "Remaining", 
        ARRAY_TO_STRING( ARRAY_AGG( CONCAT('Instalment-', i.instalments_number, ': ', '£', i.instalments_amountPaid) ), ', ' ) AS "Payment History"
FROM BOOKING b
INNER JOIN CUSTOMER cust USING (cust_id)
INNER JOIN PAYMENT p USING (booking_id)
INNER JOIN INSTALMENTS i USING (payment_id)
WHERE cust.cust_email = 'robertmicheals@gmail.com'
GROUP BY  cust.cust_email,
          cust.cust_phoneNum,
          b.booking_id,
          p.payment_id;

-- View for Query 5
CREATE VIEW package_details AS
SELECT  p.package_id                                                              AS "Package ID",
        CONCAT(p.package_start,' - ',p.package_end)                               AS "Package Duration",
        CASE 
          WHEN p.package_carRented THEN 'Yes'  
          ELSE 'No' 
        END                                                                       AS "With Car",
        CONCAT('£',ROUND(p.package_pricePP * (1 - (p.package_discount / 100)),2)) AS "Current Price Per Person",
        CONCAT(h.hotel_name,' - ',a.address_city,' - ',a.address_postcode)        AS "Hotel",
        CONCAT(f.flight_locationStart,' to ',f.flight_locationEnd)                AS "Flight",
        CONCAT(f.flight_date,' at ',f.flight_boarding)                            AS "Flight Time"
FROM PACKAGE p
INNER JOIN HOTEL h USING (hotel_id)
INNER JOIN FLIGHT f USING (flight_id)
INNER JOIN ADDRESS a USING (address_id)
WHERE p.package_id = 5;

/*--------------------------*/
/*-----------ROLES----------*/
/*--------------------------*/

-- General Roles/Templates

CREATE USER manager WITH NOSUPERUSER NOCREATEDB CREATEROLE PASSWORD NULL;

CREATE USER employee WITH NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS PASSWORD NULL;

GRANT CREATE ON DATABASE sunnyside TO manager;

-- Groups
CREATE GROUP admin_managers WITH INHERIT IN ROLE manager;
CREATE GROUP admin_employees WITH INHERIT IN ROLE employee;
CREATE GROUP resdev_managers WITH INHERIT IN ROLE manager;
CREATE GROUP resdev_employees WITH INHERIT IN ROLE employee;
CREATE GROUP marketingsales_managers WITH INHERIT IN ROLE manager;
CREATE GROUP marketingsales_employees WITH INHERIT IN ROLE employee;
CREATE GROUP hr_managers WITH INHERIT IN ROLE manager;
CREATE GROUP hr_employees WITH INHERIT IN ROLE employee;
CREATE GROUP custservice_managers WITH INHERIT IN ROLE manager;
CREATE GROUP custservice_employees WITH INHERIT IN ROLE employee;
CREATE GROUP accountfinance_managers WITH INHERIT IN ROLE manager;
CREATE GROUP accountfinance_employees WITH INHERIT IN ROLE employee;


-- Privileges

GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO admin_managers;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO admin_employees;

GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BOOKING TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON PACKAGE TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BRANCH_PACKAGE TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BRANCH TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON HOTEL TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROOM TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROOM_AMENITIES TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON HOTEL_AMENITIES TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON AMENITIES TO resdev_managers;
GRANT SELECT, UPDATE, INSERT, DELETE ON BOOKING TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON PACKAGE TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON BRANCH_PACKAGE TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON BRANCH TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON HOTEL TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROOM TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROOM_AMENITIES TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON HOTEL_AMENITIES TO resdev_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON AMENITIES TO resdev_employees;

GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BOOKING TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON PACKAGE TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON HOTEL TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROOM TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROOM_AMENITIES TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON HOTEL_AMENITIES TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON AMENITIES TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON FLIGHT TO marketingsales_managers;
GRANT SELECT, UPDATE, INSERT, DELETE ON BOOKING TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON PACKAGE TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON HOTEL TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROOM TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROOM_AMENITIES TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON HOTEL_AMENITIES TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON AMENITIES TO marketingsales_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON FLIGHT TO marketingsales_employees;

GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON EMPLOYEE TO hr_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROLE TO hr_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON DEPARTMENT TO hr_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BRANCH TO hr_managers;
GRANT SELECT, UPDATE, INSERT, DELETE ON EMPLOYEE TO hr_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROLE TO hr_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON DEPARTMENT TO hr_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON BRANCH TO hr_employees;

GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BOOKING TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON PAYMENT TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON CUSTOMER TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON INSTALMENTS TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON TRAVELLERS TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ADDRESS TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON PACKAGE TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON HOTEL TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROOM TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROOM_AMENITIES TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON HOTEL_AMENITIES TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON AMENITIES TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON FLIGHT TO custservice_managers;
GRANT SELECT, UPDATE, INSERT, DELETE ON BOOKING TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON PAYMENT TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON CUSTOMER TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON INSTALMENTS TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON TRAVELLERS TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ADDRESS TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON PACKAGE TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON HOTEL TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROOM TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROOM_AMENITIES TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON HOTEL_AMENITIES TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON AMENITIES TO custservice_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON FLIGHT TO custservice_employees;

GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BOOKING TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON PAYMENT TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON CUSTOMER TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON INSTALMENTS TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON PACKAGE TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON EMPLOYEE TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON ROLE TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BRANCH TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON BRANCH_PACKAGE TO accountfinance_managers;
GRANT SELECT, UPDATE, INSERT, DELETE ON BOOKING TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON PAYMENT TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON CUSTOMER TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON INSTALMENTS TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON PACKAGE TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON EMPLOYEE TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON ROLE TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON BRANCH TO accountfinance_employees;
GRANT SELECT, UPDATE, INSERT, DELETE ON BRANCH_PACKAGE TO accountfinance_employees;

-- Users

CREATE USER lwang01 WITH INHERIT PASSWORD 'password01' IN ROLE admin_managers;
CREATE DATABASE lwang01 OWNER lwang01;
CREATE USER wli02 WITH INHERIT PASSWORD 'password02' IN ROLE admin_managers;
CREATE DATABASE wli02 OWNER wli02;
CREATE USER fzhang03 WITH INHERIT PASSWORD 'password03' IN ROLE admin_managers;
CREATE DATABASE fzhang03 OWNER fzhang03;
CREATE USER wcheung04 WITH INHERIT PASSWORD 'password04' IN ROLE admin_employees;
CREATE DATABASE wcheung04 OWNER wcheung04;
CREATE USER xteoh05 WITH INHERIT PASSWORD 'password05' IN ROLE resdev_managers;
CREATE DATABASE xteoh05 OWNER xteoh05;
CREATE USER xchan06 WITH INHERIT PASSWORD 'password06' IN ROLE resdev_managers;
CREATE DATABASE xchan06 OWNER xchan06;
CREATE USER nyeung07 WITH INHERIT PASSWORD 'password07' IN ROLE resdev_managers;
CREATE DATABASE nyeung07 OWNER nyeung07;
CREATE USER xwong8 WITH INHERIT PASSWORD 'password08' IN ROLE resdev_employees;
CREATE DATABASE xwong08 OWNER xwong08;
CREATE USER wchiu09 WITH INHERIT PASSWORD 'password09' IN ROLE resdev_employees;
CREATE DATABASE wchiu09 OWNER wchiu09;
CREATE USER mng10 WITH INHERIT PASSWORD 'password10' IN ROLE marketingsales_managers;
CREATE DATABASE mng10 OWNER mng10;
CREATE USER jchow11 WITH INHERIT PASSWORD 'password11' IN ROLE marketingsales_managers;
CREATE DATABASE jchow11 OWNER jchow11;
CREATE USER lchao12 WITH INHERIT PASSWORD 'password12' IN ROLE marketingsales_managers;
CREATE DATABASE lchao12 OWNER lchao12;
CREATE USER qtsui13 WITH INHERIT PASSWORD 'password13' IN ROLE marketingsales_managers;
CREATE DATABASE qtsui13 OWNER qtsui13;
CREATE USER jchu14 WITH INHERIT PASSWORD 'password14' IN ROLE marketingsales_employees;
CREATE DATABASE jchu14 OWNER jchu14;
CREATE USER mwu15 WITH INHERIT PASSWORD 'password15' IN ROLE marketingsales_managers;
CREATE DATABASE mwu15 OWNER mwu15;
CREATE USER mho16 WITH INHERIT PASSWORD 'password16' IN ROLE marketingsales_employees;
CREATE DATABASE mho16 OWNER mho16;
CREATE USER llam17 WITH INHERIT PASSWORD 'password17' IN ROLE marketingsales_employees;
CREATE DATABASE llam17 OWNER llam17;
CREATE USER jlo18 WITH INHERIT PASSWORD 'password18' IN ROLE marketingsales_employees;
CREATE DATABASE jlo18 OWNER jlo18;
CREATE USER yzeng19 WITH INHERIT PASSWORD 'password19' IN ROLE hr_managers;
CREATE DATABASE yzeng19 OWNER yzeng19;
CREATE USER yze20 WITH INHERIT PASSWORD 'password20' IN ROLE hr_managers;
CREATE DATABASE yze20 OWNER yze20;
CREATE USER ysung21 WITH INHERIT PASSWORD 'password21' IN ROLE hr_employees;
CREATE DATABASE ysung21 OWNER ysung21;
CREATE USER ydang22 WITH INHERIT PASSWORD 'password22' IN ROLE custservice_managers;
CREATE DATABASE ydang22 OWNER ydang22;
CREATE USER tteng23 WITH INHERIT PASSWORD 'password23' IN ROLE custservice_managers;
CREATE DATABASE tteng23 OWNER tteng23;
CREATE USER mto24 WITH INHERIT PASSWORD 'password24' IN ROLE custservice_employees;
CREATE DATABASE mto24 OWNER mto24;
CREATE USER jhai25 WITH INHERIT PASSWORD 'password25' IN ROLE custservice_employees;
CREATE DATABASE jhai25 OWNER jhai25;
CREATE USER jkyo26 WITH INHERIT PASSWORD 'password26' IN ROLE accountfinance_managers;
CREATE DATABASE jkyo26 OWNER jkyo26;
CREATE USER xdeung27 WITH INHERIT PASSWORD 'password27' IN ROLE accountfinance_managers;
CREATE DATABASE xdeung27 OWNER xdeung27;
CREATE USER gto28 WITH INHERIT PASSWORD 'password28' IN ROLE accountfinance_employees;
CREATE DATABASE gto28 OWNER gto28;
CREATE USER ptengco29 WITH INHERIT PASSWORD 'password29' IN ROLE accountfinance_employees;
CREATE DATABASE ptengco29 OWNER ptengco29;
CREATE USER aabe30 WITH INHERIT PASSWORD 'password30' IN ROLE admin_managers;
CREATE DATABASE aabe30 OWNER aabe30;
CREATE USER habiko31 WITH INHERIT PASSWORD 'password31' IN ROLE admin_managers;
CREATE DATABASE habiko31 OWNER habiko31;
CREATE USER aabhuraya32 WITH INHERIT PASSWORD 'password32' IN ROLE admin_managers;
CREATE DATABASE aabhuraya32 OWNER aabhuraya32;
CREATE USER hadachi33 WITH INHERIT PASSWORD 'password33' IN ROLE admin_employees;
CREATE DATABASE hadachi33 OWNER hadachi33;
CREATE USER aadachihara34 WITH INHERIT PASSWORD 'password34' IN ROLE resdev_managers;
CREATE DATABASE aadachihara34 OWNER aadachihara34;
CREATE USER hagawa35 WITH INHERIT PASSWORD 'password35' IN ROLE resdev_managers;
CREATE DATABASE hagawa35 OWNER hagawa35;
CREATE USER baguni36 WITH INHERIT PASSWORD 'password36' IN ROLE resdev_managers;
CREATE DATABASE baguni36 OWNER baguni36;
CREATE USER hahane37 WITH INHERIT PASSWORD 'password37' IN ROLE resdev_employees;
CREATE DATABASE hahane37 OWNER hahane37;
CREATE USER faikawa38 WITH INHERIT PASSWORD 'password38' IN ROLE resdev_employees;
CREATE DATABASE faikawa38 OWNER faikawa38;
CREATE USER iaoki39 WITH INHERIT PASSWORD 'password39' IN ROLE marketingsales_managers;
CREATE DATABASE iaoki39 OWNER iaoki39;
CREATE USER haiuchi40 WITH INHERIT PASSWORD 'password40' IN ROLE marketingsales_managers;
CREATE DATABASE haiuchi40 OWNER haiuchi40;
CREATE USER kamamiya41 WITH INHERIT PASSWORD 'password41' IN ROLE marketingsales_managers;
CREATE DATABASE kamamiya41 OWNER kamamiya41;
CREATE USER jbaba42 WITH INHERIT PASSWORD 'password42' IN ROLE marketingsales_managers;
CREATE DATABASE jbaba42 OWNER jbaba42;
CREATE USER mbando43 WITH INHERIT PASSWORD 'password43' IN ROLE marketingsales_employees;
CREATE DATABASE mbando43 OWNER mbando43;
CREATE USER kbushida44 WITH INHERIT PASSWORD 'password44' IN ROLE marketingsales_managers;
CREATE DATABASE kbushida44 OWNER kbushida44;
CREATE USER rchiba45 WITH INHERIT PASSWORD 'password45' IN ROLE marketingsales_employees;
CREATE DATABASE rchiba45 OWNER rchiba45;
CREATE USER kchibana46 WITH INHERIT PASSWORD 'password46' IN ROLE marketingsales_employees;
CREATE DATABASE kchibana46 OWNER kchibana46;
CREATE USER rchisaka47 WITH INHERIT PASSWORD 'password47' IN ROLE marketingsales_employees;
CREATE DATABASE rchisaka47 OWNER rchisaka47;
CREATE USER ichinen48 WITH INHERIT PASSWORD 'password48' IN ROLE hr_managers;
CREATE DATABASE ichinen48 OWNER ichinen48;
CREATE USER sdaguchi49 WITH INHERIT PASSWORD 'password49' IN ROLE hr_managers;
CREATE DATABASE sdaguchi49 OWNER sdaguchi49;
CREATE USER adaigo50 WITH INHERIT PASSWORD 'password50' IN ROLE hr_employees;
CREATE DATABASE adaigo50 OWNER adaigo50;
CREATE USER sdate51 WITH INHERIT PASSWORD 'password51' IN ROLE custservice_managers;
CREATE DATABASE sdate51 OWNER sdate51;
CREATE USER ymatsumoto52 WITH INHERIT PASSWORD 'password52' IN ROLE custservice_managers;
CREATE DATABASE ymatsumoto52 OWNER ymatsumoto52;
CREATE USER syamaguchi53 WITH INHERIT PASSWORD 'password53' IN ROLE custservice_employees;
CREATE DATABASE syamaguchi53 OWNER syamaguchi53;
CREATE USER msasaki54 WITH INHERIT PASSWORD 'password54' IN ROLE custservice_employees;
CREATE DATABASE msasaki54 OWNER msasaki54;
CREATE USER myoshida55 WITH INHERIT PASSWORD 'password55' IN ROLE accountfinance_managers;
CREATE DATABASE myoshida55 OWNER myoshida55;
CREATE USER kyamada56 WITH INHERIT PASSWORD 'password56' IN ROLE accountfinance_managers;
CREATE DATABASE kyamada56 OWNER kyamada56;
CREATE USER kkato57 WITH INHERIT PASSWORD 'password57' IN ROLE accountfinance_employees;
CREATE DATABASE kkato57 OWNER kkato57;
CREATE USER iyamamoto58 WITH INHERIT PASSWORD 'password58' IN ROLE accountfinance_employees;
CREATE DATABASE iyamamoto58 OWNER iyamamoto58;
CREATE USER hkobayashi59 WITH INHERIT PASSWORD 'password59' IN ROLE admin_managers;
CREATE DATABASE hkobayashi59 OWNER hkobayashi59;
CREATE USER hnakamura60 WITH INHERIT PASSWORD 'password60' IN ROLE admin_managers;
CREATE DATABASE hnakamura60 OWNER hnakamura60;
CREATE USER hito61 WITH INHERIT PASSWORD 'password61' IN ROLE admin_managers;
CREATE DATABASE hito61 OWNER hito61;
CREATE USER ewatanabe62 WITH INHERIT PASSWORD 'password62' IN ROLE admin_employees;
CREATE DATABASE ewatanabe62 OWNER ewatanabe62;
CREATE USER dtanaka63 WITH INHERIT PASSWORD 'password63' IN ROLE resdev_managers;
CREATE DATABASE dtanaka63 OWNER dtanaka63;
CREATE USER ctakahashi64 WITH INHERIT PASSWORD 'password64' IN ROLE resdev_managers;
CREATE DATABASE ctakahashi64 OWNER ctakahashi64;
CREATE USER asuzuki65 WITH INHERIT PASSWORD 'password65' IN ROLE resdev_managers;
CREATE DATABASE asuzuki65 OWNER asuzuki65;
CREATE USER asato66 WITH INHERIT PASSWORD 'password66' IN ROLE resdev_employees;
CREATE DATABASE asato66 OWNER asato66;
CREATE USER pjung67 WITH INHERIT PASSWORD 'password67' IN ROLE resdev_employees;
CREATE DATABASE pjung67 OWNER pjung67;
CREATE USER byun68 WITH INHERIT PASSWORD 'password68' IN ROLE marketingsales_managers;
CREATE DATABASE byun68 OWNER byun68;
CREATE USER ccho69 WITH INHERIT PASSWORD 'password69' IN ROLE marketingsales_managers;
CREATE DATABASE ccho69 OWNER ccho69;
CREATE USER mchoi70 WITH INHERIT PASSWORD 'password70' IN ROLE marketingsales_managers;
CREATE DATABASE mchoi70 OWNER mchoi70;
CREATE USER lkim71 WITH INHERIT PASSWORD 'password71' IN ROLE marketingsales_managers;
CREATE DATABASE lkim71 OWNER lkim71;
CREATE USER ssung72 WITH INHERIT PASSWORD 'password72' IN ROLE marketingsales_employees;
CREATE DATABASE ssung72 OWNER ssung72;
CREATE USER szhou73 WITH INHERIT PASSWORD 'password73' IN ROLE marketingsales_managers;
CREATE DATABASE szhou73 OWNER szhou73;
CREATE USER mwu74 WITH INHERIT PASSWORD 'password74' IN ROLE marketingsales_employees;
CREATE DATABASE mwu74 OWNER mwu74;
CREATE USER dzhao75 WITH INHERIT PASSWORD 'password75' IN ROLE marketingsales_employees;
CREATE DATABASE dzhao75 OWNER dzhao75;
CREATE USER chuang76 WITH INHERIT PASSWORD 'password76' IN ROLE marketingsales_employees;
CREATE DATABASE chuang76 OWNER chuang76;
CREATE USER jyang77 WITH INHERIT PASSWORD 'password77' IN ROLE hr_managers;
CREATE DATABASE jyang77 OWNER jyang77;
CREATE USER ochen78 WITH INHERIT PASSWORD 'password78' IN ROLE hr_managers;
CREATE DATABASE ochen78 OWNER ochen78;
CREATE USER rliu79 WITH INHERIT PASSWORD 'password79' IN ROLE hr_employees;
CREATE DATABASE rliu79 OWNER rliu79;
CREATE USER szhang80 WITH INHERIT PASSWORD 'password80' IN ROLE custservice_managers;
CREATE DATABASE szhang80 OWNER szhang80;
CREATE USER cwang81 WITH INHERIT PASSWORD 'password81' IN ROLE custservice_managers;
CREATE DATABASE cwang81 OWNER cwang81;
CREATE USER rbob82 WITH INHERIT PASSWORD 'password82' IN ROLE custservice_employees;
CREATE DATABASE rbob82 OWNER rbob82;
CREATE USER bross83 WITH INHERIT PASSWORD 'password83' IN ROLE custservice_employees;
CREATE DATABASE bross83 OWNER bross83;
CREATE USER dlong84 WITH INHERIT PASSWORD 'password84' IN ROLE accountfinance_managers;
CREATE DATABASE dlong84 OWNER dlong84;
CREATE USER mlee85 WITH INHERIT PASSWORD 'password85' IN ROLE accountfinance_managers;
CREATE DATABASE mlee85 OWNER mlee85;
CREATE USER jyip86 WITH INHERIT PASSWORD 'password86' IN ROLE accountfinance_employees;
CREATE DATABASE jyip86 OWNER jyip86;
CREATE USER jyany87 WITH INHERIT PASSWORD 'password87' IN ROLE accountfinance_employees;
CREATE DATABASE jyany87 OWNER jyany87;