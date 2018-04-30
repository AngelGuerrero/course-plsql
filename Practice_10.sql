-- Practice 10
-- 1 .The rows in the JOBS table store a minimum and maximum salary allowed for
-- different JOB_ID values. You are asked to write code to ensure that employees'
-- salaries fall in the range allowed for their job type, for insert and update operations.

-- a. Write a procedure called CHECK_SALARY that accepts two praameters, 
-- one for an employee's job DI string and the other for the salary.

-- The procedure uses the job ID to determine the minimum and maximum salary for 
-- the specified job. If the salary parameter does not fall within the salary 
-- range of the job, inclusive of the minimum and maximum, then it should raise
-- an application exception, with the message 'INVALID SALARY <SAL>. salaries for
-- job <jobid> must be betweeen <min> and <max>'.
--
-- Replace the various items in the message with values supplied by parameters
-- and variables populates by queries. Save the file.

-- b. Create a trigger called CHECK_SALARY_TRG on EMPLOYEES table that fires
-- before INSERT or UPDATE operation on each row. The trigger must call the 
-- CHECK_SALARY procedure to carry out the business logic. The trigger should
-- pass the new job ID and salary to the procedure parameters.

-- 2. Test the CHECK_SALARY_TRG using the following cases:
-- a. Using your EMP_PKG.ADD_EMPLOYEE procedure, add employee Eleanor Beh to 
-- department 10. What happens and why?

-- b. Update the salary of employee 115 to $2,000. In a separate upadte operation,
-- change the employee job ID to HR_REP. What happens en each case?

-- c. Update the salary of employee 115 to $2,800. What happens?

BEGIN 

  emp_pkg.add_employee(p_first_name => 'Eleanor'
                       ,p_last_name => 'Beh'
                       ,p_deptid    => 10
                      );
END;
/


UPDATE employees
   SET salary = 2000
 WHERE 1 = 1
   AND job_id = 'HR_REP'
   AND employee_id = 115
     ;


