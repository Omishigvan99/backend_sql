-- procedure to place the order
-- @ Omkar
delimiter //
create procedure place_order(consumer_port_id varchar(255), product_id int ,quantity int)
begin
    declare product_quantity int;
    declare curr_date date;
    declare consumer_count int;
    
    select products.quantity into product_quantity from products where products.product_id = product_id;
    
    select COUNT(port_id) into consumer_count from consumer_port where consumer_port.port_id=consumer_port_id;
    
    if quantity <= product_quantity and consumer_count > 0 then
		set curr_date = curdate();
		insert into orders (product_id, consumer_port_id, quantity, order_date, order_placed, shipped, out_for_delivery, delivered) 
        values(product_id, consumer_port_id, quantity, curr_date, true, false, false, false);
        select "placed order successfully";
    else
		select "failed to place order";
    end if;
end//
delimiter ;

-- procedure to track
-- @Omkar
delimiter //
create procedure track_product(order_id int)
begin

	declare order_count int;
    
    select count(*) into order_count from orders where orders.order_id = order_id;
	
    if order_count  > 0 then    
		select 
			order_id, 
			orders.product_id, 
			product_name, 
			order_placed, 
			shipped, 
			out_for_delivery, 
			delivered 
		from orders join products on 
		orders.product_id=products.product_id 
		where orders.order_id=order_id;
	else
		select "No such order exists";
    end if;
end//
delimiter ;

-- procedure to return list of products
-- @ Omkar
delimiter //
create procedure get_products(off int, lim int)
begin
	select * from products limit lim offset off;
end//
delimiter ;

-- procedure to search products 
-- @ Omkar

delimiter //
create procedure search_products(product_name varchar(50))
begin
	select 
		p.product_id, 
        p.seller_id,
		p.product_name, 
		p.price, 
		p.quantity
	from 
		products as p
	where 
		p.product_name like concat("%",product_name,"%") ;
end //
delimiter ;
drop procedure search_products;

-- procedure to get product
-- @Omkar
delimiter //
create procedure get_product(product_id int)
begin
	select * from products where products.product_id=product_id;
end//
delimiter ; 

delimiter //

-- procedure to report products
create procedure report_product(
    in consumer_port_id varchar(50), 
    in product_id int, 
    in issue_type varchar(50)
)
begin
    declare consumer_exists boolean;
    declare product_exists boolean;
    declare valid_issue boolean;
    declare store_solution varchar(75);

    -- validate issue type
    set valid_issue = issue_type in ('damaged', 'wrong', 'delay', 'not received', 'missing');

    -- check if consumer exists
    select exists(
        select 1 from consumer_port where port_id = consumer_port_id
    ) into consumer_exists;

    -- check if product exists
    select exists(
        select 1 from products where product_id = product_id
    ) into product_exists;

    -- reporting logic
    if not consumer_exists then
        select 'no such consumer exists' as message;
    elseif not valid_issue then
        select 'no such issue type exists' as message;
    elseif not product_exists then
        select 'no such product exists' as message;
    else
        case issue_type
			when "damaged" then
				set store_solution="replacement";
			when "wrong" then
				set store_solution="replacement/refund";
			when "delay" then
				set store_solution="compensation";
			when "not received" then
				set store_solution="refund";
			when "missing" then
				set store_solution="resend/refund";
		end case;
        
		insert into reported_products (
            consumer_port_id, 
            product_id, 
            issue_type, 
            solution, 
            report_date
        ) values (
            consumer_port_id, 
            product_id, 
            issue_type, 
            store_solution, 
            curdate()
        );
        
        select concat('reported product for ', issue_type) as message;
    end if;
end //

delimiter ;

-- procedure to update consumer profile
-- @Lobhan

delimiter //
create procedure update_consumer_profile(port_id VARCHAR(50), new_location VARCHAR(255))
begin
	declare consumer_count int;
    select count(*) into consumer_count from consumer_port as c where c.port_id=port_id;
    
    if consumer_count > 0 then
		update consumer_port  
		set location = new_location  
		where consumer_port.port_id = port_id ;
		select "Profile updated successfully";
    else
		select "Failed to update consumer";
	end if;
    
end //
delimiter ;

delimiter //
create procedure delete_consumer(port_id varchar(50), password varchar(255), role varchar(25))
begin
	if login_user(port_id, password, role) then
		 delete from consumer_port as c where c.port_id = port_id;
		 select concat("Deleted user ",port_id);
	else
		select concat("Failed to delete profile, invalid credentials");
	end if;
end //
delimiter ;

-- Trigger for updating the quantity after placing orders
-- @Omkar
DELIMITER //
create trigger update_product_quantity
after insert on orders
for each row
begin
    update products
    set quantity = quantity - new.quantity
    where product_id = new.product_id;
end //
DELIMITER ;