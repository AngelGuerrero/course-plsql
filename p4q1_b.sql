-- Body packages

CREATE OR REPLACE PACKAGE BODY EMP_PKG IS

  -- || VARIABLES ||
  err_num NUMBER;
  err_msg VARCHAR2(255);
  
  -- || PRIVATE FUNCTIONS ||
  
  FUNCTION VALID_DEPTID(dept DEPARTMENTS.department_id%TYPE DEFAULT NULL) RETURN BOOLEAN;

  -- || BODY PROCEDURES ||

  -- << Add a new employee with optional parameters >> --
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
  -- Variables
  employees_seq EMPLOYEES.EMPLOYEE_ID%TYPE;
  BEGIN
    IF VALID_DEPTID(p_deptid) THEN
      
      SELECT MAX(EMPLOYEE_ID) + 1 INTO employees_seq FROM EMPLOYEES;
      
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
        employees_seq,
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
      dbms_output.put_line('Nombre: ' || p_first_name || ' ' || p_last_name);
      dbms_output.put_line('Correo: ' || p_email);
      dbms_output.put_line('Job_id: ' || p_job);
      dbms_output.put_line('Manager: ' || p_mgr);
      dbms_output.put_line('Salario: ' || p_sal);
      dbms_output.put_line('Comisión: ' || p_commission);
      dbms_output.put_line('Fecha de contratación: ' || p_hd);
      dbms_output.put_line('Departamento: ' || p_deptid);
      dbms_output.put_line('');
    ELSE
      dbms_output.put_line('El departamento: ' || p_deptid ||' que se intenta ingresar no es válido');
      dbms_output.put_line('');
    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('El registro que se intenta agregar, ya está en la base de datos');
      dbms_output.put_line('Código de error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de ingresar el registro.');
      dbms_output.put_line('Código de error: ' || err_num);
      dbms_output.put_line('Mensaje: ' || err_msg);
  END ADD_EMPLOYEE;
  
  
  -- << Add a new employee with others parameters >> --
    -- Practice 4. -> a        
  PROCEDURE ADD_EMPLOYEE(
                          p_deptid EMPLOYEES.department_id%TYPE,
                          p_first_name EMPLOYEES.first_name%TYPE,
                          p_last_name EMPLOYEES.last_name%TYPE
                        ) IS
    custom_email EMPLOYEES.EMAIL%TYPE;
  BEGIN
    custom_email := UPPER(CONCAT(SUBSTR(p_first_name, 1, 1), SUBSTR(p_last_name, 1, 7)));
    
    ADD_EMPLOYEE(p_first_name, p_last_name, p_deptid, custom_email);
    
    dbms_output.put_line(custom_email);
  END ADD_EMPLOYEE;


  -- << Get an employee with salary and manager id >> --
  PROCEDURE GET_EMPLOYEE(
                         emp_id IN EMPLOYEES.employee_id%TYPE DEFAULT NULL,
                         inout_emp_sal OUT EMPLOYEES.salary%TYPE,
                         inout_emp_job_id OUT EMPLOYEES.job_id%TYPE
                         ) IS
  BEGIN
    IF (emp_id IS NOT NULL) THEN
      SELECT 
        job_id, salary INTO inout_emp_job_id, inout_emp_sal
      FROM EMPLOYEES 
      WHERE employee_id = emp_id;
      
      dbms_output.put_line('Empleado: ' || emp_id);
    ELSE
      dbms_output.put_line('No se ha ingresado ningún parámetro');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el ID: ' || emp_id);

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de recuperar un empleado');
      dbms_output.put_line('Error: ' || err_num);
      dbms_output.put_line(err_msg);
  END GET_EMPLOYEE;


  -- << Valid department id >> --
  FUNCTION VALID_DEPTID(dept DEPARTMENTS.department_id%TYPE DEFAULT NULL)
  RETURN BOOLEAN
  IS
  deptname DEPARTMENTS.department_name%TYPE;
  BEGIN
    -- If no data found throw a exception
    SELECT department_name INTO deptname FROM DEPARTMENTS WHERE department_id = dept;
    -- Just send true, because the exception block, works...!
    RETURN TRUE;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('El departamento no existe');
        RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('Hay valores duplicados para este departamento');
        RETURN TRUE;
  END VALID_DEPTID;
  
END EMP_PKG;
/