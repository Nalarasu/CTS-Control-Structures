CREATE DATABASE BankingSystem;
USE BankingSystem;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Balance DECIMAL(15,2),
    LastModified DATE
);
SHOW TABLES;
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(20),
    Balance DECIMAL(15,2),
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    TransactionDate DATE,
    Amount DECIMAL(15,2),
    TransactionType VARCHAR(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT,
    LoanAmount DECIMAL(15,2),
    InterestRate DECIMAL(5,2),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Salary DECIMAL(15,2),
    Department VARCHAR(50),
    HireDate DATE
);
ALTER TABLE Customers
ADD IsVIP CHAR(1) DEFAULT 'N';
CREATE TABLE ErrorLog (
    ErrorID INT AUTO_INCREMENT PRIMARY KEY,
    ErrorMessage VARCHAR(4000),
    ErrorDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE AuditLog (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID INT,
    AccountID INT,
    Amount DECIMAL(15,2),
    TransactionType VARCHAR(10),
    LogDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
VALUES (1, 'John Doe', '1985-05-15', 1000, CURDATE());

INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
VALUES (2, 'Jane Smith', '1990-07-20', 1500, CURDATE());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
VALUES (1, 1, 'Savings', 1000, CURDATE());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
VALUES (2, 2, 'Checking', 1500, CURDATE());

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (1, 1, CURDATE(), 200, 'Deposit');

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (2, 2, CURDATE(), 300, 'Withdrawal');

INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
VALUES (
    1,
    1,
    5000,
    5,
    CURDATE(),
    DATE_ADD(CURDATE(), INTERVAL 60 MONTH)
);

INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
VALUES (
    1,
    'Alice Johnson',
    'Manager',
    70000,
    'HR',
    '2015-06-15'
);

INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
VALUES (
    2,
    'Bob Brown',
    'Developer',
    60000,
    'IT',
    '2017-03-20'
);

COMMIT;
SELECT * FROM Customers;
SELECT * FROM Accounts;
SELECT * FROM Transactions;
SELECT * FROM Loans;
SELECT * FROM Employees;

UPDATE Customers
SET DOB = '1950-05-15'
WHERE CustomerID = 1;

SET SQL_SAFE_UPDATES = 0;
UPDATE Loans l
JOIN Customers c
ON l.CustomerID = c.CustomerID
SET l.InterestRate = l.InterestRate - (l.InterestRate * 0.01)
WHERE TIMESTAMPDIFF(YEAR, c.DOB, CURDATE()) > 60;

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM Loans;

SELECT * FROM Customers;

UPDATE Customers
SET Balance = 15000
WHERE CustomerID = 1;

UPDATE Customers
SET IsVIP = 'Y'
WHERE Balance > 10000;

SELECT CustomerID, Name, Balance, IsVIP
FROM Customers;

SELECT * FROM Loans;
UPDATE Loans
SET EndDate = DATE_ADD(CURDATE(), INTERVAL 15 DAY)
WHERE LoanID = 1;

SELECT LoanID, CustomerID, EndDate
FROM Loans;

SELECT
    CONCAT(
        'Reminder: Loan ID ',
        LoanID,
        ' for Customer ID ',
        CustomerID,
        ' is due on ',
        DATE_FORMAT(EndDate, '%d-%b-%Y')
    ) AS Reminder_Message
FROM Loans
WHERE EndDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

DELIMITER $$

CREATE PROCEDURE LoanDueReminders()
BEGIN
    SELECT
        CONCAT(
            'Reminder: Loan ID ',
            LoanID,
            ' for Customer ID ',
            CustomerID,
            ' is due on ',
            DATE_FORMAT(EndDate, '%d-%b-%Y')
        ) AS Reminder_Message
    FROM Loans
    WHERE EndDate BETWEEN CURDATE()
    AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);
END$$

DELIMITER ;

CALL LoanDueReminders();

SHOW PROCEDURE STATUS
WHERE Db = 'bankingsystem';