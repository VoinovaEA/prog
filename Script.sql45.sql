--Задание 3.
--Вычислить средний чек (AVG(sales_amount)) накопительным итогом для каждого канала продаж (channel).


SELECT
    sales_amount,
    sales_transaction_date,
    channel,
    AVG(sales_amount) OVER (PARTITION BY channel ORDER BY sales_transaction_date) 
FROM sales;

 
