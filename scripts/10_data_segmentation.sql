/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
-- First, categorise the cost using CASE WHEN statement by converting a measure into a Dimension.
	SELECT
		product_key,
		product_name,
		cost,
		CASE 
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products


-- Next, we aggregate the data based on the new Dimension by putting it in a CTE.
	WITH product_segments AS (
	SELECT
		product_key,
		product_name,
		cost,
		CASE 
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
	)
	SELECT
		cost_range,
		COUNT(product_key) AS total_products
	FROM product_segments
	GROUP BY cost_range
	ORDER BY total_products DESC


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
-- First, we need the relevant columns (customer_key for the aggregation, sales_amount, order_date to calculate the lifespan).
-- Then JOIN the fact_sales and dim_customer tables
	SELECT
        c.customer_key,
		f.sales_amount,
        order_date
     FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key


 -- To calculate the Lifespan, we need to find out the first order and the last order of each customer ie how many months is between the first and last order.
 -- We use the MIN() for the first order and MAX() for the last order.
 -- Next, to group the data we also need the total spending (ie total_sales).
 -- Next we calculate the lifespan using the DATEDIFF function
	SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key


 -- Next we create our segments based on the result of the query above by putting it in a CTE.
 -- Next build the segments using CASE WHEN
 -- Looking at the result, we have derived a new dimesnion from two measures (lifespan and total_spending)
 WITH customer_spending AS (
    SELECT
        c.customer_key AS customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
	SELECT
		customer_key,
		total_spending,
		lifespan,
		CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
	FROM customer_spending


 -- Now, we need to find the total number of customers for each category.
 -- We will put the aggregation in the second step.
WITH customer_spending AS (
    SELECT
        c.customer_key AS customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM (
		SELECT
		customer_key,
			CASE 
				WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
				WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
				ELSE 'New'
			END AS customer_segment
		FROM customer_spending ) AS segmented_customers
		GROUP BY customer_segment
		ORDER BY total_customers DESC
