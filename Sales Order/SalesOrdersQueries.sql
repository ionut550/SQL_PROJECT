-- For this Script to work you need to run 'SalesOrdersStructure.sql' and 'SalesOrdersData.sql' first.

SET search_path TO salesorders;

-- Show me the names of all our vendors.
CREATE VIEW Vendor_Name AS
SELECT vendors.vendname
FROM salesorders.vendors;

-- What are the names and prices of all the products we carry?
CREATE VIEW Product_Price_List AS
SELECT products.productname, products.retailprice
FROM salesorders.products;

-- Which states do our customers come from?
CREATE VIEW Customer_State AS
SELECT DISTINCT customers.custstate
FROM salesorders.customers;

-- Show me all the information on our employees.
CREATE VIEW Employee_Information AS
SELECT *
FROM salesorders.employees;

-- Show me a list of cities, in alphabetical order, where our vendors
-- are located, and include the names of the vendors we work with in each city.
CREATE VIEW Vendor_Locations AS
SELECT vendors.vendcity, vendors.vendname
FROM salesorders.vendors
ORDER BY vendors.vendcity;

-- What is the inventory value of each product?
CREATE VIEW Product_Inventory_Value AS
SELECT ProductName,
	RetailPrice * QuantityOnHand AS InventoryValue
FROM Products;

-- How many days elapsed between the order date and the ship date for each order?
CREATE VIEW Shipping_Days_Analysis AS
SELECT OrderNumber, OrderDate, ShipDate,
	CAST(ShipDate - OrderDate AS INTEGER) AS DaysElapsed
FROM Orders;

-- What if we adjusted each product price by reducing it 5 percent?
CREATE VIEW Adjusted_Wholesale_Prices AS
SELECT product_vendors.wholesaleprice, (product_vendors.wholesaleprice * 1.05) AS Adjusted_Price
FROM salesorders.product_vendors;

-- Show me a list of orders made by each customer in descending date order.
CREATE VIEW Orders_By_Customer_And_Date AS
SELECT *
FROM salesorders.orders
ORDER BY  orders.customerid, orders.orderdate DESC;

-- Compile a complete list of vendor names and addresses in vendor name order.
CREATE VIEW Vendor_Addresses AS
SELECT vendors.vendname,
	vendors.vendstreetaddress,
	vendors.vendcity,
	vendors.vendstate,
	vendors.vendzipcode
FROM salesorders.vendors
ORDER BY vendors.vendname;

-- Show me all the orders for customer number 1001.
CREATE VIEW Orders_For_Customer_1001 AS
SELECT OrderNumber, CustomerID
FROM Orders
WHERE CustomerID = 1001;

-- Show me an alphabetized list of products with names that begin with ‘Dog’.
CREATE VIEW Products_That_Begin_With_Dog AS
SELECT ProductName
FROM Products
WHERE ProductName LIKE 'Dog%'
ORDER BY ProductName;

-- Give me the names of all vendors based in Ballard, Bellevue, and Redmond.
CREATE VIEW Ballard_Bellevue_Redmond_Vendors AS
SELECT vendors.vendname , vendors.vendcity
FROM salesorders.vendors
WHERE vendors.vendcity IN ('Ballard', 'Bellevue', 'Redmond');

-- Show me an alphabetized list of products with a retail price of $125.00 or more.
CREATE VIEW Products_Priced_Over_125 AS
SELECT products.productname, products.retailprice
FROM salesorders.products
WHERE products.retailprice >= 125
ORDER BY products.productname;

-- Which vendors do we work with that don’t have a Web site?
CREATE VIEW Vendors_With_No_Website AS 
SELECT vendors.vendname, vendors.vendwebpage
FROM salesorders.vendors
WHERE vendors.vendwebpage IS NULL;

-- Display all products and their categories.
CREATE VIEW Products_And_Categories AS
SELECT Categories.CategoryDescription,
	Products.ProductName
FROM Categories
INNER JOIN Products
ON Categories.CategoryID = Products.CategoryID;

-- Find all the customers who have ever ordered a bicycle helmet.
CREATE VIEW Customers_Who_Ordered_Helmets AS
SELECT DISTINCT Customers.CustFirstName,
	Customers.CustLastName
FROM Customers INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.OrderNumber = Order_Details.OrderNumber
INNER JOIN Products
ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName LIKE '%Helmet%';

-- Find all the customers who ordered a bicycle and also ordered a helmet.
CREATE VIEW Customers_Both_Bikes_And_Helmets AS
SELECT CustBikes.CustFirstName,
	CustBikes.CustLastName
FROM(
	SELECT DISTINCT Customers.CustomerID,
		Customers.CustFirstName,
		Customers.CustLastName
	FROM Customers
	INNER JOIN Orders
	ON Customers.CustomerID = Orders.CustomerID
	INNER JOIN Order_Details
	ON Orders.OrderNumber = Order_Details.OrderNumber
	 INNER JOIN Products
	ON Products.ProductNumber = Order_Details.ProductNumber
	WHERE Products.ProductName LIKE '%Bike') AS CustBikes
INNER JOIN(
	SELECT DISTINCT Customers.CustomerID
	FROM Customers
	INNER JOIN Orders
	ON Customers.CustomerID = Orders.CustomerID
	INNER JOIN Order_Details
	ON Orders.OrderNumber = Order_Details.OrderNumber
	INNER JOIN Products
	ON Products.ProductNumber = Order_Details.ProductNumber
	WHERE Products.ProductName LIKE '%Helmet') AS CustHelmets
ON CustBikes.CustomerID = CustHelmets.CustomerID;
-- First we find the customers who order a bike and then those who order a helmet and we join them together.

-- List customers and the dates they placed an order, sorted in order date sequence.
CREATE VIEW Customers_And_Order_Dates AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	orders.orderdate
FROM salesorders.customers
NATURAL JOIN salesorders.orders;
-- I used NATURAL JOIN becouse the only matching column. 

-- List employees and the customers for whom they booked an order.
CREATE VIEW Employees_And_Customers AS
SELECT DISTINCT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	employees.empfirstname || ' ' || employees.emplastname AS Employee_Name
FROM salesorders.customers
NATURAL JOIN salesorders.orders
NATURAL JOIN salesorders.employees;

-- Display all orders, the products in each order, and the amount
-- owed for each product, in order number sequence.
CREATE VIEW Orders_With_Products AS
SELECT orders.ordernumber, products.productname, products.retailprice
FROM salesorders.orders
INNER JOIN salesorders.order_details
USING (ordernumber) 
INNER JOIN salesorders.products
USING (productnumber)
ORDER BY orders.ordernumber;

-- Show me the vendors and the products they supply to us for products that cost less than $100.
CREATE VIEW Vendors_And_Products_Less_Than_100 AS
SELECT vendors.vendname, product_vendors.wholesaleprice
FROM salesorders.vendors
NATURAL JOIN salesorders.product_vendors
WHERE product_vendors.wholesaleprice < 100;

-- Show me customers and employees who have the same last name.
CREATE VIEW Customer_Employees_Same_Lastname AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	employees.empfirstname || ' ' || employees.emplastname AS Employee_Name
FROM salesorders.customers
INNER JOIN salesorders.employees
ON customers.custlastname = employees.emplastname;

-- Show me customers and employees who live in the same city.
CREATE VIEW Customers_Employees_Same_City AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	employees.empfirstname || ' ' || employees.emplastname AS Employee_Name
FROM salesorders.customers
INNER JOIN salesorders.employees
ON customers.custcity = employees.empcity;

-- What products have never been ordered?
CREATE VIEW Products_Never_Ordered AS
SELECT Products.ProductNumber,
	Products.ProductName
FROM Products
LEFT OUTER JOIN Order_Details
ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Order_Details.OrderNumber IS NULL;

-- Display all customers and any orders for bicycles.
CREATE VIEW All_Customers_And_Any_Bike_Orders AS
SELECT Customers.CustFirstName || ' ' || Customers.CustLastName AS CustFullName,
	RD.OrderDate, 
	RD.ProductName,
	RD.QuantityOrdered, 
	RD.QuotedPrice
FROM Customers
LEFT OUTER JOIN(
	SELECT Orders.CustomerID, Orders.OrderDate,
	Products.ProductName,
	Order_Details.QuantityOrdered,
	Order_Details.QuotedPrice 
	FROM Orders
	INNER JOIN Order_Details
	ON Orders.OrderNumber = Order_Details.OrderNumber
	INNER JOIN Products
	ON Order_Details.ProductNumber = Products.ProductNumber
	INNER JOIN Categories
	ON Categories.CategoryID = Products.CategoryID
	WHERE Categories.CategoryDescription = 'Bikes') AS RD
ON Customers.CustomerID = RD.CustomerID;

-- Show me customers who have never ordered a helmet.
CREATE VIEW Customers_No_Helmets AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name
FROM salesorders.customers
LEFT OUTER JOIN ( SELECT orders.customerid
	FROM salesorders.orders
	INNER JOIN salesorders.order_details
	ON orders.ordernumber = order_details.ordernumber
	INNER JOIN salesorders.products
	ON order_details.productnumber = products.productnumber
	WHERE productname ILIKE '%helmet%' ) AS helmet
ON customers.customerid = helmet.customerid 
WHERE helmet.customerid IS NULL;

-- List all products and the dates for any orders.
CREATE VIEW All_Products_Any_Order_Dates AS
SELECT DISTINCT products.productname, orders.orderdate
FROM salesorders.products
LEFT OUTER JOIN (salesorders.order_details
	INNER JOIN salesorders.orders
	USING (ordernumber))
USING(productnumber);

-- List customers and the bikes they ordered combined with vendors and the bikes they sell.
CREATE VIEW Customers_Vendors_Bike AS
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS FullName,
	Products.ProductName,
	'Customer' AS RowID
FROM Customers 
INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.OrderNumber = Order_Details.OrderNumber
INNER JOIN Products
ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName ILIKE '%bike%'

UNION

SELECT Vendors.VendName, 
	Products.ProductName,
	'Vendor' AS RowID
FROM Vendors
INNER JOIN Product_Vendors
ON Vendors.VendorID = Product_Vendors.VendorID
INNER JOIN Products
ON Products.ProductNumber = Product_Vendors.ProductNumber
WHERE Products.ProductName ILIKE '%bike%';

-- Build a single mailing list that consists of the name, address, city,
-- state, and ZIP Code for customers and the name, address, city, state, and ZIP Code for vendors.
CREATE VIEW Customers_Vendors_Mailing AS
SELECT Customers.CustLastName || ', ' ||
	Customers.CustFirstName AS MailingName,
	Customers.CustStreetAddress, Customers.CustCity,
	Customers.CustState, Customers.CustZipCode
FROM Customers

UNION

SELECT Vendors.VendName,
	Vendors.VendStreetAddress, Vendors.VendCity,
	Vendors.VendState, Vendors.VendZipCode
FROM Vendors;

-- Create a single mailing list for customers, employees, and vendors.
CREATE VIEW Customers_Employees_Vendors_Mailing AS
SELECT Customers.CustFirstName || ' ' ||
	Customers.CustLastName AS CustFullName,
	Customers.CustStreetAddress,
	Customers.CustCity,
	Customers.CustState, Customers.CustZipCode
FROM Customers

UNION

SELECT Employees.EmpFirstName || ' ' ||
	Employees.EmpLastName AS EmpFullName,
	Employees.EmpStreetAddress, Employees.EmpCity,
	Employees.EmpState,
	Employees.EmpZipCode
FROM Employees

UNION

SELECT Vendors.VendName, 
	Vendors.VendStreetAddress,
	Vendors.VendCity,
	Vendors.VendState,
	Vendors.VendZipCode
FROM Vendors;

-- Show me all the customer and employee names and addresses,
-- including any duplicates, sorted by ZIP Code.
CREATE VIEW Customers_UNION_ALL_Employees AS
SELECT Customers.CustFirstName,
	Customers.CustLastName,
	Customers.CustStreetAddress,
	Customers.CustCity,
	Customers.CustState, Customers.CustZipCode
FROM Customers

UNION ALL

SELECT Employees.EmpFirstName,
	Employees.EmpLastName,
	Employees.EmpStreetAddress, Employees.EmpCity,
	Employees.EmpState, Employees.EmpZipCode
FROM Employees
ORDER BY CustZipCode;
-- Becouse some customers are also employee we need to use 'UNION ALL' to show them all.

-- List all the customers who ordered a bicycle combined with all the customers who ordered a helmet.
CREATE VIEW Customers_Order_Bikes_UNION_Customer_Order_Helmets AS
SELECT Customers.CustFirstName,
	Customers.CustLastName, 'Bike' AS ProdType
FROM Customers INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.OrderNumber = Order_Details.OrderNumber
INNER JOIN Products
ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName ILIKE '%bike%'

UNION

SELECT Customers.CustFirstName,
	Customers.CustLastName, 'Helmet' AS ProdType
FROM Customers INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.OrderNumber = Order_Details.OrderNumber
INNER JOIN Products
ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Products.ProductName ILIKE '%helmet%';

-- List the customers who ordered a helmet together with the vendors who provide helmets.
CREATE VIEW Customer_Helmets_Vendor_Helmets AS
SELECT DISTINCT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	products.productname
FROM salesorders.customers
NATURAL JOIN salesorders.orders
NATURAL JOIN salesorders.order_details
NATURAL JOIN salesorders.products
WHERE products.productname LIKE '%Helmet%'

UNION 

SELECT vendors.vendname, products.productname
FROM salesorders.vendors
NATURAL JOIN salesorders.product_vendors
NATURAL JOIN salesorders.products
WHERE products.productname LIKE '%Helmet%';

-- List customers and all the details from their last order.
CREATE VIEW Customers_Last_Order AS
SELECT Customers.CustFirstName,
	Customers.CustLastName, Orders.OrderNumber,
	Orders.OrderDate,
	Order_Details.ProductNumber,
	Products.ProductName,
	Order_Details.QuantityOrdered
FROM Customers
INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.orderNumber = order_Details.OrderNumber
INNER JOIN Products
ON Products.ProductNumber = order_Details.ProductNumber
WHERE Orders.OrderDate =(
	SELECT MAX(OrderDate)
	FROM Orders AS O2
	WHERE O2.CustomerID = Customers.CustomerID);
	
-- List vendors and a count of the products they sell to us.
CREATE VIEW Vendors_Product_Count AS
SELECT VendName,
	(SELECT COUNT(*)
	FROM Product_Vendors
	WHERE Product_Vendors.VendorID = Vendors.VendorID) AS VendProductCount
FROM Vendors;

-- Display customers who ordered clothing or accessories.
CREATE VIEW Customers_Clothing_Or_Accessories AS
SELECT Customers.CustomerID,
	Customers.CustFirstName,
	Customers.CustLastName
FROM Customers
WHERE Customers.CustomerID = ANY (
	SELECT Orders.CustomerID
	FROM Orders
	INNER JOIN Order_Details
	ON Orders.OrderNumber = Order_Details.OrderNumber
	INNER JOIN Products
	ON Products.ProductNumber = Order_Details.ProductNumber
	INNER JOIN Categories
	ON Categories.CategoryID = Products.CategoryID
	WHERE Categories.CategoryDescription = 'Clothing'
	OR Categories.CategoryDescription = 'Accessories');

-- Display products and the latest date each product was ordered.
CREATE VIEW Products_Last_Date AS
SELECT products.productname, MAX(orders.orderdate)
FROM salesorders.products
LEFT OUTER JOIN (salesorders.order_details
	INNER JOIN salesorders.orders
	USING (ordernumber))
USING (productnumber)
GROUP BY products.productname;

-- List customers who ordered bikes.
CREATE VIEW Customer_Ordered_Bikes_IN AS
SELECT  customers.custfirstname || ' ' || customers.custlastname AS Customer_Name
FROM salesorders.customers
WHERE customers.customerid IN (
	SELECT orders.customerid
	FROM salesorders.orders
	INNER JOIN salesorders.order_details
	USING (ordernumber)
	INNER JOIN salesorders.products
	USING (productnumber)
	INNER JOIN salesorders.categories
	USING (categoryid)
	WHERE categories.categorydescription = 'Bikes');

-- What products have never been ordered?
CREATE VIEW Products_Not_Ordered AS
SELECT products.productname 
FROM salesorders.products
WHERE products.productnumber NOT IN (
	SELECT order_details.productnumber
	FROM salesorders.order_details
	INNER JOIN salesorders.orders
	USING (ordernumber));

-- How many customers do we have in the state of California?
CREATE VIEW Number_Of_California_Customers AS
SELECT COUNT(*) AS Number_Of_CA_Customers
FROM salesorders.customers
WHERE custstate = 'CA';

-- List the product names and numbers that have a quoted price greater
-- than or equal to the overall average retail price in the products table.
CREATE VIEW Quoted_Price_Vs_Average_Retail_Price AS
SELECT DISTINCT Products.ProductName,
	Products.ProductNumber
FROM Products
INNER JOIN Order_Details
ON Products.ProductNumber = Order_Details.ProductNumber
WHERE Order_Details.QuotedPrice >=(
	SELECT AVG(RetailPrice)
	FROM Products);
	
-- What is the average retail price of a mountain bike?
CREATE VIEW Average_Price_Of_A_Mountain_Bike AS
SELECT AVG(products.retailprice)
FROM salesorders.products
INNER JOIN salesorders.categories
USING (categoryid)
WHERE categories.categorydescription = 'Bikes';

-- What was the date of our most recent order?
CREATE VIEW Most_Recent_Order_Date AS
SELECT MAX(orders.orderdate)
FROM salesorders.orders;

-- What was the total amount for order number 8?
CREATE VIEW Total_Amount_For_Order_Number_8 AS
SELECT SUM(quotedprice * quantityordered)
FROM salesorders.order_details
WHERE order_details.ordernumber = 8;

-- List for each customer and order date the customer full name and the
-- total cost of items ordered on each date.
CREATE VIEW Order_Totals_By_Customer_And_Date AS
SELECT Customers.CustFirstName || ' ' || Customers.CustLastName AS CustFullName,
	Orders.OrderDate,
	SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered) AS TotalCost
FROM Customers
INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY Customers.CustFirstName,
	Customers.CustLastName, 
	Orders.OrderDate;
	
-- Show me each vendor and the average by vendor of the number of days to deliver products.”
CREATE VIEW Vendor_Avg_Delivery AS
SELECT vendors.vendname, AVG(product_vendors.daystodeliver)
FROM salesorders.vendors
NATURAL JOIN salesorders.product_vendors
GROUP BY vendors.vendname;

-- Display for each product the product name and the total sales.
CREATE VIEW Sales_By_Product AS
SELECT products.productname, SUM(quotedprice * quantityordered) AS Total_Sales
FROM salesorders.products
NATURAL JOIN salesorders.order_details
GROUP BY products.productname;

-- List all vendors and the count of products sold by each.
CREATE VIEW Vendor_Product_Count_Group AS
SELECT vendors.vendname, COUNT(*)
FROM salesorders.vendors
NATURAL JOIN salesorders.product_vendors
GROUP BY vendors.vendname;

-- List for each customer and order date the customer’s full name and
-- the total cost of items ordered that is greater than $1,000.
CREATE VIEW Order_Totals_By_Customer_And_Date_Over_1000 AS
SELECT Customers.CustFirstName || ' ' || Customers.CustLastName AS CustFullName,
	Orders.OrderDate,
	SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered) AS TotalCost
FROM Customers
INNER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details
ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY Customers.CustFirstName,
	Customers.CustLastName, 
	Orders.OrderDate
HAVING SUM(Order_Details.QuotedPrice * Order_Details.QuantityOrdered) > 1000;

-- Show me each vendor and the average by vendor of the number of
-- days to deliver products that are greater than the average delivery days for all vendors.
CREATE VIEW Vendor_Avg_Delivery_Over_Overall_Avg AS
SELECT vendors.vendname, AVG(daystodeliver)
FROM salesorders.vendors
NATURAL JOIN salesorders.product_vendors
GROUP BY vendors.vendname
HAVING AVG(daystodeliver) > (
	SELECT AVG(daystodeliver)
	FROM salesorders.product_vendors);
	
-- Display for each product the product name and the total sales
-- that is greater than the average of sales for all products in that category.
CREATE VIEW Sales_By_Product_Over_Category_Avg AS
SELECT productname, categoryid, SUM(quotedprice * quantityordered) 
FROM salesorders.products
NATURAL JOIN  salesorders.order_details
GROUP BY productname, categoryid
HAVING SUM(quotedprice * quantityordered) > (
	SELECT AVG(t1.totals)
	FROM (
		SELECT p1.categoryid, SUM(quotedprice * quantityordered) AS totals
		FROM salesorders.products AS p1
		NATURAL JOIN salesorders.order_details
		GROUP BY p1.categoryid, p1.productnumber ) AS t1
	WHERE t1.categoryid = products.categoryid
	GROUP BY t1.categoryid );

-- How many orders are for only one product?
CREATE VIEW Single_Item_Order_Count AS
SELECT COUNT(*) AS One_Product_Orders
FROM salesorders.orders
WHERE orders.ordernumber IN (
	SELECT order_details.ordernumber
	FROM salesorders.order_details
	GROUP BY ordernumber
	HAVING COUNT(*)= 1);
	