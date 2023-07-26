
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/





SELECT * 
FROM CovidPortfolioProject..CovidDeaths
ORDER BY 3,4




-- Select the data that we are going to use


SELECT Location, date, new_cases, total_cases, total_deaths, population 
FROM CovidPortfolioProject..CovidDeaths
ORDER BY 1,2








ALTER TABLE CovidPortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT

ALTER TABLE CovidPortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE Location like '%India%'
ORDER BY 1,2





-- Total Cases vs Population
-- Shows the percentage of population infected with Covid


SELECT Location, date, Population, Total_cases,  (Total_cases/Population)*100 AS PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
--WHERE Location like '%india%'
ORDER BY 1,2




-- Countries with Highest Infection Rate compared to Population


SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
--WHERE Location like '%india%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC






-- Countries with Highest Death Count per Population


SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
--WHERE Location like '%india%'
GROUP BY Location
ORDER BY TotalDeathCount DESC









--Let's Break Things Down By Continent

-- Showing Continents with the Highest Death Count per Population


SELECT Continent, SUM(new_deaths) AS TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
GROUP BY Continent
ORDER BY TotalDeathCount DESC






--Global Numbers


Select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
order by 1,2









-- Total Population vs Vaccinations

-- Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
ORDER BY 2,3






-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopulationVaccinatedPercent
FROM PopvsVac






-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DateTime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopulationVaccinatedPercent
FROM #PercentPopulationVaccinated







-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date



