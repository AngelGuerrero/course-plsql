CREATE OR REPLACE FUNCTION delete_all_rows(table_name IN VARCHAR2) RETURN NUMBER IS
   l_cursor INTEGER;
   l_del NUMBER;
BEGIN
   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, 'DELETE FROM ' || table_name, dbms_sql.native);
   l_del := dbms_sql.execute(l_cursor);
   dbms_sql.close_cursor(l_cursor);
   
   RETURN l_del;
END;
/

CREATE TABLE temp_emp as (SELECT * FROM EMPLOYEES);
DROP TABLE temp_emp;

SELECT * FROM temp_emp;

BEGIN
   dbms_output.put_line('Filas borradas: ' || delete_all_rows('temp_emp'));
END;
/

SELECT * FROM temp_emp;

SELECT dbms_metadata.get_xml('TABLE', 'EMPLOYEES', 'HR') FROM dual;

SELECT dbms_metadata.get_dependent_ddl('OBJECT_GRANT', 'EMPLOYEES', 'HR') FROM dual;

SELECT dbms_metadata.get_granted_ddl('SYSTEM_GRANT', 'HR') FROM dual;



--Practice 6
--1. Create a package called TABLE_PKG that uses Native Dynamic SQL to create or 
--drop a table, and populate, modify, and delete rows from te table.
--
--a. Create a papckage specification with the following procedures:
--   PROCEDURE make
--   PROCEDURE add_row
--   PROCEDURE upd_row
--   PROCEDURE del_row
--   PROCEDURE remove
--   
--  Ensure that subprograms manage optional default parameters with NULL values.
--
--b. Create the package body that accepts the parameters and dynamically constructs
--   the appropiate SQL statemets that are executed usgin Native Dynamic SQL,
--   except for the remove procedure that should be written using the DBMS_SQL
--   package.
--
--C. Execute the package MAKE procedure to create a table as follows:
--       make('my_contacts', 'id_number(4), name varchar2(40)');
--
--D. Describe the MY_CONTACTS table structure.
--
--E. Execte the ADD_ROW package procedure to add the following rows:
--      add_row('my_contacts', '1', ''Geoff Gallus'', 'id, name');
--      add_row('my_contacts', '2', ''Nancy'', 'id, name');
--      add_row('my_contacts', '3', ''Sunitha Patel'', 'id, name');
--      add_row('my_contacts', '4', ''Valli Pataballa'', 'id, name');
--      


CREATE OR REPLACE PROCEDURE make_table(p_tablename VARCHAR2, p_options VARCHAR2, p_override BOOLEAN DEFAULT FALSE) IS
   l_stmt VARCHAR2(2000);
   l_count_t NUMBER;
   l_opt VARCHAR2(200);
BEGIN
   -- Verifica que la tabla no esté creada
   SELECT COUNT(1) INTO l_count_t
     FROM sys.all_all_tables
    WHERE table_name = upper(p_tablename);
  
   IF l_count_t = 0
   THEN
      dbms_output.put_line('No hay tabla creada con el nombre: ' || p_tablename);
      -- Crea el query
      dbms_output.put_line('Creando query...');
      l_stmt := 'CREATE TABLE ' || p_tablename ||'('||p_tablename||'_id NUMBER NOT NULL, '||p_options||', CONSTRAINT '||p_tablename||'_id_pk PRIMARY KEY('||p_tablename||'_id))';
      dbms_output.put_line(l_stmt);
      EXECUTE IMMEDIATE l_stmt;
      dbms_output.put_line('Tabla creada correctamente');
   ELSE
      dbms_output.put_line('La tabla que se intenta crear ya existe');
      
      IF p_override
      THEN
         dbms_output.put_line('La opción para sobreescribir la tabla está en TRUE');
         dbms_output.put_line('Se sobreescribirá la tabla');
         l_stmt := 'DROP TABLE ' || p_tablename;
         EXECUTE IMMEDIATE l_stmt;
         -- Llama de nuevo al procedimiento
         make_table(p_tablename, p_options);
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error al tratar de crear la tabla: ' || p_tablename);
      dbms_output.put_line('Error: '||SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END make_table;
/

EXECUTE make_table('my_contacts', 'name varchar2(40)');

EXECUTE make_table('cliente', 'nombrecliente VARCHAR(100)');
EXECUTE make_table('direccion', 'direccion VARCHAR(100)');
EXECUTE make_table('t_direcciones', 'cliente_id NUMBER, iddireccion NUMBER', TRUE);
EXECUTE make_table('pedidos', 'fechapedido DATE, iddetalledirec NUMBER');

EXECUTE add_row('cliente', ' ''1'', ''Geoff Gallus'' ');
EXECUTE add_row('cliente', ' ''2'', ''Nancy'' ');

EXECUTE add_row('direccion', ' ''1'', ''Mayas 434'' ');
EXECUTE add_row('direccion', ' ''2'', ''Palmas 432'' ');

EXECUTE add_row('t_direcciones', ' ''1'', ''1'', ''1'' ');
EXECUTE add_row('t_direcciones', ' ''2'', ''2'', ''2'' ');

EXECUTE add_row('pedidos', ' ''1'', ''02/03/2018'', ''1'' ');
EXECUTE add_row('pedidos', ' ''2'', ''02/03/2018'', ''2'' ');

select * from cliente;
desc cliente;
select * from direccion;
select * from t_direcciones;
select * from pedidos;

select c.nombrecliente
from cliente c
intersect
select d.direccion_id
from t_direcciones ;

select cliente_id
from cliente
intersect
select cliente_id
from t_direcciones;





-- Puede sobreescribir la tabla, borrarla y crearla con los parámetros dados
EXECUTE make_table('my_contacts', 'name varchar2(40)', TRUE);


CREATE OR REPLACE PROCEDURE add_row(p_tablename VARCHAR2, p_values VARCHAR2) IS
   l_stmt VARCHAR2(200);
   l_count_t NUMBER;
BEGIN
   SELECT COUNT(1) INTO l_count_t
     FROM all_all_tables
    WHERE table_name = upper(p_tablename);
    
    IF l_count_t = 0
    THEN
       dbms_output.put_line('No hay ninguna tabla con el nombre: ' || p_tablename);
    ELSE
       -- Creando el query
       l_stmt := 'INSERT INTO ' || p_tablename || ' VALUES ('|| p_values ||')';
       dbms_output.put_line(l_stmt);
       EXECUTE IMMEDIATE l_stmt;
       dbms_output.put_line('Datos ingresados correctamente');
       COMMIT;
    END IF;
    
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      dbms_output.put_line('El registro que se trata de ingresar ya está en la base de datos');
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error al tratar de insertar el registro');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END add_row;
/

-- Ingresa los datos en la tabla
EXECUTE add_row('my_contacts', ' ''1'', ''Geoff Gallus'' ');
EXECUTE add_row('my_contacts', ' ''2'', ''Nancy'' ');
EXECUTE add_row('my_contacts', ' ''3'', ''Sunitha Patel'' ');
EXECUTE add_row('my_contacts', ' ''4'', ''Valli Pataballa'' ');

SELECT * FROM my_contacts;


CREATE OR REPLACE PROCEDURE upd_row(p_tablename VARCHAR2, p_assoc_val VARCHAR2) IS
   l_count_t NUMBER;
   l_stmt VARCHAR2(200);
BEGIN
   -- Verifica si la tabla existe
   SELECT COUNT(1) INTO l_count_t
     FROM all_all_tables
    WHERE table_name = upper(p_tablename);
    
   IF l_count_t = 0
   THEN
      dbms_output.put_line('No hay ninguna tabla con el nombre: ' || p_tablename);
   ELSE
      l_stmt := 'SET '||p_tablename||
END upd_row;




 
 