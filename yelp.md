# Yelp Data Analysis Project

### Introduction:

The objective of this project is to conduct an analysis of Yelp's data to draw conclusions about three dimensions: the customer dimension, the business dimension, and the platform dimension. Yelp is an online platform that enables users to read and write reviews of local businesses, including restaurants, cafes, and shops. Analyzing Yelp's data can provide valuable insights into factors that influence user engagement, restaurant performance, and the overall growth of the platform.

The customer dimension examines the factors that contribute to a user's attainment of elite status on the Yelp platform, including the number of reviews written per month, the number of compliments received, and the number of fans accumulated. The business dimension focuses on the factors that affect a restaurant's star rating, such as the ratio of good ratings to bad ratings and the opening status of the restaurant. Lastly, the platform dimension analyzes trends in user registration, reviews, monthly active users, and retention rate.

By gaining a comprehensive understanding of the factors that impact user engagement and restaurant performance, Yelp can improve the quality of its content and user experience, as well as maintain its competitive position in the online review space.

### Data:

#### data cleaning:

The first step in any data analysis project is to ensure that the data is clean and accurate. In this section, the yelp dataset underwent a rigorous data cleaning process to ensure the quality and accuracy of the data. Null or abnormal values were identified in each dataset using SQL queries, and any records containing such values were removed to ensure that the dataset was clean and suitable for analysis. 

yelp_business Dateset:

```sql
SELECT * 
FROM yelp.yelp_business
WHERE name IS NULL or state IS NULL or stars < 0 or stars > 5;
```

There is one result in which the `state` value was null. To remove this result from the dataset:

```sql
CREATE TABLE yelp.business AS
SELECT * 
FROM yelp.yelp_business
WHERE state IS NOT NULL;
```

yelp_business_hours Dataset:

```sql
SELECT *
FROM yelp.yelp_business_hours
WHERE business_id IS NULL;
```

There is one result in which the `business_id` value was null. To remove this result from the dataset:

```sql
CREATE TABLE yelp.business_hours AS
SELECT *
FROM yelp.yelp_business_hours
WHERE business_id IS NOT NULL;
```

yelp_checkin Dataset:

```sql
SELECT *
FROM yelp.yelp_checkin
WHERE business_id IS NULL OR weekday IS NULL OR hour IS NULL OR checkins IS NULL OR checkins<0;
```

There is not any null or abnormal value found in this dataset, so no changes were made.

yelp_review Dataset:

```sql
SELECT *
FROM yelp.yelp_review
WHERE user_id IS NULL or business_id IS NULL or date IS NULL or stars < 0 or stars > 5;
```

There is not any null or abnormal value found in this dataset, so no changes were made.

yelp_tip Dataset:

```sql
SELECT *
FROM yelp.yelp_tip
WHERE text IS NULL or date IS NULL or likes < 0 or business_ID IS NULL or user_id IS NULL;
```

There is not any null or abnormal value found in this dataset, so no changes were made.

yelp_user Dataset:

```sql
SELECT *
FROM yelp.yelp_user
WHERE user_id IS NULL or review_count < 0 or yelping_since IS NULL or average_stars <0;
```

There is not any null or abnormal value found in this dataset, so no changes were made.

Specifically, records with null values in the "name" and "state" fields of the yelp_business dataset and null values in the "business_id" field of the yelp_business_hours and yelp_checkin datasets were removed. After this initial cleaning, a final check was conducted for null or abnormal values in the remaining datasets, yelp_review, yelp_tip, and yelp_user. No further cleaning was required, resulting in a clean and high-quality dataset for further analysis.

### Customer Dimension：

##### 1. Average days take to leave reviews

To find the average number of days it takes for a user to leave a review:

```sql
SELECT max(yelping_since) 
FROM yelp.yelp_user;

SELECT SUM(registration)/SUM(review_count)
FROM
(SELECT user_id,
review_count,
DATEDIFF('2017-12-21',yelping_since) AS registration
FROM yelp.yelp_user) a;
```

on average, customers take around 202 days to leave one review. However, there is a considerable variation in this behavior.

```sql
CREATE TABLE yelp.avg_days_review AS
SELECT user_id,
CASE WHEN review_count = 0 THEN registration ELSE ROUND(registration/review_count,0) END AS avg_days
FROM 
(SELECT user_id,
review_count,
DATEDIFF('2017-12-21',yelping_since) AS registration
FROM yelp.yelp_user) a;
```

Approximately 3% of customers leave a review within 0-30 days, which indicates that they eat out at least once a month, and the chance they leave reviews when they eat out is high. 5.79% of customers take 30- 60 days to take a review, indicating that they may eat out less frequently, but still have a high chance of leaving reviews. 

30.74% of customers  take 60-180 days to leave a review. These customers may eat out less often, but still have a moderate chance of leaving reviews.

Furthermore, around 24% of customers take 180-360 days to leave a review,This suggests that customers who take longer to leave reviews may be less likely to leave reviews in general, or may only leave reviews for exceptional experiences.

As we move to the longer timeframes, the number of customers leaving reviews decreases, with only a small percentage taking more than one year to review. This may indicate that they are less likely to leave a review or may not dine out frequently, or they have lost interest in the platform.  

Therefore, businesses should focus on providing excellent service to incentivize customers to leave reviews, especially those who dine out more frequently. Additionally, encouraging customers to leave reviews within every 60 days may help improve the overall review rate and provide a more accurate representation of the restaurant's performance (see Figure 1).

![image-20230404162006435](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230404162006435.png)

​                                                               Figure 1 - Average days taken for customers to leave one review 



##### 2. Analysis of comments that are considered userful, funny and cool

The percentage of comments that are considered userful, funny or cool:

```sql
SELECT ROUND(SUM(CASE WHEN useful > 0 OR funny > 0 OR cool > 0 THEN 1 ELSE 0 END)/COUNT(*) ,2) AS percentage
FROM yelp.yelp_review;
```

With 54% of the reviews being considered useful, funny or cool, this suggests that users are engaging with the reviews and finding them to be informative, entertaining, or both. 

The percentage of positive rating (4 stars or higher) of comments are considered useful:

```sql
SELECT ROUND(SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END)/COUNT(*),2) AS pos_prop
FROM yelp.yelp_review
WHERE useful > 0;
```

The percentage of positive rating (4 stars or higher) of comments are considered useful is 61%, indicating that the majority of comments that are perceived as useful are positive reviews. It implies that customers may be more likely to find a review useful if it reflects a positive experience. 

The percentage of positive rating (4 stars or higher) of comments are considered funny:

```sql
SELECT ROUND(SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END)/COUNT(*),2) AS pos_prop
FROM yelp.yelp_review
WHERE funny > 0;
```

The percentage of positive rating (4 stars or higher) of comments considered funny is 55%, indicating that this type of comment may be a good indicator of customer satisfaction. However, it is important to note that a significant proportion of funny comments may still be associated with negative experiences. It is possible that some users leave humorous reviews that are critical of the restaurant, which other users may find amusing. Therefore, while a review may be considered funny, it does not necessarily imply a positive sentiment towards the restaurant.

The percentage of positive rating (4 stars or higher) of comments are considered cool:

```sql
SELECT ROUND(SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END)/COUNT(*),2) AS pos_prop
FROM yelp.yelp_review
WHERE cool > 0;
```

The high percentage of positive ratings (72%) for comments that are considered cool may be attributed to various factors, such as the mention of unique features or experiences that the restaurant offers, as well as positive interactions with the staff or other customers. Customers may also find the ambiance, decor, or overall atmosphere of the restaurant to be appealing and cool, leading to positive comments. Furthermore, it is possible that customers who have already had a positive experience with the restaurant are more likely to find cool aspects in their visit and leave a positive comment.

The relationship between review length and useful, funny or cool comments:

```sql
CREATE TABLE yelp.length_and_compliments
SELECT review_id,
length(text) AS length,
useful + funny + cool AS total_comp
FROM yelp.yelp_review;
```

Shorter reviews within 100 characters receive a minimal percentage of total compliments. This suggests that these reviews may not contain sufficient information to be considered useful, funny, or cool. Within the 400-character limit, reviews that are longer tend to receive more compliments.

reviews with 300-400 characters appear to receive the most compliments, implying that customers tend to find moderate-length reviews more informative and engaging. Reviews that exceed 400 characters in length tend to receive fewer compliments as their length increases. This may be because longer reviews may become overly detailed, losing the reader's attention, or contain unnecessary information that detracts from their usefulness. Therefore, it's important to encourage customers to leave reviews that are concise and informative, providing enough helpful details without becoming too lengthy and tedious to read (See Figure 2).



![image-20230327002506086](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230327002506086.png)

​                                                  Figure 2 - Percent of total compliments different lengths of reviews get



Taking into account the ratio of total compliments to the number of reviewshile reviews with 100-200 characters had the most number of reviews, reviews with 300-400 characters received the most compliments. However, when considering the ratio of compliments to the number of reviews, it is observed that longer reviews have a higher ratio of compliments, even if they have thousands of characters. Therefore, businesses may want to encourage customers to leave longer, more detailed reviews, as they are more likely to receive higher levels of positive feedback. However, it is crucial to strike a balance between review length and content quality (See Figure 3). 

![image-20230327155722093](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230327155722093.png)

​                                                 Figure 3 - Compliment to count ratio of diffrent lengths of reviews



##### 3. Average rating scores

Average rating of all reviews:

```sql
SELECT ROUND(AVG(stars),2) AS average_rating
FROM yelp.yelp_review;
```

Average rating of each individual users:

```sql
SELECT ROUND(AVG(average_stars),2) AS averaqe_rating
FROM yelp.yelp_user;
```

The average rating of all the reviews in the dataset is 3.73. However, when considering the average rating of each individual user who provided reviews, it is 3.6. This indicates that there may be some variation in the rating preferences of different users, and that businesses should take this into account when analyzing their overall ratings.

42.83% of the reviews were rated 4-5 stars, indicating that a significant number of users have rated the product or service positively with 4-5 stars. However, most users give ratings of 3-4 stars, with 4-5 stars being the second least common. This suggests that although a significant proportion of the reviews are positive, a majority of users tend to give moderate ratings and may be more critital in their assessments (See Figure 4).

![Screen Shot 2023-03-27 at 7.36.15 PM](/Users/siyuanwang/Desktop/Screen Shot 2023-03-27 at 7.36.15 PM.png)

​                                         Figure 4 - Comparison between rating distribution under each review and each customer



##### 4. Factors that affect number of followers

There is no significant correlation between the number of reviews and the number of followers. In other words, having a large number of followers does not necessarily result in more reviews or vice versa (See Figure 5).

![image-20230327195830337](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230327195830337.png)

​                                                                             Figure 5 - Review count and number of fans



There are some cases where more days of yelping are associated with more followers, but there is no clear positive relationship between the two. This suggests that the length of time a user has been on Yelp may not necessarily be a strong predictor of the number of followers they have (See Figure 6). 



![image-20230327201003624](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230327201003624.png)

​                                                                             Figure 6 - days of yelping and number of fans



There is no clear relationship between the number of followers a user has and the number of useful, funny, or cool compliments they receive. There are cases where users with many followers receive a high number of compliments, but there are also cases where users with many followers receive few or even no compliments (See Figure 7).



![image-20230327202133735](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230327202133735.png)

​                                                                   Figure 7 - compliments received and number of fans



```sql
SELECT COUNT(*) / (SELECT COUNT(*) FROM yelp.yelp_user) 
FROM yelp.yelp_user
WHERE fans > 0;
```

Only 6% of users have a fan count greater than 0. This could indicate that many users on Yelp do not have an intention to follow others originally, or they may simply not be using the platform in a way that emphasizes building a follower base. Additionally, there could be other factors at play that influence a user's decision to follow others, such as the quality of their reviews, their level of engagement with other users, or the types of businesses they review. 



##### 5.The cities most often rated by users

```sql
SELECT b.city,
COUNT(review_id) AS num_rating
FROM
yelp.yelp_review r
JOIN
yelp.business b
ON r.business_id = b.business_id
GROUP BY b.city
ORDER BY num_rating DESC;
```

The city with the highest percentage of reviews was Las Vegas, accounting for 30.50% of all reviews. This can be attributed to the large number of tourists who visit the city, leading to more reviews for businesses in the area.

The second and third most reviewed cities were Phoenix and Toronto, accounting for 10.97% and 8.32% of reviews respectively. These cities are likely to have a strong local user base contributing to the high number of reviews.

Scottsdale and Charlotte were the fourth and fifth most reviewed cities, accounting for 5.88% and 4.51% of reviews respectively.

It is worth noting that the "Other" category accounted for the majority of reviews at 39.93%. This category represents all cities not listed in the top five, suggesting that Yelp is widely used across many cities worldwide.



![image-20230327230731347](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230327230731347.png)

​                                                                           Figure 8 - Cities most often rated by users



##### 6. Factors that affect whether a user is elite:

Average reviews per month:

```sql
WITH CTE1 AS (SELECT SUM(review_count)/SUM(registration) AS avg_reviews_per_month
FROM
(SELECT review_count,
TIMESTAMPDIFF(month,yelping_since,'2017-12-21') AS registration
FROM yelp.elite)a),

CTE2 AS (SELECT SUM(review_count)/SUM(registration) AS avg_reviews_per_month
FROM
(SELECT review_count,
TIMESTAMPDIFF(month,yelping_since,'2017-12-21') AS registration
FROM yelp.not_elite)a)


SELECT 'elite'AS label,
avg_reviews_per_month
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_reviews_per_month
FROM CTE2;
```

Elite users leave an average of 1.45 reviews per month, which is significantly higher than non-elite users who only leave 0.15 reviews per month on average. This suggests that Yelp may be more likely to recognize and reward users who are active in leaving reviews on a regular basis.

Number of days using yelp:

```sql
WITH CTE1 AS(SELECT ROUND(AVG(DATEDIFF('2017-12-21',yelping_since)),0) AS avg_reg
FROM yelp.elite),

CTE2 AS(SELECT ROUND(AVG(DATEDIFF('2017-12-21',yelping_since)),0 AS avg_reg
FROM yelp.not_elite)

SELECT 'elite' AS label,
avg_reg
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_reg
FROM CTE2;
```

Elite users have an average of 1835 days of using Yelp, which is 32.4% more than the average of 1386 days for non-elite users. However, the difference in the number of days is not as significant as the difference in the number of reviews per month between elite and non-elite users. This suggests that being active in leaving reviews on a regular basis is a more important factor for becoming an elite user than the length of time using Yelp.

Number of friends:

```sql
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
```

he number of friends a user has on Yelp does not appear to be a factor in determining whether they are elite or not. Elite users have an average of only 0.09 friends, while non-elite users have an average of 3.43 friends, indicating that the number of friends is not a significant factor in Yelp's elite program.

Number of times get useful,funny, or cool:

```sql
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
```

Elite users get an average of 22.31 positive feedback such as useful, funny or cool compared to non-elite users, who only receive an average of 2.87. This suggests that being an elite user may incentivize others to leave positive feedback on a user's reviews or profile, potentially leading to greater recognition and status on the platform.

Number of fans

```sql
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
```

he average number of fans for non-elite users is 0.11, while the average for elite users is 2.21, representing a 1909.10% increase for elite users. This could indicate that elite users are more influential and have a larger impact on the Yelp community.

average stars giving

```sql
WITH CTE1 AS (SELECT ROUND(AVG(average_stars),2) AS avg_star
FROM yelp.elite),

CTE2 AS (SELECT ROUND(AVG(average_stars),2) AS avg_star
FROM yelp.not_elite)

SELECT 'elite' AS label,
avg_star
FROM CTE1
UNION ALL
SELECT 'not elite' AS label,
avg_star
FROM CTE2;
```

non-elite users have an average of 0.11 fans, while elite users have an average of 2.21 fans. While the difference between the average number of fans for elite and non-elite users is significant, it may not necessarily be an influential factor in determining elite status.

Number of compliments received:

```sql
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
```

The average number of compliments received by elite users is 5.37, which is 2883.33% more than the average of 0.18 compliments received by non-elite users. This is a significant difference and suggests that being an elite user may be positively correlated with receiving more compliments on Yelp.

 Times of photos being liked:

```sql
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
```

elite users have an average of 0.32 compliments with photos, which is 3100% more than non-elite users who only have 0.01. elite users are more likely to take the time and effort to add photos to their compliments, which may make their reviews more engaging and visually appealing to other users. This could potentially make their reviews more influential and could be a factor in their elite status.

Based on the analysis, average number of reviews per month, number of positive feedback received, number of compliments received, length of time using Yelp appear to be important factors for determining elite status on Yelp.



### Restaurant Dimension：

##### 1.Distribution of restaurants by star rating

Average star rating of restaurants:

```sql
SELECT ROUND(AVG(stars),2) AS avg_star
FROM yelp.business;
```

```sql
SELECT stars,
COUNT(*) AS num
FROM yelp.business
GROUP BY stars
ORDER BY stars DESC;
```

The average star rating of restaurants is 3.63. This indicates that on average, restaurants have a good rating. The distribution of ratings shows the most common rating among restaurants is 4.0, with a total of 33,190 restaurants, accounting for 19.18% of the total restaurants. The second most common rating is 3.5, with 18.36% of the total restaurants, followed by 5 stars with 15.77% of the total restaurants. The majority of restaurants have a rating of 3 or higher, with 4.0 being the most common rating, suggestsing that most restaurants on Yelp have a decent level of quality (See Figure 9).

![image-20230328170701272](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230328170701272.png)

​                                                                     Figure 9 - Distribution of restaurants by star rating



##### 2. Factors that affect restaurants' star rating

Relation ship between stars and number of reviews

```sql
SELECT stars,
SUM(review_count) AS total_review
FROM yelp.business
GROUP BY stars
ORDER BY total_review DESC;
```

4 and 3.5 star restaurants have the most reviews, while 5-star restaurants are in the middle position. This could be due to the fact that 3.5 and 4-star restaurants are more cost-effective, as some 5-star restaurants may have higher prices and therefore fewer customers. Customers may also be more likely to leave a review if they had an especially positive or negative experience, which could contribute to the higher number of reviews for 4 and 3.5 star restaurants.

The relationship between stars and the ratio of good to bad ratings(more than 4 star is  good & less than 2 star is bad):

```sql
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
```

There appears to be a strong positive exponential relationship between the star rating of restaurants and the ratio of good to bad ratings. The ratio is highest for 5-star restaurants with a value of 85.98, which is significantly higher than the ratio for 4.5-star restaurants, which is 12.97. This suggests that higher-rated restaurants are more likely to receive a higher ratio of good to bad ratings, indicating that customers are more satisfied with their experiences at these restaurants (See Figure 10).

![image-20230328181012179](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230328181012179.png)

​                                                  Firgure 10 - Star rating of restauants and ratio of good rating to bad rating 

##### 3.geographical analysis

States that have the most restaurants:

```sql
CREATE TABLE yelp.state_num_retaurants
SELECT state,
COUNT(*) AS num_restaurants
FROM yelp.business
GROUP BY state
ORDER BY num_restaurants DESC;
```

States that have a high percentage of 5-star restaurants:

```sql
CREATE TABLE yelp.state_five_star
SELECT
state,
ROUND(SUM(CASE WHEN stars = 5 THEN 1 ELSE 0 END)*100 / COUNT(*),2) AS five_star_percentage
FROM yelp.business
GROUP BY state
ORDER BY five_star_percentage DESC;
```

States that have a high percentage of restaurants with good reviews:

```sql
CREATE TABLE yelp.state_good_review
SELECT b.state,
ROUND(SUM(CASE WHEN r.stars >= 4 THEN 1 ELSE 0 END)*100 / COUNT(review_id),2) AS good_review_percentage
FROM yelp.business b
JOIN yelp.yelp_review r
ON b.business_id = r.business_id
GROUP BY b.state
ORDER BY good_review_percentage DESC;
```

Arizona has the highest number of restaurants in the United States with 51,735 establishments, followed by Nevada with 32,820. The reason for this may be due to Arizona's popularity as a tourist destination, especially for retirees and snowbirds who may have a higher demand for restaurants. Additionally, Arizona's proximity to Mexico and its diverse cuisine may attract a variety of restaurants. The state's population growth may also contribute to the expansion of its restaurant industry.

Arizona also has the highest percentage of 5-star restaurants at 22.38%, followed closely by Nevada with 20.03%. Furthermore, Arizona leads in the percentage of restaurants with good reviews, with 67.81%, while Nevada follows with 66.46%. Ohio, with 12,487 restaurants, has a low percentage of 5-star restaurants at 12.55%. However, it compensates with a high percentage of good review restaurants at 65.11%. Similarly, Illinois also has a low percentage of 5-star restaurants but a high percentage of good review restaurants (See Figure 11).

![Screen Shot 2023-04-04 at 10.11.12 PM](/Users/siyuanwang/Desktop/Screen Shot 2023-04-04 at 10.11.12 PM.png)

​           Figure 11 - States by number, five star percentage and good review percentage of restaurants



##### 4. Restaurants' business hour analysis

relationship between star rating of a restaurant and the number of open days per week:

```sql
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
```

Restaurants with a rating of 4.0 have the highest number of open days per week, whereas higher-rated restaurants with a rating over 4.0 tend to have slightly fewer open days. This is likely due to the fact that highly rated restaurants are in higher demand, and may need to limit their hours in order to maintain their level of quality and exclusivity. Additionally, restaurants with lower ratings may have to limit their hours or days of operation due to lower demand.

The strategy of limiting operating hours or days of highly rated restaurants with a rating of 4.5 and 5.0 in order to create a sense of exclusivity is a common tactic in the restaurant industry known as "hunger marketing." By creating a sense of scarcity, these restaurants may be able to increase demand and create a more desirable and exclusive dining experience for their customers (See Figure 12).

![image-20230329144021436](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230329144021436.png)

​                                                                     Figure 12 - star rating and total opening days 

##### 5. Factors that affect restaurants' opening status

Relation ship between restaurants' opening status and opening days per week:

```sql
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
SUM(days_open)/COUNT(*) AS avg_days_open
FROM yelp.business b
JOIN CTE
ON b.business_id = CTE.business_id
GROUP BY is_open;
```

Closed restaurants open an average of 3.94 days per week, while restaurants that are still open open an average of 4.87 days per week. This could be due to a number of factors, such as lower demand for certain types of cuisine or locations, higher operating costs, or other financial constraints. Additionally, restaurants that are closed may have had issues with maintaining consistent opening hours, which could have contributed to their closure. 

Relationship between  restaurants' opening status and average number of low star (less than 2 star) comments:

```sql
SELECT is_open,
ROUND(SUM(CASE WHEN r.stars <= 2 THEN 1 ELSE 0 END)/COUNT(*),2) AS bad
FROM yelp.business b
JOIN yelp.yelp_review r
ON b.business_id = r.business_id
GROUP BY is_open;
```

The difference between the averages of closed restaurants and open restaurants is very small, with closed restaurants having an average of 0.25 low star reviews and open restaurants having an average of 0.22 low star reviews. Despite having more business days, open restaurants still have a lower average number of low star reviews compared to closed restaurants. 



### Platform Dimension:

##### 1.user registration trend

```sql
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
```

he monthly user registration trend shows a steady increase from 2005 to July 2014, followed by a decrease until 2017. The peak of user registrations occurred in July 2014.

The annual user registration trend follows a similar pattern, with a steady increase until 2014, followed by a decrease until 2017. Overall, the trend suggests a period of rapid growth in user registrations followed by a decline (See Figure 13 & Figure 14). 

![image-20230329163034543](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230329163034543.png)

​                                                                                 Figure 13 - Monthly user registration trend

![ ](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230329163103479.png)

​                                                                                     Figure 14 - Annually user registration trend

##### 2. Monthly number of reviews trend

```sql
CREATE TABLE yelp.monthly_review
SELECT year(date) AS review_year,
month(date) AS review_month,
COUNT(*) AS num_review
FROM yelp.yelp_review
GROUP BY review_year,review_month;
```

The steady increase in monthly reviews from 2005 to 2017 may indicate a growing user base and/or increased engagement with the platform. However, the drop in December 2017 could be due to the incomplete data, so it should be taken with caution. Overall, the trend suggests a positive growth trajectory for the platform (See Figure 15).

![image-20230404231825064](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230404231825064.png)

​                                                                                 Figure 15 - Monthly number of reviews trend

##### 3. Monthly active users trend

```sql
CREATE TABLE MAU AS
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
```

The monthly active user (MAU) trend shows a similar pattern to the monthly reviews trend, with a steady increase from 2005 to 2007 and a peak in 2017. The drop in December 2017 is likely due to the fact that we only have data for 11 days, which is not representative of the entire month. Overall, the MAU trend indicates that the platform has experienced sustained growth in user engagement over the years, with more and more users using the platform on a monthly basis (See Figure 16).



![image-20230404232509503](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230404232509503.png)

​                                                                                  Figure 16 - Monthly active users (MAU) trend

##### 4. Percentage of elite customers by year

```sql
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
ON CTE1.reg_year = CTE2.year
```

There does not appear to be a clear upward trend in the percentage of elite customers over the years. The highest percentage observed was only 0.04% in 2017, while the lowest was around 0.01%. This suggests that the Elite status is a highly exclusive and prestigious level within the Yelp community, and it takes a significant amount of engagement and contribution for a user to attain this status. The fact that the percentage of Elite users remains relatively low across the years suggests that Yelp maintains high standards for selecting elite users. It also indicates that being an elite user carries a certain level of distinction and recognition within the Yelp community. This exclusivity may also motivate users to actively engage with the platform in order to attain elite status and its associated benefits.

##### 5. The annual retention rate of users

```sql
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
```

The annual retention rate of Yelp's users has remained stable at approximately 30% between 2005 and 2007, with no significant fluctuations or an upward trend observed. This suggests that while Yelp has been able to maintain a consistent user base over the years, they have not been able to substantially increase the number of users who return to the platform year after year. This lack of growth in retention rate could be due to increased competition in the market, as the growth of the internet and social media has led to the emergence of various platforms and apps that compete for users' attention. Such heightened competition makes it harder for any one platform to retain users over time. Another possible explanation for the stagnant retention rate could be attributed to user behavior. Users may be more fickle and less loyal than they used to be, with the abundance of options available to them. They may be more inclined to switch from one platform to another as their interests and needs change, rather than remaining loyal to a single platform.

![image-20230405135524556](/Users/siyuanwang/Library/Application Support/typora-user-images/image-20230405135524556.png)

​                                                                                         Figure 17 - user annual rentention rate 



##### 6. The annual retention rate of elite users

```sql
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
```

The annual retention rate of elite users shows a very different trend compared to the overall user retention rate. The retention rate for elite users is consistently high, with the lowest rate at 33% in 2010 and all other years having rates above 70%. Interestingly, the retention rate even reached 100% in 2008, 2009, 2011, and 2012. 

This could be because the benefits of being an elite user, such as access to exclusive events and promotions,. Additionally, the elite status may serve as a form of social proof, signaling to others that a user is a respected and active member of the Yelp community.

It is also possible that Yelp has implemented measures to encourage elite users to remain active on the platform, such as providing additional rewards for maintaining their elite status. Whatever the reason, the high retention rate of elite users is a positive sign for Yelp, as it indicates that users are motivated to remain active and engaged on the platform.

### Conclusion:

Based on the analysis of Yelp's data, several conclusions can be drawn regarding customer, restaurant performance, and the platform itself.

Regarding the customer dimension, an analysis was conducted on factors that influence the attainment of elite status by users. The findings suggest that the number of reviews written per month, the number of compliments received, and the number of fans accumulated are important factors that contribute to elite status. Users who consistently write high-quality reviews, receive compliments from other users, and attract a large number of fans are more likely to achieve elite status on the Yelp platform.

In the business dimension, the analysis focused on factors that influence the star rating of restaurants. The findings indicate that the most crucial factor is the ratio of good ratings to bad ratings. Additionally, the relationship between a restaurant's opening status and the number of low-star reviews received was examined. The analysis found that closed restaurants receive slightly more low-star reviews on average than open restaurants. However, this difference is relatively small, and it should be noted that open restaurants generally operate for more business days than closed restaurants, which may account for some of the difference in review volume.

Lastly, in the platform dimension, trends in user registration, reviews, monthly active users, and elite user retention were analyzed. The findings indicate that Yelp experienced steady growth in user registration and monthly reviews until 2017. It was also found that the retention rate of regular Yelp users remained consistent around 30%, while the retention rate of elite users was consistently high, with some years reaching a perfect retention rate of 100%.

In conclusion, the analysis sheds light on key factors that influence elite status attainment by users, the relationship between restaurant opening status and low-star reviews, and trends in user registration, reviews, monthly active users, and elite user retention. These insights can be valuable for Yelp as it seeks to enhance user engagement, improve the quality of its content, and maintain a competitive edge in the online review space.
