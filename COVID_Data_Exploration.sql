/* Learning Objective: explore COVID data in SQL. */

/*Shows likelihood of dying if you get covid in the US*/

SELECT
		location,
		date,
		total_cases,
		total_deaths,
		ROUND((total_deaths/total_cases)*100, 2) AS Death_Pct
FROM CovidDeaths
WHERE location  LIKE '%states'
ORDER BY 1,2 ;

/*Shows what Death Percentage of Population got Covid*/

SELECT
		location,
		date,
		population,
		total_cases,
		ROUND((total_deaths/population)*100, 2) AS Death_Pct
FROM CovidDeaths
WHERE location  LIKE '%states'
ORDER BY 1,2 ;

/*Shows what countries with the Highest Infection Rate compared to population*/

SELECT
		location,
		population,
		MAX(total_cases) as Highest_Infection_Count,
		ROUND((MAX(total_cases)/population)*100, 2) AS Pct_Highest_Population_Infected
FROM CovidDeaths
GROUP BY 1,2
ORDER BY 3 DESC;

/*Shows continent with Highest Death Count per Population*/

SELECT
		continent,
		MAX(CAST (total_deaths AS INT)) as Total_Death_Counts
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

/*Shows Total Population vs. Vaccination*/

SELECT
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3;

/*USE CTE to look at the vaccination rate compared to population by continent*/

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac ;

/*Temp Table to look at the vaccination rate compared to population by continent*/
DROP TABLE IF EXISTS Percent_population_vaccinated;
CREATE TEMPORARY TABLE Percent_population_vaccinated
(
continent TEXT,
location TEXT,
date INTEGER,
population REAL,
new_vaccinations REAL,
RollingPeopleVaccinated REAL
);

INSERT INTO Percent_population_vaccinated
SELECT
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM Percent_population_vaccinated ;

/*Creating view to store data for later visualization*/

CREATE VIEW Percent_population_vaccinated
AS
SELECT
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
;
