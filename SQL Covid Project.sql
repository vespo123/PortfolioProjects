SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths 
--shows likelihood of dying if you contract covid in your country 


Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- shows what percent of population got covid

Select location, date, population, total_cases, (total_cases/population) * 100 as PercentOfPopulationInfected 
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
ORDER BY 1,2


-- Looking at countries with higest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentOfPopulationInfected 
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group By population, location
ORDER BY PercentOfPopulationInfected desc


-- Showing countries with higest death count per population 


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group By location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- showing the continent with the highest death count 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent is null
Group By location
ORDER BY TotalDeathCount desc


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group By continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS



Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
ORDER BY 1,2


Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
ORDER BY 1,2



--looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingsVaccinations
--, (RollingsVaccinations/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3


-- USE CTE



with PopvsVac (continent, location, date, population, New_Vaccinations, RollingsVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingsVaccinations
--, (RollingsVaccinations/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingsVaccinations/population) * 100
from PopvsVac




-- TEMP TABLE 


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingsVaccinations numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingsVaccinations
--, (RollingsVaccinations/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3

Select *, (RollingsVaccinations/population) * 100
from #PercentPopulationVaccinated



--- creating view to store data for later visualizations 

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingsVaccinations
--, (RollingsVaccinations/population) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3


select *
from PercentPopulationVaccinated
where new_vaccinations is not null
