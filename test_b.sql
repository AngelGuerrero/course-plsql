CREATE OR REPLACE PACKAGE BODY MYTEST_PKG IS 

  -- Private functions --
  FUNCTION initialize_departments RETURN BOOLEAN;
  
  
  PROCEDURE INIT_DEPARTMENTS
  IS
    myquery VARCHAR(32767);
    catchval BOOLEAN;
  BEGIN
    myquery := 'CREATE OR REPLACE TABLE ORA01.valid_departments(
                            department_id NUMBER(4),
                            department_name VARCHAR2(45),
                            
                            PRIMARY KEY(department_id))';
    
    EXECUTE IMMEDIATE myquery;
    
    catchval := initialize_departments;
    
  END INIT_DEPARTMENTS;
  
  
  -- Private functions BODY --
  FUNCTION initialize_departments RETURN BOOLEAN 
  IS
    retval BOOLEAN;
    
  BEGIN
    
    dbms_output.put_line('Inicializando los departamentos.');
    
    FOR mydept IN (SELECT * FROM DEPARTMENTS)
    LOOP
      dbms_output.put_line(mydept.department_id || ' ' || mydept.department_name);
      INSERT INTO valid_departments(
                                    department_id, 
                                    department_name
                                   )
                                   VALUES
                                   (
                                    mydept.department_id,
                                    mydept.department_name);
    END LOOP;
    
      
    RETURN TRUE;
    
  END initialize_departments;
  
END MYTEST_PKG;



CREATE OR REPLACE PACKAGE BODY MYTEST_PKG IS 

-- Private functions --
--FUNCTION initialize_departments RETURN BOOLEAN;


PROCEDURE INIT_DEPARTMENTS IS

myquery VARCHAR2(2000);
--catchval BOOLEAN;
BEGIN

/*
 myquery := 'CREATE TABLE ORA01.valid_departments(
                          department_id NUMBER,
                          department_name VARCHAR2(30),
                          presence VARCHAR2(1))';
*/                          
myquery := 'CREATE TABLE ORA01.customers
( customer_id number(10) NOT NULL,
 customer_name varchar2(50) NOT NULL,
 city varchar2(50),
 CONSTRAINT customers_pk PRIMARY KEY (customer_id)
)';                          
  
  EXECUTE IMMEDIATE myquery;
  
  --catchval := initialize_departments;
  
END INIT_DEPARTMENTS;


-- Private functions BODY --
FUNCTION initialize_departments RETURN BOOLEAN 
IS
  retval BOOLEAN;
  
  presence  BOOLEAN;
  
BEGIN
  
  dbms_output.put_line('Inicializando los departamentos.');
  
  FOR mydept IN (SELECT * FROM DEPARTMENTS)
  LOOP
    dbms_output.put_line(mydept.department_id || ' ' || mydept.department_name);
    INSERT INTO valid_departments(
                                  department_id, 
                                  department_name, 
                                  presence
                                 )
                                 VALUES
                                 (
                                  mydept.department_id,
                                  mydept.department_name,
                                  TRUE);
  END LOOP;
  
    
  RETURN TRUE;
  
END initialize_departments;

END MYTEST_PKG;




