-- Muestra la descripción de la función
SELECT text FROM user_source WHERE TYPE = 'FUNCTION' ORDER BY line;

-- Muestra el nombre de las funciones
SELECT object_name FROM user_objects WHERE object_type = 'FUNCTION';

-- Entrando al sqlpls ejecutando lo siguinte
GRANT SELECT ON sys.dba_objects to ORA01;
GRANT SELECT ON sys.DBA_SOURCE to ORA01;

-- Da permisos al usuario ORA01 para poder ejecutar querys sobre 
-- sys.dba_objects y sys.DBA_SOURCE

-- Así es que ahora se puede ejecutar lo siguiente
SELECT *
  FROM DBA_SOURCE
  WHERE OWNER = 'ORA01'
    AND TYPE = 'PACKAGE'
    AND NAME = 'NOMBRE_PAQUETE'
  ORDER BY LINE;


SELECT NAME AS PACKAGE_NAME,
               LINE, 
               TEXT
  FROM SYS.DBA_SOURCE
WHERE OWNER = 'ORA01'
  AND TYPE='PACKAGE';
 

SELECT *
  FROM DBA_SOURCE
  WHERE OWNER = 'ORA01'
    AND TYPE = 'PACKAGE BODY'
    AND NAME = 'NOMBRE_PAQUETE'
  ORDER BY LINE;

SELECT * FROM DBA_OBJECTS WHERE OWNER = 'ORA01';
