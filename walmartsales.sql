CREATE DATABASE IF NOT EXISTS WalmartSales; 

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- -----------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------Feature Engineering --------------------------------------------------------

-- time_of_the_day
select 
    time,
    (CASE
        WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternon"
        ELSE "Evening"
        END
    ) AS time_of_date
from sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
ALTER TABLE sales
DROP COLUMN time_of_date;

UPDATE sales
SET time_of_day = ( 
	CASE
        WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternon"
        ELSE "Evening"
        END
);
-- -------------ADD day_name COLUMN--------------------------------------------------------------------------------------------------------
SELECT date,
       DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- -----------------ADD MONTH NAME COLUMN-----------------------------------------------------------------------------------------------
SELECT date,
       MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------------------------------
-- ---------------------------------Genric Solutions------------------------------------------------------

-- How many unique cities does the data have?

SELECT DISTINCT city
FROM sales;
-- In which city is each branch?
SELECT DISTINCT city, branch 
FROM sales;
-- ------------------------------------------------------------------------------------------------------
-- --------------------------Product---------------------------------------------------------------------
-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales;
-- What is the most common payment method?
SELECT payment, COUNT(payment) as cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC;
-- What is the most selling product line?
SELECT product_line, COUNT(product_line) as cnt
FROM sales
GROUP BY product_line
ORDER BY cnt desc;
-- What is the total revenue by month?
SELECT month_name AS month, 
       SUM(total) AS total_revenue
FROM sales 
group by month
order by total_revenue desc;
-- What month had the largest COGS?
SELECT month_name AS month, 
       SUM(cogs) AS cogs
FROM sales 
group by month
order by cogs desc;
-- What product line had the largest revenue?
SELECT product_line AS product_line, 
       SUM(total) AS total_revenue
FROM sales 
group by product_line
order by total_revenue desc;
-- What is the city with the largest revenue?
SELECT branch, city,
       SUM(total) AS total_revenue
FROM sales 
group by city, branch
order by total_revenue desc;
-- What product line had the largest VAT?
SELECT product_line, 
       AVG(tax_pct) AS avg_tax
FROM sales 
group by product_line
order by avg_tax desc;
-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales. 
SELECT product_line, 
	   AVG(quantity) AS avg_qty,
       CASE 
        WHEN AVG(quantity) > 6 THEN "GOOD" ELSE "BAD"
        END as Remark
FROM sales
GROUP BY product_line;
-- Which branch sold more products than average product sold?
SELECT branch, 
       AVG(quantity) AS avg_qty
FROM sales
group by branch
Having SUM(quantity) > (SELECT AVG(quantity) FROM sales);
-- What is the most common product line by gender?
SELECT gender,
       product_line,
       COUNT(gender) as gdr
FROM sales
group by gender, product_line
order by gdr desc;
-- What is the average rating of each product line?
SELECT product_line, 
	   ROUND(AVG(rating), 2) as avg_rating
from sales
group by product_line
ORDER BY avg_rating desc;
-- ------------------------------------------------------------------------------------------------------
-- --------------------------------Sales-----------------------------------------------------------------
-- Number of sales made in each time of the day per weekday. 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
	Round(avg(tax_pct), 2) AS VAT
FROM sales
GROUP BY city 
ORDER BY VAT DESC;
-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	avg(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax DESC;
-- -------------------------------------------------------------------------------------------------------
-- ----------------------------------------Customer-------------------------------------------------------
-- How many unique customer types does the data have?
SELECT distinct(customer_type) 
FROM sales;

-- How many unique payment methods does the data have?
SELECT distinct(payment) as payment_method
FROM sales;

-- What is the most common customer type?
SELECT customer_type,
COUNT(*) As count
FROM sales
group by customer_type
order by count desc;

-- Which customer type buys the most?
select customer_type, count(*)
from sales
group by customer_type;

-- What is the gender of most of the customers?
select gender, count(customer_type) as customer
from sales
group by gender
order by customer desc;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
select time_of_day, avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating desc;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter

-- Which time of the day do customers give most ratings per branch?
select time_of_day, avg(rating) as avg_rating
from sales
where branch = "A"
group by time_of_day
order by avg_rating desc;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- Which day fo the week has the best avg ratings?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

-- Which day of the week has the best average ratings per branch?
select day_name, count(day_name) as cnt
from sales
where branch = "C"
group by day_name
order by cnt desc;