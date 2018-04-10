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

BEGIN compile_pkg.make('employee_report'); END;
/

BEGIN compile_pkg.make('emp_pkg'); END;
/

BEGIN compile_pkg.make('emp_data'); END;
/


-- 3. Add a procedure the COMPILE_PKG that uses the DBMS_METADATA to obtaing
-- DDL statement tat can regenerate a named PLSQL subprogram, and writes the DDL
-- statement to a file by using the UTL_FILE package.

-- a. In the package specification, create a procedure called REGENERATE that accepts
-- the name of a PL/SQL component to be regenerated. Declare a public VARCHAR2
-- variable called dir initialized with the directory alias value 'UTL_FILE'.
-- Compile the specification.

-- b. In the package body, impolement the REGENERATE procedure so that it uses the
-- GET_TYPE function to determine the PL/SQL object type from the supplied name
-- if the object exists, then obtain the DDL statement used to create the compoonent
-- using the DBMS_METADATA.GET_DDL procedure, which must be provided with the object 
-- name in uppercase text.
-- Save the DDL statement in a file by using the UTL_FILE.PUT procedure, which must
-- be provided with the object name in uppercase text.

-- Save the DDL statement in a file by using the UTL_FILE.PUT procedure. Write
-- the file in the directory path stored in the public variable called dir (from the
-- specification). Construct a file name (in lowercase characters) by concatenating
-- the USER function, an underscore, and the object name with a .sql extension.

-- For example: ora01_myobject.sql Compile the body

-- c. Execute the COMPILE_PKG.REGENERATE procedure by using the name of the TABLE_PKG
-- created in the first task of this practice.

-- d. Use Putty FTP to get the generated file from the server to your local directory
-- edit the file to insert a / terminator character at the end of a CREATE statement
-- (if required). Cut and paste the results into the SQLPlus buffer and execute the
-- statement.














