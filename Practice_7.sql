-- Practice 7.
-- 1. Update EMP_PKG with a new procedure to query employees in a specified
-- department.

-- a. In the specification, declare a get_employees procedure, with its parameter
-- called dept_id based on the emploees.deparment_id column type.
-- Define an index-by PL/QL type as a TABLE OF EMPLOYEES%ROWTYPE.

-- b. In the body of the package, define a private variable called emp_table
-- based on the type defined in the specification to hold employee records.
-- Implement the get_employees procedure to bulk fetch the data into the table.

-- c. Create a new procedure in the specification and body, called show_employees,
-- that does not take argument and displays the contents of the private PLSQL table
-- variable (if any data exists).

-- Hint: Use the print_employee procedure.

-- d. Invoke the emp_pkg.get_employees procedure for department 30,
-- and invoke emp_pkg.show_employees. Repeat this for department 60.

BEGIN emp_pkg.get_employees(30); emp_pkg.show_employees; END;
/

BEGIN emp_pkg.get_employees(60);  emp_pkg.show_employees; END;
/

BEGIN emp_pkg.get_employees(210);  emp_pkg.show_employees; END;
/

-- Your manager wants to keep a log whenever the add_employee procedure in the
-- package is invoked to insert a new employee into the EMPLOYEES table.

-- a. First, load and execute the E:/tmp/lab_07_02_a.sql script to create a log
-- table called LOG_NEWEMP, and a sequence called log_newemp_seq

-- b. In the package body, modify the add_employee procedure, which performs the
-- actual INSERT operation, to have a local procdure called audit_newemp.
-- The audit_newemp procedure must use an autonomous transaction to insert a log
-- record into the LOG_NEWEMP table. Store the USER, the current time, and
-- the new employee name in the log table row. Use log_newemp_seq to set the
-- entry_id column.

-- Note: Remember to perform a COMMIT operation in a procedure with an autonomous
-- transaction.

-- c. Modify the add_employee procedure to invoke audit_emp before it performs
-- the insert operation.

-- d. Ivoke the add_employee procedure for these new employees: Max Smart in
-- department 20 and Clark Kent in department 10. What happenst?

-- e. Query the two EMPLOYEES records added, and the records in LOG_NEWEMP
-- table. How many log records are present?

-- f. Execute a ROLLBACK statement to undo the insert operations that have not
-- been committed. Use the same queries from Exercise 2e. The first to check
-- whether the employee rows for Smart and Kent have been removed, and the second
-- to check the log records in the LOG_NEWEMP table. How many log records are present? 
-- Why?


EXECUTE make_table('log_newemp', 'username VARCHAR2(40), created_at TIMESTAMP, employee_name VARCHAR2(40)', TRUE);

CREATE SEQUENCE log_new_emp_seq
                        START WITH 1
                        INCREMENT BY 1
                        NOCACHE
                        NOCYCLE;

BEGIN emp_pkg.add_employee('Max', 'Smart', 20); END; 
/

BEGIN emp_pkg.add_employee('Clark', 'Kent', 10); END;
/

SELECT * FROM LOG_NEWEMP;

SELECT * FROM EMPLOYEES WHERE first_name = 'Max';
SELECT * FROM EMPLOYEES ORDER BY first_name;

TRUNCATE TABLE LOG_NEWEMP;
DELETE FROM EMPLOYEES WHERE first_name = 'Clark';
DELETE FROM EMPLOYEES WHERE first_name = 'Max';





EXECUTE make_table('mytable_t', 'status VARCHAR2(40), lpn_id VARCHAR2(40)');

DESC MYTABLE_T;

CREATE SEQUENCE tseq
        INCREMENT BY 1
        NOCACHE
        NOCYCLE;
        
DROP SEQUENCE tseq;

CREATE OR REPLACE PROCEDURE insert_into_test IS
   l_stmt VARCHAR2(200);
BEGIN
   l_stmt := 'INSERT INTO MYTABLE_T VALUES ('||tseq.NEXTVAL||', ''ACTIVA'', NULL)';
   EXECUTE IMMEDIATE l_stmt;
   dbms_output.put_line(l_stmt);
END;
/

EXECUTE insert_into_test;

DECLARE
BEGIN
  dbms_scheduler.create_job(job_name => 'job_test_insert',
                               job_type => 'STORED_PROCEDURE',
                               job_action => 'insert_into_test',
                               start_date => SYSTIMESTAMP,
                               repeat_interval => 'FREQ=SECONDLY;INTERVAL=1',
                               enabled => TRUE);
END;
/

BEGIN dbms_scheduler.run_job('job_test_insert'); END;
/

SELECT * FROM MYTABLE_T;
SELECT COUNT(1) FROM MYTABLE_T;

SELECT *
  FROM MYTABLE_T
 WHERE STATUS = 'ACTIVA';


DECLARE
   TYPE test_tabtype IS TABLE OF MYTABLE_T%ROWTYPE
      INDEX BY PLS_INTEGER;
      
   l_container test_tabtype := test_tabtype();
   l_elegible  test_tabtype;
   
   -- Datos control
   l_count     NUMBER := 0;
   l_count_err NUMBER := 0;
   l_count_ok  NUMBER := 0;
   
BEGIN
   SELECT * 
     BULK COLLECT
     INTO l_container
     FROM MYTABLE_T
    WHERE 1 = 1
      AND STATUS = 'ACTIVA'
      AND LPN_ID IS NULL;
   
   FOR indx IN 1 .. l_container.COUNT
   LOOP
      IF l_container(indx).status = 'ACTIVA'
      THEN
         --dbms_output.put_line('La etiqueta está activa: ' || l_container(indx).status);
         l_elegible(l_elegible.COUNT + 1) := l_container(indx);
      END IF;  
   END LOOP;
   
   BEGIN
      FORALL indx IN 1 .. l_elegible.COUNT
         UPDATE MYTABLE_T t
            SET t.STATUS = 'CANCELADA'
          WHERE 1 = 1
            AND t.MYTABLE_T_ID = l_elegible(indx).mytable_t_id;
            
      -- Obtiene el número de registros que se procesaron con éxito
      l_count_ok := l_elegible.COUNT;
      
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('Ha ocurrido un error en la actualización de registros.');
            dbms_output.put_line('Código de error: ' || SQLCODE);
            dbms_output.put_line('Mensaje de error: ' || sqlerrm);
            -- Incrementa el número de registros con error
            l_count_err := l_count_err + 1;
   END;
   
      -- Obtiene el total de registros que se procesaron
   l_count := l_elegible.COUNT;
   
   dbms_output.put_line('-------- CIFRAS CONTROL ---------------');
   dbms_output.put_line('Total de registros procesados: ' || l_count);
   dbms_output.put_line('Total de registros con error: ' || l_count_err);
   dbms_output.put_line('Total de registros actualizados: ' || l_count_ok);
   
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error en el procedimiento');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mesaje de error: ' || sqlerrm);
END;
/

