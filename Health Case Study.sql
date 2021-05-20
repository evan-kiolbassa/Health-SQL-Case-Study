-- Number of unique patients in log data set
SELECT 
  COUNT(DISTINCT id) AS "Unique Users"
FROM
  health.user_logs;
  
-- Total measurements for each patients on average

-- Creation of a view that counts measurements
  CREATE VIEW user_measurements AS (
    SELECT
      id,
      COUNT(measure) AS "num_measurements"
    FROM
      health.user_logs
    GROUP BY
      id
  )
-- Calculates average of the grouped patient counts
SELECT
  AVG(num_measurements) AS "Average Number of Measurements by Patient"
FROM
  user_measurements;

-- Median amount of measurements per user
SELECT 
  ROUND(
    -- this function actually returns a float which is incompatible with ROUND!
    -- we use this cast function to convert the output type to NUMERIC
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY num_measurements) AS NUMERIC),
    2
  ) AS median_value
FROM
  user_measurements;

-- How many users have more than 3 measurements
SELECT
  COUNT(id) AS "Patients with Over 3 Measurements"
FROM
  user_measurements
WHERE
  num_measurements > 3;

-- How many users have over 1000 measurements
SELECT
  COUNT(id) AS "Patients with Over 1000 Measurements"
FROM
  user_measurements
WHERE
  num_measurements > 1000;

-- Number/percentage of users that have logged blood glucose measurements
SELECT
  COUNT(DISTINCT id) AS num_glucose,
  COUNT(DISTINCT id) :: NUMERIC / SUM(COUNT(*)) OVER () * 100 AS "percentage_glucose"
FROM
  health.user_logs
WHERE
  measure = 'blood_glucose';

  
  CREATE VIEW num_measurements AS (
    SELECT
      id,
      COUNT(*) AS measure_count,
      COUNT(DISTINCT measure) AS num_test_types
    FROM
      health.user_logs
    GROUP BY
      id
  );
-- Number and percentage of people with two or more measurements
SELECT
  COUNT(*) AS "Number of Patients with Two or More Tests"
FROM
  num_measurements
WHERE
  num_test_types >= 2;
-- Number and percentage of people with all three measurements
SELECT
  COUNT(*) AS "Number of Patients with All Tests"
FROM
  num_measurements
WHERE
  num_test_types = 3;

-- Median diastolic and systolic values
SELECT
  ROUND(
    -- this function actually returns a float which is incompatible with ROUND!
    -- we use this cast function to convert the output type to NUMERIC
    CAST(
      PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY
          systolic
      ) AS NUMERIC
    ),
    2
  ) AS median_systolic,
  ROUND (
    CAST(
      PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY
          diastolic
      ) AS NUMERIC
    ),
    2
  ) AS median_diastolic
FROM
  health.user_logs
WHERE
  measure = 'blood_pressure';