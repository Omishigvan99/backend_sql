-- Test Case 1: Valid Consumer Registration
CALL register_user('user1', 'pass123', 'pass123', 'NY', 'consumer');
-- Expected Output: "Consumer user1 registered successfully"

-- Test Case 2: Valid Seller Registration
CALL register_user('seller1', 'pass123', 'pass123', 'LA', 'seller');
-- Expected Output: "Seller seller1 registered successfully"

-- Test Case 3: Password Mismatch
CALL register_user('user2', 'pass123', 'pass321', 'NY', 'consumer');
-- Expected Output: "Password did not match"

-- Test Case 4: Invalid Role
CALL register_user('user3', 'pass123', 'pass123', 'NY', 'admin');
-- Expected Output: "Invalid role"

-- Test Case 5: Empty Password
CALL register_user('user4', '', '', 'NY', 'consumer');
-- Expected Output: "Consumer user4 registered successfully" (if empty passwords are allowed)

-- Test Case 6: Null Role
CALL register_user('user5', 'pass123', 'pass123', 'NY', NULL);
-- Expected Output: "Invalid role"


-- Test Case 7: Valid Consumer Login
SELECT login_user('user1', 'pass123', 'consumer');
-- Expected Output: 1 (TRUE)

select * from consumer_port;

-- Test Case 8: Valid Seller Login
SELECT login_user('seller1', 'pass123', 'seller');
-- Expected Output: 1 (TRUE)

-- Test Case 9: Incorrect Password
SELECT login_user('user1', 'wrongpass', 'consumer');
-- Expected Output: 0 (FALSE)

-- Test Case 10: Non-existent User
SELECT login_user('nonexistent', 'pass123', 'consumer');
-- Expected Output: 0 (FALSE)

-- Test Case 11: Invalid Role on Login
SELECT login_user('user1', 'pass123', 'admin');
-- Expected Output: 0 (FALSE)

-- Test Case 12: Null Password on Login
SELECT login_user('user1', NULL, 'consumer');
-- Expected Output: 0 (FALSE)

-- Test Case 13: SQL Injection Attempt
SELECT login_user('user1', "' OR '1'='1", 'consumer');
-- Expected Output: 0 (FALSE)

-- Test Case 14: Autheticating the user
CALL authenticate_user('user1','pass123','consumer');

CALL authenticate_user("seller1","pass123","seller");
-- Expected Output: users data

-- Insert test data
INSERT INTO consumer_port (port_id, password, location, role) VALUES 
('consumer1', 'oldpassword', 'Mumbai', 'consumer');

INSERT INTO seller_port (port_id, password, location, role) VALUES 
('seller1', 'oldpassword', 'Delhi', 'seller');

-- Test Case 15: Valid password change for a consumer
CALL change_password('consumer1', 'oldpassword', 'newpassword', 'consumer');

-- Test Case 16: Valid password change for a seller
CALL change_password('seller1', 'oldpassword', 'newpassword', 'seller');

-- Test Case 17: Invalid old password attempt
CALL change_password('consumer1', 'wrongpassword', 'newpassword', 'consumer');

-- Test Case 18: Non-existent user attempt
CALL change_password('nonexistent', 'oldpassword', 'newpassword', 'consumer');

-- Test Case 19: Role mismatch (trying to change seller password as a consumer)
CALL change_password('seller1', 'oldpassword', 'newpassword', 'consumer');

-- Verify password changes
SELECT port_id, password FROM consumer_port WHERE port_id = 'consumer1';
SELECT port_id, password FROM seller_port WHERE port_id = 'seller1';
