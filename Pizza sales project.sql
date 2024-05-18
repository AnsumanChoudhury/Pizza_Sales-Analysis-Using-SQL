create database pizzahut;
use pizzahut;
describe pizzas;
select*from order_details;
select*from orders;

# Questions and their respective queries
## Basic

### Q1.Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

### Q2.Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_revenue
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id;

### Q3.Identify the highest-priced pizza
SELECT pt.name, p.price
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE p.price = (SELECT MAX(price) FROM pizzas);

# OR
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC limit 1;

### Q4.Identify the most common pizza size ordered.
SELECT p.size, SUM(od.quantity) AS total_ordered
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
limit 1;

### Q5. List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) as total_quantity_ordered
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by total_quantity_ordered desc limit 5;

## Intermediate:
### Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,
sum(order_details.quantity) as total_quantity_ordered
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category order by  total_quantity_ordered desc;

### Q7. Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS hour_of_day, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

### Q8. Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as total_variety 
from pizza_types
group by category order by total_variety desc;

### Q9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT round (AVG(total_pizzas),0) AS avg_pizzas_ordered_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS total_pizzas
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS order_totals
;

### Q10. Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name AS pizza_type, SUM(od.quantity * p.price) AS revenue
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

## Advance:
### Q11. Calculate the percentage contribution of each pizza category to total revenue.
WITH total_revenue AS (
    SELECT SUM(od.quantity * p.price) AS total
    FROM pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
)
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price),2) AS revenue,
    ROUND((SUM(od.quantity * p.price) / (SELECT total FROM total_revenue) * 100),2) AS percentage_contribution
FROM 
    pizzas p
JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
JOIN 
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 
    pt.category
ORDER BY 
    percentage_contribution DESC;

### Q12. Analyze the cumulative revenue generated over time.
SELECT 
    order_date,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date),2) AS cumulative_revenue
FROM (
    SELECT 
        o.order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    JOIN 
        pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY 
        o.order_date
) AS daily_revenues
ORDER BY 
    order_date;
    
### Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH pizza_revenues AS (
    SELECT 
        pt.category,
        pt.name AS pizza_type,
        SUM(od.quantity * p.price) AS revenue
    FROM 
        pizzas p
    JOIN 
        pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    JOIN 
        order_details od ON p.pizza_id = od.pizza_id
    GROUP BY 
        pt.category, pt.name
),
ranked_pizzas AS (
    SELECT 
        category,
        pizza_type,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS pizza_rank
    FROM 
        pizza_revenues
)
SELECT 
    category,
    pizza_type,
    revenue
FROM 
    ranked_pizzas
WHERE 
    pizza_rank <= 3
ORDER BY 
    category, pizza_rank;
    

    
    







