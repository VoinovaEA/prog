--Задание 2.
	--Сравнить цену текущего товара с ценой следующего по дороговизне товара того же типа (LEAD по base_msrp)

SELECT
    product_id,
    product_type,
    base_msrp,
    LEAD(base_msrp, 1) OVER(PARTITION BY product_type ORDER BY base_msrp) 
FROM products;
