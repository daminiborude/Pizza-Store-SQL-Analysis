create database pizza_store;
use pizza_store;

-- orders
create table orders (
order_id int primary key,
date text,
time TIME
);

-- pizza_types
create table pizza_types (
pizza_type_id varchar(200)primary key,
name varchar(255),
category varchar(100),
Ingredients text
);

-- Pizzas
create table pizza(
pizza_id varchar(200) primary key,
pizza_type_id varchar(200),
size varchar(50),
price decimal,
foreign key(pizza_type_id) references pizza_types(pizza_type_id));

-- order_details
create table order_details(
order_details_id int primary key,
order_id int,
pizza_id varchar(200),
quantity int,
foreign key (pizza_id) references pizza(pizza_id),
foreign key (order_id) references orders(order_id) );

select * from orders;
select * from pizza_types;
select * from pizza;
select * from order_details;


