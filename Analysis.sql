select * from payments;
select * from customerorders;
-- 1. Order and Sales Analysis:

SELECT
  DATE_FORMAT(order_date, '%Y-%m') as month,
  COUNT(order_id) AS total_orders,
  SUM(order_amount) AS total_revenue,
  COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) AS delivered_orders,
  COUNT(CASE WHEN order_status = 'pending' THEN 1 END) AS pending_orders
FROM customerorders
GROUP BY month
ORDER BY month;

-- 2. Customer Analysis:
select customer_id,count(order_id) as ordercount
from customerorders
group by customer_id
having ordercount > 1;
-- customer segmentation, and trends over time.
select customer_id,
       date_format(order_date,'%Y-%m') as month,
       sum(order_amount) as totalorder
       from customerorders
       group by customer_id,month
       order by month desc;

-- Payment Status Analysis:(Payment status by month)
select * from payments;
select 
      date_format(payment_date,'%Y-%m') as month,
	  count(payment_id) as total_payments,
	  sum(payment_amount) as amount,
	  payment_status
	  from payments
      group by month,payment_status
      order by month;
      
-- 4. Order Details Report:

 select o.order_id, o.customer_id, o.order_date, o.order_amount, o.order_status,
 p.payment_id,p.payment_date,p.payment_amount,p.payment_method, p.payment_status
 FROM customerorders o 
 left join payments P
 on o.order_id = p.order_id; 
 -- 5. Customer Retention Analysis – Plan & Explanation
 -- Step 1: Determine the month of the first order per customer
WITH first_orders AS (
  SELECT 
    customer_id, 
    MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_month
  FROM customerorders
  GROUP BY customer_id
),

-- Step 2: Link all orders to the customer's cohort
orders_with_cohort AS (
  SELECT 
    o.customer_id,
    DATE_FORMAT(o.order_date, '%Y-%m-01') AS order_month,
    f.cohort_month
  FROM customerorders o
  JOIN first_orders f ON o.customer_id = f.customer_id
)

-- Step 3: Count customers by cohort and how many made orders in subsequent months
SELECT
  cohort_month,
  order_month,
  COUNT(DISTINCT customer_id) AS active_customers
FROM orders_with_cohort
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;