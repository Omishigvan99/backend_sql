-- creating database 
-- create database import_export_DB;

-- selecting the database
use import_export_DB;

-- drop database
-- drop database import_export_db;

create table consumer_port(
	port_id varchar(50) primary key,
    password varchar(255) not null,
    location varchar(255) not null,
    role varchar(25) not null,
    check (port_id regexp '^[a-zA-Z0-9]+$'),
    check (role = "consumer")
);

create table backup_consumer_port like consumer_port;
    
create table seller_port(
	port_id varchar(50) primary key,
    password varchar(255) not null,
    location varchar(255) not null,
    role varchar(25) not null,
    check (port_id regexp '^[a-zA-Z0-9]+$'),
    check (role = "seller")
);

create table backup_seller_port like seller_port;
    
create table products(
	product_id int primary key auto_increment,
    seller_id varchar(50) not null references seller_port.port_id ,
    product_name varchar(50) not null,
    quantity int not null,
    price decimal(10,2) not null,
    image_url varchar(255),
	check(price > 0)
);

create table backup_products like products;

create table orders(
	order_id int primary key auto_increment,
    product_id varchar(50) not null references products(product_id),
    consumer_port_id varchar(50) not null references consumer_port(port_id),
    quantity int not null,
    order_date date not null,
    order_placed boolean default false not null,
    shipped boolean default false not null,
    out_for_delivery boolean default false not null,
    delivered boolean default false not null
);

create table backup_orders like orders;

create table reported_products(
	report_id int primary key auto_increment,
    consumer_port_id varchar(50) not null references consumer_port(port_id),
    product_id int references products(product_id),
    issue_type enum("damaged","wrong","delay","not received", "missing"),
	solution varchar(75) not null,
    report_date date not null
);

create table backup_reported_products like reported_products;

-- ###################################################################
-- triggers backing up the data;
-- @Omkar
-- *******************************************************************

-- backup triggers for seller_port
delimiter //
create trigger backup_seller_port
after insert
on seller_port
for each row
begin
	insert into backup_seller_port 
    values(
		new.port_id,
        new.password,
        new.location,new.role
	);
end//
delimiter ;

delimiter //
create trigger update_backup_seller_port
after update
on seller_port
for each row
begin
	update backup_seller_port as bsp 
    set bsp.password=new.password, 
		bsp.location=new.location
    where bsp.port_id=new.port_id;
end//
delimiter ;

delimiter //
create trigger delete_backup_seller_port
after delete 
on seller_port
for each row
begin
	delete from backup_seller_port as bsp 
    where bsp.port_id=old.port_id; 
end//
delimiter ;

-- backup triggers for consumer
delimiter //
 create trigger backup_consumer_port
 after insert
 on consumer_port
 for each row
 begin
	insert into backup_consumer_port 
    values(
		new.port_id,new.password,
        new.location,new.role
	);
 end//
delimiter ; 

delimiter //
create trigger update_backup_consumer_port
after update
on consumer_port
for each row
begin
	update backup_consumer_port as bcp 
    set 
		bcp.location= new.location, 
        bcp.password=new.password 
	where bcp.port_id=new.port_id;
end //
delimiter ;

delimiter //
create trigger delete_backup_consumer_port 
after delete
on consumer_port
for each row
begin
	delete from backup_consumer_port as bcp 
    where bcp.port_id=old.port_id;
end//
delimiter ;

-- backup triggers for orders
delimiter //
create trigger backup_orders
after insert on orders
for each row
begin
	insert into backup_orders 
    values(	
		new.order_id, new.product_id, 
		new.consumer_port_id, 
		new.quantity, 
		new.order_date, 
		new.order_placed, 
		new.shipped, 
		new.out_for_delivery, 
		new.delivered
	);
end//
delimiter ; 

delimiter //
create trigger update_backup_orders
after update on orders
for each row
begin
	update backup_orders as bo 
    set 
		bo.product_id=new.product_id, 
        bo.consumer_port_id = new.consumer_port_id, 
        bo.quantity = new.quantity, 
        bo.order_date= new.order_date, 
        bo.order_placed= new.order_placed, 
        bo.shipped = new.shipped, 
        bo.out_for_delivery = new.out_for_delivery, 
        bo.delivered = new.delivered
	where bo.order_id = new.order_id;
end//
delimiter ;

-- backup triggers for reported_products
delimiter //
create trigger backup_reported_products
after insert on reported_products
for each row
begin
	insert into backup_reported_products 
	values(
		new.report_id,
        new.consumer_port_id,
        new.product_id, 
        new.issue_type, 
        new.solution, 
        new.report_date
	);
end//
delimiter ;

delimiter //
create trigger update_backup_reported_products
after update on reported_products
for each row
begin
	update backup_reported_products as brp
    set
		brp.consumer_port_id=new.consumer_port_id, 
        brp.product_id= new.product_id, 
        brp.issue_type= new.issue_type, 
        brp.solution= new.solution, 
        brp.report_date= new.report_date
	where brp.report_id = new.report_id;
end//
delimiter ;

-- backup triggers for products

delimiter //
create trigger backup_products
after insert on products
for each row
begin
	insert into backup_products 
    values(
		new.product_id,
		new.seller_id,
        new.product_name, 
        new.quantity, 
        new.price,
        new.image_url
	);
end//
delimiter ;

delimiter //
create trigger update_backup_products
after update on products
for each row
begin
	update backup_products as bp
    set
		bp.seller_id = new.seller_id,
        bp.product_name = new.product_name, 
        bp.quantity = new.quantity, 
        bp.price = new.price,
        bp.image_url= new.image_url
	where bp.product_id = new.product_id;
end//
delimiter ;

delimiter //
create trigger delete_backup_products
after delete on products
for each row
begin
	delete from backup_products as bp
    where bp.product_id = old.product_id;  
end//
delimiter ;

-- Trigger to delete reported products from backup table when deleted from main table
DELIMITER //
CREATE TRIGGER delete_reported_products_backup
AFTER DELETE ON reported_products
FOR EACH ROW
BEGIN
    DELETE FROM backup_reported_products WHERE backup_reported_products.report_id = OLD.report_id;
END //
DELIMITER ;

-- Trigger to delete orders from backup table when deleted from main table
DELIMITER //
CREATE TRIGGER delete_backup_orders
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    DELETE FROM backup_orders WHERE backup_orders.order_id = OLD.order_id ;
END //
DELIMITER ;