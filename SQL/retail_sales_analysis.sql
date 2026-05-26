

-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p1;

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transactions_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );



--- DATA EXPLORATION

--- FINDING TOTAL ROWS
SELECT * FROM retail_sales
--- total rows 2000


--- finding Unique customers
SELECT count(distinct customer_id) from retail_sales	
--- 155 UNIQUE customers


---finding all UNIQUE product categories
SELECT distinct retail_sales.category from retail_sales
--- ThreE unique categories are Electronics ,Clothing ,Beauty


--- finding null values from data 
SELECT * from	retail_sales
	WHERE	
		retail_sales.transactions_id is  NULL
		OR
		retail_sales.sale_date is NULL
		or
		retail_sales.sale_time is null
		OR
		retail_sales.customer_id is null
		or
		retail_sales.gender is null
		or
		retail_sales.age is null
		or 
		retail_sales.category is null
		or
		retail_sales.quantity is NULL
		or 
		retail_sales.price_per_unit is null
		or 
		retail_sales.cogs is null
		or
		retail_sales.total_sale is null

--- Total rows with null values = 13


--- Deleting rows with null values from data

DELETE from retail_sales
where
		retail_sales.transactions_id is  NULL
		OR
		retail_sales.sale_date is NULL
		or
		retail_sales.sale_time is null
		OR
		retail_sales.customer_id is null
		or
		retail_sales.gender is null
		or
		retail_sales.age is null
		or 
		retail_sales.category is null
		or
		retail_sales.quantity is NULL
		or 
		retail_sales.price_per_unit is null
		or 
		retail_sales.cogs is null
		or
		retail_sales.total_sale is null
		
--- Total rows left = 1987

--- Data Analysis

--- Q1] Write a SQL query to retrieve all columns for sales made on 2022-11-05

select * 
from retail_sales
where retail_sales.sale_date = '2022-11-05'

--- Q2] Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

select * from retail_sales
where category = 'clothing'
and
quantity = 4
and 
to_char(retail_sales.sale_date,'month') = 'november'
and 
to_char(retail_sales.sale_date,'YYYY') = '2022'

--- Q3] Write a SQL query to calculate the total sales (total_sale) for each category.

select category,
sum(retail_sales.total_sale) as Net_sale
from retail_sales
group by category

--- 4] Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category

select round(avg(age)) as avg_age 
from retail_sales
where retail_sales.category = 'Beauty'

--- Average age of customers who purchased items from the 'Beauty' category = 40 

--- Q5] Write a SQL query to find all transactions where the total_sale is greater than 1000

select * 
from retail_sales
where total_sale >= 1000

--- Total transactions ere the total_sale is greater than 1000 are 402

--- Q6] Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.: 

select category, 
gender,
count(*) as total_transaction
from retail_sales
group by 1,2
order by 1


--- Q7] Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
select * 
from 
(SELECT
		extract(month from sale_Date) as months,
		extract(year from sale_Date) as years ,
		avg(total_sale)  as avg_Sale,
		Rank()  OVER(partition by extract(year from sale_Date)  order by avg(total_sale) desc  )  as rnk 
from retail_sales
group by 1,2) as t1

where rnk = 1


--- Q8] **Write a SQL query to find the top 5 customers based on the highest total sales **:
select customer_id,
sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by total_sales desc limit 5

--- Q9] Write a SQL query to find the number of unique customers who purchased items from each category.:

select category,  
count(distinct retail_sales.customer_id) as unique_customer

from retail_sales
group by 1

--- count of customers who have purchased from all three categories
select count(*) as loyal_customers
FROM
	(select customer_id
		from retail_sales
		where category in ('Beauty','Clothing','Electronics')
		group by customer_id
		having count(distinct category) = 3) t1



--- q10] Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):


with hourly_sales as 
(SELECT *,
CASE
	when extract(hour from sale_time) <12 then 'morning'
	when extract(hour from sale_time) between 12 and 17 then 'afternoon'
	else 'evening'
end as shift
from retail_sales)

select shift,
count(*) as total_orders
from  hourly_sales
group by shift

-- Q11] . Which category generated the highest revenue?

SELECT category,
sum(retail_sales.total_sale)	 
from retail_sales
group by 1
order by 1 desc

-- Q12] Which day had the highest sales?


select retail_sales.sale_date,
sum(retail_sales.total_sale) 
from retail_sales
group by 1
order by 2 DESC

--- Q13] What is the average order value for each category

select retail_sales.category,
round(avg(retail_sales.total_sale)) as avg_sales
from retail_sales
group by 1
order by 2 DESC

--- Q14]Which category is most popular among each gender?
select * 
from (SELECT gender,
	category,
	sum(quantity) as total_unit_sold,
	rank() over(partition by retail_sales.gender order by sum(quantity) desc) as rnk
	from retail_sales
	group by 1,2) t1
where rnk = 1

-- most popular categories among Male and Female are Clothing

--- Q15. Customer Segmentation by Spending

WITH CustomerSpending AS (
    SELECT customer_id,
    SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY customer_id),
	
SpendingThresholds AS (
    SELECT customer_id,
        	total_spent,
        	PERCENT_RANK() OVER (ORDER BY total_spent) AS spending_percentile
    		FROM CustomerSpending)

SELECT 
    customer_id,
    total_spent,
    CASE 
        WHEN spending_percentile >= 0.75 THEN 'High Value'
        WHEN spending_percentile >= 0.40 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM SpendingThresholds
ORDER BY total_spent DESC;












