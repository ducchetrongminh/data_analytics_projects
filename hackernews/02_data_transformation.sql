/*
UPDATED AT: 2024-02-20
*/

WITH rename_column AS (
  SELECT 
    id AS hackernews_id
    , `by` AS hackernews_user_id
    , type
    , timestamp AS posted_at
    , title AS story_title
    , url AS story_url
    , score AS story_score
    , text
    , parent AS parent_comment_id
    , ranking AS comment_ranking
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
    AND is_deleted IS NULL 
    AND is_dead IS NULL 
    AND hackernews_user_id IS NOT NULL
    AND type IN ('story', 'comment')
    AND posted_at >= '2007-01-01'
)

, enrich AS (
  SELECT 
    *
    , NET.REG_DOMAIN(story_url) AS story_domain
  FROM remove_useless_data
)

SELECT 
  hackernews_id
  , hackernews_user_id
  , type
  , posted_at
  , story_title
  , story_url
  , story_domain
  , story_score
  , text
  , parent_comment_id
  , comment_ranking
FROM enrich
ORDER BY posted_at
