-- Drop existing procedures
DROP PROCEDURE IF EXISTS add_product;
DROP PROCEDURE IF EXISTS get_seller_products;
DROP PROCEDURE IF EXISTS update_product;
DROP PROCEDURE IF EXISTS remove_product;
DROP PROCEDURE IF EXISTS view_orders;
DROP PROCEDURE IF EXISTS update_order_status;
DROP PROCEDURE IF EXISTS view_reported_products;
DROP PROCEDURE IF EXISTS resolve_issue;
DROP PROCEDURE IF EXISTS generate_sales_report;

-- Drop existing triggers
DROP TRIGGER IF EXISTS validate_product;

-- Insert test sellers
INSERT INTO seller_port (port_id, password, location, role) VALUES 
('seller1', 'pass123', 'New York', 'seller'), 
('seller2', 'pass456', 'Los Angeles', 'seller'),
('SELLER3', 'pass789', 'San Francisco', 'seller'); -- Edge case: Uppercase ID

-- Insert test consumers
INSERT INTO consumer_port (port_id, password, location, role) VALUES 
('consumer1', 'pass789', 'Chicago', 'consumer'), 
('consumer2', 'pass012', 'Houston', 'consumer'),
('CONSUMER3', 'pass345', 'Boston', 'consumer'); -- Edge case: Uppercase ID

-- Insert test products
CALL add_product('seller1', 'Laptop Pro', 10, 1200.00); -- Expected: "Product added successfully"
CALL add_product('seller2', 'Smartphone X', 15, 800.00); -- Expected: "Product added successfully"
CALL add_product('invalid_seller', 'Tablet Z', 5, 300.00); -- Expected: "Entered seller id is Invalid"
CALL add_product('seller1', '', 5, 500.00); -- Edge case: Empty product name, Expected: Validation error
CALL add_product('seller1', 'Laptop Mini', -5, 600.00); -- Edge case: Negative quantity, Expected: Validation error
CALL add_product('seller1', 'Laptop Mini', 5, -600.00); -- Edge case: Negative price, Expected: Validation error

-- View seller products
CALL get_seller_products('seller1', 0, 10); -- Expected: List of products by 'seller1'
CALL get_seller_products('invalid_seller', 0, 10); -- Expected: "No seller exist"
CALL get_seller_products('seller1', -5, 10); -- Edge case: Negative offset, Expected: SQL error
CALL get_seller_products('seller1', 0, 0); -- Edge case: Zero limit, Expected: No products returned

-- Update product details
CALL update_product(1, 'Laptop Pro Max', 8, 1300.00); -- Expected: "Product updated successfully"
CALL update_product(999, 'Non-Existent Product', 0, 0.00); -- Expected: "No such product exist, update failed"
CALL update_product(2, NULL, 10, 900.00); -- Edge case: name was skipped and old value is used others which are not null are updated 
CALL update_product(2, 'Smartphone X Pro', -1, 900.00); -- Edge case: Negative quantity, Expected: Trigger validation

-- Remove product
CALL remove_product(1); -- Expected: "Product deleted successfully"
CALL remove_product(999); -- Expected: "No such product exist, delete failed"
CALL remove_product(NULL); -- Edge case: Null product ID, Expected: SQL error

-- Insert test orders
INSERT INTO orders (product_id, consumer_port_id, quantity, order_date, order_placed) VALUES 
(2, 'consumer1', 2, '2024-12-01', TRUE),
(2, 'CONSUMER3', 1, '2024-12-05', TRUE); -- Edge case: Uppercase consumer ID

-- View orders for a seller
CALL view_orders('seller2'); -- Expected: List of orders for 'seller2'
CALL view_orders('invalid_seller'); -- Expected: "Entered seller id is Invalid"
CALL view_orders(NULL); -- Edge case: Null seller ID, Expected: SQL error

-- Update order status
-- =============================
-- Insert Test Data
-- =============================

insert into orders (product_id, consumer_port_id, quantity, order_date, order_placed, shipped, out_for_delivery, delivered) 
values 
(1, 'consumer1', 2, '2025-02-11', true, false, false, false),
(2, 'consumer2', 1, '2025-02-11', true, true, false, false);

select * from orders;

-- =============================
-- Test Cases for update_shipped_status
-- =============================

-- Test Case 1: Valid order ID, set shipped to true
call update_shipped_status(1, true);

-- Test Case 2: Valid order ID, set shipped to false
call update_shipped_status(2, false);

-- Test Case 3: Invalid order ID (non-existent order)
call update_shipped_status(999, true);

-- Verify updates
select order_id, shipped from orders;

-- =============================
-- Test Cases for update_out_for_delivery_status
-- =============================

-- Test Case 4: Valid order ID, set out_for_delivery to true
call update_out_for_delivery_status(1, true);

-- Test Case 5: Valid order ID, set out_for_delivery to false
call update_out_for_delivery_status(2, false);

-- Test Case 6: Invalid order ID
call update_out_for_delivery_status(999, true);

-- Verify updates
select order_id, out_for_delivery from orders;

-- =============================
-- Test Cases for update_delivered_status
-- =============================

-- Test Case 7: Valid order ID, set delivered to true
call update_delivered_status(1, true);

-- Test Case 8: Valid order ID, set delivered to false
call update_delivered_status(2, false);

-- Test Case 9: Invalid order ID
call update_delivered_status(999, true);

-- Verify updates
select order_id, delivered from orders;


-- Reported products
INSERT INTO reported_products (consumer_port_id, product_id, issue_type, solution, report_date) VALUES 
('consumer1', 2, 'damaged', '', '2024-12-02'),
('consumer2', 2, 'missing', '', '2024-12-03'),
('CONSUMER3', 2, 'wrong', '', '2024-12-04'); -- Edge case: Uppercase consumer ID

-- View reported products
CALL view_reported_products('seller2',0,10); -- Expected: List of reported products for 'seller2'
CALL view_reported_products('invalid_seller',0,10); -- Expected: "Entered seller id is Invalid"
CALL view_reported_products(NULL,0,10); -- Edge case: Null seller ID, Expected: SQL error

-- Generate sales report
CALL generate_sales_report('seller2', 'monthly', 2024, 12); -- Expected: Monthly sales data
CALL generate_sales_report('seller2', 'annual', 2024, NULL); -- Expected: Annual sales data
CALL generate_sales_report(NULL, 'monthly', 2024, 12); -- Edge case: Null seller ID, Expected: SQL error

-- Insert test data
INSERT INTO seller_port (port_id, password, location, role) VALUES 
('seller1', 'password123', 'Delhi', 'seller'),
('seller2', 'securepass', 'Mumbai', 'seller');

-- =============================
-- Test Cases for update_seller_profile
-- =============================

-- Test Case 1: Valid profile update
CALL update_seller_profile('seller1', 'Bangalore');

-- Test Case 2: Update non-existent seller profile
CALL update_seller_profile('nonexistent', 'Chennai');

-- Verify the updates
SELECT port_id, location FROM seller_port WHERE port_id = 'seller1';


-- =============================
-- Test Cases for delete_seller
-- =============================

-- Test Case 3: Valid deletion of a seller profile
CALL delete_seller('seller2', 'securepass', 'seller');

-- Test Case 4: Attempt to delete with incorrect password
CALL delete_seller('seller1', 'wrongpassword', 'seller');

-- Test Case 5: Attempt to delete a non-existent seller
CALL delete_seller('nonexistent', 'password123', 'seller');

-- Verify if deletion was successful
SELECT * FROM seller_port WHERE port_id = 'seller2';
SELECT * FROM seller_port WHERE port_id = 'seller1';

