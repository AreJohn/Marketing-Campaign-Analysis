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
##### After meeting with the executive team at the marketing agency, including the Head of Performance, Audience Strategy Lead, CMO, and Growth Marketing Manager. It was clear that this analysis needed to serve real business decision-making, not just generic metrics. Each stakeholder had distinct goals, and the questions were shaped around their priorities:

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

1. The data did not conatin duplicates
2. The data did not contain blanks

## Stakeholder-Focused Analysis
##### With a clean, validated dataset, I used SQL L to answer the business-critical questions, mapped directly to the needs of key stakeholders within the marketing agency.
##### Each group below includes:  
##### - The business question  
##### - A concise insight  
##### - A collapsible SQL block showing how the answer was derived

#### 📈 Performance Marketing Manager
##### Focus: Cost efficiency, ROI optimization, and platform performance.
##### 1. **Which campaigns achieved the highest return per $1 spent, normalized by duration and impressions?**
**Insight:** Campaigns run on YouTube and Email platforms for 30–45 days produced the highest ROI per impression, especially those from **Alpha Innovations**.

<details>
<summary>📜 SQL</summary>

```sql
SELECT campaign_id, company, roi, impressions, duration,
       ROUND(roi / NULLIF(impressions, 0), 4) AS roi_per_impression
FROM campaigndata
ORDER BY roi_per_impression DESC
LIMIT 10;
````

</details>

---

#### 2. **Which channels deliver the most conversions per 1,000 impressions?**

🧠 **Insight:** **Email and Website** outperformed Facebook and Display in conversions per 1,000 impressions, indicating more qualified traffic.

<details>
<summary>📜 SQL</summary>

```sql
SELECT channel_used,
       ROUND(SUM(clicks * conversion_rate) * 1000.0 / NULLIF(SUM(impressions), 0), 2) AS conversions_per_1000_impressions
FROM campaigndata
GROUP BY channel_used
ORDER BY conversions_per_1000_impressions DESC;
```

</details>

---

#### 3. **What is the cost per conversion trend by platform over time?**

🧠 **Insight:** **Facebook’s cost per conversion is increasing steadily**, while **Email and YouTube remain cost-stable** across time.

<details>
<summary>📜 SQL</summary>

```sql
SELECT channel_used, DATE_TRUNC('month', date) AS month,
       ROUND(SUM(acquisition_cost::numeric) / NULLIF(SUM(clicks * conversion_rate), 0), 2) AS cost_per_conversion
FROM campaigndata
GROUP BY channel_used, month
ORDER BY month, channel_used;
```

</details>

---

#### 4. **Which campaigns combine high CTR (>10%) and high ROI (>5x)?**

🧠 **Insight:** **Alpha Innovations** had 3 of the top 10 high-CTR, high-ROI campaigns. Most used Email or Instagram.

<details>
<summary>📜 SQL</summary>

```sql
SELECT campaign_id, company, roi, clicks, impressions,
       ROUND((clicks * 100.0) / NULLIF(impressions, 0), 2) AS ctr
FROM campaigndata
WHERE roi > 5
  AND (clicks * 100.0 / NULLIF(impressions, 0)) > 10
ORDER BY roi DESC;
```

</details>

---

#### 5. **Which platform has the best engagement-adjusted ROI?**

🧠 **Insight:** **YouTube** outperformed other platforms when adjusting ROI by engagement score.

<details>
<summary>📜 SQL</summary>

```sql
SELECT channel_used,
       ROUND(AVG(roi * engagement_score), 2) AS adjusted_roi
FROM campaigndata
GROUP BY channel_used
ORDER BY adjusted_roi DESC;
```

</details>

---

### 👥 Audience Strategist

Focus: Best audience-platform combinations and engagement insights.

---

#### 6. **Which audience + segment pairing converted most efficiently?**

🧠 **Insight:** “Men 25–34” in the **Health & Wellness** segment had the **highest conversion efficiency** when reached via Email or Google Ads.

<details>
<summary>📜 SQL</summary>

```sql
SELECT target_audience, customer_segment,
       ROUND(SUM(clicks * conversion_rate) * 100.0 / NULLIF(SUM(impressions), 0), 2) AS conversion_efficiency
FROM campaigndata
GROUP BY target_audience, customer_segment
ORDER BY conversion_efficiency DESC
LIMIT 10;
```

</details>

---

#### 7. **Which segments show high impressions but low engagement?**

🧠 **Insight:** **“Outdoor Adventurers”** had consistently high impressions but ranked lowest in engagement scores.

<details>
<summary>📜 SQL</summary>

```sql
SELECT customer_segment, SUM(impressions) AS total_impressions,
       ROUND(AVG(engagement_score), 2) AS avg_engagement
FROM campaigndata
GROUP BY customer_segment
ORDER BY avg_engagement ASC
LIMIT 5;
```

</details>

---

#### 8. **What audience-platform pairs consistently outperform?**

🧠 **Insight:** **Women 25–34** on Instagram and YouTube delivered high CTR and conversion rates across campaigns.

<details>
<summary>📜 SQL</summary>

```sql
SELECT target_audience, channel_used,
       ROUND(AVG(conversion_rate * 100), 2) AS avg_conversion_rate,
       ROUND(AVG(engagement_score), 2) AS avg_engagement
FROM campaigndata
GROUP BY target_audience, channel_used
ORDER BY avg_conversion_rate DESC
LIMIT 10;
```

</details>

#### 9. **How does conversion rate vary across audience types and platforms?**

🧠 **Insight:** The **Men 25–34** audience consistently showed high conversion rates on **YouTube** and **Email**, while **All Ages** campaigns underperformed across most platforms.

<details>
<summary>📜 SQL</summary>

```sql
SELECT target_audience, channel_used,
       ROUND(AVG(conversion_rate * 100), 2) AS avg_conversion_rate
FROM campaigndata
GROUP BY target_audience, channel_used
ORDER BY avg_conversion_rate DESC;
````

</details>

---

### 💰 Finance / CMO

#### Focus: Budget effectiveness and strategic reallocation of marketing spend

---

#### 10. **Which companies spent the most—and did that investment justify the return?**

🧠 **Insight:** While **TechCorp** had the highest spend, **Alpha Innovations** delivered **higher ROI per dollar** spent.

<details>
<summary>📜 SQL</summary>

```sql
SELECT company,
       SUM(acquisition_cost::numeric) AS total_spend,
       ROUND(AVG(roi), 2) AS avg_roi
FROM campaigndata
GROUP BY company
ORDER BY total_spend DESC;
```

</details>

---

#### 11. **Which channels show ROI declines as acquisition cost increases?**

🧠 **Insight:** **Facebook** and **Display** campaigns showed **declining ROI trends** at higher acquisition cost levels, while **Email** remained stable.

<details>
<summary>📜 SQL</summary>

```sql
SELECT channel_used,
       ROUND(CORR(acquisition_cost::numeric, roi), 2) AS roi_cost_correlation
FROM campaigndata
GROUP BY channel_used
ORDER BY roi_cost_correlation ASC;
```

</details>

---

#### 13. **If the budget were reduced by 30%, which campaigns could be paused with minimal impact on conversions?**

🧠 **Insight:** Campaigns with **high cost and low conversion efficiency** (especially on Display and Facebook) were flagged as **low-priority** under budget cuts.

<details>
<summary>📜 SQL</summary>

```sql
SELECT campaign_id, company, channel_used,
       acquisition_cost::numeric AS cost,
       ROUND(clicks * conversion_rate, 2) AS conversions,
       ROUND((clicks * conversion_rate) / NULLIF(acquisition_cost::numeric, 0), 4) AS conv_per_dollar
FROM campaigndata
ORDER BY conv_per_dollar ASC
LIMIT 10;
```

</details>

---

#### 15. **Which regions consistently underperform or overperform and should have budgets scaled accordingly?**

🧠 **Insight:** **Miami and Chicago** had strong ROI and conversion rates, while **Houston** and **Phoenix** underperformed despite high spend.

<details>
<summary>📜 SQL</summary>

```sql
SELECT location,
       ROUND(AVG(roi), 2) AS avg_roi,
       ROUND(SUM(clicks * conversion_rate), 2) AS total_conversions,
       SUM(acquisition_cost::numeric) AS total_spend
FROM campaigndata
GROUP BY location
ORDER BY avg_roi DESC;
```

</details>

---

### 📊 Growth & Strategy Team

#### Focus: Uncovering low-cost, high-return campaign opportunities

---

#### 16. **Which campaigns delivered strong engagement and conversion outcomes on a limited budget?**

🧠 **Insight:** Campaigns by **Innovate Industries** and **Alpha Innovations** stood out with **low spend but high conversion-adjusted engagement**.

<details>
<summary>📜 SQL</summary>

```sql
SELECT campaign_id, company, acquisition_cost::numeric AS cost,
       ROUND(engagement_score * conversion_rate, 2) AS engagement_conversion_score
FROM campaigndata
WHERE acquisition_cost::numeric < 10000
ORDER BY engagement_conversion_score DESC
LIMIT 10;
```

</details>

---

#### 17. **What underutilized platforms offer untapped potential in terms of engagement-adjusted ROI?**

🧠 **Insight:** Despite fewer campaigns, **Website** and **Instagram** had some of the **highest engagement-adjusted ROIs**, signaling underused opportunities.

<details>
<summary>📜 SQL</summary>

```sql
SELECT channel_used,
       COUNT(*) AS campaign_count,
       ROUND(AVG(roi * engagement_score), 2) AS engagement_roi
FROM campaigndata
GROUP BY channel_used
ORDER BY engagement_roi DESC;
```

</details>

#### 🧾[Download the complete SQL analysis script](./sql/campaign_analysis.sql)

---

## 📊 Visual Summary & Executive Dashboard

To make the insights actionable for stakeholders, I created a clean, stakeholder-facing dashboard in Google Sheets.

The dashboard includes:
- 📈 ROI and conversion trends by platform and location
- 📊 Audience performance vs. campaign spend
- 💰 Cost-efficiency breakdown by company and segment
- 🧠 Engagement vs. ROI scatter analysis

📎 [View the full Google Sheets dashboard here](https://link-to-your-dashboard)

> *Each tab is structured around stakeholder roles (Performance, Audience, Finance, Growth) for clarity.*
