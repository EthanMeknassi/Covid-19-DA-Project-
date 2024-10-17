

-- Covid-19 Project --

select * from CovidDeaths where continent is not null order by 3,4

select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths order by 1, 2

-- Total cases vs Total deaths, displaying the likelihood of dying if Covid was contracted in your country:

select location, date, total_cases, total_deaths, (convert(float,total_deaths)/nullif(convert(float, total_cases),0)) * 100 [Death rate after contracting] 
from CovidDeaths 
where location = 'France' or location = 'South Africa' 
order by 1, 2 

-- Total cases vs Population:

select location, date, population, total_cases, (convert(float,total_cases)/nullif(convert(float, population),0)) * 100 [Percentage infected in country] 
from CovidDeaths 
where location = 'France' or location = 'South Africa' 
order by 1, 2 

-- Countries with highest infection rate compared to population:

select location, population, max(total_cases) [Highest Infection Count], MAX(convert(float,total_cases)/nullif(convert(float, population),0)) * 100 [Percentage infected in country] 
from CovidDeaths 
group by Location, Population
order by [Percentage infected in country] desc

-- Countries with highest death rate compared to population:

select Location, max(total_deaths) [Total death count] 
from CovidDeaths 
where continent is not null
group by Location
order by [Total death count] desc

-- Continents with highest death rate compared to population:

select Location, max(total_deaths) [Total death count] 
from CovidDeaths 
where continent is null
group by location
order by [Total death count] desc

-- Global numbers:

select sum(new_cases) as [Total cases], sum(new_deaths) [Total deaths], sum(cast(new_deaths as float))/sum(New_Cases)*100 as [Death Percentage]
from CovidDeaths
where continent is not null 
order by 1,2

-- Total population vs vaccinations in France and South Africa

select d.continent, d.location, d.date, population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location, d.date) [Total Vaccinations]
from CovidDeaths d join CovidVax v 
on d.location = v.location and d.date = v.date
where d.continent is not null and d.location = 'France' and d.location = 'South Africa'
order by 2, 3 

-- Using a CTE to get the percentage of the population vaccinated in France and South Africa:

with CTE (Continent, Location, Date, Population, New_Vaccinations,  [Total Vaccinations]) 
as (
select d.continent, d.location, d.date, population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location, d.date) [Total Vaccinations]
from CovidDeaths d join CovidVax v 
on d.location = v.location and d.date = v.date
where d.continent is not null
) 

select *, (convert(float,[Total Vaccinations])/convert(float, population)) *100 [Percentage of the population vaccinated] from CTE where location = 'France' or location = 'South Africa'

-- Using a temp table to get percentage of the population vaccinated:

drop table if exists #Percentage_population_vaccinated
create table #Percentage_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)

insert into #Percentage_population_vaccinated 
select d.continent, d.location, d.date, population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location, d.date) [Total Vaccinations]
from CovidDeaths d join CovidVax v 
on d.location = v.location and d.date = v.date
where d.continent is not null

select *, (total_vaccinations/population) *100 [Percentage of the population vaccinated] from #Percentage_population_vaccinated where location = 'France'

-- Creating views to store data for vizualisation:

create view Percentage_population_vaccinated as 
select d.continent, d.location, d.date, population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location, d.date) [Total Vaccinations]
from CovidDeaths d join CovidVax v 
on d.location = v.location and d.date = v.date
where d.continent is not null

