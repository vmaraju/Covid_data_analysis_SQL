Select * 
From covid19
Where Continent is not null
Order by 3,4;

Select Location, data, total_cases, new_cases, total_deaths, Poplulation
From covid19
Order by 1,2;

-- Total Cases vs Total Deaths
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From covid19
Order by 1,2;

-- Shows Likelihood of dying if you contract Covid in the US
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From covid19
Where location like '%states%'
Order by 1,2;

-- looking at population vs total cases
-- shows infection rate
Select Location, Date, Population, total_cases (total_cases/Population)*100 as infection_rate
From covid19
Where location like '%states%'
Order by 1,2;

-- Looking at Countries with highest Infection Rate Compared to Population
Select Location, Date, Population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as highest_infection_rate 
From covid19
Group by location, population
Order by highest_infection_rate DESC;

-- Showing highest death rate per population
Select location, MAX(total_deaths) AS total_death_count
From covid19
Where continent is not null
Group by location
Order by total_death_count DESC;

-- Death Rate Broken down by continent
Select location, MAX(total_deaths) AS total_death_count
From covid19
Where continent is null
Group by location
Order by total_death_count DESC;

-- Global Numbers
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as global_death_rate
From covid19
Where continent is not null
Group by date
Order by 1,2;

-- Looking at total population vs vaccination
Select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccination
From covid19 cd
join covidvaccinations vac
on cd.location=vac.location
and cd.date = vac.date
Where cd.continent is not null
order by 2,3;

Select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccination, 
sum(vac.new_vaccination) Over (Partition by cd.location Order by cd.location, cd.date) as rolling_count_vax
From covid19 cd
join covidvaccinations vac
on cd.location=vac.location
and cd.date = vac.date
Where cd.continent is not null
order by 2,3;

-- Using CTE
with pop_vs_vac (continent, location, date, population, new_vaccination, rolling_count_vax)
AS
(
Select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccination, 
sum(vac.new_vaccination) Over (Partition by cd.location Order by cd.location, cd.date) as rolling_count_vax
From covid19 cd
join covidvaccinations vac
on cd.location=vac.location
and cd.date = vac.date
Where cd.continent is not null
)
select *, (rolling_count_vax/population)*100
from pop_vs_vac;

-- Create view to store data for later visualization
Create View pop_vax as 
Select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccination, 
sum(vac.new_vaccination) Over (Partition by cd.location Order by cd.location, cd.date) as rolling_count_vax
From covid19 cd
join covidvaccinations vac
on cd.location=vac.location
and cd.date = vac.date
Where cd.continent is not null;