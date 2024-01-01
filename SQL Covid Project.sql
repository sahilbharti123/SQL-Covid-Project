Select * 
from PortfolioProject..CovidDeaths
order by 
	3,4;


Select * 
from PortfolioProject..CovidVaccinations
order by 3,4

Select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From PortfolioProject..CovidDeaths
order by 
	1,2;

--Total deaths vs Total cases

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN total_cases > 0 THEN (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100
        ELSE 0
    END AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY
    1, 2;

--Total Cases vs Population

SELECT
    location,
    date,
    total_cases,
    Population,
    CASE
        WHEN total_cases > 0 THEN (CAST(total_cases AS FLOAT) / CAST(Population AS FLOAT)) * 100
        ELSE 0
    END AS PercentPopulationInfected
FROM
    PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY
    1, 2;

--Countries with highest infection rates compared to population

SELECT
    location,
    MAX(total_cases) as HighestInfectionCount,
    Population,
    MAX ((total_cases/Population))*100 AS PercentPopulationInfected
FROM
    PortfolioProject..CovidDeaths
GROUP BY location, Population
ORDER BY
    PercentPopulationInfected desc

--Countries with highest death count per population

SELECT
    location,
    MAX(cast(total_deaths as int)) as HighestDeathCount
FROM
    PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY
    HighestDeathCount desc

--Breaking by continent

SELECT
    location,
    MAX(cast(total_deaths as int)) as HighestDeathCount
FROM
    PortfolioProject..CovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY
    HighestDeathCount desc

--Global Numbers

SELECT
    date,
    SUM(CAST(New_cases AS INT)) as Total_cases,
    SUM(CAST(New_deaths AS INT)) as Total_deaths,
    CASE
        WHEN SUM(CAST(New_cases AS INT)) > 0
        THEN
            SUM(CAST(New_deaths AS INT)) * 100.0 / NULLIF(SUM(CAST(New_cases AS INT)), 0)
        ELSE
            0
    END AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    1, 2;

SELECT
    SUM(CAST(New_cases AS INT)) as Total_cases,
    SUM(CAST(New_deaths AS INT)) as Total_deaths,
    CASE
        WHEN SUM(CAST(New_cases AS INT)) > 0
        THEN
            SUM(CAST(New_deaths AS INT)) * 100.0 / NULLIF(SUM(CAST(New_cases AS INT)), 0)
        ELSE
            0
    END AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY
    1, 2;


--looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by
	2,3;

--other method
Select dea.location, dea.population, MAX(cast (vac.total_vaccinations as bigint))
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
group by dea.location, dea.population
order by
	1;

--Using CTE

With PopvsVaC (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by
--	2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by
--	2,3;

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to visualise data

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by
--	2,3;