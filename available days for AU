WITH 
-- === THIS YEAR: Last 20 full weeks ===
ThisYear AS (
    SELECT
        week_start AS Starting_Week_Date,
        week_offset,
        AvailableDays,
        AvailableCars,
        AvailableDays / (AvailableCars * 7.0) AS Availability_pct
    FROM (
        SELECT
            toMonday(archive_date) AS week_start,
            dateDiff('week', toMonday(archive_date), toMonday(today())) AS week_offset,
            sum(dailyAvailability) / 24.0 AS AvailableDays,
            countDistinct(listing_id) AS AvailableCars
        FROM au_listings_historical
        WHERE state = 'published'
          AND JSONExtract(metadata, 'live', 'Bool') = true
          AND JSONExtract(publicData, 'isDeposit', 'Bool') = false
          AND deleted = 0
          AND archive_date >= toMonday(today() - INTERVAL 20 WEEK)
          AND archive_date < toMonday(today())
        GROUP BY week_start
    ) t
),

-- === LAST YEAR: Same 20 weeks, 52 weeks ago ===
LastYear AS (
    SELECT
        week_start AS Starting_Week_Date,
        week_offset,
        AvailableDays,
        AvailableCars,
        AvailableDays / (AvailableCars * 7.0) AS Availability_pct
    FROM (
        SELECT
            toMonday(archive_date) AS week_start,
            dateDiff('week', toMonday(archive_date), toMonday(today() - INTERVAL 52 WEEK)) AS week_offset,
            sum(dailyAvailability) / 24.0 AS AvailableDays,
            countDistinct(listing_id) AS AvailableCars
        FROM au_listings_historical
        WHERE state = 'published'
          AND JSONExtract(metadata, 'live', 'Bool') = true
          AND JSONExtract(publicData, 'isDeposit', 'Bool') = false
          AND deleted = 0
          AND archive_date >= toMonday(today() - INTERVAL 52 WEEK - INTERVAL 20 WEEK)
          AND archive_date < toMonday(today() - INTERVAL 52 WEEK)
        GROUP BY week_start
    ) t
)

-- === FINAL JOIN ON week_offset ===
SELECT
    formatDateTime(T1.Starting_Week_Date, '%Y-%m-%d') AS Week_starting_date,
    round(T1.AvailableDays, 0) AS AvailableDays_this_year,
    round(T2.AvailableDays, 0) AS AvailableDays_last_year,
    round(T1.Availability_pct * 100, 1) AS Availability_pct_this_yr,
    round(T2.Availability_pct * 100, 1) AS Availability_pct_last_yr,
    -- Optional: YoY growth
    round(
        nullIf(T2.AvailableDays, 0) = 0 
            ? NULL 
            : (T1.AvailableDays - T2.AvailableDays) * 100.0 / T2.AvailableDays,
        1
    ) AS AvailableDays_YoY_pct
FROM ThisYear T1
LEFT JOIN LastYear T2 
    ON T1.week_offset = T2.week_offset
ORDER BY T1.Starting_Week_Date ASC;
