-- Practice 2. Creating stored functions

-- After completing this lesson, you should be able to do the following
-- Describe the uses of functions
-- Create stored functions
-- Invoke a function
-- Remove a function
-- Differentiate between a procedure and a function

-- ADVANTAGES OF USER-DEFINED FUNCTIONS IN SQL STATEMENTS
-- Can extend SQL where activities are too complex,
-- too awkward, or unavailable with SQL.
-- Can increase effiency when used in the WHERE clause to filter data,
-- as opposed to filtering the data in the application.
-- Can manipulate data values.

-- LOCATIONS TO CALL USER-DEFINED functions
-- User defined functions act like built-in single-row
-- functions and can be used in:

-- The SELECT list or clause of a query
-- Conditional expressions of the WHERE and HAVING clauses
-- The CONNECT BY, START WITH, ORDER BY, and GROUP BY clauses of a query
-- The VALUES clause of the INSERT statement
-- The SET clause of the UPDATE statement

-- CONTROLLING SIDE EFFECTS WHEN CALLING FUNCTIONS FROM SQL EXPRESSIONS

-- Functions called from
-- A SELECT statement cannot contain DML statements
-- An UPDATE or DELETE statement on a table T canot query or contain DML
-- on the same table T.
-- SQL statements canot end transactions (that is, cannot execute COMMIT or 
-- ROLLBACK operations)

-- Practice 2. 

-- Exercise 1. Create and invoke the GET_JOB function to return a job_title.
-- a. Create and compile a function called GET_JOB to return a job_title.
-- b. Create a VARCHAR2 host variable called TITLE, allowing a length of 35
-- characters. Invoke the function with SA_REP job ID to return the value in the
-- host variable. Print the host variable to view the result.

-- Creating the GET_JOB function
CREATE OR REPLACE 
  FUNCTION GET_JOB(
    j_id JOBS.job_id%TYPE,
    paramout OUT JOBS.job_title%TYPE
  )
  RETURN JOBS.job_title%TYPE IS
  BEGIN
    SELECT job_title INTO paramout FROM JOBS WHERE job_id = j_id;

    RETURN '';
  END;
/

-- Call the function
DECLARE
  retval JOBS.job_title%TYPE; -- It needs a variable for save the return value
  TITLE VARCHAR2(35);
BEGIN
  retval := GET_JOB('SA_REP', TITLE);
  dbms_output.put_line(TITLE);
END;
/


-- Exercise 2. Create a function called GET_ANNUAL_COMP to return the annual
-- salary computed from an employee's monthly salary and commission passed as
-- parameters.
-- a. Develop and store the GET_ANNUAL_COMP function, accepting parameter VALUES
-- for monthly salary and commission. Either or both values passed can be NULL,
-- but the function should still return a non-NULL annual salary. Use the
-- following basic formula to calculate the annual salary:
--      (salary * 12) + (commission_pct * salary * 12)
-- b. Use the function in a SELECT statement against the EMPLOYEES table for
-- EMPLOYEES in department 30.

CREATE OR REPLACE 
  FUNCTION GET_ANNUAL_COMP(salary BINARY_DOUBLE DEFAULT NULL, commission_pct BINARY_DOUBLE DEFAULT 0)
  RETURN BINARY_DOUBLE
  IS
    
  err_num NUMBER;
  err_msg VARCHAR2(255);
  myresult BINARY_DOUBLE;
  
  BEGIN
    CASE
      WHEN salary IS NULL THEN
        myresult := 0;
      WHEN commission_pct IS NOT NULL THEN
        myresult := (salary * 12) + (commission_pct * salary * 12);
      ELSE 
        myresult := (salary * 12);
    END CASE;
    
    RETURN myresult;
    
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error al tratar de calcular el salario anual');
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
  END;
/

SELECT 
  employee_id, 
  last_name, 
  GET_ANNUAL_COMP(salary, commission_pct) "Annual Compensation"
FROM EMPLOYEES
WHERE department_id = 30;

SELECT 
  employee_id, 
  last_name, 
  GET_ANNUAL_COMP(salary) "Annual Compensation"
FROM EMPLOYEES
WHERE department_id = 30;

SELECT 
  employee_id, 
  last_name, 
  GET_ANNUAL_COMP() "Annual Compensation"
FROM EMPLOYEES
WHERE department_id = 30;

