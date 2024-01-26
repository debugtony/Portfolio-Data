select location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases) )*100 as DeathPercent
From covidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select Location, Population,MAx(total_cases) as HighestInfectionCount,  CONVERT(decimal(18,2), total_cases) / CONVERT(decimal(18,2), population)*100 as infected
From covidDeaths
--Where location like '%states%'
Group by Location, Population
order by 1,2



Select Location, Population, MAX(CONVERT(decimal(18,2), total_cases)) as HighestInfectionCount,  MAX(CONVERT(decimal(18,2), Total_Cases) / CONVERT(decimal(18,2), Population) * 100) AS MaxInfectedRate
From covidDeaths
--Where location like '%states%'
Group by Location, Population
order by MaxInfectedRate desc

Select Location, MAX(CONVERT(decimal(18,2), Total_Deaths)) AS MaxTotalDeathCount
from covidDeaths
Group by location
Order by MaxTotalDeathCount Desc

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc
 
-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

Select * 
From covidDeaths dea
JOIN covidVaccinations vac
	ON dea.location = vac.location
	And dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM
    covidDeaths dea
JOIN
    covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    1, 2, 3;


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM
    covidDeaths dea
JOIN
    covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
--     2, 3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

FROM covidDeaths dea 
Join covidVaccinations vac
On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 