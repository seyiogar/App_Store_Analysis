
SELECT *
FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

--Check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

-- Check for missing values in key fields 

SELECT count(*) as MissingValues
from AppleStore
where track_name is null  or user_rating is null or prime_genre is null 

SELECT count(*) as MissingValues
from appleStore_description_combined
where app_desc is null 

--Find out the number of apps per genre 

select prime_genre, count(*) as NumApps
from AppleStore
GROUp BY prime_genre
order by NumApps desc

-- Get an overview of the apps ratings

select min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
from AppleStore

**DATA ANALYSIS**

-- Determine whether paid apps have higher ratings than free apps 

SELECT
	CASE
		when price > 0 then 'Paid'
    	else 'Free'
	end as App_Type,
    avg(user_rating) as Avg_Rating 
from AppleStore
GROUP by App_Type
order by Avg_Rating desc

-- Check if apps that support languages have higher ratings 

SELECT	
	CASE
    	when lang_num < 10 then 'lower than 10 languages'
        when lang_num between 10 and 30 then '10-30 languages'
        else 'higher than 20 languages'
    end as language_bracket,
     avg(user_rating) as Avg_Rating 
from AppleStore
group by language_bracket
order by Avg_Rating desc

-- Check the genres with low rating 

select prime_genre,
	   avg(user_rating) as Avg_Rating 
from AppleStore
group by prime_genre
order by Avg_Rating asc

-- Check if there is a correlation between the app description and the user rating 

select
	case 
    	when length(b.app_desc) < 500 then 'short description'
        when length(b.app_desc) between 500 and 1000 then 'medium description' 
        else 'long description'
    end as desc_length_bracket,
    avg(user_rating) as Avg_Rating 
from AppleStore as a
join appleStore_description_combined as b 
on a.id = b.id 
GROUP by desc_length_bracket
order by  Avg_Rating desc 

-- check the top rated apps in each of the app category 

SELECT prime_genre,
	   track_name,
       user_rating
FROM (
  	  SELECT prime_genre,
  			 track_name,
  			 user_rating,
  			 RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating desc, rating_count_tot desc) as rank 
  	  from AppleStore
  	) as a 
WHERE a.rank = 1 
    
    
