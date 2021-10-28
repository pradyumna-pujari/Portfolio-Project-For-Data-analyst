/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
USE [Portfolio Project]
SELECT * FROM ['covid deaths$']
ORDER BY 3,4

--SELECT * FROM ['covis vaccinations$']
--ORDER BY 3,4

-- Select Data that we are going to be starting with

select LOCATION, DATE , TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION
FROM [Portfolio Project]..['covid deaths$']
ORDER BY 1,2

-- Total Cases vs Total Deaths
--it shows likelihood of dying if you contract covid-19 in Asia

select LOCATION, DATE , TOTAL_CASES,TOTAL_DEATHS,POPULATION,(total_deaths/total_cases)*100 AS DEATH_PERCENTAGE
FROM [Portfolio Project]..['covid deaths$']
WHERE LOCATION LIKE '%Asia%'
ORDER BY 1,2

--Looking at total cases vs. population
--Shows what percentage of	population got covid

select LOCATION, DATE ,POPULATION ,TOTAL_CASES,(total_cases/population)*100 AS Percent_of_population_infected
FROM [Portfolio Project]..['covid deaths$']
--WHERE LOCATION LIKE '%Asia%'
ORDER BY 1,2


--Looking at coutries with highest infection rates compared to populations

select LOCATION ,POPULATION ,max(TOTAL_CASES),max((total_cases/population))*100 AS Percent_of_population_infected
FROM [Portfolio Project]..['covid deaths$']
group by LOCATION ,POPULATION
ORDER BY Percent_of_population_infected desc

--Showing countries with highest death count per population

select LOCATION  ,max(cast(total_deaths as int)) as Total_death_counts
FROM [Portfolio Project]..['covid deaths$']
where continent is not null
group by LOCATION 
ORDER BY Total_death_counts desc

--NOW LET'S CHECK BY CONTINENT 
--CONTINET WITH HIGHEST DEATH COUNTS

select continent  ,max(cast(total_deaths as int)) as Total_death_counts
FROM ['covid deaths$']
where continent is not null
group by continent 
ORDER BY Total_death_counts desc

--GLOBAL NUMBERS

SELECT date ,SUM(new_cases) as total_new_case, sum(cast(new_deaths as int)) as total_new_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) *100 as Death_percentage
FROM ['covid deaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Now let's check the total cases across the global

select sum(new_cases) as total__new_cases , sum(cast(new_deaths as int)) as total__new_deaths
from ['covid deaths$']
where continent is not null

--now lets join two tables
--Lookig at total populaton vs. vaccination	
-- Shows Percentage of Population that has recieved at least one Covid Vaccine	

select dea.continent,dea.location, dea.date ,dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint) ) over (Partition	by dea.location order by dea.location,dea.date) 
as Totalpeoplevaccinated
from ['covid deaths$'] dea
join ['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac(continent,location,date,population,new_vaccination,Totalpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date ,dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint) ) over (Partition	by dea.location order by dea.location,dea.date) 
as Totalpeoplevaccinated
from ['covid deaths$'] dea
join ['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

)
select *, (Totalpeoplevaccinated/population)*100 as percentage_of_vaccination 
from popvsvac

--Temp Table

create table #Peoplegetvaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccination numeric,
Totalpeoplevaccinated numeric
)
insert into #Peoplegetvaccinated
select dea.continent,dea.location, dea.date ,dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint) ) over (Partition	by dea.location order by dea.location,dea.date) 
as Totalpeoplevaccinated
from ['covid deaths$'] dea
join ['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
select *,(Totalpeoplevaccinated/population)*100
from #Peoplegetvaccinated

-- Creating View to store data for later visualizations

create view Peoplegetvaccinated AS 
select dea.continent,dea.location, dea.date ,dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint) ) over (Partition	by dea.location order by dea.location,dea.date) 
as Totalpeoplevaccinated
from ['covid deaths$'] dea
join ['covid vaccinations$'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

SELECT * FROM Peoplegetvaccinated
