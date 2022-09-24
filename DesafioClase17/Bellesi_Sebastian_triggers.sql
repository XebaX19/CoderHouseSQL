-- Creación tabla para almacenar auditoria de otras tablas
DROP TABLE IF EXISTS log_auditoria;
CREATE TABLE log_auditoria (
	id_log INT NOT NULL AUTO_INCREMENT,
	tabla VARCHAR(45) NOT NULL,
	accion VARCHAR(15) NOT NULL,
	mensaje VARCHAR(400) NOT NULL,
	usuario VARCHAR(45) NOT NULL,
	fecha_hora DATETIME NOT NULL,
	PRIMARY KEY (id_log)
);

/*
	Trigger asociado a la tabla “servicios”, que se dispara con la acción de actualización y verifica si lo que se está modificando es el estado.
	En ese caso, si el estado al que se actualiza es “Dado de baja”, setea la “fecha de baja” con la fecha/hora actual.

	Tabla asociada: servicios
	Acción asociada: UPDATE
*/
DROP TRIGGER IF EXISTS `tg_servicios_fecha_baja`;
DELIMITER $$
CREATE TRIGGER `tg_servicios_fecha_baja`
BEFORE UPDATE ON `servicios`
FOR EACH ROW
BEGIN
	IF NEW.id_estado = 6 THEN
        SET NEW.fecha_baja = NOW();
    END IF;
END$$
DELIMITER ;

/*
	Trigger asociado a la tabla “transacciones”, que se dispara con la acción de eliminación y guarda en una tabla de auditoria la transacción eliminada y datos del usuario que realizó la eliminación.
	
    Tabla asociada: transacciones
	Acción asociada: DELETE
*/
DROP TRIGGER IF EXISTS `tg_auditoria_txs_eliminadas`;
DELIMITER $$
CREATE TRIGGER `tg_auditoria_txs_eliminadas`
AFTER DELETE ON `transacciones`
FOR EACH ROW
BEGIN
	INSERT INTO log_auditoria (tabla, accion, mensaje, usuario, fecha_hora)
    VALUES (
		'transacciones',
        'Eliminación',
        CONCAT(	'Se eliminó la transacción. id_transaccion: ', IFNULL(OLD.id_transaccion, 'NULO'),
				', id_servicio: ', IFNULL(OLD.id_servicio, 'NULO'),
                ', fecha: ', IFNULL(OLD.fecha, 'NULO'),
                ', importe: ', IFNULL(OLD.importe, 'NULO'),
                ', id_moneda: ', IFNULL(OLD.id_moneda, 'NULO'),
                ', id_estado: ', IFNULL(OLD.id_estado, 'NULO'),
                ', fecha_anulacion: ', IFNULL(OLD.fecha_anulacion, 'NULO'),
                ', id_tipo_transaccion: ', IFNULL(OLD.id_tipo_transaccion, 'NULO')
		),
        USER(),
        NOW()
	);
END$$
DELIMITER ;