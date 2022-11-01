CREATE DATABASE SunnySideHolidays;

\c SunnySideHolidays

CREATE TABLE HOTEL (
    ht_id SERIAL PRIMARY KEY,
    ht_name VARCHAR(50) NOT NULL,
    ht_rating CHAR(5) NOT NULL,
    ht_country CHAR(2) NOT NULL,
    ht_addressLine1 VARCHAR(150) NOT NULL,
    ht_city VARCHAR(50) NOT NULL,
    ht_postcode VARCHAR(8) NOT NULL,
    ht_phoneNum VARCHAR(20) NOT NULL,
    ht_numOfRooms INT NOT NULL
);

CREATE TABLE ROOM (
    rm_id SERIAL PRIMARY KEY,
    ht_id INT NOT NULL,
    rm_type VARCHAR(20) NOT NULL,
    rm_occupied BOOL NOT NULL,
    rm_extraDetails TEXT,
        FOREIGN KEY (ht_id)
            REFERENCES HOTEL(ht_id)
            ON DELETE CASCADE
);

-- talking note how does the room table function with regards to data.


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

CREATE TABLE BOOKKING (
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





INSERT INTO HOTEL (ht_name,ht_rating,ht_country,ht_addressLine1,ht_city,ht_postcode,ht_phoneNum,ht_numOfRooms)
VALUES 
    ('Crown',3,'UK','69 Church Lane ','LERWICK','ZE1 0AA','0783213984',52),
    ('Jamersons',5,'UK','28 Manchester Road','SUTTON','SM1 5CW','0763613484',32)
;
INSERT INTO ROOM (ht_id,rm_type,rm_occupied,rm_extraDetails)
VALUES
    FOR ()
    (1,'small single','fauls',''),
;