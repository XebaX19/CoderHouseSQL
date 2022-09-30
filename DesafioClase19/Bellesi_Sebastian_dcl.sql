-- Nos posicionamos sobre la DB del sistema MySQL
USE mysql;


-- Creación de usuario de sólo lectura
CREATE USER 'userConsulta'@'localhost' IDENTIFIED BY 'pass12345';

-- Agregamos el permiso correspondiente para que el usuario sea de sólo lectura sobre todos los esquemas y tablas
GRANT SELECT ON *.* TO 'userConsulta'@'localhost'; 



-- Creación de usuario de lectura, inserción y modificación
CREATE USER 'userAMC'@'localhost' IDENTIFIED BY 'pass123456789';

-- Agregamos los permisos correspondiente para que el usuario pueda consultar, insertar y actualizar sobre todos los esquemas y tablas
GRANT SELECT, INSERT, UPDATE ON *.* TO 'userAMC'@'localhost'; 



-- Visualizamos permisos por usuario
SHOW GRANTS FOR 'userConsulta'@'localhost';
SHOW GRANTS FOR 'userAMC'@'localhost';

-- Verificación en tabla user de MySQL
SELECT * FROM `user`;


-- Eliminación de usuarios
-- DROP USER 'userConsulta'@'localhost';
-- DROP USER 'userAMC'@'localhost';