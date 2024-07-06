-- We have a layoffs dataset with us so lets import that using the "Table Data Import Wizard" option from database

select * from layoffs;

-- Now the data has some columns like 

show columns from layoffs;

-- We can see some columns are not formatted such as 
-- 1. percentage_laid_off : Should be in DECIMAL / FLOAT but it is in TEXT
-- 2. date : Supposed to be in DATE format but is in TEXT format 

-- Process of Data Cleaning :
-- 1. Remove Duplicates
-- 2. Standardize the data 
-- 3. Handling Null / Blank values 
-- 4. Remove Irrelevant Columns / Rows  

# Now its a good practice not to modify the raw data / original data and save it as backup, so better make a copy of it and store it in another table.

create table layoffs_cleaned
like layoffs;

insert into layoffs_cleaned 
select * from layoffs; 

-- The copied data 
select * from layoffs_cleaned;


### 1. Removing Duplicates ###
-- Check if there are duplicates or not, which basically can be done by checking every column values in different rows and assigning a id to each row
-- We will use a window function in this step called row_number()
select *,
row_number() over(
	partition by company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions) as id
from layoffs_cleaned;

-- Now check the data with id > 1 because those will be duplicates
with duplicate_data as 
(
	select *,
	row_number() over(
	partition by company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions) as id
	from layoffs_cleaned
)
select * 
from duplicate_data
where id > 1;

-- Lets verify the result
select *
from layoffs_cleaned
where company = "Yahoo";

-- So, the cte is working fine !

-- Now we need to remove those duplicates from the layoffs_cleaned table , but how to do that ?
-- Simply create another table and use the id to delete the duplicate rows
create table layoffs_cleaned2
like layoffs_cleaned;

alter table layoffs_cleaned2
add column row_num int;

show columns from layoffs_cleaned2;

insert into layoffs_cleaned2
select *,
	row_number() over(
	partition by company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions) as id
from layoffs_cleaned;

select * from layoffs_cleaned2;

delete from layoffs_cleaned2
where row_num > 1;

select * from layoffs_cleaned2
where row_num > 1;

select * from layoffs_cleaned2;

-- Now we can also truncate the data in layoffs_cleaned and insert the data from layoffs_cleaned2 , but thats just redundant work 
-- We will do everything with layoffs_cleaned2 from here on.
-- Now our data is duplicate free, so we can move to the next step 

### 2. Standardize the data  ###
-- Lets have a look at each column of the availiable data

# Company column 
-- See if the text in the company column starts or ends with white spaces
select distinct company 
from layoffs_cleaned2
where company like " %" or company like "% ";

-- Since we have whitespaces, we can remove the spaces from the data  
select company, trim(company) as company_trimed
from layoffs_cleaned2;

update layoffs_cleaned2
set company = trim(company);

select *
from layoffs_cleaned2;

# Location column 
select distinct location
from layoffs_cleaned2
order by location;

-- Lets see if location column has some anomalies
select distinct location
from layoffs_cleaned2
where location like " %" or "% ";

-- Lets see if they have some unrecognized special characters
select distinct location 
from layoffs_cleaned2
where location regexp '[^a-zA-Z0-9 ]';

-- So I found some locations that have unrecognized special characters like these
/* 
MalmÃ¶
DÃ¼sseldorf
FlorianÃ³polis
*/

-- After searching through internet, I found that these were some other decoded language and not utf-8
-- So I replaced each of them using multiple replace functions
select distinct location, 
replace(replace(replace(replace(location, 'Ã¶', 'ö'), 'Ã¼', 'ü'), 'Ã³', 'ó'), 'Ã©', 'é') AS corrected_name
from layoffs_cleaned2
where location regexp '[^a-zA-Z0-9 ]';

update layoffs_cleaned2
set location = replace(replace(replace(replace(location, 'Ã¶', 'ö'), 'Ã¼', 'ü'), 'Ã³', 'ó'), 'Ã©', 'é')
where location regexp '[^a-zA-Z0-9 ]';

-- Now checkout the result 
select distinct location 
from layoffs_cleaned2
where location regexp '[^a-zA-Z0-9 ]';

select * from layoffs_cleaned2;

# Industry column 
-- See the anomalies in industry column
select distinct industry
from layoffs_cleaned2
order by industry;

-- So I can see null and blank in industries but we will handle them in the third step 
-- One more anomaly or say mistake is dividng Crypto into 3 separate industry like Crypto, Crypto Currency, CryptoCurrency
-- which I believe should be one single industry.
-- Also Fin-tech and Finance are different so, I would like them as it is.
 
select distinct industry
from layoffs_cleaned2
where industry like "Crypto%";

update layoffs_cleaned2
set industry = "Crypto Currency"
where industry like "Crypto%";

select * from layoffs_cleaned2;

# total_laid_off column
-- Lets check if this column has some anomalies
select distinct total_laid_off
from layoffs_cleaned2;

-- check the datatype of the column
show columns from layoffs_cleaned2;

-- So I think its fine, lets move to next column

# percentage_laid_off column
-- Lets check for any mistakes here
select distinct percentage_laid_off 
from layoffs_cleaned2;

-- check the datatype of the column
show columns from layoffs_cleaned2 where field = 'percentage_laid_off';
-- Its text formatted but percentages are usually decimal or float formatted , so lets format it to float type

alter table layoffs_cleaned2
modify column percentage_laid_off float;

show columns from layoffs_cleaned2 where field = 'percentage_laid_off';

-- Moving to next column

# date column
-- Lets check the datatype first 
show columns from layoffs_cleaned2 where field = 'date';

-- Its also text formatted, lets change it to date format
-- But first change the structure of it to a possible format for date
select `date` , str_to_date(`date`, "%m/%d/%Y")
from layoffs_cleaned2;

-- First structure the date 
update layoffs_cleaned2
set `date` = str_to_date(`date`, "%m/%d/%Y");

-- Then change the datatype from text to date
alter table layoffs_cleaned2
modify `date` date;

select * 
from layoffs_cleaned2;

show columns from layoffs_cleaned2 where field = 'date';
-- Perfecto !!

# Country column
select distinct country
from layoffs_cleaned2
order by country;

-- Only one mistake, there is United States and United States. so remove the trailing dot and its fixed 
update layoffs_cleaned2
set country = trim(trailing '.' from country);

### 3. Handling Null / Blank values ###
-- Lets see the null in some relevant columns like total_laid_off , percentage_laid_off and funds_raised_millions
select *
from layoffs_cleaned2
where total_laid_off is null and percentage_laid_off is null and funds_raised_millions is null;
-- Honestly, this chunk of data is a waste for us since there is nothing quantitative information to look for.
-- We can also delete these rows as its of no use.
delete from layoffs_cleaned2
where total_laid_off is null and percentage_laid_off is null and funds_raised_millions is null;

-- Also we have some rows like these where funds_raised_millions is there but 
-- still the main data part is missing , so I will delete this too
select count(*) as row_counts
from layoffs_cleaned2
where total_laid_off is null and percentage_laid_off is null;

delete from layoffs_cleaned2
where total_laid_off is null and percentage_laid_off is null;

select count(*) as row_counts
from layoffs_cleaned2
where total_laid_off is null and percentage_laid_off is null;
-- Nice !!

-- Now remember we have some nulls / blanks in industries
select *
from layoffs_cleaned2
where industry is null or industry = '';

-- Nulls / Blanks are same so make it same in the data
update layoffs_cleaned2
set industry = null
where industry = '';

-- We should be able to populate these if we have some records for those same company with the same location
select *
from layoffs_cleaned2 as t1 
inner join layoffs_cleaned2 as t2
on  t1.company = t2.company and 
	t1.location = t2.location
where t1.industry is null and t2.industry is not null;

-- So we have some records that can be updates as thier industry is present in different records
update layoffs_cleaned2 as t1 
inner join layoffs_cleaned2 as t2
on  t1.company = t2.company and 
	t1.location = t2.location
set t1.industry = t2.industry
where t1.industry is null  and t2.industry is not null;

select *
from layoffs_cleaned2
where industry is null;
-- Now we have only one row for it , but I believe not to delete this because we have some quantitative info. here

select * from layoffs_cleaned2;

-- Okay now we have to drop a column
alter table layoffs_cleaned2
drop column row_num;

select * from layoffs_cleaned2;

-- This is the finalised cleaned data !!
-- Now export it to any new csv file using the Table data export wizard !!