/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which categories contribute the most to overall sales?
-- First, we JOIN both tables (fact_sales table & dim_product table) using the product_key.
	SELECT
		p.category AS category,
		f.sales_amount
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON		  f.product_key = p.product_key

-- Next, calculate the total sales for each category
	SELECT
		p.category AS category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON		  f.product_key = p.product_key
	GROUP BY p.category

/*
In order to calculate the percentage, we need two measures (total sales for each category (ie the query above) and the total sales across all categories.
Now calculate the total sales across all categories (the big number without any dimension).
To achieve this, we use the Windows functions: to display aggregations at multiple levels in the results.
		>> First start with a CTE, then select the columns from the CTE in the second SELECT statement.
		>> Next, build a windows function to aggregrate all the values in the total_sales column to get the total sales of the whole dataset.
		>> Next, calculate the percentage [(total_sales / SUM(total_sales) OVER ()) * 100 AS prcentage_of_total]. The output is giving zeros because the total_sales
			is not float. So we CAST it AS FLOAT in the query.
		>> With the Cast and Float, the output is giving alot of numbers after the comma so we need to ROUND it to 2 decimal places.
		>> Next, we can add a percantage next to the values ie converting the values to a string using CONCATENATION.
		>> Finally, order the data by the total_sales in descending order.		
*/
	WITH category_sales AS (
	SELECT
		p.category AS category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON		  f.product_key = p.product_key
	GROUP BY p.category
	)
	SELECT
		category,
		total_sales,
		SUM(total_sales) OVER () AS overall_sales,
		CONCAT(ROUND((CAST(total_sales AS float) / SUM(total_sales) OVER ()) * 100, 2), '%') AS prcentage_of_total
	FROM category_sales
	ORDER BY total_sales DESC

