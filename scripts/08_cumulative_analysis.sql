/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time 
/*
N/B: The (running_total_sales) column is adding the current value to all previous rows' values and this is because of the default frame of the Window.
  >> SQL Default Window Frame is between Unbounded Preceding and Current row, this means we are getting all the previous values together with the current value to
  give us the Running Total Sales.
  */
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales ---This is adding each row's value to the sum of all the previous rows' value
FROM
(
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t


/*
We can go and limit the running total for only one year. So for each new year, the running total will reset and recacluate from the scratch.
To do this, we use the PARTITION BY function on the (order_date) to partition the data for each year.
*/

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales ---This is adding each row's value to the sum of all the previous rows' value
FROM
(
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t

--If you are using YEAR in the DATETRUNC arguement, remove the PARTITION BY. Only use it for MONTH in the DATETRUNC argument.
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales ---This is adding each row's value to the sum of all the previous rows' value
FROM
(
    SELECT 
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) t


-- Calculate the total sales per month 
-- and the moving average of price over time 

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t

/*
Difference between Normal Aggregation and Cummulative Aggregation.
  >>> The Normal aggregation is used to check the performance of each individual row. For e.g if I want to see how each year is performing.
  >>> However, if you want to see a progression and understand how your business is growing, use Cummulative aggregation
