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







