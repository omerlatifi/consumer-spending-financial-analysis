-- ============================================
-- PROJECT  : Consumer Spending & Financial
--            Health Analysis
-- DATASET  : Indian Personal Finance Dataset
--            Kaggle — 20,000 rows
-- ============================================
-- SKILLS DEMONSTRATED:
-- GROUP BY, UNION ALL, CASE WHEN, HAVING,
-- Subqueries, CTEs, RANK(), LAG(), NTILE(),
-- Window Functions, Conditional Aggregations
-- ============================================


-- ============================================
-- QUERY 1: FINANCIAL HEALTH OVERVIEW
-- Skill   : GROUP BY, Aggregations, ROUND
-- Purpose : Segment 20,000 people by
--           financial health category
-- ============================================

SELECT
    financial_health                          AS Health_Category,
    COUNT(*)                                  AS Total_People,
    ROUND(COUNT(*) * 100.0 / 20000, 1)       AS Percentage,
    ROUND(AVG(income), 0)                     AS Avg_Income,
    ROUND(AVG(total_expenses), 0)             AS Avg_Expenses,
    ROUND(AVG(actual_savings), 0)             AS Avg_Savings,
    ROUND(AVG(savings_rate), 1)               AS Avg_Savings_Rate
FROM finance
GROUP BY financial_health
ORDER BY Total_People DESC;


-- ============================================
-- QUERY 2: TOP SPENDING CATEGORIES
-- Skill   : AVG, ROUND, UNION ALL, ORDER BY
-- Purpose : Identify which categories drain
--           the most money from income
-- ============================================

SELECT
    'Rent'           AS Category,
    ROUND(AVG(rent), 0)              AS Avg_Amount,
    ROUND(AVG(rent) * 100.0
          / AVG(income), 1)          AS Pct_Of_Income
FROM finance
UNION ALL
SELECT 'Groceries',
    ROUND(AVG(groceries), 0),
    ROUND(AVG(groceries) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Transport',
    ROUND(AVG(transport), 0),
    ROUND(AVG(transport) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Utilities',
    ROUND(AVG(utilities), 0),
    ROUND(AVG(utilities) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Education',
    ROUND(AVG(education), 0),
    ROUND(AVG(education) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Loan Repayment',
    ROUND(AVG(loan_repayment), 0),
    ROUND(AVG(loan_repayment) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Healthcare',
    ROUND(AVG(healthcare), 0),
    ROUND(AVG(healthcare) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Eating Out',
    ROUND(AVG(eating_out), 0),
    ROUND(AVG(eating_out) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Insurance',
    ROUND(AVG(insurance), 0),
    ROUND(AVG(insurance) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Entertainment',
    ROUND(AVG(entertainment), 0),
    ROUND(AVG(entertainment) * 100.0
          / AVG(income), 1)
FROM finance
UNION ALL
SELECT 'Miscellaneous',
    ROUND(AVG(miscellaneous), 0),
    ROUND(AVG(miscellaneous) * 100.0
          / AVG(income), 1)
FROM finance
ORDER BY Avg_Amount DESC;


-- ============================================
-- QUERY 3: SPENDING BEHAVIOR CLASSIFICATION
-- Skill   : CASE WHEN, GROUP BY, COUNT
-- Purpose : Classify every person's spending
--           behavior and identify patterns
--           across the entire population
-- ============================================

SELECT
    CASE
        WHEN rent / income > 0.40
            THEN 'Severe Rent Burden'
        WHEN rent / income > 0.30
            THEN 'High Rent Burden'
        WHEN rent / income > 0.20
            THEN 'Moderate Rent Burden'
        ELSE 'Manageable Rent'
    END                              AS Rent_Category,
    CASE
        WHEN savings_rate >= 30
            THEN 'Excellent Saver'
        WHEN savings_rate >= 20
            THEN 'Good Saver'
        WHEN savings_rate >= 10
            THEN 'Moderate Saver'
        WHEN savings_rate >= 0
            THEN 'Poor Saver'
        ELSE 'Negative Saver'
    END                              AS Savings_Category,
    CASE
        WHEN (eating_out + entertainment
              + miscellaneous) / income > 0.20
            THEN 'Heavy Lifestyle Spender'
        WHEN (eating_out + entertainment
              + miscellaneous) / income > 0.10
            THEN 'Moderate Lifestyle Spender'
        ELSE 'Controlled Lifestyle Spender'
    END                              AS Lifestyle_Category,
    COUNT(*)                         AS Total_People,
    ROUND(AVG(income), 0)            AS Avg_Income,
    ROUND(AVG(actual_savings), 0)    AS Avg_Savings,
    ROUND(AVG(savings_rate), 1)      AS Avg_Savings_Rate
FROM finance
GROUP BY
    Rent_Category,
    Savings_Category,
    Lifestyle_Category
ORDER BY Total_People DESC
LIMIT 15;


-- ============================================
-- QUERY 4: HIGH RISK SEGMENTS DETECTION
-- Skill   : HAVING, GROUP BY, Multiple
--           Aggregations, Conditional COUNT
-- Purpose : Detect which city-occupation
--           combinations are financially
--           most dangerous
-- ============================================

SELECT
    city_tier                            AS City,
    occupation                           AS Occupation,
    COUNT(*)                             AS Total_People,
    ROUND(AVG(income), 0)               AS Avg_Income,
    ROUND(AVG(total_expenses), 0)       AS Avg_Expenses,
    ROUND(AVG(actual_savings), 0)       AS Avg_Savings,
    ROUND(AVG(savings_rate), 1)         AS Avg_Savings_Rate,
    ROUND(AVG(rent), 0)                 AS Avg_Rent,
    ROUND(AVG(rent) * 100.0
          / AVG(income), 1)             AS Rent_Pct_Income,
    COUNT(CASE WHEN financial_health
          = 'At Risk' THEN 1 END)       AS At_Risk_Count,
    ROUND(COUNT(CASE WHEN financial_health
          = 'At Risk' THEN 1 END)
          * 100.0 / COUNT(*), 1)        AS At_Risk_Pct
FROM finance
GROUP BY
    city_tier,
    occupation
HAVING
    COUNT(*) >= 100
    AND AVG(savings_rate) < 20
    AND AVG(total_expenses)
        > AVG(income) * 0.75
ORDER BY
    At_Risk_Pct DESC,
    Avg_Savings_Rate ASC;


-- ============================================
-- QUERY 5: ABOVE AVERAGE EARNERS ANALYSIS
-- Skill   : Subquery, WHERE, Nested SELECT
-- Purpose : Compare above vs below average
--           earners financial behavior
-- ============================================

SELECT
    earner_type                          AS Earner_Type,
    COUNT(*)                             AS Total_People,
    ROUND(AVG(income), 0)               AS Avg_Income,
    ROUND(AVG(total_expenses), 0)       AS Avg_Expenses,
    ROUND(AVG(actual_savings), 0)       AS Avg_Savings,
    ROUND(AVG(savings_rate), 1)         AS Avg_Savings_Rate,
    ROUND(AVG(rent), 0)                 AS Avg_Rent,
    ROUND(AVG(groceries), 0)            AS Avg_Groceries,
    COUNT(CASE WHEN financial_health
        = 'Healthy' THEN 1 END)         AS Healthy_Count,
    COUNT(CASE WHEN financial_health
        = 'At Risk' THEN 1 END)         AS At_Risk_Count,
    ROUND(COUNT(CASE WHEN financial_health
        = 'Healthy' THEN 1 END)
        * 100.0 / COUNT(*), 1)          AS Healthy_Pct,
    ROUND(COUNT(CASE WHEN financial_health
        = 'At Risk' THEN 1 END)
        * 100.0 / COUNT(*), 1)          AS At_Risk_Pct
FROM (
    SELECT
        *,
        CASE
            WHEN income > (
                SELECT AVG(income)
                FROM finance
            )
            THEN 'Above Average Earner'
            ELSE 'Below Average Earner'
        END AS earner_type
    FROM finance
) AS classified_earners
GROUP BY earner_type
ORDER BY Avg_Income DESC;


-- ============================================
-- QUERY 6: COMPLETE CITY TIER FINANCIAL REPORT
-- Skill   : Multiple Aggregations, ROUND,
--           Conditional COUNT, Arithmetic
-- Purpose : Build a complete boardroom-ready
--           financial summary by city tier
-- ============================================

SELECT
    city_tier                                    AS City_Tier,
    COUNT(*)                                     AS Total_People,
    ROUND(MIN(income), 0)                        AS Min_Income,
    ROUND(AVG(income), 0)                        AS Avg_Income,
    ROUND(MAX(income), 0)                        AS Max_Income,
    ROUND(AVG(total_expenses), 0)               AS Avg_Expenses,
    ROUND(AVG(rent), 0)                         AS Avg_Rent,
    ROUND(AVG(rent) * 100.0
          / AVG(income), 1)                     AS Rent_Pct_Income,
    ROUND(AVG(groceries), 0)                    AS Avg_Groceries,
    ROUND(AVG(transport), 0)                    AS Avg_Transport,
    ROUND(AVG(actual_savings), 0)               AS Avg_Savings,
    ROUND(MIN(actual_savings), 0)               AS Min_Savings,
    ROUND(MAX(actual_savings), 0)               AS Max_Savings,
    ROUND(AVG(savings_rate), 1)                 AS Avg_Savings_Rate,
    COUNT(CASE WHEN financial_health
        = 'Healthy'  THEN 1 END)                AS Healthy_Count,
    COUNT(CASE WHEN financial_health
        = 'Moderate' THEN 1 END)                AS Moderate_Count,
    COUNT(CASE WHEN financial_health
        = 'At Risk'  THEN 1 END)                AS At_Risk_Count,
    ROUND(COUNT(CASE WHEN financial_health
        = 'Healthy' THEN 1 END)
        * 100.0 / COUNT(*), 1)                  AS Healthy_Pct,
    ROUND(COUNT(CASE WHEN financial_health
        = 'At Risk' THEN 1 END)
        * 100.0 / COUNT(*), 1)                  AS At_Risk_Pct,
    ROUND(AVG(desired_savings), 0)              AS Avg_Desired_Savings,
    ROUND(AVG(desired_savings)
        - AVG(actual_savings), 0)               AS Savings_Gap,
    ROUND(AVG(eating_out
        + entertainment
        + miscellaneous), 0)                    AS Avg_Lifestyle_Spend,
    ROUND(AVG(eating_out
        + entertainment
        + miscellaneous) * 100.0
        / AVG(income), 1)                       AS Lifestyle_Pct_Income
FROM finance
GROUP BY city_tier
ORDER BY Avg_Savings_Rate DESC;


-- ============================================
-- QUERY 7: FINANCIAL HEALTH CTE ANALYSIS
-- Skill   : CTE, WITH clause, Multi-step
--           Analysis, CROSS JOIN
-- Purpose : Use CTEs to build a clean
--           multi-step age group analysis
-- ============================================

WITH age_summary AS (
    SELECT
        age_group,
        COUNT(*)                          AS Total_People,
        ROUND(AVG(income), 0)            AS Avg_Income,
        ROUND(AVG(total_expenses), 0)    AS Avg_Expenses,
        ROUND(AVG(actual_savings), 0)    AS Avg_Savings,
        ROUND(AVG(savings_rate), 1)      AS Avg_Savings_Rate,
        ROUND(AVG(rent), 0)              AS Avg_Rent,
        COUNT(CASE WHEN financial_health
            = 'At Risk' THEN 1 END)      AS At_Risk_Count,
        ROUND(COUNT(CASE WHEN financial_health
            = 'At Risk' THEN 1 END)
            * 100.0 / COUNT(*), 1)       AS At_Risk_Pct
    FROM finance
    GROUP BY age_group
),
overall_avg AS (
    SELECT
        ROUND(AVG(income), 0)            AS Overall_Avg_Income,
        ROUND(AVG(savings_rate), 1)      AS Overall_Avg_Savings_Rate,
        ROUND(AVG(actual_savings), 0)    AS Overall_Avg_Savings
    FROM finance
),
age_performance AS (
    SELECT
        a.age_group,
        a.Total_People,
        a.Avg_Income,
        a.Avg_Expenses,
        a.Avg_Savings,
        a.Avg_Savings_Rate,
        a.Avg_Rent,
        a.At_Risk_Count,
        a.At_Risk_Pct,
        o.Overall_Avg_Income,
        o.Overall_Avg_Savings_Rate,
        o.Overall_Avg_Savings,
        CASE
            WHEN a.Avg_Income > o.Overall_Avg_Income
            THEN 'Above Average Income'
            ELSE 'Below Average Income'
        END AS Income_Performance,
        CASE
            WHEN a.Avg_Savings_Rate >= 30
            THEN 'Excellent Saver'
            WHEN a.Avg_Savings_Rate >= 20
            THEN 'Good Saver'
            WHEN a.Avg_Savings_Rate >= 10
            THEN 'Moderate Saver'
            ELSE 'Poor Saver'
        END AS Savings_Performance,
        ROUND(a.Avg_Income
            - o.Overall_Avg_Income, 0)   AS Income_Gap,
        ROUND(a.Avg_Savings_Rate
            - o.Overall_Avg_Savings_Rate,
            1)                           AS Savings_Rate_Gap
    FROM age_summary a
    CROSS JOIN overall_avg o
)
SELECT
    age_group                   AS Age_Group,
    Total_People,
    Avg_Income,
    Overall_Avg_Income,
    Income_Gap,
    Income_Performance,
    Avg_Savings_Rate,
    Overall_Avg_Savings_Rate,
    Savings_Rate_Gap,
    Savings_Performance,
    Avg_Rent,
    At_Risk_Count,
    At_Risk_Pct
FROM age_performance
ORDER BY Avg_Savings_Rate DESC;


-- ============================================
-- QUERY 8: RANKING BY FINANCIAL PERFORMANCE
-- Skill   : Window Functions, RANK(),
--           ROW_NUMBER(), NTILE(), COUNT OVER
-- Purpose : Rank every person within their
--           age group by savings rate
-- ============================================

WITH ranked_people AS (
    SELECT
        age_group,
        occupation,
        city_tier,
        income_group,
        financial_health,
        ROUND(income, 0)              AS Income,
        ROUND(total_expenses, 0)      AS Total_Expenses,
        ROUND(actual_savings, 0)      AS Actual_Savings,
        ROUND(savings_rate, 1)        AS Savings_Rate,
        RANK() OVER (
            PARTITION BY age_group
            ORDER BY savings_rate DESC
        )                             AS Rank_In_Age_Group,
        ROW_NUMBER() OVER (
            PARTITION BY age_group
            ORDER BY savings_rate DESC
        )                             AS Row_Num,
        RANK() OVER (
            ORDER BY savings_rate DESC
        )                             AS Overall_Rank,
        NTILE(4) OVER (
            PARTITION BY age_group
            ORDER BY savings_rate DESC
        )                             AS Quartile,
        RANK() OVER (
            PARTITION BY city_tier
            ORDER BY income DESC
        )                             AS Income_Rank_In_City,
        COUNT(*) OVER (
            PARTITION BY age_group
        )                             AS Total_In_Age_Group
    FROM finance
),
quartile_classified AS (
    SELECT
        *,
        CASE Quartile
            WHEN 1 THEN 'Top 25% Performer'
            WHEN 2 THEN 'Above Average'
            WHEN 3 THEN 'Below Average'
            WHEN 4 THEN 'Bottom 25% Performer'
        END                           AS Performance_Tier
    FROM ranked_people
)
SELECT
    age_group                         AS Age_Group,
    occupation                        AS Occupation,
    city_tier                         AS City_Tier,
    income_group                      AS Income_Group,
    financial_health                  AS Financial_Health,
    Income,
    Total_Expenses,
    Actual_Savings,
    Savings_Rate,
    Rank_In_Age_Group,
    Total_In_Age_Group,
    Overall_Rank,
    Quartile,
    Performance_Tier
FROM quartile_classified
WHERE Rank_In_Age_Group <= 5
ORDER BY
    age_group ASC,
    Rank_In_Age_Group ASC;


-- ============================================
-- QUERY 9: INCOME GROUP PROGRESSION ANALYSIS
-- Skill   : LAG() Window Function,
--           COALESCE, CTE, CASE ordering
-- Purpose : Measure how financial metrics
--           change as income increases
-- ============================================

WITH income_summary AS (
    SELECT
        income_group,
        COUNT(*)                              AS Total_People,
        ROUND(AVG(income), 0)                AS Avg_Income,
        ROUND(AVG(total_expenses), 0)        AS Avg_Expenses,
        ROUND(AVG(actual_savings), 0)        AS Avg_Savings,
        ROUND(AVG(savings_rate), 1)          AS Avg_Savings_Rate,
        ROUND(AVG(rent), 0)                  AS Avg_Rent,
        ROUND(AVG(groceries), 0)             AS Avg_Groceries,
        ROUND(AVG(eating_out
            + entertainment
            + miscellaneous), 0)             AS Avg_Lifestyle,
        COUNT(CASE WHEN financial_health
            = 'At Risk' THEN 1 END)          AS At_Risk_Count,
        ROUND(COUNT(CASE WHEN financial_health
            = 'At Risk' THEN 1 END)
            * 100.0 / COUNT(*), 1)           AS At_Risk_Pct,
        ROUND(AVG(total_potential_savings),0) AS Avg_Potential_Savings
    FROM finance
    GROUP BY income_group
),
income_ordered AS (
    SELECT
        *,
        CASE income_group
            WHEN 'Very Low' THEN 1
            WHEN 'Low'      THEN 2
            WHEN 'Medium'   THEN 3
            WHEN 'High'     THEN 4
            WHEN 'Very High'THEN 5
        END                                  AS Sort_Order
    FROM income_summary
),
lag_analysis AS (
    SELECT
        income_group,
        Sort_Order,
        Total_People,
        Avg_Income,
        Avg_Expenses,
        Avg_Savings,
        Avg_Savings_Rate,
        Avg_Rent,
        Avg_Lifestyle,
        At_Risk_Pct,
        Avg_Potential_Savings,
        LAG(Avg_Income) OVER (
            ORDER BY Sort_Order
        )                                    AS Prev_Avg_Income,
        LAG(Avg_Expenses) OVER (
            ORDER BY Sort_Order
        )                                    AS Prev_Avg_Expenses,
        LAG(Avg_Savings) OVER (
            ORDER BY Sort_Order
        )                                    AS Prev_Avg_Savings,
        LAG(Avg_Savings_Rate) OVER (
            ORDER BY Sort_Order
        )                                    AS Prev_Savings_Rate,
        LAG(At_Risk_Pct) OVER (
            ORDER BY Sort_Order
        )                                    AS Prev_At_Risk_Pct
    FROM income_ordered
),
progression AS (
    SELECT
        Income_Group,
        Total_People,
        Avg_Income,
        Avg_Expenses,
        Avg_Savings,
        Avg_Savings_Rate,
        Avg_Rent,
        Avg_Lifestyle,
        At_Risk_Pct,
        Avg_Potential_Savings,
        ROUND(Avg_Income
            - COALESCE(Prev_Avg_Income, Avg_Income),
            0)                               AS Income_Jump,
        ROUND(Avg_Expenses
            - COALESCE(Prev_Avg_Expenses, Avg_Expenses),
            0)                               AS Expense_Jump,
        ROUND(Avg_Savings
            - COALESCE(Prev_Avg_Savings, Avg_Savings),
            0)                               AS Savings_Jump,
        ROUND(Avg_Savings_Rate
            - COALESCE(Prev_Savings_Rate, Avg_Savings_Rate),
            1)                               AS Savings_Rate_Change,
        ROUND(At_Risk_Pct
            - COALESCE(Prev_At_Risk_Pct, At_Risk_Pct),
            1)                               AS Risk_Change,
        ROUND(Avg_Expenses * 100.0
            / Avg_Income, 1)                 AS Expense_Pct_Income,
        CASE
            WHEN ROUND(Avg_Income
                - COALESCE(Prev_Avg_Income,
                    Avg_Income), 0) = 0
            THEN 'Base Group'
            WHEN ROUND(Avg_Expenses
                - COALESCE(Prev_Avg_Expenses,
                    Avg_Expenses), 0)
                > ROUND(Avg_Income
                - COALESCE(Prev_Avg_Income,
                    Avg_Income), 0) * 0.75
            THEN 'Lifestyle Inflation — Expenses Absorb 75%+ of Raise'
            WHEN ROUND(Avg_Expenses
                - COALESCE(Prev_Avg_Expenses,
                    Avg_Expenses), 0)
                > ROUND(Avg_Income
                - COALESCE(Prev_Avg_Income,
                    Avg_Income), 0) * 0.50
            THEN 'Moderate Inflation — Expenses Absorb 50-75% of Raise'
            ELSE 'Controlled — Savings Absorb Most of Raise'
        END                                  AS Raise_Behavior
    FROM lag_analysis
)
SELECT
    Income_Group,
    Total_People,
    Avg_Income,
    Avg_Expenses,
    Expense_Pct_Income,
    Avg_Savings,
    Avg_Savings_Rate,
    Income_Jump,
    Expense_Jump,
    Savings_Jump,
    Savings_Rate_Change,
    Risk_Change,
    Avg_Potential_Savings,
    Raise_Behavior
FROM progression
ORDER BY
    CASE Income_Group
        WHEN 'Very Low'  THEN 1
        WHEN 'Low'       THEN 2
        WHEN 'Medium'    THEN 3
        WHEN 'High'      THEN 4
        WHEN 'Very High' THEN 5
    END;


-- ============================================
-- QUERY 10: COMPLETE FINANCIAL INTELLIGENCE
-- Skill   : CTE + Window Functions + CASE
--           WHEN + Subquery + Aggregations
--           + RANK + NTILE + LAG + ROUND
-- Purpose : Complete financial intelligence
--           scoring system — the masterpiece
-- ============================================

WITH base_metrics AS (
    SELECT
        occupation,
        city_tier,
        age_group,
        income_group,
        financial_health,
        ROUND(income, 0)                     AS Income,
        ROUND(total_expenses, 0)             AS Total_Expenses,
        ROUND(actual_savings, 0)             AS Actual_Savings,
        ROUND(savings_rate, 1)               AS Savings_Rate,
        ROUND(rent, 0)                       AS Rent,
        ROUND(groceries, 0)                  AS Groceries,
        ROUND(eating_out
            + entertainment
            + miscellaneous, 0)              AS Lifestyle_Spend,
        ROUND(total_potential_savings, 0)    AS Potential_Savings,
        ROUND(loan_repayment, 0)             AS Loan_Repayment,
        ROUND(rent * 100.0 / income, 1)      AS Rent_Burden_Pct,
        ROUND((eating_out + entertainment
            + miscellaneous)
            * 100.0 / income, 1)             AS Lifestyle_Pct,
        ROUND(total_expenses
            * 100.0 / income, 1)             AS Expense_Ratio
    FROM finance
),
scored_people AS (
    SELECT
        *,
        ROUND(
            CASE
                WHEN Savings_Rate >= 40 THEN 40
                WHEN Savings_Rate >= 30 THEN 32
                WHEN Savings_Rate >= 20 THEN 24
                WHEN Savings_Rate >= 10 THEN 16
                WHEN Savings_Rate >= 0  THEN 8
                ELSE 0
            END
            + CASE
                WHEN Rent_Burden_Pct <= 15 THEN 30
                WHEN Rent_Burden_Pct <= 25 THEN 22
                WHEN Rent_Burden_Pct <= 35 THEN 14
                WHEN Rent_Burden_Pct <= 45 THEN 7
                ELSE 0
            END
            + CASE
                WHEN Lifestyle_Pct <= 5  THEN 20
                WHEN Lifestyle_Pct <= 10 THEN 15
                WHEN Lifestyle_Pct <= 15 THEN 10
                WHEN Lifestyle_Pct <= 20 THEN 5
                ELSE 0
            END
            + CASE
                WHEN Loan_Repayment = 0             THEN 10
                WHEN Loan_Repayment / Income <= 0.10 THEN 7
                WHEN Loan_Repayment / Income <= 0.20 THEN 4
                ELSE 0
            END
        , 0)                                 AS Financial_Score
    FROM base_metrics
),
ranked_scored AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY Financial_Score DESC
        )                                    AS Overall_Rank,
        RANK() OVER (
            PARTITION BY age_group
            ORDER BY Financial_Score DESC
        )                                    AS Rank_In_Age_Group,
        RANK() OVER (
            PARTITION BY city_tier
            ORDER BY Financial_Score DESC
        )                                    AS Rank_In_City,
        RANK() OVER (
            PARTITION BY occupation
            ORDER BY Financial_Score DESC
        )                                    AS Rank_In_Occupation,
        ROUND(
            RANK() OVER (
                ORDER BY Financial_Score DESC
            ) * 100.0 / COUNT(*) OVER (), 1
        )                                    AS Score_Percentile,
        NTILE(5) OVER (
            ORDER BY Financial_Score DESC
        )                                    AS Performance_Tier,
        ROUND(AVG(Financial_Score) OVER (
            PARTITION BY age_group
        ), 1)                                AS Avg_Score_In_Age_Group,
        ROUND(AVG(Financial_Score) OVER (
            PARTITION BY city_tier
        ), 1)                                AS Avg_Score_In_City,
        ROUND(Financial_Score - AVG(Financial_Score) OVER (
            PARTITION BY age_group
        ), 1)                                AS Score_Vs_Age_Avg,
        COUNT(*) OVER (
            PARTITION BY age_group
        )                                    AS Total_In_Age_Group
    FROM scored_people
),
final_classified AS (
    SELECT
        *,
        CASE Performance_Tier
            WHEN 1 THEN 'Elite — Top 20%'
            WHEN 2 THEN 'Strong — Top 40%'
            WHEN 3 THEN 'Average — Middle 20%'
            WHEN 4 THEN 'Weak — Bottom 40%'
            WHEN 5 THEN 'Critical — Bottom 20%'
        END                                  AS Performance_Label,
        CASE
            WHEN Financial_Score >= 80 THEN 'A — Excellent'
            WHEN Financial_Score >= 65 THEN 'B — Good'
            WHEN Financial_Score >= 50 THEN 'C — Average'
            WHEN Financial_Score >= 35 THEN 'D — Below Average'
            ELSE 'F — Critical'
        END                                  AS Score_Grade,
        CASE
            WHEN Rent_Burden_Pct > 40
            THEN 'Priority: Reduce housing cost immediately'
            WHEN Savings_Rate < 10
            THEN 'Priority: Build emergency fund first'
            WHEN Lifestyle_Pct > 20
            THEN 'Priority: Cut lifestyle spending'
            WHEN Loan_Repayment / Income > 0.20
            THEN 'Priority: Focus on debt reduction'
            WHEN Savings_Rate >= 30
            THEN 'On Track: Consider investment options'
            ELSE 'Maintain: Small optimizations needed'
        END                                  AS Top_Recommendation
    FROM ranked_scored
)
SELECT
    age_group                    AS Age_Group,
    occupation                   AS Occupation,
    city_tier                    AS City_Tier,
    income_group                 AS Income_Group,
    financial_health             AS Financial_Health,
    Income,
    Total_Expenses,
    Actual_Savings,
    Savings_Rate,
    Rent_Burden_Pct,
    Lifestyle_Pct,
    Financial_Score,
    Score_Grade,
    Overall_Rank,
    Score_Percentile,
    Rank_In_Age_Group,
    Total_In_Age_Group,
    Avg_Score_In_Age_Group,
    Score_Vs_Age_Avg,
    Avg_Score_In_City,
    Performance_Label,
    Top_Recommendation
FROM final_classified
ORDER BY Financial_Score DESC
LIMIT 20;
