/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Explore all Countries our Customers come from
SELECT DISTINCT country
FROM gold.dim_customers


-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products

SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY 1,2,3
