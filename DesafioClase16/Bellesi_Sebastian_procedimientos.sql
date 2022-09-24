/*
	Procedimiento almacenado para dar de alta un cliente y una cuenta a la vista asociada. La cuenta quedará en estado “Solicitud pendiente” para su posterior aprobación.
	En caso de que ya exista dado de alta el cliente (verificación por índice único “nro_documento”) se dará de alta sólo la cuenta, mostrando un mensaje informativo con lo sucedido.
    En caso de que ya exista la cuenta a la vista para el cliente en cuestión (verificación por línea, sucursal y estado activo o pendiente aprobación), no se realizará ninguna acción, mostrando un mensaje informativo con lo sucedido.
    En caso de que haya errores en los parámetros de entrada (obligatoriedad, error de dato, etc), no se realizará ninguna acción, mostrando un mensaje informativo con lo sucedido.
	
    Parámetros de entrada: nro_documento, nombre, apellido, direccion, codigo_postal, id_sucursal, id_linea
	Parámetros de salida: cod_ejecucion, estado_ejecucion (*)
    
    (*) El parámetro de salida “cod_ejecucion” permite conocer si el SP se ejecutó ok (devuelve 0) o si hubo algún problema (devuelve -1).
    En caso de que haya finalizado con código -1, se puede visualizar el error en el parámetro de salida “estado_ejecucion”.
*/
DROP PROCEDURE IF EXISTS `sp_alta_cliente_cuenta`;
DELIMITER $$
CREATE PROCEDURE `sp_alta_cliente_cuenta` (
    IN p_nro_documento INT,
	IN p_nombre VARCHAR(50),
	IN p_apellido VARCHAR(50),
	IN p_direccion VARCHAR(250),
	IN p_codigo_postal VARCHAR(8),
	IN p_id_sucursal INT,
	IN p_id_linea INT,
    OUT p_cod_ejecucion SMALLINT,
    OUT p_estado_ejecucion VARCHAR(250)
)
proc_label:BEGIN
	-- Declaración de variables
	DECLARE v_id_cliente INT;
    DECLARE v_generar_cliente BOOL;
    DECLARE v_id_servicio BIGINT;
    
    -- Asignación de variables
    SET v_generar_cliente = TRUE;
    SET v_id_cliente = 0;
    
    -- --------------------------------------------------------------------------------------------------
	-- Validaciones
    
    -- Valida p_nro_documento
    IF p_nro_documento IS NULL THEN
		SET p_cod_ejecucion = -1;
		SET p_estado_ejecucion = 'Error: el parámetro "p_nro_documento" es obligatorio.';
        
        LEAVE proc_label;
	ELSE
		-- Si el cliente ya se encuentra creado, recupera id_cliente
		SELECT c.id_cliente INTO v_id_cliente
        FROM clientes AS c
        WHERE c.nro_documento = p_nro_documento;
        
        IF v_id_cliente > 0 THEN
			SET v_generar_cliente = FALSE;
        END IF;
    END IF;
    
    -- Validaciones si se debe realizar el alta de cliente
    IF v_generar_cliente THEN
		-- Valida p_nombre
		IF p_nombre IS NULL THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = 'Error: el parámetro "p_nombre" es obligatorio.';
            
            LEAVE proc_label;
        END IF;

		-- Valida p_apellido
		IF p_apellido IS NULL THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = 'Error: el parámetro "p_apellido" es obligatorio.';
            
            LEAVE proc_label;
        END IF;
        
		-- Valida p_direccion
		IF p_direccion IS NULL THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = 'Error: el parámetro "p_direccion" es obligatorio.';
            
            LEAVE proc_label;
        END IF;
        
		-- Valida p_codigo_postal
		IF p_codigo_postal IS NULL THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = 'Error: el parámetro "p_codigo_postal" es obligatorio.';
            
            LEAVE proc_label;
        END IF;        
	END IF;
    
    -- Valida p_id_sucursal
    IF p_id_sucursal IS NULL THEN
		SET p_cod_ejecucion = -1;
		SET p_estado_ejecucion = 'Error: el parámetro "p_id_sucursal" es obligatorio.';
        
        LEAVE proc_label;
	ELSE
		-- Verifica si la sucursal recibida se encuentra registrada
        IF NOT EXISTS (
			SELECT 1
            FROM sucursales AS s
            WHERE s.id_sucursal = p_id_sucursal
        ) THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = CONCAT('Error: el id_sucursal recibido ', CONVERT(p_id_sucursal, CHAR(10)), ' no se encuentra registrado.');
			
			LEAVE proc_label;
        END IF;
    END IF;

    -- Valida p_id_linea
    IF p_id_linea IS NULL THEN
		SET p_cod_ejecucion = -1;
		SET p_estado_ejecucion = 'Error: el parámetro "p_id_linea" es obligatorio.';
        
        LEAVE proc_label;
	ELSE
		-- Verifica si la linea recibida se encuentra registrada
        IF NOT EXISTS (
			SELECT 1
            FROM lineas AS l
            WHERE l.id_linea = p_id_linea
				  AND l.id_operatoria = 1 -- Cuenta a la vista
        ) THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = CONCAT('Error: el id_linea recibido ', CONVERT(p_id_linea, CHAR(10)), ' no se encuentra registrado o no pertenece a la Operatoria "Cuenta a la Vista".');
			
			LEAVE proc_label;
        END IF;
    END IF;
    
    -- Valida si es un cliente existente y ya dispone de un servicio "activo" o "pendiente aprobación" para la misma línea y en la sucursal solicitada
	IF EXISTS (
		SELECT 1
		FROM servicios AS s
		WHERE s.id_cliente = v_id_cliente
			  AND s.id_sucursal = p_id_sucursal
			  AND s.id_linea = p_id_linea
			  AND s.id_estado IN (1, 3) -- Pendiente aprobación / Activo
	) THEN
		SET p_cod_ejecucion = 0;
		SET p_estado_ejecucion = CONCAT('Informativo: El cliente con nro_documento ', CONVERT(p_nro_documento, CHAR(15)), ' ya dispone de un servicio activo o pendiente de aprobación para la sucursal ', CONVERT(p_id_sucursal, CHAR(10)), ' y la línea ',  CONVERT(p_id_linea, CHAR(10)), '.');
		
		LEAVE proc_label;
	END IF;
    -- Fin validaciones
    -- --------------------------------------------------------------------------------------------------
    
    -- Si no existe el cliente, se da de alta
    IF v_generar_cliente THEN
		INSERT INTO clientes (nro_documento, nombre, apellido, direccion, codigo_postal)
        VALUES (p_nro_documento, p_nombre, p_apellido, p_direccion, p_codigo_postal);
        
        SET v_id_cliente = LAST_INSERT_ID();
    END IF;
    
    -- Se da de alta la cuenta
    INSERT INTO servicios (id_cliente, id_sucursal, id_operatoria, id_linea, fecha_solicitud, id_estado)
    VALUES (v_id_cliente, p_id_sucursal, 1, p_id_linea, NOW(), 1);
    
    SET v_id_servicio = LAST_INSERT_ID();
    
	SET p_cod_ejecucion = 0;
    IF v_generar_cliente THEN
		SET p_estado_ejecucion = CONCAT('Ejecución ok. Cliente generado: ', CONVERT(v_id_cliente, CHAR(15)), '. Servicio generado: ', CONVERT(v_id_servicio, CHAR(20)));
    ELSE
		SET p_estado_ejecucion = CONCAT('Ejecución ok. Cliente ya registrado. Servicio generado: ', CONVERT(v_id_servicio, CHAR(20)));
    END IF;
END$$
DELIMITER ;

/*
	-- Verifica sp_alta_cliente_cuenta
	CALL sp_alta_cliente_cuenta(33514817, 'Seba', 'Bellesi', 'Entre rios 988', 'C2000ABC', 1, 1, @cod_ejec, @estado_ejec);
	SELECT @cod_ejec, @estado_ejec;
*/

/*
	Procedimiento almacenado para anular una transacción pasando la misma a estado “Anulado”.
    En caso de que la transacción no exista o no se encuentre en estado “Aplicado”, no se realizará ninguna acción, mostrando un mensaje informativo con lo sucedido.
    En caso de que haya errores en los parámetros de entrada (obligatoriedad, error de dato, etc), no se realizará ninguna acción, mostrando un mensaje informativo con lo sucedido.
	
    Parámetros de entrada: id_transaccion
	Parámetro de salida: cod_ejecucion, estado_ejecucion (*)
    
    (*) El parámetro de salida “cod_ejecucion” permite conocer si el SP se ejecutó ok (devuelve 0) o si hubo algún problema (devuelve -1).
    En caso de que haya finalizado con código -1, se puede visualizar el error en el parámetro de salida “estado_ejecucion”.
*/
DROP PROCEDURE IF EXISTS `sp_anula_transaccion`;
DELIMITER $$
CREATE PROCEDURE `sp_anula_transaccion` (
	IN p_id_transaccion BIGINT,
    OUT p_cod_ejecucion SMALLINT,
    OUT p_estado_ejecucion VARCHAR(100)
)
proc_label:BEGIN
    -- --------------------------------------------------------------------------------------------------
	-- Validaciones
    
    -- Valida p_id_transaccion
    IF p_id_transaccion IS NULL THEN
		SET p_cod_ejecucion = -1;
		SET p_estado_ejecucion = 'Error: el parámetro "p_id_transaccion" es obligatorio.';
        
        LEAVE proc_label;
	ELSE
		-- Verifica si la transacción se encuentra registrada y en estado "Aplicado"
        IF NOT EXISTS (
			SELECT 1
            FROM transacciones AS t
            WHERE t.id_transaccion = p_id_transaccion
				  AND t.id_estado = 7 -- Aplicado
        ) THEN
			SET p_cod_ejecucion = -1;
			SET p_estado_ejecucion = CONCAT('Error: no se encontró la transacción con id ', CONVERT(p_id_transaccion, CHAR(20)), ' o la misma no se encuentra en estado "Aplicado".');
			
			LEAVE proc_label;
        END IF;
    END IF;
    -- Fin validaciones
    -- --------------------------------------------------------------------------------------------------
    
    UPDATE transacciones
    SET id_estado = 5, -- Anulado
		fecha_anulacion = NOW()
	WHERE id_transaccion = p_id_transaccion;
    
	SET p_cod_ejecucion = 0;
	SET p_estado_ejecucion = CONCAT('Ejecución ok. Id Transacción: ', CONVERT(p_id_transaccion, CHAR(20)), ' anulada.');
END$$
DELIMITER ;

/*
	-- Verifica sp_anula_transaccion
	CALL sp_anula_transaccion(2000, @cod_ejec, @estado_ejec);
	SELECT @cod_ejec, @estado_ejec;
*/