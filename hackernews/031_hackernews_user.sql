SELECT 
  hackernews_user_id
  , CAST(MIN(posted_at) AS DATE) AS first_posted_date -- for user acquisition analysis
  , CAST(MAX(posted_at) AS DATE) AS last_posted_date
FROM `vit-lam-data.cleansed.hackernews`
GROUP BY 1 
ORDER BY 2
