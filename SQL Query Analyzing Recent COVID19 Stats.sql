Select *
From PortfolioProject..['covid deaths$']
where continent is not null
order by 3,4


-- Select Data that I will use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid deaths$']
order by 1,2




-- Looking at the Total Cases vs Total Deaths
-- Shows me the likelihood of dying if you get COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid deaths$']
where location like '%states%'
order by 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of the population got Covid
Select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid deaths$']
where location like '%states%'
order by 1,2



--Looking at Countries with Highest Infection Rate when compared to population
Select location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['covid deaths$']
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Shows the countries with the highest Death Count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid deaths$']
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid deaths$']
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing the Continents with the Highest Death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid deaths$']
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['covid deaths$']
-- where location like '%states%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
