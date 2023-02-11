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

-- 5. Write a query that returns the five distributors with the highest average movie budget.

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?