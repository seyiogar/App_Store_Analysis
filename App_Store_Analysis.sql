** DATA CLEANING AND PREPARATION **

SELECT *
FROM AppleStore

-- Drop irrelevant Columns 

ALTER TABLE AppleStore 
DROP sup_devices_num, ipadSc_urls_num, vpp_lic

-- Check for missing values in key fields 

SELECT COUNT(*) as MissingValues
FROM AppleStore
WHERE track_name is null  or user_rating is null or prime_genre is null 

SELECT COUNT(*) as MissingValues
FROM appleStore_description
WHERE app_desc is null 

-- Replacing the missing values 

UPDATE appleStore_description
SET app_desc = 'No Description'
WHERE app_desc is null 


**DATA ANALYSIS**

--Check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM appleStore_description

--Find out the number of apps per genre 

SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER by NumApps desc

-- Get an overview of the apps ratings

SELECT min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore

-- Determine whether paid apps have higher ratings than free apps 

SELECT(
	CASE
		WHEN price > 0 THEN 'Paid'
    	ELSE 'Free'
	END) as App_Type,
    avg(user_rating) as Avg_Rating 
FROM AppleStore
GROUP BY 
(
	CASE
		WHEN price > 0 THEN 'Paid'
    	ELSE 'Free'
	END
)
ORDER BY Avg_Rating desc

-- Check if apps that support languages have higher ratings 

SELECT(	
	CASE
    	WHEN lang_num < 10 THEN 'lower than 10 languages'
        WHEN lang_num between 10 and 30 THEN '10-30 languages'
        ELSE 'higher than 20 languages'
    END) as language_bracket,
     avg(user_rating) as Avg_Rating 
FROM AppleStore
GROUP BY 
(	
	CASE
    	WHEN lang_num < 10 THEN 'lower than 10 languages'
        WHEN lang_num between 10 and 30 THEN '10-30 languages'
        ELSE 'higher than 20 languages'
    END
)
ORDER BY Avg_Rating desc

-- Check the genres with low rating 

SELECT prime_genre,
	   avg(user_rating) as Avg_Rating 
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating asc

-- Check the genres with high downloads

SELECT prime_genre,
	   avg(rating_count_tot) as Avg_Downloads,
       avg(user_rating) as Avg_Rating 
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Downloads  DESC

-- Check if there is a correlation between the app description and the user rating 

SELECT(
	CASE 
    	WHEN len(b.app_desc) < 500 THEN 'short description'
        WHEN len(b.app_desc) between 500 and 1000 THEN 'medium description' 
        ELSE 'long description'
    END) as desc_length_bracket,
    avg(user_rating) as Avg_Rating 
FROM AppleStore as a
JOIN appleStore_description as b 
ON a.id = b.id 
GROUP BY 
(
	CASE 
    	WHEN len(b.app_desc) < 500 THEN 'short description'
        WHEN len(b.app_desc) between 500 and 1000 THEN 'medium description' 
        ELSE 'long description'
    END
)
ORDER BY  Avg_Rating desc 

-- check if number of downloads affects app ratings

SELECT (
	CASE
    	WHEN rating_count_tot >= 2000000 THEN 'High'
        WHEN rating_count_tot BETWEEN 1000000 AND 2000000 THEN 'Medium'
        ELSE 'Low'
    END) as download_bracket,
    avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY
(
	CASE
    	WHEN rating_count_tot >= 2000000 THEN 'High'
        WHEN rating_count_tot BETWEEN 1000000 AND 2000000 THEN 'Medium'
        ELSE 'Low'
    END
)
ORDER BY Avg_Rating desc

-- Check the apps with the top revenues 

SELECT track_name,
	   sum(rating_count_tot * price) as revenue
FROM AppleStore
GROUP BY track_name
ORDER BY revenue desc

-- Check the app genres with the top revenues 

SELECT prime_genre,
	   sum(rating_count_tot * price) as revenue
FROM AppleStore
GROUP BY prime_genre
ORDER BY revenue desc

-- check the top rated apps in each of the app genre 

SELECT prime_genre,
	   track_name,
       user_rating
FROM (
  	  SELECT prime_genre,
  			 track_name,
  			 user_rating,
  			 RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating desc, rating_count_tot desc) as rank 
  	  FROM AppleStore
  	) as a 
WHERE a.rank = 1 
    
