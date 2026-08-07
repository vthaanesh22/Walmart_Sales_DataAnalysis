# 🛒 Walmart Sales Data Analysis using SQL

An end-to-end data analytics project that demonstrates how SQL can be used to transform raw Walmart sales data into actionable business insights. The project covers data preparation using Python, feature engineering, exploratory data analysis (EDA), and business analytics using MySQL.

---

## 📌 Project Overview

The objective of this project is to analyze Walmart sales transactions and answer real-world business questions that support better decision-making. The project follows a complete analytics workflow from data preparation to business reporting.

---

## 🚀 Project Workflow

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/d4c515bd-e973-4254-8b5d-a8a2f409a7a7" />


---

## 🎯 Project Objectives

- Clean and prepare the Walmart sales dataset.
- Perform feature engineering for better analysis.
- Analyze customer purchasing behavior.
- Evaluate branch and product category performance.
- Compare yearly revenue (2025 vs 2026).
- Generate business insights using SQL.

---

## 🛠️ Technologies Used

- Python
- Pandas
- PyMySQL
- SQLAlchemy
- MySQL
- MySQL Workbench
- Git & GitHub

---

## 📂 Repository Structure

```text
Walmart_Sales_DataAnalysis/
│
├── README.md
├── requirements.txt
│
├── data/
│   ├── Walmart.csv
│   └── Walmart_cleaned.csv
│
├── sql/
│   └── Walmart_Sales_Analysis.sql
│
├── notebooks/
│   └── data_preparation.ipynb
│
├── docs/
│   └── Walmart_SQL_Business_Problems.pdf
│
└── images/
    └── walmart_project_workflow.png
```

---

## ⚙️ Project Phases

### Phase 1 – Data Preparation

- Imported the Walmart sales dataset.
- Cleaned and validated the data using Python.
- Loaded the cleaned dataset into MySQL.
- Created additional columns:
  - `shift`
  - `day_name`
  - `month_name`
- Generated a modified 2026 dataset for Year-over-Year analysis.

### Phase 2 – Business Analysis

The project answers 15 real-world business questions, including:

- Payment method analysis
- Highest-rated category by branch
- Busiest day by branch
- Sales shift analysis
- Profit analysis by category
- Revenue comparison (2025 vs 2026)
- Executive business dashboard

---

## 💡 SQL Concepts Used

- SELECT
- WHERE
- GROUP BY
- ORDER BY
- Aggregate Functions
- CASE Statement
- Date Functions
- Window Functions
- RANK()
- Common Table Expressions (CTE)
- Joins

---

## 📈 Key Business Insights

- Identified the most preferred payment methods.
- Ranked product categories based on profitability.
- Determined peak shopping days and sales shifts.
- Compared branch revenue across two years.
- Identified high-performing and low-performing branches.
- Created an executive dashboard summarizing key business KPIs.

---

## 📄 Documentation

The complete list of business questions and their objectives is available in:

- `docs/Walmart_SQL_Business_Problems.pdf`

---
