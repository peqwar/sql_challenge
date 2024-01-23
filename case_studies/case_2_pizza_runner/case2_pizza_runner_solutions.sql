/*

==========================================
	8 Week SQL Challenge
	Case Study # 2: Pizza Runner (SQL Solutions)
==========================================
	SQL Challenge Creator: Danny Ma (https://www.linkedin.com/in/datawithdanny/) (https://www.datawithdanny.com/)
	SQL Challenge Location: https://8weeksqlchallenge.com/
    
    SQL Author: Andres Guerrero
	Email: peqwar@gmail.com 
	LinkedIn: https://www.linkedin.com/in/peqwar/
    
	Published: January 23, 2024
	*/
    
    /*

Cleaning customer_oders table data

	Before writing our SQL queries, we have to first clean the data. There are inconsistent data types in the customer_orders table, and we find that
    columns exclusions and extras contain values that are either 'null' (text), null (data type) or '' (empty). 
    We will correct this by creating a temporary table.

*/
    

-- Creating a clean table from customer_orders
DROP TABLE IF EXISTS clean_customer_orders;
CREATE TEMPORARY TABLE clean_customer_orders AS (
	SELECT
		order_id,
		customer_id,
		pizza_id,
		CASE
			-- Check if exclusions is either empty or has the string value 'null'
			WHEN exclusions = '' OR exclusions = 'null' OR exclusions = 'NaN' THEN NULL
			ELSE exclusions
		END AS exclusions,
		CASE
			-- Check if extras is either empty or has the string value 'null'
			WHEN extras = '' OR extras LIKE 'null' OR extras = 'NaN' THEN NULL
			ELSE extras
		END AS extras,
		order_time
	FROM
		pizza_runner.customer_orders
);

SELECT * 
FROM clean_customer_orders;
    
    /*

Cleaning runner_orders table data

	Columns distance and duration have text and numbers. In order to clean the data, text values will be removed and converted to numeric. 
    All null and NaN values will be converted to null data type in the cancellation column.alter
    Finally, the pickup time column, which is varchar, will be converted to timestamp data type

*/
-- Creating a clean table from customer_orders    
DROP TABLE IF EXISTS clean_runner_orders;
CREATE TEMPORARY TABLE clean_runner_orders AS (
    SELECT
        order_id,
        runner_id,
        CASE
            WHEN pickup_time LIKE 'null' THEN NULL
            ELSE STR_TO_DATE(pickup_time, '%Y-%m-%d %H:%i:%s')
        END AS pickup_time,
        CAST(NULLIF(REGEXP_REPLACE(distance, '[^0-9.]', ''), '') AS DECIMAL) AS distance,
        CAST(NULLIF(REGEXP_REPLACE(duration, '[^0-9.]', ''), '') AS DECIMAL) AS duration,
        CASE
            WHEN cancellation LIKE 'null'
                OR cancellation LIKE 'NaN' 
                OR cancellation LIKE '' THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM
        pizza_runner.runner_orders
);
SELECT * 
FROM clean_runner_orders;
   
    
-- ==========================================
-- Case Study Questions:
-- A. Pizza Metrics 
-- ==========================================
-- 1. How many pizzas were ordered?
      
SELECT
	COUNT(*) AS number_of_orders
FROM
	clean_customer_orders;
    
-- 2. How many unique customer orders were made?
   
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM
	clean_customer_orders;    
    
-- 3. How many successful orders were delivered by each runner?

SELECT
	runner_id,
	COUNT(order_id) AS successful_orders
FROM
	clean_runner_orders
WHERE
	cancellation IS NULL
GROUP BY
	runner_id
ORDER BY
	successful_orders DESC;
    
-- 4. How many of each type of pizza was delivered?
        
SELECT
	t2.pizza_name,
	COUNT(*) AS delivery_count
FROM
	clean_customer_orders AS t1
JOIN 
	pizza_names AS t2
ON
	t2.pizza_id = t1.pizza_id
JOIN 
	clean_runner_orders AS t3
ON
	t1.order_id = t3.order_id
WHERE
	cancellation IS NULL
GROUP BY
	t2.pizza_name
ORDER BY
	delivery_count DESC;
    
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	customer_id,
	SUM(
		CASE
			WHEN pizza_id = 1 THEN 1 
			ELSE 0
		END
	) AS meat_lovers,
	SUM(
		CASE
			WHEN pizza_id = 2 THEN 1 
			ELSE 0
		END
	) AS vegetarian
FROM
	clean_customer_orders
GROUP BY
	customer_id
ORDER BY 
	customer_id;
    
-- 6. What was the maximum number of pizzas delivered in a single order?       
        
WITH order_count_cte AS (
	SELECT	
		t1.order_id,
		COUNT(t1.pizza_id) AS n_orders
	FROM 
		clean_customer_orders AS t1
	JOIN 
		clean_runner_orders AS t2
	ON 
		t1.order_id = t2.order_id
	WHERE
		t2.cancellation IS NULL
	GROUP BY 
		t1.order_id
)
SELECT
	MAX(n_orders) AS max_delivered_pizzas
FROM order_count_cte;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
	t1.customer_id,
	SUM(
		CASE
			WHEN t1.exclusions IS NOT NULL OR t1.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS with_changes,
	SUM(
		CASE
			WHEN t1.exclusions IS NULL AND t1.extras IS NULL THEN 1
			ELSE 0
		END
	) AS no_changes
FROM
	clean_customer_orders AS t1
JOIN 
	clean_runner_orders AS t2
ON 
	t1.order_id = t2.order_id
WHERE
	t2.cancellation IS NULL
GROUP BY
	t1.customer_id
ORDER BY
	t1.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
        
SELECT
	SUM(
		CASE
			WHEN t1.exclusions IS NOT NULL AND t1.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS number_of_pizzas
FROM 
	clean_customer_orders AS t1
JOIN 
	clean_runner_orders AS t2
ON 
	t1.order_id = t2.order_id
WHERE 
	t2.cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
    -- Extracting the hour from order_time
    EXTRACT(HOUR FROM order_time) AS hour_of_day_24h,
    -- Formatting the hour in 12-hour time format
    DATE_FORMAT(order_time, '%h: %p') AS hour_of_day_12h,
    COUNT(*) AS number_of_pizzas
FROM 
    clean_customer_orders
WHERE 
    order_time IS NOT NULL
GROUP BY 
    hour_of_day_24h,
    hour_of_day_12h
ORDER BY 
    hour_of_day_24h;


-- 10. What was the volume of orders for each day of the week?

SELECT
    -- Formatting the day of the week
    DAYNAME(order_time) AS day_of_week,
    COUNT(*) AS number_of_pizzas
FROM 
    clean_customer_orders
GROUP BY 
    day_of_week,
    DAYOFWEEK(order_time)
ORDER BY 
    DAYOFWEEK(order_time);



        

