# Data-Driven Optimization of Multi-Channel Marketing Campaigns
## Table Of Contents
- [Business Context](#Business-Context)
- [Project Goal](#Project-Goal)
- [Tools](#Tools)
- [Business Questions](#Business-Questions)
- [Data Preparation & Cleaning](#Data-Preparation-&-Cleaning)

## Business Context
##### A national performance marketing agency running campaigns for multiple clients across Google Ads, YouTube, Facebook, Email, and Display channels needed to evaluate the **efficiency and ROI** of their digital strategies.
##### They manage over **200,000+ campaigns** with diverse audience targeting, channel strategies, and customer segments across locations. The marketing leadership team needed to know:
##### - Which audiences are actually converting?
##### - Where should we scale or cut spend?
##### - Which platforms offer the best bang for our buck?
##### As a Marketing Analyst consultant, I was brought in to analyze their campaign data and deliver **clear, actionable recommendations** through **SQL-driven analysis** and **clean executive-facing visuals**.

## Project Goal
##### To evaluate the **return on investment (ROI)** and **efficiency** of paid marketing efforts across platforms, audiences, and locations—enabling smarter budget reallocation and campaign strategy decisions.

## Tools

| Tool         | Purpose                                   |
|--------------|-------------------------------------------|
| **PostgreSQL**  | Database creation, data loading, SQL querying |
| **Google Sheets** | Data visualizations and executive summary |

## Business Questions
#### After meeting with the executive team at the marketing agency, including the Head of Performance, Audience Strategy Lead, CMO, and Growth Marketing Manager. It was clear that this analysis needed to serve real business decision-making, not just generic metrics. Each stakeholder had distinct goals, and the questions were shaped around their priorities:

### 📈 Performance Marketing Manager
#### Focus: Cost efficiency, ROI optimization, and platform performance
##### 1. Which campaigns achieved the highest return per $1 spent, normalized by duration and impressions?
##### 2. Which channels deliver the most conversions for every 1,000 impressions?
##### 3. What is the cost per conversion trend by platform over time?
##### 4. Which campaigns combine high CTR (>10%) and high ROI (>5x)?
##### 5. Which platform has the best engagement-adjusted ROI?

### 👥 Audience Strategist
#### Focus: Identifying the best-performing audience segments and combinations
##### 6. Which segment + audience pairing (e.g., “Health & Wellness” + “Men 25–34”) converted most efficiently?
##### 7. Which segments show high impressions but poor engagement?
##### 8. What audience-platform pairings outperform others in both ROI and CTR?
##### 9. How does conversion rate vary across audience types and platforms?

### 💰 Finance / CMO
#### Focus: Budget effectiveness and strategic reallocation of marketing spend
##### 10. Which companies spent the most and did that investment justify the return?
##### 11. Which channels show ROI declines as acquisition cost increases?
##### 13. If the budget were reduced by 30%, which campaigns could be paused with minimal impact on conversions?
##### 15. Which regions consistently underperform or overperform and should have budgets scaled accordingly?

### 📊 Growth & Strategy Team
#### Focus: Uncovering low-cost, high-return campaign opportunities
##### 16. Which campaigns delivered strong engagement and conversion outcomes on a limited budget?
##### 17. What underutilized platforms offer untapped potential in terms of engagement-adjusted ROI?

---

## Data Preparation & Cleaning
##### Once the project goals and business questions were defined, the next step was to prepare the campaign data for analysis in **PostgreSQL**. This involved setting up a new database, defining a table schema with appropriate data types, and importing the dataset using the `/COPY` command.

#### 🗄️ PostgreSQL Database Setup

```sql
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
    conversion_rate NUMERIC(5,4),
    acquisition_cost MONEY,
    roi NUMERIC(5,2),
    location TEXT,
    date DATE,
    clicks INTEGER,
    impressions INTEGER,
    engagement_score INTEGER,
    customer_segment TEXT
);
```

#### Data Import from CSV
##### The raw dataset was imported from a .csv file using the /COPY command in the psql CLI.
To avoid issues with date parsing (e.g. 13/01/2021 being misinterpreted), the datestyle was explicitly set to ISO, DMY.

```sql
-- Changing the datestyle to DMY
BEGIN;
SET datestyle TO ISO, DMY;

-- Run in psql CLI to import the data
\COPY public.campaigndata (
    campaign_id, company, campaign_type, target_audience, duration,
    channel_used, conversion_rate, acquisition_cost, roi, location,
    date, clicks, impressions, engagement_score, customer_segment
)
FROM 'C:/Users/marketing_campaign_dataset.csv'
DELIMITER ',' CSV HEADER QUOTE '"' ESCAPE '''';
```

#### Initial Data Review
##### After successful import, the first step was to explore the structure and quality of the data.

```sql
SELECT * FROM campaigndata LIMIT 20;
```
#### Data Quality Checks

##### Before diving into deeper analysis, I performed a series of data quality checks to ensure the dataset was accurate, consistent, and analysis-ready. These checks are crucial in a business environment where decisions are made based on data — and even small data issues can lead to misleading insights.
##### Key Quality Checks Performed

| Check Type           | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| ✅ **Missing Values**        | Checked for any NULLs in key metrics like `clicks`, `impressions`, `roi`, `acquisition_cost` |
| ✅ **Duplicates**           | Verified uniqueness of `campaign_id` and removed duplicates if found |
| ✅ **Incorrect Data Types** | Confirmed that `conversion_rate`, `roi`, and `acquisition_cost` used numeric-compatible types |
| ✅ **Invalid Zero Values**  | Flagged campaigns with `0` impressions or `0` clicks where conversions > 0 (illogical cases) |
| ✅ **Outlier Detection**    | Checked for campaigns with unusually high or low `conversion_rate`, `roi`, or `acquisition_cost` |
| ✅ **Currency Consistency** | Verified all `acquisition_cost` values were correctly interpreted as currency (no text symbols) |

#### 🧰 Sample SQL Queries Used for Checks

<details>
<summary>Check for NULLs</summary>

```sql
-- Check for missing values in key columns
SELECT 
    COUNT(*) FILTER (WHERE clicks IS NULL) AS null_clicks,
    COUNT(*) FILTER (WHERE impressions IS NULL) AS null_impressions,
    COUNT(*) FILTER (WHERE roi IS NULL) AS null_roi,
    COUNT(*) FILTER (WHERE acquisition_cost IS NULL) AS null_cost
FROM campaigndata;
```
</details>

 <details> <summary>Check for Duplicate Campaign IDs</summary>

```sql
SELECT campaign_id, COUNT(*) 
FROM campaigndata
GROUP BY campaign_id
HAVING COUNT(*) > 1;
```
</details> 

<details> <summary>Find Zero or Illogical Values</summary>

```sql
-- Campaigns with conversions but zero clicks or impressions
SELECT *
FROM campaigndata
WHERE (clicks = 0 OR impressions = 0) AND conversion_rate > 0;
```
</details> 

<details> <summary>Identify Outliers (High ROI)</summary>

```sql
-- Flag campaigns with extremely high ROI for manual review
SELECT *
FROM campaigndata
WHERE roi > 1000 OR roi < 0;
```
</details>
