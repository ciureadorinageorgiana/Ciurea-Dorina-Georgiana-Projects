Select *
From ProjectPortfolio..[Covid Deaths]
Where continent is not null
Order by 3, 4

--Select *
--From ProjectPortfolio..[Covid Vaccinations]
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..[Covid Deaths]
order by 1, 2


--Total Cases vs Population (what percentage of population got covid)
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..[Covid Deaths]
Where Location like '%romania%'
and continent is not null
order by 1, 2

--Countries with Highest Infection Rate compared with Population
Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)) * 100 as PercentPopulationInfected
From ProjectPortfolio..[Covid Deaths]
Group by Location, population
Order by PercentPopulationInfected desc

--Dividing by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..[Covid Deaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Continents with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..[Covid Deaths]
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From ProjectPortfolio..[Covid Deaths]
Where continent is not null
order by 1, 2

-- Total Population Vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
From ProjectPortfolio..[Covid Deaths] dea
Join ProjectPortfolio..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

--Using CTE

With PopvsVacc (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
From ProjectPortfolio..[Covid Deaths] dea
Join ProjectPortfolio..[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVacc



--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..[Covid Deaths] dea
Join ProjectPortfolio..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..[Covid Deaths] dea
Join ProjectPortfolio..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


