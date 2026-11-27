--Лабараторная 4
	--Вариант 2
	--Задание 1.
	--Пронумеровать (ROW_NUMBER) продажи (sales) для каждого клиента, упорядочив их по дате транзакции (от новых к старым)

	SELECT 
    customer_id, 
    sales_transaction_date, 
    sales_amount,
    ROW_NUMBER() OVER(ORDER BY sales_transaction_date DESC) 
FROM sales
ORDER BY sales_transaction_date DESC;

	--Задание 2.
	--Сравнить цену текущего товара с ценой следующего по дороговизне товара того же типа (LEAD по base_msrp)

SELECT
    product_id,
    product_type,
    base_msrp,
    LEAD(base_msrp, 1) OVER(PARTITION BY product_type ORDER BY base_msrp) 
FROM products;

--Задание 3.
--Вычислить средний чек (AVG(sales_amount)) накопительным итогом для каждого канала продаж (channel).


SELECT
    sales_amount,
    sales_transaction_date,
    channel,
    AVG(sales_amount) OVER (PARTITION BY channel ORDER BY sales_transaction_date) 
FROM sales;

 

 
