CREATE DATABASE final_project;

USE final_project;

UPDATE customers
SET age = NULL
WHERE age = '';

UPDATE customers
SET gender = NULL
WHERE gender = '';

ALTER TABLE customers
MODIFY age INT NULL;

SELECT * FROM customers;

DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions(
	date_new DATE,
    id_check INT,
    id_client INT,
    count_products DECIMAL(10, 3),
    sum_payment DECIMAL(10, 2)
);

LOAD DATA INFILE'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM transactions;