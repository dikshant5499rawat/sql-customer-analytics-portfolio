
-- Main Business KPI's
-- Revenue, Active customers, No of Orders, Unit Sold
Select 
  Count(distinct o.customer_id) as active_customers,
  Count(distinct o.order_id) as total_orders,
  Sum(oi.quantity) as unit_sold,
  Round(Sum(oi.quantity*p.price),2) as revenue
From orders o
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Where o.order_date between '2025-01-01' and '2025-12-31';

-- Average memebr spent (AMS), Average order value (AOV), Average orders per cusomer (AOPC), Average bascket size (ABS)
Select 
  Round(Sum(oi.quantity*p.price)/Count(distinct o.customer_id),2) as AMS,
  Round(Sum(oi.quantity*p.price)/Count(distinct o.order_id),2) as AOV,
  Round(Count(distinct o.order_id)/Count(distinct o.customer_id),2) as AOPC,
  Round(Sum(oi.quantity)/Count(distinct o.order_id),2) as ABS
From orders o
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Where o.order_date::date between '2025-01-01' and '2025-12-31';
----------------------------------------------------------------------------------------------------------------------------------------

-- Cusomers KPI's
-- Customer Retention, Churn and aquisition
with cte as (
  Select
    o.customer_id,
    max(Case when o.order_date::date between '2024-01-01' and '2024-12-31' then 1 else 0 end) as active_2024,
    max(Case when o.order_date::date between '2025-01-01' and '2025-12-31' then 1 else 0 end) as active_2025
  From orders o
  Group by o.customer_id
  )
  Select 
    Sum(Case When active_2024 = 1 and active_2025 = 1 then 1 else 0 End) as Active_customers,
    Sum(Case When active_2024 = 1 and active_2025 = 0 then 1 else 0 End) as Churned_customers,
    Sum(Case When active_2024 = 0 and active_2025 = 1 then 1 else 0 End) as New_customers,
    Round((Sum(Case When active_2024 = 1 and active_2025 = 1 then 1 else 0 End)/(Sum(Case When active_2024 = 1 then 1 else 0 End)))*100,2) as Retention_%
  From cte;

-- Repeat cusomers
with cte as (
  Select 
    o.customer_id as customer_id, 
    count(distinct o.order_id) as order_counts
  from orders o
  Where o.order_date::date between '2025-01-01' and '2025-12-31'
  Group by o.customer_id
  )
Select 
  Round(100*count(Case When order_counts>=2 then 1 end)/count(customer_id),2) as repeat_rate
from cte;

-- Customer Lifetime Value (CLV)
Select
  c.customer_id,
  c.customer_name,
  Round(Sum(oi.quantity*p.price),2) as lifetime_value
From customers c 
Left join orders o on c.customer_id = o.customer_id 
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Group by 1,2
Order by lifetime_value desc;
----------------------------------------------------------------------------------------------------------------------------------------

-- Growth KPI's
--month_on_month growth
With monthly_sales as (
  Select
    DATE_TRUNC('month', o.order_date) AS month,
    Round(Sum(oi.quantity*p.price),2) as revenue
  From orders o
  Left join order_items oi on o.order_id = oi.order_id
  Left join products p on oi.product_id = p.product_id
  Group by 1
  )
Select
  month,
  revenue,
  round(100*(revenue - LAG(revenue) over(order by month))/LAG(revenue) over(order by month),2) as mom_growth
From monthly_sales
Order by month;

-- New Vs Repeat Revenue in 2025
with first_order as (
  Select 
    customer_id, 
    min(order_date) as fod
  From orders )
Select
  Case When o.order_date=f.fod then 'New_customer' Else 'Repeat_customer' End as customer_type,
  Round(Sum(oi.quantity*p.price),2) as revenue
From orders o
left join first_order f on o.customer_id = f.customer_id
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Where o.order_date::date between '2025-01-01' and '2025-12-31'
Group by customer_type;
----------------------------------------------------------------------------------------------------------------------------------------

-- Product KPI's 
-- Top 10 Products by revenue
Select
  p.product_id,
  p.product_name,
  Round(Sum(oi.quantity*p.price),2) as revenue
From orders o
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Group by 1,2
Order by revenue desc
Limit 10;

-- Top 3 Categories by revenue
Select
  p.category,
  Round(Sum(oi.quantity*p.price),2) as revenue
From orders o
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Group by 1
Order by revenue desc
Limit 3;

-- Geo/Segment KPI's
-- Revenue by cities
Select
  c.city,
  Round(Sum(oi.quantity*p.price),2) as revenue 
From customers c 
Left join orders o on c.customer_id = o.customer_id 
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Group by 1
Order by revenue desc
Limit 3;
  
