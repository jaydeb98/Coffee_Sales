-- Describe the Data Types of Different Columns

DESCRIBE coffee_sales;

-- Find the Total Sales of January Month

SELECT 
    ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales
FROM
    coffee_sales;
    
-- Total Sales KPI - MoM Difference and Growth

WITH sales_data AS (
    SELECT 
        MONTH(transaction_date) AS month_num,
        SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee_sales
    WHERE MONTH(transaction_date) IN (4, 5) -- Showing Results for Month April & May
    GROUP BY MONTH(transaction_date)
)
SELECT 
    month_num, 
    ROUND(total_sales) AS Total_Sales, 
    ROUND(
        (total_sales - LAG(total_sales, 1) OVER (ORDER BY month_num)) / 
        LAG(total_sales, 1) OVER (ORDER BY month_num) * 100, 
        2
    ) AS mom_percentage 
FROM sales_data 
ORDER BY month_num;

-- Find the Total Orders of January Month

SELECT 
    COUNT(transaction_id) AS Total_Orders
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1;
    
-- Total Orders KPI - MoM Difference and Growth

WITH orders_data AS (
    SELECT 
        MONTH(transaction_date) AS month_num, 
        COUNT(transaction_id) AS Total_Orders 
    FROM coffee_sales 
    WHERE MONTH(transaction_date) IN (4, 5) 
    GROUP BY MONTH(transaction_date)
)
SELECT 
    month_num, 
    Total_Orders, 
    ROUND(
        (Total_Orders - LAG(Total_Orders, 1) OVER (ORDER BY month_num)) / 
        LAG(Total_Orders, 1) OVER (ORDER BY month_num) * 100, 
        2
    ) AS mom_growth_percentage 
FROM orders_data
ORDER BY month_num;

-- Find the Total Quantity Sold in January Month

SELECT 
    SUM(transaction_qty) AS Total_Quantity_Sold
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1;

-- Total Quantity Sold KPI - MoM Difference & Growth

WITH quantity_sold AS (
    SELECT 
        MONTH(transaction_date) AS month_num, 
        SUM(transaction_qty) AS total_quantity_sold 
    FROM coffee_sales 
    WHERE MONTH(transaction_date) IN (4, 5) 
    GROUP BY MONTH(transaction_date)
)
SELECT 
    month_num, 
    total_quantity_sold, 
    ROUND(
        (total_quantity_sold - LAG(total_quantity_sold, 1) OVER (ORDER BY month_num)) / 
        LAG(total_quantity_sold, 1) OVER (ORDER BY month_num) * 100, 
        2
    ) AS mom_growth_percentage 
FROM quantity_sold 
ORDER BY month_num;

-- Calendar Table : Daily Sales, Quantity, and Total Orders (Show in exact round off values)

SELECT 
    CONCAT(ROUND(SUM(transaction_qty * unit_price) / 1000,
                    1),
            'K') AS Total_Sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),
            'K') AS Total_Orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),
            'K') AS Total_Quantity_Sold
FROM
    coffee_sales
WHERE
    transaction_date = '2023-05-27'; -- Showing Results for 27th May 2023

-- Sales Trend Over Period

SELECT 
    AVG(Total_Sales) AS Average_Sales
FROM
    (SELECT 
        SUM(transaction_qty * unit_price) AS Total_Sales
    FROM
        coffee_sales
    WHERE
        MONTH(transaction_date) = 5
    GROUP BY transaction_date) AS average;
    
-- Daily Sales for January Month

SELECT 
    DAY(transaction_date) AS Days,
    ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);

-- Comparing Daily Sales of January with Average Sales, If Greater then "Above Average" and Lesser then "Below Average" 

SELECT 
    Days, 
    Total_Sales, 
    CASE 
        WHEN Total_Sales > Avg_Sales THEN 'Above Average'
        WHEN Total_Sales < Avg_Sales THEN 'Below Average'
        ELSE 'Average' 
    END AS Sales_Status 
FROM (
    SELECT 
        DAY(transaction_date) AS Days, 
        ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales, 
        ROUND(AVG(SUM(transaction_qty * unit_price)) OVER()) AS Avg_Sales 
    FROM coffee_sales 
    WHERE MONTH(transaction_date) = 1 
    GROUP BY DAY(transaction_date)
) AS sales_data 
ORDER BY Days;

-- Sales by Weekdays and Weekends for January Month

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends' 
        ELSE 'Weekdays' 
    END AS Day_Type, 
    ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales 
FROM coffee_sales 
WHERE MONTH(transaction_date) = 1 
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends' 
        ELSE 'Weekdays' 
    END;


-- Sales by Store Location of January Month

SELECT 
    store_location AS Store_Location,
    ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1
GROUP BY store_location
ORDER BY Total_Sales DESC;

-- Sales by Product Category of January Month

SELECT 
    product_category AS Product_Category,
    ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1
GROUP BY product_category
ORDER BY Total_Sales DESC;

-- Top 10 Products Sold in January Month

SELECT 
    product_type,
    ROUND(SUM(transaction_qty * unit_price)) AS total_sales
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;

-- Sales by Day | Hour (Let's Assume it for January in Tuesday and in 8th Hour)

SELECT 
    COUNT(transaction_id) AS Total_Orders,
    SUM(transaction_qty) AS Total_Quantity_Sold,
    ROUND(SUM(transaction_qty * unit_price)) AS Total_Sales
FROM
    coffee_sales
WHERE
    DAYOFWEEK(transaction_date) = 3
        AND HOUR(transaction_time) = 8
        AND MONTH(transaction_date) = 1;
        
-- Get Sales from Monday to Sunday for the January Month

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_sales
WHERE 
    MONTH(transaction_date) = 1 
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

-- Generate Sales for All Hours for January Month

SELECT 
    HOUR(transaction_time) AS Hour_of_the_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
    coffee_sales
WHERE
    MONTH(transaction_date) = 1
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);
