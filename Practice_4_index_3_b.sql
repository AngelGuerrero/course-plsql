CREATE OR REPLACE PACKAGE BODY MYTEST_PKG IS 

  myquery VARCHAR2(32767);
  err_num NUMBER;
  err_msg VARCHAR2(255);

  -- Private functions --
  FUNCTION initialize_departments RETURN BOOLEAN;
  
  
  PROCEDURE INIT_DEPARTMENTS
  IS
    counter NUMBER;  
    catchval BOOLEAN;
  BEGIN
    
    SELECT COUNT(*) INTO counter FROM SYS.USER_ALL_TABLES WHERE TABLE_NAME = 'VALID_DEPARTMENTS';
    
    IF counter <= 0 THEN
      dbms_output.put_line('No hay ninguna tabla llamada: valid_departments');
      dbms_output.put_line('Creando la tabla de nombre: valid_departments');
      
      myquery := 'CREATE TABLE ORA01.valid_departments
                                                      (dept_id NUMBER(10) NOT NULL,
                                                       
                                                       CONSTRAINT val_departs_pk PRIMARY KEY(dept_id)
                                                       )';
      EXECUTE IMMEDIATE myquery;
    ELSE
      dbms_output.put_line('Ya existe una tabla llamada: valid_departments');
    END IF;
    
    catchval := initialize_departments;
    
  END INIT_DEPARTMENTS;
  
  
  -- Private functions BODY --
  FUNCTION initialize_departments RETURN BOOLEAN 
  IS
  BEGIN
    FOR mydept IN (SELECT * FROM DEPARTMENTS) LOOP
      myquery := 'INSERT INTO ORA01.VALID_DEPARTMENTS(dept_id) VALUES ('||mydept.department_id||')';
      EXECUTE IMMEDIATE myquery;
    END LOOP;
    
    dbms_output.put_line('Departamentos inicializados.');
    RETURN TRUE;
  
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Se está tratando de ingresar datos duplicados');
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
      RETURN FALSE;
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error inesperado, al tratar de ingresar los datos a la tabla');
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
      RETURN FALSE;
  END initialize_departments;
  
END MYTEST_PKG;


