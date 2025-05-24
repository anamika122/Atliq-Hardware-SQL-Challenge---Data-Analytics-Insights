# Atliq-Hardware-SQL-Challenge-Data-Analytics-Insights
## Introduction 
Atliq Hardware, one of the leading computer hardware producers in India with customers from across the globe, want to get insights on company products sales to make data-informed decisions.

## Dataset used
-<a herf = "https://github.com/anamika122/Atliq-Hardware-SQL-Challenge---Data-Analytics-Insights/blob/main/Input%20for%20participants/atliq_hardware_db.zip">Dataset</a>

## Questions (KPIs)


## Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region.

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


## What is the percentage of unique product increase in 2021 vs. 2020? (The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg.)

### Sql Query

with product_count as(
select count(distinct(case when fiscal_year = 2020 then product_code end)) as unique_products_2020,
count(distinct(case when fiscal_year = 2021 then product_code end)) as unique_products_2021
from fact_sales_monthly)
select unique_products_2020 ,unique_products_2021, round(((unique_products_2021-unique_products_2020) /unique_products_2020 )*100,2) as percentage_change 
from product_count;

### Business Impact :-Significant product portfolio expansion indicating strong R&D investment.

![Screenshot 2025-05-23 131628](https://github.com/user-attachments/assets/15b26f0e-6301-44fd-b473-45aaf5396288)


## Provide a report with all the unique product counts for each  segment  and sort them in descending order of product counts.
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


## Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
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
 

 ## Get the products that have the highest and lowest manufacturing costs. 
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

 

##  Generate a report which contains the top 5 customers who received an average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the Indian  market. 
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



##  Get the complete report of the Gross sales amount for the customer  “Atliq Exclusive”  for each month  .  
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


## In which quarter of 2020, got the maximum total_sold_quantity?
-- The final output contains these fields sorted by the total_sold_quantity, Quarter total_sold_quantity.

### Sql Query

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
;

 ### Business Impact:-
Peak quarter identification for FY 2020
Capacity planning insights for operational efficiency
Market timing strategies for product launches

![Screenshot 2025-05-23 221035](https://github.com/user-attachments/assets/0778802e-3db3-46ff-8ab9-bd8c3b83e414)



## Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
-- The final output  contains these fields, channel gross_sales_mln percentage

### Sql Query

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

 ### Business Impact:-
Distribution channel performance analysis for FY 2021
Contribution percentage by channel for resource allocation
Strategic recommendations for channel investment

![Screenshot 2025-05-23 230954](https://github.com/user-attachments/assets/fe003500-cc7f-4220-9c5d-a4b11ab93e37)



## Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
-- The final output contains these  fields, division product_code  product total_sold_quantity rank_order 

### Sql Query

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

 ### Business Impact:-
Top 3 products by division based on sales volume
Division-wise performance for strategic focus
Product rationalization opportunities


![Screenshot 2025-05-24 004456](https://github.com/user-attachments/assets/edd962aa-04fe-4160-90a0-d008b930bf92)



![Screenshot 2025-05-24 004601](https://github.com/user-attachments/assets/e5895bfc-f023-4778-9dfa-0738ff7480ee)



![Screenshot 2025-05-24 004613](https://github.com/user-attachments/assets/b571e0d3-cb67-4609-8fe6-35da0abcaf92)



![Screenshot 2025-05-24 004621](https://github.com/user-attachments/assets/a5cdf036-a334-4434-bace-63f5907857d8)




