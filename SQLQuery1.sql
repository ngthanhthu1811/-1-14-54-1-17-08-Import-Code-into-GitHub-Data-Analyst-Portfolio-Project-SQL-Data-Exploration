SELECT *
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project].dbo.CovidDeaths$
--order by 3,4


-- Select Data used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
where location like '%Vietnam%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of populetion got Covid
SELECT location, date, population, total_cases ,(total_cases/population)*100 as PercentagePopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths$
--where location like '%Vietnam%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population,  MAX( total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths$
group by location, population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Break things dowm by Continent
-- Showing continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Global numbers
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentages
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths$ dea
Join [Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths$ dea
Join [Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths$ dea
Join [Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths$ dea
Join [Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 