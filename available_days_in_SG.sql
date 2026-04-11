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
        FROM sg_listings_historical
        WHERE state = 'published'
          AND JSONExtract(metadata, 'live', 'Bool') = true
          AND JSONExtract(publicData, 'isDeposit', 'Bool') = false
          AND deleted = 0
          AND archive_date >= toMonday(today() - INTERVAL 20 WEEK)
          AND archive_date < toMonday(today())
        GROUP BY week_start
