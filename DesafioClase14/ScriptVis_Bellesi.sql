/*
	Vista que muestra los servicios del Banco asociados a Cuentas a la Vista que se encuentren 
    en estado activo recuperando además información de los clientes y descripción del tipo de cuenta.
*/
CREATE VIEW `view_cuentas_activas` AS
    SELECT 	s.id_servicio, 
			l.descripcion AS tipo_cuenta, 
            s.fecha_solicitud, 
            s.fecha_aprobacion,
            c.id_cliente,
            c.nro_documento,
            c.nombre,
            c.apellido,
            c.direccion,
            c.codigo_postal
    FROM servicios AS s
    INNER JOIN lineas AS l
		ON s.id_linea = l.id_linea
    INNER JOIN clientes AS c
		ON s.id_cliente = c.id_cliente
    WHERE s.id_operatoria = 1 		-- Cuentas a la Vista
		  AND s.id_estado = 3; 		-- Activo

/*
	Vista que muestra la cantidad de servicios que posee el Banco agrupados por sucursal, 
    mostrando los datos de cada sucursal.
*/          
CREATE VIEW `view_servicios_x_sucursal` AS
	SELECT su.id_sucursal,
		   su.nombre AS nombre_sucursal,
		   su.direccion AS direccion_sucursal,
		   su.codigo_postal AS codigo_postal_sucursal,
		   COUNT(1) AS cant_servicios_x_sucursal
	FROM servicios AS s
	INNER JOIN sucursales AS su
		ON s.id_sucursal = su.id_sucursal
	GROUP BY su.id_sucursal;

/*
	Vista que muestra las transacciones en pesos realizadas en el mes actual, es decir, en estado "aplicado"; 
    mostrando información del servicio y del cliente.
*/  
CREATE VIEW `view_txs_mes_actual_pesos` AS
	SELECT t.id_transaccion, 
		   t.fecha AS fecha_transaccion,
		   t.importe,
		   t.id_servicio,
		   o.descripcion AS descripcion_operatoria,
		   l.descripcion AS descripicion_linea,
		   s.fecha_solicitud AS fecha_solicitud_servicio,
		   s.fecha_aprobacion AS fecha_aprobacion_servicio,
		   c.id_cliente,
		   c.nro_documento,
		   c.nombre,
		   c.apellido,
		   c.direccion,
		   c.codigo_postal
	FROM transacciones AS t
	INNER JOIN servicios AS s
		ON t.id_servicio = s.id_servicio
	INNER JOIN operatorias AS o
		ON s.id_operatoria = o.id_operatoria
	INNER JOIN lineas AS l
		ON s.id_linea = l.id_linea
	INNER JOIN clientes AS c
		ON s.id_cliente = c.id_cliente
	WHERE YEAR(t.fecha) = YEAR(CURDATE())			-- Año actual
		  AND MONTH(t.fecha) =  MONTH(CURDATE())	-- Mes actual
		  AND t.id_moneda = 1						-- Moneda: Pesos
		  AND t.id_estado = 7;						-- Estado: Aplicado

/*
	Vista que muestra las transacciones en dólares realizadas en el mes actual, es decir, en estado "aplicado"; 
    mostrando información del servicio y del cliente.
*/ 
CREATE VIEW `view_txs_mes_actual_dolar` AS
	SELECT t.id_transaccion, 
		   t.fecha AS fecha_transaccion,
		   t.importe,
		   t.id_servicio,
		   o.descripcion AS descripcion_operatoria,
		   l.descripcion AS descripicion_linea,
		   s.fecha_solicitud AS fecha_solicitud_servicio,
		   s.fecha_aprobacion AS fecha_aprobacion_servicio,
		   c.id_cliente,
		   c.nro_documento,
		   c.nombre,
		   c.apellido,
		   c.direccion,
		   c.codigo_postal
	FROM transacciones AS t
	INNER JOIN servicios AS s
		ON t.id_servicio = s.id_servicio
	INNER JOIN operatorias AS o
		ON s.id_operatoria = o.id_operatoria
	INNER JOIN lineas AS l
		ON s.id_linea = l.id_linea
	INNER JOIN clientes AS c
		ON s.id_cliente = c.id_cliente
	WHERE YEAR(t.fecha) = YEAR(CURDATE())			-- Año actual
		  AND MONTH(t.fecha) =  MONTH(CURDATE())	-- Mes actual
		  AND t.id_moneda = 2						-- Moneda: Dolar
		  AND t.id_estado = 7;						-- Estado: Aplicado
          
/*
	Vista que muestra las transacciones anuladas en el mes anterior al actual, 
    mostrando la moneda y la información del servicio y del cliente.
*/ 
CREATE VIEW `view_txs_anuladas_mes_anterior` AS
	SELECT t.id_transaccion, 
		   t.fecha AS fecha_transaccion,
           t.fecha_anulacion AS fecha_anulacion,
		   t.importe,
           m.descripcion_reducida AS moneda,
		   t.id_servicio,
		   o.descripcion AS descripcion_operatoria,
		   l.descripcion AS descripicion_linea,
		   s.fecha_solicitud AS fecha_solicitud_servicio,
		   s.fecha_aprobacion AS fecha_aprobacion_servicio,
		   c.id_cliente,
		   c.nro_documento,
		   c.nombre,
		   c.apellido,
		   c.direccion,
		   c.codigo_postal
	FROM transacciones AS t
	INNER JOIN servicios AS s
		ON t.id_servicio = s.id_servicio
	INNER JOIN operatorias AS o
		ON s.id_operatoria = o.id_operatoria
	INNER JOIN lineas AS l
		ON s.id_linea = l.id_linea
	INNER JOIN clientes AS c
		ON s.id_cliente = c.id_cliente
	INNER JOIN monedas AS m
		ON t.id_moneda = m.id_moneda
	WHERE YEAR(t.fecha) = YEAR(DATE_ADD(CURDATE(), INTERVAL -1 MONTH))			-- Año del mes pasado
		  AND MONTH(t.fecha) =  MONTH(DATE_ADD(CURDATE(), INTERVAL -1 MONTH))	-- Mes pasado
		  AND t.id_estado = 5;													-- Estado: Anulado