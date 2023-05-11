Select *
From PortfolioProject..CovidDeaths
Where continent is not Null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not Null
Order By 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%State%'
and continent is not Null
Order By 1,2

--Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%State%'
Order By 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%State%'
Group BY location, population
Order By PercentPopulationInfected Desc

--Showing Countries with Highest Death Count per Population

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%State%'
Where continent is not Null
Group BY location
Order By TotalDeathCount Desc

--LET's BREAKING THINGS DOWN BY CONTINENT

--Showing contintents with the highest death count per population

Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%State%'
Where continent is not Null
Group BY continent
Order By TotalDeathCount Desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%State%'
Where continent is not Null
--Group By date
Order By 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated   
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
Order By 2,3

--Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated   
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated   
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not Null
--Order By 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated   
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order By 2,3

Select *
From PercentPopulationVaccinated

