SELECT * FROM online.retail_cleansing;

SELECT DISTINCT Country
FROM online.retail_cleansing;

SELECT Country,
COUNT(DISTINCT InvoiceNo) AS orders_by_country,
ROUND(SUM(subtotal),2) AS revenue_by_country
FROM online.retail_cleansing
GROUP BY Country
ORDER BY revenue_by_country DESC, orders_by_country DESC;
InvoiceDate
SELECT Country,
ROUND(SUM(subtotal)/COUNT(DISTINCT CustomerID),2) AS consump_customer
FROM online.retail_cleansing
GROUP BY Country
ORDER BY consump_customer DESC;

SELECT MAX(InvoiceDate)
FROM online.retail_cleansing;

CREATE TEMPORARY TABLE CustomerLifecycle
SELECT CustomerID,
COUNT(DISTINCT InvoiceNo) AS num_orders,
MIN(TIMESTAMPDIFF(DAY, InvoiceDate, '2011-12-09 12:50:00')) AS diff
FROM online.retail_cleansing
GROUP BY CustomerID;

CREATE TABLE CustomerCategory AS 
SELECT Customer_label,
COUNT(*) AS num_customers
FROM
(SELECT CustomerID,
CASE WHEN num_orders = 1 AND diff <= 90 THEN 'new' WHEN num_orders = 1 AND diff > 90 THEN 'onetime'
WHEN num_orders > 1 AND diff <= 90 THEN 'returning'
ELSE 'lost' END AS Customer_label
FROM CustomerLifecycle) a
GROUP BY Customer_label;


SELECT ROUND(AVG(diff),0) AS avg_diff,
ROUND(AVG(num_orders),0) AS avg_orders
FROM CustomerLifecycle;

CREATE TEMPORARY TABLE CustomerSubtotal
SELECT CustomerID,
SUM(subtotal) AS sub_customer
FROM online.retail_cleansing
GROUP BY CustomerID;

SELECT * FROM CustomerSubtotal;

SELECT ROUND(AVG(sub_customer),0) AS avg_subtotal
FROM CustomerSubtotal;

CREATE TABLE RFM_label AS
SELECT cl.CustomerID,
num_orders,
diff,
sub_customer,
CASE WHEN diff <= 92 AND num_orders >= 4 AND sub_customer >= 2054 THEN 'Key Value Customers'
WHEN diff <= 92 AND num_orders >= 4 AND sub_customer < 2054 THEN 'Potential Customers'
WHEN diff <= 92 AND num_orders < 4 AND sub_customer >= 2054 THEN 'Key Development Customers'
WHEN diff <= 92 AND num_orders < 4 AND sub_customer < 2054 THEN 'New Customers'
WHEN diff > 92 AND num_orders >= 4 AND sub_customer >= 2054 THEN 'Key Retention Customers'
WHEN diff > 92 AND num_orders >= 4 AND sub_customer < 2054 THEN 'General Keeping Customers'
WHEN diff > 92 AND num_orders < 4 AND sub_customer >= 2054 THEN 'Key Keeping Customers'
WHEN diff > 92 AND num_orders < 4 AND sub_customer < 2054 THEN 'Lost Customers' END AS customer_label
FROM CustomerLifecycle cl
JOIN CustomerSubtotal cs
ON cl.CustomerID = cs.CustomerID;

CREATE TABLE PurchaseInterval AS 
SELECT CustomerID, 
TIMESTAMPDIFF(DAY, InvoiceDate, lead_1) AS time_interval
FROM
(SELECT CustomerID, 
InvoiceDate,
IFNULL(LEAD(InvoiceDate,1) OVER(PARTITION BY CustomerID ORDER BY InvoiceNo),'2011-12-09 12:50:00') AS lead_1
FROM
(SELECT CustomerID,
InvoiceNo,
InvoiceDate
FROM online.retail_cleansing
GROUP BY CustomerID, InvoiceNo, InvoiceDate)a)b
ORDER BY time_interval DESC;

SELECT * FROM PurchaseInterval;

SELECT SUM(CASE WHEN time_interval <=30 THEN 1 ELSE 0 END) AS '0-30',
SUM(CASE WHEN time_interval > 30 AND time_interval <= 60 THEN 1 ELSE 0 END) AS '30-60',
SUM(CASE WHEN time_interval > 60 AND time_interval <= 90 THEN 1 ELSE 0 END) AS '60-90',
SUM(CASE WHEN time_interval > 90 AND time_interval <= 120 THEN 1 ELSE 0 END) AS '90-120',
SUM(CASE WHEN time_interval > 120 AND time_interval <= 150 THEN 1 ELSE 0 END) AS '120-150',
SUM(CASE WHEN time_interval > 150 AND time_interval <= 180 THEN 1 ELSE 0 END) AS '150-180',
SUM(CASE WHEN time_interval > 180 AND time_interval <= 210 THEN 1 ELSE 0 END) AS '180-210',
SUM(CASE WHEN time_interval > 210 AND time_interval <= 240 THEN 1 ELSE 0 END) AS '210-240',
SUM(CASE WHEN time_interval > 240 AND time_interval <= 270 THEN 1 ELSE 0 END) AS '240-270',
SUM(CASE WHEN time_interval > 270 AND time_interval <= 300 THEN 1 ELSE 0 END) AS '270-300',
SUM(CASE WHEN time_interval > 300 AND time_interval <= 330 THEN 1 ELSE 0 END) AS '330-360',
SUM(CASE WHEN time_interval > 330 AND time_interval <= 360 THEN 1 ELSE 0 END) AS '330-360',
SUM(CASE WHEN time_interval > 360 THEN 1 ELSE 0 END) AS 'more than 360'
FROM online.PurchaseInterval;

SELECT ROUND((num_retention)*100.00/4338,2) AS retention_rate
FROM
(SELECT COUNT(*) AS num_retention
FROM CustomerLifecycle
WHERE num_orders>=2)a;

SELECT * FROM retail_cleansing;

CREATE TABLE PurchaseTime AS
SELECT CustomerID,
YEAR(InvoiceDate) AS InvoiceYear,
MONTH(InvoiceDate) AS InvoiceMonth,
DAY(InvoiceDate) AS InvoiceDay
FROM retail_cleansing;

WITH temp_PurchaseTime AS (SELECT * FROM PurchaseTime),

CTE1 AS(SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=1),

CTE2 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=2)

SELECT 2011 AS year,
11 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE1),2) AS rentention_rate
FROM CTE2
WHERE CustomerID IN (SELECT * FROM CTE1);


SELECT min(InvoiceDate)
FROM retail_cleansing;
2010-12-01 08:26:00;
SELECT * FROM PurchaseTime;

SELECT * FROM online.retail_cleansing;

SELECT DISTINCT Country
FROM online.retail_cleansing;

SELECT Country,
COUNT(DISTINCT InvoiceNo) AS orders_by_country,
ROUND(SUM(subtotal),2) AS revenue_by_country
FROM online.retail_cleansing
GROUP BY Country
ORDER BY revenue_by_country DESC, orders_by_country DESC;
InvoiceDate
SELECT Country,
ROUND(SUM(subtotal)/COUNT(DISTINCT CustomerID),2) AS consump_customer
FROM online.retail_cleansing
GROUP BY Country
ORDER BY consump_customer DESC;

SELECT MAX(InvoiceDate)
FROM online.retail_cleansing;

CREATE TEMPORARY TABLE CustomerLifecycle
SELECT CustomerID,
COUNT(DISTINCT InvoiceNo) AS num_orders,
MIN(TIMESTAMPDIFF(DAY, InvoiceDate, '2011-12-09 12:50:00')) AS diff
FROM online.retail_cleansing
GROUP BY CustomerID;

CREATE TABLE CustomerCategory AS 
SELECT Customer_label,
COUNT(*) AS num_customers
FROM
(SELECT CustomerID,
CASE WHEN num_orders = 1 AND diff <= 90 THEN 'new' WHEN num_orders = 1 AND diff > 90 THEN 'onetime'
WHEN num_orders > 1 AND diff <= 90 THEN 'returning'
ELSE 'lost' END AS Customer_label
FROM CustomerLifecycle) a
GROUP BY Customer_label;


SELECT ROUND(AVG(diff),0) AS avg_diff,
ROUND(AVG(num_orders),0) AS avg_orders
FROM CustomerLifecycle;

CREATE TEMPORARY TABLE CustomerSubtotal
SELECT CustomerID,
SUM(subtotal) AS sub_customer
FROM online.retail_cleansing
GROUP BY CustomerID;

SELECT * FROM CustomerSubtotal;

SELECT ROUND(AVG(sub_customer),0) AS avg_subtotal
FROM CustomerSubtotal;

CREATE TABLE RFM_label AS
SELECT cl.CustomerID,
num_orders,
diff,
sub_customer,
CASE WHEN diff <= 92 AND num_orders >= 4 AND sub_customer >= 2054 THEN 'Key Value Customers'
WHEN diff <= 92 AND num_orders >= 4 AND sub_customer < 2054 THEN 'Potential Customers'
WHEN diff <= 92 AND num_orders < 4 AND sub_customer >= 2054 THEN 'Key Development Customers'
WHEN diff <= 92 AND num_orders < 4 AND sub_customer < 2054 THEN 'New Customers'
WHEN diff > 92 AND num_orders >= 4 AND sub_customer >= 2054 THEN 'Key Retention Customers'
WHEN diff > 92 AND num_orders >= 4 AND sub_customer < 2054 THEN 'General Keeping Customers'
WHEN diff > 92 AND num_orders < 4 AND sub_customer >= 2054 THEN 'Key Keeping Customers'
WHEN diff > 92 AND num_orders < 4 AND sub_customer < 2054 THEN 'Lost Customers' END AS customer_label
FROM CustomerLifecycle cl
JOIN CustomerSubtotal cs
ON cl.CustomerID = cs.CustomerID;

CREATE TABLE PurchaseInterval AS 
SELECT CustomerID, 
TIMESTAMPDIFF(DAY, InvoiceDate, lead_1) AS time_interval
FROM
(SELECT CustomerID, 
InvoiceDate,
IFNULL(LEAD(InvoiceDate,1) OVER(PARTITION BY CustomerID ORDER BY InvoiceNo),'2011-12-09 12:50:00') AS lead_1
FROM
(SELECT CustomerID,
InvoiceNo,
InvoiceDate
FROM online.retail_cleansing
GROUP BY CustomerID, InvoiceNo, InvoiceDate)a)b
ORDER BY time_interval DESC;

SELECT * FROM PurchaseInterval;

SELECT SUM(CASE WHEN time_interval <=30 THEN 1 ELSE 0 END) AS '0-30',
SUM(CASE WHEN time_interval > 30 AND time_interval <= 60 THEN 1 ELSE 0 END) AS '30-60',
SUM(CASE WHEN time_interval > 60 AND time_interval <= 90 THEN 1 ELSE 0 END) AS '60-90',
SUM(CASE WHEN time_interval > 90 AND time_interval <= 120 THEN 1 ELSE 0 END) AS '90-120',
SUM(CASE WHEN time_interval > 120 AND time_interval <= 150 THEN 1 ELSE 0 END) AS '120-150',
SUM(CASE WHEN time_interval > 150 AND time_interval <= 180 THEN 1 ELSE 0 END) AS '150-180',
SUM(CASE WHEN time_interval > 180 AND time_interval <= 210 THEN 1 ELSE 0 END) AS '180-210',
SUM(CASE WHEN time_interval > 210 AND time_interval <= 240 THEN 1 ELSE 0 END) AS '210-240',
SUM(CASE WHEN time_interval > 240 AND time_interval <= 270 THEN 1 ELSE 0 END) AS '240-270',
SUM(CASE WHEN time_interval > 270 AND time_interval <= 300 THEN 1 ELSE 0 END) AS '270-300',
SUM(CASE WHEN time_interval > 300 AND time_interval <= 330 THEN 1 ELSE 0 END) AS '330-360',
SUM(CASE WHEN time_interval > 330 AND time_interval <= 360 THEN 1 ELSE 0 END) AS '330-360',
SUM(CASE WHEN time_interval > 360 THEN 1 ELSE 0 END) AS 'more than 360'
FROM online.PurchaseInterval;

SELECT ROUND((num_retention)*100.00/4338,2) AS retention_rate
FROM
(SELECT COUNT(*) AS num_retention
FROM CustomerLifecycle
WHERE num_orders>=2)a;

SELECT * FROM retail_cleansing;

CREATE TABLE PurchaseTime AS
SELECT CustomerID,
YEAR(InvoiceDate) AS InvoiceYear,
MONTH(InvoiceDate) AS InvoiceMonth,
DAY(InvoiceDate) AS InvoiceDay
FROM retail_cleansing;

CREATE TABLE monthly_rentention AS 
WITH temp_PurchaseTime AS (SELECT CustomerID,
YEAR(InvoiceDate) AS InvoiceYear,
MONTH(InvoiceDate) AS InvoiceMonth,
DAY(InvoiceDate) AS InvoiceDay
FROM retail_cleansing),

CTE1 AS(SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2010 AND InvoiceMonth=12),

CTE2 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=1),

DEC_2010_retention AS(
SELECT 2010 AS year,
12 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE1),2) AS rentention_rate
FROM CTE2
WHERE CustomerID IN (SELECT * FROM CTE1)),


CTE3 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=2),

JAN_2011_retention AS (SELECT 2011 AS year,
1 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE2),2) AS rentention_rate
FROM CTE3
WHERE CustomerID IN (SELECT * FROM CTE2)),

CTE4 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=3),

FEB_2011_retention AS (SELECT 2011 AS year,
2 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE3),2) AS rentention_rate
FROM CTE4
WHERE CustomerID IN (SELECT * FROM CTE3)),

CTE5 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=4),

MAR_2011_retention AS (SELECT 2011 AS year,
3 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE4),2) AS rentention_rate
FROM CTE5
WHERE CustomerID IN (SELECT * FROM CTE4)),

CTE6 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=5),

APR_2011_retention AS (SELECT 2011 AS year,
4 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE5),2) AS rentention_rate
FROM CTE6
WHERE CustomerID IN (SELECT * FROM CTE5)),

CTE7 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=6),

MAY_2011_retention AS (SELECT 2011 AS year,
5 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE6),2) AS rentention_rate
FROM CTE7
WHERE CustomerID IN (SELECT * FROM CTE6)),

CTE8 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=7),

JUNE_2011_retention AS (SELECT 2011 AS year,
6 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE7),2) AS rentention_rate
FROM CTE8
WHERE CustomerID IN (SELECT * FROM CTE7)),

CTE9 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=8),

JULY_2011_retention AS (SELECT 2011 AS year,
7 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE8),2) AS rentention_rate
FROM CTE9
WHERE CustomerID IN (SELECT * FROM CTE8)),

CTE10 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=9),

AUG_2011_retention AS (SELECT 2011 AS year,
8 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE9),2) AS rentention_rate
FROM CTE10
WHERE CustomerID IN (SELECT * FROM CTE9)),

CTE11 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=10),

SEP_2011_retention AS (SELECT 2011 AS year,
9 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE10),2) AS rentention_rate
FROM CTE11
WHERE CustomerID IN (SELECT * FROM CTE10)),

CTE12 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=11),

OCT_2011_retention AS (SELECT 2011 AS year,
10 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE11),2) AS rentention_rate
FROM CTE12
WHERE CustomerID IN (SELECT * FROM CTE11)),

CTE13 AS (SELECT DISTINCT CustomerID
FROM temp_PurchaseTime
WHERE InvoiceYear=2011 AND InvoiceMonth=12),

NOV_2011_retention AS (SELECT 2011 AS year,
11 AS month,
ROUND((COUNT(DISTINCT CustomerID))*100.00/(SELECT COUNT(DISTINCT CUstomerID) FROM CTE12),2) AS rentention_rate
FROM CTE13
WHERE CustomerID IN (SELECT * FROM CTE12))

SELECT * FROM DEC_2010_retention
UNION ALL
SELECT * FROM JAN_2011_retention
UNION ALL
SELECT * FROM FEB_2011_retention
UNION ALL
SELECT * FROM MAR_2011_retention
UNION ALL
SELECT * FROM APR_2011_retention
UNION ALL
SELECT * FROM MAY_2011_retention
UNION ALL
SELECT * FROM JUNE_2011_retention
UNION ALL
SELECT * FROM JULY_2011_retention
UNION ALL
SELECT * FROM AUG_2011_retention
UNION ALL
SELECT * FROM SEP_2011_retention
UNION ALL
SELECT * FROM OCT_2011_retention
UNION ALL
SELECT * FROM NOV_2011_retention;



SELECT min(InvoiceDate)
FROM retail_cleansing;
2010-12-01 08:26:00;
SELECT * FROM PurchaseTime;

