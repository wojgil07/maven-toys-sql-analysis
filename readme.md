\# Retail Store \& Inventory Analysis

\*\*All queries and results are fully reproducible\*\* from the included CSV dataset files.



\## Dataset



\- \*\*Source\*\*: Maven Toys Retail Dataset (Maven Analytics – public domain / educational license)

\- \*\*Format\*\*: CSV (5 relational tables: `sales`, `products`, `stores`, `inventory`, `calendar`)

\- \*\*Size\*\*: 829,262 sales transactions across 50 stores and 35 products (Jan 2022 – Sep 2023)



\## Methodology \& Technical Skills



\- \*\*Database\*\*: MySQL

\- \*\*SQL techniques used\*\*:

&#x20; - Data quality \& referential integrity validation (anti-joins via `LEFT JOIN ... WHERE IS NULL`, `UNION ALL` audit checks)

&#x20; - Common Table Expressions (CTEs) for multi-stage aggregations

&#x20; - Window functions for rankings, time-series, and share of total (`DENSE\_RANK`, `LAG`, `NTILE`, `SUM() OVER()`)

&#x20; - Conditional aggregation (`CASE WHEN`) and defensive math (`NULLIF`, `COALESCE`)

&#x20; - Date formatting and Month-over-Month (MoM) growth modeling (`DATE\_FORMAT`)

\- All queries are modular, commented, and split into data validation (`01\_data\_quality.sql`) and business analysis (`02\_business\_analysis.sql`)



\## Key Analyses \& Findings



\### 1. Category Profitability by Store Location

\*\*Question\*\*: Which categories generate the highest profit, and how does their ranking change by location (Airport, Downtown, Commercial, Residential)?



\*\*Findings\*\*:

\- \*\*Downtown \& Residential\*\*: \*\*Toys\*\* rank \*\*#1\*\* in total profit (\*\*$630,029\*\* in Downtown; \*\*$136,214\*\* in Residential), followed by \*\*Electronics\*\* (\*\*#2\*\*)

\- \*\*Airport \& Commercial\*\*: \*\*Electronics\*\* take the \*\*#1\*\* profit spot (\*\*$108,197\*\* at Airports; \*\*$287,574\*\* in Commercial zones) despite \*\*Toys\*\* generating higher top-line revenue

\- \*\*Electronics\*\* maintain the highest profit margin across all locations (\*\*43.70%–45.75%\*\*), more than double that of \*\*Toys\*\* (\*\*20.81%–21.38%\*\*)



\### 2. Seasonality \& Month-over-Month (MoM) Revenue Growth

\*\*Question\*\*: In which months does the store chain hit peak sales, and how does MoM revenue growth trend over time?



\*\*Findings\*\*:

\- Highest revenue peaks occurred in \*\*March 2023\*\* (\*\*$883,515.64\*\*, \*\*+22.26%\*\* MoM) and \*\*December 2022\*\* (\*\*$877,203.69\*\*, \*\*+32.65%\*\* MoM)

\- Steepest seasonal contractions occurred in late summer: \*\*July 2022\*\* (\*\*-16.00%\*\* MoM) and \*\*August 2023\*\* (\*\*-20.22%\*\* MoM)



\### 3. Inventory Valuation \& Days of Supply (DOS)

\*\*Question\*\*: How much capital is tied up in inventory across the stores, and how long will the current stock last?



\*\*Findings\*\*:

\- Total capital tied up in inventory across all stores: \*\*$300,209.58\*\* (representing \*\*$410,240.58\*\* in potential retail revenue across \*\*29,742\*\* units)

\- \*\*Toys\*\* lock up the largest share of capital (\*\*$99,861.47\*\* / \*\*33.26%\*\* of total stock value) with \*\*15.5\*\* days of supply

\- \*\*Electronics\*\* hold the lowest capital share (\*\*$30,705.82\*\* / \*\*10.23%\*\*) and the fastest stock depletion at \*\*10.6\*\* days of supply



\### 4. Store Tier Concentration (Pareto / Tertile Split)

\*\*Question\*\*: How much of total profit and revenue is concentrated in the top tier of stores?



\*\*Findings\*\*:

\- \*\*Tier 1\*\* (top 17 stores) generates \*\*42.87%\*\* of total chain profit (\*\*$1,720,973.00\*\*) and \*\*41.91%\*\* of total revenue (\*\*$6,053,056.05\*\*), averaging \*\*$101,233.71\*\* profit per store

\- \*\*Tier 2\*\* (middle 17 stores) accounts for \*\*31.98%\*\* of profit (\*\*$75,503.35\*\* avg. profit per store)

\- \*\*Tier 3\*\* (bottom 16 stores) accounts for \*\*25.15%\*\* of profit (\*\*$63,093.69\*\* avg. profit per store)



\## Reproducibility



1\. Clone the repository

2\. Import the CSV files from `/data/` into your SQL database (strip the `$` symbol from `product\_cost` and `product\_price` in `products.csv` to cast as `DECIMAL(10,2)`)

3\. Run queries from `/queries/01\_data\_quality.sql` and `/queries/02\_business\_analysis.sql` in order



\---



Wojciech Gil  

\[LinkedIn](https://www.linkedin.com/in/wojciech-gil07/)



\*Last updated: October 2026\*

