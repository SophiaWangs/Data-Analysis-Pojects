CREATE TABLE yelp.business AS
SELECT * 
FROM yelp.yelp_business
WHERE state IS NOT NULL AND city IS NOT NULL;


CREATE TABLE yelp.business_hours AS
SELECT *
FROM yelp.yelp_business_hours
WHERE business_id IS NOT NULL;

SELECT *
FROM yelp.yelp_checkin
WHERE business_id IS NULL OR weekday IS NULL OR hour IS NULL OR checkins IS NULL OR checkins < 0;

SELECT *
FROM yelp.yelp_review
WHERE user_id IS NULL or business_id IS NULL or date IS NULL or stars < 0 or stars > 5;

SELECT *
FROM yelp.yelp_tip
WHERE text IS NULL or date IS NULL or likes < 0 or business_ID IS NULL or user_id IS NULL;

SELECT *
FROM yelp.yelp_user
WHERE user_id IS NULL or review_count < 0 or yelping_since IS NULL or average_stars <0;

SELECT max(yelping_since) 
FROM yelp.yelp_user;


SELECT user_id,
ROUND(review_count/registration,2) AS avg_review
FROM 
(SELECT user_id,
review_count,
DATEDIFF('2017-12-21',yelping_since) AS registration
FROM yelp.yelp_user) a;

CREATE TABLE yelp.avg_days_review AS
SELECT user_id,
CASE WHEN review_count = 0 THEN registration ELSE ROUND(registration/review_count,0) END AS avg_days
FROM 
(SELECT user_id,
review_count,
DATEDIFF('2017-12-21',yelping_since) AS registration
FROM yelp.yelp_user) a;

CREATE TABLE yelp.average_review_month AS
SELECT user_id,
CASE WHEN registration = 0 THEN review_count ELSE ROUND(review_count/registration,2) END AS avg_review
FROM 
(SELECT user_id,
review_count,
TIMESTAMPDIFF(MONTH,yelping_since,'2017-12-21') AS registration
FROM yelp.yelp_user) a;

SELECT ROUND(SUM(CASE WHEN useful > 0 OR funny > 0 OR cool > 0 THEN 1 ELSE 0 END) / COUNT(*) ,2) AS percentage
FROM yelp.yelp_review;

SELECT ROUND(SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END)/COUNT(*),2) AS pos_prop
FROM yelp.yelp_review
WHERE useful > 0;

SELECT ROUND(SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END)/COUNT(*),2) AS pos_prop
FROM yelp.yelp_review
WHERE funny > 0;

SELECT ROUND(SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END)/COUNT(*),2) AS pos_prop
FROM yelp.yelp_review
WHERE cool > 0;

CREATE TABLE yelp.length_and_compliments
SELECT review_id,
length(text) AS length,
useful + funny + cool AS total_comp;


SELECT ROUND(AVG(stars),2) AS average_rating
FROM yelp.yelp_review;

SELECT ROUND(AVG(average_stars),2) AS averaqe_rating
FROM yelp.yelp_user;

CREATE TABLE yelp.days_and_fans AS
SELECT user_id,
DATEDIFF('2017-12-21',yelping_since) AS registration,
fans
FROM yelp.yelp_user;

CREATE TABLE yelp.total_comps_and_fans
SELECT user_id,
fans,
useful + funny + cool AS total_comps
FROM yelp.yelp_user;

SELECT user_id,
fans,
friends
FROM yelp.yelp_user
WHERE friends != 'None';


SELECT b.city,
COUNT(review_id) AS num_rating
FROM
yelp.yelp_review r
JOIN
yelp.business b
ON r.business_id = b.business_id
GROUP BY b.city
ORDER BY num_rating DESC;

SELECT ROUND(COUNT(*) / (SELECT COUNT(*)FROM yelp.yelp_user),2)
FROM yelp.yelp_user
WHERE fans > 0;

CREATE TABLE yelp.elite AS
SELECT *
FROM yelp.yelp_user
WHERE elite != 'None';

CREATE TABLE yelp.not_elite AS 
SELECT *
FROM yelp.yelp_user
WHERE elite = 'None';



WITH CTE1 AS (SELECT ROUND(SUM(review_count)/SUM(registration),2) AS avg_reviews_per_month
FROM
(SELECT review_count,
TIMESTAMPDIFF(month,yelping_since,'2017-12-21') AS registration
FROM yelp.elite)a),

CTE2 AS (SELECT ROUND(SUM(review_count)/SUM(registration),2) AS avg_reviews_per_month
FROM
(SELECT review_count,
TIMESTAMPDIFF(month,yelping_since,'2017-12-21') AS registration
FROM yelp.not_elite)a)


SELECT 'elite',
avg_reviews_per_month
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_reviews_per_month
FROM CTE2;

WITH CTE1 AS(SELECT ROUND(AVG(DATEDIFF('2017-12-21',yelping_since)),0) AS avg_reg
FROM yelp.elite),

CTE2 AS(SELECT ROUND(AVG(DATEDIFF('2017-12-21',yelping_since)),0) AS avg_reg
FROM yelp.not_elite)

SELECT 'elite',
avg_reg
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_reg
FROM CTE2;


WITH CTE1 AS (SELECT ROUND(AVG(friends),2) AS avg_friends
FROM yelp.elite),

CTE2 AS (SELECT ROUND(AVG(friends),2) AS avg_friends
FROM yelp.not_elite)

SELECT 'elite' AS label,
avg_friends
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_friends
FROM CTE2;

WITH CTE1 AS (SELECT ROUND(AVG(useful+funny+cool),2) AS account_comp
FROM yelp.elite),

CTE2 AS (SELECT ROUND(AVG(useful+funny+cool),2) AS account_comp
FROM yelp.not_elite)

SELECT 'elite' AS label,
account_comp
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
account_comp
FROM CTE2;

WITH CTE1 AS (SELECT ROUND(AVG(fans),2) AS avg_fans
FROM yelp.elite),

CTE2 AS (SELECT ROUND(AVG(fans),2) AS avg_fans
FROM yelp.not_elite)

SELECT 'elite' AS label,
avg_fans
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_fans
FROM CTE2;

WITH CTE1 AS (SELECT ROUND(AVG(compliment_hot+compliment_more+compliment_cute+compliment_plain+compliment_cool+compliment_funny),2) AS avg_comp
FROM yelp.elite),

CTE2 AS (SELECT ROUND(AVG(compliment_hot+compliment_more+compliment_cute+compliment_plain+compliment_cool+compliment_funny),2) AS avg_comp
FROM yelp.not_elite)

SELECT 'elite' AS label,
avg_comp
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_comp
FROM CTE2;

WITH CTE1 AS (SELECT ROUND(AVG(compliment_photos),2) AS avg_photo
FROM yelp.elite),

CTE2 AS (SELECT ROUND(AVG(compliment_photos),2) AS avg_photo
FROM yelp.not_elite)

SELECT 'elite' AS label,
avg_photo
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_photo
FROM CTE2;

SELECT stars,
COUNT(*) AS num
FROM yelp.business
GROUP BY stars
ORDER BY stars DESC;

SELECT ROUND(AVG(stars),2) AS avg_star
FROM yelp.business;

SELECT b.stars,
ROUND(AVG(r.stars),1) AS avg_rating
FROM yelp.business b
JOIN
yelp.yelp_review r
ON b.business_id = r.business_id
GROUP BY b.stars
ORDER BY b.stars DESC;


SELECT stars,
SUM(review_count) AS total_review
FROM yelp.business
GROUP BY stars
ORDER BY total_review DESC;

CREATE TABLE yelp.stars_and_ratio
SELECT stars,
good_rating,
bad_rating,
ROUND(good_rating/bad_rating,2) AS ratio
FROM
(SELECT b.stars,
SUM(CASE WHEN r.stars >= 4 THEN 1 ELSE 0 END) AS good_rating,
SUM(CASE WHEN r.stars<=2 THEN 1 ELSE 0 END) AS bad_rating
FROM yelp.business b
JOIN
yelp.yelp_review r
ON b.business_id = r.business_id
GROUP BY b.stars
ORDER BY b.stars DESC)a;

CREATE TABLE yelp.state_num_retaurants
SELECT state,
COUNT(*) AS num_restaurants
FROM yelp.business
GROUP BY state
ORDER BY num_restaurants DESC;

CREATE TABLE yelp.state_five_star
SELECT
state,
ROUND(SUM(CASE WHEN stars = 5 THEN 1 ELSE 0 END)*100 / COUNT(*),2) AS five_star_percentage
FROM yelp.business
GROUP BY state
ORDER BY five_star_percentage DESC;

CREATE TABLE yelp.state_good_review
SELECT b.state,
ROUND(SUM(CASE WHEN r.stars >= 4 THEN 1 ELSE 0 END)*100 / COUNT(review_id),2) AS good_review_percentage
FROM yelp.business b
JOIN yelp.yelp_review r
ON b.business_id = r.business_id
GROUP BY b.state
ORDER BY good_review_percentage DESC;

CREATE TABLE yelp.stars_and_days_open
WITH CTE AS (SELECT business_id, 
mon + tue + wed + thur + fri + sat + sun AS days_open
FROM
(SELECT business_id,
CASE WHEN monday != 'None' THEN 1 ELSE 0 END AS mon,
CASE WHEN tuesday!= 'None' THEN 1 ELSE 0 END AS tue,
CASE WHEN wednesday!= 'None' THEN 1 ELSE 0 END AS wed,
CASE WHEN thursday!= 'None' THEN 1 ELSE 0 END AS thur,
CASE WHEN friday!= 'None' THEN 1 ELSE 0 END AS fri,
CASE WHEN saturday!= 'None' THEN 1 ELSE 0 END AS sat,
CASE WHEN sunday!= 'None' THEN 1 ELSE 0 END AS sun
FROM yelp.business_hours)a)

SELECT b.business_id,
b.stars,
CTE.days_open
FROM yelp.business b
JOIN CTE
ON b.business_id = CTE.business_id
WHERE days_open > 0;


WITH CTE AS (SELECT business_id, 
mon + tue + wed + thur + fri + sat + sun AS days_open
FROM
(SELECT business_id,
CASE WHEN monday != 'None' THEN 1 ELSE 0 END AS mon,
CASE WHEN tuesday!= 'None' THEN 1 ELSE 0 END AS tue,
CASE WHEN wednesday!= 'None' THEN 1 ELSE 0 END AS wed,
CASE WHEN thursday!= 'None' THEN 1 ELSE 0 END AS thur,
CASE WHEN friday!= 'None' THEN 1 ELSE 0 END AS fri,
CASE WHEN saturday!= 'None' THEN 1 ELSE 0 END AS sat,
CASE WHEN sunday!= 'None' THEN 1 ELSE 0 END AS sun
FROM yelp.business_hours)a)

SELECT is_open,
ROUND(SUM(days_open)/COUNT(*),2) AS avg_days_open
FROM yelp.business b
JOIN CTE
ON b.business_id = CTE.business_id
GROUP BY is_open;



SELECT is_open,
ROUND(SUM(CASE WHEN r.stars <= 2 THEN 1 ELSE 0 END)/COUNT(*),2) AS bad
FROM yelp.business b
JOIN yelp.yelp_review r
ON b.business_id = r.business_id
GROUP BY is_open;

CREATE TABLE yelp.user_registration_monthly
SELECT reg_year,
reg_month,
COUNT(*) AS num_registration 
FROM
(SELECT user_id,
year(yelping_since) AS reg_year,
month(yelping_since) AS reg_month
FROM yelp.yelp_user)a
GROUP BY reg_year, reg_month
ORDER BY reg_year,reg_month;

CREATE TABLE yelp.monthly_review
SELECT year(date) AS review_year,
month(date) AS review_month,
COUNT(*) AS num_review
FROM yelp.yelp_review
GROUP BY review_year,review_month;

CREATE TABLE yelp.annual_retention AS
WITH CTE AS(SELECT user_id,
year(date) AS year_review
FROM yelp.yelp_review
GROUP BY user_id, year_review)

SELECT c1.year_review,
ROUND(COUNT(c2.year_review)/COUNT(*),2) AS retention
FROM CTE c1
LEFT JOIN CTE c2
ON c1.user_id = c2.user_id AND c2.year_review - 1 = c1.year_review
GROUP BY c1.year_review
ORDER BY c1.year_review;

CREATE TABLE yelp.MAU AS
SELECT year_review,
month_review,
COUNT(DISTINCT user_id) AS num_user
FROM
(SELECT user_id,
year(date) AS year_review,
month(date) AS month_review
FROM yelp.yelp_review)a
GROUP BY year_review, month_review
ORDER BY year_review, month_review;

WITH CTE1 AS(SELECT reg_year,
SUM(num) OVER (ORDER BY reg_year) AS total_user
FROM
(SELECT reg_year,
COUNT(*) AS num
FROM
(SELECT user_id,
year(yelping_since) AS reg_year
FROM yelp.yelp_user)a
GROUP BY reg_year
ORDER BY reg_year)b),

CTE2 AS(SELECT 2008 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2008%'
UNION ALL
SELECT 2009 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2009%'
UNION ALL
SELECT 2010 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2010%'
UNION ALL
SELECT 2011 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2011%'
UNION ALL
SELECT 2012 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2012%'
UNION ALL
SELECT 2013 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2013%'
UNION ALL
SELECT 2014 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2014%'
UNION ALL
SELECT 2015 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2015%'
UNION ALL
SELECT 2016 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2016%'
UNION ALL
SELECT 2017 AS year,
COUNT(*) AS num_elite
FROM yelp.elite
WHERE elite LIKE '%2017%')

SELECT CTE2.year,
CTE2.num_elite*100/ CTE1.total_user AS elite_percent
FROM CTE1
JOIN CTE2
ON CTE1.reg_year = CTE2.year;

SELECT 2008 as year,
SUM(CASE WHEN elite LIKE '%2008%' AND  elite LIKE '%2009%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2008%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2009 as year,
SUM(CASE WHEN elite LIKE '%2009%' AND  elite LIKE '%2010%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2009%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2010 as year,
SUM(CASE WHEN elite LIKE '%2010%' AND  elite LIKE '%2011%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2010%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2011 as year,
SUM(CASE WHEN elite LIKE '%2011%' AND  elite LIKE '%2012%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2011%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2012 as year,
SUM(CASE WHEN elite LIKE '%2012%' AND  elite LIKE '%2013%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2012%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2013 as year,
SUM(CASE WHEN elite LIKE '%2013%' AND  elite LIKE '%2014%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2013%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2014 as year,
SUM(CASE WHEN elite LIKE '%2014%' AND  elite LIKE '%2015%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2014%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2015 as year,
SUM(CASE WHEN elite LIKE '%2015%' AND  elite LIKE '%2016%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2015%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite
UNION ALL
SELECT 2016 as year,
SUM(CASE WHEN elite LIKE '%2016%' AND  elite LIKE '%2017%' THEN 1 ELSE 0 END)/SUM(CASE WHEN elite LIKE '%2016%' THEN 1 ELSE 0 END) AS retention
FROM yelp.elite;


SELECT MAX(date)
FROM yelp.yelp_review;