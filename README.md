
# 📝 Data Analyst Portfolio Project: SQL Data Exploration <img src="https://cdn-icons-png.flaticon.com/512/4248/4248443.png" width="30" alt="SQL Icon" />


## 🌍 Overview
This project explores COVID-19 data, specifically focusing on deaths, vaccinations, and their relationship to population. The goal is to identify trends, correlations, and patterns in the data, such as the infection rates and vaccination progress across various locations. The analysis utilizes SQL queries to extract meaningful insights and inform decisions regarding public health measures.

## 📊 Data Sources
- **CovidDeaths**: Contains data on COVID-19 deaths, new cases, total deaths, population, and more, across different locations and dates.
- **CovidVaccinations**: Includes information on COVID-19 vaccinations, particularly new vaccinations by date and location.

## 🔎 SQL Queries Overview
### 1. **Initial Data Exploration**
The initial queries explore the CovidDeaths table, filtering out entries where the continent is not null, and ordering by key metrics like total cases, deaths, and population. This helps understand the global spread of COVID-19.
```sql
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4
```

### 2. **📉 Analyzing the Relationship Between Total Cases and Total Deaths**
This query calculates the percentage of deaths for each location based on total cases, providing insights into the likelihood of dying if contracting COVID-19.
```sql
SELECT Location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%state%'
ORDER BY 1, 2
```

### 3. **🦠 COVID-19 Cases vs Population**
This query compares the total COVID-19 cases to the population of each location, helping us understand what percentage of each population has been infected.
```sql
SELECT Location, date, total_cases, Population, 
       (total_cases / population) * 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2
```

### 4. **🌍 Countries with Highest Infection Rate Compared to Population**
This analysis highlights countries with the highest infection rates, comparing total cases to population size.
```sql
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC
```

### 5. **💀 Countries with Highest Death Count per Population**
This query ranks countries by their total deaths per population, highlighting areas with the most severe impacts in terms of fatalities.
```sql
SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
GROUP BY LOCATION 
ORDER BY TotalDeathCount DESC
```

### 6. **🌍 Continents with the Highest Death Count per Population**
To further break down the data by continent, this query identifies continents with the highest total death counts relative to population.
```sql
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY TotalDeathCount DESC
```

### 7. **🌐 Global Summary**
This query provides global statistics, summing up the new cases and deaths globally, and calculating the global death percentage.
```sql
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths, 
       SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2
```

### 8. **💉 Total Population vs Vaccinations**
This query compares the total population of each location to the number of people vaccinated, showing the progress of vaccination efforts.
```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3
```

### 9. **📝 Using Common Table Expressions (CTE)**
This part of the project uses CTEs to perform advanced calculations, like computing the rolling total of vaccinated people.
```sql
WITH PopvsVac AS 
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated 
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location 
        AND dea.date = vac.date 
    WHERE dea.continent IS NOT NULL
) 
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac
```

### 10. **📊 Temporary Tables for Intermediate Analysis**
Temporary tables are used to hold intermediate data, like the cumulative count of vaccinations for each location.
```sql
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated 
(
    Continent NVARCHAR(255), 
    Location NVARCHAR(255), 
    Date DATETIME, 
    Population NUMERIC, 
    New_vaccinations NUMERIC, 
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;
```

### 11. **🔍 Creating a View for Later Visualization**
The view created here aggregates vaccination data, allowing for easy access in future visualizations.
```sql
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;

SELECT * 
FROM PercentPopulationVaccinated;
```

## 📌 Key Insights & Observations
- **Infection vs Population**: Some countries and continents have higher infection rates relative to their population, signaling potential hotspots.
- **Vaccination Progress**: The progress of vaccinations can be tracked over time, helping identify regions lagging behind.
- **Death Rates**: By comparing total deaths to total cases and population, we can identify areas with higher mortality rates.

## ✅ Conclusion
This project demonstrates the ability to explore and analyze large datasets using SQL. By creating complex queries, temporary tables, views, and CTEs, we can extract valuable insights into the global impact of COVID-19 and vaccination efforts.
