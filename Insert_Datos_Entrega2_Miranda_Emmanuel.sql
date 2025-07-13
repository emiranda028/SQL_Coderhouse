
USE hoteleria;

INSERT INTO hotel (nombre, ciudad, marca) VALUES
('Marriott Buenos Aires', 'Buenos Aires', 'Marriott'),
('Sheraton Mar del Plata', 'Mar del Plata', 'Sheraton'),
('Sheraton Bariloche', 'Bariloche', 'Sheraton'),
('Maitei Posadas', 'Posadas', 'Maitei');

INSERT INTO reporte (id_hotel, fecha, tipo_reporte) VALUES
(1, '2024-06-01', 'Diario'),
(2, '2024-06-01', 'Flash');

INSERT INTO indicador (id_reporte, total_habitaciones, habitaciones_ocupadas, uso_interno, personas_alojadas, adr) VALUES
(1, 200, 150, 5, 220, 18000.50),
(2, 180, 120, 4, 190, 15500.00);

INSERT INTO venta (id_reporte, ingresos_habitaciones, ingresos_alimentos_bebidas, otros_ingresos) VALUES
(1, 2700000.00, 820000.00, 150000.00),
(2, 1860000.00, 670000.00, 120000.00);
