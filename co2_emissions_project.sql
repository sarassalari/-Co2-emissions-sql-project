-- ============================================================
-- Project: Power Sector CO2 Emissions Tracking
-- Built in MySQL via DBeaver.
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Create the database
-- ------------------------------------------------------------
CREATE DATABASE co2_emissions;
USE co2_emissions;


-- ------------------------------------------------------------
-- STEP 2: Create the staging table (raw_emissions)
--
-- Mirrors the raw CSV exactly. Every column is text (VARCHAR),
-- even the numeric value column -- because the source file has
-- the literal text "Not Available" in some rows instead of a
-- number. A real numeric column would reject that and crash
-- the import.
-- ------------------------------------------------------------
CREATE TABLE raw_emissions (
    msn            VARCHAR(20),
    yyyymm         VARCHAR(10),
    value_raw      VARCHAR(20),
    column_order   VARCHAR(5),
    description    VARCHAR(255),
    unit           VARCHAR(100)
);


-- ------------------------------------------------------------
-- STEP 3: Load the CSV into raw_emissions
-- ------------------------------------------------------------
-- STEP 4: Create the clean table (emissions)
--
-- This is the table actual reporting/analysis runs against:
-- proper data types, year/month split into real numbers, and
-- a UNIQUE KEY that prevents duplicate rows from ever existing.
-- ------------------------------------------------------------
CREATE TABLE emissions (
    emission_id     INT AUTO_INCREMENT PRIMARY KEY,
    source_code     VARCHAR(20)    NOT NULL,
    source_name     VARCHAR(255)   NOT NULL,
    year            SMALLINT       NOT NULL,
    month           TINYINT        NOT NULL,
    emissions_value DECIMAL(10,3)  NULL,
    unit            VARCHAR(100)   NOT NULL,
    UNIQUE KEY uq_source_year_month (source_code, year, month)
);


-- ------------------------------------------------------------
-- STEP 5: Clean the data -- move it from raw_emissions into emissions
--
-- This single query fixes every problem found in the raw data:
--
-- 1. ANNUAL TOTALS DISGUISED AS MONTH "13"
--    Every year had a fake 13th "month" that was actually the
--    year's total, not a real month. Left in, it would wreck
--    any monthly average or trend. Removed via the WHERE clause.
--
-- 2. "Not Available" TEXT INSTEAD OF NULL
--    416 rows had the literal text "Not Available" where a
--    number should be. Converted to true NULL so it's correctly
--    excluded from sums/averages instead of crashing or being
--    misread as zero.
--
-- 3. YYYYMM SPLIT INTO REAL YEAR + MONTH
--    "197301" becomes year = 1973, month = 1 -- enabling real
--    date filtering, grouping, and year-over-year comparisons.
-- ------------------------------------------------------------
INSERT INTO emissions (source_code, source_name, year, month, emissions_value, unit)
SELECT
    msn AS source_code,
    description AS source_name,
    CAST(LEFT(yyyymm, 4) AS UNSIGNED) AS year,
    CAST(RIGHT(yyyymm, 2) AS UNSIGNED) AS month,
    CASE
        WHEN value_raw = 'Not Available' THEN NULL
        ELSE CAST(value_raw AS DECIMAL(10,3))
    END AS emissions_value,
    unit
FROM raw_emissions
WHERE RIGHT(yyyymm, 2) <> '13';


-- ------------------------------------------------------------
-- VERIFICATION QUERIES
-- Sanity checks run after cleaning, before trusting the data.
-- ------------------------------------------------------------

-- Should be 4,707 (5,094 raw rows minus 387 annual-total rows)
SELECT COUNT(*) AS clean_row_count FROM emissions;

-- Should only show 1 through 12 -- confirms no fake "month 13" rows survived
SELECT DISTINCT month FROM emissions ORDER BY month;

-- Should be 384 (416 "Not Available" rows minus 32 that were inside
-- the annual-total rows we excluded above)
SELECT COUNT(*) AS null_value_count FROM emissions WHERE emissions_value IS NULL;


-- ------------------------------------------------------------
-- STEP 6: Analysis -- client-facing reporting queries
-- ------------------------------------------------------------

-- Q1: Total emissions by source, all-time
-- "Which fuel sources have contributed the most to our footprint?"
-- TXEIEUS is excluded -- it's the EIA's own pre-calculated grand
-- total across all sources, not a fuel source itself.
SELECT
    source_name,
    ROUND(SUM(emissions_value), 1) AS total_emissions_mmt_co2
FROM emissions
WHERE source_code <> 'TXEIEUS'
GROUP BY source_name
ORDER BY total_emissions_mmt_co2 DESC;

-- Q2: Year-over-year trend for coal, the dominant source
-- "Is coal's contribution rising or falling over time?"
SELECT
    year,
    ROUND(SUM(emissions_value), 1) AS annual_coal_emissions
FROM emissions
WHERE source_code = 'CLEIEUS'
GROUP BY year
ORDER BY year;

-- Q3: Fossil fuel vs. low-carbon sources, all-time comparison
-- "How does clean energy generation compare to fossil fuels?"
SELECT
    CASE
        WHEN source_code IN ('GEEIEUS', 'NWEIEUS') THEN 'Low-Carbon (Geothermal/Waste)'
        WHEN source_code = 'TXEIEUS' THEN 'TOTAL (exclude from comparison)'
        ELSE 'Fossil Fuel'
    END AS category,
    ROUND(SUM(emissions_value), 1) AS total_emissions_mmt_co2
FROM emissions
GROUP BY category
ORDER BY total_emissions_mmt_co2 DESC;
