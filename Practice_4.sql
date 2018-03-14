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