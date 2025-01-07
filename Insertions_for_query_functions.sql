use ecommercedb;
-- Inserting sample data into Users, Products, and ProductInventory
INSERT INTO users (UserID, UserName, Email, CreatedAt)
VALUES ('U123', 'John Doe', 'johndoe@example.com', '2024-11-01');

INSERT INTO products (ProductID, ProductName, Category, Price, StockLevel)
VALUES ('product123', 'Sample Product', 'Electronics', 99.99, 100);

INSERT INTO productinventory (ProductID, StockLevel, ReorderThreshold, LastUpdated)
VALUES ('product123', 100, 20, NOW());

-- Insert an order to test order status logging
INSERT INTO orders (OrderID, UserID, OrderStatus, TotalAmount, OrderDate, PaymentMethod)
VALUES ('O9999', 'U123', 'Pending', 499.95, '2024-11-11', 'Credit Card');

-- Insert into orderitems to trigger stock update in ProductInventory and low-stock alert
INSERT INTO orderitems (OrderID, ProductID, Quantity, Price)
VALUES ('O9999', 'product123', 85, 99.99);  -- This should drop stock below the reorder threshold

-- Update the order status to test status logging
UPDATE orders
SET OrderStatus = 'Shipped'
WHERE OrderID = 'O9999';

-- Check updated stock level and low-stock alert in ProductInventory and InventoryAlerts
SELECT ProductID, StockLevel, LastUpdated
FROM productinventory
WHERE ProductID = 'product123';

SELECT * FROM inventoryalerts;

-- Check order status change logs
SELECT * FROM orderstatuslog;

-- Check cart events
SELECT * FROM cartevents;



