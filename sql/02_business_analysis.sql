-- Which categories generates highest revenue and is their ranking changes depends on location (airport ,downtown etc.)
 with category_performance as (
 	select
 		st.store_location,
 		p.product_category,
 		sum(s.units) as total_units_sold,
 		round(sum(s.units*p.product_price), 2) as total_revenue,
 		round(sum(s.units * (p.product_price - p.product_cost)), 2) as total_profit,
        round((sum(s.units * (p.product_price - p.product_cost)) / sum(s.units * p.product_price)) * 100, 2) as profit_margin_pct
 	from sales s
 	join products p on s.Product_ID = p.Product_ID
 	join stores st on s.Store_ID = st.Store_ID
 	group by 1,2
 	),
 	ranked_categories as (
    select
        store_location,
        product_category,
        total_revenue,
        total_profit,
        profit_margin_pct,
        dense_rank() over (
            partition by store_location 
            order by total_profit desc
        ) as profit_rank
    from category_performance
	)
select
    store_location,
    profit_rank,
    product_category,
    total_revenue,
    total_profit,
    profit_margin_pct
from ranked_categories
order by 1,2;

-- In which months does the store chain hit peak sales, and how does MoM revenue growth trend over time?
with monthly_sales as (
	select
		date_format(s.date, '%Y-%m') as sales_year_month,
		sum(s.units) as total_units_sold,
		round(sum(s.units*p.product_price),2) as total_revenue,
		round(sum(s.units*(p.product_price-p.product_cost)),2) as total_profit
	from sales s
	join products p on s.Product_ID = p.Product_ID 
	group by 1
),
mom_growth as (
	select
		sales_year_month,
		total_units_sold,
		total_revenue,
		total_profit,
		lag(total_revenue) over (order by sales_year_month) as prev_month_rev,
		round((total_revenue - lag(total_revenue) over (order by sales_year_month)) / nullif(lag(total_revenue) over (order by sales_year_month), 0) * 100,2) as mom_rev_growth_prc
	from monthly_sales 		
)
select
	sales_year_month,
	total_units_sold,
	total_revenue,
	prev_month_rev,
	mom_rev_growth_prc,
	total_profit
from mom_growth
order by 1

-- How much capital is stored in inventory across the stores, and how long will the current stock last?

with product_inventory as (
    select
        product_id,
        sum(stock_on_hand) as total_stock_units
    from inventory
    group by product_id
),
daily_velocity as (
    select
        product_id,
        sum(units) * 1.0 / count(distinct date) as avg_daily_units
    from sales
    group by product_id
),
category_inventory as (
    select
        p.product_category,
        sum(coalesce(pi.total_stock_units, 0)) as total_stock_units,
        sum(coalesce(pi.total_stock_units, 0) * p.product_cost) as total_cost_value,
        sum(coalesce(pi.total_stock_units, 0) * p.product_price) as total_retail_value,
        sum(coalesce(dv.avg_daily_units, 0)) as total_daily_velocity
    from products p
    left join product_inventory pi on p.product_id = pi.product_id
    left join daily_velocity dv on p.product_id = dv.product_id
    group by p.product_category
)
select
    product_category,
    total_stock_units,
    round(total_cost_value, 2) as capital_tied_up,
    round((total_cost_value / sum(total_cost_value) over ()) * 100, 2) as share_of_total_capital_pct,
    round(total_retail_value, 2) as potential_revenue,
    round(total_stock_units / nullif(total_daily_velocity, 0), 1) as days_of_supply
from category_inventory
order by 3 desc;


-- how much of total profit/revenue is concentrated in the top tier of stores


-- Part 1: Store level Classification
with store_metrics as (
	select 
		st.store_id,
		st.store_name,
		st.store_city,
		st.store_location,
		st.store_open_date,
		sum(s.units) as total_sold_units,
		round(sum(s.units * p.product_price), 2) as total_revenue,
        round(sum(s.units * (p.product_price - p.product_cost)), 2) as total_profit,
        round((sum(s.units * (p.product_price - p.product_cost)) / nullif(sum(s.units * p.product_price), 0)) * 100, 2) as profit_margin_pct
	from stores st
	join sales s on st.Store_ID = s.Store_ID 
	join products p on s.Product_ID = p.Product_ID
	group by 1,2,3,4,5
),
store_bucketing as (
	select
		store_id,
		store_name,
		store_city,
		store_location,
		total_sold_units,
		total_revenue,
		total_profit,
		profit_margin_pct,
		ntile(3) over (order by total_profit desc) as profit_tertile
	from store_metrics	
	)
select 
	store_id,
	store_name,
	store_city,
	store_location,
	total_sold_units,
	total_revenue,
	total_profit,
	profit_margin_pct,
	case
		when profit_tertile = 1 then 'Tier 1'
		when profit_tertile = 2 then 'Tier 2'
		else 'Tier 3'
	end as store_tier
	from store_bucketing
	order by total_profit desc
	



-- Part 2: Executive Summary
with store_metrics as (
    select
        st.store_id,
        st.store_location,
        sum(s.units * p.product_price) as total_revenue,
        sum(s.units * (p.product_price - p.product_cost)) as total_profit,
        ntile(3) over (order by sum(s.units * (p.product_price - p.product_cost)) desc) as profit_tertile
    from stores st
    join sales s on st.store_id = s.store_id
    join products p on s.product_id = p.product_id
    group by st.store_id, st.store_location
),
tiered_stores as (
	select
		store_id,
		store_location,
		total_revenue,
		total_profit,
		case
			when profit_tertile = 1 then 'Tier 1'
			when profit_tertile = 2 then 'Tier 2'
			else 'Tier 3'
		end as store_tier
	from store_metrics
)
select 
	store_tier,
	count(store_id) as number_of_stores,
	round(sum(total_revenue),2) as tier_total_revenue,
	round((sum(total_revenue) / sum(sum(total_revenue)) over ()) * 100, 2) as revenue_share_pct,
    round(sum(total_profit), 2) as tier_total_profit,
    round((sum(total_profit) / sum(sum(total_profit)) over ()) * 100, 2) as profit_share_pct,
    round(avg(total_profit), 2) as avg_profit_per_store
from tiered_stores
group by store_tier 
order by tier_total_profit desc





