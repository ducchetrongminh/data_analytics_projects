SELECT 
  hackernews_user_id
  , CAST(MIN(posted_at) AS DATE) AS first_posted_date -- for user acquisition analysis
FROM `vit-lam-data.cleansed.hackernews`
GROUP BY 1 
ORDER BY 2
