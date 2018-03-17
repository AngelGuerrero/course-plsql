-- Practice 4.

-- 1. Copy and modify the code for the EMP_PKG package that you created in the
-- Practice 3, Exercise 2, and overload the ADD_EMPLOYEE procedure.

-- a. In the package specification, add a new procedure called ADD_EMPLOYEE that
-- accepts three parameters: the first name, last name, and department ID.
-- Save and compile the changes.

-- b. Implement the new ADD_EMPLOYEE procdure in the packages body so that it
-- formats the e-mail address in uppercase characters, using the first letter
-- of the first name concatenaed with the first seven letters of the last name.
-- The procedure should call the existing ADD_EMPLOYEE procedure to perfom the
-- actual INSERT operation using its parameters and formatted e-mail to supply
-- the values. Save and compile the changes.

-- c. Invoke the new ADD_EMPLOYEE procedure using the name Samuel Joplin to be
-- added to department 30.


EXECUTE EMP_PKG.ADD_EMPLOYEE('Samuel', 'Joplin', 30);


-- 2. In the EMP_PKG package, create two overloaded functions called GET_EMPLOYEE

-- a. In the specification, add a GET_EMPLOYEE function that accepts the
-- parameter called emp_id based on the employees.employee_id%TYPE type, and
-- a second GET_EMPLOYEE function that accepts the parameter called family_name
-- of type employees.last_name%TYPE. Both functions sould return an
-- EMPLOYEES%ROWTYPE. Save and compile the changes

-- b. In the package body, implement the first GET_EMPLOYEE function to query
-- and employee by his or her ID, and the second to use the equality operator
-- on the value supplied in the familty_name parameter. Save and compile the
-- changes.

-- c. Add a utility procedure PRINT_EMPLOYEE to the package that accepts and
-- EMPLOYEES%ROWTYPE as a parameter and displays the department_id, employee_id,
-- first_name, last_nam, job_id, and salary for an employee on one line
-- using DBMS_OUTPUT.PUT_LINE. Save and compile the changes.

-- d. Use an anonymus block to invoke the EMP_PKG.GET_EMPLOYEE function with
-- an employee ID of 100 and family name of 'Joplin'. Use the PRINT_EMPLOYEE
-- procedure to display the results for each row returned.


DECLARE
  retstring varchar2(32767);
BEGIN
  retstring := EMP_PKG.PRINT_EMPLOYEE(EMP_PKG.GET_EMPLOYEE(100));
  
  retstring := EMP_PKG.PRINT_EMPLOYEE(EMP_PKG.GET_EMPLOYEE('Joplin'));
END;
/


-- 3. Because the company does not frequently change its departmental data,
-- your improve performance of tour EMP_PKG by adding a public procedure
-- INIT_DEPARTMENTS to populate a private PL/SQL table of valid department IDs.
-- Modify the VALID_DEPTID function to use the private PL/SQL table contents to
-- validate department ID values.

-- a. In the package specification, create a procedure called INIT_DEPARTMENTS
-- with no parameters.

-- b. In the package body, implement the INIT_DEPARTMENTS procedure to store
-- all department IDs in a private PL/SQL index-by table named valid_departments
-- containing BOOLEAN values. 

-- Use the DEPARTMENT_ID column value as the index to
-- create the entry in the index-by table to indicate its presence, and assign the
-- entry a value of TRUE. 

-- Declare the valid_departments variable and its type
-- definition boolean_tabtype before all procedures in the body.

-- c. In the body, create an initialization block that calls the
-- INIT_DEPARTMENTS procedure to initialize the table. Save and compile the
-- changes.



EXECUTE MYTEST_PKG.INIT_DEPARTMENTS;

DESCRIBE valid_departments;

DESCRIBE DEPARTMENTS;



