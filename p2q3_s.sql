-- Specification package

CREATE OR REPLACE PACKAGE EMP_PKG IS

  -- PUBLIC PROCEDURES

  PROCEDURE GET_EMPLOYEE(
                          emp_id IN EMPLOYEES.employee_id%TYPE DEFAULT NULL,
                          inout_emp_sal OUT EMPLOYEES.salary%TYPE,
                          inout_emp_job_id OUT EMPLOYEES.job_id%TYPE
                         ); 

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
                         );
    
END EMP_PKG;
/