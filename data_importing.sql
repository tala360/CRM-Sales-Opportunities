-- switch to database
USE crm_sales;
GO
---------------------------------------------------------------------------------------------
-- create accounts table
CREATE TABLE dbo.accounts (
    account NVARCHAR(50),
    sector NVARCHAR(20),
    year_established SMALLINT,
    revenue DECIMAL(7,2),
    employees INT,
    office_location NVARCHAR(20),
    subsidiary_of NVARCHAR(20)
);
GO

-- bulk insert accounts data
BULK INSERT dbo.accounts
FROM 'C:\Users\User\Desktop\projects\CRM_Sales_Opportunities\dataset\accounts.csv'
WITH (FIELDTERMINATOR = ',',ROWTERMINATOR = '\n',FIRSTROW = 2);
GO
---------------------------------------------------------------------------------------------
-- create products table
create table dbo.products (
	product nvarchar(20),
	series nvarchar(5),
	sales_price int
);
go

--bulk insert products data
BULK INSERT dbo.products
FROM 'C:\Users\User\Desktop\projects\CRM_Sales_Opportunities\dataset\products.csv'
WITH (FIELDTERMINATOR = ',',ROWTERMINATOR = '\n',FIRSTROW = 2);
go
---------------------------------------------------------------------------------------------
-- create sales pipeline table
create table dbo.sales_pipeline(
	opportunity_id nvarchar(50) primary key,
	sales_agent nvarchar(30),
	product nvarchar(20),
	account nvarchar(50),
	deal_stage nvarchar(15),
	engage_date date,
	close_date date,
	close_value int
);
go

--bulk insert sales pipeline data
BULK INSERT dbo.sales_pipeline
FROM 'C:\Users\User\Desktop\projects\CRM_Sales_Opportunities\dataset\sales_pipeline.csv'
WITH (FIELDTERMINATOR = ',',ROWTERMINATOR = '\n',FIRSTROW = 2);
go
---------------------------------------------------------------------------------------------
-- create sales agents table
create table sales_agents(
	sales_agent nvarchar(30),
	manager nvarchar(30),
	regional_office nvarchar(10)
);

go
--bulk insert sales agent data
BULK INSERT dbo.sales_agents
FROM 'C:\Users\User\Desktop\projects\CRM_Sales_Opportunities\dataset\sales_teams.csv'
WITH (FIELDTERMINATOR = ',',ROWTERMINATOR = '\n',FIRSTROW = 2);
go


