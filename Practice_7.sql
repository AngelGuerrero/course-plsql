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
-- table called LOG_NEWEMP, and a sequence called 