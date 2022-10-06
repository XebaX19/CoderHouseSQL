-- Nos posicionamos sobre la DB a utilizar
USE coder_banco_34945;

/* --------------------------------------------------------------------
	Ejemplo 1
 -------------------------------------------------------------------- */
-- Inicializamos la transacción (internamente se pasa el @@AUTOCOMMIT a 0)
START TRANSACTION;

-- Verificamos registro a eliminar
SELECT * FROM transacciones AS t
WHERE t.id_transaccion = 123;

-- Eliminamos registro de la tabla "transacciones" con id_transaccion = 123
DELETE FROM transacciones
WHERE id_transaccion = 123;

-- Verificamos registro eliminado
SELECT * FROM transacciones AS t
WHERE t.id_transaccion = 123;

-- Hasta acá, la eliminación está pendiente hasta invocar al COMMIT (confirma eliminación) o ROLLBACK (deshace eliminación)

-- Se deshacen los cambios
ROLLBACK;

-- Se confirman los cambios
-- COMMIT;

-- Verificamos como quedó luego de la transacción
SELECT * FROM transacciones AS t
WHERE t.id_transaccion = 123;

/* --------------------------------------------------------------------
	Ejemplo 2
 -------------------------------------------------------------------- */
-- Inicializamos la transacción (internamente se pasa el @@AUTOCOMMIT a 0)
START TRANSACTION;

-- Se insertan 3 registros dentro de la transacción
INSERT INTO clientes (nro_documento, nombre, apellido, direccion, codigo_postal)
VALUES 	(12345671, 'Cliente 1', 'Apellido 1', 'Direccion 1', 'L2000HGA'),
		(12345672, 'Cliente 2', 'Apellido 2', 'Direccion 2', 'L2000HGB'),
		(12345673, 'Cliente 3', 'Apellido 3', 'Direccion 3', 'L2000HGC');

-- Se agrega SAVEPOINT hasta el registro 3 
SAVEPOINT registro_3;

-- Se insertan 2 registros más dentro de la transacción
INSERT INTO clientes (nro_documento, nombre, apellido, direccion, codigo_postal)
VALUES (12345674, 'Cliente 4', 'Apellido 4', 'Direccion 4', 'L2000HGD');
INSERT INTO clientes (nro_documento, nombre, apellido, direccion, codigo_postal)
VALUES (12345675, 'Cliente 5', 'Apellido 5', 'Direccion 5', 'L2000HGE');

-- Se agrega SAVEPOINT hasta el registro 5
SAVEPOINT registro_5;

-- Para quitar último SAVEPOINT
-- RELEASE SAVEPOINT registro_5;

-- Se deshacen los cambios hasta el savepoint registro_3
-- ROLLBACK TO SAVEPOINT registro_3;
-- Se deshacen los cambios hasta el savepoint registro_5
-- ROLLBACK TO SAVEPOINT registro_5;
-- Se deshacen todos los cambios
ROLLBACK;

-- Se confirman los cambios
-- COMMIT;

-- Verificamos como quedó luego de la transacción por nro_documento
SELECT * FROM clientes AS c
WHERE c.nro_documento IN (12345671, 12345672, 12345673, 12345674, 12345675);