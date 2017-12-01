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


-- Exercise 3. Create a procedure, ADD_EMPLOYEE, to insert a new employee into
-- EMPLOYEES table. The procedure should call a VALID DEPT ID function to check
-- whether the department ID specified for the new employee exists in the 
-- DEPARTMENTS table.

-- a. Create a function VALID_DEPTID to validate a specified department ID and
-- return a BOOLEAN value of TRUE if the department exists.

-- b. Create the ADD_EMPLOYEE procedure to add an employee to the EMPLOYEES
-- table. The row should be added to the EMPLOYEES table if the VALID_DEPTID
-- function returns TRUE; otherwise, alert the user with an appropiate message.
-- Provide the following parameters (with defaults specified in parenthesis):
-- first_name, last_name, email, job(SA_REP), mgr(145), sal(1000), comm(0),
-- and deptid(30). Use the EMPLOYEES_SEQ sequence to set the employee_id column
-- and set hire_date to TRUNC(SYSDATE).

-- c. Call ADD_EMPLOYEE for the name Jane Harris in department 15, leaving other
-- parameters with their default values. What is the result?

-- d. Add another employee named Joe Harris in department 80, leaving remaining
-- parameters with their default values. What is the result?


-- Creating a function VALID_DEPTID
CREATE OR REPLACE
  FUNCTION VALID_DEPTID(dept DEPARTMENTS.department_id%TYPE DEFAULT NULL)
  RETURN BOOLEAN
  IS

  deptname DEPARTMENTS.department_name%TYPE;

  BEGIN
    -- If no data found throw a exception
    SELECT department_name INTO deptname FROM DEPARTMENTS WHERE department_id = dept;
    -- Just send true, because the exception block works...!
    RETURN TRUE;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('El departamento no existe');
        RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('Hay valores duplicados para este departamento');
        RETURN TRUE;

END VALID_DEPTID;
/

-- Creating the sequence EMPLOYEES_SEQ
CREATE SEQUENCE EMPLOYEES_SEQ
  MINVALUE 0
  MAXVALUE 100000
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- Creating the procedure for add a new employee
CREATE OR REPLACE
  PROCEDURE ADD_EMPLOYEE(
    p_first_name EMPLOYEES.first_name%TYPE DEFAULT '',
    p_last_name EMPLOYEES.last_name%TYPE DEFAULT '',
    p_deptid EMPLOYEES.department_id%TYPE DEFAULT 30,
    p_email EMPLOYEES.email%TYPE DEFAULT '',
    p_job EMPLOYEES.job_id%TYPE DEFAULT 'SA_REP',
    p_mgr EMPLOYEES.manager_id%TYPE DEFAULT 145,
    p_sal EMPLOYEES.salary%TYPE DEFAULT 1000,
    p_commission EMPLOYEES.commission_pct%TYPE DEFAULT 0,
    p_hd EMPLOYEES.hire_date%TYPE DEFAULT TRUNC(SYSDATE)
  ) IS

  err_num NUMBER;
  err_msg VARCHAR2(255);

  BEGIN
    IF VALID_DEPTID(p_deptid) THEN
      INSERT INTO EMPLOYEES (
        EMPLOYEE_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        JOB_ID,
        MANAGER_ID,
        SALARY,
        COMMISSION_PCT,
        HIRE_DATE,
        DEPARTMENT_ID
      )
      VALUES (
        ( (SELECT MAX(employee_id) FROM EMPLOYEES) + EMPLOYEES_SEQ.NEXTVAL ),
        p_first_name,
        p_last_name,
        CONCAT(SUBSTR(p_first_name, 1, 1), SUBSTR(p_last_name, 2)),
        p_job,
        p_mgr,
        p_sal,
        p_commission,
        p_hd,
        p_deptid
      );
      COMMIT;
      dbms_output.put_line('--------------------------');
      dbms_output.put_line('Registro agregado.');
      dbms_output.put_line('Datos.');
      dbms_output.put_line('Nombre: ' || p_first_name || ', Apellido: ' || p_last_name);
      dbms_output.put_line('Correo: ' || p_email || ', Job_id: ' || p_job);
      dbms_output.put_line('Manager: ' || p_mgr || ', Salario: ' || p_sal);
      dbms_output.put_line('Comisión: ' || p_commission || 'Fecha de contratación: ' || p_hd);
      dbms_output.put_line('Departamento: ' || p_deptid);
      dbms_output.put_line('');
    ELSE
      dbms_output.put_line('El departamento: ' || p_deptid ||' que se intenta ingresar no es válido');
      dbms_output.put_line('');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de ingresar el registro.');
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
END ADD_EMPLOYEE;
/
