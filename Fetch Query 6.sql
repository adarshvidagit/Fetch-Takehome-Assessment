WITH yearly_new_users AS (
SELECT EXTRACT(YEAR FROM u.created_date) AS yr,
       COUNT(DISTINCT u.u_id) AS new_users_count
FROM users u
GROUP BY yr
),
total_transactions AS (
SELECT EXTRACT(YEAR FROM u.created_date) AS yr,
       COUNT(t.receipt_id) AS total_transactions
FROM users u
LEFT JOIN transactions t ON u.u_id = t.user_id
GROUP BY yr
),
yearly_data AS (
SELECT y.yr, y.new_users_count,
       COALESCE(tt.total_transactions, 0) AS total_transactions
FROM yearly_new_users y
LEFT JOIN total_transactions tt ON y.yr = tt.yr
),
cumulative_data AS (
SELECT yr, new_users_count, total_transactions,
        -- Calculating the cumulative sums for new users and transactions
        SUM(new_users_count) OVER (ORDER BY yr) AS cumulative_new_users,
        SUM(total_transactions) OVER (ORDER BY yr) AS cumulative_total_transactions
FROM yearly_data
)
SELECT yr, new_users_count, total_transactions,
    -- Calculating YoY cumulative growth for new users, handling zero in previous cumulative values
CASE WHEN LAG(cumulative_new_users) OVER (ORDER BY yr) > 0 THEN 
     ROUND((cumulative_new_users - LAG(cumulative_new_users) 
	 OVER (ORDER BY yr)) / LAG(cumulative_new_users) OVER (ORDER BY yr) * 100, 2)
     ELSE NULL 
END AS cumulative_new_user_growth_percentage,
    -- Calculating YoY cumulative growth for total transactions, handling zero in previous cumulative values
CASE WHEN LAG(cumulative_total_transactions) OVER (ORDER BY yr) > 0 THEN 
     ROUND((cumulative_total_transactions - LAG(cumulative_total_transactions)
	 OVER (ORDER BY yr)) / LAG(cumulative_total_transactions) OVER (ORDER BY yr) * 100, 2)
     ELSE NULL 
END AS cumulative_total_transactions_growth_percentage
FROM cumulative_data
ORDER BY yr;
