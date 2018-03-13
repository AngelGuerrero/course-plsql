-- Practice 3

-- Crate a packages specification and body, called JOB__PKG, containing a copy of your
-- ADD_JOB, UPD_JOB_ and DEL_JOB procedures as well as your GET_JOB function.

-- Tip. Consider saving the package specification and body in two separate files
-- (for example, p3q2_s.sql and p3q1_b.sql) for the package specification and body,
-- respectively). Include a SHOW ERRORS after the CREATE PACKAGE statement in each file.

-- Note: User the code in your previously saved script files when creating the package.

-- a. Create the package specification including the procedures and function headings
-- as public constructs.
-- Note: Consider wheather you still need the stand-alone procedures and functions
-- you just packaged.

-- b. Create the package body with the imlementations for each of the subprograms.

-- c. Invoke your ADD_JOB package procedure by passing the values IT_SYSAN and
-- SYSTEMS_ANALYST as parameters.

-- d. Query the JOBS table to see the result

EXECUTE JOB_PKG.ADD_JOB('IT_SYSAN', 'SYSTEMS_ANALYST');
EXECUTE JOB_PKG.UPD_JOB('DEWEB', 'Desarrollador web', 1000, 16000);
EXECUTE JOB_PKG.UPD_JOB('IT_SYSAN', 'SYSTEMS_ANALYST', 20000, 30000);
EXECUTE JOB_PKG.DEL_JOB('DEWEB');
EXECUTE JOB_PKG.DEL_JOB('IT_SYSAN');

EXECUTE dbms_output.put_line(JOB_PKG.GET_JOB('DEWEB'));
EXECUTE dbms_output.put_line(JOB_PKG.GET_JOB('IT_SYSAN'));

SELECT * FROM JOBS; -- ID_PRES



-- Part 2.

-- a. Create a package specification and package body called EMP_PKG that
-- contains your ADD_EMPLOYEE and GET_EMPLOYEE procedure as public constructs,
-- and include your VALID_DEPTID function as a private construct.

-- b. Invoke the EMP_PKG.ADD_EMPLOYEE procedure, using department ID 15 for 
-- employee Jane Harris with the e-mail ID jaharris. Because department ID 15
-- does not exist, you should get an error message as specified in the exception
-- handler of your procedure.

EXECUTE EMP_PKG.ADD_EMPLOYEE('Jane', 'Harris', 15, 'jaharris');

-- c. Invoke the ADD_EMPLOYEE package procedure by using department ID 80 for
-- employee David Smith with the e-mail ID DASMITH

EXECUTE EMP_PKG.ADD_EMPLOYEE('David', 'Smith', 80, 'DASMITH');

