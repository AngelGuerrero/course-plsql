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

DECLARE
   h NUMBER;
   th NUMBER;
   doc CLOB;
BEGIN
   h := dbms_metadata.open('TABLE');
   dbms_metadata.set_filter(h, 'SCHEMA', 'HR');
   dbms_metadata.set_filter(h, 'NAME', 'EMPLOYEES');
   
   th := dbms_metadata.add_transform(h, 'DDL');
   
   doc := dbms_metadata.fetch_clob(h);
   
   dbms_metadata.close(h);
END;
/



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
   IF t_exists(p_tablename)
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


CREATE OR REPLACE PROCEDURE del_table(p_tablename VARCHAR2) IS
   l_stmt VARCHAR2(100);
BEGIN
   IF t_exists(p_tablename)
   THEN
      l_stmt := 'DROP TABLE '||p_tablename;
      EXECUTE IMMEDIATE l_stmt;
      dbms_output.put_line('Tabla eliminada correctamente');
   ELSE
      dbms_output.put_line('La tabla especificada no existe');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error al tratar de eliminar la tabla: ' || p_tablename);
      dbms_output.put_line('Error: '||SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END del_table;
/


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


CREATE OR REPLACE PROCEDURE upd_row(p_tablename VARCHAR2, p_cond VARCHAR2, p_assoc_val VARCHAR2) IS
   l_count_t NUMBER;  -- Count tables
   
   l_stmt VARCHAR2(200); -- Statement SQL
   
   l_ok   NUMBER; -- Número de registros ok
   l_err  NUMBER; -- Número de registros con error
   l_t    NUMBER; -- Número de registros actualizados, total
   
   l_desc user_tab_columns%rowtype;
BEGIN
   IF t_exists(p_tablename)
   THEN
      dbms_output.put_line('No hay ninguna tabla con el nombre: ' || p_tablename);
   ELSE
      l_stmt := 'UPDATE ' || p_tablename || 
                  ' SET ' || p_assoc_val ||
                ' WHERE ' || p_cond;
      --dbms_output.put_line('Query: ' || l_stmt);
      
      -- INIT UPDATE
      BEGIN
         EXECUTE IMMEDIATE l_stmt;
         dbms_output.put_line('Registro actualizado correctamente');
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('');
            dbms_output.put_line('Ha ocurrido un error al actualizar el registro');
            dbms_output.put_line('Código de error: ' || SQLCODE);
            dbms_output.put_line('Mensaje de error: ' || sqlerrm);
            IF SQLCODE = -904
            THEN
               dbms_output.put_line('Las columnas especificadas no existen.');
               dbms_output.put_line('Prueba con las siguientes: ');
               FOR l_desc IN (SELECT * FROM user_tab_columns WHERE table_name = upper(p_tablename)) LOOP
                  dbms_output.put_line('Columna: ' || l_desc.column_name || ' = ''something'' ');
               END LOOP;
            END IF;

      END;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en el procedimiento');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END upd_row;
/


CREATE OR REPLACE PROCEDURE del_row(p_tablename VARCHAR2, p_column VARCHAR2, p_val VARCHAR2) IS
   l_count_t NUMBER;  -- Count tables
   
   l_stmt VARCHAR2(200); -- Statement SQL
   
   l_ok   NUMBER; -- Número de registros ok
   l_err  NUMBER; -- Número de registros con error
   l_t    NUMBER; -- Número de registros actualizados, total
BEGIN
   -- Verifica que la tabla exista
   IF t_exists(p_tablename)
   THEN 
      IF row_exists(p_tablename, p_column, p_val)
      THEN
         -- ELIMINA EL REGISTRO
         dbms_output.put_line('Eliminando el registro de la tabla: ' || p_tablename);
         l_stmt := 'DELETE FROM '||p_tablename||' WHERE '||p_column||' = '''||p_val||''' ';
         dbms_output.put_line(l_stmt);
         EXECUTE IMMEDIATE l_stmt;
         dbms_output.put_line('El registro se ha eliminado correctamente');
      ELSE
         dbms_output.put_line('El registro no existe');
      END IF;
   ELSE
      dbms_output.put_line('No existe alguna tabla con el nombre: ' || p_tablename);
   END IF;
END del_row;
/


CREATE OR REPLACE FUNCTION t_exists(p_tablename VARCHAR2) RETURN BOOLEAN IS
   l_count_t NUMBER;  -- Count tables
   l_retval BOOLEAN := FALSE;  -- Return value
BEGIN
   -- Verifica si la tabla existe
   SELECT COUNT(1) INTO l_count_t
     FROM all_all_tables
    WHERE table_name = upper(p_tablename);
    
   IF l_count_t = 1
   THEN
      l_retval := TRUE;
   END IF;
   
   RETURN l_retval;
END t_exists;
/


CREATE OR REPLACE FUNCTION row_exists(p_tablename VARCHAR2, p_column VARCHAR2, p_val VARCHAR2) RETURN BOOLEAN IS
   l_count_t NUMBER;
   
   l_retval BOOLEAN := FALSE;
   
   l_stmt VARCHAR2(200);
BEGIN
   l_stmt := '
   SELECT COUNT(1)
     FROM '||p_tablename||'
    WHERE '||p_column||' = :1';
   
   -- dbms_output.put_line(l_stmt);
   EXECUTE IMMEDIATE l_stmt INTO l_count_t USING p_val;
   --dbms_output.put_line(l_count_t);
   
   IF l_count_t = 1
   THEN
      l_retval := TRUE;
   END IF;
   
   RETURN l_retval;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error al buscar un registro');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Error del mensaje: ' || sqlerrm);
END;
/


DECLARE
   l_catchval BOOLEAN;
BEGIN 
   l_catchval := row_exists('my_contacts', 'my_contacts_id', '5');
END;
/

-- Puede "sobreescribir" la tabla, borrarla y crearla con los parámetros dados
EXECUTE make_table('my_contacts', 'name varchar2(40)', TRUE);

-- Ingresa los datos en la tabla
EXECUTE add_row('my_contacts', ' ''1'', ''Geoff Gallus'' ');
EXECUTE add_row('my_contacts', ' ''2'', ''Nancy'' ');
EXECUTE add_row('my_contacts', ' ''3'', ''Sunitha Patel'' ');
EXECUTE add_row('my_contacts', ' ''4'', ''Valli Pataballa'' ');
-- Trata de ingresar un dato repetido
EXECUTE add_row('my_contacts', ' ''4'', ''Valli Pataballa'' ');

-- Lanza un error para actualizar
EXECUTE upd_row('my_contacts','1', 'nombre = algo');
EXECUTE upd_row('my_contacts', 'my_contacts_id = ''1'' ', 'nam = ''Angel'' ');

--  Actualización de datos
EXECUTE upd_row('my_contacts', 'my_contacts_id = ''1'' ', 'name = ''Angel'' ');

-- Lanza un error al tratar de eliminar un registro
EXECUTE del_row('my_contacts', 'my_contacts_id', '44');
-- Elimina un registro
EXECUTE del_row('my_contacts', 'my_contacts_id', '3');

SELECT * FROM MY_CONTACTS;

-- Borra la tabla
EXECUTE del_table('my_contacts');

SELECT * FROM MY_CONTACTS;


-- 2. Create a COMPILE_PKG package that compiles the PLSQL code in your schema.
-- a. In the specification, create a package procedure called MAKE that accepts
-- the name of a PLSQL program unit to be compiled.

-- b. In the body, the MAKE procedure should call a private function named GET_TYPE
-- to determine the PLSQL object type from the data dictionary, and return the type
-- name (use PACKAGE for a package with a body) if the object exists; otherwise,
-- it should return a NULL. If the object exists, MAKE dynamically compiles it with
-- the ALTER statement.

-- c. Use the compile_pkg.MAKE procedure to compile the EMPLOYEE_REPORT procedure,
-- the EMP_PKG package, and a nonexistent object called EMP_DATA.

CREATE OR REPLACE PACKAGE compile_pkg IS
   PROCEDURE make(name_program VARCHAR2);
END compile_pkg;
/

CREATE OR REPLACE PACKAGE BODY compile_pkg IS
   -- Private function
   
   PROCEDURE make(name_program VARCHAR2) IS
   BEGIN
      dbms_output.put_line('Inicio del paquete de make...');
   END make;
END compile_pkg;
/


-- 3. Add a procedureto the COMPILE_PKG that uses the DBMS_METADATA to obtaing
-- DDL statement tat can regenerate a named PLSQL subprogram, and writes the DDL
-- statement to a file by using the UTL_FILE package.

