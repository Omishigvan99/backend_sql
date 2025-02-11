-- SQL Test Script for Validating Database Schema and Triggers

-- 1. Test Insert into consumer_port
INSERT INTO consumer_port (port_id, password, location, role)
VALUES ('consumer01', 'pass123', 'New York', 'consumer');

-- Verify insertion
SELECT * FROM consumer_port WHERE port_id = 'consumer01';

-- Verify backup trigger
SELECT * FROM backup_consumer_port WHERE port_id = 'consumer01';

-- 2. Test Update on consumer_port
UPDATE consumer_port
SET location = 'Los Angeles', password = 'newpass123'
WHERE port_id = 'consumer01';

-- Verify update
SELECT * FROM consumer_port WHERE port_id = 'consumer01';

-- Verify backup update trigger
SELECT * FROM backup_consumer_port WHERE port_id = 'consumer01';

-- 3. Test Delete from consumer_port
DELETE FROM consumer_port WHERE port_id = 'consumer01';

-- Verify deletion
SELECT * FROM consumer_port WHERE port_id = 'consumer01';

-- Verify backup delete trigger
SELECT * FROM backup_consumer_port WHERE port_id = 'consumer01';

-- 4. Test Insert into seller_port
INSERT INTO seller_port (port_id, password, location, role)
VALUES ('seller01', 'sellerpass', 'San Francisco', 'seller');

-- Verify insertion
SELECT * FROM seller_port WHERE port_id = 'seller01';

-- Verify backup trigger
SELECT * FROM backup_seller_port WHERE port_id = 'seller01';

-- 5. Test Update on seller_port
UPDATE seller_port
SET location = 'Seattle', password = 'newSellerPass'
WHERE port_id = 'seller01';

-- Verify update
SELECT * FROM seller_port WHERE port_id = 'seller01';

-- Verify backup update trigger
SELECT * FROM backup_seller_port WHERE port_id = 'seller01';

-- 6. Test Delete from seller_port
DELETE FROM seller_port WHERE port_id = 'seller01';

-- Verify deletion
SELECT * FROM seller_port WHERE port_id = 'seller01';

-- Verify backup delete trigger
SELECT * FROM backup_seller_port WHERE port_id = 'seller01';

-- 7. Test Insert into products
INSERT INTO products (seller_id, product_name, quantity, price)
VALUES ('seller01', 'Laptop', 10, 999.99);

-- Verify insertion
SELECT * FROM products WHERE product_name = 'Laptop';

-- Verify backup trigger
SELECT * FROM backup_products WHERE product_name = 'Laptop';

-- 8. Test Update on products
UPDATE products
SET product_name = 'Gaming Laptop', quantity = 5, price = 1299.99
WHERE product_id = 1;

-- Verify update
SELECT * FROM products WHERE product_name = 'Gaming Laptop';

-- Verify backup update trigger
SELECT * FROM backup_products WHERE product_name = 'Gaming Laptop';

-- 9. Test Delete from products
DELETE FROM products WHERE product_id = 1;

-- Verify deletion
SELECT * FROM products WHERE product_name = 'Gaming Laptop';

-- Verify backup delete trigger
SELECT * FROM backup_products WHERE product_name = 'Gaming Laptop';

-- 10. Test Insert into orders
INSERT INTO orders (product_id, consumer_port_id, quantity, order_date, order_placed)
VALUES (1, 'consumer01', 2, '2024-02-01', TRUE);

-- Verify insertion
SELECT * FROM orders WHERE product_id = 1 AND consumer_port_id = 'consumer01';

-- Verify backup trigger
SELECT * FROM backup_orders WHERE product_id = 1 AND consumer_port_id = 'consumer01';

-- 11. Test Update on orders
UPDATE orders
SET quantity = 3, shipped = TRUE
WHERE order_id=1;

-- Verify update
SELECT * FROM orders WHERE order_id=1;

-- Verify backup update trigger
SELECT * FROM backup_orders WHERE order_id=1;

-- 12. Test Delete from orders
DELETE FROM orders WHERE order_id=1;

-- Verify deletion
SELECT * FROM orders WHERE product_id = 1 AND consumer_port_id = 'consumer01';

-- Verify backup delete trigger
SELECT * FROM backup_orders WHERE product_id = 1 AND consumer_port_id = 'consumer01';

-- 13. Test Insert into reported_products
INSERT INTO reported_products (consumer_port_id, product_id, issue_type, solution, report_date)
VALUES ('consumer01', 1, 'damaged', 'Refund issued', '2024-02-02');

-- Verify insertion
SELECT * FROM reported_products WHERE report_id=1;

-- Verify backup trigger
SELECT * FROM backup_reported_products WHERE report_id=1;

-- 14. Test Update on reported_products
UPDATE reported_products
SET issue_type = 'wrong', solution = 'Replacement sent'
WHERE report_id=1;

-- Verify update
SELECT * FROM reported_products WHERE report_id=1;

-- Verify backup update trigger
SELECT * FROM backup_reported_products WHERE report_id=1;

-- 15. Test Delete from reported_products
DELETE FROM reported_products WHERE report_id=1;

-- Verify deletion
SELECT * FROM reported_products WHERE report_id=1;

-- Verify backup delete trigger
SELECT * FROM backup_reported_products WHERE report_id=1;

-- 16. Truncate All Tables
TRUNCATE TABLE reported_products;
TRUNCATE TABLE backup_reported_products;
TRUNCATE TABLE orders;
TRUNCATE TABLE backup_orders;
TRUNCATE TABLE products;
TRUNCATE TABLE backup_products;
TRUNCATE TABLE seller_port;
TRUNCATE TABLE backup_seller_port;
TRUNCATE TABLE consumer_port;
TRUNCATE TABLE backup_consumer_port;

-- 17. Drop All Triggers
DROP TRIGGER IF EXISTS backup_seller_port;
DROP TRIGGER IF EXISTS update_backup_seller_port;
DROP TRIGGER IF EXISTS delete_backup_seller_port;
DROP TRIGGER IF EXISTS backup_consumer_port;
DROP TRIGGER IF EXISTS update_backup_consumer_port;
DROP TRIGGER IF EXISTS delete_backup_consumer_port;
DROP TRIGGER IF EXISTS backup_orders;
DROP TRIGGER IF EXISTS update_backup_orders;
DROP TRIGGER IF EXISTS backup_reported_products;
DROP TRIGGER IF EXISTS update_backup_reported_products;
DROP TRIGGER IF EXISTS backup_products;
DROP TRIGGER IF EXISTS update_backup_products;
DROP TRIGGER IF EXISTS delete_backup_products;

-- 18. Drop All Tables
DROP TABLE IF EXISTS reported_products;
DROP TABLE IF EXISTS backup_reported_products;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS backup_orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS backup_products;
DROP TABLE IF EXISTS seller_port;
DROP TABLE IF EXISTS backup_seller_port;
DROP TABLE IF EXISTS consumer_port;
DROP TABLE IF EXISTS backup_consumer_port;
