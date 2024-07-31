--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--Selecting Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total cases versus total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%nigeria' AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population
--shows what percentage of populaton got covid
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 PercentPopulatonInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulatonInfected DESC

--showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC

--LET BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC

--showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount  DESC

GLOBAL NUMBERS
SELECT date, SUM(new_cases) total_cases, SUM(CAST(new_deaths as int))total_deaths, SUM((CAST(new_deaths as float))/NULLIF(CAST(new_cases AS FLOAT),0)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%nigeria'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total populaton vs vaccination

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS float)) OVER(PARTITION BY dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as (SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS float)) OVER(PARTITION BY dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100  
FROM PopvsVac

--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS float)) OVER(PARTITION BY dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS float)) OVER(PARTITION BY dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated
