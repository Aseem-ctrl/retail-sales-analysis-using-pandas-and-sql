CREATE DATABASE orders_db;
USE orders_db;

SHOW TABLES;

SELECT * FROM df_orders;

DESCRIBE df_orders;

DROP TABLE df_orders;

#saving storage spaces by changing the datatypes in pandas df.to_sql("df_orders",con=engine,if_exists="replace",index=False) "replace" changing with "append" 

CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

SELECT * FROM df_orders;

DESCRIBE df_orders;


#top 10 highest revenue generating products
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
LIMIT 10;






#top 5 highest selling products in each region
with cte as (
    select region,product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rownumber
from cte) A
where rownumber <= 5;




#month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as (
    select year(order_date) as order_year , month(order_date) as order_month, sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
#order by year(order_date),month(order_date)
)
select order_month
, sum(case when order_year=2022 then sales else 0 END) as sales_2022
, sum(case when order_year=2023 then sales else 0 END) as sales_2023
from cte
group by order_month
order by order_month


#for each category which month had highest sales
with cte as (
    select category, DATE_FORMAT(order_date, '%Y%m') as order_year_month 
, sum(sale_price) as sales
from df_orders
group by category, DATE_FORMAT(order_date, '%Y%m')
#order by category, DATE_FORMAT(order_date, '%Y%m')
)
select * from (
select *
,row_number() over(partition by category order by sales desc) as rownumber
from cte) A
where rownumber=1;


#which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
    select sub_category, year(order_date) as order_year , sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
#order by year(order_date),month(order_date)
)
, cte2 as (
select sub_category 
, sum(case when order_year=2022 then sales else 0 END) as sales_2022
, sum(case when order_year=2023 then sales else 0 END) as sales_2023
from cte
group by sub_category 
#order by order_month
)
select *
, (sales_2023 - sales_2022)*100/sales_2022
from cte2
order by (sales_2023 - sales_2022)*100/sales_2022 desc
LIMIT 5;