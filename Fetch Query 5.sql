WITH dipandsal_sales AS (
    SELECT
        p.brand,
        COUNT(t.receipt_id) AS num_sales,                       -- Number of sales
        SUM(t.final_sale * t.final_quantity) AS total_sales_value  -- Total sales value
    FROM
        transactions t
    LEFT JOIN 
        products p ON t.barcode = p.barcode -- Join to get product information based on barcode
    WHERE 
        t.barcode IS NOT NULL               -- Excluding transactions with missing barcodes
        AND t.final_sale IS NOT NULL        -- Ensure we have a valid price for sales calculation
        AND p.category_2 = 'Dips & Salsa'   -- Filtering for "Dips & Salsa" in category_2
    GROUP BY 
        p.brand                             --Grouping the calculations based on brand
)
SELECT 
    brand,
    num_sales,
    total_sales_value
FROM 
    dipandsal_sales
ORDER BY 
    total_sales_value DESC,     -- Order by total sales value first
    num_sales DESC              -- Order by the number of sales as a secondary criterion
LIMIT 1;                        -- Get the top brand
