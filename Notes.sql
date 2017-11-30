-- Muestra la descripción de la función
SELECT text FROM user_source WHERE TYPE = 'FUNCTION' ORDER BY line;

-- Muestra el nombre de las funciones
SELECT object_name FROM user_objects WHERE object_type = 'FUNCTION';
