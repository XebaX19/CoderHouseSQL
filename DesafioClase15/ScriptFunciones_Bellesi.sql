/*
	Función para obtener la fecha de la última transacción que realizó un cliente determinado 
	para un producto (operatoria y línea) en particular y relacionado a un tipo de transacción seleccionada.
	
	Parámetros de entrada: id_cliente, id_linea, id_tipo_transaccion
	Parámetro de salida: DATETIME
*/
DELIMITER $$
CREATE FUNCTION `fn_fecha_ultima_tx_cliente` (p_id_cliente INT, p_id_linea INT, p_id_tipo_transaccion SMALLINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
	DECLARE v_fecha_ultima_tx DATETIME;
	
	SELECT fecha INTO v_fecha_ultima_tx
	FROM transacciones AS t
	INNER JOIN servicios AS s
		ON t.id_servicio = s.id_servicio
	WHERE s.id_cliente = p_id_cliente
		  AND s.id_linea = p_id_linea
		  AND t.id_tipo_transaccion = p_id_tipo_transaccion
	ORDER BY t.fecha DESC
	LIMIT 1;
	
	RETURN v_fecha_ultima_tx;
END$$

/*
	Función para obtener la cantidad de transacciones que realizó un cliente determinado en un mes/año en particular,
	para un producto (operatoria y línea) específico y relacionado a un tipo de transacción seleccionada.
	
	Parámetros de entrada: id_cliente, id_linea, año-mes, id_tipo_transaccion
	Parámetro de salida: INT
*/
CREATE FUNCTION `fn_cant_movimientos_cliente` (p_id_cliente INT, p_id_linea INT, p_anio_mes DATE,  p_id_tipo_transaccion SMALLINT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE v_cant_movimientos INT;
	
	SELECT COUNT(1) INTO v_cant_movimientos
	FROM transacciones AS t
	INNER JOIN servicios AS s
		ON t.id_servicio = s.id_servicio
	WHERE s.id_cliente = p_id_cliente
		  AND s.id_linea = p_id_linea
          AND YEAR(t.fecha) = YEAR(p_anio_mes)
          AND MONTH(t.fecha) = MONTH(p_anio_mes)
		  AND t.id_tipo_transaccion = p_id_tipo_transaccion;
	
	RETURN v_cant_movimientos;
END$$
DELIMITER ;