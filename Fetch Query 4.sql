WITH user_activity AS (
SELECT t.user_id, COUNT(t.receipt_id) AS transaction_count,
       SUM(t.final_sale * t.final_quantity) AS total_spent,
       MAX(t.purchase_date) AS last_purchase_date
FROM transactions t
LEFT JOIN users u ON u.u_id = t.user_id
WHERE (t.purchase_date >= u.created_date OR u.created_date IS NULL)          
      AND t.barcode IS NOT NULL                  -- Exclude transactions with missing barcode
GROUP BY t.user_id
)
SELECT ua.user_id, ua.transaction_count, ua.total_spent
FROM user_activity ua
WHERE ua.transaction_count >= 5						       -- Setting the criterion for the number of transactions
      AND ua.total_spent > 30								   -- Setting the criterion for the total amount spent
	  AND ua.last_purchase_date >= NOW() - INTERVAL '6 months'-- Setting the criterion for activity
ORDER BY ua.transaction_count DESC, ua.total_spent DESC;                          -- Order by total spent
