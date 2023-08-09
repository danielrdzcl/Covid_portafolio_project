/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From [Portafolio].[dbo].[Covid.deaths]
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select 
	Location,
	date, 
	total_cases_per_million,
	new_cases, total_deaths_per_million,
	population,
	(population/1000000)  AS population_per_million,
	(total_cases_per_million * (population/1000000)) AS aprox_total_cases 
From
	[Portafolio].[dbo].[Covid.deaths]
Where 
	continent is not null 
order by 
	1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select
	Location, 
	date, 
	(total_cases_per_million * (population/1000000)) AS aprox_total_cases ,
	total_deaths, 
	(total_deaths/(total_cases_per_million * (population/1000000)))*100 as DeathPercentage
From 
	[Portafolio].[dbo].[Covid.deaths]
Where 
	location like 'Mexico'
	and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population per million infected with Covid

Select 
	Location, 
	date, 
	Population, 
	(total_cases_per_million * (population/1000000)) AS aprox_total_cases,  
	((total_cases_per_million * (population/1000000))/population)*100 as PercentPopulationInfected
From
	[Portafolio].[dbo].[Covid.deaths]
Where 
	location like 'Mexico'
order by 1,2
 

-- Countries with Highest Infection Rate compared to Population

Select 
	Location,
	Population,
	MAX((total_cases_per_million * (population/1000000))) as HighestInfectionCount, 
	Max(((total_cases_per_million * (population/1000000))/population))*100 as PercentPopulationInfected
From 
	[Portafolio].[dbo].[Covid.deaths]
--Where location like '%states%'
Group by
	Location,
	Population
order by 
	PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select 
	Location,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
	[Portafolio].[dbo].[Covid.deaths]
--Where location like '%states%'
Where 
	continent is not null 
Group by 
	Location
order by
	TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select 
	continent, 
	MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
	[Portafolio].[dbo].[Covid.deaths]
--Where location like '%states%'
Where 
	continent is not null 
Group by 
	continent
order by
	TotalDeathCount desc

-- GLOBAL NUMBERS

Select 
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From 
	[Portafolio].[dbo].[Covid.deaths]
--Where location like '%states%'
where 
	continent is not null 
--Group By date
order by
	1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
    [Portafolio].[dbo].[Covid.deaths] dea
JOIN 
    [Portafolio].[dbo].[covid_vaccination] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    2, 3;


-- Create a CTE named PopvsVac to calculate the rolling sum of vaccinated people

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location,
        dea.date, 
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
    FROM
        [Portafolio].[dbo].[Covid.deaths] dea
    JOIN
        [Portafolio].[dbo].[covid_vaccination] vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL 
)

-- Select data from the CTE and calculate the vaccination percentage
SELECT 
    *,
    (RollingPeopleVaccinated * 100.0) / NULLIF(Population, 0) as VaccinationPercentage
FROM
    PopvsVac;

