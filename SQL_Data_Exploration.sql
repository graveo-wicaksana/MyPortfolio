--Source of data https://ourworldindata.org/covid-deaths
--In this case, the covid data is split into covid deaths and covid vaccinations to show the SQL skills.
--The script running in SQL Server Management Studio
--Better to do data checking in SQL table because sometimes the data type is not match and need to be formatted.


--Check preview of the data.
SELECT
	*
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is not NULL
ORDER BY
	3, 4;

SELECT
	*
FROM
	PortfolioProject..Covid_Vaccinations_Excel
WHERE
	continent is not NULL
ORDER BY
	3, 4




--Explore important information the Covid Death data
--1. Show prevew of the data you want to focus on (certain columns)
SELECT
	[date]
	, [location]
	, [population]
	, [total_cases]
	, [new_cases]
	, [total_deaths]
	, [new_deaths]
FROM
	PortfolioProject..Covid_Death_Excel
WHERE
	continent is not NULL
ORDER BY
	2, 1


--2. Test the calculation for total cases and total deaths
--shows the possibility of death for the certain country
SELECT
	[date]
	, [location]
	, [total_deaths]
	, [total_cases]
	, ROUND(CAST([total_deaths] as float)/[total_cases] * 100, 2) AS death_percentage 
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is not NULL
	AND location like 'Indonesia'
ORDER BY
	2, 1


--3 Calculate the total case compare with population
--Shows the percentage of population that got covid
SELECT
	[date]
	, [location]
	, [total_cases]
	, [population]
	, ROUND(CAST([total_cases] as float)/[population] * 100, 5) AS case_percentage
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is not NULL
ORDER BY
	2, 1


--4 Show the highest infection rate
SELECT
	[location]
	, [population]
	, MAX([total_cases]) HighInfectedCase
	, MAX(ROUND(CAST([total_cases] as float)/[population] * 100, 5)) AS HighInfectedRate
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is not NULL
GROUP BY
	[location]
	, [population]
ORDER BY
	HighInfectedRate DESC




--5 Show the highest date count per population for countries
SELECT
	[location]
	, [population]
	, MAX([total_deaths]) HighDeathCase
	, MAX(ROUND(CAST([total_deaths] as float)/[population] * 100, 5)) AS high_death_case_percentage
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is not NULL
GROUP BY
	[location]
	, [population]
ORDER BY
	HighDeathCase DESC


--Show the highest death per continent
SELECT
	[location]
	, MAX([total_deaths]) HighDeathCase
	, MAX(ROUND(CAST([total_deaths] as float)/[population] * 100, 5)) AS high_death_case_percentage
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is NULL
GROUP BY
	[location]
ORDER BY
	HighDeathCase DESC





--6. Show Global Numbers for looking at new cases and new deaths
SELECT
	SUM([new_cases]) total_new_cases
	, SUM([new_deaths]) total_new_death
	, SUM(CAST([new_deaths] as float))/SUM([new_cases]) * 100 AS new_death_percentage
FROM
	PortfolioProject..Covid_Death_Excel
WHERE 
	continent is not NULL
ORDER BY
	1







--Explore important information the Covid Vaccinations data
--1. Join both covid death and covid vaccinations
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.date) cummulative_new_vaccinations
FROM
	PortfolioProject.dbo.Covid_Death_Excel tableA
JOIN
	PortfolioProject.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	tableB.continent IS NOT NULL
ORDER BY
	1, 2, 3



--2. Using CTE(Common Table Expression)
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
FROM
	PortfolioProject.dbo.Covid_Death_Excel tableA
JOIN
	PortfolioProject.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	tableB.continent IS NOT NULL
	)
SELECT
	*
	, cummulative_new_vaccinations/population * 100 percent_vac_vs_pop
FROM
	Pop_vs_Vac


--3. Using temp table
DROP TABLE
	IF EXISTS #POPvsVAC
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.location, tableA.date) cummulative_new_vaccinations
INTO
	#POPvsVAC
FROM
	PortfolioProject.dbo.Covid_Death_Excel tableA
JOIN
	PortfolioProject.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	tableB.continent IS NOT NULL
ORDER BY
	1, 2, 3

SELECT
	*
	, cummulative_new_vaccinations/population*100 percentage_vaccinations
FROM
	#POPvsVAC




--4. Using view for visualization
CREATE VIEW
	POPvsVAC 
AS
SELECT
	tableA.continent
	, tableB.location
	, tableA.date
	, tableA.population
	, tableB.new_vaccinations
	, SUM(convert(bigint, tableB.new_vaccinations)) OVER (partition by tableA.location order by tableA.location, tableA.date) cummulative_new_vaccinations
FROM
	PortfolioProject.dbo.Covid_Death_Excel tableA
JOIN
	PortfolioProject.dbo.Covid_Vaccinations_Excel tableB
ON
	tableA.date = tableB.date
	AND tableA.location = tableB.location
WHERE
	tableB.continent IS NOT NULL

SELECT 
	*
FROM
	POPvsVAC 
