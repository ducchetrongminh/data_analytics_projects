/*
UPDATED AT: 2024-02-20
*/


-- Check duplicates of id. Found about 2.4m duplicated ids.
SELECT 
  id
  , COUNT(*) AS count_records
FROM `bigquery-public-data.hacker_news.full`
GROUP BY 1 
HAVING COUNT(*) > 1
ORDER BY 2 DESC
;


-- Check year range. Year range is from 2006 to 2022, which indicates that the data had not updated since 2022.
SELECT 
  EXTRACT(YEAR FROM timestamp) AS year
  , COUNT(*) AS count_records
FROM `bigquery-public-data.hacker_news.full`
GROUP BY 1 
ORDER BY 1
;


-- Check month range to dive deeper. The data had not updated since 2022 November.
SELECT 
  DATE_TRUNC(timestamp, MONTH) AS month
  , COUNT(*) AS count_records
FROM `bigquery-public-data.hacker_news.full`
GROUP BY 1 
ORDER BY 1
;


-- Check `type` column. Besides comment and story, there are other types: job, pollopt, poll. 
-- Comments and stories are the most content created with 25.6m comments and 4.2m stories. 
SELECT 
  type
  , COUNT(*) AS count_records
FROM `bigquery-public-data.hacker_news.full`
GROUP BY 1 
ORDER BY 2 DESC
;
