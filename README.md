# CRM Sales Opportunities Dashboard
The project designs an interactive dashboard for sales team managers of a company selling computer hardware to large businesses to keep track of sales performance of their team. <br>
### Tech Stack: SQL (T-SQL) | Power BI | DAX

## Business Problem:
The sales organization needed a centralized analytics solution to:
- **Track performance across 6 regional managers and their teams of sales agents**
- **Monitor key metrics (total sales, win rates, average deal values, and sales cycle length)**
- **Compare performance:** Identify top performers and underperformers relative to company averages
- **Analyze product mix:** Understand which products (GTX Pro, GTX Plus Pro, MG Advanced, etc.) drive revenue
- **Identify trends:** Track quarter-over-quarter growth and seasonal patterns
- **Pipeline visibility:** Monitor engaging opportunities and potential sales value
- **Geographic insights:** Understand sales distribution across countries and industries

## My Process
### 1. Data Import & Database Setup
I began by setting up a SQL Server database and importing the raw CSV data files:
**Database Architecture: created a relational database (crm_sales) with 4 normalized tables:**
- ``accounts`` table - Customer/company information
  - Fields: account name, sector, year_established, revenue, employees, office_location, subsidiary_of
  - Data types optimized: NVARCHAR for text, DECIMAL for revenue, INT for employees
- ``products`` table - Product catalog
  - Fields: product name, series, sales_price
  - Captures the 6 product lines (GTX Pro, GTX Plus Pro, MG Advanced, etc.)
- `sales_pipeline` table - Core fact table
  - Fields: opportunity_id (PK), sales_agent, product, account, deal_stage, engage_date, close_date, close_value
  - Captures full sales lifecycle from engagement to close
  - **opportunity_id** as primary key ensures data integrity
- `sales_agents` table - Sales team hierarchy
  - Fields: sales_agent, manager, regional_office
  - Links 30+ agents to 6 regional managers
#### Import Process:
- Used BULK INSERT for efficient data loading
- Specified field and row terminators for CSV parsing
- Set FIRSTROW = 2 to skip CSV headers

#### Design Decisions:
- Normalized structure prevents data redundancy
- Primary key on opportunity_id ensures unique opportunities
- Foreign key relationships defined through shared columns (sales_agent, product, account)
- Data types sized appropriately (NVARCHAR(50) for names, SMALLINT for years, DECIMAL(7,2) for revenue)

**Code can be found in `data_importing.sql` file.**

### 2. Data Profiling
