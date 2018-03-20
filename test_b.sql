CREATE OR REPLACE PACKAGE BODY MYTEST_PKG IS 

  -- Private functions --
  FUNCTION initialize_departments RETURN BOOLEAN;
  
  
  PROCEDURE INIT_DEPARTMENTS
  IS
    counter NUMBER;
    myquery VARCHAR2(32767);
    catchval BOOLEAN;
  BEGIN
    
    SELECT COUNT(*) INTO counter FROM SYS.USER_ALL_TABLES WHERE TABLE_NAME = 'VALID_DEPARTMENTS';
    
    IF counter <= 0 THEN
      dbms_output.put_line('No hay ninguna tabla llamada: valid_departments');
      dbms_output.put_line('Creando la tabla de nombre: valid_departments');
      
      myquery := 'CREATE TABLE ORA01.valid_departments
                                                          (dept_id NUMBER(10) NOT NULL,
                                                           dept_name VARCHAR2(45) NOT NULL,
                                                           
                                                           CONSTRAINT val_departs_pk PRIMARY KEY(dept_id)
                                                           )';
      EXECUTE IMMEDIATE myquery;
    ELSE
      dbms_output.put_line('Existe una tabla llamada: valid_departments');
    END IF;
    
    catchval := initialize_departments;
    
    IF catchval THEN
      dbms_output.put_line('Se han ingresado correctamente los datos en la tabla');
    ELSE
      dbms_output.put_line('Ha ocurrido un error al tratar de ingresar los datos en la tabla');
    END IF;
    
  END INIT_DEPARTMENTS;
  
  
  -- Private functions BODY --
  FUNCTION initialize_departments RETURN BOOLEAN 
  IS
    myquery VARCHAR(32767);
  BEGIN
    dbms_output.put_line('Ingresando los datos en la tabla valid_departments');
    
    myquery := 'CREATE OR REPLACE TABLE ORA01.valid_departments
                (department_id number(10) NOT NULL,
                 department_name varchar2(50) NOT NULL,
                 
                 CONSTRAINT departments_pk PRIMARY KEY (department_id)
                )';                          
  
    
     EXECUTE IMMEDIATE myquery;
    
    dbms_output.put_line('Inicializando los departamentos.');
    
    FOR mydept IN (SELECT * FROM DEPARTMENTS)
    LOOP
      dbms_output.put_line(mydept.department_id || ' ' || mydept.department_name);
      
      INSERT INTO ORA01.valid_departments 
        VALUES
               (
                mydept.department_id,
                mydept.department_name
                );
    END LOOP;
    
      
    RETURN TRUE;
    
  END initialize_departments;
  
END MYTEST_PKG;


