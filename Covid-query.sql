-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_data

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
-- Indonesia berada di peringkat ke-18 dengan 3.07% orang yang mati
SELECT location, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths, MAX(total_deaths)/MAX(total_cases)*100 as DeathPercentage 
FROM covid_data
WHERE continent is not NULL
GROUP BY location
ORDER BY DeathPercentage DESC, TotalDeaths

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
-- 1.74% of the population has been contracted Covid in Indonesia
SELECT location, MAX(total_cases) as TotalCases, population, MAX(total_cases)/population*100 as InfectedPercentage 
FROM covid_data
WHERE continent is not NULL
GROUP BY location
ORDER BY InfectedPercentage DESC

-- Showing Countries with Highest Death Count per Population
-- Indonesia has the 9th highest total death out of all the country
SELECT location, MAX(total_deaths) as TotalDeath, population, MAX(total_deaths)/population*100 as DeathPercentage 
FROM covid_data
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeath DESC

-- STATS BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, SUM(new_deaths) as TotalDeath
FROM covid_data
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeath DESC

SELECT location, MAX(total_deaths) as TotalDeath
FROM covid_data
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeath DESC

-- Global Numbers by date
SELECT date, sum(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM covid_data
WHERE continent is not NULL
GROUP BY date

-- Looking at Total Population vs Vaccinations
SELECT location, SUM(new_vaccinations) as TotalVac, population, SUM(new_vaccinations)/population*100 as VacPercentage 
FROM covid_data
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalVac DESC

-- CTE
WITH Vacs (location, date, NewVac, TotalVac) as
(
SELECT location, date, new_vaccinations, total_vaccinations
FROM covid_data
WHERE continent is not NULL
)
SELECT *
FROM Vacs

WITH Cases (location, date, NewCases, TotalCases) as
(
SELECT location, date, 	new_cases, total_cases
FROM covid_data
WHERE continent is not NULL
)
SELECT *
FROM Cases

-- Creating View to store data for later visualization
CREATE VIEW Cases as
SELECT location, date, 	new_cases, total_cases
FROM covid_data
WHERE continent is not NULL

SELECT * FROM Cases