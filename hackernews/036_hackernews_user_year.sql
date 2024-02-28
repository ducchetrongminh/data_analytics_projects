WITH summary_stories AS (
  SELECT 
    hackernews_user_id
    , EXTRACT(YEAR FROM posted_at) AS year
    , COUNT(hackernews_id) AS count_stories
  FROM `vit-lam-data.cleansed.hackernews`
  WHERE 
    type = 'story'
  GROUP BY 1, 2
)

SELECT
  hackernews_user_id
  , year
  , count_stories
  , NTILE(100) OVER (PARTITION BY year ORDER BY count_stories) AS count_stories_rank
  , CASE 
    WHEN count_stories >= 50 THEN '1. Very active (>= 50)'
    WHEN count_stories >= 5 THEN '2. Normal (5 - 50)'
    ELSE '3. Low (<5)' END 
    AS count_stories_segment
FROM summary_stories
ORDER BY 1, 2
