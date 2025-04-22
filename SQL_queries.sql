--Calculation number of days for A/B test with our sample size
WITH first_training_table AS(
SELECT DISTINCT user_id
  ,MIN(DATE(event_time)) as date
FROM `FitUp.events`
WHERE event_type = "workout_end"
GROUP BY 1
),
numb_training_by_day_table AS(
SELECT date
  ,COUNT(DISTINCT user_id) as users
FROM first_training_table
GROUP BY 1
)
SELECT CEIL(757*2/AVG(users)) AS days_for_ab_test
FROM numb_training_by_day_table
;



--Conversion rate by group
WITH group_table AS(
SELECT user_id
  ,ab_group
  ,event_type
FROM `AB_test_FitUp.users`
JOIN `AB_test_FitUp.events`
USING (user_id)
)
SELECT ab_group
  ,COUNT(DISTINCT CASE WHEN event_type = "buy_subscription" THEN user_id END) AS subscribed_users
  ,COUNT(DISTINCT user_id) AS total_users
  ,ROUND(COUNT(DISTINCT CASE WHEN event_type = "buy_subscription" THEN user_id END)*100.0/COUNT(DISTINCT user_id),2) AS conversion_rate
FROM group_table
GROUP BY 1
ORDER BY 1
;


--Lift effect
WITH group_a_table AS(
SELECT user_id
  ,ab_group
  ,event_type
FROM `AB_test_FitUp.users`
JOIN `AB_test_FitUp.events`
USING (user_id)
),
conversion_table AS(
SELECT ab_group
  ,COUNT(DISTINCT CASE WHEN event_type = "buy_subscription" THEN user_id END) AS subscribed_users
  ,COUNT(DISTINCT user_id) AS total_users
  ,ROUND(COUNT(DISTINCT CASE WHEN event_type = "buy_subscription" THEN user_id END)*100.0/COUNT(DISTINCT user_id),2) AS conversion_rate
FROM group_a_table
GROUP BY 1
ORDER BY 1
)
SELECT ROUND(
  ((SELECT conversion_rate FROM conversion_table
  WHERE ab_group = "B")-
  (SELECT conversion_rate FROM conversion_table
  WHERE ab_group = "A"))/
  (SELECT conversion_rate FROM conversion_table
  WHERE ab_group = "A")*100.0
,2) AS lift_effect
;


--Distribution users across countries
SELECT country
  ,ROUND(COUNT(DISTINCT CASE WHEN ab_group = "A" THEN user_id END)*100.0/COUNT(DISTINCT user_id),1) AS A_group_percentage
  ,ROUND(COUNT(DISTINCT CASE WHEN ab_group = "B" THEN user_id END)*100.0/COUNT(DISTINCT user_id),1) AS B_group_percentage
FROM `AB_test_FitUp.users`
GROUP BY 1
ORDER BY 1
;






