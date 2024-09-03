/*
Data Analyst Portfolio Project | SQL Data Exploration
*/


SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--- Select Data that we are going to be using 

Select Location, date, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
Order by 1,2

--- Looking at Total cases Vs Total Deaths 
--- Shows likelihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeadthPercentage 
FROM PortfolioProject..CovidDeaths
Where Location Like '%state%'
Order by 1,2

--- Looking at Total Case VS Popluation 
--- Shows what percetage of population go Covid 

Select Location, date, total_cases, Population, (total_cases/population) *100 AS DeathPercetage 
FROM PortfolioProject..CovidDeaths
--Where Location Like '%state%'
Order by 1,2 

--- Looking at Country with Hihest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population)) *100 AS 
	PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
----Where Location Like '%state%'
Group by Location, Population 
Order by PercentPopulationInfected desc

--- Showing Countries with Highest Death Count Per Poplation 

Select Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
----Where Location Like '%state%'
GROUP BY LOCATION 
ORDER BY TotalDeathCount desc 

--- LET'S BREAK THINGS DOWN BY CONTINENT 
--- Showng Continents with the hihest death  count per popluation 
Select continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
----Where Location Like '%state%'
WHERE continent is not null 
GROUP BY continent 
ORDER BY TotalDeathCount desc 


--- GLOBAL NUMBERS 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) 
/SUM(New_Cases) * 100 as DeathPercentage

---- date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_cases)
----* 100 as DeathPercentage
--, total_deaths, (total_deaths/total_cases)* 100 AS DeadthPercentage 
FROM PortfolioProject..CovidDeaths
--Where Location Like '%state%'
WHERE continent is not null 
----group bY date 
Order by 1,2


--- Looking at Total Population VS Vaccinations 

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT (int,vac.new_vaccinations))OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeoplevaccinated 
--, (RollinggPeopleVaccinatedVaccinated/Population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location 
	 and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

-- USE CTE 
 
With PopvsVac  (Continet, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated 
--- (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths vac 
  On dea.location = vac.location 
  and dea.date = vac.date 
where dea.continent is not null 
--- order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--- TEMP TABLE 

DROP TABLE if exists #PercentPoplationVaccinated 
Create Table #PercentPopulationVaccinated 
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric 
)

INSERT INTO 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated 
--- (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths vac 
  On dea.location = vac.location 
  and dea.date = vac.date 
where dea.continent is not null 
--- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated 



--- Creating View to store data for late visulization 

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated 
--- (RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths vac 
  On dea.location = vac.location 
  and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select * 
FROM PercentPopulationVaccinated
