# FitUp A/B Testing Analysis  
**Testing the Effect of a Motivational Phrase on Subscription Conversion**  
---

![FitUp Logo](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/Logo.png)  
---

## Overview

**FitUp** is a mobile fitness app that helps users track workouts and monitor progress.  
It offers personalized training plans, real-time performance tracking, and a subscription-based model for premium features.

Users can access a limited set of workouts for free, or unlock full access to all training programs through one of two premium subscription plans: **monthly ($9.99)** or **yearly ($99.99)**.



## Experiment Context & Objective

This project aims to evaluate whether **adding a motivational message at the end of a workout session** can positively impact the **subscription conversion rate**.

### Hypothesis

Users are more emotionally engaged and motivated immediately after completing a workout.  
Displaying a **motivational phrase** along with a **subscription CTA (Call-to-Action)** at that moment may increase the likelihood of upgrading to a premium plan.


## Methodology

- **Main Metric:** Conversion to subscription (% of users who purchase a premium plan)  
- **Test Type:** A/B Test (between Group A – control, and Group B – variant)  
- **Group Allocation:** Users were **randomly assigned** to control and treatment groups  
- **Sample Size:** Calculated based on minimum detectable effect and desired statistical power. Calculated with [Evan_Miller](https://www.evanmiller.org/ab-testing/sample-size.html)
![FitUp Logo](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/Sample_size.png)   
-	**Test Duration:** Calculated based on the sample size
```SQL
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
```
![days_for_test](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/days_for_test.png)   

## Results

### 1. Randomization Check (by Country)

To confirm even distribution across key user segments:  
- Verified that **country distribution** was balanced between groups  
```SQL
--Distribution users across countries
SELECT country
  ,ROUND(COUNT(DISTINCT CASE WHEN ab_group = "A" THEN user_id END)*100.0/COUNT(DISTINCT user_id),1) AS A_group_percentage
  ,ROUND(COUNT(DISTINCT CASE WHEN ab_group = "B" THEN user_id END)*100.0/COUNT(DISTINCT user_id),1) AS B_group_percentage
FROM `AB_test_FitUp.users`
GROUP BY 1
ORDER BY 1
;
```
![users_distributions](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/users_distributions.png)   
---

### 2. Subscription Conversion by Group

```SQL
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
```
![results_table](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/results_table.png)  
---

### 3. Lift Calculation

The motivational message group showed a **+24.8% relative lift** in conversion compared to the control group.  
```SQL
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
``` 
![lift_effect](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/lift_effect.png)  

---

### 4. Statistical Significance (ABTestGuide)

Final validation was performed using [AB Testguide](https://abtestguide.com/calc/):

- **P-value:** 0.0291 → statistically significant at the 95% confidence level  
- **Statistical Power:** 85.54% → strong confidence in the result

![ABTestquide](https://github.com/Andrii-Klipailo/FitUp_A-B_Testing_Analysis/blob/main/images/ABTestquide.png)  


## Findings and Conclusion

The experiment demonstrated a statistically significant improvement in conversion after adding the motivational phrase window:

- **Control Group Conversion:** 13.78%  
- **Test Group Conversion:** **17.2%**  
- **Relative Lift:** +24.8%  
- **P-value:** 0.0291  
- **Power:** 85.54%

### Key Insight

Timing and emotional context matter — a well-placed motivational message right after a workout can create an effective upsell moment.

### Recommendation

Based on these results, the **motivational phrase feature was implemented** into the app's production version.


---

#### Thank you for taking the time to explore my project!
If you have any feedback, questions, or would like to connect — feel free to reach out.

