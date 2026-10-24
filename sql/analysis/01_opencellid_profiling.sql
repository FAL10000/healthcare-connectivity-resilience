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