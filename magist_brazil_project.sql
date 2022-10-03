
USE magist;

-- 1. How many orders are there in the dataset? 

SELECT COUNT(order_id)
FROM orders;
    
    
-- 2 Are orders actually delivered?

SELECT 
    order_status, COUNT(order_id)
FROM
    orders
GROUP BY order_status;

-- 3 Is Magist having user growth? 

SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;


-- 4 How many products are there on the products table? 
SELECT 
    COUNT(DISTINCT product_id) AS products_count
FROM
    products;
    
-- And per category

SELECT DISTINCT
    product_category_name, COUNT(product_category_name)
FROM
    products
GROUP BY product_category_name;

-- Which are the categories with the most products? 
    
    SELECT distinct product_category_name, COUNT(product_category_name)
FROM products
GROUP BY product_category_name
ORDER BY COUNT(product_category_name) DESC;

-- with translated names

SELECT 
    product_category_name_translation.product_category_name_english AS product_category,
    COUNT(product_id) AS 'Total Count'
FROM
    products
        JOIN
    product_category_name_translation USING (product_category_name)
GROUP BY products.product_category_name
ORDER BY COUNT(product_id) DESC;

-- 6 How many of those products were present in actual transactions?

SELECT 
    COUNT(DISTINCT product_id)
FROM
    order_items;

-- 7 What’s the price for the most expensive and cheapest products?

SELECT 
    MAX(price), MIN(price)
FROM
    order_items;

    -- 8 What are the highest and lowest payment values? 
    
    SELECT 
    MAX(payment_value) highest_payment, MIN(payment_value) lowest_payment
FROM
    order_payments;
    
   
-- BUSINESS QUESTIONS
-- 1 What categories of tech products does Magist have?

    SELECT 
    *
FROM
    product_category_name_translation;
   
  -- "audio", "computers", "pc_gamer", "security_and_services", "consoles_games", "computers_accessories", "tablets_printing_image", "telephony", "electronics"
   
-- 2 How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?

SELECT 
    pc.product_category_name_english AS 'Category',
    COUNT(oi.order_item_id) AS 'Quantity'
FROM
    products AS p
        JOIN
    order_items AS oi USING (product_id)
        JOIN
    product_category_name_translation AS pc USING (product_category_name)
GROUP BY product_category_name
HAVING product_category_name_english IN ('audio' , 'computers',
    'pc_gamer',
    'security_and_services',
    'consoles_games',
    'computers_accessories',
    'tablets_printing_image',
    'telephony',
    'electronics')
ORDER BY COUNT(oi.order_item_id) DESC;
  
-- 3 What’s the average price of the products being sold?

   SELECT AVG(price) AS average_product_price
   FROM order_items;
   
-- for tech

SELECT 
    pc.product_category_name_english, AVG(price) AS 'AVG Price'
FROM
    order_items
        JOIN
    products USING (product_id)
        JOIN
    product_category_name_translation AS pc USING (product_category_name)
GROUP BY products.product_category_name
HAVING product_category_name_english IN ('audio' , 'computers',
    'pc_gamer',
    'security_and_services',
    'consoles_games',
    'computers_accessories',
    'tablets_printing_image',
    'telephony',
    'electronics')
ORDER BY AVG(price) DESC;

   -- 4 Are expensive tech products popular? hier bin ich
   
  SELECT 
CASE
    WHEN price <= '120.65' THEN 'cheap'
    ELSE 'expensive'
END price_category,
COUNT(order_id), product_category_name_english
FROM order_items
JOIN products p USING (product_id)
JOIN product_category_name_translation pc USING (product_category_name)
GROUP BY price_category, product_category_name_english
HAVING product_category_name_english IN ('audio' , 'computers',
    'pc_gamer',
    'security_and_services',
    'consoles_games',
    'computers_accessories',
    'tablets_printing_image',
    'telephony',
    'electronics')
ORDER BY price_category; 
-- halb so schlau

SELECT 
CASE
    WHEN price <= '120.65' THEN 'cheap'
    ELSE 'expensive'
END price_category,
COUNT(order_id)
FROM order_items
GROUP BY price_category
ORDER BY price_category;

SELECT 
    eng.product_category_name_english AS 'Category',
    COUNT(p.product_id) AS 'Total Items',
    ROUND(AVG(oi.price), 2) 'Average Price'
FROM
    products AS p
        JOIN
    product_category_name_translation AS eng USING (product_category_name)
        JOIN
    order_items AS oi USING (product_id)
WHERE
    product_category_name_english IN ('consoles_games' , 'cool_stuff',
        'electronics',
        'computer accessories',
        'pc_gamer',
        'computers',
        'security_and_services',
        'tablets_printing_image',
        'Telephony')
        AND price > 100
GROUP BY eng.product_category_name_english
ORDER BY product_category_name_english;

-- SELLERS QUESTIONS
-- 1 How many months of data are included in the magist database?

SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;

-- 2 How many sellers are there? 

SELECT COUNT(distinct seller_id)
FROM sellers;

-- How many Tech sellers are there? 
    
    SELECT COUNT(distinct seller_id)
FROM sellers
JOIN order_items USING (seller_id)
JOIN products USING (product_id)
JOIN product_category_name_translation USING (product_category_name)
WHERE product_category_name_english IN ('audio' , 'computers',
    'pc_gamer',
    'security_and_services',
    'consoles_games',
    'computers_accessories',
    'tablets_printing_image',
    'telephony',
    'electronics');
    
    -- PER CATEGORY

SELECT COUNT(distinct seller_id), product_category_name_english
FROM sellers
JOIN order_items USING (seller_id)
JOIN products USING (product_id)
JOIN product_category_name_translation USING (product_category_name)
GROUP BY product_category_name_english
HAVING product_category_name_english IN ('audio' , 'computers',
    'pc_gamer',
    'security_and_services',
    'consoles_games',
    'computers_accessories',
    'tablets_printing_image',
    'telephony',
    'electronics');


-- What percentage of overall sellers are Tech sellers?
-- 477/3095= 15.4%

-- 3 What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?

SELECT 
    SUM(payment_value)
FROM
    order_payments;
    
-- What is the total amount earned by all Tech sellers? HIER WEITER

SELECT 
    COUNT(DISTINCT seller_id), ROUND(SUM(payment_value), 2)
FROM
    order_payments
        JOIN
    order_items USING (seller_id)
        JOIN
    products USING (product_id)
        JOIN
    product_category_name_translation USING (product_category_name)
WHERE product_category_name_english IN ('audio' , 'computers',
    'pc_gamer',
    'security_and_services',
    'consoles_games',
    'computers_accessories',
    'tablets_printing_image',
    'telephony',
    'electronics');

-- 4 Can you work out the average monthly income of all sellers? 
    -- 16008872.139586091/ 3095= 5172.5
    
-- Can you work out the average monthly income of Tech sellers?
    
-- In relation to the delivery time:
-- 1 What’s the average time between the order being placed and the product being delivered?

SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),2)
FROM orders;

-- 2 How many orders are delivered on time vs orders delivered with a delay?
SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),2)
FROM orders o
JOIN order_payments AS op USING (order_id)
        JOIN
    order_items AS os USING (order_id)
        JOIN
    products AS p USING (product_id)
        JOIN
    product_category_name_translation AS pc USING (product_category_name)
WHERE
    product_category_name_english IN ('audio' , 'computers',
        'pc_gamer',
        'security_and_services',
        'consoles_games',
        'computers_accessories',
        'tablets_printing_image',
        'telephony',
        'electronics');


-- 3 Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT 
    CASE
        WHEN
            DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date) >= 0
        THEN
            'delayed'
        ELSE 'Ontime'
    END AS 'duration',
     COUNT('duration') AS amount
FROM
    orders
JOIN order_items USING(order_id)
JOIN products USING(product_id)

WHERE
    product_length_cm > 50
   OR product_weight_g > 4000
GROUP BY duration;

SELECT 
    CASE
        WHEN
            DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date) >= 0
        THEN
            'delayed'
        ELSE 'Ontime'
    END AS 'duration',
     COUNT('duration') AS amount
FROM
    orders
JOIN order_items USING(order_id)
JOIN products USING(product_id)

WHERE
    product_length_cm < 50
   OR product_weight_g < 4000
GROUP BY duration;

-- no pattern

