WITH user_generation AS (
SELECT u_id,
       CASE 
            
            WHEN birth_date::DATE BETWEEN DATE '1900-01-01' AND DATE '1945-12-31' THEN 'Silent Generation'
            WHEN birth_date::DATE BETWEEN DATE '1946-01-01' AND DATE '1964-12-31' THEN 'Baby Boomer'
            WHEN birth_date::DATE BETWEEN DATE '1965-01-01' AND DATE '1980-12-31' THEN 'Generation X'
            WHEN birth_date::DATE BETWEEN DATE '1981-01-01' AND DATE '1996-12-31' THEN 'Millennial'
            WHEN birth_date::DATE >= DATE '1997-01-01' THEN 'Generation Z'
            ELSE 'Other'
END AS generation
FROM users
),
category_sales AS (
SELECT u.generation, SUM(CAST(t.final_sale AS DECIMAL)) AS total_sales,
        SUM(CASE WHEN p.category_1 = 'Health & Wellness' 
		THEN CAST(t.final_sale AS DECIMAL) ELSE 0 END) AS health_wellness_sales
FROM transactions t
LEFT JOIN products p ON t.barcode = p.barcode
JOIN user_generation u ON t.user_id = u.u_id
WHERE t.barcode IS NOT NULL OR p.brand IS NOT NULL
GROUP BY u.generation
)
SELECT generation,
	   COALESCE((health_wellness_sales / NULLIF(total_sales, 0)) * 100, 0)
	   AS health_wellness_percentage
FROM category_sales
ORDER BY health_wellness_percentage DESC;
