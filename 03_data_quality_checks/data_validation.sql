-- Checks for duplicate entries
-- Check for duplicate customers
Select customer_id, Count(*)
From customers 
Group by customer_id
Having Count(*)>1;

-- Check for duplicate order entries
Select order_id, count(*)
From orders
Group by order_id
Having count(*)>1;


-- Checking Orphan records
-- Check for orders without customers
Select * 
from orders o 
Left join customers c on o.customer_id = c.customer_id
where c.customer_id is null;

-- Check for order_items where product not available in products
Select *
From order_items ot
left join products p on ot.product_id = p.product_id
where p.product_id is null;


-- Missing Values
-- Find missing values in customer table
Select count(customer_id), count(name_name), count(city), count(signup_date)
from customers; --returns not null counts for each field then compare with count(customer_id)

-- Find missing values in product table
Select count(product_id), count(product_name), count(category), count(price)
From products;

-- Date validations
-- customer signedup_date where orders before signed_up
Select o.order_id, o.order_date, c.signedup_date, c.customer_name
from orders o
left join customers on o.customer_id = c.customer_id
where o.order_date<c.signedup_date;

-- Check for futur order dates
Select * from orders
where o.order_date>current_date;

--Invalid Entries in billing order_item table/product table
--Check for negative or zero qty
Select * from order_items
where quantity<=0;  -- order qty can not be o or negative

--Check for negative or zero price
Select * from products
Where price<=0;

-- check for Order without any item
Select o.order_id
From orders o
Left join order_items ot on o.order_id = ot.order_id
where ot.order_id is null;






