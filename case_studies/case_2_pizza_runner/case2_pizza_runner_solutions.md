## 8 Week SQL Challenge
# Case Study # 2: Pizza Runner (SQL Solutions)

**Author:** Andres Guerrero <br />
**Email:** peqwar@gmail.com <br />
**LinkedIn:** <a href="https://www.linkedin.com/in/peqwar/" target="_blank">https://www.linkedin.com/in/peqwar/</a>

**Published:** January 23, 2024

## Data Cleaning
#### `customer_orders`
Before writing our SQL queries, we have to first clean the data. There are inconsistent data types in the `customer_orders` table, and we find that columns `exclusions` and `extras` contain values that are either 'null' (text), null (data type) or '' (empty). 
    We will correct this by creating a temporary table.

#### Original table
```sql
SELECT * 
FROM pizza_runner.customer_orders;
```
**Results:**

order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------|-----------|--------|----------|------|-----------------------|
1|        101|       1|          |      |2021-01-01 18:05:02.000|
2|        101|       1|          |      |2021-01-01 19:00:52.000|
3|        102|       1|          |      |2021-01-02 23:51:23.000|
3|        102|       2|          |NaN   |2021-01-02 23:51:23.000|
4|        103|       1|4         |      |2021-01-04 13:23:46.000|
4|        103|       1|4         |      |2021-01-04 13:23:46.000|
4|        103|       2|4         |      |2021-01-04 13:23:46.000|
5|        104|       1|null      |1     |2021-01-08 21:00:29.000|
6|        101|       2|null      |null  |2021-01-08 21:03:13.000|
7|        105|       2|null      |1     |2021-01-08 21:20:29.000|
8|        102|       1|null      |null  |2021-01-09 23:54:33.000|
9|        103|       1|4         |1, 5  |2021-01-10 11:22:59.000|
10|        104|       1|null      |null  |2021-01-11 18:34:49.000|
10|        104|       1|2, 6      |1, 4  |2021-01-11 18:34:49.000|
<br />

```sql
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
```
**Results:**
order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------|-----------|--------|----------|------|-----------------------|
1|        101|       1|[NULL]    |[NULL]|2021-01-01 18:05:02.000|
2|        101|       1|[NULL]    |[NULL]|2021-01-01 19:00:52.000|
3|        102|       1|[NULL]    |[NULL]|2021-01-02 23:51:23.000|
3|        102|       2|[NULL]    |[NULL]|2021-01-02 23:51:23.000|
4|        103|       1|4         |[NULL]|2021-01-04 13:23:46.000|
4|        103|       1|4         |[NULL]|2021-01-04 13:23:46.000|
4|        103|       2|4         |[NULL]|2021-01-04 13:23:46.000|
5|        104|       1|[NULL]    |1     |2021-01-08 21:00:29.000|
6|        101|       2|[NULL]    |[NULL]|2021-01-08 21:03:13.000|
7|        105|       2|[NULL]    |1     |2021-01-08 21:20:29.000|
8|        102|       1|[NULL]    |[NULL]|2021-01-09 23:54:33.000|
9|        103|       1|4         |1, 5  |2021-01-10 11:22:59.000|
10|        104|       1|[NULL]    |[NULL]|2021-01-11 18:34:49.000|
10|        104|       1|2, 6      |1, 4  |2021-01-11 18:34:49.000|
<br />


#### `customer_orders`
Columns `distance` and `duration` have text and numbers. In order to clean the data, text values will be removed and converted to numeric. 
    All null and NaN values will be converted to null data type in the `cancellation` column.
    Finally, the `pickup_time` column, which is varchar, will be converted to timestamp data type

#### Original table
```sql
SELECT * 
FROM pizza_runner.runner_orders;
```
**Results:**

order_id|runner_id|pickup_time            |distance|duration|cancellation           |
--------|---------|-----------------------|--------|--------|-----------------------|
1|        1|2021-01-01 18:15:34.000|      20|      32|[NULL]                 |
2|        1|2021-01-01 19:10:54.000|      20|      27|[NULL]                 |
3|        1|2021-01-03 00:12:37.000|    13.4|      20|[NULL]                 |
4|        2|2021-01-04 13:53:03.000|    23.4|      40|[NULL]                 |
5|        3|2021-01-08 21:10:57.000|      10|      15|[NULL]                 |
6|        3|                 [NULL]|  [NULL]|  [NULL]|Restaurant Cancellation|
7|        2|2021-01-08 21:30:45.000|      25|      25|[NULL]                 |
8|        2|2021-01-10 00:15:02.000|    23.4|      15|[NULL]                 |
9|        2|                 [NULL]|  [NULL]|  [NULL]|Customer Cancellation  |
10|        1|2021-01-11 18:50:20.000|      10|      10|[NULL]                 |
<br />

```sql
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
```
**Results:**

order_id|runner_id|pickup_time            |distance|duration|cancellation           |
--------|---------|-----------------------|--------|--------|-----------------------|
1|        1|2020-01-01 18:15:34.000|      20|      32|[NULL]                 |
2|        1|2020-01-01 19:10:54.000|      20|      27|[NULL]                 |
3|        1|2020-01-03 00:12:37.000|    13.4|      20|[NULL]                 |
4|        2|2020-01-04 13:53:03.000|    23.4|      40|[NULL]                 |
5|        3|2020-01-08 21:10:57.000|      10|      15|[NULL]                 |
6|        3|                 [NULL]|  [NULL]|  [NULL]|Restaurant Cancellation|
7|        2|2020-01-08 21:30:45.000|      25|      25|[NULL]                 |
8|        2|2020-01-10 00:15:02.000|    23.4|      15|[NULL]                 |
9|        2|                 [NULL]|  [NULL]|  [NULL]|Customer Cancellation  |
10|        1|2020-01-11 18:50:20.000|      10|      10|[NULL]                 |
<br />
# Case Study Questions - 
## A. Pizza Metrics:


### **1.** How many pizzas were ordered?

<details>
  <summary>See query.</summary>

```sql
SELECT
	COUNT(*) AS number_of_orders
FROM
	clean_customer_orders;
```
</details>
<br />

**Results:**

number_of_orders|
----------------|
14|

### **2.** How many unique customer orders were made?

<details>
  <summary>See query.</summary>

```sql
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM
	clean_customer_orders; 
```

</details>
<br />

**Results:**

unique_orders|
-------------|
10|



### **3.** How many successful orders were delivered by each runner?

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**

runner_id|successful_orders|
---------|-----------------|
1|                4|
2|                3|
3|                1|


### **4.** How many of each type of pizza was delivered?

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**
pizza_name|delivery_count|
----------|--------------|
Meatlovers|             9|
Vegetarian|             3|


### **5.** How many Vegetarian and Meatlovers were ordered by each customer?

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**
customer_id|meat_lovers|vegetarian|
-----------|-----------|----------|
101|          2|         1|
102|          2|         1|
103|          3|         1|
104|          3|         0|
105|          0|         1|


### **6.** What was the maximum number of pizzas delivered in a single order? 

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**
max_delivered_pizzas|
--------------------|
3|


### **7.** For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**
customer_id|with_changes|no_changes|
-----------|------------|----------|
101|           0|         2|
102|           0|         3|
103|           3|         0|
104|           2|         1|
105|           1|         0|


### **8.** How many pizzas were delivered that had both exclusions and extras?

<details>
  <summary>See query.</summary>

```sql
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

```
</details>
<br />

**Results:**
number_of_pizzas|
----------------|
1|


### **9.** What was the total volume of pizzas ordered for each hour of the day?

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**
hour_of_day_24h|hour_of_day_12h|number_of_pizzas|
---------------|---------------|----------------|
11             |11:AM          |               1|
13             |01:PM          |               3|
18             |06:PM          |               3|
19             |07:PM          |               1|
21             |09:PM          |               3|
23             |11:PM          |               3| 


### **10.** What was the volume of orders for each day of the week?	

<details>
  <summary>See query.</summary>

```sql
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
```
</details>
<br />

**Results:**
day_of_week|number_of_pizzas|
-----------|----------------|
Sunday     |               1|
Monday     |               5|
Friday     |               5|
Saturday   |               3|

