WITH new_users_by_month AS (
  SELECT 
    DATE_TRUNC(first_posted_date, MONTH) AS first_month
    , COUNT(hackernews_user_id) AS new_users
  FROM `vit-lam-data.cleansed.hackernews_user`
  GROUP BY 1
)

, retained_users_by_month AS (
  SELECT 
    first_posted_month AS first_month
    , month AS retention_month
    , retention_month_number
    , COUNT(hackernews_user_id) AS retained_users
  FROM `vit-lam-data.cleansed.hackernews_user_month`
  GROUP BY 1, 2, 3
)

SELECT 
  first_month 
  , retained_users_by_month.retention_month
  , retained_users_by_month.retention_month_number
  , new_users_by_month.new_users
  , retained_users_by_month.retained_users
  , ROUND(retained_users_by_month.retained_users / new_users_by_month.new_users, 4) AS retention_rate
FROM retained_users_by_month
LEFT JOIN new_users_by_month USING (first_month)
ORDER BY 1, 2
