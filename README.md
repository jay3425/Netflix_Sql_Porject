# Netflix Movies and TV Shows Data Analysis using SQL

![Netflix Logo](https://github.com/jay3425/Netflix_Sql_Porject/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Average duration of movies by rating?

```sql
SELECT rating,
round(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER)),2) AS avg_duration
FROM netflix
WHERE type = 'Movie' AND duration LIKE '%min'
GROUP BY rating
ORDER BY avg_duration DESC;
```

**Objective:** Analyze how movie lengths vary by audience rating.

### 2. Countries produce the most TV Shows vs Movies?

```sql
SELECT country, type, COUNT(*) AS total
FROM netflix
WHERE country IS NOT NULL
GROUP BY country, type
ORDER BY total DESC
LIMIT 10;
```

**Objective:**  Compare content type output by country.

### 3. Directors with the most Netflix content

```sql
SELECT director, COUNT(*) AS total_content
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_content DESC
LIMIT 10;
```

**Objective:** Identify the most prolific directors on the platform.

### 4. Track Netflix content growth over time

```sql
SELECT EXTRACT(YEAR FROM To_date(date_added,'Month DD, YYYY')) AS year,
COUNT(*) AS total
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year
ORDER BY year;
```

**Objective:** Track how content additions evolved over time.

### 5. Top 10 most common genres?

```sql
SELECT genre, COUNT(*) AS total
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre
    FROM netflix
) AS genres
GROUP BY genre
ORDER BY total DESC
LIMIT 10;
```

**Objective:** Discover the most represented genres on Netflix.

### 6. Count the Number of Movies vs TV Shows

```sql
SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 7. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 8. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE
    type = 'Movie'
    AND
    release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 9. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 10. Identify the Longest Movie

```sql
SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration LIKE '%min'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 11. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - interval '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 12. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE 
director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 13. List All TV Shows with More Than 5 Seasons

```sql
SELECT * FROM netflix WHERE type = 'TV Show' AND
CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) >5;
-- OR
SELECT *
FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1)::numeric >5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 14. Count the Number of Content Items in Each Genre

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ','))AS genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 15. Find the average number of content releases in India on Netflix each year. 
Return the top 5 years with the highest average content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 16. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 17. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 18. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 19. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS total_count
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 20. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Jay dengle

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join me

- **GMail**: [Email Me!](https://www.jaydengle2005@gmail.com)
- **Instagram**: [Follow me]()
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/jay-anil-dengle-049952337/)

Thank you, and I look forward to connecting with you!

