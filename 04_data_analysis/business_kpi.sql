
-- Main Business KPI's
-- Revenue, Active customers, No of Orders, Unit Sold
Select 
  Count(distinct o.customerd_id) as active_customers,
  Count(distinct o.order_id) as total_orders,
  Count(oi.quantity) as unit_sold,
  Round(Sum(oi.quantity*p.price),2) as revenue
From orders o
Left join order_items oi on o.order_id = oi.order_id,
Left join products p on oi.product_id = p.product_id
Where o.order_date between '2025-01-01' and '2025-12-31';

-- Average memebr spent (AMS), Average order value (AOV), Average orders per cusomer (AOPC), Average bascket size (ABS)
Select 
  Round(Sum(oi.quantity*p.price),2)/Count(distinct o.customerd_id) as AMS,
  Round(Sum(oi.quantity*p.price),2)/Count(distinct o.order_id) as AOV,
  Count(distinct o.customerd_id)/Count(distinct o.order_id) as AOPC,
  Count(oi.quantity)/Count(distinct o.order_id) as ABS
From orders o
Left join order_items oi on o.order_id = oi.order_id,
Left join products p on oi.product_id = p.product_id
Where o.order_date::date between '2025-01-01' and '2025-12-31';

-- Cusomers KPI's
-- Customer Retention, Churn and aquisition
with cte as (
  Select
    o.customr_id,
    max(Case when o.order_date::date between '2024-01-01' and '2024-12-31' then 1 else 0 end) as active_2024,
    max(Case when o.order_date::date between '2025-01-01' and '2025-12-31' then 1 else 0 end) as active_2024
  From orders o
  )
  Select 
    Sum(Case When active_2024 = 1 and active_2025 = 1 then 1 else 0 End) as Active_customers,
    Sum(Case When active_2024 = 1 and active_2025 = 0 then 1 else 0 End) as Churned_customers,
    Sum(Case When active_2024 = 0 and active_2025 = 1 then 1 else 0 End) as New_customers,
    (Sum(Case When active_2024 = 1 and active_2025 = 1 then 1 else 0 End)/(Sum(Case When active_2024 = 1 and active_2025 = 1 then 1 else 0 End)+Sum(Case When active_2024 = 1 and active_2025 = 0 then 1 else 0 End)))*100 as Retention_%
  From cte;

-- Repeat cusomers
with cte as (
  Select 
    o.customer_id as customer_id, 
    count(distinct o.order_id) as order_counts
  from orders o
  Where o.order_date::date between '2025-01-01' and '2025-12-31'
  )
Select 
  100*count(Case When order_counts>=2 then customer_id else null end)/count(customer_id) as repeat_rate
from cte;
  
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
  Case When o.order_date>f.fod then 'New_customer' Else 'Old_customer' End as customer_type,
  Round(Sum(oi.quantity*p.price),2) as revenue
From orders o
left join first_order f on o.customer_id = f.customer_id
Left join order_items oi on o.order_id = oi.order_id
Left join products p on oi.product_id = p.product_id
Where o.order_date::date between '2025-01-01' and '2025-12-31'
Group by customer_type;



