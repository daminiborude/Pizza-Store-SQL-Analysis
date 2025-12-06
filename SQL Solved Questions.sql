use pizza_store;

-- 1. Retrieve the total number of orders placed.
SELECT COUNT(*) AS total_orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id;

-- 3. Identify the highest-priced pizza.
SELECT 
    p.pizza_id, 
    pt.name, 
    p.price
FROM pizza p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT 
    p.size, 
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name,
    SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 5;

-- 6. Find the total quantity of each pizza category ordered.
SELECT 
    pt.category, 
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY HOUR(time)
ORDER BY order_hour;

-- 8. Find the category-wise distribution of pizzas (count of pizza types per category).
SELECT 
    category,
    COUNT(*) AS number_of_pizza_types
FROM pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    date,
    AVG(total_pizzas) OVER () AS avg_pizzas_per_day
FROM (
    SELECT 
        o.date,
        SUM(od.quantity) AS total_pizzas
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date
) AS daily_pizzas
LIMIT 1;

-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue,
    ROUND((SUM(od.quantity * p.price) / 
          (SELECT SUM(od.quantity * p.price) 
           FROM order_details od 
           JOIN pizza p ON od.pizza_id = p.pizza_id)) * 100, 2) AS percentage
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY percentage DESC;

-- 12. Analyze the cumulative revenue generated over time.
SELECT 
    date,
    SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM (
    SELECT 
        o.date,
        SUM(od.quantity * p.price) AS revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizza p ON od.pizza_id = p.pizza_id
    GROUP BY o.date
) AS daily_revenue
ORDER BY date;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    category, 
    name, 
    revenue
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
    FROM order_details od
    JOIN pizza p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked
WHERE rnk <= 3
ORDER BY category, revenue DESC;

-- 14. Find orders where multiple pizzas were ordered but all pizzas are from the same category.
SELECT 
    o.order_id
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY o.order_id
HAVING COUNT(DISTINCT pt.category) = 1
   AND SUM(od.quantity) > 1;

-- 15. Find the ingredient that contributes the most to revenue.
SELECT 
    ingredient,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM pizza_types pt
JOIN pizza p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
CROSS JOIN JSON_TABLE(
    CONCAT('["', REPLACE(pt.Ingredients, ',', '","'), '"]'),
    '$[*]' COLUMNS (ingredient VARCHAR(100) PATH '$')
) AS jt
GROUP BY ingredient
ORDER BY total_revenue DESC
LIMIT 1;
