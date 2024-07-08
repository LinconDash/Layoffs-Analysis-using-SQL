# Based on the cleaned dataset we will perfrom some EDA techniques to identify some trends and patterns to gain some insights regarding layoffs scenario 
select * from layoffs_cleaned2;

-- Total layoffs in the world yearwise
select year(`date`) as `year`, sum(total_laid_off) as total
from layoffs_cleaned2
where year(`date`) is not null
group by 1
order by 1;

-- The years having min and max layoffs
with years as 
(
	select year(`date`) as `year`, sum(total_laid_off) as total
	from layoffs_cleaned2
	where year(`date`) is not null	
	group by 1
)
select y1.`year` as min_layoffs_year, y2.`year` as max_layoffs_year
from years as y1, years as y2
where y1.total = (select min(total) from years) and y2.total = (select max(total) from years);

-- Top 5 companies that have the highest number of total layoffs
select company, sum(total_laid_off) as total_layoffs
from layoffs_cleaned2
group by company
order by total_layoffs desc
limit 5;
-- Most of the MMANG companies !! 

-- Top 5 companies that have the lowest number of total layoffs
select company, sum(total_laid_off) as total_layoffs
from layoffs_cleaned2
group by company
having total_layoffs >= 0		# I included this because we know we have some nulls in total_laid_off column
order by total_layoffs asc
limit 5;

-- What is the distribution of layoffs by country?
select country, sum(total_laid_off) as total_layoffs
from layoffs_cleaned2
group by country
having total_layoffs >= 0
order by total_layoffs desc;
-- we have United States and India at top !!

-- Now the percentage of world layoffs from each country
with cte as 
(
	select country, sum(total_laid_off) as total_layoffs
	from layoffs_cleaned2
	group by country
	having total_layoffs >= 0
),
cte2 as 
(
	select *, 
    sum(total_layoffs) over() as total
    from cte
)
select country, total_layoffs, round((total_layoffs / total) * 100, 2) as percentage 
from cte2
order by percentage desc;
-- Around 66.87 of the world layoffs is alone from United States

-- Are there any patterns in layoffs based on the company's stage (e.g., Series B, Post-IPO)
select stage, sum(total_laid_off) as total_layoffs
from layoffs_cleaned2
group by stage
having total_layoffs >= 0
order by total_layoffs desc;
-- Post-IPO staged refers to the period after the company has completed its IPO (Initial Public Offering). 
-- During this stage, the company is publicly traded on a stock exchange, and its shares can be bought and sold by investors.
-- So I think to mantain the capital and for cost reduction, they are forced to do layoffs.
-- Hmmm , makes sense right !!

-- Lets see the layoffs across different locations 
with cte as 
( select x.location, x.total_layoffs, 
	sum(x.total_layoffs) over() as total
	from (
			select location, sum(total_laid_off) as total_layoffs
			from layoffs_cleaned2
			group by location
			having total_layoffs >= 0
		) as x
)
select location, total_layoffs, round((total_layoffs / total) * 100, 3) as percentage  
from cte
order by percentage desc;
-- Around 32.74 % of the world layoffs is alone from SF Bay Area 

-- Are there specific months or periods where layoffs were more common?
select 
monthname(`date`) as `month`,
sum(total_laid_off) as total,
count(*) as num_records
from layoffs_cleaned2
where monthname(`date`) is not null
group by monthname(`date`)
order by 2 desc;
-- So we can conclude that the most common month where layoffs happened the most is January 

select substr(`date`, 1, 7) as `month-year`, sum(total_laid_off) as total
from layoffs_cleaned2
where substr(`date`, 1, 7) is not null
group by 1
order by 1 asc;
-- Looks like most of the layoffs happened from 2022-10 to 2023-02

-- How do layoffs differ between companies in the different industry and in different countries?
select company, country, industry, sum(total_laid_off) as total
from layoffs_cleaned2
group by company, country, industry
order by company;

select company, count(distinct industry) as industry_count
from layoffs_cleaned2
group by company
order by 2 desc;

select *
from layoffs_cleaned2
where company = "Bolt";

-- Lets see the same query for same industries and different countries
select industry, country, sum(total_laid_off) as total
from layoffs_cleaned2
group by industry, country
order by industry desc;

-- And which industry contributes to what percent of layoffs around the world
with cte as 
( select x.industry, x.total, sum(x.total) over() as sum_total
	from  
	(
		select industry, sum(total_laid_off) as total
		from layoffs_cleaned2
		group by industry
		order by total desc
	) as x
)
select industry, round((total / sum_total) * 100, 2) as percentage_layoff
from cte;
-- So Consumer and Retail industry has highest amount of layoffs and also it makes sense because these industries have more work force than others

-- What percentage of company worforce they layoff the most (ignoring NULLs) ?
select company, industry, percentage_laid_off, date
from layoffs_cleaned2
group by company, industry, percentage_laid_off, date
having percentage_laid_off >= 0
order by company, industry, percentage_laid_off desc;
-- There are many companies that have laid off thier entire industry (i.e percentage_laid_off = 1)


-- Highest average percent_layoffs industries
select industry, avg(percentage_laid_off) as avg_percent_layoff
from layoffs_cleaned2
group by industry
order by 2 desc;
-- Manufacturing has the lowest and aerospace has the highest

-- Are there any significant differences in the number of layoffs based on the company's funding stage?
with cte as 
(
	select stage, sum(total_laid_off) as total
    from layoffs_cleaned2
    where stage is not null
    group by stage
    order by stage asc
), 
cte2 as (
	select *,
	lag(total, 1) over() as prev_total
	from cte
)
select *, abs(prev_total - total) as difference
from cte2;
-- So, yes there are significant differences of layoffs between company's funding stages 

-- What is the average number of layoffs per company within each industry?
select company, industry, avg(total_laid_off) as avg_layoffs
from layoffs_cleaned2
group by company, industry
order by avg_layoffs desc;

-- Lets see the year-wise layoffs in a company
select 
    company,
    SUM(CASE WHEN YEAR(date) = 2020 THEN total_laid_off ELSE 0 END) AS Layoffs_2020,
    SUM(CASE WHEN YEAR(date) = 2021 THEN total_laid_off ELSE 0 END) AS Layoffs_2021,
    SUM(CASE WHEN YEAR(date) = 2022 THEN total_laid_off ELSE 0 END) AS Layoffs_2022,
    SUM(CASE WHEN YEAR(date) = 2023 THEN total_laid_off ELSE 0 END) AS Layoffs_2023
from layoffs_cleaned2
group by company
order by company desc;
-- Just like a pivot table in Excel

-- How do layoffs vary between companies that are in the same funding stage but in different industries?
select 
    stage,
    industry,
    sum(total_laid_off) AS total_layoffs,
    avg(total_laid_off) AS average_layoffs,
    min(total_laid_off) AS min_layoffs,
    max(total_laid_off) AS max_layoffs,
    count(*) AS num_companies
from layoffs_cleaned2
where total_laid_off is not null and stage is not null
group by stage, industry
order by stage, industry;

# I think this is enough EDA for this dataset , suggest some more qualitative or quantitative questions