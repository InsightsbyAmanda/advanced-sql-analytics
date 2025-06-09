/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

/* =============================================================================
As a final step in this project, we will collect all the different types of explorations and analysis we've done so far
and put everything in a VIEW or TABLE then present to stakeholders or Users for decison-making.

Lets breakdown the step-by-step process of building a complex query to be used to create the Customer Report.
   >>> Select the data from the database starting with the fact table and joining it with the Dimension tables using LEFT JOIN.
   >>> Next, select only the relevant columns needed for the report.
	>>> For a complex query, we will divide the process into multiple steps
		
		>> Step 1: Base Query
					This will be the foundation of the next steps and since there are multiple steps, we will put it inside a CTE(Intermediate results).
		>> Step 2: Transformation
					On the base data, we will do few basic transformations like calculating/deriving new columns, formatting dates
		>> Step 3: Aggregations
					On top of these transformed base query, we will do all the aggregations needed in the report. 
					We will still put it in another CTE(intermediate results).
					Use a seperated CTE for aggregations.
		>> Step 4: Final Results
					Now we have all the preparations required to build the final results. 
					We will build the final results from the second CTE (aggregation CTE).
		>> Step 5: Final Transformation
					We will also introduce final transformations needed for the report.
					Here, we will segment our customers into categories and age groups and calculate the KPIs.
		>> Step 6: Create a VIEW
					We will now create a VIEW from the entire query and from there, it can be shared with the End users.
					The end user can then connect to the View to create a dashboard in order to visulaise the data using either Power BI or Tableau.
					The End user can also write a query on top of the VIEW to generate quick insights.
	Finally, this report is very important because it gives a full picture of all the customers helping end users to quickly
	understand the data and generate insights.
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

/*---------------------------------------------------------------------------
1 & 2) Base Query: Retrieves core columns from tables and put inside a CTE
---------------------------------------------------------------------------*/
WITH base_query AS(
	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) age
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
	WHERE order_date IS NOT NULL)

/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
, customer_aggregation AS (
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		age
)
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		CASE 
			 WHEN age < 20 THEN 'Under 20'
			 WHEN age between 20 and 29 THEN '20-29'
			 WHEN age between 30 and 39 THEN '30-39'
			 WHEN age between 40 and 49 THEN '40-49'
			 ELSE '50 and above'
	END AS age_group,
		CASE 
			WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
	END AS customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,		-- Calculate the recency (months since last order)
	total_orders,
	total_sales,
	total_quantity,
	total_products
	lifespan,
-- Calculate average order value (AVO) (Divide Total Sales by Total Number of Orders)
	CASE WHEN total_sales = 0 THEN 0			--This is to ensure you are not dividing by 0
		 ELSE total_sales / total_orders
	END AS avg_order_value,
-- Calculate average monthly spend (Divide Total Sales by Number of Months ie the lifespan)
	CASE WHEN lifespan = 0 THEN total_sales		--This is to ensure you are not dividing by 0
		 ELSE total_sales / lifespan
	END AS avg_monthly_spend
	FROM customer_aggregation



-- Query the VIEW
	SELECT *
	FROM gold.report_customers

-- Typical Insight an End User can generate from the VIEW
	SELECT
		age_group,
		COUNT(customer_number) AS total_customers,
		SUM(total_sales) AS total_sales
	FROM gold.report_customers
	GROUP BY age_group

	SELECT
		customer_segment,
		COUNT(customer_number) AS total_customers,
		SUM(total_sales) AS total_sales
	FROM gold.report_customers
	GROUP BY customer_segment
