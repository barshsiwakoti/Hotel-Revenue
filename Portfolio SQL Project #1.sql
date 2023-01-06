-- For this project, I Followed along the youtube video by Alex the Analyst

Select *
FROM Portfolio1..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--FROM Portfolio1..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio1..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows that percentage of population got Covid (in the United States)
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio1..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio1..CovidDeaths$
Group by Location, Population 
Order by PercentPopulationInfected desc

--BREAKING THINGS DOWN BY CONTINENT

--Since Total_deaths is nvarchar(255), we need to convert/cast it as int so its read as numeric
/*The right way
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio1..CovidDeaths$
Where continent is null
Group by location
Order by TotalDeathCount desc */

--Showing continents with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio1..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(New_Cases) as DeathPercentage
From Portfolio1..CovidDeaths$
Where continent is not null
Group By date --removing this will give total cases or total deaths across the world
order by 1,2


--Joining the two excel files
--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- everytime it gets to new location, count will start over
--(RollingPeopleVaccinated/population)*100 --need to create a temp table because you just created rolling people vaccinated
From Portfolio1..CovidDeaths$ dea
Join Portfolio1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopulationvsVaccinations (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- everytime it gets to new location, count will start over
--(RollingPeopleVaccinated/population)*100 --need to create a temp table because you just created rolling people vaccinated
From Portfolio1..CovidDeaths$ dea
Join Portfolio1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
From PopulationvsVaccinations


--TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- everytime it gets to new location, count will start over
--(RollingPeopleVaccinated/population)*100 --need to create a temp table because you just created rolling people vaccinated
From Portfolio1..CovidDeaths$ dea
Join Portfolio1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- everytime it gets to new location, count will start over
--(RollingPeopleVaccinated/population)*100 --need to create a temp table because you just created rolling people vaccinated
From Portfolio1..CovidDeaths$ dea
Join Portfolio1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--Query from the view created
Select *
From PercentPopulationVaccinated
