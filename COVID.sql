SELECT * FROM portfolioproject.`covidvaccinations_i.xlsx`
order by 3,4;

SELECT * FROM coviddeaths_i;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths_i
order by 1, 2;

-- looking at total cases vs total deaths --
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,1) as DeathPercentage
from coviddeaths_i
where continent is not null;

-- showing countries with highest death count per population --
select location, max(cast(total_deaths as unsigned)) as totaldeaths, population
from coviddeaths_i
where continent is not null
group by location
order by totaldeaths desc;

-- highest deaths by continent version 1 --
select location, max(cast(total_deaths as unsigned)) as totaldeaths, population
from coviddeaths_i
where continent is null
group by location
order by totaldeaths desc;


-- highest deaths by continent version 2 (has error, i guess) --
select continent, location, max(cast(total_deaths as unsigned)) as totaldeaths
from coviddeaths_i
where continent is not null
group by continent
order by totaldeaths desc;

-- Total population vs vaccinations using WITH AS --
WITH PopvsVac(Continent, Location, Date, population, New_vaccinations, Rolling_vaccinations) 
AS(
select coviddeaths_i.continent, coviddeaths_i.location, CAST(coviddeaths_i.date AS DATE) AS Date, 
		coviddeaths_i.population, covidvaccinations_i.new_vaccinations, SUM(CAST(new_vaccinations AS unsigned)) 
        OVER(PARTITION by coviddeaths_i.location order by coviddeaths_i.location, coviddeaths_i.date) AS rolling_vaccinations 
       -- (rolling_vaccinations/coviddeaths_i.population)*100 AS Rolling_percent
from coviddeaths_i
join covidvaccinations_i on coviddeaths_i.location= covidvaccinations_i.location
						 AND coviddeaths_i.date= covidvaccinations_i.date
WHERE coviddeaths_i.continent is not null AND new_vaccinations is not null
-- ORDER BY Date --
)
select *,(rolling_vaccinations/population)*100 AS Rolling_percent FROM PopvsVac
ORDER BY location, Date;

-- Total population vs vaccinations BY creating table --
DROP TABLE IF EXISTS RollingVaccinationsTable;
CREATE TABLE RollingVaccinationsTable
(
cotinent varchar(255),
location varchar(255),
date date,
population numeric,
New_vaccinations numeric,
Rolling_vaccinations numeric
);
Insert into RollingVaccinationsTable

select coviddeaths_i.continent, coviddeaths_i.location, (coviddeaths_i.date), 
		coviddeaths_i.population, covidvaccinations_i.new_vaccinations, SUM(CAST(new_vaccinations AS unsigned)) 
        OVER(PARTITION by coviddeaths_i.location order by coviddeaths_i.location, coviddeaths_i.date) AS rolling_vaccinations 
       -- (rolling_vaccinations/coviddeaths_i.population)*100 AS Rolling_percent
from coviddeaths_i
join covidvaccinations_i on coviddeaths_i.location= covidvaccinations_i.location
						 AND coviddeaths_i.date= covidvaccinations_i.date
WHERE coviddeaths_i.continent is not null AND new_vaccinations is not null;
-- ORDER BY Date --

select *,(rolling_vaccinations/population)*100 AS Rolling_percent FROM RollingVaccinationsTable
ORDER BY location, Date;

-- CREATE VIEW TO STORE DATA FOR LATER--
DROP TABLE if exists RollingVaccinationsTable; 
CREATE VIEW RollingVaccinationsTable 
AS
select coviddeaths_i.continent, coviddeaths_i.location, (coviddeaths_i.date), coviddeaths_i.population, 
		covidvaccinations_i.new_vaccinations, SUM(CAST(new_vaccinations AS unsigned)) OVER(PARTITION by 
		coviddeaths_i.location order by coviddeaths_i.location, coviddeaths_i.date) AS rolling_vaccinations 
from coviddeaths_i
join covidvaccinations_i on coviddeaths_i.location= covidvaccinations_i.location
						 AND coviddeaths_i.date= covidvaccinations_i.date
WHERE coviddeaths_i.continent is not null AND new_vaccinations is not null;

select *,(rolling_vaccinations/population)*100 AS Rolling_percent FROM RollingVaccinationsTable
ORDER BY location, Date;