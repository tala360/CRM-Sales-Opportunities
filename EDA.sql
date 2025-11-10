use crm_sales;

-- total sales amounts and average sale value by closing date quarter
select 
concat('Q',DATEPART(QUARTER,CLOSE_DATE),' ',DATEPART(YEAR,CLOSE_DATE)) as quarter_year,
SUM(CLOSE_VALUE) AS TOTAL_SALES,
AVG(CLOSE_VALUE) AS AVG_SALE_VALUE
from sales_pipeline 
WHERE deal_stage='Won'
group by concat('Q',DATEPART(QUARTER,CLOSE_DATE),' ',DATEPART(YEAR,CLOSE_DATE))
order by quarter_year asc
-- Q2 2017 brought in the most sales at approx. 3.09M, whereas Q1 2017 was the worst at ~1.13M

-- top 5 sales agents with the highest total sales amounts, 
-- including their manager, average sale value, and number of won opportunities
select top 5
t1.sales_agent, 
t2.manager,
sum(close_value) as total_sales,
avg(close_value) as avg_sale_value,
count(distinct opportunity_id) as count_sales
from sales_pipeline t1
left join sales_agents t2 on lower(t1.sales_agent)=lower(t2.sales_agent)
where deal_stage = 'Won'
group by t1.sales_agent,t2.manager
order by total_sales desc 
-- Darcel Schlecht brought in the most sales amount across the entire year at approx. 1.15M 

-- winning and losing rates by sales agent along with their manager
SELECT 
t1.sales_agent,
t2.manager,
SUM(CASE WHEN deal_stage='Won' THEN 1 ELSE 0 END) AS won_opp,
SUM(CASE WHEN deal_stage='Lost' THEN 1 ELSE 0 END) AS lost_opp,
COUNT(*) AS total_opps,
ROUND(CAST(SUM(CASE WHEN deal_stage='Won' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 2) AS win_rate,
ROUND(CAST(SUM(CASE WHEN deal_stage='Lost' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 2) AS losing_rate
FROM sales_pipeline t1
left join sales_agents t2 on lower(t1.sales_agent) = lower(t2.sales_agent )
WHERE deal_stage IN ('Won','Lost')  
GROUP BY t1.sales_agent,t2.manager

-- avg days to close a deal - by sales agent, along with their manager
select t1.sales_agent,
t2.manager,
AVG(CAST(DATEDIFF(DAY, engage_date, close_date) AS FLOAT)) AS avg_days_to_close
from sales_pipeline t1
left join sales_agents t2 on lower(t1.sales_agent) = lower(t2.sales_agent )
where close_date is not null
group by t1.sales_agent,t2.manager


-- POTENTIAL SALES OPPORTUNITIES:
-- total # of sales opportunities and their potential value, by sales agent and manager
SELECT
	t1.sales_agent,
	t3.manager,
	count(opportunity_id) as total_opportunities,
	sum(t2.sales_price) as total_potential_value
FROM sales_pipeline t1
left join products t2 on t1.[product] = t2.[product]
left join sales_agents t3 on lower(t3.sales_agent) = lower(t1.sales_agent)
where t1.deal_stage = 'Engaging'
group by t1.sales_agent, t3.manager
order by total_opportunities desc
-- Markita Hansen has the highest potential deal value at 282.8K across 79 opportunities,
-- whereas Vicki Laflamme has the highest number of potential opportunities at 104, with a total potential value of 227.3K

-- total sales by region
SELECT office_location AS region, SUM(close_value) AS total_sales
FROM sales_pipeline AS t1
LEFT JOIN accounts AS t2
ON t1.account = t2.account
WHERE deal_stage = 'Won'
GROUP BY office_location
order by total_sales desc
-- United States, Korea, Jordan, Panama, Japan are the top 5 countries bringing in sales


-- total sales by industry
SELECT 
	sector AS industry,
	SUM(close_value) as total_sales
FROM sales_pipeline AS t1
LEFT JOIN accounts AS t2
ON t1.account = t2.account
WHERE
deal_stage = 'Won'
group by sector
order by total_sales desc
-- retail, tech, medical, software, and finance are the top 5 industries bringing in sales

-- total sales by product
WITH cte_product_sales AS (
	SELECT [product], 
	close_value,
	CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END AS win_flag
	FROM sales_pipeline
	WHERE close_date IS NOT NULL
)
SELECT 
	[product], 
	SUM(close_value) AS total_sales,
	SUM(win_flag) AS Wins,
	AVG(CAST(win_flag AS FLOAT))*100 AS win_rate
FROM cte_product_sales
GROUP BY [product]
ORDER BY total_sales DESC
GO
-- GTX Pro brings in the most sales at 3,510,578, where as MG Special has the highest winning rate at 64.84%

-- sales over time
WITH qtr_sales_by_manager AS (
SELECT
		concat('Q',DATEPART(QUARTER,CLOSE_DATE),' ',DATEPART(YEAR,CLOSE_DATE)) as quarter_year,
		manager,
		SUM(close_value) AS Total_Sales
	FROM sales_pipeline AS sp
	LEFT JOIN sales_agents AS st
	ON sp.sales_agent = st.sales_agent
	where close_date is not null
	GROUP BY concat('Q',DATEPART(QUARTER,CLOSE_DATE),' ',DATEPART(YEAR,CLOSE_DATE)) , manager
)
SELECT *,
	AVG(Total_Sales) OVER(PARTITION BY quarter_year) AS company_avg,
	RANK() OVER(PARTITION BY quarter_year ORDER BY Total_Sales DESC) AS 'Rank'
FROM qtr_sales_by_manager
ORDER BY quarter_year, Total_Sales DESC



