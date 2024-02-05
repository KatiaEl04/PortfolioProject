select *
from Portfolio_Project..CovidDeaths
where continent is not null
ORDER BY 3,4

--select *
--from Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
select location, date, total_cases,new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--Lokoking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases,new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
WHERE location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
select location, date,  population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
select location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
Group by location,population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--Showing continents with the highest death count per population 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers 
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea 
join Portfolio_Project..CovidVaccinations vac
    ON dea.location=vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea 
join Portfolio_Project..CovidVaccinations vac
    ON dea.location=vac.location
	and dea.date= vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac 

--Temp Table 
Drop Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
 , Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea 
join Portfolio_Project..CovidVaccinations vac
    ON dea.location=vac.location
	and dea.date= vac.date

Select *,(RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated

--Creating View to store data for later visualizations 
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea 
join Portfolio_Project..CovidVaccinations vac
    ON dea.location=vac.location
	and dea.date= vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated
