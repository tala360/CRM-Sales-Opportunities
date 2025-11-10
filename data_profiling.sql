/* data profiling performed to identify relevant data and potential anomalies, outliers,  
or other data quality issues that needs to be handled prior to EDA.*/

use crm_sales;
go
--------------------------------------------------------------------------------------------------
-- SALES_PIPELINE TABLE

-- quick glance at the table
select * from dbo.sales_pipeline;

-- check total # of transactions
select count(distinct opportunity_id)  from sales_pipeline;
-- total sales opportunities: 8,800

-- how many unique sales agents conducted transactions, and are there nulls?
select distinct sales_agent from dbo.sales_pipeline 
-- 30 sales agents, no nulls

-- how many unique products are in the sales pipeline, and are there nulls?
SELECT DISTINCT product FROM sales_pipeline
-- 7 unique products, no nulls

-- how many unique accounts are in the sales pipeline, and are there nulls?
SELECT DISTINCT account FROM sales_pipeline;
-- total 86 unique accounts, there are nulls which will be investigated further
-- how many null accounts are there?
select count(*) from sales_pipeline where account is null
-- 1425 nulls
select deal_stage,count(*) from sales_pipeline where account is null group by deal_stage
-- 337 are in the prospecting stage - which means the sales agents are actively looking for clients to engage
-- 1088 records are in the engaging stage

-- check the total # of transactions by deal stage
select deal_stage, count(opportunity_id) as total_count 
from sales_pipeline
group by deal_stage
/* 
deal_stage	total_count
Lost			2473
Engaging		1589
Prospecting		500
Won				4238 */
-- no missing values, and distribution looks logical

-- check the earliest and latest engage dates
select min(engage_date) as earliest,max(engage_date) as latest from sales_pipeline
-- earliest was 2016-10-20	and latest was 2017-12-27, date range is within a normal timeframe

-- check for missing values in the engagement dates
select * from sales_pipeline where engage_date is null
--there are 500 records with missing engage_dates, to investigate further check their deal stages, closing dates and values
select distinct deal_stage,close_date,close_value 
from sales_pipeline where engage_date is null
-- they are all in the prospecting stage, with no closing date or closing value so in business context, it does make sense

-- check the earliest and latest closing dates
select min(close_date) as earliest,max(close_date) as latest from sales_pipeline
-- earliest was 2017-03-01	and latest was 2017-12-31, date range is within a normal timeframe

-- check for missing values in the closing dates
select * from sales_pipeline where close_date is null
-- 2089 records with missing closing dates, to investigate further check their deal stages and closing values
select distinct deal_stage, close_value 
from sales_pipeline where close_date is null
-- they are all in the engaging or prospecting stage, with no closing value, so in business context this makes sense

-- check stats for the close_value 
select min(close_value) as 'min', 
max(close_value) as 'max', 
avg(close_value) as 'avg', 
sum(case when close_value is null then 1 else 0 end) as count_nulls
from sales_pipeline
-- the min is 0 (which will be investigated), max is 30288, avg is 1490, with a total of 2089 nulls (which were addressed before)

-- check the deal_stage where the closing value was 0
select distinct deal_stage from sales_pipeline where close_value = 0
-- all these opportunities were lost, which makes sense as to why their value is 0.

--------------------------------------------------------------------------------------------------
-- ACCOUNTS TABLE

-- quick glance
select * from accounts
-- this clearly is a dimensional table with only 85 records, by visually inspecting the table we can see that:
-- there are only some nulls in the SUBSIDIARY_OF column, makes sense since not all companies are subsidiaries

-- how many unique accounts are there? just in case there are any duplicates
-- count distinct accounts in a case-insensitive manner by normalizing all values to lowercase (just in case)
select count(distinct(lower(account))) from accounts
-- 85 total accounts, so no duplicates

--------------------------------------------------------------------------------------------------
-- PRODUCTS TABLE

-- quick glance at the tbale
select * from products
-- only 7 records
-- there are 3 series with a total of 7 products

-- the product GTX Pro is written as GTXPro in sales_pipeline so this needs to be fixed
UPDATE sales_pipeline
SET product = 'GTX Pro'
WHERE product = 'GTXPro'

-- double check and confirm the changes were applied
select distinct product from sales_pipeline

--------------------------------------------------------------------------------------------------
-- SALES_AGENTS TABLE

--quick glance
select * from sales_agents
-- only 35 records (sales agents), by visually inspecting the table, there are NO nulls

-- group sales teams by regional office
-- count in a case-insensitive manner by normalizing all values to lowercase (just in case)
SELECT 
    regional_office, 
    COUNT(DISTINCT LOWER(manager)) AS manager_count,
    COUNT(DISTINCT LOWER(sales_agent)) AS sales_agent_count
FROM sales_agents
GROUP BY regional_office;
-- there are 2 managers in each region
-- central region has 11 sales agents, whereas east and west regions both have 12 sales agents each.

-- there are 35 unique sales agents in the sales_agents table, but only 30 in the sales pipeline
-- find sales agents in sales_agents not listed in sales_pipeline
select distinct t1.sales_agent from 
sales_agents t1
left join sales_pipeline t2 on t1.sales_agent=t2.sales_agent
where t2.sales_agent is null
-- there's no additional data to explain this discrepancy
-- we can assume that these sales agents are newly recruited and have not started prospecting opportunities.

--------------------------------------------------------------------------------------------------

/* CONCLUSION
The dataset contains some expected missing values, which have been retained
The sales_pipeline product column was cleaned to correct spelling inconsistencies with the products table
Overall, all four tables are of sufficient quality and ready for EDA now
*/