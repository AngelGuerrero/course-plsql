-- Practice 1. Exercise 2

-- Create a procedure called HELLO to display the text HelloWorld
-- a. Create a procdure called HELLO.
-- b. In the executable section, use the DBMS_OUTPUT.PUT_LINE procedure to print
-- the text Hello World', and save the code in the database.
-- c. Execute the SET SERVEROUTPUT ON command to ensure that the output from
-- the DBMS_OUTPUT.PUT_LINE procedure is displayed in iSQ*Plus
-- d. Create an anonymous block to invoke the stored procedure.

CREATE OR REPLACE PROCEDURE HELLO IS
BEGIN
  dbms_output.put_line('Hello World');
END;
/

SET SERVEROUTPUT ON;

BEGIN
  HELLO;
END;
/
--------------------------------------------------------------------------------

-- Practice 1. Exercise 3

-- a. Create  a function called TOTAL_SALARY to compute the sum of all employees
-- salaries.

-- b. In the executable section, execute a query to store the total salary of all
-- employees in a local variable that you declare in the declarations section.
-- Return the value stored in the local variable. Save and compile the code.

-- c. Use an anonymous block to invoke the function. To display the result
-- computed by the function, use the DBMS_OUTPUT.PUT_LINE procedure.

-- Function to calculate the total salary of all employees.
CREATE OR REPLACE FUNCTION TOTAL_SALARY RETURN NUMBER IS
  total_salary EMPLOYEES.salary%TYPE;
BEGIN
  SELECT SUM(salary) INTO total_salary
  FROM EMPLOYEES;

  RETURN total_salary;
END;
/


-- Anonymous block
BEGIN
  dbms_output.put_line(TOTAL_SALARY);
END;
/

--------------------------------------------------------------------------------

-- Practice 1. REAL

-- 1. Create and invoke the ADD_JOB procedure and consider the results.

-- a. Create a procedure called ADD_JOB to insert a new job into the JOBS table.
-- Provide the ID and title of the job using two parameters.

-- b. Compile the code; invoke the procedure with IT_DBA as job ID and Database
-- Administrator as job_title. Query the JOBS table to view the results.

-- c. Invoke your procedure again, passing a job ID of ST_MAN and a job title of 
-- Stock Manager. What happens and why?

CREATE OR REPLACE PROCEDURE ADD_JOB (
  j_id    JOBS.job_id%TYPE,
  j_title JOBS.job_title%TYPE) IS
  
BEGIN
  INSERT INTO JOBS(job_id, job_title) VALUES (j_id, j_title);
  COMMIT;
  
  dbms_output.put_line(j_id || ', ' || j_title || ' agregados correctamente');
END;
/

EXECUTE ADD_JOB('IT_DBA', 'DATABASE ADMINISTRATOR');

EXECUTE ADD_JOB('ST_MAN', 'STOCK MANAGER');


-- Lo que pasa es que ocurre un error, 'unique constraint violated'
-- Se trata de insertar un valor que ya está dentro de los registros y que
-- contiene una llave primaria.


--------------------------------------------------------------------------------

-- Practice 1. Excercise 2

-- Create a procedure called UPD_JOB to modify a job in the JOBS table.

-- a. Create a procedure called UPD_JOB to update the job title. Provide the
-- job ID and a new title using two parameters. Include the necessary exception
-- handling if no update occurs.

-- b. Compile the code; invoke the procedure to change the job title of the job ID
-- IT_DBA to Data Administrator. Query the JOBS table to view the results.
-- Also check the exception handling by trying to update a job that does not 
-- exists. (You can use the job ID IT_WEB and the job title Web Master).

CREATE OR REPLACE PROCEDURE UPD_JOB(j_id IN JOBS.job_id%TYPE, j_title IN JOBS.job_title%TYPE) IS
  
  db_job_title JOBS.job_title%TYPE;
  DUP_DATA_EXCEPTION EXCEPTION;
  
  err_num NUMBER;
  err_msg VARCHAR2(255);
  
  BEGIN
    SELECT job_title INTO db_job_title FROM JOBS WHERE job_id = j_id;
    
    -- Verify the title into the database not be equal that parameter
    IF (db_job_title = j_title) THEN
      RAISE DUP_DATA_EXCEPTION;
    ELSE
      -- Update the employee data
      UPDATE jobs
        SET jobs.job_title = j_title
        WHERE jobs.job_id = j_id;
      COMMIT;
      dbms_output.put_line('El JOB_ID: ' || j_id || ', ha sido actualizado por: ' || j_title);
    END IF;
  
  EXCEPTION
    WHEN DUP_DATA_EXCEPTION THEN
      dbms_output.put_line('Error: El registro que se intenta actualizar ya contiene estos valores');
    
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Error: No hay ningún registro con el JOB_ID: ' || j_id);
      
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de actualizar los datos');
      dbms_output.put_line('Error: ' || TO_CHAR(err_num));
      dbms_output.put_line('mensaje: ' || err_msg);
      
END UPD_JOB;
/
-- Execute the following sentences for view the result
EXECUTE UPD_JOB('IT_DBA', 'ADMINISTRATOR');
EXECUTE UPD_JOB('IT_WEB', 'Web Master');
SELECT * FROM JOBS;


--------------------------------------------------------------------------------

-- Practice 1, Exercise 3

-- Create a procedure called DEL_JOB to delete a job from the JOBS table.

-- a. Create a procedure called DEL_JOB to delete job. Incude the necessary
-- exception handling if no job is deleted.
-- b. Compile the code; invoke the procedure using the job ID IT_DBA.
-- Query the JOBS table to view the results.
-- Also, check the exception handling by trying to delete a job that does not
-- exists. Use the IT_WEB job ID. You should get the message that you used in
-- the exception-handling section of the procedure as output.

CREATE OR REPLACE PROCEDURE DEL_JOB(j_id IN JOBS.job_id%TYPE) IS
  err_num NUMBER;
  err_msg VARCHAR2(255);
  db_j_title JOBS.job_title%TYPE;

  BEGIN
    -- If the data doesn't exists it'll throw a exception
    SELECT job_title INTO db_j_title FROM JOBS WHERE job_id = j_id;

    DELETE FROM JOBS
    WHERE JOBS.job_id = j_id;
    dbms_output.put_line('El registro se ha eliminado con éxito');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se ha encontrado ningún registro con el ID: ' || j_id);

    WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error al tratar de eliminar el registro' || j_id);
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
END DEL_JOB;
/

EXECUTE DEL_JOB('IT_DBA');
EXECUTE DEL_JOB('IT_WEB');

SELECT * FROM JOBS;

--------------------------------------------------------------------------------

-- Practice 1. Exercise 4

-- Create a procedure called GET_EMPLOYEE to query the EMPLOYEES table,
-- retrieving the salary and job ID for an employee when provided with the employee ID

-- a. Create a procedure that returns a value from the SALARY and JOB_ID columns
-- for specific employee ID. Compile the code and remove the syntax errors.

-- b. Execute the procedure using host variables for the two OUT parameters
-- one for the salary and other for the job ID. Display the salary and job ID
-- for employee ID 120

-- c. Invoke the procedure again, passing an EMPLOYEE_ID of 300. What happens and
-- why?

CREATE OR REPLACE
  PROCEDURE GET_EMPLOYEE(emp_id EMPLOYEES.employee_id%TYPE DEFAULT NULL) IS
  
  e_job_id EMPLOYEES.job_id%TYPE;
  e_salary EMPLOYEES.salary%TYPE;

  err_num NUMBER;
  err_msg VARCHAR2(255);

  BEGIN
    IF (emp_id IS NOT NULL) THEN
      SELECT job_id, salary INTO e_job_id, e_salary FROM EMPLOYEES WHERE employee_id = emp_id;
      dbms_output.put_line('Empleado: ' || emp_id);
      dbms_output.put_line('Salario: ' || e_salary || ' job_id: ' || e_job_id);
    ELSE
      dbms_output.put_line('No se ha ingresado ningún parámetro');
    END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el ID: ' || emp_id);

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de recuperar un empleado');
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line(err_msg);
  END GET_EMPLOYEE;
/

EXECUTE GET_EMPLOYEE();

DESCRIBE EMPLOYEES;






