USE ecommercedb;
SHOW TABLES;

GRANT SELECT ON ecommercedb.orders TO 'root'@'localhost';
FLUSH PRIVILEGES;

SELECT * FROM products WHERE ProductID = 2;
INSERT INTO products (ProductID, ProductName, StockLevel) VALUES (2, 'Example Product', 100);
INSERT INTO inventoryalerts (ProductID, AlertType) VALUES (2, 'low_stock');



