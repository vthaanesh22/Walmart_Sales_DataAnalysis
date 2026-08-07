/*==========================================================
          WALMART SALES DATA ANALYSIS PROJECT
============================================================

Project Name : Walmart Sales Data Analysis
Database     : MySQL
Tools Used   : MySQL Workbench
==========================================================*/
##1.Select Database
USE walmart_db;

##2.Check Dataset
SELECT *
FROM walmart
LIMIT 10;

##3.Check Total Records
SELECT COUNT(*) AS total_records
FROM walmart;

##4.Data Cleaning
## Check NULL values
SELECT *
FROM walmart
WHERE invoice_id IS NULL
OR Branch IS NULL
OR City IS NULL
OR category IS NULL
OR unit_price IS NULL
OR quantity IS NULL
OR date IS NULL
OR time IS NULL
OR payment_method IS NULL
OR rating IS NULL
OR profit_margin IS NULL
OR total IS NULL;

##5.Feature Engineering
##Add Shift Column
ALTER TABLE walmart
ADD COLUMN shift VARCHAR(20);

##Update values
UPDATE walmart
SET shift =
CASE
    WHEN TIME(time) < '12:00:00'
        THEN 'Morning'

    WHEN TIME(time) >= '12:00:00'
     AND TIME(time) < '17:00:00'
        THEN 'Afternoon'

    ELSE 'Evening'
END;
##Check
SELECT
time,
shift
FROM walmart
LIMIT 20;
##Add Day Name
ALTER TABLE walmart
ADD COLUMN day_name VARCHAR(20);
##Update
UPDATE walmart
SET day_name =
DAYNAME(
STR_TO_DATE(date,'%d/%m/%y')
);
##Check
SELECT
date,
day_name
FROM walmart
LIMIT 20;
##Add Month Name
ALTER TABLE walmart
ADD COLUMN month_name VARCHAR(20);
##Update
UPDATE walmart
SET month_name =
MONTHNAME(
STR_TO_DATE(date,'%d/%m/%y')
);
##check 
SELECT
date,
month_name
FROM walmart
LIMIT 20;

#6. Verify Feature Engineering
SELECT
invoice_id,
date,
time,
shift,
day_name,
month_name
FROM walmart
LIMIT 20;

##7. Create Backup
CREATE TABLE walmart_backup AS
SELECT *
FROM walmart;
##Verify
SELECT COUNT(*)
FROM walmart_backup;

#8. Create 2026 Dataset
CREATE TABLE walmart_2026 AS
SELECT *
FROM walmart_backup;

##9. Convert Years
##Convert Walmart to 2025
UPDATE walmart
SET date =
CONCAT(
LEFT(date,6),
'25'
);

##Convert Walmart_2026 to 2026
UPDATE walmart_2026
SET date =
CONCAT(
LEFT(date,6),
'26'
);

##10. Create Realistic Revenue Difference
UPDATE walmart_2026
SET total =
CASE

WHEN branch IN ('WALM001','WALM002','WALM003')
THEN total*0.75

WHEN branch IN ('WALM004','WALM005','WALM006')
THEN total*0.85

WHEN branch IN ('WALM007','WALM008','WALM009')
THEN total*0.95

ELSE total*(1-(RAND()*0.20+0.05))

END;


#11. Merge Both Years
TRUNCATE TABLE walmart;
INSERT INTO walmart
SELECT *
FROM walmart_backup;
UPDATE walmart
SET date =
CONCAT(
LEFT(date,6),
'25'
);
INSERT INTO walmart
SELECT *
FROM walmart_2026;

##12. Verify Dataset
SELECT
RIGHT(date,2) AS year,
COUNT(*) AS records,
ROUND(SUM(total),2) AS revenue
FROM walmart
GROUP BY RIGHT(date,2);

##Walmart Business Problems
##1.What are the different payment methods, and how many transactions and items were sold with each method?
SELECT
    payment_method,
    COUNT(invoice_id) AS no_of_transactions,
    SUM(quantity) AS no_of_items_sold
FROM walmart
GROUP BY payment_method
ORDER BY no_of_transactions DESC;

##2.Which category received the highest average rating in each branch?
SELECT branch,
       category,
       avg_rating
FROM
(
    SELECT
        branch,
        category,
        ROUND(AVG(rating),2) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rankings
    FROM walmart
    GROUP BY branch, category
) AS t
WHERE rankings = 1
ORDER BY branch;


##3.What is the busiest day of the week for each branch based on transaction volume?
SELECT
    branch,
    day_name,
    no_transactions
FROM
(
    SELECT
        branch,
        day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS rankings
    FROM walmart
    GROUP BY branch, day_name
) AS t
WHERE rankings = 1
ORDER BY branch;

##4.Calculate the total quantity sold by each payment method.
SELECT
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method
ORDER BY total_quantity_sold DESC;

##5.Determine the average, minimum, and maximum rating of categories for each city.
SELECT
    city,
    category,
    ROUND(AVG(rating),2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category
ORDER BY city, category;

##6.Calculate the total profit by category and rank the categories from highest to lowest profit.
SELECT
    category,
    ROUND(SUM(total * profit_margin), 2) AS total_profit,
    RANK() OVER(
        ORDER BY SUM(total * profit_margin) DESC
    ) AS profit_rank
FROM walmart
GROUP BY category
ORDER BY profit_rank;

##7.Determine the most common payment method for each branch.
SELECT
    branch,
    payment_method,
    no_transactions
FROM
(
    SELECT
        branch,
        payment_method,
        COUNT(*) AS no_transactions,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS rankings
    FROM walmart
    GROUP BY branch, payment_method
) AS t
WHERE rankings = 1
ORDER BY branch;

##8.Analyze sales shifts throughout the day by counting the number of transactions in each shift for every branch.
SELECT
    branch,
    shift,
    no_transactions
FROM
(
    SELECT
        branch,
        shift,
        COUNT(*) AS no_transactions,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS rankings
    FROM walmart
    GROUP BY branch, shift
) AS t
WHERE rankings = 1
ORDER BY branch;

##9.Identify the 5 branches with the highest decrease ratio in revenue compared to the previous year (2025 vs 2026 in your modified dataset).
WITH revenue AS
(
    SELECT
        branch,
        RIGHT(date,2) AS year,
        ROUND(SUM(total),2) AS revenue
    FROM walmart
    GROUP BY branch, RIGHT(date,2)
)

SELECT
    y25.branch,
    y25.revenue AS revenue_2025,
    y26.revenue AS revenue_2026,
    ROUND(
        ((y25.revenue - y26.revenue) / y25.revenue) * 100,
        2
    ) AS decrease_ratio
FROM revenue y25
JOIN revenue y26
ON y25.branch = y26.branch
WHERE y25.year = '25'
AND y26.year = '26'
AND y25.revenue > y26.revenue
ORDER BY decrease_ratio DESC
LIMIT 5;

##10.Find the percentage of total transactions contributed by each payment method.
SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM walmart),
        2
    ) AS transaction_percentage
FROM walmart
GROUP BY payment_method
ORDER BY transaction_percentage DESC;

##11.Find the best-selling category in every branch based on the total quantity sold.
SELECT
    branch,
    category,
    total_quantity
FROM
(
    SELECT
        branch,
        category,
        SUM(quantity) AS total_quantity,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY SUM(quantity) DESC
        ) AS rankings
    FROM walmart
    GROUP BY branch, category
) AS t
WHERE rankings = 1
ORDER BY branch;

##12.Rank all branches based on their total revenue from highest to lowest.
SELECT
    branch,
    ROUND(SUM(total), 2) AS total_revenue,
    RANK() OVER(
        ORDER BY SUM(total) DESC
    ) AS revenue_rank
FROM walmart
GROUP BY branch
ORDER BY revenue_rank;

##13.Which month generated the highest total revenue?
SELECT
    MONTHNAME(STR_TO_DATE(date, '%d/%m/%y')) AS month_name,
    MONTH(STR_TO_DATE(date, '%d/%m/%y')) AS month_number,
    ROUND(SUM(total), 2) AS total_revenue
FROM walmart
GROUP BY
    MONTHNAME(STR_TO_DATE(date, '%d/%m/%y')),
    MONTH(STR_TO_DATE(date, '%d/%m/%y'))
ORDER BY total_revenue DESC;

##14.Find the branches whose revenue increased by more than 20% from 2025 to 2026.
WITH revenue AS (
    SELECT
        branch,
        RIGHT(date,2) AS year,
        ROUND(SUM(total),2) AS revenue
    FROM walmart
    GROUP BY branch, RIGHT(date,2)
)

SELECT
    y25.branch,
    y25.revenue AS revenue_2025,
    y26.revenue AS revenue_2026,
    ROUND(
        ((y26.revenue - y25.revenue) / y25.revenue) * 100,
        2
    ) AS growth_percentage
FROM revenue y25
JOIN revenue y26
    ON y25.branch = y26.branch
WHERE y25.year = '25'
  AND y26.year = '26'
ORDER BY growth_percentage DESC;

##15.Create an Executive Dashboard that provides a one-page summary of Walmart's business performance.

##SQL Query 1 — Total Revenue
SELECT
ROUND(SUM(total),2) AS total_revenue
FROM walmart;
##SQL Query 2 — Total Profit
SELECT
ROUND(SUM(total * profit_margin),2) AS total_profit
FROM walmart;
##SQL Query 3 — Total Transactions
SELECT
COUNT(invoice_id) AS total_transactions
FROM walmart;
##SQL Query 4 — Average Customer Rating
SELECT
ROUND(AVG(rating),2) AS average_rating
FROM walmart;
##SQL Query 5 — Best Performing Branch
SELECT
branch,
ROUND(SUM(total),2) AS revenue
FROM walmart
GROUP BY branch
ORDER BY revenue DESC
LIMIT 1;
##SQL Query 6 — Best Performing Category
SELECT
category,
ROUND(SUM(total),2) AS revenue
FROM walmart
GROUP BY category
ORDER BY revenue DESC
LIMIT 1;
##SQL Query 7 — Most Used Payment Method
SELECT
payment_method,
COUNT(*) AS no_transactions
FROM walmart
GROUP BY payment_method
ORDER BY no_transactions DESC
LIMIT 1;
##SQL Query 8 — Best Performing City
SELECT
city,
ROUND(SUM(total),2) AS revenue
FROM walmart
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;