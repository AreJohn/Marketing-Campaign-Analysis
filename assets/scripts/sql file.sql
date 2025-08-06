-- Step 1: Create the Database 
CREATE DATABASE campaign_analysis;

-- Step 2: Create the main table to store campaign data
CREATE TABLE campaigndata (
    campaign_id SERIAL PRIMARY KEY,
    company TEXT,
    campaign_type TEXT,
    target_audience TEXT,
    duration TEXT,
    channel_used TEXT,
    conversion_rate NUMERIC(5,4),     -- Allows up to 4 decimal places
    acquisition_cost MONEY,
    roi NUMERIC(5,2),
    location TEXT,
    date DATE,
    clicks INTEGER,
    impressions INTEGER,
    engagement_score INTEGER,
    customer_segment TEXT
);


-- Step 3: Import data from CSV using /COPY
-- Ensure the data has the same Date Formating
BEGIN;
SET datestyle TO ISO, DMY;

-- Run this in the pSQL CLI to import the data
\COPY public.campaigndata (campaign_id, company, campaign_type, target_audience, duration, channel_used, conversion_rate, acquisition_cost, roi, location, date, clicks, impressions, engagement_score, customer_segment) FROM 'C:/Users/marketing_campaign_dataset.csv' DELIMITER ',' CSV HEADER QUOTE '"' ESCAPE '''';

-- View the data
SELECT *
FROM campaigndata;

-- Step 4: Start running the analysis

-- Q1: What Campaign had the highest Impressions?
SELECT campaign_id, SUM(impressions) AS totalimpressions
FROM campaigndata
GROUP BY campaign_id
ORDER BY totalimpressions DESC; 

-- Q2: What Campaign had the highest Highest ROI?
SELECT campaign_id, company, roi
FROM campaigndata
ORDER BY ROI DESC
LIMIT 1;

-- Q3: What are the Top 3 Locations with the highest Total Impressions
SELECT location, SUM(impressions) AS totalimpressions
FROM campaigndata
GROUP BY Location
ORDER BY totalimpressions DESC
LIMIT 3;

-- Q4:  What Target Audience has the Average Engagement Score?
SELECT target_audience, AVG(engagement_score) AS avgengagementscore
FROM campaigndata
GROUP BY target_audience
ORDER BY avgengagementscore DESC;

-- Q5:What is the Overall Click-Through Rate (CTR) of all campaigns ran?
SELECT (SUM(clicks) * 100.0) / SUM(impressions) AS overallctr
FROM campaigndata;

-- Q6: Most Cost-Effective Campaign (Lowest Cost per Conversion)
SELECT campaign_id, company, 
    (CAST(REPLACE(REPLACE(acquisition_cost::TEXT, '$', ''), ',', '') AS NUMERIC) / (conversion_rate * clicks)) AS costperconversion
FROM campaigndata
ORDER BY costperconversion ASC;

-- Q7: Top Campaigns with CTR Above A Threshold 95%
SELECT 
    campaign_id, 
    company, 
    (SUM(clicks) * 100.0) / SUM(impressions) AS ctr
FROM campaigndata
GROUP BY campaign_id, company
HAVING (SUM(clicks) * 100.0) / SUM(impressions) > 5
ORDER BY ctr DESC;

-- Q8: Total Conversions by Channel (Clicks * Conversion Rate)
SELECT
    Channel_Used,
    SUM(Clicks * Conversion_Rate) AS TotalConversions
FROM campaigndata
GROUP BY Channel_Used
ORDER BY TotalConversions DESC;