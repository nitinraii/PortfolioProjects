--SELECT *
--FROM PortfolioProject..CovidDeaths
--order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Location, date, total_cases,new_cases,total_deaths,population
--FROM PortfolioProject..CovidDeaths ORDER BY 1,2

--looking at total  total cases vs total deaths

--Select Location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
--where location like '%states%'
--ORDER BY 1,2

--looking at countries with highest infection rate

Select location , population , MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as
percentpopulationinfected

from PortfolioProject..CovidDeaths
Group by location, population
order by percentpopulationinfected DESC



--SHOWING DEATH COUNT PER POPULATION

SELECT LOCATION , MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location 
order by TotalDeathCount desc

-- break down by continent

SELECT continent , MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS


SELECT date, SUM(new_cases) as total_cases, sum (cast(new_deaths as int))  as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- total population vs vaccination
with PopvsVac (Continent,Location ,Date, Population,new_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date ,population , vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

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
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from  PercentPopulationVaccinated
