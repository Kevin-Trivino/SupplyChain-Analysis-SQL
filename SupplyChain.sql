SHOW FIELDS FROM orders from supplychain;

-- standardize column names
ALTER TABLE orders
CHANGE COLUMN OrderNumber order_number VARCHAR(255),
CHANGE COLUMN `Sales Channel` sales_channel VARCHAR(255),
CHANGE COLUMN WarehouseCode warehouse_code VARCHAR(255),
CHANGE COLUMN ProcuredDate procured_date VARCHAR(255),
CHANGE COLUMN OrderDate order_date VARCHAR(255),
CHANGE COLUMN ShipDate ship_date VARCHAR(255),
CHANGE COLUMN DeliveryDate delivery_date VARCHAR(255),
CHANGE COLUMN CurrencyCode currency_code VARCHAR(255),
CHANGE COLUMN _SalesTeamID sales_team_id INT,
CHANGE COLUMN _CustomerID customer_id INT,
CHANGE COLUMN _StoreID store_id INT,
CHANGE COLUMN _ProductID product_id INT,
CHANGE COLUMN `Order Quantity` order_quantity INT,
CHANGE COLUMN `Discount Applied` discount_applied DECIMAL(5, 2),
CHANGE COLUMN `Unit Cost` unit_cost VARCHAR(255),
CHANGE COLUMN `Unit Price` unit_price VARCHAR(255);

-- Update date columns to proper format
UPDATE orders
SET procured_date = STR_TO_DATE(procured_date, '%d/%m/%Y'),
    order_date = STR_TO_DATE(order_date, '%d/%m/%Y'),
    ship_date = STR_TO_DATE(ship_date, '%d/%m/%Y'),
    delivery_date = STR_TO_DATE(delivery_date, '%d/%m/%Y');

ALTER TABLE orders
CHANGE COLUMN procured_date procured_date DATE,
CHANGE COLUMN order_date order_date DATE,
CHANGE COLUMN ship_date ship_date DATE,
CHANGE COLUMN delivery_date delivery_date DATE;

-- Remove dollars symbols and commas
UPDATE orders
SET unit_cost = REPLACE(REPLACE(unit_cost, '$', ''), ',', ''),
    unit_price = REPLACE(REPLACE(unit_price, '$', ''), ',', '');

-- Update column type    
ALTER TABLE orders
CHANGE COLUMN unit_cost unit_cost DECIMAL(10, 2),
CHANGE COLUMN unit_price unit_price DECIMAL(10, 2);


## Data Exploration ## 

## Order Fulfillment ##

-- Order fullfilment time general
SELECT 
    AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
    MIN(DATEDIFF(delivery_date, order_date)) AS min_fulfillment_time,
    MAX(DATEDIFF(delivery_date, order_date)) AS max_fulfillment_time
FROM orders;
-- avg around 20 with a range of 3-38

-- Order fullfilment by warehouse
SELECT 
    warehouse_code,
    AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
    COUNT(order_number) AS total_orders
FROM orders
GROUP BY warehouse_code
ORDER BY avg_fulfillment_time;
-- large disparity in number of orders for some warehouses however it does not affect avg. fulfillment time

-- Avg order fullment time by product
SELECT 
    product_id,
    AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
    MIN(DATEDIFF(delivery_date, order_date)) AS min_fulfillment_time,
    MAX(DATEDIFF(delivery_date, order_date)) AS max_fulfillment_time,
    COUNT(order_number) AS total_orders
FROM orders
GROUP BY product_id
ORDER BY avg_fulfillment_time ASC;
-- some disparity with avg fulfillment ime for each product ranging between 18-22 days


-- Identifying top five products with highest fullment times in each warehouse
-- Identifying warehouses that have lowest fullment times for those products
WITH AvgFulfillmentTimes AS (
    SELECT 
        warehouse_code,
        product_id,
        AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
        ROW_NUMBER() OVER (PARTITION BY warehouse_code ORDER BY AVG(DATEDIFF(delivery_date, order_date)) DESC) AS rn
    FROM orders
    GROUP BY warehouse_code, product_id
),
TopFiveFullfilment AS (
    SELECT 
        warehouse_code AS original_warehouse,
        product_id,
        avg_fulfillment_time
    FROM AvgFulfillmentTimes
    WHERE rn <= 5
),
ShortestFulfillment AS (
    SELECT 
        product_id,
        warehouse_code AS best_warehouse,
        AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time
    FROM orders
    GROUP BY product_id, warehouse_code
)
SELECT 
    t.original_warehouse,
    t.product_id,
    t.avg_fulfillment_time AS original_avg_fulfillment_time,
    s.best_warehouse,
    s.avg_fulfillment_time AS best_avg_fulfillment_time
FROM TopFiveFullfilment t
JOIN ShortestFulfillment s ON t.product_id = s.product_id
WHERE s.avg_fulfillment_time = (
    SELECT MIN(avg_fulfillment_time)
    FROM ShortestFulfillment
    WHERE product_id = t.product_id
)
ORDER BY t.original_warehouse, t.product_id;
-- some warehouses fulfill porducts much faster than other
-- so matched the top five worst products in terms of fulfillment times froom each warehouse
	-- with the warehouse that fulfills that product the fastest


-- overall warehouse perofrmance
SELECT 
    warehouse_code,
    COUNT(order_number) AS total_orders,
    AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
    SUM(order_quantity * unit_price) AS total_sales,
    SUM(order_quantity * unit_cost) AS total_cost,
    SUM(order_quantity * (unit_price - unit_cost)) AS total_profit
FROM orders
GROUP BY warehouse_code
ORDER BY total_profit ASC;
-- nothing unexpected
	-- the warehouses with more orders also have highesr costs and total sales
    -- avg fulfillment time stays the same

-- order size imapct on fullfilment time
SELECT 
    order_size,
    AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
    COUNT(order_number) AS total_orders
FROM (
    SELECT 
        order_number,
        CASE 
            WHEN order_quantity <= 5 THEN 'Small'
            WHEN order_quantity <= 10 THEN 'Medium'
            ELSE 'Large'
        END AS order_size,
        delivery_date,
        order_date
    FROM orders
) AS order_sizes
GROUP BY order_size
ORDER BY avg_fulfillment_time DESC;
-- order size does not appear to have an effect on fulfillment time

-- avg fulfillment times by month
SELECT 
    DATE_FORMAT(order_date, '%m') AS month,
    AVG(DATEDIFF(delivery_date, order_date)) AS avg_fulfillment_time,
    COUNT(order_number) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;
-- time of year does not appear to have an effect as the avg. is 20 for all months



## Customer Analysis

-- Top customers by revenue
SELECT 
    customer_id,
    COUNT(order_number) AS total_orders,
    SUM(order_quantity * unit_price) AS total_revenue
FROM orders
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- Top customers by orders
SELECT 
    customer_id,
    COUNT(order_number) AS total_orders,
    SUM(order_quantity * unit_price) AS total_revenue
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;


-- Top performing products
SELECT 
    product_id,
    SUM(order_quantity) AS total_quantity_sold,
    SUM(order_quantity * unit_price) AS total_sales
FROM orders
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- sales and order quantity for each product by month
SELECT 
    product_id,
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(order_quantity * unit_price) AS total_sales,
    COUNT(order_number) AS total_orders
FROM orders
GROUP BY product_id, month
ORDER BY product_id, month;

-- sales and order quanitity for each product by warehouse
SELECT 
    product_id,
    warehouse_code,
    SUM(order_quantity * unit_price) AS total_sales,
    COUNT(order_number) AS total_orders
FROM orders
GROUP BY warehouse_code, product_id
ORDER BY warehouse_code, product_id DESC;

-- Sales by sales channel
SELECT 
    sales_channel,
    SUM(order_quantity * unit_price) AS total_sales,
    COUNT(order_number) AS total_orders
FROM orders
GROUP BY sales_channel;



