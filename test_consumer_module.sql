-- Insert required data for testing

-- Insert sellers
INSERT INTO seller_port (port_id, password, location, role) VALUES ('S001', SHA2('sellerpass', 256), 'Seller Location A', 'seller');
INSERT INTO seller_port (port_id, password, location, role) VALUES ('S002', SHA2('sellerpass2', 256), 'Seller Location B', 'seller');

-- Insert products
INSERT INTO products (product_id, seller_id, product_name, quantity, price) VALUES (1, 'S001', 'Product A', 50, 100.00);
INSERT INTO products (product_id, seller_id, product_name, quantity, price) VALUES (2, 'S002', 'Product B', 20, 200.00);

-- Insert consumers
INSERT INTO consumer_port (port_id, password, location, role) VALUES ('C001', 'correct_password', 'Location A', 'consumer');
INSERT INTO consumer_port (port_id, password, location, role) VALUES ('C002', 'password123', 'Location B', 'consumer');

-- Insert orders for tracking test
INSERT INTO orders (order_id, product_id, consumer_port_id, quantity, order_date, order_placed, shipped, out_for_delivery, delivered) 
VALUES (1, 1, 'C001', 5, CURDATE(), TRUE, FALSE, FALSE, FALSE);


-- Test Case 1: Valid Order Placement
-- Assumes product_id = 1 exists with sufficient quantity, and consumer_port_id = 'C001' exists
CALL place_order('C001', 1, 5);
SELECT * FROM orders WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 2: Insufficient Product Quantity
-- Assumes product_id = 1 has less than 1000 quantity available
CALL place_order('C001', 1, 1000);
SELECT * FROM orders WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 3: Non-Existent Consumer
-- Assumes consumer_port_id 'C999' does not exist
CALL place_order('C999', 1, 5);
SELECT * FROM orders WHERE consumer_port_id = 'C999';

-- Test Case 4: Non-Existent Product
-- Assumes product_id = 999 does not exist
CALL place_order('C001', 999, 5);
SELECT * FROM orders WHERE product_id = 999;

-- Test Case 5: Quantity Exactly Equal to Available Stock
-- Assumes product_id = 1 has exactly 5 units left
CALL place_order('C001', 1, 5);
SELECT * FROM products WHERE product_id = 1;


-- Test Case 6: Track Existing Product
-- Assumes order_id = 1 exists
CALL track_product(1);

-- Test Case 7: Track Non-Existent Order
-- Assumes order_id = 999 does not exist
CALL track_product(999);


-- Test Case 8: Retrieve Products with Offset and Limit
CALL get_products(0, 10);

-- Test Case 9: Retrieve Products with Large Offset
CALL get_products(1000, 10);


-- Test Case 10: Retrieve Existing Product
-- Assumes product_id = 1 exists
CALL get_product(1);

-- Test Case 11: Retrieve Non-Existent Product
CALL get_product(999);


-- Test Case 12: Update Existing Consumer Profile
-- Assumes port_id = 'C001' exists
CALL update_consumer_profile('C001', 'New Location');
SELECT * FROM consumer_port WHERE port_id = 'C001';

-- Test Case 13: Update Non-Existent Consumer Profile
CALL update_consumer_profile('C999', 'New Location');
SELECT * FROM consumer_port WHERE port_id = 'C999';


-- Test Case 14: Delete Existing Consumer with Valid Credentials
-- Assumes login_user('C001', 'correct_password', 'consumer') returns TRUE
CALL delete_consumer('C001', 'correct_password', 'consumer');
SELECT * FROM consumer_port WHERE port_id = 'C001';

-- Test Case 15: Delete Consumer with Invalid Credentials
CALL delete_consumer('C001', 'wrong_password', 'consumer');
SELECT * FROM consumer_port WHERE port_id = 'C001';


-- Test Case 16: Change Password with Correct Old Password
-- Assumes login_user('C001', 'correct_password', 'consumer') returns TRUE
CALL change_password('C001', 'correct_password', 'new_password', 'consumer');
SELECT * FROM consumer_port WHERE port_id = 'C001';

-- Test Case 17: Change Password with Incorrect Old Password
CALL change_password('C001', 'wrong_old_password', 'new_password', 'consumer');
SELECT * FROM consumer_port WHERE port_id = 'C001';

-- Test Case 18: Trigger Test - Product Quantity Update
-- Assumes placing an order will decrease product quantity
CALL place_order('C001', 1, 5);
-- Verify by checking product quantity
SELECT quantity FROM products WHERE product_id = 1;


-- Test Case 19: Report Product as Damaged
-- Assumes consumer_port_id = 'C001' and product_id = 1 exist
CALL report_product('C001', 1, 'damaged');
SELECT * FROM reported_products WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 20: Report Product as Wrong
CALL report_product('C001', 1, 'wrong');
SELECT * FROM reported_products WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 21: Report Product with Delay
CALL report_product('C001', 1, 'delay');
SELECT * FROM reported_products WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 22: Report Product as Not Received
CALL report_product('C001', 1, 'not received');
SELECT * FROM reported_products WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 23: Report Product as Missing
CALL report_product('C001', 1, 'missing');
SELECT * FROM reported_products WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 24: Report Product with Invalid Issue Type
-- Should handle gracefully if issue type not in defined cases
CALL report_product('C001', 1, 'invalid_issue');
SELECT * FROM reported_products WHERE consumer_port_id = 'C001' AND product_id = 1;

-- Test Case 25: Search products with product name
-- Should search for project gracefully
-- Insert sample data
INSERT INTO products (seller_id, product_name, quantity, price) 
VALUES
	("S001", 'Gaming Laptop',1500.00, 10),
	("S001", 'Office Laptop',  900.00, 20),
	("S001", 'Wireless Mouse',  25.00, 50),
	("S001", 'Mechanical Keyboard',80.00, 30),
	("S001", 'Smartphone', 700.00, 15),
	("S001", 'Laptop Stand', 40.00, 25),
	("S001", 'Ultrabook',  1200.00, 5),
	("S001", 'Tablet', 300.00, 12),
	("S001", 'Laptop Bag', 60.00, 40),
	("S001", 'Desktop Computer', 1000.00, 8);
    
select * from products;
call search_products("Gam");

-- Test get consumer products 
call get_consumer_orders("C001");



