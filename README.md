# Atliq-Hardware-SQL-Challenge-Data-Analytics-Insights
## Introduction 
Atliq Hardware, one of the leading computer hardware producers in India with customers from across the globe, want to get insights on company products sales to make data-informed decisions.

## Dataset used
-<a herf = "https://github.com/anamika122/Atliq-Hardware-SQL-Challenge---Data-Analytics-Insights/blob/main/Input%20for%20participants/atliq_hardware_db.zip">/Dataset</a>

## Questions (KPIs)
-- Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region.

### Sql Query

SELECT 
    market
FROM
    dim_customer
WHERE
    customer = 'Atliq Exclusive'
        AND region = 'APAC';
        
### Business Impact :- Strategic market focus for expansion planning.

![Screenshot 2025-05-23 131044](https://github.com/user-attachments/assets/e7debb4b-4235-4d9c-8ac6-184dd7dae89e)

-- What is the percentage of unique product increase in 2021 vs. 2020? (The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg.)

### Sql Query

with product_count as(
select count(distinct(case when fiscal_year = 2020 then product_code end)) as unique_products_2020,
count(distinct(case when fiscal_year = 2021 then product_code end)) as unique_products_2021
from fact_sales_monthly)
select unique_products_2020 ,unique_products_2021, round(((unique_products_2021-unique_products_2020) /unique_products_2020 )*100,2) as percentage_change 
from product_count;

### Business Impact :-Significant product portfolio expansion indicating strong R&D investment.

![Screenshot 2025-05-23 131628](https://github.com/user-attachments/assets/15b26f0e-6301-44fd-b473-45aaf5396288)

-- Provide a report with all the unique product counts for each  segment  and sort them in descending order of product counts.
-- (The final output contains 2 fields, segment product_count )

### Sql Query

SELECT 
    segment, COUNT(DISTINCT product_code) AS product_count
FROM
    dim_product
GROUP BY segment
ORDER BY product_count DESC;

### Business Impact :-Resource allocation and segment prioritization.

![Screenshot 2025-05-23 131957](https://github.com/user-attachments/assets/9d5e3950-cdf8-424d-919f-d90820f04380)

--  Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
-- (The final output contains these fields, segment product_count_2020 product_count_2021 difference.)

### Sql Query

with product_count as 
(SELECT 
    d.segment, COUNT(DISTINCT(case when f.fiscal_year = 2020 then f.product_code end)) AS product_count_2020,
    COUNT(DISTINCT(case when f.fiscal_year = 2021 then f.product_code end)) AS product_count_2021
FROM
    dim_product d left join fact_sales_monthly f on d.product_code = f.product_code
GROUP BY segment)
SELECT 
    segment,
    product_count_2020,
    product_count_2021,
    (product_count_2021 - product_count_2020) AS difference
FROM
    product_count;

 ### Business Impact:-Identifies high-growth segments for investment priority.

 ![Screenshot 2025-05-23 154106](https://github.com/user-attachments/assets/011fc549-0c98-4d1c-bf1d-545d5e70a220)

 -- Get the products that have the highest and lowest manufacturing costs. 
-- The final output should contain these fields, product_code product manufacturing_cost

### Sql Query

SELECT 
    f.product_code, d.product, f.manufacturing_cost
FROM
    fact_manufacturing_cost f
        JOIN
    dim_product d ON f.product_code = d.product_code
WHERE
    manufacturing_cost
IN (
	SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost
    UNION
    SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost
    ) 
ORDER BY manufacturing_cost DESC ;

 ### Business Impact:-Identifies products for cost structure review.
 
 ![Screenshot 2025-05-23 164047](https://github.com/user-attachments/assets/a3d9386c-545b-4834-88f9-a61eb71629fd)

 --  Generate a report which contains the top 5 customers who received an average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the Indian  market. 
-- The final output contains these fields, customer_code customer average_discount_percentage 

### Sql Query

SELECT 
    d.customer_code,
    d.customer,
    ROUND(AVG(pre_invoice_discount_pct) * 100, 2) AS average_discount_percentage
FROM
    dim_customer d
        LEFT JOIN
    fact_pre_invoice_deductions f ON d.customer_code = f.customer_code
WHERE
    f.fiscal_year = 2021
        AND d.market = 'india'
GROUP BY d.customer , d.customer_code
ORDER BY average_discount_percentage DESC
LIMIT 5;

 ### Business Impact:-

Top 5 customers by average discount percentage in Indian market (FY 2021)

Strategic insight: Customer relationship optimization opportunities

Action item: Review discount strategies for key accounts

![Screenshot 2025-05-23 184132](https://github.com/user-attachments/assets/a9580a0a-3050-49b5-884a-cc163d229166)

--   Get the complete report of the Gross sales amount for the customer  “Atliq Exclusive”  for each month  .  
-- This analysis helps to  get an idea of low and high-performing months and take strategic decisions. 
-- The final report contains these columns: Month Year Gross sales Amount

### Sql Query

SELECT CONCAT(MONTHNAME(FS.date), ' (', YEAR(FS.date), ')') AS 'Month', FS.fiscal_year,
       ROUND(SUM(FG.gross_price*FS.sold_quantity), 2) AS Gross_sales_Amount
FROM fact_sales_monthly FS JOIN dim_customer d ON FS.customer_code = d.customer_code
						   JOIN fact_gross_price FG ON FS.product_code = FG.product_code
WHERE d.customer = 'Atliq Exclusive'
GROUP BY  Month, FS.fiscal_year 
ORDER BY FS.fiscal_year ;

 ### Business Impact:-

Monthly gross sales tracking for "Atliq Exclusive"

Seasonal patterns identification for inventory planning

Performance metrics for strategic decision making

![Screenshot 2025-05-23 210330](https://github.com/user-attachments/assets/bdf5803a-96d7-4f66-a2f3-116c368daefa)

