/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
--Select *
--From CovidDeaths 
--order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4


Select *
From CovidDeaths
Where continent is not null 
order by location, date


-- Select Data that we are going to be starting with

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM CovidDeaths
Where continent is not null
ORDER BY location, date

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY location, date

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_With_Covid
FROM CovidDeaths
--WHERE location like '%states%' AND continent is not null
ORDER BY location, date


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX( total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%' AND continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population
SELECT location, MAX(cast( total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast( total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--showing continents with the highest death count per population 
SELECT location, MAX(cast( total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT  date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 AS Death_Percentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY date, Total_Cases


--Joining CovidDeaths and CovidVaccinations
SELECT *
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  location, date


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (conintent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  location, date
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table If Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  location, date

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  location, date

SELECT *
FROM PercentPopulationVaccinated