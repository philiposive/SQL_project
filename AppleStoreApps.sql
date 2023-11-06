create table appleStore_description_combined AS

select * from appleStore_description1

UNION ALL

select * from appleStore_description2

Union ALL

Select * from appleStore_description3

Union ALL

select * from appleStore_description4

--check the number of unique apps in both tables
select count(distinct id) as UniqueAppIDs
from AppleStore

select count(distinct id) as UniqueAppIDs
from appleStore_description_combined

--check for any missing values in key fields of AppleStore
select count(*) as MissingValues
from AppleStore
where track_name is null or user_rating is null or prime_genre is null

--check for any missing values in key fields of appleStore_description_combined
select count(*) as MissingValues
from appleStore_description_combined
where app_desc is null

--find out the number of apps per genre
select prime_genre, count(*) as NumApps
from AppleStore
group by prime_genre
order by NumApps DESC

--get an overview of app's ratings
select min(user_rating) as MinRating,
	   max(user_rating) as Maxrating,
       avg(user_rating) as AvgRating
from AppleStore

**Data Analysis**

--determine whether paid apps have higher ratings than free apps
select Case
		when price > 0 then 'paid'
        else 'free'
        end as App_Type,
        avg(user_rating) as Avg_Rating
From AppleStore
group by App_Type

--determine whether apps that support more languages have higher ratings
select CASE
		when lang_num < 10 then '<10 languages'
        when lang_num between 10 and 30 then '10-30 languages'
        else '>30 languages'
        end as language_bucket,
        avg(user_rating) as Avg_Rating
From AppleStore
group by language_bucket
order by Avg_Rating DESC

--check genres with low ratings
select prime_genre,
	   avg(user_rating) as Avg_Rating
from AppleStore
Group By prime_genre
order by Avg_Rating ASC
Limit 10

--check if there is correlation between the length of the app description and the user rating
SELECT CASE
	when length(b.app_desc) < 500 then 'short'
    when length(b.app_desc) between 500 and 1000 then 'medium'
    else 'long'
    end as description_length_bucket,
    avg(A.user_rating) as average_rating
from
AppleStore A
join
appleStore_description_combined B
on A.id = B.id
group by description_length_bucket
order by average_rating DESC

--check the top-rated apps for each genre
select
	prime_genre,
    track_name,
    user_rating
from (select prime_genre,
      		 track_name,
             user_rating,
             rank() over(partition by prime_genre order by user_rating DESC, rating_count_tot DESC)
      as rank
      from AppleStore) as A
where A.rank = 1