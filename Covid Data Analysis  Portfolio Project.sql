Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4 

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

--Select Data that we are gonna be using

Select Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases of death
--Shows the Likelihood of Dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what Percentage of population that got covid

Select Location, date,Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate  compared to Population

Select Location,Population,MAX( total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc



--Showing continent with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc


--GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2



--Looking at Total Population VS VACCINATION

--Select *
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--   On dea.location = vac.location
--   and dea.date= vac.date

Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.Date) as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date= vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent , Location, Date, Populationn,New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated / Population) *100
From PopvsVac


---TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated / Population) *100
From #PercentPopulationVaccinated



--CREATING View to store data for later visualization

Create View PercentPopulationVaccinated  as

Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date= vac.date
where dea.continent is not null
----order by 2,3


Select *
From PercentPopulationVaccinated