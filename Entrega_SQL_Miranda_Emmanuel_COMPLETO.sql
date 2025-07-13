
-- Script SQL completo - Proyecto Variables Hoteleras - Miranda Emmanuel

DROP DATABASE IF EXISTS hoteleria;
CREATE DATABASE hoteleria;
USE hoteleria;

-- TABLAS
CREATE TABLE hotel (
    id_hotel INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100),
    marca VARCHAR(100),
    PRIMARY KEY (id_hotel)
);

CREATE TABLE reporte (
    id_reporte INT NOT NULL AUTO_INCREMENT,
    id_hotel INT NOT NULL,
    fecha DATE NOT NULL,
    tipo_reporte VARCHAR(50),
    PRIMARY KEY (id_reporte),
    FOREIGN KEY (id_hotel) REFERENCES hotel(id_hotel)
);

CREATE TABLE indicador (
    id_indicador INT NOT NULL AUTO_INCREMENT,
    id_reporte INT NOT NULL,
    total_habitaciones INT,
    habitaciones_ocupadas INT,
    uso_interno INT,
    personas_alojadas INT,
    adr DECIMAL(10,2),
    PRIMARY KEY (id_indicador),
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte)
);

CREATE TABLE venta (
    id_venta INT NOT NULL AUTO_INCREMENT,
    id_reporte INT NOT NULL,
    ingresos_habitaciones DECIMAL(10,2),
    ingresos_alimentos_bebidas DECIMAL(10,2),
    otros_ingresos DECIMAL(10,2),
    PRIMARY KEY (id_venta),
    FOREIGN KEY (id_reporte) REFERENCES reporte(id_reporte)
);

-- VISTA 1: vista_metrica
CREATE VIEW vista_metrica AS
SELECT
    i.id_indicador,
    i.id_reporte,
    CASE
        WHEN i.total_habitaciones > 0 THEN ROUND(i.habitaciones_ocupadas / i.total_habitaciones, 4)
        ELSE NULL
    END AS porcentaje_ocupacion,
    CASE
        WHEN i.habitaciones_ocupadas > 0 THEN ROUND(i.personas_alojadas / i.habitaciones_ocupadas, 2)
        ELSE NULL
    END AS doble_ocupacion,
    CASE
        WHEN i.total_habitaciones > 0 THEN ROUND(i.adr * (i.habitaciones_ocupadas / i.total_habitaciones), 2)
        ELSE NULL
    END AS revpar
FROM indicador i;

-- VISTA 2: vista_reporte_completo
CREATE VIEW vista_reporte_completo AS
SELECT 
    h.nombre AS hotel,
    h.ciudad,
    r.fecha,
    r.tipo_reporte,
    i.total_habitaciones,
    i.habitaciones_ocupadas,
    i.personas_alojadas,
    i.adr,
    v.ingresos_habitaciones,
    v.ingresos_alimentos_bebidas,
    v.otros_ingresos
FROM hotel h
JOIN reporte r ON h.id_hotel = r.id_hotel
JOIN indicador i ON r.id_reporte = i.id_reporte
JOIN venta v ON r.id_reporte = v.id_reporte;

-- FUNCION
DELIMITER //
CREATE FUNCTION calcular_revpar(adr DECIMAL(10,2), ocupacion DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(adr * ocupacion, 2);
END;
//
DELIMITER ;

-- TRIGGER
CREATE TABLE log_insert_reporte (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    fecha_evento DATETIME,
    id_hotel INT,
    mensaje VARCHAR(255)
);

DELIMITER //
CREATE TRIGGER before_insert_reporte_log
BEFORE INSERT ON reporte
FOR EACH ROW
BEGIN
    INSERT INTO log_insert_reporte (fecha_evento, id_hotel, mensaje)
    VALUES (NOW(), NEW.id_hotel, CONCAT('Nuevo reporte ingresado para hotel ID ', NEW.id_hotel));
END;
//
DELIMITER ;

-- STORED PROCEDURE
DELIMITER //
CREATE PROCEDURE insertar_reporte_completo(
    IN p_id_hotel INT,
    IN p_fecha DATE,
    IN p_tipo_reporte VARCHAR(50),
    IN p_total_hab INT,
    IN p_ocupadas INT,
    IN p_uso_interno INT,
    IN p_personas INT,
    IN p_adr DECIMAL(10,2),
    IN p_ing_hab DECIMAL(10,2),
    IN p_ing_ab DECIMAL(10,2),
    IN p_otros_ing DECIMAL(10,2)
)
BEGIN
    DECLARE nuevo_id_reporte INT;

    INSERT INTO reporte (id_hotel, fecha, tipo_reporte)
    VALUES (p_id_hotel, p_fecha, p_tipo_reporte);
    SET nuevo_id_reporte = LAST_INSERT_ID();

    INSERT INTO indicador (id_reporte, total_habitaciones, habitaciones_ocupadas, uso_interno, personas_alojadas, adr)
    VALUES (nuevo_id_reporte, p_total_hab, p_ocupadas, p_uso_interno, p_personas, p_adr);

    INSERT INTO venta (id_reporte, ingresos_habitaciones, ingresos_alimentos_bebidas, otros_ingresos)
    VALUES (nuevo_id_reporte, p_ing_hab, p_ing_ab, p_otros_ing);
END;
//
DELIMITER ;
