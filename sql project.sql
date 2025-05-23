-- Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region.
SELECT 
    market
FROM
    dim_customer
WHERE
    customer = 'Atliq Exclusive'
        AND region = 'APAC';

-- What is the percentage of unique product increase in 2021 vs. 2020? (The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg.)
with product_count as(
select count(distinct(case when fiscal_year = 2020 then product_code end)) as unique_products_2020,
count(distinct(case when fiscal_year = 2021 then product_code end)) as unique_products_2021
from fact_sales_monthly)
select unique_products_2020 ,unique_products_2021, round(((unique_products_2021-unique_products_2020) /unique_products_2020 )*100,2) as percentage_change 
from product_count;

-- Provide a report with all the unique product counts for each  segment  and sort them in descending order of product counts.
-- (The final output contains 2 fields, segment product_count )

SELECT 
    segment, COUNT(DISTINCT product_code) AS product_count
FROM
    dim_product
GROUP BY segment
ORDER BY product_count DESC;

--  Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
-- (The final output contains these fields, segment product_count_2020 product_count_2021 difference.)

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
    
-- Get the products that have the highest and lowest manufacturing costs. 
-- The final output should contain these fields, product_code product manufacturing_cost
-- select f.product_code,d.product,f.manufacturing_cost ,dense_rank() over(order by manufacturing_cost )  as manufacturing_rank from fact_manufacturing_cost f join dim_product d on f.product_code = d.product_code;

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

--  Generate a report which contains the top 5 customers who received an average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the Indian  market. 
-- The final output contains these fields, customer_code customer average_discount_percentage 
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

--   Get the complete report of the Gross sales amount for the customer  “Atliq Exclusive”  for each month  .  
-- This analysis helps to  get an idea of low and high-performing months and take strategic decisions. 
-- The final report contains these columns: Month Year Gross sales Amount

SELECT CONCAT(MONTHNAME(FS.date), ' (', YEAR(FS.date), ')') AS 'Month', FS.fiscal_year,
       ROUND(SUM(FG.gross_price*FS.sold_quantity), 2) AS Gross_sales_Amount
FROM fact_sales_monthly FS JOIN dim_customer d ON FS.customer_code = d.customer_code
						   JOIN fact_gross_price FG ON FS.product_code = FG.product_code
WHERE d.customer = 'Atliq Exclusive'
GROUP BY  Month, FS.fiscal_year 
ORDER BY FS.fiscal_year ;

--   In which quarter of 2020, got the maximum total_sold_quantity?
-- The final output contains these fields sorted by the total_sold_quantity, Quarter total_sold_quantity

SELECT 
CASE
    WHEN date BETWEEN '2019-09-01' AND '2019-11-01' then 'FIRST QUARTER'  
    WHEN date BETWEEN '2019-12-01' AND '2020-02-01' then 'SECOND QUARTER'  
    WHEN date BETWEEN '2020-03-01' AND '2020-05-01' then 'THIRD QUARTER'  
    WHEN date BETWEEN '2020-06-01' AND '2020-08-01' then 'FOURTH QUARTER'  
    END AS Quarters,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
group by Quarters
order by total_sold_quantity DESC
LIMIT 1;

-- Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
-- The final output  contains these fields, channel gross_sales_mln percentage

WITH gross_sale AS
(
SELECT D.channel,
       ROUND(SUM(FG.gross_price*FS.sold_quantity/1000000), 2) AS Gross_sales_mln
FROM fact_sales_monthly FS JOIN dim_customer D ON FS.customer_code = D.customer_code
						   JOIN fact_gross_price FG ON FS.product_code = FG.product_code
WHERE FS.fiscal_year = 2021
GROUP BY channel
)
SELECT Channel, CONCAT(Gross_sales_mln,' M') AS Gross_sales_mln , CONCAT(ROUND(Gross_sales_mln*100/total , 2), ' %') AS Percentage
FROM
(
(SELECT SUM(Gross_sales_mln) AS total FROM gross_sale) A,
(SELECT * FROM gross_sale) B
)
ORDER BY percentage DESC ;

-- Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
-- The final output contains these  fields, division product_code  product total_sold_quantity rank_order 

with cte1 as(
select d.division,d.product,fs.product_code,sum(fs.sold_quantity)as total_sold_quantity
from dim_product d JOIN fact_sales_monthly FS
ON d.product_code = FS.product_code
WHERE FS.fiscal_year = 2021 
GROUP BY  FS.product_code, division, d.product
),
cte2 as(select division,product,product_code,total_sold_quantity, 
rank() over(partition by division order by total_sold_quantity desc) as rank_order
from cte1)
 SELECT division,product,product_code,Total_sold_quantity,Rank_Order
 FROM cte2
WHERE Rank_Order IN (1,2,3);
