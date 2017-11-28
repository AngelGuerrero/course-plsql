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

-- b. Compile the code; invoke he procedure to change the job title of the job ID
-- IT_DBA to Data Administrator. Query the JOBS table to view the results.
-- Also check the exception handling by trying to update a job that does not 
-- exists. (You can use the job ID IT_WEB and the job title Web Master).

CREATE OR REPLACE PROCEDURE UPD_JOB(
  j_id    EMPLOYEES.job_id%TYPE,
  j_title EMPLOYEES.job_title%TYPE) IS

  BEGIN
    UPDATE EMPLOYEES e
      SET e.job_title = j_title
      WHERE e.job_id = j_id;
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error, no se ha podido actualizar la tabla');
END;
/
DROP PROCEDURE UPD_JOB;

DESC EMPLOYEES;
    