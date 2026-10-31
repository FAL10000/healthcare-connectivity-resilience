-- Healthcare Connectivity Resilience
-- OpenCellID - Initial Data Exploration


-- 01. Dataset Structure

DESCRIBE opencellid_raw;


-- 02. Radio Technology Distribution
-- Count cellular records by radio technology.
-- Sort technologies by the highest record count.

SELECT
    radio,
    COUNT(*) as cell_count
FROM opencellid_raw
GROUP BY radio
ORDER BY cell_count desc;


-- 03. Coordinate Completeness
-- Count total records, missing coordinates, and zero coordinates.
-- Identify potential geographic data quality issues.

SELECT
    COUNT(*),
    SUM(CASE WHEN lat ISNULL OR lon ISNULL THEN 1 ELSE 0 END) AS null_coords,
    SUM(CASE WHEN lat = 0 AND lon = 0 THEN 1 ELSE 0 END) AS zero_coords
FROM opencellid_raw;


-- 04. Geographic Coordinate Ranges
-- Find the minimum and maximum latitude and longitude.
-- Check whether coordinates fall within expected geographic ranges.

SELECT
    MIN(lat) minimum_latitude,
    MAX(lat) maximum_latitude,
    MIN(lon) minimum_longitude,
    MAX(lon) maximum_longitude
FROM opencellid_raw;


-- 05. Mobile Country Code Distribution
-- Count cellular records by Mobile Country Code (MCC).
-- Verify the country identifiers represented in the dataset.

SELECT
    mcc,
    COUNT(*)
FROM opencellid_raw
GROUP BY mcc;


-- 06. MNC and Radio Technology Distribution
-- Count records for each combination of Mobile Network Code (MNC) and radio technology.
-- Examine technology distribution across mobile networks.

SELECT
    net,
    radio,
    COUNT(*) AS record_count
FROM opencellid_raw
GROUP BY net, radio
ORDER BY net, radio, record_count DESC;


-- 07. Radio Technology Composition by MNC
-- Calculate the total number of records for each MNC.
-- Count LTE, NR, UMTS, and GSM records using conditional aggregation.
-- Calculate the percentage of LTE records within each MNC.

SELECT
    net,
    COUNT(*) AS total,
    SUM(CASE WHEN radio = 'LTE' THEN 1 ELSE 0 END) AS lte,
    SUM(CASE WHEN radio = 'NR' THEN 1 ELSE 0 END) AS nr,
    SUM(CASE WHEN radio = 'UMTS' THEN 1 ELSE 0 END) AS umts,
    SUM(CASE WHEN radio = 'GSM' THEN 1 ELSE 0 END) AS gsm,
    ROUND((lte/total) * 100, 2) AS lte_pct
FROM opencellid_raw
GROUP BY net
ORDER BY total DESC;


-- 08. Temporal Data Range
-- Find the earliest and latest creation and update timestamps.
-- Convert Unix timestamps into readable date and time values.
-- Establish the temporal coverage of the dataset.

SELECT
    TO_TIMESTAMP(MIN(created)) as earliest_created,
    TO_TIMESTAMP(MAX(created)) as latest_created,
    TO_TIMESTAMP(MIN(updated)) as earliest_updated,
    TO_TIMESTAMP(MAX(updated)) as latest_updated,
FROM opencellid_raw;


-- 09. Monthly Update Distribution
-- Count records by their last update month.
-- Identify temporal patterns, unusual spikes, and gaps in updates.
-- Examine the distribution of update activity over time.

SELECT
    DATE_TRUNC('month', TO_TIMESTAMP(updated)) as update_month,
    COUNT(*) AS record_count
FROM opencellid_raw
GROUP BY update_month
ORDER BY update_month;


-- 10. Record Freshness by Radio Technology
-- Use the latest update timestamp as the reference date.
-- Count records older than 6 and 12 months for each radio technology.
-- Calculate the proportion of potentially stale records.

WITH reference AS(
    SELECT
        TO_TIMESTAMP(MAX(updated)) - INTERVAL '6 months' AS ref_6m,
    TO_TIMESTAMP(MAX(updated)) - INTERVAL '12 months' AS ref_12m,
FROM opencellid_raw
    )

SELECT
    radio,
    COUNT(*) as total_records,
    SUM(CASE WHEN TO_TIMESTAMP(updated) < ref_6m THEN 1 ELSE 0 END) AS older_6m,
    SUM(CASE WHEN TO_TIMESTAMP(updated) < ref_12m THEN 1 ELSE 0 END) AS older_12m,
    (older_6m / total_records) * 100 AS pct_older_6m,
    (older_12m / total_records) * 100 AS pct_older_12m
FROM opencellid_raw
         CROSS JOIN reference
GROUP BY radio;


-- 11. UMTS Monthly Update Distribution
-- Examine monthly update activity specifically for UMTS records.
-- Identify unusual changes in the volume of UMTS updates.
-- Investigate the observed update spike in May 2026.

SELECT
    DATE_TRUNC('month', TO_TIMESTAMP(updated)) as update_month,
    COUNT(*) AS record_count
FROM opencellid_raw
WHERE radio = 'UMTS'
GROUP BY update_month
ORDER BY update_month;


-- 12. UMTS May 2026 Daily Updates by Network
-- Break down UMTS updates in May 2026 by day and network code.
-- Identify which networks contributed to the update activity.
-- Examine whether the spike was concentrated on specific dates.

SELECT
    DATE_TRUNC('day', TO_TIMESTAMP(updated)) as update_day,
    net,
    COUNT(*) AS record_count
FROM opencellid_raw
WHERE radio = 'UMTS' AND EXTRACT(MONTH FROM update_day) = 5 AND EXTRACT(YEAR FROM update_day) = 2026
GROUP BY update_day, net
ORDER BY update_day;


-- 13. Creation History of UMTS Records Updated in May 2026
-- Examine the original creation dates of UMTS records updated in May 2026.
-- Group records by their creation month and year.
-- Determine whether the update activity involved newly created or older records.

SELECT
    STRFTIME(TO_TIMESTAMP(created), '%Y-%m') AS create_month_year,
    COUNT(*) AS record_count
FROM opencellid_raw
WHERE radio = 'UMTS' AND DATE_TRUNC('month', TO_TIMESTAMP(updated)) = DATE '2026-05-01'
GROUP BY create_month_year
ORDER BY create_month_year;


-- 14. Creation and Update Timestamp Comparison
-- Compare creation and update timestamps for UMTS records updated in May 2026.
-- Count records with identical and different timestamps.
-- Assess whether the observed activity primarily reflects subsequent updates.

SELECT
    COUNT(*) AS record_count,
    SUM(CASE WHEN updated = created THEN 1 ELSE 0 END) AS same_date,
    SUM(CASE WHEN updated = created THEN 0 ELSE 1 END) AS diff_date
FROM opencellid_raw
WHERE radio = 'UMTS' AND DATE_TRUNC('month', TO_TIMESTAMP(updated)) = DATE '2026-05-01';