select *
from [dbo].[CovidDeaths]
order by 3,4

/*select * 
from [dbo].[CovidVaccinations]
order by 3,4 */

--Select required data 

select location,date,total_cases , new_cases,total_deaths, population 
from PortfolioProject..CovidDeaths

--Looking at total Cases vs total Deaths
--Indicate the chance of dying if you contact covid in your country

select location,date,total_cases , total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got Covid

select location,date, Population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, Population, Max(total_cases) as HighestInfectionCount ,Max( (total_cases/population))*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by InfectedPopulationPercentage desc

---Showing the country with highest Death Count per Population

select location,population , Max (cast( Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by TotalDeathCount desc

---Let's break things down by Continent

select location , Max (cast( Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


---Showing Continents with the highest death count per population

select continent , Max (cast( Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


---Global numbers


select date,sum (new_cases) TotalNewCases ,sum (cast (new_deaths as int )) TotalNewDeaths, sum (cast (new_deaths as int ))/sum (new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
Group by date
order by 1,2

---
select sum (new_cases) TotalNewCases ,sum (cast (new_deaths as int )) TotalNewDeaths, sum (cast (new_deaths as int ))/sum (new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
---Group by date
order by 1,2



-----Looking at Total population vs Vaccination


Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3


--USE CTE

With PopvsVac 
as
(Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 )
Select Continent, Location,Date, Population,isnull(new_Vaccinations,0) New_Vaccination,
isnull(RollingPeopleVaccinated,0) RollingPeopleVaccinated, (isnull(RollingPeopleVaccinated,0)/population) *100 as PercentPopulationVaccinated
from PopvsVac

---Create View to store data for later visualization

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null

select * from PopulationVaccinated



