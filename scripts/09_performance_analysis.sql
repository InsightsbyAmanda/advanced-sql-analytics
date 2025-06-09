/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales 
  -- Let's break this down:
       >>> Yearly Peformance of products: We need the (order_date) as a dimension and the (product_name).
	   >>> Previous Year's sales: The measure is the (sales_amount).
	-- We will need data from the Sales fact table (order_date and sales_amount) and JOIN it with the Product Dim table (product_name)
*/
	SELECT 
		f.order_date,
		p.product_name,
		f.sales_amount
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON		  f.product_key = p.product_key


-- YEARLY PERFORMANCE OF PRODUCTS
-- In the query above, the date column is the day and we need to analyse the yearly performance so we need the YEARS. So we convert to YEARS.
	SELECT 
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON		  f.product_key = p.product_key
	WHERE order_date IS NOT NULL			-- Filter out the null values
	GROUP BY YEAR(f.order_date), p.product_name


/*
COMPARE SALES WITH AVERAGE SALES PERFORMANCE OF THE PRODUCT AND PREVIOUS YEAR'S SALES
-- Next, we have to compare the current sales to the average sales performance of the products.
This means we need the average and the previous year's sales to compare each value to the preious year for the same product.
We will use Windows Functions.
*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales			-- Retrieving data from the CTE above
ORDER BY product_name, order_year;

/*
Focusing on Average Sales:
Based on the Current sales values column, we will derive new calculations and aggregations either using a subquery or a CTE.
We will use CTE because it looks nicer.
		Starting off with the: WITH yearly_product_sales AS (, (this is the CTE) we will then build queries on top of the first query results.
		Now selecting data from our CTE, we will list all the columns we want in our results (order_year, product_name and current_sales).
		Next, we will Order the data by the (product_name and order_date) using ORDER BY.
		Next, Calculate the average current sales  [AVG(current_sales) OVER], but then we need to decide how to partition the data.
		Since we are focusing on the products, we have to partition the results by the (product_name)[(PARTITION BY product_name) AS avg_sales].
		We dont need to sort the data (ORDER BY in the PARTITION BY) since we are using AVERAGE.
		Since, we have both current sales and average sales, we need to substract [ current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,].
		Next, we set an indicator showing if we are above or below the average using CASE WHEN Statements:
			>> If the difference is higher than zero, THEN we are above average
			>> If the difference is below zero, THEN we are below average
			>> ELSE, it is average
			>> END AS avg_change.
		With this, we are comparing the performance of the current sales of each product with the average sales using the Windows function.

Now compare with the Previous Year's sales (Year-over-Year Analysis):
		This time, we have to compare the current sales not with the average sales but the previous year.
		We dont need to write another CTE, just continue with the same results.
		First thing is to do is to access the previous year using the LAG function and PARTITION BY the (product_name).
		Now to access the previous year's value, we will sort byt the (order_year) ie include ORDER BY in the PARTITION BY sorting ascending (Default).
		This will give us the previou's year sales of the product (AS py_sales)
		Next is to find the difference between current year sales (current_sales) and previous year sales (py_sales). [current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,]
		Next, we set an indicator showing if sales are increasing or decreasing using CASE WHEN Statements:
			>> If the difference is higher than zero, THEN sales is Increasing
			>> If the difference is below zero, THEN sales is Decreasing
			>> ELSE, there is no change
			>> END AS py_change.
This is called Year-over-year analysis and if you want to calculate Month-over-month analysis, change the function from YEAR to MONTH and with that you're extracting
the month part.

  Difference between analysing Months and Years is the SCOPE.
    >> YOY is good for long-term trend analysis
	>> MOM is good got short-term analysis.
This is how to analyse the performance of a business by comparing the Current measure with a Target measure using different dimensions.
So instead of sales, you can compare the quantity. Instead of Products, compare Customers. 
You can compare the current information with not only the average or the previous year but with the lowest or highest sales.
*/
