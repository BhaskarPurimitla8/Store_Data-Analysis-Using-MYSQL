use mydb;

-- Table Analysis
-- 1. Creating table

CREATE TABLE Sales_Data (
    Row_ID int PRIMARY KEY,
    Order_ID VARCHAR(50) NOT NULL,
    Order_Date DATE NOT NULL,
    Ship_Date DATE NOT NULL,
    Ship_Mode VARCHAR(50) NOT NULL,
    Customer_ID VARCHAR(50) NOT NULL,
    Customer_Name VARCHAR(100) NOT NULL,
    Segment VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    Postal_Code VARCHAR(20),
    Region VARCHAR(50) NOT NULL,
    Product_ID VARCHAR(50) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Sub_Category VARCHAR(50) NOT NULL,
    Product_Name VARCHAR(255) NOT NULL,
    Sales DECIMAL(10,2) NOT NULL,
    Quantity DECIMAL NOT NULL CHECK (Quantity > 0),
    Discount DECIMAL(5,2) CHECK (Discount >= 0 AND Discount <= 1),
    Profit DECIMAL(10,2),
    Discount_Amount DECIMAL(10,2),
    Years INT NOT NULL,
    Customer_Duration TEXT NOT NULL,
    Returned_Items TEXT NOT NULL,
    Return_Reason TEXT 
);
-- 2. Check the raw table
DESCRIBE Sales_Data;

-- 3. Import the data
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:/Glucksort/SQL/SQL_Project/Modified_store_data.csv'
INTO TABLE Sales_Data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

-- 4. Check the raw table
DESCRIBE Sales_Data;
select * from Sales_Data limit 5;

-- 5. Database size
SELECT table_schema AS 'Database', 
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'mydb'
GROUP BY table_schema;

-- 6. Table Size
SELECT table_name as 'Table',
ROUND(SUM(index_length+data_length)/1024/1024,2) as 'Size (MB)'
FROM information_schema.tables
WHERE table_schema='mydb' AND table_name='Sales_Data';

-- 7. Dataset Information with your words

-- 8. Row count of data
SELECT COUNT(*) FROM Sales_Data;

-- 9. Column count of data
SELECT COUNT(*) as Column_count
FROM information_schema.columns
WHERE table_schema='mydb' and table_name='Sales_Data';

-- 10. Check dataset information
DESCRIBE Sales_Data;

-- 11.Get column names of data

SHOW columns from Sales_Data;
DESCRIBE Sales_Data;

SELECT column_name FROM information_schema.columns
WHERE table_schema='mydb' and table_name='Sales_Data';

-- 12.Get columns names with data type of data
SELECT column_name,data_type from information_schema.columns
WHERE table_schema='mydb' and table_name='Sales_Data';

DESCRIBE Sales_Data;
select * from Sales_Data;
-- 13. Check null values of store data (use nested query)

SELECT
 SUM(Order_ID IS NULL) AS Order_ID,
 SUM(Order_Date IS NULL) AS Order_Date,
 SUM(Ship_Date IS NULL) AS Ship_Date,
 SUM(Ship_Mode IS NULL) AS Ship_Mode,
 SUM(Customer_ID IS NULL) AS Customer_ID,
 SUM(Customer_Name IS NULL) AS Customer_Name,
 SUM(Segment IS NULL) AS Segment,
 SUM(Country IS NULL) AS Country,
  SUM(City IS NULL) AS City,
 SUM(State IS NULL) AS State,
 SUM(Postal_Code IS NULL) AS Postal_Code,
 SUM(Region IS NULL) AS Region,
 SUM(Product_ID IS NULL) AS Product_ID,
 SUM(Category IS NULL) AS Category,
 SUM(Sub_Category IS NULL) AS Sub_Category,
 SUM(Product_Name IS NULL) AS Product_Name,
 SUM(Sales IS NULL) AS Sales,
 SUM(Quantity IS NULL) AS Quantity,
 SUM(Discount IS NULL) AS Discount,
 SUM(Profit IS NULL) AS Profit,
 SUM(Discount_Amount IS NULL) AS Discount_Amount,
 SUM(Years IS NULL) AS Years,
 SUM(Customer_Duration IS NULL) AS Customer_Duration,
 SUM(Returned_Items IS NULL) AS Returned_Items,
 SUM(Return_Reason IS NULL) AS Return_Reason
 FROM Sales_Data ;


-- 14. Remove Unnecessary columns like Row_Id

ALTER TABLE Store_Data
DROP Row_ID,
DROP Country;

-- 15.	Check the count of united states
SELECT count(Country) FROM Sales_Data;

-- Product Level Analysis
-- 16. What are the unique product categories?
SELECT DISTINCT(Category) FROM Sales_Data;

-- 17. What is the number of products in each category?
SELECT Category,COUNT(Product_ID) 
FROM Sales_Data 
GROUP BY Category;

-- 18. Find the number of Subcategories products that are divided.
SELECT COUNT(DISTINCT Sub_Category) FROM Sales_Data;

-- 19. Find the number of products in each sub-category.
SELECT Sub_Category,COUNT(Product_ID) 
FROM Sales_Data 
GROUP BY Sub_Category 
ORDER BY Sub_Category;

-- 20. Find the number of unique product names

SELECT COUNT(DISTINCT Product_Name) FROM Sales_Data;

-- 21. Which are the Top 10 Products that are ordered frequently?

SELECT Product_Name,SUM(Quantity) as Count
FROM Sales_Data
GROUP BY Product_Name
ORDER BY count DESC
LIMIT 10;


-- 22. Calculate the cost for each Order_ID with respective Product Name
SELECT Order_ID,Product_Name,ROUND(Sales/Quantity,2) as Cost
FROM Sales_Data;

-- 23. Calculate % profit for each Order_ID with respective Product Name.

SELECT Order_ID,Product_Name,ROUND((Profit/Sales)*100,2) as 'Profit Percentage'
FROM Sales_Data;

-- 24. Calculate the overall profit of the store.

SELECT ROUND(SUM(Profit),2) AS Profit FROM Sales_Data;

-- 25. Calculate percentage profit and group by them with Product Name and Order_Id.
SELECT Order_ID,Product_Name,
ROUND((SUM(Profit)/SUM(Sales))*100,2) as Percentage_Profit
FROM Sales_Data
GROUP BY Product_Name,Order_ID;

-- 26. Where can we trim some loses? In Which products? 
-- We can do this by calculating the average sales and profits, and comparing the values to that average.
-- If the sales or profits are below average, then they are not best sellers and 
-- can be analysed deeper to see if it’s worth selling them anymore.
-- Average Sales and profits of all products.
SELECT AVG(Sales) AS avg_sales, AVG(Profit) AS avg_profit
FROM Sales_Data;
-- Products less than average sales and average profits.
SELECT Product_Name, AVG(Sales) AS avg_sales, AVG(Profit) AS avg_profit
FROM Sales_Data
GROUP BY Product_Name
HAVING avg_sales<(SELECT AVG(Sales) FROM Sales_Data)
AND avg_profit <(SELECT AVG(Profit) FROM Sales_Data);


-- 27. Average sales per sub-cat
SELECT Sub_Category,ROUND(AVG(Sales),2) as Avg_Sales
FROM Sales_Data
GROUP BY Sub_Category;


-- 28. Average profit per sub-cat
SELECT Sub_Category, ROUND(AVG(Profit),2) as Avg_Profit
FROM Sales_Data
GROUP BY Sub_Category;

-- Customer Level Analysis

-- 29. What is the number of unique customer IDs?
SELECT COUNT(DISTINCT Customer_ID) FROM Sales_Data;

-- 30. Find those customers who registered during 2014-2016.
SELECT Customer_Name, MIN(Order_Date)
FROM Sales_Data
WHERE YEAR(Order_Date) BETWEEN 2014 AND 2016
GROUP BY Customer_Name;

-- 31. Calculate Total Frequency of each order id by each customer Name in descending order.
SELECT Customer_Name,Order_ID,COUNT(*) AS Frequency
FROM Sales_Data
GROUP BY Customer_Name, Order_ID
ORDER BY Frequency DESC;

-- 32. Calculate cost of each customer name.
select * from Sales_Data;

SELECT Customer_Name, ROUND(SUM(Sales*Quantity),2) as Cost
FROM Sales_Data
GROUP BY Customer_Name;

-- 33. Display No of Customers in each region in descending order.

SELECT Region, COUNT(Customer_Name) AS No_of_Customers
FROM Sales_Data
GROUP BY Region
ORDER BY No_of_Customers DESC;


-- 34. Find Top 10 customers who order frequently.
SELECT Customer_Name, COUNT(Order_id) as No_of_Orders
FROM Sales_Data
GROUP BY Customer_Name
ORDER BY No_of_Orders DESC
LIMIT 10;

-- 35.Display the records for customers who live in state California and Have postal code 90032.

SELECT count(*) FROM Sales_Data
WHERE State='California' and Postal_Code='90032';

-- 36.Find Top 20 Customers who benefitted the store.
SELECT Customer_Name, SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Customer_Name
ORDER BY Total_Profit DESC
LIMIT 20;

-- 37.	Which state(s) is the superstore most succesful in? Least? Top 10 results.
-- Based on no of orders top 10 states
SELECT State,COUNT(Order_ID) as No_of_Orders
FROM Sales_Data
GROUP BY State
ORDER BY No_of_Orders DESC
-- ORDER BY No_of_Orders 
LIMIT 10;

-- Based on Profit Top 10 states
SELECT State,SUM(Profit) as Total_Profit
FROM Sales_Data
GROUP BY State
ORDER BY Total_Profit DESC
LIMIT 10;

-- Based on revenue top 10 states
SELECT State,SUM(Sales*Quantity) as Total_Revenue
FROM Sales_Data
GROUP BY State
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Order level Analysis
-- 38.number of unique orders 
SELECT COUNT(DISTINCT(Order_ID)) FROM Sales_Data;

-- 39.Find Sum Total Sales of Superstore.
SELECT SUM(Sales) FROM Sales_Data;

-- 40.	Calculate the time taken for an order to ship and converting the no. of days in int format. (Show 20)

SELECT Order_ID, DATEDIFF(Ship_Date,Order_Date) AS Time_Taken
FROM Sales_Data
ORDER BY Time_Taken DESC
LIMIT 20;

-- 41.Extract the year for respective order ID and Customer ID with quantity

SELECT Order_ID,Customer_ID,YEAR(Order_Date), Quantity
FROM Sales_Data;

-- 42.What is the Sales impact? (Show 20).
-- yearwise profit percentage
SELECT Years,ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Percentage
FROM Sales_Data
GROUP BY Years
ORDER BY Years;


-- 43.Find Top 10 Categories (with the addition of best sub-category within the category).
SELECT Category,COUNT(Order_ID) AS No_of_Orders 
FROM Sales_Data
GROUP BY Category
ORDER BY No_of_Orders DESC
LIMIT 10;

-- 44
SELECT Category,Sub_Category,COUNT(Order_ID) AS No_of_Orders 
FROM Sales_Data
GROUP BY Category,Sub_Category
ORDER BY No_of_Orders DESC
LIMIT 10;


-- 45.Find Top 10 Sub-Categories.
-- based on no of orders
SELECT Sub_Category,COUNT(Order_ID) AS No_of_Orders 
FROM Sales_Data
GROUP BY Sub_Category
ORDER BY No_of_Orders DESC
LIMIT 10;

-- Based on Profit
SELECT Sub_Category,SUM(Profit) AS Total_profit 
FROM Sales_Data
GROUP BY Sub_Category
ORDER BY Total_profit DESC
LIMIT 10;


-- 46. Find Worst 10 Categories.
-- Based on profit
SELECT Category,SUM(Profit) AS Total_profit 
FROM Sales_Data
GROUP BY Category
ORDER BY Total_profit 
LIMIT 10;

-- Based on no of orders
SELECT Category,COUNT(Order_ID) AS No_of_Orders 
FROM Sales_Data
GROUP BY Category
ORDER BY No_of_Orders
LIMIT 10;

-- 47.Find Worst 10 Sub-Categories.
-- Based on profit
SELECT Sub_Category,SUM(Profit) AS Total_profit 
FROM Sales_Data
GROUP BY Sub_Category
ORDER BY Total_profit
LIMIT 10;

-- Based on orders count
SELECT Sub_Category,COUNT(Order_ID) AS No_of_Orders 
FROM Sales_Data
GROUP BY Sub_Category
ORDER BY No_of_Orders
LIMIT 10;

-- Return Level Analysis
-- 48.Find the number of returned orders.
select * from Sales_Data;

SELECT COUNT(*) FROM Sales_Data 
WHERE Returned_Items='Returned';

-- 49.Find Top 10 Returned Categories.
SELECT Category,COUNT(*) AS Returned_Count 
FROM Sales_Data 
WHERE Returned_Items='Returned'
GROUP BY Category
ORDER BY Returned_Count DESC
LIMIT 10;

-- 50.Find Top 10 Returned Sub-Categories.
SELECT Sub_Category,COUNT(*) AS Returned_Count 
FROM Sales_Data 
WHERE Returned_Items='Returned'
GROUP BY Sub_Category
ORDER BY Returned_Count DESC
LIMIT 10;


-- 51.Find Top 10 Customers Returned Frequently.
SELECT Customer_Name,COUNT(*) AS Returned_Count 
FROM Sales_Data 
WHERE Returned_Items='Returned'
GROUP BY Customer_Name
ORDER BY Returned_Count DESC
LIMIT 10;

-- 52.	Find Top 20 cities and states having higher return.
SELECT State,City,COUNT(*) AS Returned_Count 
FROM Sales_Data 
WHERE Returned_Items='Returned'
GROUP BY State,City
ORDER BY Returned_Count DESC
LIMIT 20;


-- 53.Check whether new customers are returning higher or not (show 20)
SELECT 
    (SUM(CASE WHEN Returned_Items = 'Returned' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS Return_Percentage
FROM Sales_Data
WHERE Customer_Duration = 'new customer';

-- the new customers are returning the fewer orders.

-- 54.Find Top Reasons for returning.
SELECT Return_Reason,COUNT(*) AS Count 
FROM Sales_Data 
WHERE Returned_Items='Returned'
GROUP BY Return_Reason
ORDER BY Count DESC
;
