-- ---------------------------------------------------------------------------- --
--                       LIMPIEZA DE DATOS SQL                                  --
-- ---------------------------------------------------------------------------- --

create database if not exists clean;

use clean;

select * from limpieza limit 10;
select * from limpieza;

DELIMITER //
CREATE PROCEDURE limp()
BEGIN
select * from limpieza;
END //
DELIMITER ;

CALL limp();

ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` id_emp VARCHAR(20) NULL;
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender VARCHAR(20) NULL;


select id_emp, count(*) as cantidad_duplicados
from limpieza 
group by id_emp
having count(*) > 1;

select count(*) as cantidad_duplicados
from(
select id_emp, count(*) as cantidad_duplicados
from limpieza 
group by id_emp
having count(*) > 1
) as subquery;

rename table limpieza to conduplicados;

CREATE TEMPORARY TABLE Temp_limpieza AS
SELECT DISTINCT * FROM conduplicados;

select count(*) as original from conduplicados;
select count(*) as original from tem_limpieza;

CREATE TABLE LIMPIEZA AS SELECT * FROM TEMP_LIMPIEZA;
CALL LIMP();
DROP TABLE CONDUPLICADOS;
SET sql_safe_updates = 0;

ALTER TABLE limpieza CHANGE COLUMN Apellido last_name varchar (50) null;
ALTER TABLE limpieza CHANGE COLUMN star_date star_date varchar (50) null;

DESCRIBE LIMPIEZA;

CALL LIMP();

SELECT name FROM limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

SELECT name, trim(name) as name
from limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

UPDATE LIMPIEZA SET NAME = TRIM(NAME)
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

SELECT last_name, trim(last_name) as last_name
from limpieza
WHERE LENGTH(last_name) - LENGTH(TRIM(last_name)) > 0;

UPDATE LIMPIEZA SET last_name = trim(last_name)
WHERE LENGTH(last_name) - LENGTH(TRIM(last_name)) > 0;

UPDATE limpieza SET area = REPLACE(area,' ','   ');
call limp();

SELECT AREA FROM LIMPIEZA
WHERE AREA regexp `\\s{2,}`;

SELECT area, trim(regexp_replace(area, `\\s+`,``)) as ensayo from limpieza;
UPDATE limpieza SET area = trim(regexp_replace(area, `\\s+`,``));
call limp();


SELECT gender ,
CASE 
when Gender = 'hombre' then 'male'
when Gender = 'mujer' then 'female'
else 'other'
END AS gender1
FROM limpieza;

UPDATE limpieza SET gender = CASE
when Gender = 'hombre' then 'male'
when Gender = 'mujer' then 'female'
else 'other'
 END;
call limp();

DESCRIBE LIMPIEZA;
ALTER TABLE LIMPIEZA MODIFY COLUMN type TEXT;

SELECT TYPE,
CASE 
when type = 1 then 'Remote'
when type = 0 then 'Hybrid'
Else 'Other' 
END AS ejemplo
from limpieza;

UPDATE LIMPIEZA 
SET TYPE = CASE 
when type = 1 then 'Remote'
when type = 0 then 'Hybrid'
Else 'Other' 
END;

CALL LIMP();

SELECT salalry,
CAST(TRIM(REPLACE(REPLACE(salary, '$', ''),',','')) AS decimal (15,2)) AS salary1 from limpieza;
UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''),',','')) AS decimal (15,2));

alter table limpieza modify column salary int null;
DESCRIBE LIMPIEZA;
SELECT birth_date from limpieza;
SELECT birth_date, CASE
    WHEN birth_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END AS new_birth_date
FROM limpieza;

UPDATE limpieza
SET birth_date = CASE
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;
ALTER TABLE limpieza MODIFY COLUMN birth_date date;
DESCRIBE limpieza; -- comprobar el cambio 

-- # Start_date (Se repite el proceso)
-- ----- Identificar como están las fechas de fecha
SELECT start_date FROM limpieza; -- Orden en SQL AAAA-MM-DD =  año, mes, día
call limp(); -- está en mes, día, año.

-- ----- "ensayo" - dar formato a la fecha 
SELECT start_date, CASE
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END AS new_start_date
FROM limpieza;
UPDATE limpieza
SET start_date = CASE
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

-- Cambiar el tipo de dato de la columna 
ALTER TABLE limpieza MODIFY COLUMN start_date DATE;
DESCRIBE limpieza;
-- ===========  Explorando funciones de fecha  ================== --

-- usaremos finish_date para explorar
SELECT finish_date FROM limpieza;
CALL limp();

-- # "ensayos" hacer consultas de como quedarían los datos si queremos ensayar diversos cambios.
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza;  -- convierte el valor en objeto de fecha (timestamp)
SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza; -- objeto en formato de fecha, luego da formato en el deseado '%Y-%m-%d %H:'
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd FROM limpieza; -- separar solo la fecha
SELECT  finish_date, str_to_date(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza; -- separar solo la hora no funciona
SELECT  finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza; -- separar solo la hora(marca de tiempo)
-- # Diviendo los elementos de la hora
SELECT finish_date,
    date_format(finish_date, '%H') AS hora,
    date_format(finish_date, '%i') AS minutos,
    date_format(finish_date, '%s') AS segundos,
    date_format(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

-- ===========  Actualizaciones de fecha en la tabla  ================== --

-- ----- Copia de seguridad de la columna finish_date
call limp();
ALTER TABLE limpieza ADD COLUMN date_backup TEXT; -- Agregar columna respaldo
UPDATE limpieza SET date_backup = finish_date; -- Copiar los datos de finish_date a a la columna respaldo

-- # Actualizar la fecha a marca de tiempo: (TIMESTAMP ; DATETIME)
 Select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')  as formato from limpieza; -- (UTC)
 /* Diferencia entre timestamp y datetime
-- timestamp (YYYY-MM-DD HH:MM:SS) - desde: 01 enero 1970 a las 00:00:00 UTC , hasta milesimas de segundo
-- datetime desde año 1000 a 9999 - no tiene en cuenta la zona horaria , hasta segundos. */

UPDATE limpieza
	SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC') 
	WHERE finish_date <> '';
    
call limp();
-- --------- Dividir la finish_date en fecha y hora

 -- # Crear las columnas que albergarán los nuevos datos 
ALTER TABLE limpieza
	ADD COLUMN fecha DATE,
	ADD COLUMN hora TIME;
    
-- # actualizar los valores de dichas columnas
UPDATE limpieza
SET fecha = DATE(finish_date),
    hora = TIME(finish_date)
WHERE finish_date IS NOT NULL AND finish_date <> '';
 -- # Valores en blanco a nulos
UPDATE limpieza SET finish_date = NULL WHERE finish_date = '';

-- # Actualizar la propiedad
ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;

-- # Revisar los datos
SELECT * FROM limpieza; 
CALL limp();
DESCRIBE limpieza;

-- ========= Cálculos con fechas ====== -- 

-- # Agregar columna para albergar la edad
ALTER TABLE limpieza ADD COLUMN age INT;
call limp();

SELECT name,birth_date, start_date, TIMESTAMPDIFF(YEAR, birth_date, start_date) AS edad_de_ingreso
FROM limpieza;


-- # Actualizar los datos en la columna edad
UPDATE limpieza
SET age = timestampdiff(YEAR, birth_date, CURDATE()); 
-- esta función diferencia en años entre dos fechas (diferencia en años YEAR "year_month", birth_date y fecha actual CURDATE)
/* Calcular diferencias
SECOND: Diferencia en segundos.
MINUTE: Diferencia en minutos.
HOUR: Diferencia en horas.
DAY: Diferencia en días.
WEEK: Diferencia en semanas.
MONTH: Diferencia en meses.
QUARTER: Diferencia en trimestres.
DAY_HOUR: Diferencia en días y horas.
YEAR_MONTH: Diferencia en años y meses. */
call limp;


-- ============ creando columnas adicionales ================= -- 

select CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@consulting.com') as email from limpieza;
-- correo: primer nombre, _ , dos letras del apellido, @consulting.com
-- SUBSTRING_INDEX(cadena, delimitador, ocurrencia) 
	/* Ocurrencia
	Ocurrencia: es el número de ocurrencia del delimitador a partir del cual se extraerá la parte de la cadena
		Si se especifica un número positivo, la función devolverá todos los caracteres antes del enésimo delimitador. 
		Si se especifica un número negativo, la función devolverá todos los caracteres después del enésimo delimitador.*/
-- SUBSTRING(Last_name, inicio, longitud)

ALTER TABLE limpieza
ADD COLUMN email VARCHAR(100);

UPDATE limpieza 
SET email = CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@consulting.com'); 

CALL limp();

SELECT * FROM limpieza
WHERE finish_date <= CURDATE() OR finish_date IS NULL
ORDER BY area, Name;

SELECT area, COUNT(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;