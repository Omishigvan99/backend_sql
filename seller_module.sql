-- ###################################################################
-- SELLER MODULE 
-- @Akash, Harsh, Abid
-- *******************************************************************

-- procedure to get seller products
delimiter //
create procedure get_seller_products(
	seller_id varchar(50)
)
begin
    declare seller_count int;
    
    select count(*) into seller_count from seller_port where port_id=seller_id;
	
    if seller_count > 0 then
		select * from products as p where p.seller_id = seller_id;
    else
		select "No seller exist";
	end if;
end //
delimiter ;

drop procedure get_seller_products;

-- procedures for adding product
delimiter //
create procedure add_product(
	seller_id varchar(40), 
	product_name varchar(40), 
	quantity int, 
	price decimal(12,2)
)
begin
    declare seller_exists int;
    select count(*) into seller_exists from seller_port sp where sp.port_id=seller_id;
    if seller_exists>0 then
        insert into products(seller_id,product_name,quantity,price)
        values(seller_id, product_name, quantity,price);
        select "Product added successfully" as MESSAGE;
    else
        select "Entered seller id is Invalid" as MESSAGE;
    end if;
end//
delimiter ;

-- procedure to update product details
delimiter //
create procedure update_product(
	product_id int, 
	product_name varchar(40), 
	quantity int, 
	price decimal(12,2)
)
begin
	
    declare product_count int;
    
    select count(*) into product_count from products as p where p.product_id=product_id; 
    
    if product_count > 0 then
		update products 
        set 
			products.product_name=product_name, 
			products.quantity=quantity, 
            products.price=price 
		where products.product_id=product_id;
		select "Product updated successfully" as MESSAGE;
    else
		select "No such product exist, update failed";
	end if;
end//
delimiter ;

-- procedure to remove product from inventory
delimiter //
create procedure remove_product(product_id int)
begin
	declare product_count int;
    
    select count(*) into product_count from products as p where p.product_id=product_id; 
    
    if product_count > 0 then
		delete from products where products.product_id=product_id;
		select "Product deleted successfully" as MESSAGE;
    else
		select "No such product exist, delete failed" as MESSAGE;
	end if;
end //
delimiter ;

delimiter //
create procedure get_seller_orders(seller_id varchar(40))
begin
	declare seller_exists int;
    
    select count(*) into seller_exists from seller_port sp where sp.port_id=seller_id;
    
    if seller_exists > 0 then
        select 
		orders.order_id, 
		orders.product_id, 
		products.product_name,
        products.price,
		orders.consumer_port_id, 
		orders.quantity, 
        (orders.quantity * products.price) as cost,
		orders.order_date,
		orders.order_placed, 
		orders.shipped, 
		orders.out_for_delivery, 
		orders.delivered
    from orders
    join products on orders.product_id=products.product_id
    where products.seller_id=seller_id;
    else
        select "Entered seller id is Invalid" as MESSAGE;
    end if;
end//
delimiter ;

-- procedures to manage products, view orders and generate sales report
-- @Akash
delimiter //
create procedure update_order_status(
	order_id int,
    shipped boolean,
    out_for_delivery boolean,
    delivered boolean
)
begin
	declare order_count int;
    
    select count(*) into order_count from orders where orders.order_id = order_id;
    
    if order_count > 0 then
		update orders
		set shipped = shipped,
			out_for_delivery = out_for_delivery,
			delivered = delivered
		where orders.order_id = order_id;
		select "Order status updated successfully" as message;
	else
		select "No such order exist";
	end if;
end //
delimiter ;

-- =============================
-- Procedure to update 'shipped' status
-- =============================
delimiter //
create procedure update_shipped_status(order_id int, shipped boolean)
begin
    declare order_count int;

    select count(*) into order_count from orders where orders.order_id = order_id;

    if order_count > 0 then
        update orders
        set shipped = shipped
        where orders.order_id = order_id;
        select 'order status updated successfully' as message;
    else
        select 'no such order exists';
    end if;
end //
delimiter ;

-- =============================
-- Procedure to update 'out for delivery' status
-- =============================
delimiter //
create procedure update_out_for_delivery_status(order_id int, out_for_delivery boolean)
begin
    declare order_count int;

    select count(*) into order_count from orders where orders.order_id = order_id;

    if order_count > 0 then
        update orders
        set out_for_delivery = out_for_delivery
        where orders.order_id = order_id;
        select 'order status updated successfully' as message;
    else
        select 'no such order exists';
    end if;
end //
delimiter ;

-- =============================
-- Procedure to update 'delivered' status
-- =============================
delimiter //
create procedure update_delivered_status(order_id int, delivered boolean)
begin
    declare order_count int;

    select count(*) into order_count from orders where orders.order_id = order_id;

    if order_count > 0 then
        update orders
        set delivered = delivered
        where orders.order_id = order_id;
        select 'order status updated successfully' as message;
    else
        select 'no such order exists';
    end if;
end //
delimiter ;

delimiter //
create procedure get_seller_reported_products(seller_id varchar(50))
begin
    declare seller_exists int;
    select count(*) into seller_exists from seller_port sp where sp.port_id=seller_id;
    if seller_exists>0 then
        select 
			r.report_id, 
            r.consumer_port_id, 
            r.product_id,
            p.product_name,
            r.issue_type, 
            r.solution, 
            r.report_date
		from reported_products as r
		join products p on r.product_id = p.product_id
		where p.seller_id = seller_id;
    else
        select "No such seller id exists" as MESSAGE;
    end if;
end //
delimiter ;

delimiter //
create procedure generate_sales_report(
    seller_id varchar(50),
    report_type enum('monthly', 'annual'),
    report_year int,
    report_month int
)
begin

	declare seller bool;
    
    select exists(
		select 1 from seller_port as s where s.port_id = seller_id
    ) into seller;
	
    if not seller then
		signal sqlstate '45000' set message_text= 'Invalid Seller';
	end if;

    if report_type = 'monthly' then
        select sum(p.price * o.quantity) as total_sales, count(o.order_id) as total_orders
        from orders o
        join products p on o.product_id = p.product_id
        where p.seller_id = seller_id
          and year(o.order_date) = report_year
          and month(o.order_date) = report_month;
    else
        select sum(p.price * o.quantity) as total_sales, count(o.order_id) as total_orders
        from orders o
        join products p on o.product_id = p.product_id
        where p.seller_id = seller_id
          and year(o.order_date) = report_year;
    end if;
end //
delimiter ;
drop procedure generate_sales_report;

delimiter //
create trigger update_validate_product
before update on products
for each row
begin
    if new.product_name is null then
        set new.product_name = old.product_name;
    end if;
    
    if new.quantity is null then
        set new.quantity = old.quantity;
    end if;
        
    if new.price is null then
        set new.price = old.price;
    end if;
    
    if new.price < 0 then
        signal sqlstate '45000' set message_text = 'invalid price';
    end if;
    
    if new.quantity < 0 then
        signal sqlstate '45000' set message_text = 'invalid quantity';
    end if;
end //
delimiter ;

delimiter //
create trigger insert_validate_product
before insert on products
for each row
begin
    if new.product_name is null or new.product_name="" then
        signal sqlstate '45000' set message_text = 'invalid product name';
    end if;
    
    if new.quantity is null or new.quantity < 0 then
        signal sqlstate '45000' set message_text = 'invalid quantity';
    end if;
        
    if new.price is null or new.price < 0 then
        signal sqlstate '45000' set message_text = 'invalid price';
    end if;
end //
delimiter ;

-- procedure to update the seller profile
-- @Omkar
delimiter //
create procedure update_seller_profile( port_id varchar(50), new_location varchar(255))
begin
	declare has_seller bool;
	select exists(
		select 1 from seller_port as s where s.port_id=port_id
	) into has_seller;
    
    if has_seller then
		update seller_port  
		set location = new_location  
		where seller_port.port_id = port_id ;
		select "Profile updated successfully";
    else
		select "No such seller found";
	end if;
end//
delimiter ;

delimiter //
create procedure delete_seller(port_id varchar(50), password varchar(255), role varchar(25))
begin
	declare seller_exists bool;
	select exists(
		select 1 from seller_port as s where s.port_id=port_id
	) into seller_exists;
    
    if not seller_exists then
		select "No such profile exists";
	elseif login_user(port_id, password, role) then
		 delete from seller_port as s where s.port_id = port_id;
		 select concat("Deleted user ",port_id);
	else
		select concat("Failed to delete profile, invalid credentials");
	end if;
end //
delimiter ;



