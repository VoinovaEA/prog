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
