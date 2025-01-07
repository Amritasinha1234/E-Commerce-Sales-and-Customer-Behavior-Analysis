use ecommercedb
DELIMITER //

CREATE TRIGGER update_stock_after_order_new
AFTER INSERT ON OrderItemsorderitems
FOR EACH ROW
BEGIN
    UPDATE productinventory
    SET StockLevel = StockLevel - NEW.Quantity,
        LastUpdated = NOW()
    WHERE ProductID = NEW.ProductID;
END //

DELIMITER ;
DELETE FROM orderitems WHERE OrderItemID = 1;
SELECT * FROM orders WHERE OrderID = 101;

INSERT INTO orders (OrderID, UserID, OrderStatus, TotalAmount, OrderDate, PaymentMethod)
VALUES (101, 'U123', 'Pending', 499.95, '2024-11-11', 'Credit Card');



select * from  orderitems

-- Step 1: Ensure the trigger is created
DELIMITER //

CREATE TRIGGER update_stock_after_order_old
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE ProductInventory
    SET StockLevel = StockLevel - NEW.Quantity,
        LastUpdated = NOW()
    WHERE ProductID = NEW.ProductID;
END //

DELIMITER ;

INSERT INTO Users (UserID, UserName, Email, CreatedAt)
VALUES ('U123', 'John Doe', 'johndoe@example.com', '2024-11-01')
ON DUPLICATE KEY UPDATE UserID=UserID;

INSERT INTO Orders (OrderID, UserID, OrderStatus, TotalAmount, OrderDate, PaymentMethod)
VALUES ('O9999', 'U123', 'Pending', 499.95, '2024-11-11', 'Credit Card')
ON DUPLICATE KEY UPDATE OrderID=OrderID;

INSERT INTO Products (ProductID, ProductName, Category, Price, StockLevel)
VALUES ('product123', 'Sample Product', 'Electronics', 99.99, 100)
ON DUPLICATE KEY UPDATE ProductID=ProductID;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
VALUES ('O9999', 'product123', 5, 99.99);

SELECT ProductID, StockLevel, LastUpdated
FROM ProductInventory
WHERE ProductID = 'product123';

DELIMITER //

CREATE TRIGGER after_order_item_insert
AFTER INSERT ON orderitems
FOR EACH ROW
BEGIN
    UPDATE productinventory
    SET StockLevel = StockLevel - NEW.Quantity,
        LastUpdated = NOW()
    WHERE ProductID = NEW.ProductID;

    -- Check if stock level falls below the reorder threshold
    IF (SELECT StockLevel FROM productinventory WHERE ProductID = NEW.ProductID) < 
       (SELECT ReorderThreshold FROM productinventory WHERE ProductID = NEW.ProductID) THEN
        INSERT INTO inventoryalerts (ProductID, AlertType, AlertTime)
        VALUES (NEW.ProductID, 'Low Stock', NOW());
    END IF;
END //

DELIMITER ;


-- Create an OrderStatusLog table for tracking status changes
CREATE TABLE IF NOT EXISTS orderstatuslog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID VARCHAR(50),
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20),
    ChangedAt DATETIME
);

-- Trigger to log order status changes
DELIMITER //

CREATE TRIGGER before_order_status_update
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.OrderStatus != NEW.OrderStatus THEN
        INSERT INTO orderstatuslog (OrderID, OldStatus, NewStatus, ChangedAt)
        VALUES (OLD.OrderID, OLD.OrderStatus, NEW.OrderStatus, NOW());
    END IF;
END //

DELIMITER ;
-- Trigger for adding an item to the cart
DELIMITER //

CREATE TRIGGER after_cart_item_added
AFTER INSERT ON Cartevents
FOR EACH ROW
BEGIN
    INSERT INTO CartEvents (UserID, SessionID, ProductID, EventType, Timestamp)
    VALUES (NEW.UserID, NEW.SessionID, NEW.ProductID, 'add', NOW());
END //

DELIMITER ;

-- Trigger for removing an item from the cart
DELIMITER //

CREATE TRIGGER after_cart_item_removed
AFTER DELETE ON Cartevents
FOR EACH ROW
BEGIN
    INSERT INTO CartEvents (UserID, SessionID, ProductID, EventType, Timestamp)
    VALUES (OLD.UserID, OLD.SessionID, OLD.ProductID, 'remove', NOW());
END //

DELIMITER ;


-- Create InventoryAlerts table for low-stock notifications
CREATE TABLE IF NOT EXISTS inventoryalerts (
    AlertID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID VARCHAR(50),
    AlertType VARCHAR(20),
    AlertTime DATETIME,
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

DELIMITER //

CREATE TRIGGER UpdateInventoryOnOrderAdd
AFTER INSERT ON orderitems
FOR EACH ROW
BEGIN
    UPDATE ProductInventory
    SET StockLevel = StockLevel - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END;
//

DELIMITER ;
DELIMITER //
CREATE TRIGGER UpdateInventoryOnOrderCancel
AFTER DELETE ON orderitems
FOR EACH ROW
BEGIN
    UPDATE ProductInventory
    SET StockLevel = StockLevel + OLD.Quantity
    WHERE ProductID = OLD.ProductID;
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER UpdateOrderStatusOnPayment
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.PaymentMethod IS NOT NULL AND NEW.OrderStatus = 'Pending' THEN
        UPDATE Orders
        SET OrderStatus = 'Processing'
        WHERE OrderID = NEW.OrderID;
    END IF;
END;

//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CheckLowStock()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE product_id VARCHAR(50);
    DECLARE stock_level INT;
    DECLARE reorder_threshold INT;

    DECLARE cur CURSOR FOR
        SELECT ProductID, StockLevel, ReorderThreshold FROM ProductInventory WHERE StockLevel <= ReorderThreshold;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur;
    
    low_stock_loop: LOOP
        FETCH cur INTO product_id, stock_level, reorder_threshold;
        IF finished = 1 THEN 
            LEAVE low_stock_loop;
        END IF;
        -- Insert alert into an alerts table (assuming an Alerts table exists for notifications)
        INSERT INTO Alerts (ProductID, AlertMessage, AlertType, CreatedAt)
        VALUES (product_id, CONCAT('Low stock level: ', stock_level), 'Inventory', NOW());
    END LOOP;

    CLOSE cur;
END//

DELIMITER ;

