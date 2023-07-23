CREATE DATABASE IF NOT EXISTS hw5_base;
USE hw5_base;

CREATE TABLE cars
(
	id INT NOT NULL PRIMARY KEY,
    name VARCHAR(45),
    cost INT
);

INSERT cars
VALUES
	(1, "Audi", 52642),
    (2, "Mercedes", 57127 ),
    (3, "Skoda", 9000 ),
    (4, "Volvo", 29000),
	(5, "Bentley", 350000),
    (6, "Citroen ", 21000 ), 
    (7, "Hummer", 41400), 
    (8, "Volkswagen ", 21600);
    
SELECT *
FROM cars;

-- Создадим представление, в которое попадут автомобили стоимостью до 25 000 долларов

CREATE VIEW price_up_to_25000 AS
SELECT *
FROM cars
WHERE cost <= 25000;

SELECT *
FROM price_up_to_25000;

-- Изменим в существующем представлении порог для стоимости: 
-- пусть цена будет до 30 000 долларов (используя оператор OR REPLACE)

CREATE OR REPLACE VIEW price_up_to_25000 AS
SELECT *
FROM cars
WHERE cost <= 30000;

SELECT *
FROM price_up_to_25000;

-- Создадим представление, в котором будут только автомобили марки “Шкода” и “Ауди”

CREATE VIEW skoda_and_audi AS
SELECT *
FROM cars
WHERE name IN ('Skoda', 'Audi');

SELECT *
FROM skoda_and_audi;

-- Добавим новый столбец под названием «время до следующей станции». 
-- Чтобы получить это значение, мы вычитаем время станций для пар смежных станций. 
-- Мы можем вычислить это значение без использования оконной функции SQL, но это может быть очень сложно. 
-- Проще это сделать с помощью оконной функции LEAD . Эта функция сравнивает значения из одной строки со следующей строкой, чтобы получить результат. 
-- В этом случае функция сравнивает значения в столбце «время» для станции со станцией сразу после нее.

DROP TABLE schedule; 
CREATE TABLE IF NOT EXISTS `schedule` (
	`train_id` INT,
    `station` VARCHAR (20),
    `station_time` TIME
);

INSERT INTO `schedule`
VALUES 
		(110, "San Francisco", '10:00:00'),
        (110, "Redwood city", '10:54:00'),
        (110, "Palo Alto", '11:02:00'),
        (110, "San Jose", '12:35:00'),
        (120, "San Francisco", '11:00:00'),
        (120, "Palo Alto", '12:49:00'),
        (120, "San Jose", '13:30:00');

SELECT * FROM schedule;

ALTER TABLE schedule
ADD COLUMN time_to_next_station TIME;

SELECT * FROM schedule;

UPDATE schedule
SET time_to_next_station = TIMEDIFF(LEAD(station_time) OVER (PARTITION BY train_id ORDER BY station_time), station_time);

-- Здесь выдает ошибку 3593.

SELECT s1.train_id, s1.station, s1.station_time, TIMEDIFF(s2.station_time, s1.station_time) AS time_to_next_station
FROM schedule s1
JOIN schedule s2 ON s1.train_id = s2.train_id AND s2.station_time > s1.station_time
ORDER BY s1.train_id, s1.station_time;