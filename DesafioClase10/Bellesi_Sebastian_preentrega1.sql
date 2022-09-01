-- Creación de Base de Datos
CREATE DATABASE coder_banco_34945;
USE coder_banco_34945;

-- Creación Tablas
CREATE TABLE sucursales (
	id_sucursal INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(250) NULL,
    codigo_postal VARCHAR(8) NULL,
    PRIMARY KEY (id_sucursal)
);

CREATE TABLE estados (
	id_estado INT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_estado)
);

CREATE TABLE clientes (
	id_cliente INT NOT NULL AUTO_INCREMENT,
    nro_documento INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(250) NOT NULL,
    codigo_postal VARCHAR(8) NOT NULL,
    PRIMARY KEY (id_cliente)
);

CREATE TABLE operatorias (
	id_operatoria INT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_operatoria)
);

CREATE TABLE lineas (
	id_linea INT NOT NULL AUTO_INCREMENT,
    id_operatoria INT NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    fecha_vigencia_desde DATETIME NOT NULL,
    fecha_vigencia_hasta DATETIME NULL,
    PRIMARY KEY (id_linea),
    CONSTRAINT FK_lineas_operatorias FOREIGN KEY (id_operatoria) REFERENCES operatorias (id_operatoria)
);

CREATE TABLE servicios (
	id_servicio BIGINT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_sucursal INT NOT NULL,
    id_operatoria INT NOT NULL,
    id_linea INT NOT NULL,
    fecha_solicitud DATETIME NOT NULL,
    fecha_aprobacion DATETIME NULL,
    id_estado INT NOT NULL,
    fecha_baja DATETIME NULL,
    PRIMARY KEY (id_servicio),
    CONSTRAINT FK_servicios_clientes FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
    CONSTRAINT FK_servicios_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales (id_sucursal),
    CONSTRAINT FK_servicios_operatorias FOREIGN KEY (id_operatoria) REFERENCES operatorias (id_operatoria),
    CONSTRAINT FK_servicios_lineas FOREIGN KEY (id_linea) REFERENCES lineas (id_linea),
    CONSTRAINT FK_servicios_estados FOREIGN KEY (id_estado) REFERENCES estados (id_estado)
);

CREATE TABLE monedas (
	id_moneda SMALLINT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL,
    descripcion_reducida VARCHAR(3) NOT NULL,
    PRIMARY KEY (id_moneda)
);

CREATE TABLE transacciones (
	id_transaccion BIGINT NOT NULL AUTO_INCREMENT,
    id_servicio BIGINT NOT NULL,
    fecha DATETIME NOT NULL,
    importe DECIMAL(13,2) NOT NULL,
    id_moneda SMALLINT NOT NULL,
    id_estado INT NOT NULL,
    fecha_anulacion DATETIME NULL,
    PRIMARY KEY (id_transaccion),
    CONSTRAINT FK_transacciones_servicios FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio),
    CONSTRAINT FK_transacciones_monedas FOREIGN KEY (id_moneda) REFERENCES monedas (id_moneda),
    CONSTRAINT FK_transacciones_estados FOREIGN KEY (id_estado) REFERENCES estados (id_estado)
);