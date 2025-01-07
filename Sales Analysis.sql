use ecommercedb;
-- Daily Sales
SELECT DATE(OrderDate) AS SaleDate, 
       SUM(TotalAmount) AS DailySales, 
       AVG(TotalAmount) AS AvgDailySales
FROM orders
GROUP BY DATE(OrderDate);

-- Weekly sales 
SELECT YEAR(OrderDate) AS Year, 
       WEEK(OrderDate) AS Week, 
       SUM(TotalAmount) AS WeeklySales, 
       AVG(TotalAmount) AS AvgWeeklySales
FROM orders
GROUP BY YEAR(OrderDate), WEEK(OrderDate);

-- Monthly Sales
SELECT YEAR(OrderDate) AS Year, 
       MONTH(OrderDate) AS Month, 
       SUM(TotalAmount) AS MonthlySales, 
       AVG(TotalAmount) AS AvgMonthlySales
FROM orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

-- Average Order values
SELECT AVG(TotalAmount) AS AvgOrderValue
FROM orders;

-- Selecting UserID, average order amount, and order count for each customer
SELECT UserID, 
       AVG(TotalAmount) AS AvgOrderAmount,  -- Calculate the average order value for each customer
       COUNT(OrderID) AS OrderCount         -- Count the number of orders for each customer
FROM orders
GROUP BY UserID                             -- Group by UserID to calculate metrics per customer
HAVING AVG(TotalAmount) > 70.00            -- Filter for high-value customers with average order > 70
LIMIT 10; 
-- Selecting ProductID and total quantity sold for each product
SELECT ProductID, 
       SUM(Quantity) AS TotalQuantitySold   -- Sum the quantity sold for each product
FROM orderitems
GROUP BY ProductID                          -- Group by ProductID to calculate sales per product
ORDER BY SUM(Quantity) DESC                 -- Sort in descending order to get the top-selling products first
LIMIT 10;                                   -- Limit the results to the top 10 products


-- Selecting ProductID for products with low or no sales
SELECT p.ProductID
FROM products p
LEFT JOIN orderitems oi ON p.ProductID = oi.ProductID   -- Left join to include all products, even those with no sales
GROUP BY p.ProductID                                    -- Group by ProductID to calculate sales per product
HAVING SUM(oi.Quantity) IS NULL                         -- Include products with no sales
   OR SUM(oi.Quantity) < 5;                             -- Include products with total sales below threshold Z

-- Selecting ProductID and count of abandoned events for each product
SELECT ProductID, 
       COUNT(*) AS AbandonedCount                        -- Count the number of times each product was abandoned
FROM cartevents
WHERE EventType = 'add'                                  -- Only consider 'add' events to focus on added items
  AND ProductID NOT IN (
      -- Subquery to get products that have been purchased (appear in orderitems with a valid OrderID)
      SELECT DISTINCT ProductID 
      FROM orderitems 
      WHERE OrderID IS NOT NULL                          -- Only include products that are actually ordered
  )
GROUP BY ProductID                                       -- Group by ProductID to calculate abandonment count per product
ORDER BY COUNT(*) DESC                                   -- Sort by the highest abandonment count first
LIMIT 10;                                                -- Limit the results to the top 10 most abandoned products

