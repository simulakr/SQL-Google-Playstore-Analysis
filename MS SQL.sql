--Analyzing App Ratings & Reviews
--Insights from App Categories & Popularity
--Discovering Key Trends in the Google Play Store 

--Overview
SELECT * FROM googleplaystore 


--Data Cleaning & Preparation
--1. NAN Values in rating
SELECT * FROM googleplaystore 
	WHERE  rating LIKE '%[A-Z]%'

SELECT DISTINCT rating FROM googleplaystore 
	WHERE  rating LIKE '%[A-Z]%' --Only NAN 
    
DELETE FROM googleplaystore WHERE rating LIKE '%[A-Z]%' 

-- 2. Make float ratings
ALTER TABLE googleplaystore 
ALTER COLUMN rating DECIMAL(5,2) 

--3. Make int reviews 
SELECT * FROM googleplaystore WHERE reviews LIKE '%[A-Z]%' 
SELECT DISTINCT reviews FROM googleplaystore

UPDATE googleplaystore 
SET reviews= 3000000 
WHERE reviews = '3.0M'

ALTER TABLE googleplaystore 
ALTER COLUMN reviews INT 

--4.Updating installs
SELECT DISTINCT installs FROM googleplaystore --(+'s is problem.)

UPDATE googleplaystore 
set installs = REPLACE(installs,'+', '') 

UPDATE googleplaystore 
set installs = REPLACE(installs,',', '') 

UPDATE googleplaystore 
SET installs = 0 
WHERE installs = 'Free'

ALTER TABLE googleplaystore 
ALTER COLUMN installs bigint 

--5.Duplicated Remove 
--Catching

SELECT *, ROW_NUMBER() OVER(PARTITION BY app ORDER BY APP) AS ROW_NUMBER 
FROM googleplaystore ORDER BY ROW_NUMBER() OVER(PARTITION BY app ORDER BY APP) DESC

--Removing
with cte as (SELECT *, ROW_NUMBER() OVER(PARTITION BY app ORDER BY APP) AS ROW_NUMBER 
FROM googleplaystore) 
DELETE from cte WHERE ROW_NUMBER > 1


-----ANALYSIS----- 

--1.The dataset is filtered to find the total number of app titles containing the term 'Astrology' 
SELECT COUNT(*) FROM googleplaystore 
	WHERE app LIKE '%Astrology%'  --2 
    
--2.The average app ratings 
SELECT AVG(rating) FROM googleplaystore --4.28

--Each app
SELECT app, AVG(rating) AS AVG_RATINGS FROM googleplaystore 
	GROUP BY app 
    ORDER BY 2 DESC 
    
--3.Total number of unique app category 
SELECT COUNT(DISTINCT category) FROM googleplaystore --28 

--4. The app category receiving highest average rating. 
SELECT TOP 1 category, AVG(rating) AS AVG_RATINGS FROM googleplaystore 
GROUP BY category 
ORDER BY 2 DESC

--5.The total number of 5.0 ratigs app 
SELECT COUNT(*) FROM googleplaystore 
	WHERE rating = 5

--6.The average value of reviews is computed, considering a case where reviews are represents in millions
SELECT ROUND(AVG(reviews * 1.0),2) FROM googleplaystore 
	WHERE reviews > 1000000 
    
--7.The total number of free and paid apps is counted. 
SELECT type, COUNT(*) AS NUMBER_OF_TYPE FROM googleplaystore 
GROUP BY type ORDER BY 2 DESC

--8.The app with the maximum number of reviews is identified. 
SELECT TOP 1 app FROM googleplaystore 
ORDER BY reviews DESC 

----9.The top 5 apps with the highest number of reviews are displayed. 
SELECT TOP 5 app, reviews FROM googleplaystore 
ORDER BY reviews DESC


--10.The average rating of free and paid type apps. 
SELECT type, AVG(rating) AS AVG_RATINGS FROM googleplaystore 
GROUP BY type

--11.The top 5 apps with the maximum number of installed are displayed. 
SELECT *, DENSE_RANK() OVER(ORDER BY installs DESC) ROW_N FROM googleplaystore 
ORDER BY installs 

WITH cte as(
  SELECT *, DENSE_RANK() OVER(ORDER BY installs DESC) ROW_N 
  FROM googleplaystore) 
SELECT * from cte WHERE ROW_N < 5 
ORDER by ROW_N DESC
