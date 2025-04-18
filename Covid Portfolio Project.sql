--Select *
--From PortfolioProject..CovidDeaths
--order by 3, 4

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population FLOAT;

-- ...continue for the rest numeric columns


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE ISDATE([date]) = 0;


ALTER TABLE PortfolioProject..CovidDeaths
ADD RealDate DATE;


UPDATE PortfolioProject..CovidDeaths
SET RealDate = TRY_CAST([date] AS DATE);

ALTER TABLE PortfolioProject..CovidDeaths
DROP COLUMN [date];

EXEC sp_rename 'PortfolioProject..CovidDeaths.RealDate', 'date', 'COLUMN';

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- looking at Total cases vs Total_deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%China'
order by 1, 2

-- shows what percentage of population got Covid 
SELECT Location, date, total_cases, population, (total_cases / population ) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%China'
ORDER BY 1, 2

-- looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Max(population) AS population, Max(total_cases) AS MaxTotalCases, Max((total_cases / NULLIF(population, 0 ))) * 100 as 
 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location
ORDER BY PercentPopulationInfected desc

-- population vs vaccinations
-- use CTE
With PopvaVac (continent, location, date, population, new_vaccinations, cumulativevaccinated)
as
(
	SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (
		PARTITION BY dea.location
		ORDER BY dea.date
		) AS CumulativePeopleVaccinated
	FROM 
	PortfolioProject..CovidDeaths dea
	JOIN 
	PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE 
	dea.continent IS NOT NULL
)
SELECT * ,(cumulativevaccinated / NULLIF(population, 0)) * 100 AS PercentVaccinated
From PopvaVac