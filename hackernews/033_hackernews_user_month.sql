WITH hackernews_user_month AS (
  SELECT 
    hackernews_user_id
    , CAST(DATE_TRUNC(posted_at, MONTH) AS DATE) AS month
    , COUNT(hackernews_id) AS count_posts
  FROM `vit-lam-data.cleansed.hackernews`
  GROUP BY 1, 2
)

, join_data AS (
  SELECT 
    hackernews_user_id
    , hackernews_user_month.month
    , hackernews_user_month.count_posts
    , DATE_TRUNC(hackernews_user.first_posted_date, MONTH) AS first_posted_month
  FROM hackernews_user_month 
  LEFT JOIN `vit-lam-data.cleansed.hackernews_user` AS hackernews_user
    USING (hackernews_user_id)
)

SELECT 
  *
  , DATE_DIFF(month, first_posted_month, MONTH) AS retention_month_number
FROM join_data
ORDER BY 1, 2
