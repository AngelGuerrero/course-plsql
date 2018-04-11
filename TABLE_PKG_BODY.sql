CREATE OR REPLACE PACKAGE BODY TABLE_PKG IS

  PROCEDURE make_table(p_tablename VARCHAR2, p_options VARCHAR2, p_override BOOLEAN DEFAULT FALSE) IS
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
        dbms_output.put_line('Error: '|| SQLCODE);
        dbms_output.put_line('Mensaje: ' || sqlerrm);
  END make_table;
  
  
  PROCEDURE del_table(p_tablename VARCHAR2) IS
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
  
  
  PROCEDURE add_row(p_tablename VARCHAR2, p_values VARCHAR2) IS
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
  
  
  PROCEDURE upd_row(p_tablename VARCHAR2, p_cond VARCHAR2, p_assoc_val VARCHAR2) IS
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
  
  
  PROCEDURE del_row(p_tablename VARCHAR2, p_column VARCHAR2, p_val VARCHAR2) IS
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
  
  
  FUNCTION t_exists(p_tablename VARCHAR2) RETURN BOOLEAN IS
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
  
  
  FUNCTION row_exists(p_tablename VARCHAR2, p_column VARCHAR2, p_val VARCHAR2) RETURN BOOLEAN IS
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
  END row_exists;  
  
END TABLE_PKG;