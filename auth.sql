-- ###################################################################
-- LOGIN AND REGISTRATION MODULE;
-- @Somnath
-- *******************************************************************
DELIMITER //
CREATE PROCEDURE register_user(
	port_id VARCHAR(50),
	pass VARCHAR(255),
	c_pass VARCHAR(255),
	location VARCHAR(255),
	role VARCHAR(25)
)
BEGIN
	-- Check if passwords match
	IF pass = c_pass THEN
		IF role = "consumer" THEN
			INSERT INTO consumer_port (port_id, password, location, role)
			VALUES (port_id, c_pass, location, role);
			SELECT port_id AS port_id;
		ELSEIF role = "seller" THEN
			INSERT INTO seller_port (port_id, password, location, role)
			VALUES (port_id, c_pass, location, role);
			SELECT port_id AS port_id;
		ELSE
			SELECT "Invalid role" AS message;
		END IF;
	ELSE
		SELECT "Password did not match" AS message;
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION login_user(
	port_id VARCHAR(50),
	pass VARCHAR(255),
	role VARCHAR(25)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	DECLARE store_pass CHAR(64);
	DECLARE hash_password CHAR(64);
    
	-- Validate role
	IF role = "consumer" THEN
		SELECT password INTO store_pass FROM consumer_port as c WHERE c.port_id = port_id;
	ELSEIF role = "seller" THEN
		SELECT password INTO store_pass FROM seller_port as s WHERE s.port_id = port_id;
	ELSE
		RETURN FALSE; -- Invalid role
	END IF;
    
	-- If no password is found, return FALSE
	IF store_pass IS NULL THEN
		RETURN FALSE;
	END IF;
    
	-- Hash input password
	SET hash_password = SHA2(pass, 256);
	-- Compare stored password with hashed input
	IF store_pass = hash_password THEN
		RETURN TRUE; -- Success
	ELSE
		RETURN FALSE; -- Failure
	END IF;
END//
DELIMITER ;

-- @Omkar

delimiter //

create procedure authenticate_user(port_id varchar(50), password varchar(255), role varchar(25))
begin
	declare profile_exists bool;
    
    if role = "consumer" then
		select exists(
		select 1 from consumer_port as c where c.port_id=port_id
		) into profile_exists;
	end if;
    
    if role = "seller" then
		select exists(
			select 1 from seller_port as s where s.port_id=port_id
		) into profile_exists;
	end if;
    
    if not profile_exists then
		select "No such profile exists";
    elseif login_user(port_id, password, role) then
		if role= "consumer" then
			select c.port_id,c.location,c.role from consumer_port as c where c.port_id=port_id;
        end if;
        if role = "seller" then
			select s.port_id,s.location,s.role from seller_port as s where s.port_id=port_id;
        end if;
    else
		select "Authentication failed, invalid credentials";
	end if;
end//
delimiter ;

delimiter //
create procedure change_password(port_id varchar(50), old_pass varchar(255), new_pass varchar(255), role varchar(25))
begin

	declare profile_exists bool;
    
    if role = "consumer" then
		select exists(
			select 1 from consumer_port as c where c.port_id=port_id
		) into profile_exists;
	end if;
    
    if role = "seller" then
		select exists(
		select 1 from seller_port as s where s.port_id=port_id
		) into profile_exists;
	end if;
    
    if not profile_exists then
		select "No such profile exists";
    elseif login_user(port_id, old_pass, role) then
		if role= "consumer" then
			update consumer_port set password= sha2(new_pass,256) where consumer_port.port_id=port_id;
        end if;
        if role = "seller" then
			update seller_port set password = sha2(new_pass,256) where seller_port.port_id=port_id;
        end if;
        select concat(role," password changed successfully for id ", port_id);
    else
		select "Authentication failed, password change unsuccessful";
	end if;
end //
delimiter ;

drop procedure change_password;


-- ###################################################################
-- triggers for athentication;
-- @Omkar
-- *******************************************************************

delimiter //
 create trigger hash_password_consumer
 before insert
 on consumer_port
 for each row
 begin
	set new.password = sha2(new.password, 256);
 end//
delimiter ; 

delimiter //
 create trigger hash_password_seller
 before insert
 on seller_port
 for each row
 begin
	set new.password = sha2(new.password, 256);
 end//
delimiter ; 

