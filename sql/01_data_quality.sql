-- Looking for data anomalies


-- Checking for null records

select
	count(*) as total_rows,
	sum(case when sale_id is null then 1 else 0 end) as null_sale_ids,
	sum(case when date is null then 1 else 0 end) as null_dates,
	sum(case when store_id is null then 1 else 0 end) as null_store_ids,
	sum(case when product_id is null then 1 else 0 end) as null_product_ids,
	sum(case when units is null then 1 else 0 end) as null_units
from sales

-- checking if there is any transactions with unknown product

select distinct s.product_id
from sales s
left join products p on s.Product_ID = p.Product_ID
where p.Product_ID is null

-- checking if there is any transactions with unknown store

select distinct s.Store_ID
from sales s
left join stores st on s.Store_ID  = st.Store_ID
where st.store_ID is null

-- checking if there is any records of non existent items in inventory

select distinct i.product_id
from inventory i 
left join products p on i.Product_ID = p.Product_ID
where p.Product_ID is null

-- looking for duplicates

select
	sale_id,
	COUNT(*) as duplicates
from sales
group by sale_id
having COUNT(*) > 1


-- looking for any invalid amounts (for example negative product cost)
select 
	'sales_units <= 0' as check_name, 
	count(*) as invalid_count 
from sales 
where units <= 0
union all
select 
	'inventory_stock < 0', 
	count(*) 
from inventory 
where stock_on_hand < 0
union all
select 
	'product_cost <= 0', 
	count(*) 
from products 
where product_cost <= 0
union all
	select 
	'product_price <= 0',
	count(*) 
from products 
where product_price <=0