SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death
 FROM PortfolioProject.dbo.Covid_Deaths  
order by 1,2;

alter TABLE dbo.Covid_Deaths
alter column population float;

-- total cases vs population

SELECT location, date, total_cases,population, (total_deaths/population)*100 as Death
 FROM PortfolioProject.dbo.Covid_Deaths  
order by 1,2;

--Global numbers death percentage of total cases
select SUM(new_cases) as total_cases,  SUM(new_deaths) as total_deaths, sum(new_deaths)/sum(cast(new_cases as float))*100 as deathPercentage
from Covid_Deaths
where continent is not null;


-- countries with higest infection rate
    SELECT location,population,  max(total_cases) as higestInfctionCount, max((total_deaths/population))*100 as populationInfacted
    FROM PortfolioProject.dbo.Covid_Deaths   where continent is not null
    group by [location], population
    order by populationInfacted desc;

-- continents with highest death count per population

select [location], MAX(cast (total_deaths as int)) as TotalDeathCount from dbo.Covid_Deaths
where continent is NULL
group by [location]
order by TotalDeathCount desc ; 

-- countries with total vaccination vs population

ALTER TABLE dbo.covidVaccination
alter column new_vaccinations INT;

select cd.continent, cd.[location], cd.[date], cd.population, cv.new_vaccinations,
 SUM(cv.new_vaccinations) over ( PARTITION BY cd.location order by cd.LOCATION, cd.DATE ) as RollingPeopleVaccinated
from Covid_Deaths  as CD JOIN
CovidVaccination as CV 
on CD.[location]= CV.[location] AND
cd.[date] = cv.[date]
WHERE cd.continent is not NULL and new_vaccinations is not null
ORDER by cd.[location],cd.[date];

-- USE CTE

with PopVsVac (continent, [location], [date], population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.[location], cd.[date], cd.population, cv.new_vaccinations,
 SUM(cv.new_vaccinations) over ( PARTITION BY cd.location order by cd.LOCATION, cd.DATE ) as RollingPeopleVaccinated
from Covid_Deaths  as CD JOIN
CovidVaccination as CV 
on CD.[location]= CV.[location] AND
cd.[date] = cv.[date]
WHERE cd.continent is not NULL
--ORDER by cd.[location],cd.[date]
)
select * , (RollingPeopleVaccinated/population)*100
from PopVsVac;

-- Temp Table

Drop table if exists #percentPopulationVaccinated
create table  #percentPopulationVaccinated

(
    continent nvarchar(200),
    location NVARCHAR (200),
    Date DATETIME,
    population numeric,
    New_Vaccinations numeric,
    RollingPeopleVaccinated numeric

)

insert into #percentPopulationVaccinated

select cd.continent, cd.[location], cd.[date], cd.population, cv.new_vaccinations,
 SUM(cv.new_vaccinations) over ( PARTITION BY cd.location order by cd.LOCATION, cd.DATE ) as RollingPeopleVaccinated
from Covid_Deaths  as CD JOIN
CovidVaccination as CV 
on CD.[location]= CV.[location] AND
cd.[date] = cv.[date]
WHERE cd.continent is not NULL
--ORDER by cd.[location],cd.[date]

select * , (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated;

--creating View to store data for later visualizatons

create view percentPopulationVaccinated 
as
select cd.continent, cd.[location], cd.[date], cd.population, cv.new_vaccinations,
 SUM(cv.new_vaccinations) over ( PARTITION BY cd.location order by cd.LOCATION, cd.DATE ) as RollingPeopleVaccinated
from Covid_Deaths  as CD JOIN
CovidVaccination as CV 
on CD.[location]= CV.[location] AND
cd.[date] = cv.[date]
WHERE cd.continent is not NULL
--ORDER by cd.[location],cd.[date] 

select * from percentPopulationVaccinated;

