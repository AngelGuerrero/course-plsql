create or replace PACKAGE BODY MYTEST_PKG IS 
  
  l_query  VARCHAR2(3000) := NULL;

  -- Private functions --
  FUNCTION initialize_departments RETURN BOOLEAN;
   
 

/*===============================================================+
 PROCEDURE:    INIT_DEPARTMENTS
 DESCRIPTION:  Procedimiento que crea una tabla en el esquema de ORA01
 ARGUMENTS:
               IN
                  
               OUT

 RETURNS:      N/A
 NOTES:        procedimiento de prueba

 HISTORY
 Version    Date         Author                   Change Reference
  1.0      16/03/2018   JOSE HEBERT  HDZ. HDZ.    1. Creacion del procedimiento
+================================================================*/   
  PROCEDURE INIT_DEPARTMENTS IS
     l_counter  NUMBER;  
     l_catchval BOOLEAN;
  BEGIN
    
     SELECT COUNT(1) 
       INTO l_counter 
       FROM SYS.USER_ALL_TABLES 
      WHERE table_name = 'VALID_DEPARTMENTS';
    
     IF l_counter = 0 THEN
        dbms_output.put_line('Creando la tabla de nombre: valid_departments');
    
        l_query := 'CREATE TABLE ORA01.valid_departments(dept_id NUMBER(10) NOT NULL,                                                      
                                                       CONSTRAINT val_departs_pk PRIMARY KEY(dept_id)
                                                       )';
        EXECUTE IMMEDIATE l_query;
     ELSE
        dbms_output.put_line('Ya existe una tabla llamada: valid_departments');
     END IF;
    
     l_catchval := initialize_departments;
     
     IF l_catchval THEN
        dbms_output.put_line('insert OK');
     ELSE
        dbms_output.put_line('ocurrió un error en el insert');
     END IF;
    
  END INIT_DEPARTMENTS;


  -- Private functions BODY --
  FUNCTION initialize_departments RETURN BOOLEAN IS

  BEGIN
     dbms_output.put_line('Inicializando los departamentos.');
    
     FOR mydept IN (SELECT * FROM DEPARTMENTS) 
        LOOP
           dbms_output.put_line('Departamento: ' || mydept.department_name);
           l_query := 'INSERT INTO ORA01.VALID_DEPARTMENTS(dept_id) VALUES ('||mydept.department_id||')';
           dbms_output.put_line(l_query);

           EXECUTE IMMEDIATE l_query;
        END LOOP;
  
     COMMIT;
     RETURN TRUE; -- Regresa true sólo por la función, falta configurar...
     
  EXCEPTION
     WHEN OTHERS THEN
        dbms_output.put_line('ERROR : ' || SQLERRM);
        RETURN FALSE;
  END initialize_departments; 
 
END MYTEST_PKG;
