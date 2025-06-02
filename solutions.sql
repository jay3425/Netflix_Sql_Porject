-- Netflix Project\
drop table if exists netflix;
CREATE TABLE netflix
(
	show_id      VARCHAR(6),
	type         VARCHAR(10),
	title        VARCHAR(150),
	director     VARCHAR(208),
	casts         VARCHAR(1000),
	country      VARCHAR(150),
	date_added   VARCHAR(50),
	release_year INT,
	rating       VARCHAR(10),
	duration     VARCHAR(15),
	listed_in    VARCHAR(100), 
	description  VARCHAR(250)
);
select * from netflix;
select count(*) as total_content from netflix;
select distinct type from netflix;

-- 20 Business Problems

-- 1. What is the average duration of movies by rating?

SELECT rating,
round(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER)),2) AS avg_duration
FROM netflix
WHERE type = 'Movie' AND duration LIKE '%min'
GROUP BY rating
ORDER BY avg_duration DESC;

-- 2. Which countries produce the most TV Shows vs Movies?

SELECT country, type, COUNT(*) AS total
FROM netflix
WHERE country IS NOT NULL
GROUP BY country, type
ORDER BY total DESC
LIMIT 10;


-- 3. Find directors with the most Netflix content

SELECT director, COUNT(*) AS total_content
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_content DESC
LIMIT 10;



-- 4. Track Netflix content growth over time

SELECT EXTRACT(YEAR FROM To_date(date_added,'Month DD, YYYY')) AS year,
COUNT(*) AS total
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year
ORDER BY year;


-- 5. What are the top 10 most common genres?

SELECT genre, COUNT(*) AS total
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre
    FROM netflix
) AS genres
GROUP BY genre
ORDER BY total DESC
LIMIT 10;


-- 6. Count the number of Movies vs TV Shows

select
	type,
	count(*) as total_content
From netflix
GROUP BY type


-- 7.Find the most comman rating for movies and TV shows

select 
	type,
	rating
from
(
	select 
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) DESC) as ranking
	from netflix
	group by 1,2
) as t1
where 
	ranking =1 
	

-- 8. List all movies released in specific year (e.g., 2020)

-- filter 2020
-- movies
select * from netflix
where
	type = 'Movie'	
	AND
	release_year = 2020


-- 9. Find the top 5 countries with the most content on netflix

select
	unnest(string_to_array(country,',')) as new_country,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

-- 10.Identify the longest movie?

SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration LIKE '%min'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;

-- 11.Find content added in the last 5 years	

select *
from netflix
where
	To_date(date_added,'Month DD, YYYY') >= current_date - interval '5 years'


-- 12.Find all the movies/TV shows by director 'Rajiv Chilaka'!

select *
from netflix
where 
director ilike '%Rajiv Chilaka%'


-- 13.List all TV shows with more than 5 seasons

select * from netflix where type = 'TV Show' and
CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) >5
-- OR
select *
from netflix
where
	type = 'TV Show'
	and
	split_part(duration,' ',1)::numeric >5


-- 14.Count the number of content items in each genre

select
	unnest(STRING_TO_ARRAY(listed_in, ','))as genre,
	count(show_id)
from netflix
group by 1


-- 15.Find each year and the average numbers of content release in India on netflix.
-- 	return top 5 year with highest avg content release!

select 
	extract(year from TO_DATE(date_added,'Month DD, YYYY')) as year,
	count(*) as yearly_content,
	round(
	count(*)::numeric/(select count(*) from netflix where country ilike '%India%') * 100
	,2)as avg_content_per_year
from netflix
where country ilike '%India%'
group by 1
order by 3 desc
limit 5;



-- 16. List All Movies that are Documentaries

select * from netflix where listed_in ilike '%Documentaries%'


-- 17. Find All Content Without a Director

select * from netflix where 
director is null


-- 18. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select * from netflix
where
casts ilike '%Salman Khan%'	
and
release_year > (extract(year from current_date) - 10)



-- 19. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select
unnest(string_to_array(casts, ',')) as actors,
count(*) as total_count
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10


-- 20. Categorize Content Based on the Presence of 'Kill' and 'Violence'
	-- in description field. Label content containig these keywords as Bad and all other
	-- content as 'good'. Count how many items fall into each category.

with new_table
as(
select * ,
case 
when 
	description ilike '%kill%' 
	or
	description ilike '%violence%' then 'Bad_Content'
	else 'Good_content'
end category
from netflix
)
select category,
	count(*) as total_content
from new_table
group by 1

	
	