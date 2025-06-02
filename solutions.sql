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

SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


-- 7.Find the most comman rating for movies and TV shows

SELECT
	type,
	rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(*) AS count_rating,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) AS t1
WHERE 
	ranking = 1; 
	

-- 8. List all movies released in specific year (e.g., 2020)

-- filter 2020
-- movies
select * from netflix
where
	type = 'Movie'	
	AND
	release_year = 2020;


-- 9. Find the top 5 countries with the most content on netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 10.Identify the longest movie?

SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration LIKE '%min'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;

-- 11.Find content added in the last 5 years	

SELECT *
FROM netflix
WHERE
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - interval '5 years';


-- 12.Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE 
director ILIKE '%Rajiv Chilaka%';


-- 13.List all TV shows with more than 5 seasons

SELECT * FROM netflix WHERE type = 'TV Show' AND
CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) >5;
-- OR
SELECT *
FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1)::numeric >5;


-- 14.Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ','))AS genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1;


-- 15.Find each year and the average numbers of content release in India on netflix.
-- 	return top 5 year with highest avg content release!

select 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%') * 100
	,2)AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;



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
release_year > (extract(year from current_date) - 10);



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

WITH new_table
AS(
SELECT * ,
CASE 
WHEN 
	description ILIKE '%kill%' 
	OR
	description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE 'Good_content'
END category
FROM netflix
)
SELECT category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;

	
	