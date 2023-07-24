select *
from dbo.CovidDeaths
order by 3,4

--select *
--from dbo.CovidVaccinations
--order by 3,4


--select data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths
order by 1,2



--Looking at total cases vs total deaths in US
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from dbo.CovidDeaths
where location like '%states%'
order by 1,2




--Total cases vs Population
--Shows percentage of population affected by covid
select location,date,total_cases,population,(total_cases/population)*100 as percentage_affected
from dbo.CovidDeaths
where location like '%states%'
order by 1,2




--Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highest_infection_count,max(total_cases/population)*100 as percentage_affected
from dbo.CovidDeaths
group by location,population
order by percentage_affected desc	




--Showing continents with highest death count per population
select continent,max(cast(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by total_death_count desc




--Death percentage per day globally
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2




--Total cases and death percentage
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2



--Joining covid deaths and covid vaccinations table
--Looking at total population vs vaccinations
select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations
from dbo.CovidDeaths deaths
join dbo.CovidVaccinations vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2,3



--Use CTE
with pop_vac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,sum(convert(int,vaccinations.new_vaccinations)) 
over (partition by deaths.location order by deaths.location,deaths.date) as rolling_people_vaccinated
from dbo.CovidDeaths deaths
join dbo.CovidVaccinations vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
--order by 2,3
)
select *,(rolling_people_vaccinated/population)*100
from pop_vac



--temp table
drop table if exists percent_population_vaccinated
create table percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into percent_population_vaccinated
select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,sum(convert(int,vaccinations.new_vaccinations)) 
over (partition by deaths.location order by deaths.location,deaths.date) as rolling_people_vaccinated
from dbo.CovidDeaths deaths
join dbo.CovidVaccinations vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
--where deaths.continent is not null
--order by 2,3
select *,(rolling_people_vaccinated/population)*100 as percentage_rolling_people_vaccinated
from percent_population_vaccinated



--create view to store data for reporting
create view percentage_vaccinated as
select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,sum(convert(int,vaccinations.new_vaccinations)) 
over (partition by deaths.location order by deaths.location,deaths.date) as rolling_people_vaccinated
from dbo.CovidDeaths deaths
join dbo.CovidVaccinations vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null

select *
from percentage_vaccinated
