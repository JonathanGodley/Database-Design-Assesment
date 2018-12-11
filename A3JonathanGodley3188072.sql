-- Assignment 3
-- Jonathan Godley
-- c3188072

-- Drop Tables
DROP TABLE ItemsOrdered
DROP TABLE IngredientList
DROP TABLE IngredientOrders
DROP TABLE Ingredients
DROP TABLE Suppliers
DROP TABLE MenuItems
DROP TABLE PaymentHistory
DROP TABLE Shifts
DROP TABLE Orders
DROP TABLE Customers
DROP TABLE DiscountPrograms
DROP TABLE Staff
GO

-- Create Database
CREATE TABLE Staff(
	StaffID INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Address VARCHAR(200) NOT NULL,
	Phone VARCHAR(15) NOT NULL,
	TaxFileNumber VARCHAR(11) NOT NULL,
	BankCode VARCHAR(7) NOT NULL,
	BankName VARCHAR(50) NOT NULL,
	BankAccountNumber VARCHAR(20) NOT NULL,
	PaymentRate FLOAT NOT NULL DEFAULT 15, -- instore paid hourly, delivery paid per delivery
	Description VARCHAR(100),
	Type CHAR DEFAULT 'I' NOT NULL,
	DriversLicenceNo int
	)

CREATE TABLE DiscountPrograms(
	DiscountID INT PRIMARY KEY,
	DiscDescription VARCHAR(50),
	StartDate DATE DEFAULT (CONVERT (date, GETDATE()))  NOT NULL,
	EndDate DATE ,
	DiscountPercentage INT DEFAULT 20 NOT NULL CHECK(DiscountPercentage !> 80),
	Requirements VARCHAR(50) NOT NULL
	)

CREATE TABLE Customers(
	CustomerID INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	CustomerAddress VARCHAR(200) NOT NULL,
	Phone VARCHAR(20) NOT NULL
	)

CREATE TABLE Orders(
	OrderNumber INT PRIMARY KEY,
	OrderDateTime DATETIME NOT NULL DEFAULT GETDATE(),
	CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
	StaffID INT FOREIGN KEY REFERENCES Staff(StaffID),
	OrderType CHAR(2) NOT NULL DEFAULT 'PD', -- PP = Phone Pickup, WI = Walkin PD = PhoneDelivery
	OrderDescription VARCHAR(250),
	OrderStatus VARCHAR(10) NOT NULL DEFAULT 'ORDERED',
	PaymentMethod VARCHAR(4) NOT NULL DEFAULT 'CASH', -- or 'CARD'
	Subtotal FLOAT NOT NULL DEFAULT 0.0 CHECK(Subtotal >= 0),
	DiscountID INT FOREIGN KEY REFERENCES DiscountPrograms(DiscountID),
	DiscountAmount FLOAT CHECK(DiscountAmount >= 0),
	TaxAmount FLOAT NOT NULL CHECK(TaxAmount >= 0),
	TotalAmount FLOAT NOT NULL CHECK(TotalAmount >=0),
	PaymentApprovalNumber VARCHAR(50),
	VerificationAnswered DATETIME,
	VerificationEnded DATETIME,
	DeliveryDriverID INT FOREIGN KEY REFERENCES Staff(StaffID),
	)

CREATE TABLE Shifts(
	ShiftID INT PRIMARY KEY,
	StaffID INT FOREIGN KEY REFERENCES Staff(StaffID), 
	StartingDateTime DATETIME NOT NULL,
	EndingDateTime DATETIME,
	HoursWorked FLOAT,
	OrdersDelivered INT CHECK(OrdersDelivered >= 0)
	)

CREATE TABLE PaymentHistory(
	PaymentID INT PRIMARY KEY,
	StaffID INT FOREIGN KEY REFERENCES Staff(StaffID),
	ShiftID INT FOREIGN KEY REFERENCES Shifts(ShiftID),
	Amount FLOAT NOT NULL CHECK(Amount >= 0),
	PaymentDateTime DATETIME NOT NULL DEFAULT GETDATE(),
	PaymentConfirmation INT NOT NULL
	)

CREATE TABLE MenuItems(
	ItemNo INT PRIMARY KEY,
	ItemName VARCHAR(50) NOT NULL,
	Size CHAR NOT NULL DEFAULT 'S',
	Price FLOAT NOT NULL
	)

CREATE TABLE Suppliers(
	SupplierNo INT PRIMARY KEY,
	SupplierName VARCHAR(100) NOT NULL,
	SupplierAddress VARCHAR(200) NOT NULL,
	Phone VARCHAR(20) NOT NULL,
	ContactPerson VARCHAR(50))

CREATE TABLE Ingredients(
	IngredientCode INT PRIMARY KEY,
	IngredientName VARCHAR(50) NOT NULL,
	IngredientType VARCHAR(25) NOT NULL,
	IngredientDescription VARCHAR(100),
	StockLevelAtCurrentPeriod FLOAT NOT NULL CHECK(StockLevelAtCurrentPeriod >= 0), --quantity in grams
	DateLastStocktakeWasTaken DATETIME NOT NULL,
	SuggestedStockLevel FLOAT NOT NULL CHECK(SuggestedStockLevel >= 0),
	ReorderLevel FLOAT NOT NULL CHECK(ReorderLevel >= 0),
	SupplierNo INT FOREIGN KEY REFERENCES Suppliers(SupplierNo)
	)

CREATE TABLE IngredientOrders(
	OrderNo INT PRIMARY KEY,
	DateOrdered DATETIME NOT NULL DEFAULT GETDATE(),
	DateReceived DATETIME,
	Status VARCHAR(10) NOT NULL DEFAULT 'ORDERED',
	Description VARCHAR(200),
	SupplierNo INT FOREIGN KEY REFERENCES Suppliers(SupplierNo),
	IngredientCode INT FOREIGN KEY REFERENCES Ingredients(IngredientCode),
	Amount FLOAT NOT NULL DEFAULT 5000 CHECK(Amount > 0),
	Price FLOAT NOT NULL CHECK(Price > 0))

CREATE TABLE IngredientList(
	ItemNo INT FOREIGN KEY REFERENCES MenuItems(ItemNo),
	IngredientCode INT FOREIGN KEY REFERENCES Ingredients(IngredientCode),
	Quantity FLOAT NOT NULL DEFAULT 0.0 CHECK(Quantity >= 0)
	)

CREATE TABLE ItemsOrdered(
	OrderNo INT FOREIGN KEY REFERENCES Orders(OrderNumber),
	ItemNo INT FOREIGN KEY REFERENCES MenuItems(ItemNo),
	)
GO

-- Insert Proper Data into Tables, 3 per table
INSERT INTO Staff VALUES (1,'Tom','Yates','23 Fake Street','0222223333','123-456-789','123-456','CommBank','54215654',16.50,NULL,'I',NULL)
INSERT INTO Staff VALUES (2,'Samantha','Jackson','12 Fake Street','0222223344','123-456-779','123-456','CommBank','54215657',16.50,NULL,'I',NULL)
INSERT INTO Staff VALUES (3,'James','McDeliveryperson','13 Fake Street','0222223355','123-456-888','323-456','Greater Building Society','54215659',2.50,'Our only delivery driver','D',00001234)
GO

INSERT INTO DiscountPrograms VALUES (1,'25% off your order','2017-05-03','2018-01-01',25,'Order must contain 3+ Pizzas')
INSERT INTO DiscountPrograms VALUES (2,'15% off your order','2017-08-03','2017-09-03',15,'Order must contain 2+ Pizzas')
INSERT INTO DiscountPrograms VALUES (3,'5% off your order','2016-05-03',NULL,5,'No Requirements')
GO

INSERT INTO Customers VALUES (1,'Steven','Jacobs','31 Fake Avenue','0401666666')
INSERT INTO Customers VALUES (2,'Tyler','Thomas','21 Fake Avenue','0401666678')
INSERT INTO Customers VALUES (3,'Mary','Shelley','1 Fake Avenue','0401666656')
GO

INSERT INTO Orders VALUES (1,'01/01/17 20:50:59.990',1,1,'PD',NULL,'READY',
	'CASH',17.50,NULL,NULL,1.75,19.25,NULL,'01/01/17 20:56:59.990','01/01/17 20:58:23.990',3)
INSERT INTO Orders VALUES (2,'10/19/17 19:59:59.990',1,2,'WI','Had to recook order','COOKING',
	'CASH',35.00,NULL,NULL,3.50,38.50,NULL,NULL,NULL,NULL)
INSERT INTO Orders VALUES (3,'05/05/17 21:59:59.990',2,2,'WI',NULL,'COMPLETE',
	'CARD',17.50,3,0.88,1.66,18.28,'1535WAF3543532',NULL,NULL,NULL)
INSERT INTO Orders VALUES (4,'10/19/17 19:59:59.990',1,2,'WI',NULL,'COOKING',
	'CASH',35.00,NULL,NULL,3.50,38.50,NULL,NULL,NULL,NULL)
GO

INSERT INTO Shifts VALUES (1,1,'01/01/17 12:00:01.290','01/01/17 20:00:03.990',8,NULL)
INSERT INTO Shifts VALUES (2,2,'01/01/17 15:00:02.990','01/01/17 21:30:02.990',6.5,NULL)
INSERT INTO Shifts VALUES (3,3,'10/10/17 18:30:30.290','10/10/17 21:30:29.990',3,18)
INSERT INTO Shifts VALUES (4,3,'10/15/17 18:30:30.290','10/15/17 21:30:29.990',3,18)
INSERT INTO Shifts VALUES (5,3,'11/11/17 18:30:30.290','11/11/17 21:30:29.990',3,20)
INSERT INTO Shifts VALUES (6,3,'11/15/17 18:30:30.290','11/15/17 21:30:29.990',3,20)
GO

INSERT INTO PaymentHistory VALUES (1,1,1,132,'01/01/17 12:10:01.290',1452342)
INSERT INTO PaymentHistory VALUES (2,2,2,107.25,'01/01/17 12:10:03.590',234324145)
INSERT INTO PaymentHistory VALUES (3,3,3,45,'10/10/17 12:10:08.292',152334242)
INSERT INTO PaymentHistory VALUES (4,3,4,45,'10/15/17 12:10:08.292',152334242)
INSERT INTO PaymentHistory VALUES (5,3,5,50,'11/11/17 12:10:08.292',152334242)
INSERT INTO PaymentHistory VALUES (6,3,6,50,'11/15/17 12:10:08.292',152334242)
GO

INSERT INTO MenuItems VALUES (1,'Pepperoni','S',17.50)
INSERT INTO MenuItems VALUES (2,'Supreme','S',17.50)
INSERT INTO MenuItems VALUES (3,'Meatlovers','S',17.50)
GO

INSERT INTO Suppliers VALUES (1,'General Supplies','3 Factory Way','0249341234','Jacob')
INSERT INTO Suppliers VALUES (2,'Stuff Co', '2 Factory Way','0249343334','Sam')
INSERT INTO Suppliers VALUES (3,'Cheese Corp', '32 Factory Way','0249341233','Adam')
GO

INSERT INTO Ingredients VALUES (1,'Mozzarella','CHEESE','Fresh Mozzarella Cheese',3202.55,'02/01/17 12:30:01.290',15000,5000,3) 
INSERT INTO Ingredients VALUES (2,'Bacon','MEAT','Diced Bacon Pieces',1202.55,'02/01/17 12:35:01.290',5000,2500,1)
INSERT INTO Ingredients VALUES (3,'Capsicum','VEGETABLE','Diced Red Capsicum Pieces',2442.05,'02/01/17 12:40:01.290',5000,2500,2)
GO

INSERT INTO IngredientOrders VALUES (1,'02/01/17 12:30:01.290',NULL,'ORDERED','AUTOMATED ORDER',3,1,12000,60)
INSERT INTO IngredientOrders VALUES (2,'02/01/17 12:35:01.290','02/03/17 12:35:01.290','ORDERED','AUTOMATED ORDER',1,2,4000,80)
INSERT INTO IngredientOrders VALUES (3,'02/01/17 12:40:01.290',NULL,'ORDERED','AUTOMATED ORDER',2,3,3000,30)
GO

INSERT INTO IngredientList VALUES (2,1,300)
INSERT INTO IngredientList VALUES (2,3,150)
INSERT INTO IngredientList VALUES (3,1,300)
INSERT INTO IngredientList VALUES (3,2,200)
GO

INSERT INTO ItemsOrdered VALUES (1,3)
INSERT INTO ItemsOrdered VALUES (2,3)
INSERT INTO ItemsOrdered VALUES (2,2)
INSERT INTO ItemsOrdered VALUES (3,3)
INSERT INTO ItemsOrdered VALUES (4,2)
INSERT INTO ItemsOrdered VALUES (4,3)
GO

-- Queries
--Q.1 For a staff with id number xxx, print his/her 1stname, lname, and hourly payment rate.

SELECT FirstName, LastName, PaymentRate FROM Staff WHERE staffID = 2;
GO

--Q.2 List the ingredient details of a menu item named xxx.
--note: understood the question as show all details for ingredients in pizza xxx, hence the use of ing.* rather than picking and choosing

SELECT mi.ItemName AS 'Pizza', ing.* FROM IngredientList il, MenuItems mi, Ingredients ing 
	WHERE mi.ItemName = 'Meatlovers' AND mi.ItemNo = il.ItemNo AND il.IngredientCode = ing.IngredientCode;
GO

--Q.3 List all the order details of the orders that are made by the customer with first name xxx via phone between date yyy and zzz.

SELECT O.* FROM Orders O, Customers C
	WHERE O.CustomerID = C.CustomerID AND C.Firstname = 'Steven' 
		AND O.OrderType IN ('PP','PD') AND O.OrderDateTime > '01/01/17' AND O.OrderDateTime < '01/01/18';
GO

--Q.4 Print the salary paid to a delivery staff named xxx in current month.

SELECT SUM(PH.Amount) AS 'Current Month Salary' FROM Staff ST, Shifts SH, PaymentHistory PH -- print the salary paid
	WHERE ST.FirstName = 'James' AND ST.LastName = 'McDeliveryperson'  -- delivery staff named xxx
	AND SH.StaffID = ST.StaffID AND SH.StaffID = PH.StaffID AND PH.ShiftID = SH.ShiftID
	AND YEAR(SH.EndingDateTime) = YEAR(getdate()) AND MONTH(SH.EndingDateTime) = MONTH(getdate());-- in current month
GO

--Q.5 List the menu item that is mostly ordered in current month.

SELECT TOP 1 MenuItems.ItemName AS 'Most Ordered Pizza', COUNT(ItemsOrdered.ItemNo) AS Occurrences  -- List the menu item that is mostly ordered
    FROM ItemsOrdered, MenuItems, Orders
	WHERE MenuItems.ItemNo = ItemsOrdered.ItemNo AND ItemsOrdered.OrderNo = Orders.OrderNumber
	AND YEAR(Orders.OrderDateTime) = YEAR(getdate()) AND MONTH(Orders.OrderDateTime) = MONTH(getdate())-- in current month
	GROUP BY MenuItems.ItemName, ItemsOrdered.ItemNo
    ORDER BY ItemsOrdered.ItemNo DESC;
GO

--Q.6 List the ingredient(s) that was/were supplied by the supplier with supplier ID xxx on date yyy

SELECT Ingredients.IngredientName, Ingredients.IngredientDescription, Ingredients.IngredientType -- List the ingredient(s) that was/were supplied
	FROM IngredientOrders, Ingredients
	WHERE IngredientOrders.IngredientCode = Ingredients.IngredientCode
	AND IngredientOrders.SupplierNo = 1 -- by the supplier with supplier ID xxx
	AND YEAR(IngredientOrders.DateReceived) = YEAR('02/03/17')
	AND MONTH(IngredientOrders.DateReceived) = MONTH('02/03/17')
	AND DAY(IngredientOrders.DateReceived) = DAY('02/03/17');-- on date yyy
GO