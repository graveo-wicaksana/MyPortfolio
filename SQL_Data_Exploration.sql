--remember. the data type is the first
--lesson learned: separate data into more than one of big groups
SELECT
	*
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
ORDER BY
	3, 4

--reason to take out null continent
SELECT
	DISTINCT continent, location
FROM
	portfolio_data_analyst..Covid_Death_Excel
ORDER BY 
	continent


--SELECT
--	*
--FROM
--	portfolio_data_analyst..Covid_Vaccinations_Excel
--WHERE
	--continent is not NULL
--ORDER BY
--	3, 4


--1. Select the data you want to focus on
--Take the important things
SELECT
	[date]
	, [location]
	, [population]
	, [total_cases]
	, [new_cases]
	, [total_deaths]
	, [new_deaths]
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE
	continent is not NULL
ORDER BY
	2, 1


--2. Test the calculation for total cases and total deaths
--shows the possibility of death for the related country
--total cases vs total death
SELECT
	[date]
	, [location]
	, [total_deaths]
	, [total_cases]
	, ROUND(CAST([total_deaths] as float)/[total_cases] * 100, 2) AS death_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
	AND location like 'Indonesia'
ORDER BY
	2, 1

--it turns out fail due to nvarchar format. so we need to convert into int first and execute again

--3 Calculate the total case compare with population
--Shows the percentage of population that got covid
SELECT
	[date]
	, [location]
	, [total_cases]
	, [population]
	, ROUND(CAST([total_cases] as float)/[population] * 100, 5) AS case_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
	--AND location like 'Indonesia'
ORDER BY
	2, 1


--4 Show the highest case percentage
SELECT
	--[date]
	[location]
	, [population]
	, MAX([total_cases]) HighInfectedCase
	, MAX(ROUND(CAST([total_cases] as float)/[population] * 100, 5)) AS high_case_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
	--AND location like 'Indonesia'
GROUP BY
	[location]
	--, [total_cases]
	, [population]
ORDER BY
	high_case_percentage DESC




--5 Show the highest date count per population
SELECT
	--[date]
	[location]
	, [population]
	, MAX([total_deaths]) HighDeathCase
	, MAX(ROUND(CAST([total_deaths] as float)/[population] * 100, 5)) AS high_death_case_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
	--AND location like 'Indonesia'
GROUP BY
	[location]
	--, [total_cases]
	, [population]
ORDER BY
	HighDeathCase DESC


--Highest death per continent
--lesson learned: location with continent filled shows that the location is calculated the value.
--But when we move to continent, try to think broader by focussing on continent null cause it will shows the whole continent from location column
--instead of recorded location in the certain continent
SELECT
	--[date]
	[location]
	--, [population]
	, MAX([total_deaths]) HighDeathCase
	, MAX(ROUND(CAST([total_deaths] as float)/[population] * 100, 5)) AS high_death_case_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is NULL
	--AND location like 'Indonesia'
GROUP BY
	[location]
	--, [total_cases]
	--, [population]
ORDER BY
	HighDeathCase DESC




--just in case
SELECT
	--[date]
	[continent]
	--, [population]
	, MAX([total_deaths]) HighDeathCase
	, MAX(ROUND(CAST([total_deaths] as float)/[population] * 100, 5)) AS high_death_case_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
	--AND location like 'Indonesia'
GROUP BY
	[continent]
	--, [total_cases]
	--, [population]
ORDER BY
	HighDeathCase DESC



--GLOBAL NUMBERS
SELECT
	--[date]
	--, [location]
	SUM([new_cases]) total_new_cases
	, SUM([new_deaths]) total_new_death
	, SUM(CAST([new_deaths] as float))/SUM([new_cases]) * 100 AS new_death_percentage
	--, (total_deaths/total_cases) * 100 --will result in integer due to both 
FROM
	portfolio_data_analyst..Covid_Death_Excel
WHERE 
	continent is not NULL
	--AND new_cases is not NULL
	--AND new_cases > 0
	--AND new_deaths is not NULL
	--AND CAST([total_deaths] as float)/[total_cases] * 100 IS NOT NULL
	--AND location like 'Indonesia'
--GROUP BY
--	[date]
ORDER BY
	1, 2


--ALTER TABLE portfolio_data_analyst..Covid_Death_Excel
--ALTER COLUMN [total_Deaths] int

ALTER TABLE portfolio_data_analyst..Covid_Vaccinations_Excel
ALTER COLUMN [total_vaccinations] bigint



--looking at the total vaccinations
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.date) cummulative_new_vaccinations
	--, tableB.new_vaccinations/tableA.population*100 percentage_vaccinations
FROM
	portfolio_data_analyst.dbo.Covid_Death_Excel tableA
JOIN
	portfolio_data_analyst.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	--tableB.new_vaccinations/tableA.population IS NOT NULL ensure the case. when the null is neglect, it means we just focus on the vaccine case
	tableB.continent IS NOT NULL
ORDER BY
	1, 2, 3




--using CTE
WITH
	Pop_vs_Vac( continet, location, date, population, new_vaccinations, cummulative_new_vaccinations)
AS 
	(
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.date) cummulative_new_vaccinations
	--, tableB.new_vaccinations/tableA.population*100 percentage_vaccinations
FROM
	portfolio_data_analyst.dbo.Covid_Death_Excel tableA
JOIN
	portfolio_data_analyst.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	--tableB.new_vaccinations/tableA.population IS NOT NULL ensure the case. when the null is neglect, it means we just focus on the vaccine case
	tableB.continent IS NOT NULL
--ORDER BY
--	1, 2, 3
	)
SELECT
	*
	, cummulative_new_vaccinations/population * 100 percent_vac_vs_pop
FROM
	Pop_vs_Vac


--using temp table
DROP TABLE
	IF EXISTS #POPvsVAC
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.date) cummulative_new_vaccinations
	--, tableB.new_vaccinations/tableA.population*100 percentage_vaccinations
INTO
	#POPvsVAC
FROM
	portfolio_data_analyst.dbo.Covid_Death_Excel tableA
JOIN
	portfolio_data_analyst.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	--tableB.new_vaccinations/tableA.population IS NOT NULL ensure the case. when the null is neglect, it means we just focus on the vaccine case
	tableB.continent IS NOT NULL
ORDER BY
	1, 2, 3

SELECT
	*
	, cummulative_new_vaccinations/population*100 percentage_vaccinations
FROM
	#POPvsVAC







--creating view for viz
CREATE VIEW
	POPvsVAC 
AS
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.date) cummulative_new_vaccinations
	--, tableB.new_vaccinations/tableA.population*100 percentage_vaccinations
FROM
	portfolio_data_analyst.dbo.Covid_Death_Excel tableA
JOIN
	portfolio_data_analyst.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	--tableB.new_vaccinations/tableA.population IS NOT NULL ensure the case. when the null is neglect, it means we just focus on the vaccine case
	tableB.continent IS NOT NULL


SELECT 
	*
FROM
	POPvsVAC 


