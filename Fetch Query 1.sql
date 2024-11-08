SELECT p.brand, COUNT(t.receipt_id) AS receipt_count
FROM users u    
LEFT JOIN transactions t ON u.u_id = t.user_id
LEFT JOIN products p ON t.barcode = p.barcode
WHERE DATE_PART('year', AGE(t.scan_date, u.birth_date)) >= 21 AND p.brand IS NOT NULL	
GROUP BY p.brand
ORDER BY receipt_count DESC
LIMIT 5;