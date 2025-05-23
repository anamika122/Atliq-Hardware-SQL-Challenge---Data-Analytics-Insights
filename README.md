# Atliq-Hardware-SQL-Challenge-Data-Analytics-Insights
-- =====================================================================================
-- ATLIQ HARDWARE - SQL CHALLENGE: COMPLETE QUERY COLLECTION
-- =====================================================================================
-- Author: ANAMIKA
-- Date: May 23, 2025
-- Purpose: Comprehensive business analytics for strategic decision making
-- Database: MySQL
-- =====================================================================================

-- =====================================================================================
-- QUERY 1: MARKET OPERATIONS ANALYSIS
-- =====================================================================================
-- Business Question: Provide the list of markets in which customer "Atliq Exclusive" 
--                   operates its business in the "APAC" region.
-- Strategic Impact: Market expansion and regional strategy planning
-- Complexity Level: ⭐⭐ (Simple Filter)
-- =====================================================================================

-- Query 1: Market Analysis for Atliq Exclusive in APAC
SELECT DISTINCT market
FROM dim_customer
WHERE customer = 'Atliq Exclusive' 
  AND region = 'APAC'
ORDER BY market;

-- Business Insights:
-- • Identifies specific markets for targeted expansion
-- • Enables regional resource allocation planning
-- • Supports market penetration strategies

-- =====================================================================================
-- QUERY 2: PRODUCT PORTFOLIO GROWTH ANALYSIS
-- =====================================================================================
-- Business Question: What is the percentage of unique product increase in 2021 vs. 2020?
-- Strategic Impact: Product development ROI and portfolio expansion success
-- Complexity Level: ⭐⭐⭐ (Complex Aggregation with CTEs)
-- =====================================================================================

-- Query 2: Product Portfolio Growth Metrics
WITH product_count AS (
    SELECT 
        COUNT(DISTINCT(CASE WHEN fiscal_year = 2020 THEN product_code END)) as unique_products_2020,
        COUNT(DISTINCT(CASE WHEN fiscal_year = 2021 THEN product_code END)) as unique_products_2021
    FROM fact_sales_monthly
)
SELECT 
    unique_products_2020,
    unique_products_2021, 
    ROUND(((unique_products_2021 - unique_products_2020) / unique_products_2020) * 100, 2) as percentage_change 
FROM product_count;

-- Business Insights:
-- • Measures product innovation success rate
-- • Quantifies R&D investment effectiveness
-- • Guides future product development budget allocation

-- =====================================================================================
-- QUERY 3: SEGMENT DISTRIBUTION ANALYSIS
-- =====================================================================================
-- Business Question: Provide a report with all the unique product counts for each segment 
--                   and sort them in descending order of product counts.
-- Strategic Impact: Segment prioritization and resource allocation
-- Complexity Level: ⭐⭐ (Group By Analysis)
-- =====================================================================================

-- Query 3: Segment-wise Product Distribution
SELECT 
    segment, 
    COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

-- Business Insights:
-- • Identifies dominant product segments
-- • Reveals portfolio balance across segments
-- • Supports strategic segment investment decisions

-- =====================================================================================
-- QUERY 4: SEGMENT GROWTH COMPARISON
-- =====================================================================================
-- Business Question: Which segment had the most increase in unique products in 2021 vs 2020?
-- Strategic Impact: Growth segment identification for strategic focus
-- Complexity Level: ⭐⭐⭐⭐ (Multi-year Comparison with CTEs)
-- =====================================================================================

-- Query 4: Segment Growth Analysis (2020 vs 2021)
WITH product_count AS (
    SELECT 
        d.segment, 
        COUNT(DISTINCT(CASE WHEN f.fiscal_year = 2020 THEN f.product_code END)) AS product_count_2020,
        COUNT(DISTINCT(CASE WHEN f.fiscal_year = 2021 THEN f.product_code END)) AS product_count_2021
    FROM dim_product d 
    LEFT JOIN fact_sales_monthly f ON d.product_code = f.product_code
    GROUP BY segment
)
SELECT 
    segment,
    product_count_2020,
    product_count_2021,
    (product_count_2021 - product_count_2020) AS difference
FROM product_count
ORDER BY difference DESC;

-- Business Insights:
-- • Identifies fastest-growing segments for investment priority
-- • Reveals market demand trends by segment
-- • Guides strategic resource reallocation

-- =====================================================================================
-- QUERY 5: MANUFACTURING COST OPTIMIZATION
-- =====================================================================================
-- Business Question: Get the products that have the highest and lowest manufacturing costs.
-- Strategic Impact: Cost optimization and pricing strategy development
-- Complexity Level: ⭐⭐⭐ (Min/Max Analysis with Joins)
-- =====================================================================================

-- Query 5: Manufacturing Cost Extremes Analysis
SELECT 
    f.product_code, 
    d.product, 
    f.manufacturing_cost
FROM fact_manufacturing_cost f
JOIN dim_product d ON f.product_code = d.product_code
WHERE manufacturing_cost IN (
    SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost
    UNION
    SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost
) 
ORDER BY manufacturing_cost DESC;

-- Business Insights:
-- • Identifies cost optimization opportunities
-- • Reveals pricing strategy potential
-- • Highlights manufacturing efficiency gaps

-- =====================================================================================
-- QUERY 6: CUSTOMER PROFITABILITY ANALYSIS
-- =====================================================================================
-- Business Question: Generate a report which contains the top 5 customers who received 
--                   an average high pre_invoice_discount_pct for the fiscal year 2021 
--                   and in the Indian market.
-- Strategic Impact: Customer relationship optimization and discount strategy
-- Complexity Level: ⭐⭐⭐⭐ (Customer Analytics with Aggregations)
-- =====================================================================================

-- Query 6: Top 5 Customers by Discount Percentage (India, FY 2021)
SELECT 
    d.customer_code,
    d.customer,
    ROUND(AVG(f.pre_invoice_discount_pct) * 100, 2) AS average_discount_percentage
FROM dim_customer d
LEFT JOIN fact_pre_invoice_deductions f ON d.customer_code = f.customer_code
WHERE f.fiscal_year = 2021 
  AND d.market = 'India'
GROUP BY d.customer_code, d.customer
ORDER BY average_discount_percentage DESC
LIMIT 5;

-- Business Insights:
-- • Identifies high-value customer relationships
-- • Reveals discount strategy effectiveness
-- • Supports customer loyalty program development

-- =====================================================================================
-- QUERY 7: REVENUE TREND ANALYSIS
-- =====================================================================================
-- Business Question: Get the complete report of the Gross sales amount for the customer 
--                   "Atliq Exclusive" for each month.
-- Strategic Impact: Performance tracking and seasonal planning
-- Complexity Level: ⭐⭐⭐⭐ (Time Series Analysis with Multiple Joins)
-- =====================================================================================

-- Query 7: Monthly Gross Sales Analysis for Atliq Exclusive
SELECT 
    CONCAT(MONTHNAME(fs.date), ' (', YEAR(fs.date), ')') AS 'Month', 
    fs.fiscal_year,
    ROUND(SUM(fg.gross_price * fs.sold_quantity), 2) AS gross_sales_amount
FROM fact_sales_monthly fs 
JOIN dim_customer d ON fs.customer_code = d.customer_code
JOIN fact_gross_price fg ON fs.product_code = fg.product_code
WHERE d.customer = 'Atliq Exclusive'
GROUP BY Month, fs.fiscal_year 
ORDER BY fs.fiscal_year, fs.date;

-- Business Insights:
-- • Reveals seasonal sales patterns
-- • Identifies peak and low-performing months
-- • Supports inventory and capacity planning

-- =====================================================================================
-- QUERY 8: SEASONAL PERFORMANCE ANALYSIS
-- =====================================================================================
-- Business Question: In which quarter of 2020, got the maximum total_sold_quantity?
-- Strategic Impact: Seasonal demand planning and operational optimization
-- Complexity Level: ⭐⭐⭐ (Quarterly Aggregation with CASE Logic)
-- =====================================================================================

-- Query 8: Peak Quarter Analysis for FY 2020
SELECT 
    CASE
        WHEN date BETWEEN '2019-09-01' AND '2019-11-01' THEN 'Q1 (Sep-Nov)'  
        WHEN date BETWEEN '2019-12-01' AND '2020-02-01' THEN 'Q2 (Dec-Feb)'  
        WHEN date BETWEEN '2020-03-01' AND '2020-05-01' THEN 'Q3 (Mar-May)'  
        WHEN date BETWEEN '2020-06-01' AND '2020-08-01' THEN 'Q4 (Jun-Aug)'  
    END AS quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY quarter
ORDER BY total_sold_quantity DESC
LIMIT 1;

-- Business Insights:
-- • Identifies peak demand periods for capacity planning
-- • Supports seasonal inventory management
-- • Guides marketing campaign timing

-- =====================================================================================
-- QUERY 9: CHANNEL PERFORMANCE OPTIMIZATION
-- =====================================================================================
-- Business Question: Which channel helped to bring more gross sales in the fiscal year 2021 
--                   and the percentage of contribution?
-- Strategic Impact: Distribution strategy and channel investment optimization
-- Complexity Level: ⭐⭐⭐⭐⭐ (Channel Analysis with Percentage Calculations)
-- =====================================================================================

-- Query 9: Channel Performance & Contribution Analysis (FY 2021)
WITH gross_sales AS (
    SELECT 
        d.channel,
        ROUND(SUM(fg.gross_price * fs.sold_quantity / 1000000), 2) AS gross_sales_mln
    FROM fact_sales_monthly fs 
    JOIN dim_customer d ON fs.customer_code = d.customer_code
    JOIN fact_gross_price fg ON fs.product_code = fg.product_code
    WHERE fs.fiscal_year = 2021
    GROUP BY d.channel
)
SELECT 
    channel, 
    CONCAT(gross_sales_mln, ' M') AS gross_sales_mln,
    CONCAT(ROUND(gross_sales_mln * 100 / total_sales, 2), ' %') AS percentage_contribution
FROM (
    SELECT *, (SELECT SUM(gross_sales_mln) FROM gross_sales) AS total_sales
    FROM gross_sales
) channel_performance
ORDER BY gross_sales_mln DESC;

-- Business Insights:
-- • Identifies most profitable distribution channels
-- • Quantifies channel contribution for investment decisions
-- • Supports omnichannel strategy development

-- =====================================================================================
-- QUERY 10: PRODUCT PORTFOLIO EXCELLENCE
-- =====================================================================================
-- Business Question: Get the Top 3 products in each division that have a high 
--                   total_sold_quantity in the fiscal_year 2021.
-- Strategic Impact: Product portfolio optimization and division strategy
-- Complexity Level: ⭐⭐⭐⭐⭐ (Ranking Analysis with Window Functions)
-- =====================================================================================

-- Query 10: Top 3 Products by Division (FY 2021)
WITH product_sales AS (
    SELECT 
        d.division,
        d.product,
        fs.product_code,
        SUM(fs.sold_quantity) AS total_sold_quantity
    FROM dim_product d 
    JOIN fact_sales_monthly fs ON d.product_code = fs.product_code
    WHERE fs.fiscal_year = 2021 
    GROUP BY fs.product_code, d.division, d.product
),
ranked_products AS (
    SELECT 
        division,
        product,
        product_code,
        total_sold_quantity, 
        RANK() OVER(PARTITION BY division ORDER BY total_sold_quantity DESC) AS rank_order
    FROM product_sales
)
SELECT 
    division,
    product,
    product_code,
    total_sold_quantity,
    rank_order
FROM ranked_products
WHERE rank_order IN (1, 2, 3)
ORDER BY division, rank_order;

-- Business Insights:
-- • Identifies star products in each division
-- • Reveals cross-division performance patterns
-- • Supports product rationalization decisions

-- =====================================================================================
-- PERFORMANCE OPTIMIZATION NOTES:
-- =====================================================================================
-- 1. Ensure proper indexing on join columns (
