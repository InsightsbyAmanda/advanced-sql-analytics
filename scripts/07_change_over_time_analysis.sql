/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time
/*
This gives a picture of revenue trends, increasing or decreasing over the time, whats the best or worst year.
It also shows if we are gaining customers over time and so on.
*/
-- Yearly Analysis: This gives a high-level overview insights that helps with strategic decision making.
	SELECT 
		YEAR(order_date) AS order_year,
		SUM(sales_amount) AS total_sales,					---Aggregrating Total Sales
		COUNT(DISTINCT customer_key) AS total_customers,	--- Calculating Total number of Customers
		SUM(quantity) AS total_quantity						--- Find the Total number of quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date)
	ORDER BY YEAR(order_date)

-- Monthly Analysis: This gives a detailed insight to discover seasonility in your data.
	SELECT 
		MONTH(order_date) AS order_month,
		SUM(sales_amount) AS total_sales,					---Aggregrating Total Sales
		COUNT(DISTINCT customer_key) AS total_customers,	--- Calculating Total number of Customers
		SUM(quantity) AS total_quantity						--- Find the Total number of quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY MONTH(order_date)
	ORDER BY MONTH(order_date)

-- Month Analysis by the Year. If you want to focus on only year, you can filter the data by the (order_year).
	SELECT 
		YEAR(order_date) AS order_year,
		MONTH(order_date) AS order_month,
		SUM(sales_amount) AS total_sales,					---Aggregrating Total Sales
		COUNT(DISTINCT customer_key) AS total_customers,	--- Calculating Total number of Customers
		SUM(quantity) AS total_quantity						--- Find the Total number of quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), MONTH(order_date)
	ORDER BY YEAR(order_date), MONTH(order_date)


-- Formatting the Date using DATETRUNC function (Rounds a date or timestamp to a specified date part).
	SELECT 
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,					---Aggregrating Total Sales
		COUNT(DISTINCT customer_key) AS total_customers,	--- Calculating Total number of Customers
		SUM(quantity) AS total_quantity						--- Find the Total number of quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	ORDER BY DATETRUNC(MONTH, order_date)

	SELECT 
		DATETRUNC(YEAR, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,					---Aggregrating Total Sales
		COUNT(DISTINCT customer_key) AS total_customers,	--- Calculating Total number of Customers
		SUM(quantity) AS total_quantity						--- Find the Total number of quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
	ORDER BY DATETRUNC(YEAR, order_date)



-- Making your date column to a specific format using the FORMAT function.
	SELECT 
		FORMAT(order_date, 'yyyy-MMM') AS order_date,
		SUM(sales_amount) AS total_sales,					---Aggregrating Total Sales
		COUNT(DISTINCT customer_key) AS total_customers,	--- Calculating Total number of Customers
		SUM(quantity) AS total_quantity						--- Find the Total number of quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY FORMAT(order_date, 'yyyy-MMM')
	ORDER BY FORMAT(order_date, 'yyyy-MMM')

--Note that using the FORMAT function in a Date column, the result will be a string.
-- Using a DATETRUNC function in a Date column, the result will be a date. 
-- Using a YEAR or MONTH function in a Date column, the result will be an Integer
