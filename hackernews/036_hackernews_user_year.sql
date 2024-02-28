WITH summary_stories AS (
  SELECT 
    hackernews_user_id
    , CAST(DATE_TRUNC(posted_at, YEAR) AS DATE) AS year
    , COUNT(hackernews_id) AS count_stories
    , SUM(story_score) AS sum_story_scores
  FROM `vit-lam-data.cleansed.hackernews`
  WHERE type = 'story'
  GROUP BY 1, 2
  ORDER BY 1 
)

, ntile_by_year AS (
  SELECT
    *
    , NTILE(100) OVER (PARTITION BY year ORDER BY count_stories) AS count_stories_rank
  FROM summary_stories
)

, segment AS (
  SELECT 
    *
    , CASE 
      WHEN count_stories_rank = 100 THEN '1. Top 1%'
      WHEN count_stories_rank >= 80 THEN '2. Top 20%'
      ELSE '3. Bottom 80%' END AS count_stories_segment
  FROM ntile_by_year
)

, dim_year AS (
  SELECT DISTINCT DATE_TRUNC(full_date, YEAR) AS year
  FROM `vit-lam-data.cleansed.dim_date`
)

, generate_dense AS (
  -- for story only
  SELECT 
    hackernews_user.hackernews_user_id
    , dim_year.year
  FROM `vit-lam-data.cleansed.hackernews_user` AS hackernews_user
  CROSS JOIN dim_year
  WHERE dim_year.year 
      BETWEEN DATE_TRUNC(hackernews_user.first_story_date, YEAR)
      AND DATE_TRUNC(hackernews_user.last_story_date, YEAR)
)
, make_dense AS (
  SELECT
    hackernews_user_id 
    , year 
    , COALESCE(hackernews_user_year.count_stories, 0) AS count_stories
    , COALESCE(hackernews_user_year.sum_story_scores, 0) AS sum_story_scores
    , COALESCE(hackernews_user_year.count_stories_rank, 0) AS count_stories_rank
    , COALESCE(hackernews_user_year.count_stories_segment, '4. Inactive') AS count_stories_segment
    , CASE 
      WHEN count_stories_segment = '1. Top 1%' THEN 3
      WHEN count_stories_segment = '2. Top 20%' THEN 2
      WHEN count_stories_segment = '3. Bottom 80%' THEN 1
      WHEN count_stories_segment IS NULL THEN 0
      END
      AS count_stories_segment_rank
  FROM generate_dense
  LEFT JOIN segment AS hackernews_user_year
    USING (hackernews_user_id, year)
  ORDER BY 1, 2
)

, calculate_change AS (
  SELECT 
    *
    , count_stories_segment_rank - COALESCE(LAG(count_stories_segment_rank, 1) OVER (PARTITION BY hackernews_user_id ORDER BY year), 0) AS count_stories_segment_change
  FROM make_dense
  ORDER BY 1, 2
)

SELECT *
FROM calculate_change
WHERE 
  -- remove rows where users inactive 2 years straight
  NOT (
    count_stories_segment_rank = 0
    AND count_stories_segment_change = 0
  )
ORDER BY 1, 2
