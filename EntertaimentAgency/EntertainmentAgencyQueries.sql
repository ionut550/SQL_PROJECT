-- For this Script to work you need to run 'EntertainmentAgencyStructure.sql' and 'EntertainmentAgencyData.sql' first.

SET search_path TO EntertainmentAgency;

-- List all entertainers and the cities they’re based in, and sort the results by city and name in ascending order.
CREATE VIEW Entertainer_Location AS 
SELECT entertainers.entcity, entertainers.entstagename 
FROM entertainmentagency.entertainers
ORDER BY entertainers.entcity ASC, entertainers.entstagename ASC;
-- 'ORDER BY' default ordering is 'ASC' but for clarity I put them there

-- Give me a unique list of engagement dates. I’m not concerned with how many engagements there are per date.
CREATE VIEW Engagements_Dates AS
SELECT DISTINCT engagements.startdate
FROM entertainmentagency.engagements;

-- Give me the names and phone numbers of all our agents, and list them in last name/first name order.
CREATE VIEW Agents_Phone_List AS
SELECT agents.agtlastname || ' ' || agents.agtfirstname AS Agent_Name,
	agents.agtphonenumber
FROM entertainmentagency.agents
ORDER BY agents.agtlastname, agents.agtfirstname;

-- Give me the information on all our engagements.
CREATE VIEW Engagement_Information AS
SELECT *
FROM entertainmentagency.engagements;
-- Here I used '*' as a shortcut for fetching all the information about Engagements

-- List all engagements and their associated start dates. Sort
-- the records by date in descending order and by engagement in ascending order.
CREATE VIEW Scheduled_Engagements AS
SELECT engagements.engagementnumber, engagements.startdate
FROM entertainmentagency.engagements
ORDER BY engagements.startdate DESC, engagements.engagementnumber ASC;

-- How long is each engagement due to run?
CREATE VIEW Engagements_Lengths AS
SELECT engagements.engagementnumber, 
	CAST(CAST(enddate - startdate AS INTEGER)+1 AS CHARACTER) || ' day(s)' AS DueToRun
FROM entertainmentagency.engagements;
-- I used 'CAST' function to make sure that the dates difference will be an Integer 
-- and the results of the sum will be a Character, becouse will be concatenated with a string.

-- What is the net amount for each of our contracts?
CREATE VIEW Net_Amount_Per_Contract AS
SELECT engagements.engagementnumber, engagements.contractprice,
	engagements.contractprice * 0.12 AS OurFee,
	engagements.contractprice - (engagements.contractprice * 0.12) AS NetAmount
FROM entertainmentagency.engagements;

-- Give me the names of all our customers by city.
CREATE VIEW Customers_By_City AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	customers.custcity
FROM entertainmentagency.customers
ORDER BY customers.custcity;

-- List all entertainers and their Web sites.
CREATE VIEW Entertainer_Web_Sites AS
SELECT entertainers.entstagename, entertainers.entwebpage
FROM entertainmentagency.entertainers;

-- Show the date of each agent’s first six-month performance review.
CREATE VIEW Firs_Performance_Review AS
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name,
	agents.datehired AS Hire_Date,
	agents.datehired + 180 AS Performance_Review_Date
FROM entertainmentagency.agents;

-- Show me an alphabetical list of entertainers based in Bellevue, Redmond, or Woodinville.
CREATE VIEW Eastside_Entertainers AS 
SELECT entertainers.entstagename, entertainers.entphonenumber,
	entertainers.entcity
FROM entertainmentagency.entertainers
WHERE entertainers.entcity IN ('Bellevue', 'Redmond', 'Woodinville')
ORDER BY entertainers.entstagename;

-- Show me all the engagements that run for four days.
CREATE VIEW Four_Days_Engagements AS
SELECT engagements.engagementnumber, engagements.startdate, engagements.enddate
FROM entertainmentagency.engagements
WHERE CAST(engagements.enddate - engagements.startdate AS INTEGER) = 3;

-- Let me see a list of all engagements that occurred during October 2017.
CREATE VIEW October_2017_Engagements AS 
SELECT engagements.engagementnumber, engagements.startdate, engagements.enddate
FROM entertainmentagency.engagements
WHERE engagements.startdate <= '2017-10-31' AND engagements.enddate >= '2017-10-01';
-- To accurately find all the engagements that occur during October we need to find 
-- which started before 31.10.2017 and which one ended after 01.10.2017

--Show me any engagements in October 2017 that start between noon and 5 p.m.
CREATE VIEW October_Engagements_Between_Noon_And_Five AS 
SELECT engagements.engagementnumber, engagements.startdate, engagements.enddate
FROM entertainmentagency.engagements
WHERE engagements.startdate <= '2017-10-31' AND engagements.enddate >= '2017-10-01'
	AND engagements.starttime <= '17:00' AND engagements.stoptime >= '12:00';

--List all the engagements that start and end on the same day.
CREATE VIEW Single_Day_Engagements AS
SELECT engagements.engagementnumber
FROM entertainmentagency.engagements
WHERE engagements.startdate = engagements.enddate;

-- Show me entertainers, the start and end dates of their contracts, and the contract price.
CREATE VIEW Entertainers_And_Contracts AS
SELECT entertainers.entstagename,
	engagements.startdate,
	engagements.enddate,
	engagements.contractprice
FROM entertainmentagency.entertainers
	INNER JOIN entertainmentagency.engagements
	ON entertainers.entertainerid = engagements.entertainerid;

-- Find the entertainers who played engagements for customers Berg or Hallmark.
CREATE VIEW Entertainer_For_Berg_Or_Hallmark AS
SELECT DISTINCT Entertainers.EntStageName
FROM entertainmentagency.Entertainers
	INNER JOIN entertainmentagency.Engagements
	ON Entertainers.EntertainerID = Engagements.EntertainerID
	INNER JOIN entertainmentagency.Customers
	ON Customers.CustomerID = Engagements.CustomerID
WHERE Customers.CustLastName = 'Berg' OR Customers.CustLastName = 'Hallmark';

-- List the entertainers who played engagements for both customers Berg and Hallmark.
CREATE VIEW Entertainers_Berg_And_Hallmark AS 
SELECT EntBerg.EntStageName
FROM(
	SELECT DISTINCT Entertainers.EntertainerID,
		Entertainers.EntStageName
	FROM entertainmentagency.Entertainers
		INNER JOIN entertainmentagency.Engagements
		ON Entertainers.EntertainerID = Engagements.EntertainerID
		INNER JOIN entertainmentagency.Customers
		ON Customers.CustomerID = Engagements.CustomerID
	WHERE Customers.CustLastName = 'Berg') AS EntBerg 
	INNER JOIN (
		SELECT DISTINCT Entertainers.EntertainerID,
				Entertainers.EntStageName
		FROM entertainmentagency.Entertainers
		INNER JOIN entertainmentagency.Engagements
		ON Entertainers.EntertainerID = Engagements.EntertainerID
		INNER JOIN entertainmentagency.Customers
		ON Customers.CustomerID = Engagements.CustomerID
		WHERE Customers.CustLastName = 'Hallmark') AS EntHallmark
	ON EntBerg.EntertainerID = EntHallmark.EntertainerID;
-- Now becouse we have to find out which entertainer played for both customers 
-- we fetch who played for Bers, then we fetch who played for Hallmark and we join them to find common entertainers.

-- Display agents and the engagement dates they booked, sorted by booking start date.
CREATE VIEW Agents_Booked_Dates AS
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name,
	engagements.engagementnumber, 
	engagements.startdate
FROM entertainmentagency.agents
INNER JOIN entertainmentagency.engagements
ON agents.agentid = engagements.agentid
ORDER BY engagements.startdate ASC;

-- List customers and the entertainers they booked.
CREATE VIEW Customers_Booked_Entertainers AS 
SELECT DISTINCT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	entertainers.entstagename
FROM entertainmentagency.customers
INNER JOIN entertainmentagency.engagements
ON customers.customerid = engagements.customerid
INNER JOIN entertainmentagency.entertainers
ON engagements.entertainerid = entertainers.entertainerid;
-- I used 'DISTINCT' becouse a customer booked more than one time the same entertainer.

-- Find the agents and entertainers who live in the same postal code.
CREATE VIEW Agents_Entertainers_Same_Postal AS
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name,
	entertainers.entstagename,
	agents.agtzipcode
FROM entertainmentagency.agents
INNER JOIN entertainmentagency.entertainers
ON agents.agtzipcode = entertainers.entzipcode;
-- Becouse we need to find the same zip code we can join on that column.

-- List entertainers who have never been booked.
CREATE VIEW Entertainers_Never_Booked AS
SELECT Entertainers.EntertainerID,
	Entertainers.EntStageName
FROM entertainmentagency.Entertainers
LEFT OUTER JOIN entertainmentagency.Engagements
ON Entertainers.EntertainerID = Engagements.EntertainerID
WHERE Engagements.EngagementNumber IS NULL;

-- Show me all musical styles and the customers who prefer those styles.
CREATE VIEW All_Styles_And_Any_Customers AS 
SELECT Musical_Styles.StyleID,
Musical_Styles.StyleName,
Customers.CustomerID,
Customers.CustFirstName,
Customers.CustLastName
FROM entertainmentagency.Musical_Styles
LEFT OUTER JOIN (Musical_Preferences
	INNER JOIN entertainmentagency.Customers
	ON Musical_Preferences.CustomerID = Customers.CustomerID)
ON Musical_Styles.StyleID = Musical_Preferences.StyleID;

-- Display agents who haven’t booked an entertainer.
CREATE VIEW Agents_No_Contracts AS
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name,
	engagements.entertainerid
FROM entertainmentagency.agents
LEFT OUTER JOIN entertainmentagency.engagements
ON agents.agentid = engagements.agentid
WHERE engagements.agentid IS NULL;

-- List customers with no bookings.
CREATE VIEW Customers_No_Bookings AS 
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	engagements.engagementnumber
FROM entertainmentagency.customers
LEFT OUTER JOIN entertainmentagency.engagements
ON customers.customerid = engagements.customerid
WHERE engagements.customerid IS NULL;

-- List all entertainers and any engagements they have booked.
CREATE VIEW All_Entertainers_And_Any_Engagements AS
SELECT entertainers.entstagename, 
	engagements.engagementnumber
FROM entertainmentagency.entertainers
LEFT OUTER JOIN entertainmentagency.engagements
ON entertainers.entertainerid = engagements.entertainerid;

-- Create a list that combines agents and entertainers.
CREATE VIEW UNION_Entertainers AS
SELECT Agents.AgtLastName || ', ' || Agents.AgtFirstName AS Name, 'Agent' AS Type
FROM entertainmentagency.Agents

UNION

SELECT Entertainers.EntStageName, 'Entertainer' AS Type
FROM entertainmentagency.Entertainers;

-- Display a combined list of customers and entertainers.
CREATE VIEW Customers_UNION_Entertainers AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name
FROM entertainmentagency.customers

UNION 

SELECT entertainers.entstagename
FROM entertainmentagency.entertainers;

-- Produce a list of customers who like contemporary music together
-- with a list of entertainers who play contemporary music.
CREATE VIEW Customers_Entertainers_Contemporary AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name,
	musical_styles.stylename
FROM entertainmentagency.customers
INNER JOIN entertainmentagency.musical_preferences
ON customers.customerid = musical_preferences.customerid
INNER JOIN entertainmentagency.musical_styles
ON musical_preferences.styleid = musical_styles.styleid
WHERE musical_styles.stylename = 'Contemporary'

UNION 

SELECT entertainers.entstagename, musical_styles.stylename
FROM entertainmentagency.entertainers
INNER JOIN entertainmentagency.entertainer_styles
ON entertainers.entertainerid = entertainer_styles.entertainerid
INNER JOIN entertainmentagency.musical_styles
ON entertainer_styles.styleid = musical_styles.styleid
WHERE musical_styles.stylename = 'Contemporary';

-- Display all customers and the date of the last booking each made.
CREATE VIEW Customers_Last_Booking AS
SELECT Customers.CustFirstName,
	Customers.CustLastName,
	(SELECT MAX(StartDate)
	FROM entertainmentagency.Engagements
	WHERE Engagements.CustomerID = Customers.CustomerID) AS LastBooking
FROM entertainmentagency.Customers;

-- List the entertainers who played engagements for customer Berg.
CREATE VIEW Entertainers_Berg_EXISTS AS
SELECT Entertainers.EntertainerID,
	Entertainers.EntStageName 
FROM entertainmentagency.Entertainers 
WHERE EXISTS(
	SELECT *
	FROM entertainmentagency.Customers
	INNER JOIN entertainmentagency.Engagements
	ON Customers.CustomerID = Engagements.CustomerID
	WHERE Customers.CustLastName = 'Berg'
	AND Engagements.EntertainerID = Entertainers.EntertainerID);
-- Using EXISTS
CREATE VIEW Entertainers_Berg_IN AS
SELECT Entertainers.EntertainerID,
	Entertainers.EntStageName 
FROM entertainmentagency.Entertainers 
WHERE entertainers.entertainerid IN (
	SELECT engagements.entertainerid
	FROM entertainmentagency.Customers
	INNER JOIN entertainmentagency.Engagements
	ON Customers.CustomerID = Engagements.CustomerID
	WHERE Customers.CustLastName = 'Berg');
-- Using IN, both methods fetch the same rows but to show you can solve a problem with various tehnique.

-- Show me all entertainers and the count of each entertainer’s engagements.
CREATE VIEW Entertainers_Engagements_Count AS
SELECT entertainers.entstagename , (
	SELECT COUNT(*)
	FROM entertainmentagency.engagements
	WHERE entertainers.entertainerid = engagements.entertainerid)
FROM entertainmentagency.entertainers;

-- List customers who have booked entertainers who play country or country rock.
CREATE VIEW Customers_Who_Like_Country AS
SELECT customers.custfirstname || ' ' || customers.custlastname AS Customer_Name
FROM entertainmentagency.customers
WHERE EXISTS (SELECT entertainers.entstagename
	FROM entertainmentagency.engagements
	INNER JOIN entertainmentagency.entertainers
	ON engagements.entertainerid = entertainers.entertainerid
	INNER JOIN entertainmentagency.entertainer_styles
	ON entertainers.entertainerid = entertainer_styles.entertainerid
	INNER JOIN entertainmentagency.musical_styles
	ON entertainer_styles.styleid = musical_styles.styleid
	WHERE engagements.customerid = customers.customerid AND stylename IN ('Country', 'Country Rock'));

-- Find the entertainers who played engagements for customers Berg or Hallmark.
CREATE VIEW Entertainers_Berg_Or_Hallmark_SOME AS
SELECT entertainers.entstagename
FROM entertainmentagency.entertainers
WHERE entertainers.entertainerid = SOME (
	SELECT engagements.entertainerid
	FROM entertainmentagency.engagements
	INNER JOIN entertainmentagency.customers
	ON engagements.customerid = customers.customerid
	WHERE customers.custlastname IN ('Berg', 'Hallmark'));
	
-- Display agents who haven’t booked an entertainer.
CREATE VIEW Bad_Agents AS
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name
FROM entertainmentagency.agents
WHERE agents.agentid NOT IN (
	SELECT engagements.agentid
	FROM entertainmentagency.engagements);

-- List the engagement number and contract price of contracts that occur on the earliest date.
CREATE VIEW Earlies_Contracts AS
SELECT EngagementNumber, ContractPrice
FROM entertainmentagency.Engagements
WHERE StartDate = (
	SELECT MIN(StartDate) 
	FROM entertainmentagency.Engagements);
	
-- What is the average salary of a booking agent?
CREATE VIEW Average_Agent_Salery AS
SELECT AVG(agents.salary)
FROM entertainmentagency.agents;

-- Show me the engagement numbers for all engagements that have
-- a contract price greater than or equal to the overall average contract price.
CREATE VIEW Contract_Price_Over_Average AS
SELECT engagements.engagementnumber
FROM entertainmentagency.engagements
WHERE engagements.contractprice >= (
	SELECT AVG(engagements.contractprice)
	FROM entertainmentagency.engagements);

-- How many of our entertainers are based in Bellevue?
CREATE VIEW Number_Of_Bellevue_Entertainer AS
SELECT COUNT(entertainers.entertainerid)
FROM entertainmentagency.entertainers
WHERE entertainers.entcity = 'Bellevue';

-- Which engagements occur earliest in October 2017?
CREATE VIEW Earliest_October_Engagements AS
SELECT engagements.engagementnumber
FROM entertainmentagency.engagements
WHERE engagements.startdate = (
	SELECT MIN(engagements.startdate)
	FROM entertainmentagency.engagements
	WHERE engagements.startdate <= '2017-10-31' AND engagements.startdate >= '2017-10-01');

-- Show me for each entertainment group the group name, the count of
-- contracts for the group, the total price of all the contracts, the lowest
-- contract price, the highest contract price, and the average price of all the contracts.
CREATE VIEW Aggregate_Contract_Info_By_Customer AS 
SELECT Entertainers.EntStageName,
COUNT(Engagements.EntertainerID) AS NumContracts,
SUM(Engagements.ContractPrice) AS TotPrice,
MIN(Engagements.ContractPrice) AS MinPrice,
MAX(Engagements.ContractPrice) AS MaxPrice,
AVG(Engagements.ContractPrice) AS AvgPrice
FROM entertainmentagency.entertainers
LEFT OUTER JOIN entertainmentagency.engagements
ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntStageName;

-- Display the engagement contract whose price is greater than the sum of all contracts for any other customer.
CREATE VIEW Biggest_Contract AS
SELECT Customers.CustFirstName,
	Customers.CustLastName,
	Engagements.StartDate,
	Engagements.ContractPrice
FROM entertainmentagency.customers
INNER JOIN entertainmentagency.engagements
ON Customers.CustomerID = Engagements.CustomerID
WHERE Engagements.ContractPrice > ALL(
	SELECT SUM(ContractPrice)
	FROM Engagements AS E2
	WHERE E2.CustomerID <> Customers.CustomerID
	GROUP BY E2.CustomerID);
	
-- Display the customer ID, customer full name, and the total of all engagement contract prices.
CREATE VIEW Customer_Total_Spent AS 
SELECT Customers.CustomerID,
Customers.CustFirstName || ' ' || Customers.CustLastName AS CustFullName,
SUM(Engagements.ContractPrice) AS TotalPrice
FROM entertainmentagency.customers
INNER JOIN entertainmentagency.engagements
ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID,
	Customers.CustFirstName,
	Customers.CustLastName;

-- Show me for each customer in the state of Washington the customer
-- full name, the customer full address, the latest contract date for the
-- customer, and the total price of all the contracts.
CREATE VIEW Customers_Total_Contract AS
SELECT CE.CustomerFullName,
	CE.CustomerFullAddress,
	MAX(CE.StartDate) AS LatestDate,
	SUM(CE.ContractPrice) AS TotalContractPrice
FROM (
	SELECT Customers.CustLastName || ', ' ||
		Customers.CustFirstName AS CustomerFullName,
		Customers.CustStreetAddress || ', ' ||
		Customers.CustCity || ', ' ||
		Customers.CustState || ' ' ||
		Customers.CustZipCode AS CustomerFullAddress,
		Engagements.StartDate,
		Engagements.ContractPrice
	FROM entertainmentagency.customers
	INNER JOIN entertainmentagency.engagements
	ON Customers.CustomerID = Engagements.CustomerID
	WHERE Customers.CustState = 'WA') AS CE
	GROUP BY CE.CustomerFullName,
		CE.CustomerFullAddress;

-- Display each entertainment group ID, entertainment group member,
-- and the amount of pay for each member based on the total contract
-- price divided by the number of members in the group.
CREATE VIEW Member_Pay AS
SELECT Entertainers.EntertainerID,
	Members.MbrFirstName, 
	Members.MbrLastName,
	SUM(Engagements.ContractPrice)/(
		SELECT COUNT(*)
		FROM Entertainer_Members AS EM2
 		WHERE EM2.Status <> 3 AND EM2.EntertainerID = Entertainers.EntertainerID) AS MemberPay
FROM ((Members
INNER JOIN Entertainer_Members
ON Members.MemberID = Entertainer_Members.MemberID)
INNER JOIN Entertainers
ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID)
INNER JOIN Engagements
ON Entertainers.EntertainerID = Engagements.EntertainerID
WHERE Entertainer_Members.Status <> 3
GROUP BY Entertainers.EntertainerID,
	Members.MbrFirstName, 
	Members.MbrLastName
ORDER BY Members.MbrLastName;

-- Show each agent’s name, the sum of the contract price for the
-- engagements booked, and the agent’s total commission.
CREATE VIEW Agents_Sales_And_Commissions AS
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name,
	SUM(engagements.contractprice) AS Total_Sales,
	SUM(engagements.contractprice * agents.commissionrate) AS Commission
FROM entertainmentagency.agents
INNER JOIN entertainmentagency.engagements
ON agents.agentid = engagements.agentid
GROUP BY agents.agtfirstname,
	agents.agtlastname;
	
-- Show me the entertainer groups that play in a jazz style and have more than three members.
CREATE VIEW Jazz_Entertainers_More_Than_3 AS 
SELECT Entertainers.EntertainerID,
	Entertainers.EntStageName,
	Count(Entertainer_Members.EntertainerID) AS CountOfMembers
FROM ((Entertainers 
INNER JOIN Entertainer_Members
ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID)
INNER JOIN Entertainer_Styles
ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID)
INNER JOIN Musical_Styles
ON Musical_Styles.StyleID = Entertainer_Styles.StyleID
WHERE Musical_Styles.StyleName = 'Jazz'
GROUP BY Entertainers.EntertainerID,
	Entertainers.EntStageName
HAVING Count(Entertainer_Members.EntertainerID) > 3;

-- Which agents booked more than $3,000 worth of business in December 2017?
CREATE VIEW Agents_Book_Over_3000 AS 
SELECT Agents.AgtFirstName, 
	Agents.AgtLastName,
	SUM(Engagements.ContractPrice) AS TotalBooked
FROM Agents
INNER JOIN Engagements
ON Agents.AgentID = Engagements.AgentID
WHERE Engagements.StartDate BETWEEN '2017-12-01' AND '2017-12-31'
GROUP BY Agents.AgtFirstName, 
	Agents.AgtLastName
HAVING SUM(Engagements.ContractPrice) > 3000;

-- Show me the entertainers who have more than two overlapped bookings.
CREATE VIEW Entertainers_More_Than_2_Overlap AS 
SELECT entertainers.entertainerid,
	entertainers.entstagename
FROM entertainmentagency.entertainers
WHERE (entertainers.entertainerid IN ( 
	SELECT e1.entertainerid
    FROM entertainmentagency.engagements e1
    INNER JOIN entertainmentagency.engagements e2 
	ON e1.entertainerid = e2.entertainerid
    WHERE e1.engagementnumber <> e2.engagementnumber AND e1.startdate <= e2.enddate AND e1.enddate >= e2.startdate
    GROUP BY e1.entertainerid
    HAVING count(*) >= 2));

-- Show each agent’s name, the sum of the contract price for the
-- engagements booked, and the agent’s total commission for agents
-- whose total commission is more than $1,000.
CREATE VIEW Agent_Sales_Big_Commissions AS 
SELECT agents.agtfirstname || ' ' || agents.agtlastname AS Agent_Name,
	SUM(engagements.contractprice) AS Total_Contracts,
	SUM(engagements.contractprice * agents.commissionrate) AS Agent_Commission
FROM entertainmentagency.agents
INNER JOIN entertainmentagency.engagements
ON agents.agentid = engagements.agentid 
GROUP BY agents.agtfirstname,
	agents.agtlastname
HAVING SUM(engagements.contractprice * agents.commissionrate) > 1000;