# PizzaHut Database Analysis Project

This project contains SQL scripts and queries used to analyze the PizzaHut database. The database includes tables for pizzas, pizza types, orders, and order details. The goal of this project is to perform various analyses to gain insights into sales, popular pizza types, order distribution, and revenue contributions.

## Project Structure

- **Database Creation and Setup**
  - Scripts to create the database and tables.

- **SQL Queries**
  - Queries to perform different types of analysis on the database.

## Database Schema

### Tables

#### `pizzas`
- `pizza_id`: INT, primary key
- `pizza_type_id`: INT, foreign key to `pizza_types`
- `size`: VARCHAR
- `price`: DECIMAL

#### `pizza_types`
- `pizza_type_id`: INT, primary key
- `name`: VARCHAR
- `category`: VARCHAR
- `ingredients`: TEXT

#### `orders`
- `order_id`: INT, primary key
- `order_date`: DATE
- `order_time`: TIME

#### `order_details`
- `order_details_id`: INT, primary key
- `order_id`: INT, foreign key to `orders`
- `pizza_id`: INT, foreign key to `pizzas`
- `quantity`: INT

## Some Major SQL Queries

### Determine the most common pizza size ordered

SELECT p.size, SUM(od.quantity) AS total_ordered
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
LIMIT 1;

### Average number of pizzas ordered per day
SELECT order_date, AVG(total_pizzas) AS avg_pizzas_ordered_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS total_pizzas
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS order_totals
GROUP BY order_date;

### Top 3 most ordered pizza types based on revenue
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

### Percentage contribution of each category to total revenue
WITH total_revenue AS (
    SELECT SUM(od.quantity * p.price) AS total
    FROM pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
)
SELECT 
    pt.category,
    SUM(od.quantity * p.price) AS revenue,
    (SUM(od.quantity * p.price) / (SELECT total FROM total_revenue) * 100) AS percentage_contribution
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

### Cumulative revenue generated over time
SELECT 
    order_date,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
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


### Getting Started
Prerequisites
-MySQL Server
-MySQL Workbench or any other SQL client

### Setting Up the Database
Create the database:
CREATE DATABASE pizzahut;
USE pizzahuCreate the tables and insert sample data using the provided SQL scripts.

### Running the Queries
Execute the queries in the provided order to perform the analyses described above.

### License
This project is licensed under the MIT License - see the LICENSE file for details.

### Acknowledgments
This project is inspired by the need to analyze pizza sales data to gain business insights.
Special thanks to the MySQL documentation for the comprehensive SQL reference.


This README provides an overview of the project, including the database schema, the purpose of each query, and instructions on how to set up and run the queries. You can customize it further based on your specific needs and details.



