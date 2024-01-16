## 8 Week SQL Challenge
# Case Study # 1: Danny's Diner (SQL Solutions)

**Author:** Andres Guerrero <br />
**Email:** peqwar@gmail.com <br />
**LinkedIn:** https://www.linkedin.com/in/peqwar/

**Published:** January 16, 2024

## Case Study Questions:


### **1.** What is the total amount each customer spent at the restaurant?

<details>
  <summary>See query.</summary>

```sql
SELECT
	sales.customer_id AS Customer,
    SUM(menu.price) AS total_amt_spent
FROM
	sales
JOIN
	menu
ON
	sales.product_id = menu.product_id
GROUP BY
	sales.customer_id
ORDER BY
	total_amt_spent DESC;
```
</details>
<br />

**Results:**

customer_id|total_spent|
-----------|-----------|
A          |         76|
B          |         74|
C          |         36|

### **2.** How many days has each customer visited the restaurant?

<details>
  <summary>See query.</summary>

```sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS number_of_days
FROM 
	sales
GROUP BY 
	customer_id
ORDER BY 
	number_of_days DESC;
```

</details>
<br />

**Results:**

| customer_id | number_of_days |
|-------------|----------------|
| B           | 6              |
| A           | 4              |
| C           | 2              |



### **3.** What was the first item from the menu purchased by each customer?

<details>
  <summary>See query.</summary>

```sql
SELECT
    customer_id,
    MIN(order_date) AS first_purchase,
    -- MIN(sales.product_id) AS first_product_id,
    MIN(product_name) AS product_name
FROM
    sales
JOIN
	menu
ON
	sales.product_id = menu.product_id
GROUP BY
    customer_id;
```
</details>
<br />

**Results:**

| customer_id | first_purchase | product_name |
|-------------|----------------|--------------|
| A           | 2021-01-01     | curry        |
| B           | 2021-01-01     | curry        |
| C           | 2021-01-01     | ramen        |


### **4.** What is the most purchased item on the menu and how many times was it purchased by all customers?

<details>
  <summary>See query.</summary>

```sql
SELECT 
	menu.product_name AS product,
    COUNT(sales.product_id) as times_purchased
FROM
	sales
JOIN
	menu
ON
	sales.product_id = menu.product_id
GROUP BY
    product
ORDER BY
	times_purchased DESC
LIMIT 1;
```
</details>
<br />

**Results:**
| product | times_purchased |
|---------|------------------|
| ramen   | 8                |


### **5.** Which item was the most popular for each customer?

<details>
  <summary>See query.</summary>

```sql
WITH cte_most_popular_items AS
(
	SELECT 
			t1.customer_id,
			t2.product_name,
			COUNT(t2.product_id) AS times_purchased,
			RANK() OVER (
				PARTITION BY t1.customer_id 
				ORDER BY COUNT(t2.product_id) DESC) AS popularity_rank
			FROM 
				dannys_diner.sales AS t1
			JOIN 
				dannys_diner.menu as t2
			ON 
				t1.product_id = t2.product_id
			GROUP BY 
				t1.customer_id,
				t2.product_name
)
SELECT
	customer_id,
    product_name,
    times_purchased
FROM
	cte_most_popular_items
WHERE 
	popularity_rank = 1;
```
</details>
<br />

**Results:**
| customer_id | product_name | times_purchased |
|-------------|--------------|------------------|
| A           | ramen        | 3                |
| B           | sushi        | 2                |
| B           | curry        | 2                |
| B           | ramen        | 2                |
| C           | ramen        | 3                |


### **6.** Which item was purchased first by the customer after they became a member?

<details>
  <summary>See query.</summary>

```sql
WITH cte_first_member_purchase AS
(
	SELECT 
		t1.customer_id,
		t3.product_name,
		t1.join_date,
		t2.order_date,	
		RANK() OVER (
			PARTITION BY t1.customer_id 
			ORDER BY t2.order_date) as purchase_rank
	FROM 
		dannys_diner.members AS t1
	JOIN 
		dannys_diner.sales AS t2 
	ON 
		t1.customer_id = t2.customer_id
	JOIN 
		dannys_diner.menu AS t3 
	ON 
		t2.product_id = t3.product_id
	WHERE 
		t2.order_date >= t1.join_date
)
SELECT
	customer_id,
	join_date,
	order_date,
	product_name
FROM 
	cte_first_member_purchase
WHERE 
	purchase_rank = 1;
```
</details>
<br />

**Results:**
| customer_id | join_date | order_date | product_name |
|-------------|-----------|------------|--------------|
| A           | 2021-01-07| 2021-01-07 | curry        |
| B           | 2021-01-09| 2021-01-11 | sushi        |


### **7.** Which item was purchased just before the customer became a member?

<details>
  <summary>See query.</summary>

```sql
WITH cte_last_nonmember_purchase AS
(
	SELECT 
		t1.customer_id,
		t3.product_name,
		t2.order_date,
		t1.join_date,
		RANK() OVER (
			PARTITION BY t1.customer_id 
			ORDER BY t2.order_date DESC) as purchase_rank
		FROM 
			dannys_diner.members AS t1
		JOIN 
			dannys_diner.sales AS t2 
		ON 
			t2.customer_id = t1.customer_id
		JOIN 
			dannys_diner.menu AS  t3 
		ON 
			t2.product_id = t3.product_id
		WHERE
			t2.order_date < t1.join_date
)
SELECT 
	customer_id,
	order_date,
	join_date,
	product_name
FROM 
	cte_last_nonmember_purchase
WHERE
	purchase_rank = 1;
```
</details>
<br />

**Results:**
| customer_id | order_date | join_date | product_name |
|-------------|------------|-----------|--------------|
| A           | 2021-01-01 | 2021-01-07| sushi        |
| A           | 2021-01-01 | 2021-01-07| curry        |
| B           | 2021-01-04 | 2021-01-09| sushi        |


### **8.** What is the total items and amount spent for each member before they became a member?

<details>
  <summary>See query.</summary>

```sql
SELECT 
	t1.customer_id,
	COUNT(t3.product_id) AS total_products,
	SUM(t3.price) AS total_spent
FROM 
	dannys_diner.members AS t1
JOIN 	
	dannys_diner.sales AS t2 
ON 
	t2.customer_id = t1.customer_id
JOIN
	dannys_diner.menu AS t3 
ON
	t2.product_id = t3.product_id
WHERE
	t2.order_date < t1.join_date
GROUP BY 
	t1.customer_id
ORDER BY 
	customer_id;

```
</details>
<br />

**Results:**
| customer_id | total_products | total_spent |
|-------------|----------------|-------------|
| A           | 2              | 25          |
| B           | 3              | 40          |


### **9.** If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

<details>
  <summary>See query.</summary>

```sql
SELECT 
	t1.customer_id as customer,
	SUM(
		CASE
			WHEN t2.product_name = 'sushi' THEN (t2.price * 10 * 2)
			ELSE (t2.price * 10)
		END
	) AS member_points
FROM 
	dannys_diner.sales as t1
JOIN
	dannys_diner.menu AS t2 
ON
	t1.product_id = t2.product_id
GROUP BY 
	t1.customer_id;
```
</details>
<br />

**Results:**
| customer | member_points |
|----------|---------------|
| A        | 860           |
| B        | 940           |
| C        | 360           |


### **10.** In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?	

<details>
  <summary>See query.</summary>

```sql
SELECT 
	t1.customer_id,
	SUM(
		CASE
			WHEN t2.order_date < t1.join_date THEN
				CASE 
					WHEN t3.product_name = 'sushi' THEN (t3.price * 10 * 2)
					ELSE (t3.price * 10)
				END
			WHEN t2.order_date > (t1.join_date + 6) THEN 
				CASE 
					WHEN t3.product_name = 'sushi' THEN (t3.price * 10 * 2)
					ELSE (t3.price * 10)
				END 
			ELSE (t3.price * 10 * 2)	
		END) AS member_points
FROM
	dannys_diner.members AS t1
JOIN
	dannys_diner.sales AS t2 
ON
	t2.customer_id = t1.customer_id
JOIN
	dannys_diner.menu AS t3 
ON
	t2.product_id = t3.product_id
WHERE 
	t2.order_date <= '2021-01-31'
GROUP BY 
	t1.customer_id;
```
</details>
<br />

**Results:**
| customer_id | member_points |
|-------------|----------------|
| A           | 1370           |
| B           | 820            |

## Bonus Questions:

### Recreate the following table output using the available data:
customer_id|order_date|product_name|price |member|
-----------|----------|------------|------|------|
A          |2021-01-01|curry       |    15|N     |
A          |2021-01-01|sushi       |    10|N     |
A          |2021-01-07|curry       |    15|Y     |
A          |2021-01-10|ramen       |    12|Y     |
A          |2021-01-11|ramen       |    12|Y     |
A          |2021-01-11|ramen       |    12|Y     |
B          |2021-01-01|curry       |    15|N     |
B          |2021-01-02|curry       |    15|N     |
B          |2021-01-04|sushi       |    10|N     |
B          |2021-01-11|sushi       |    10|Y     |
B          |2021-01-16|ramen       |    12|Y     |
B          |2021-02-01|ramen       |    12|Y     |
C          |2021-01-01|ramen       |    12|N     |
C          |2021-01-01|ramen       |    12|N     |
C          |2021-01-07|ramen       |    12|N     |

<details>
  <summary>See query.</summary>

```sql
CREATE TABLE merged_data AS 
(
	SELECT 
		t1.customer_id,
		t1.order_date,
		t3.product_name,
		t3.price,
		CASE
			WHEN t1.order_date < t2.join_date OR t2.join_date IS NULL THEN 'N'
			WHEN t1.order_date >= t2.join_date THEN 'Y'
		END AS member
	FROM
		dannys_diner.sales AS t1
	LEFT JOIN
		dannys_diner.members AS t2
	ON
		t1.customer_id = t2.customer_id
	JOIN
		dannys_diner.menu AS t3 
	ON
		t1.product_id = t3.product_id    
);
SELECT 
	*
FROM
	merged_data
ORDER BY
	customer_id, order_date, product_name;
```
</details>

### Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
<details>
  <summary>See query.</summary>

```sql
SELECT 
	*,
	CASE
		WHEN member = 'Y' THEN 
			DENSE_RANK() OVER (
				PARTITION BY customer_id, member 
				ORDER BY order_date) 
	END AS ranking
FROM
	merged_data
ORDER BY
	customer_id, order_date, product_name;
```
</details>
<br />

**Results:**
| customer_id | order_date  | product_name | price | member | ranking |
|-------------|-------------|--------------|-------|--------|---------|
| A           | 2021-01-01  | curry        | 15    | N      |         |
| A           | 2021-01-01  | sushi        | 10    | N      |         |
| A           | 2021-01-07  | curry        | 15    | Y      | 1       |
| A           | 2021-01-10  | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11  | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11  | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01  | curry        | 15    | N      |         |
| B           | 2021-01-02  | curry        | 15    | N      |         |
| B           | 2021-01-04  | sushi        | 10    | N      |         |
| B           | 2021-01-11  | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16  | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01  | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01  | ramen        | 12    | N      |         |
| C           | 2021-01-01  | ramen        | 12    | N      |         |
| C           | 2021-01-07  | ramen        | 12    | N      |         |
