create table pizza(
 pizza_id varchar(50),	
 pizza_type_id varchar(50),
 size varchar (10),
 price numeric (10,2)
 );
 
 select * from pizza;

 create table pizza_type(
 pizza_type_id varchar (50),
 name varchar (50),
 category varchar (50),
 ingredients varchar (500)
 );

select * from pizza_type; 

create table orders (
order_details_id int,
order_id int,
pizza_id varchar (50),
quantity int )
;

select * from orders;

create table orders_1(
order_id int not null,
order_date date not null,
order_time time not null)
;

select * from orders_1;

--Retrive the total no. of orders placed;

select count (order_id) as total_orders from orders_1;

--calculated the total revenue genrated from pizza sales;

select sum(orders .quantity * pizza.price) as total_revenue
from orders 
join 
pizza on pizza.pizza_id = orders.pizza_id;

--identify the highest price pizza

select  pizza_TYPE .NAME , PIZZA.PRICE
FROM PIZZA_TYPE             JOIN PIZZA 
ON PIZZA_TYPE.PIZZA_TYPE_ID=PIZZA.PIZZA_TYPE_ID 
ORDER BY PIZZA	.PRICE DESC LIMIT 1;

--Identify the most common pizza size ordered

select pizza.size, 	count(orders.order_details_id)
 as order_count
from  orders join  pizza
on pizza.pizza_id =	orders.pizza_id
group by pizza.size
order by order_count desc ;

--list the  top 5 most ordered pizza types along with their quantities;
select * from pizza_type;
select * from orders;
select * from orders_1;
select * from pizza;

select pizza_type.name,
sum(orders.quantity) as quantity
from pizza_type join pizza
on pizza_type.pizza_type_id=pizza.pizza_type_id
join orders
on  orders.pizza_id=pizza.pizza_id
group by pizza_type.name order by quantity desc limit 5;

--join the necessary table to find the total quantity of each pizza category ordered..


select pizza_type.category,
sum(orders.quantity) as quantity
from pizza_type join pizza
on pizza_type.pizza_type_id=pizza.pizza_type_id
join orders
on orders.pizza_id=pizza.pizza_id
group by pizza_type.category
order by quantity desc;

--determine the distribution of orders by hour of the day.


SELECT (order_time), count(order_id) as order_count
from orders_1
group by (order_time);

--join the relevent table category wise distribution of pizza.

select category, count(name)
from pizza_type
group by  category;

--group the orders by the date and calculate the avg number of pizza ordered per day.

select round (avg(quantity),0) as avg_pizza_ordered_per_day
from 
(select orders_1.order_date, sum (orders.quantity) as quantity
from orders join orders_1
on orders.order_id=orders_1.order_id 
group by orders_1.order_date) as order_quantity; 

--determine the top 3 most ordered pizza type baed on revenue.

select pizza_type.name,
sum(orders.quantity* pizza.price) as revenue 
from pizza_type join pizza
on pizza.pizza_type_id=pizza_type.pizza_type_id
join orders on orders.pizza_id = pizza.pizza_id
group by pizza_type. name order by revenue desc limit 3;

--calculate the percentage contribution of each pizza type to total revenue.

select pizza_type.category,
sum (orders.quantity*pizza.price)  as revenue
from pizza_type join pizza 
on pizza_type.pizza_type_id=pizza.pizza_type_id
join orders
on orders.pizza_id=pizza.pizza_id
group by pizza_type .category order by revenue desc;

--Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from 
(select orders_1.order_date,
sum (orders.quantity*pizza.price) as revenue
from orders join pizza
on orders.pizza_id=pizza.pizza_id
join orders_1
on orders_1.order_id=orders.order_id
group by orders_1.order_date) as sales ;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category..

select name, revenue,category,rank from 
(select category,name,revenue,rank()
over(partition by category order by revenue desc) as rank
from
(select pizza_type.category,pizza_type.name,
sum ((orders.quantity) * pizza.price) as revenue 
from pizza_type join pizza
on pizza_type .pizza_type_id=pizza.pizza_type_id
join orders on
pizza.pizza_id =orders.pizza_id
group by pizza_type.category,pizza_type.name) as a) as b
where rank<=3;