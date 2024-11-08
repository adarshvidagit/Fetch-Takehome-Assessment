SELECT p.brand, SUM(t.final_sale * final_quantity) AS total_sales
FROM users u
RIGHT JOIN transactions t ON u.u_id = t.user_id
INNER JOIN products p ON t.barcode = p.barcode
WHERE t.purchase_date >= u.created_date + INTERVAL '6 months' 
GROUP BY p.brand
ORDER BY total_sales DESC
LIMIT 5;

