-- ========================================================
-- ЛР 5 Вариант 2
-- ========================================================

-- --------------------------------------------------------------------
-- Задача 1. Задание 1 (Анализ на сервере)
-- Найти товары (products) типа product_type = 'scooter'. (Индекс B-Tree)
------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT * 
FROM products 
WHERE product_type = 'scooter';

--Задание 2* (Индекс локально)
--	Найти товары (products) типа product_type = 'scooter'. (Индекс B-Tree)

SET enable_seqscan = off;
DROP INDEX IF EXISTS idx_products_product_type;
CREATE INDEX idx_products_product_type 
ON products (product_type);

EXPLAIN ANALYZE
SELECT *
FROM products
WHERE product_type = 'scooter';

--Задание 3* (Сложная оптимизация локально - JOIN/Range) 
--Оптимизировать поиск клиентов с postal_code = '33111'.
DROP INDEX IF EXISTS idx_postal_code;
CREATE INDEX idx_postal_code ON customers(postal_code);

SELECT 
    customer_id,
	postal_code,
	ip_address,
	date_added
FROM customers c      
JOIN (                 
  SELECT '33111' AS target_code
) t                  
ON c.postal_code = t.target_code; 


SELECT 
    customer_id,
	postal_code,
	ip_address,
	date_added
FROM customers 
WHERE postal_code >= '33111' AND postal_code <= '33111';


