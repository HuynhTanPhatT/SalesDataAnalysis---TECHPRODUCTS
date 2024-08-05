/*UPDATE [SaleDataProject].[dbo].[Worksheet$]
SET [Sales] = TRY_CAST([Sales] AS float);
ALTER TABLE [SaleDataProject].[dbo].[Worksheet$]
ALTER COLUMN [Sales] float;

UPDATE [SaleDataProject].[dbo].[Worksheet$]
SET [Price Each] = TRY_CAST([Price Each] AS float);
ALTER TABLE [SaleDataProject].[dbo].[Worksheet$]
ALTER COLUMN [Price Each] float;*/

select * 
from dbo.Worksheet;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
													--SalesTrendsOverTime

--Month-Over-Month(MoM Percentage)/City
With Monthly_Sales as (
select	trim(City) as city,
		DATENAME(month,ws.OrderDate) as Month_Name,
		DATEPART(month,ws.OrderDate) as Month_Number,
		DATEPART(year,ws.OrderDate) as Years,
		sum(ws.Sales) AS "ThisMonthSales"
from dbo.Worksheet ws
group by DATENAME(month,ws.OrderDate), DATEPART(month,ws.OrderDate),DATEPART(year,ws.OrderDate),city
),Pre_Month as (
select	city,
		Month_Name,
		Month_Number,
		Years,
		ThisMonthSales as ThisMonthSales,
		lag(ThisMonthSales,1,ThisMonthSales) over(partition by city order by Years,Month_number asc) as PreSalesMonths
from Monthly_Sales
)
select	*,
		pm.ThisMonthSales - pm.PreSalesMonths as Diff,
		(pm.ThisMonthSales  - pm.PreSalesMonths) / (pm.PreSalesMonths * 100) as MoM_Growth
from Pre_Month pm;

---Estimated Product Cost 
select	trim(city) as city,
		DATENAME(month,OrderDate) as OrderDate,
		DATEPART(month,OrderDate) as Month_Number,
        DATEPART(YEAR,OrderDate) as Year,
		sum(sales) as Revenue,
		(sum(Sales) * 0.15) as "Estimated Product Cost",
	(sum(Sales) - (sum(Sales) * 0.15)) / sum(Sales) as EstimatedProfitMargin
from dbo.Worksheet
--where DATEPART(YEAR,OrderDate) = 2020
group by City,DATENAME(month,OrderDate),DATEPART(month,OrderDate),DATEPART(YEAR,OrderDate);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Sales In each Month Per city in 2019/2020
With SalesInTwoYears as (
select	trim(city) as city,
		datepart(month,OrderDate) as Month,
		datepart(year,OrderDate) as year,
		sum(Sales) as TotalSales
from dbo.Worksheet
group by trim(City),datepart(month,OrderDate),datepart(year,OrderDate)
)
select *
from SalesInTwoYears
order by Year,city,Month 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

