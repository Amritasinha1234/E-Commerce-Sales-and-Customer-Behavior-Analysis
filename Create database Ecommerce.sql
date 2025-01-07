CREATE DATABASE EcommerceDB;
USE EcommerceDB;
-- creating a table for users
CREATE TABLE users (
    UserID VARCHAR(50) PRIMARY KEY,
    UserName VARCHAR(100),
    Email VARCHAR(100),
    CreatedAt VARCHAR(50)  -- Storing as VARCHAR for import compatibility
);
-- creating a table for Products
CREATE TABLE Products (
    ProductID VARCHAR(50) PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2),
    StockLevel INT
);

CREATE TABLE Orders (
    OrderID VARCHAR(50) PRIMARY KEY,
    UserID VARCHAR(50),
    OrderStatus VARCHAR(20),
    TotalAmount DECIMAL(10, 2),
    OrderDate VARCHAR(50),  -- Adjusted for import compatibility; can later convert to DATETIME if needed
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID VARCHAR(50),
    ProductID VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID VARCHAR(50),
    ProductID VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID VARCHAR(50),
    ProductID VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
CREATE TABLE CartEvents (
    CartEventID VARCHAR(50) PRIMARY KEY,
    UserID VARCHAR(50),
    SessionID VARCHAR(50),
    ProductID VARCHAR(50),
    EventType VARCHAR(20),
    Timestamp VARCHAR(50),  -- Adjusted for import compatibility; can convert to DATETIME if needed
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
CREATE TABLE ProductInventory (
    ProductID VARCHAR(50),
    StockLevel INT,
    ReorderThreshold INT,
    LastUpdated DATETIME,
    PRIMARY KEY (ProductID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
select * from ProductInventory










