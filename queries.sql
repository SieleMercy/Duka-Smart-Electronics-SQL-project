
-- ### Section A — SQL fundamentals (Q1–Q10)

-- Q1: Retrieve all customer records
select * from customers;

-- Q2: Display customer names, cities, and segments
select customer_name, city, customer_segment from customers;

-- Q3: Find customers living in nairobi
select * from customers where city = 'Nairobi';

-- Q4: Find customers registered after january 1, 2025
select * from customers where registration_date > '2025-01-01';

-- Q5: Display all unique customer cities
select distinct city from customers;

-- Q6: Retrieve the 10 most recent orders
select * from orders order by order_date desc limit 10;

-- Q7: Find orders with unit prices above ksh 10,000
select * from orders where unit_price > 10000;

-- Q8: Find customers whose names start with a
select * from customers where customer_name like 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5
select * from orders where quantity between 2 and 5;

-- Q10: Find orders paid through m-pesa
select * from orders where payment_method = 'M-Pesa';


--### Section B — Aggregation and grouping (Q11–Q20)

-- Q11: Count all customers
select count(*) as total_customers from customers;

-- Q12: Count all orders
select count(*) as total_orders from orders;

-- Q13: Calculate completed-order revenue
select sum(quantity * unit_price * (1 - discount / 100)) as completed_revenue 
from orders 
where order_status = 'Completed';

-- Q14: Calculate the average completed-order value
select avg(quantity * unit_price * (1 - discount / 100)) as avg_completed_order_value 
from orders 
where order_status = 'Completed';

-- Q15: Find the highest and lowest product prices
select max(unit_price) as highest_price, min(unit_price) as lowest_price 
from orders;

-- Q16: Calculate revenue by product category
select product_category, sum(quantity * unit_price * (1 - discount / 100)) as revenue 
from orders 
where order_status = 'Completed' 
group by product_category;

-- Q17: Count customers by city
select city, count(*) as customer_count 
from customers 
group by city;

-- Q18: Calculate quantity sold by product
select product_name, sum(quantity) as total_quantity_sold 
from orders 
group by product_name;

-- Q19: Find categories generating more than ksh 100,000 in revenue
select product_category, sum(quantity * unit_price * (1 - discount / 100)) as revenue 
from orders 
where order_status = 'Completed' 
group by product_category 
having sum(quantity * unit_price * (1 - discount / 100)) > 100000;

-- Q20: Calculate the percentage of cancelled orders
select (count(case when order_status = 'Cancelled' then 1 end) * 100) / count(*) as cancellation_pct 
from orders;


-- ###Section c — joins and customer analytics (q21–q28)

-- Q21: Display orders with customer names and cities
select o.order_id, c.customer_name, c.city, o.product_name, o.order_date
from orders o
join customers c on o.customer_id = c.customer_id;

-- Q22: Calculate total spending by customer
select c.customer_id, c.customer_name, SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS total_spent
from customers c
left join orders o 
on c.customer_id = o.customer_id 
and o.order_status = 'Completed'
group by c.customer_id, c.customer_name;


-- Q23: Identify customers who have never ordered
select c.customer_name,o.order_id
from customers c
left join orders o 
on c.customer_id = o.customer_id
where o.order_id is null;
 
-- Q24: Find the 10 highest-spending customers
select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spent
from customers c
join orders o on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spent desc
limit 10;

-- Q25: Calculate revenue by customer city
select c.city, sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_revenue
from customers c
join orders o 
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.city;

-- Q26: Identify customers with more than five orders
select c.customer_id, c.customer_name, count(o.order_id) as order_count
from customers c
join orders o 
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(o.order_id) > 5;

-- Q27: Calculate average customer spending by segment
select c.customer_segment, avg(cust_spend.total_spent) as avg_segment_spending
from customers c
join (
    select customer_id, sum(quantity * unit_price * (1 - discount / 100.0)) as total_spent
    from orders
    where order_status = 'Completed'
    group by customer_id
) cust_spend on c.customer_id = cust_spend.customer_id
group by c.customer_segment;

-- Q28: Identify the most popular category among vip customers
select o.product_category, count(*) as order_count
from orders o
join customers c on o.customer_id = c.customer_id
where c.customer_segment = 'VIP'
group by o.product_category
order by order_count desc
limit 1;


-- section d — subqueries and ctes (q29–q34)


-- Q29: Find customers spending above the average total spending per purchasing customer
with customer_spending as (
    select customer_id, sum(quantity * unit_price * (1 - discount / 100)) as total_spent
    from orders
    where order_status = 'Completed'
    group by customer_id
)
select * 
from customer_spending 
where total_spent > (select avg(total_spent) from customer_spending);

-- Q30: Find products priced above the overall average unit price
select distinct product_name, unit_price 
from orders 
where unit_price > (select avg(unit_price) from orders);

-- Q31: Use a cte to identify the three highest-revenue months
with monthly_rev as (
    select date_trunc('month', order_date) as order_month, 
           sum(quantity * unit_price * (1 - discount / 100)) as revenue
    from orders
    where order_status = 'Completed'
    group by 1
)
select * from monthly_rev order by revenue desc limit 3;


-- Q32: Find customers purchasing from at least three categories
select c.customer_id, c.customer_name,count(distinct o.product_category)
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(distinct o.product_category) >= 3;

-- Q33: Use a cte to calculate category revenue, cost, profit, and profit margin
with cat_summary as (
    select product_category, 
           sum(quantity * unit_price * (1 - discount / 100)) as revenue, 
           sum(quantity * cost_price) as cost
    from orders 
    where order_status = 'Completed' 
    group by product_category
)
select product_category, cost, revenue, 
(revenue - cost) as profit, 
round(((revenue - cost) / NULLIF(revenue, 0)) * 100, 2) as profit_margin_pct
from cat_summary;

-- Q34: Find customers whose latest completed order is more than 90 days before latest order date
with max_date as (
    select max(order_date) as latest_date from orders
), 
cust_latest as (
    select customer_id, max(order_date) as last_order_date 
    from orders 
    where order_status = 'Completed' 
    group by customer_id
)
select c.* 
from cust_latest cl 
join customers c on cl.customer_id = c.customer_id 
cross join max_date md 
where cl.last_order_date < (md.latest_date - interval '90 days');


-- section e — window functions (q35–q42)


-- Q35: Rank customers by spending using rank()
select c.customer_id, c.customer_name, 
       sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spent, 
       rank() over (order by sum(o.quantity * o.unit_price * (1 - o.discount / 100)) desc) as spending_rank 
from customers c 
join orders o on c.customer_id = o.customer_id 
where o.order_status = 'Completed' 
group by c.customer_id, c.customer_name;

-- Q36: Number each customer's orders by recency using row_number()
select order_id, customer_id, order_date, 
       row_number() over (partition by customer_id order by order_date desc) as order_recency_rank 
from orders;

-- Q37: Rank products within categories using dense_rank()
select product_name, product_category, 
       sum(quantity * unit_price) as sales, 
       dense_rank() over (partition by product_category order by sum(quantity * unit_price) desc) as product_rank 
from orders 
group by product_name, product_category;

-- Q38: Calculate cumulative monthly revenue
with monthly as (
    select date_trunc('month', order_date) as mth, 
           sum(quantity * unit_price * (1 - discount / 100)) as rev 
    from orders 
    where order_status = 'Completed' 
    group by 1
)
select mth, rev, sum(rev) over (order by mth) as cumulative_revenue 
from monthly;

-- Q39: Compare monthly revenue using lag()
with monthly as (
    select date_trunc('month', order_date) as mth, 
           sum(quantity * unit_price * (1 - discount / 100)) as rev 
    from orders 
    where order_status = 'Completed' 
    group by 1
)
select mth, rev, lag(rev, 1) over (order by mth) as prev_month_rev 
from monthly;

-- Q40: Calculate month-over-month revenue growth (%)
with monthly as (
    select date_trunc('month', order_date) as mth, 
           sum(quantity * unit_price * (1 - discount / 100)) as rev 
    from orders 
    where order_status = 'Completed' 
    group by 1
), 
lagged as (
    select mth, rev, lag(rev, 1) over (order by mth) as prev_rev 
    from monthly
)
select mth, rev, 
       round(((rev - prev_rev) / nullif(prev_rev, 0)) * 100, 2) as mom_growth_pct 
from lagged;

-- Q41: Divide customers into four spending groups using ntile(4)
with cust_spend as (
    select customer_id, sum(quantity * unit_price * (1 - discount / 100.0)) as spent 
    from orders 
    where order_status = 'Completed' 
    group by customer_id
)
select customer_id, spent, ntile(4) over (order by spent desc) as spending_quartile 
from cust_spend;

-- Q42: Calculate each category's share of total revenue using window functions
select product_category, 
       sum(quantity * unit_price * (1 - discount / 100)) as cat_rev, 
       sum(sum(quantity * unit_price * (1 - discount / 100))) over () as total_rev, 
       round((sum(quantity * unit_price * (1 - discount / 100)) / sum(sum(quantity * unit_price * (1 - discount / 100))) over ()) * 100, 2) as revenue_share_pct 
from orders 
where order_status = 'Completed' 
group by product_category;


-- section f — advanced business intelligence (q43–q46)


-- Q43: Create a monthly_sales_summary view, then select from it
create view monthly_sales_summary as 
select date_trunc('month', order_date) as order_month, 
       count(order_id) as total_orders, 
       sum(quantity * unit_price * (1 - discount / 100)) as revenue, 
       sum(quantity * cost_price) as cost, 
       sum(quantity * unit_price * (1 - discount / 100)) - sum(quantity * cost_price) as profit 
from orders 
where order_status = 'Completed' 
group by 1;

select * from monthly_sales_summary;

-- Q44: Create a pl/pgsql function returning completed-order revenue for a customer id
create function get_customer_revenue(p_customer_id int) 
returns numeric as $$ 
declare 
    v_revenue numeric; 
begin 
    select coalesce(sum(quantity * unit_price * (1 - discount / 100.0)), 0) 
    into v_revenue 
    from orders 
    where customer_id = p_customer_id and order_status = 'Completed'; 
    
    return v_revenue; 
end; 
$$ language plpgsql;

-- Test the function for an existing customer id and a non-existing id
select get_customer_revenue(1);
select get_customer_revenue(999999);

-- Q45: Segment customers into high, medium, and low value, and explain your thresholds

-- Threshold rationale: high value = top 20% spending tier, medium value = middle 50%, low value = bottom 30%
with cust_totals as (
    select customer_id, sum(quantity * unit_price * (1 - discount / 100.0)) as total_spent
    from orders
    where order_status = 'Completed'
    group by customer_id
),
ranked_cust as (
    select customer_id, total_spent,
           percent_rank() over (order by total_spent desc) as spend_pct_rank
    from cust_totals
)
select customer_id, total_spent,
       case 
           when spend_pct_rank <= 0.20 then 'High Value'
           when spend_pct_rank <= 0.70 then 'Medium Value'
           else 'Low Value'
       end as customer_tier
from ranked_cust;

-- Q46: Produce a management report: top five customers, top five products, most profitable category, and lowest-revenue month

-- 1. Top five customers
select c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as revenue
from customers c join orders o on c.customer_id = o.customer_id
where o.order_status = 'Completed' group by c.customer_name order by revenue desc limit 5;

-- 2. Top five products
select product_name, sum(quantity * unit_price * (1 - discount / 100)) as revenue
from orders where order_status = 'Completed' group by product_name order by revenue desc limit 5;

-- 3. Most profitable category
select product_category, sum(quantity * unit_price * (1 - discount / 100)) - sum(quantity * cost_price) as profit
from orders where order_status = 'Completed' group by product_category order by profit desc limit 1;

-- 4. Lowest-revenue month
select order_month, revenue from monthly_sales_summary order by revenue asc limit 1;

