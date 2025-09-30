CREATE DATABASE mini_project;
DROP DATABASE mini_project;

CREATE TABLE mini_project.t_tab1
(
	id INT NOT NULL AUTO_INCREMENT,
    goods_type VARCHAR(30),
    quantity INT NOT NULL,
    amount INT NOT NULL,
    seller_name VARCHAR(20) NOT NULL,
    
    PRIMARY KEY(id)
);

INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Mobile phone', 2, 400000, 'Mike');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Keyboard', 1, 10000, 'Mike');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Mobile phone', 1, 50000, 'Jane');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Monitor', 1, 110000, 'Joe');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Monitor', 2, 80000, 'Jane');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Mobile phone', 1, 130000, 'Joe');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Mobile phone', 1, 60000, 'Anna');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Printer', 1, 90000, 'Anna');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Keyboard', 2, 10000, 'Anna');
INSERT INTO mini_project.t_tab1 (goods_type, quantity, amount, seller_name)
VALUES ('Printer', 1, 80000, 'Mike');

CREATE TABLE mini_project.t_tab2
(
	id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(20),
    salary INT NOT NULL,
    age INT,
    
    PRIMARY KEY(id)
);

INSERT INTO mini_project.t_tab2 (name, salary, age)
VALUES ('Anna', 110000, 27);
INSERT INTO mini_project.t_tab2 (name, salary, age)
VALUES ('Jane', 80000, 25);
INSERT INTO mini_project.t_tab2 (name, salary, age)
VALUES ('Mike', 120000, 25);
INSERT INTO mini_project.t_tab2 (name, salary, age)
VALUES ('Joe', 70000, 24);
INSERT INTO mini_project.t_tab2 (name, salary, age)
VALUES ('Rita', 120000, 29);

SELECT * FROM mini_project.t_tab1;
SELECT * FROM mini_project.t_tab2;

# DELETE FROM mini_project.t_tab1;
# DELETE FROM mini_project.t_tab2;

/* 1. Напишите запрос, который вернёт список уникальных категорий товаров (GOODS_TYPE).
	Какое количество уникальных категорий товаров вернёт запрос? */
SELECT DISTINCT goods_type,
(SELECT COUNT(DISTINCT goods_type) FROM mini_project.t_tab1) AS total_categories
FROM mini_project.t_tab1;
# Ответ: 4.

/* 2. Напишите запрос, который вернет суммарное количество и суммарную стоимость проданных
	мобильных телефонов. Какое суммарное количество и суммарную стоимость вернул запрос? */
SELECT goods_type, SUM(quantity) AS quantity_sold,
SUM(amount) AS amount_sold
FROM mini_project.t_tab1
WHERE goods_type = 'Mobile phone';
# Ответ: суммарное количество - 5, суммарная стоимость - 640000.

/* 3. Напишите запрос, который вернёт список сотрудников с заработной платой > 100000.
	Какое кол-во сотрудников вернул запрос? */
SELECT id, name, COUNT(id) OVER() AS num_of_employees
FROM mini_project.t_tab2
WHERE salary > 100000;
# Ответ: 3.

/* 4. Напишите запрос, который вернёт минимальный и максимальный возраст сотрудников,
	а также минимальную и максимальную заработную плату. */
SELECT MIN(age) AS min_age,
MAX(age) AS max_age,
MIN(salary) AS min_salary,
MAX(salary) AS max_salary
FROM mini_project.t_tab2; 

/* 5. Напишите запрос, который вернёт среднее количество проданных клавиатур и принтеров. */
SELECT goods_type, ROUND(AVG(quantity), 2) AS avg_quantity_sold
FROM mini_project.t_tab1
WHERE goods_type = 'Printer' OR
goods_type = 'Keyboard'
GROUP BY goods_type
ORDER BY avg_quantity_sold DESC;

/* 6. Напишите запрос, который вернёт имя сотрудника и суммарную стоимость проданных им товаров. */
SELECT seller_name, SUM(amount) AS total_amount_sold
FROM mini_project.t_tab1
GROUP BY seller_name;

/* 7. Напишите запрос, который вернёт имя сотрудника, тип товара, кол-во товара, стоимость товара,
	заработную плату и возраст сотрудника MIKE. */
SELECT e.name, s.goods_type, s.quantity, s.amount, e.salary, e.age
FROM mini_project.t_tab1 s
JOIN mini_project.t_tab2 e
ON s.seller_name = e.name
ORDER BY e.name;

/* 8. Напишите запрос, который вернёт имя и возраст сотрудника, который ничего не продал.
	Сколько таких сотрудников? */
SELECT name, age, COUNT(name) OVER() AS num_emp_not_selling
FROM mini_project.t_tab2
WHERE name IN (
	SELECT seller_name 
    FROM mini_project.t_tab1 )
IS NOT TRUE;
# Ответ: 1.

/* 9. Напишите запрос, который вернёт имя сотрудника и его заработную плату с возрастом
	меньше 26 лет? Какое количество строк вернул запрос? */
SELECT name, salary, COUNT(name) OVER() AS num_of_emps_younger_26
FROM mini_project.t_tab2
WHERE age < 26;
# Ответ: 3.

/* 10. Сколько строк вернёт следующий запрос:
SELECT * FROM T_TAB1 t
JOIN T_TAB2 t2 ON t2.name = t.seller_name
WHERE t2.name = 'RITA';
Ответ: 0, так как тут используется Inner Join, нет пересечения строк
по ключу имени, так как 'Rita' не совершила продаж, следовательно этот
запрос не выдаст никаких строк. */