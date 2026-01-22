-- =====================================
-- End-to-End Sales Analysis using MySQL📶
-- =====================================
-- Objective 
-- This project analyzes sales performance using SQL by answering key business questions related to 
-- revenue, profitability, trends, and regional and category-level performance.

-- CORE BUSINESS KPIs
with kpi as (select sum(sales) as total_sales , 
sum(profit) as total_profit ,
sum(quantity) as total_quantity_sold ,
count(distinct order_id) as total_orders 
from sales
) 
select * , 
round(total_profit/total_sales*100 , 2) as profit_margin,
round(total_sales/total_orders, 2) as average_order_value
from kpi;
-- INSIGHT💡
-- The company generated total sales of ₹322,000 with a profit of ₹69,300, 
-- resulting in a healthy profit margin of 21.52%. A total of 6 orders were placed,
-- selling 21 units overall with avergae sorder value of 53,666.
-- I calculated AOV using total sales divided by distinct orders to avoid inflation caused by multiple products per order.

-- ========================================================================== 

-- TIME BASED ANALYSIS(year)
select sum(sales) as sales, 
year(order_date) as year 
from sales as s 
join orders as o on o.order_id = s.order_id
group by year 
order by sales desc;
-- Total sales 2022 = 153,000
-- Total sales 2023 = 169,000


-- TIME BASED ANALYSIS(month) 
SELECT YEAR(o.order_date) AS year,
MONTHNAME(o.order_date) AS month,
SUM(s.sales) AS total_sales
FROM sales  as s
JOIN orders as o 
ON s.order_id = o.order_id
GROUP BY YEAR , MONTH
ORDER BY year, total_sales DESC;
-- Best month by sales(2022)= August
-- Best month by sales(2023) = October


-- YOY GROWTH %
with yearly_sales as ( 
select year(order_date) as year , 
sum(sales) as total_sales
from sales as s 
join orders as o on s.order_id = o.order_id  
group by year
)
select year , total_sales , 
lag(total_sales) over (order by year) as previous_year,
round(
((total_sales - lag(total_sales) over (order by year)) /
lag(total_sales) over (order by year)) *100 , 2)
as YOY_growth_percent
from yearly_sales
order by year;
-- Sales increased by 10.46% in 2023 compared to 2022, indicating positive year-over-year growth.

-- ==========================================================================

-- CATEGORY-WISE SALES , PROFIT & REVENUE CONTRIBUTION ANALYSIS
with category_sales_profit as (
select 
sum(sales) as total_sales,
sum(profit) as total_profit,
category 
from sales as s
join products as p on s.product_id = p.product_id
group by category
order by total_sales desc
),
overall_sales as ( 
select sum(sales) as grand_total
from sales
)
select cs.category , total_sales , total_profit , 
round(cs.total_sales / grand_total *100, 2) as top_category_contribution_pct
from category_sales_profit as cs
cross join overall_sales;
-- INSIGHT💡
-- Technology is the highest revenue-contributing category, accounting for the largest share of total sales.
-- Although it generates strong sales, its profit margin indicates potential opportunities for cost optimization or 
-- pricing improvements compared to other categories.

-- ==========================================================================

-- CATEGORIES WITH BELOW AVERAGE PROFIT MARGIN
with category_margin as (
select category , 
round(sum(profit) / sum(sales) *100, 2) as profit_margin
from sales as s
join products as p on s.product_id = p.product_id
group by category 
)
select category , profit_margin
from category_margin
where profit_margin < (select avg(profit_margin) from category_margin);
-- Furniture’s profit margin is 15.79% lower than the overall average.

-- ==========================================================================

-- SALES BY REGION
select region , 
sum(sales) as total_sales ,
sum(profit) as total_profit
from sales as s
join orders as o on s.order_id = o.order_id
join customers as c on c.customer_id = o.customer_id
group by region 
order by total_profit desc;
-- The North region leads in profitability, generating a total profit of 32,500

-- ==========================================================================

-- RUNNING TOTAL 
select date_format(order_date,"%y-%m" ) as month,
sum(sales) as monthly_sales, 
sum(sum(sales)) over (order by date_format(order_date,"%y-%m" )) as running_total
from sales as s
join orders as o on o.order_id = s.order_id
group by month
order by month;
-- Sales show a cumulative upward trend, indicating steady buisness growth over time

-- ==========================================================================

-- TOP 3 CUSTOMERS BY SALES
with customer_sales as (
select o.customer_id,
customer_name , 
sum(sales) as total_sales
from sales as s
join orders as o on s.order_id = o.order_id
join customers as c on c.customer_id = o.customer_id
group by o.customer_id , customer_name 
)
SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM customer_sales
) ranked_customers
WHERE sales_rank <= 3;
-- 1 : KUNAL MEHTA CUSTOMER_ID = 5
-- 2 : AARAV SHARMA CUSTOMER_ID = 1
-- 3 : ROHAN GUPTA CUSTOMER_ID = 3

-- ==========================================================================














