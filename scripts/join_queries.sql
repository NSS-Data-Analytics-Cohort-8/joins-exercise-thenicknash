-- ** Movie Database project. See the file movies_erd for table\column info. **

-- Exploratory data discovery queries:
select * from distributors;
select * from rating;
select * from revenue;
select * from specs;

-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.

select
	specs.film_title as name,
	specs.release_year,
	revenue.worldwide_gross
from specs
inner join revenue
on specs.movie_id = revenue.movie_id
order by revenue.worldwide_gross
limit 1;

-- Semi-Tough, 1977, $37,187,139

-- 2. What year has the highest average imdb rating?

select
	specs.release_year,
	avg(rating.imdb_rating) as avg_yearly_rating
from specs
inner join rating
on specs.movie_id = rating.movie_id
group by specs.release_year
order by avg_yearly_rating desc
limit 1;

-- 1991 had the highest average imdb rating.

-- 3. What is the highest grossing G-rated movie? Which company distributed it?

select
	specs.film_title as name,
	revenue.worldwide_gross,
	distributors.company_name
from specs
inner join revenue
on specs.movie_id = revenue.movie_id
inner join distributors
on specs.domestic_distributor_id = distributors.distributor_id
where specs.mpaa_rating = 'G'
order by revenue.worldwide_gross desc
limit 1;

-- The highest grossing G-rated movie is Toy Story 4. Walt Disney distributed it.

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies 
-- table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

select
	d.company_name,
	count(s.*) as number_of_movies
from distributors as d
left join specs as s
on d.distributor_id = s.domestic_distributor_id
group by d.company_name
order by d.company_name;

-- 5. Write a query that returns the five distributors with the highest average movie budget.

select
	d.company_name,
	round(avg(r.film_budget), 2) as avg_movie_budget
from distributors as d
inner join specs as s
on d.distributor_id = s.domestic_distributor_id
inner join revenue as r
on s.movie_id = r.movie_id
group by d.company_name
order by avg_movie_budget desc
limit 5;

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

select
	s.film_title
from distributors as d
inner join specs as s
on d.distributor_id = s.domestic_distributor_id
where lower(d.headquarters) not like '%ca%'
order by s.film_title;

-- Only 1 movie in the dataset has a distributor whose HQ is not in CA. My Big Fat Greek Wedding by default has the highest imdb rating.

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

select (
	select round(avg(r.imdb_rating), 2)
	from specs as s
	inner join rating as r
	on s.movie_id = r.movie_id
	where s.length_in_min <= 120
) as avg_under_2_hour_movie_rating,
(
	select round(avg(r.imdb_rating), 2)
	from specs as s
	inner join rating as r
	on s.movie_id = r.movie_id
	where s.length_in_min > 120
) as avg_over_2_hour_movie_rating;

-- Over 2 hour movies have a .34 edge over under 2 hour movies


-- Amanda Questions

-- 1.	Find the total worldwide gross and average imdb rating by decade. Then alter your query so it returns JUST the second highest average imdb rating and its decade. This should result in a table with just one row.

select
	v_decade_ratings.decade,
	avg(v_decade_ratings.avg_rating) as avg_decade_rating
from (
	select 
		case
			when s.release_year between 1970 and 1979
			then '1970s'
			when s.release_year between 1980 and 1989
			then '1980s'
			when s.release_year between 1990 and 1999
			then '1990s'
			when s.release_year between 2000 and 2009
			then '2000s'
			when s.release_year between 2010 and 2019
			then '2010s'
		end as decade,
		re.worldwide_gross,
		avg(r.imdb_rating) as avg_rating
	from specs as s
	inner join rating as r
	on s.movie_id = r.movie_id
	inner join revenue as re
	on s.movie_id = re.movie_id
	group by s.release_year, re.worldwide_gross
	order by avg_rating desc
) as v_decade_ratings
group by v_decade_ratings.decade
order by avg_decade_rating desc
limit 1 offset 1;


-- 2.	Our goal in this question is to compare the worldwide gross for movies compared to their sequels. 
-- a.	Start by finding all movies whose titles end with a space and then the number 2.
-- b.	For each of these movies, create a new column showing the original film’s name by removing the last two characters of the film title. For example, for the film “Cars 2”, the original title would be “Cars”. Hint: You may find the string functions listed in Table 9-10 of https://www.postgresql.org/docs/current/functions-string.html to be helpful for this. 
-- c.	Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. Modify your query to fix these issues. 
-- d.	Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a self-join on the specs table in order to get the movie_id values for both the original films and their sequels. Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. Incorporate this into your query to ensure that you are matching as many sequels as possible.

select *
from specs
where film_title like '% 2';

alter table specs add column prequel_film_title text;

update specs set prequel_film_title = split_part(film_title, ' 2', -1)

-- 3.	Sometimes movie series can be found by looking for titles that contain a colon. For example, Transformers: Dark of the Moon is part of the Transformers series of films.
-- 
-- a.	Write a query which, for each film will extract the portion of the film name that occurs before the colon. For example, “Transformers: Dark of the Moon” should result in “Transformers”.  If the film title does not contain a colon, it should return the full film name. For example, “Transformers” should result in “Transformers”. Your query should return two columns, the film_title and the extracted value in a column named series. Hint: You may find the split_part function useful for this task.
-- b.	Keep only rows which actually belong to a series. Your results should not include “Shark Tale” but should include both “Transformers” and “Transformers: Dark of the Moon”. Hint: to accomplish this task, you could use a WHERE clause which checks whether the film title either contains a colon or is in the list of series values for films that do contain a colon.
-- c.	Which film series contains the most installments?
-- d.	Which film series has the highest average imdb rating? Which has the lowest average imdb rating?
-- 
-- 4.	How many film titles contain the word “the” either upper or lowercase? How many contain it twice? three times? four times? Hint: Look at the sting functions and operators here: https://www.postgresql.org/docs/current/functions-string.html 
-- 
-- 5.	For each distributor, find its highest rated movie. Report the company name, the film title, and the imdb rating. Hint: you may find the LATERAL keyword useful for this question. This keyword allows you to join two or more tables together and to reference columns provided by preceding FROM items in later items. See this article for examples of lateral joins in postgres: https://www.cybertec-postgresql.com/en/understanding-lateral-joins-in-postgresql/ 
-- 
-- 6.	Follow-up: Another way to answer 5 is to use DISTINCT ON so that your query returns only one row per company. You can read about DISTINCT ON on this page: https://www.postgresql.org/docs/current/sql-select.html. 
-- 
-- 7.	Which distributors had movies in the dataset that were released in consecutive years? For example, Orion Pictures released Dances with Wolves in 1990 and The Silence of the Lambs in 1991. Hint: Join the specs table to itself and think carefully about what you want to join ON. 
