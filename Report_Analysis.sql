USE ecommercedb;
SHOW TABLES;
SELECT DATE(OrderDate) AS Date, SUM(TotalAmount) AS TotalSales
FROM orders
WHERE OrderDate >=  '2023-11-12' - INTERVAL 1 DAY
GROUP BY Date
ORDER BY Date DESC;


SELECT UserID, COUNT(OrderID) AS OrderCount, SUM(TotalAmount) AS TotalSpent
FROM orders
GROUP BY OrderID
HAVING TotalSpent > 100.00 AND OrderCount > 0;

SELECT ProductID, ProductName, StockLevel
FROM products
WHERE StockLevel < 20;
USE ecommercedb;



CREATE TABLE real_time_sales_n (
    OrderID Varchar(50),
    Sales DECIMAL(10, 2)
);

INSERT INTO real_time_sales_n (OrderID, Sales)
SELECT OrderID, SUM(TotalAmount) AS Sales
FROM orders
GROUP BY OrderID;

DELIMITER //

CREATE PROCEDURE refresh_real_time_sales_n()
BEGIN
    -- Clear old data
    TRUNCATE TABLE real_time_sales_n;

    -- Insert updated data
    INSERT INTO real_time_sales_n (OrderID, Sales)
    SELECT OrderID, SUM(TotalAmount) AS Sales
    FROM orders
    GROUP BY OrderID;
END;
//

DELIMITER ;
CREATE EVENT refresh_sales_event
ON SCHEDULE EVERY 1 HOUR
DO
    CALL refresh_real_time_sales_n();


SHOW VARIABLES LIKE 'event_scheduler';
CREATE VIEW sales_report AS
SELECT * FROM real_time_sales_n;

SELECT * FROM sales_report;





