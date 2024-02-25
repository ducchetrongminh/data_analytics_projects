WITH summary_hackernews_user AS (
  SELECT 
    DATE_TRUNC(first_posted_date, YEAR) AS start_of_year
    , COUNT(hackernews_user_id) AS new_users -- for user acquisition analysis
  FROM `vit-lam-data.cleansed.hackernews_user`
  GROUP BY 1 
)

, calculate_metrics_1 AS (
  SELECT 
    *
    , SUM(new_users) OVER (ORDER BY start_of_year ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_users_start_of_year
    , SUM(new_users) OVER (ORDER BY start_of_year) AS total_users_end_of_year
  FROM summary_hackernews_user
)

SELECT
  *
  , new_users / total_users_start_of_year AS user_acquisition_rate
FROM calculate_metrics_1
ORDER BY 1
