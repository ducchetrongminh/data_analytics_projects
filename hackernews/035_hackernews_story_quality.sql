WITH rename_column AS (
  SELECT 
    id AS hackernews_id
    , type
    , timestamp AS posted_at
    , score AS story_score
    , deleted AS is_deleted
    , dead AS is_dead
  FROM `bigquery-public-data.hacker_news.full`
)

, deduplicate AS (
  SELECT DISTINCT *
  FROM rename_column
)

, remove_useless_data AS (
  SELECT *
  FROM deduplicate
  WHERE 
    posted_at IS NOT NULL
    AND type IN ('story')
    AND posted_at >= '2007-01-01'
)

SELECT 
  EXTRACT(YEAR FROM posted_at) AS year
  , CASE 
    WHEN is_deleted IS TRUE OR is_dead IS TRUE THEN 'Dead/Deleted'
    WHEN story_score IS NULL THEN 'Low score'
    WHEN story_score <= 1 THEN 'Low score'
    WHEN story_score > 1 THEN 'Normal'
    ELSE 'Undefined' END
    AS story_quality_segment
  , COUNT(*) AS count_stories
FROM remove_useless_data
GROUP BY 1, 2
ORDER BY 1, 2 
