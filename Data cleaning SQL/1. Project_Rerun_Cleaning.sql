-- cleaning data

select * 
from layoffs;

-- 1. make second copy data
-- 2. make row table
-- 3. delete duplicate
-- 4. delete anomalies
-- 5. change date data set and format
-- 6. detect nulls, fill first, then if no delete
-- 7. delete the row_num and finish



-- 1. make second copy data

select * 
from layoffs;

create table ly_0
like layoffs;

select *
from ly_0;

insert into ly_0
select *
from layoffs
;
-- finish



-- 2. make row table
CREATE TABLE `ly_1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from ly_1;

with cte_0 as
(select *, ROW_NUMBER() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions)
as row_num
from ly_0
)
select *
from cte_0;

insert into ly_1
select *, ROW_NUMBER() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions)
as row_num
from ly_0;

select *
from ly_1;
-- finish




-- 3. delete duplicate
select *
from ly_1
where row_num > 1;

delete
from ly_1
where row_num > 1;




-- 4. delete anomalies
-- 4.0 detection of .
select * 
from ly_1;

select distinct country
from ly_1
where trim(country) like '.%' or trim(country) like '%.';

-- updating to right one
update ly_1
set country = trim(trailing '.' from country)
where country like 'United States%'
;
-- finishing 



-- 4.1 detection of ' '
select *
from ly_1;

select distinct company
from ly_1
where company like ' %' or '% ';

-- updating to right one
update ly_1
set company = trim(company);

select company
from ly_1;
-- finishing



-- 4.2 detection of typo or not same format
select distinct industry
from ly_1
order by 1;

update ly_1
set industry = 'Crypto'
where industry like 'Crypto%';




-- 5. change date data set and format
select `date`ly_1
from ly_1;

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from ly_1;

update ly_1
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table ly_1
MODIFY COLUMN `date` date;

select `date`
from ly_1;



-- 6. detect nulls, fill first, then if no delete
select *
from ly_1
where industry is null or industry like '';

select distinct l1.company, l1.industry
from ly_1 as l1
join ly_1 as l2
	on l1.company = l2.company
where (l1.industry is null or l1.industry like '')
and l2.industry is null or l2.industry like '';

-- make ' ' into nulls

update ly_1
set industry = null
where industry = '';

select distinct l1.company, l1.industry, l2.company, l2.industry
from ly_1 as l1
join ly_1 as l2
	on l1.company = l2.company
where l1.industry is null
and l2.industry is not null;

update ly_1 as l1
join ly_1 as l2
	on l1.company = l2.company
set l1.industry = l2.industry
where l1.industry is null
and l2.industry is not null;

select *
from ly_1
where industry is null;
-- finish 


-- 6.1 deleting data is no no, except if you already made copy data and you certain enough that its useless

select *
from ly_1
where total_laid_off is NULL and percentage_laid_off is null;

delete
from ly_1
where total_laid_off is NULL 
and percentage_laid_off is null;
-- finish 




-- 7. delete the row_num and finish
alter table ly_1
drop column row_num;

select *
from ly_1;

