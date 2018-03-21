/*=============================================================================+
   Filename: EMPLOYEE_PACKAGE_BODY.sql
   Component: Package
   Package: EMPLOYEE_PACKAGE
   Designer: Luis Ángel De Santiago Guerrero
   Developer: Luis Ángel De Santiago Guerrero
   Version: 1.0
   Description: Paquete para el manejo de datos en la tabla EMPLOYEES
/*============================================================================*/


/*===================================================================+
    BODY PACKAGE
+===================================================================*/

CREATE OR REPLACE PACKAGE BODY EMP_PKG IS

   -- DECLARE GLOBAL VARIABLES
   g_myquery VARCHAR2(32767);
   g_err_msg VARCHAR2(255);
   g_err_num NUMBER;

   -- DECLARE PRIVATE FUNCTIONS
   FUNCTION chk_init_depts RETURN BOOLEAN;

   FUNCTION valid_department(p_dept DEPARTMENTS.department_id%TYPE DEFAULT NULL) RETURN BOOLEAN;

   /*===============================================================+
   PROCEDURE:    add_employee
   DESCRIPTION:  Agrega un empleado en la tabla EMPLOYEES con argumentos por defecto
   ARGUMENTS:
               IN p_first_name Recibe el primer nombre del empleado.
                  p_last_name Recibe el apellido o apellidos del empleado.
                  p_deptid Recibe el departamento donde se encontrará el empleado.
                  p_email Recibe el email del empleado, sin el dominio de la empresa.
                  p_job Recibe el identificador del puesto que se le asignará.
                  p_mgr Recibe el identificador del manager que se le asignará.
                  p_sal Recibe el salario que el empleado tendrá.
                  p_commission Recibe la cantidad de comisión que el empleado ganará.
                  p_hd Recibe la fecha en la que el empleado se contrató, si no se especifica
                       el procidimiento toma la fecha cuando se ejecutó el procedimiento.

               OUT

   RETURNS:      N/A
   NOTES:

   HISTORY
   Version     Date         Author                    Change Reference
   1.0         21/03/2018   Ángel Guerrero.           1. Creación del procedimiento.
   +================================================================*/
   PROCEDURE add_employee(
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
  l_employees_seq EMPLOYEES.EMPLOYEE_ID%TYPE;
  BEGIN
    IF valid_department(p_deptid) THEN

      SELECT MAX(EMPLOYEE_ID) + 1 INTO l_employees_seq FROM EMPLOYEES;

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
        l_employees_seq,
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
      g_err_num := SQLCODE;
      g_err_msg := SQLERRM;
      dbms_output.put_line('El registro que se intenta agregar, ya está en la base de datos');
      dbms_output.put_line('Código de error: ' || g_err_num);
      dbms_output.put_line('Mensaje: ' || g_err_msg);
    WHEN OTHERS THEN
      g_err_num := SQLCODE;
      g_err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de ingresar el registro.');
      dbms_output.put_line('Código de error: ' || g_err_num);
      dbms_output.put_line('Mensaje: ' || g_err_msg);
  END add_employee;


  /*===============================================================+
     PROCEDURE:    add_employee
     DESCRIPTION:  Agrega un empleado aceptando sólo unos cuántos parámetros.
     ARGUMENTS:
                 IN p_deptid Recibe el identificador del departamento donde se
                             asignará al empleado a registrar.
                    p_first_name Recibe el nombre del empleado.
                    p_last_name Recibe el apellido del empleado.

                 OUT

     RETURNS:      N/A
     NOTES:        En este procedimiento se reciben los anteriores parámetros,
                   mas sin embargo, internamente se llama a otra función para
                   agregar un empleado, manda llamar al procedimiento que recibe
                   todos los parametros para agregar un empleado.


     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de procedimiento.
  +================================================================*/
  PROCEDURE add_employee(
                          p_deptid EMPLOYEES.department_id%TYPE,
                          p_first_name EMPLOYEES.first_name%TYPE,
                          p_last_name EMPLOYEES.last_name%TYPE
                        ) IS
     custom_email EMPLOYEES.EMAIL%TYPE;
  BEGIN
    custom_email := UPPER(CONCAT(SUBSTR(p_first_name, 1, 1), SUBSTR(p_last_name, 1, 7)));

    add_employee(p_first_name, p_last_name, p_deptid, custom_email);

    dbms_output.put_line(custom_email);
  END add_employee;


  /*===============================================================+
     PROCEDURE:    get_employee
     DESCRIPTION:  Obtiene un empleado de acuerdo a un identificador
     ARGUMENTS:
                 IN p_emp_id Recibe el identificador del empleado a buscar
                             dentro del procedimiento.

                 OUT p_x_emp_sal Almacena el salario del empleado a buscar.
                     p_x_emp_job_id Almacena el puesto del empleado a buscar.

     RETURNS:      N/A
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación del procedimiento
  +================================================================*/
  PROCEDURE get_employee(
                         p_emp_id IN EMPLOYEES.employee_id%TYPE DEFAULT NULL,
                         p_x_emp_sal OUT EMPLOYEES.salary%TYPE,
                         p_x_emp_job_id OUT EMPLOYEES.job_id%TYPE
                         ) IS
  BEGIN
    IF p_emp_id IS NOT NULL THEN
      SELECT
        job_id, salary INTO p_x_emp_job_id, p_x_emp_sal
        FROM EMPLOYEES
       WHERE employee_id = p_emp_id;

      dbms_output.put_line('Empleado: ' || p_emp_id);
    ELSE
      dbms_output.put_line('No se ha ingresado ningún parámetro');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el ID: ' || p_emp_id);

    WHEN OTHERS THEN
      g_err_num := SQLCODE;
      g_err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error al tratar de recuperar un empleado');
      dbms_output.put_line('Error: ' || g_err_num);
      dbms_output.put_line(g_err_msg);
  END get_employee;


  /*===============================================================+
     FUNCTION:    get_employee
     DESCRIPTION:  Obtiene un empleado según el identificador del empleado.
     ARGUMENTS:
                 IN emp_id Almacena un valor de tipo employee_id de la tabla
                           EMPLOYEES.


                 OUT

     RETURNS:      EMPLOYEES%ROWTYPE
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
  +================================================================*/
  FUNCTION get_employee(p_emp_id IN EMPLOYEES.employee_id%TYPE) RETURN EMPLOYEES%ROWTYPE IS
    retval EMPLOYEES%ROWTYPE;
  BEGIN
     SELECT
         * INTO retval
      FROM EMPLOYEES
      WHERE employee_id = p_emp_id;

    RETURN retval;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el identificador: ' || p_emp_id);
      RETURN NULL;
  END get_employee;


  /*===============================================================+
     FUNCTION:    get_employee
     DESCRIPTION:  Obtiene un empleado según el identificador del empleado.
     ARGUMENTS:
                 IN emp_id Almacena un valor de tipo employee_id de la tabla
                           EMPLOYEES.


                 OUT

     RETURNS:      EMPLOYEES%ROWTYPE
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
  +================================================================*/
  FUNCTION get_employee(p_family_name IN EMPLOYEES.last_name%TYPE) RETURN EMPLOYEES%ROWTYPE IS
    retval EMPLOYEES%ROWTYPE;
  BEGIN
    SELECT
      * INTO retval
      FROM EMPLOYEES
     WHERE last_name = p_family_name;
    RETURN retval;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el nombre de familia: ' || p_family_name);
  END get_employee;


  /*===============================================================+
     FUNCTION:    print_employee
     DESCRIPTION:  Imprime los datos de un empleado.
     ARGUMENTS:
                 IN p_employee Recibe un empleado de tipo EMPLOYEES.

                 OUT

     RETURNS:      VARCHAR2
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
  +================================================================*/
  FUNCTION print_employee(p_employee IN EMPLOYEES%ROWTYPE) RETURN varchar2 IS
  BEGIN
    IF p_employee.employee_id IS NULL THEN
      dbms_output.put_line('El objeto empleado que se ha mandado como parámetro está vacío');
    ELSE
      dbms_output.put_line('--------------------------');
      dbms_output.put_line('El id del departamento es: ' || p_employee.department_id);
      dbms_output.put_line('El id del empleado es: ' || p_employee.employee_id);
      dbms_output.put_line('El primer nombre del empleado es: ' || p_employee.first_name);
      dbms_output.put_line('El apellido del empleado es: ' || p_employee.last_name);
      dbms_output.put_line('El job id del empleado es: ' || p_employee.job_id);
      dbms_output.put_line('El salario del empleado es: ' || p_employee.salary);
    END IF;

    RETURN '';
  END print_employee;


  /*===============================================================+
     FUNCTION:    valid_department
     DESCRIPTION:  Verifica que el departamento exista para poder ingresar un empleado.
     ARGUMENTS:
                 IN p_dept Recibe el número del departamento.
  
                 OUT 
  
     RETURNS:      BOOLEAN
     NOTES:        
  
     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función
  +================================================================*/
  FUNCTION valid_department(p_dept DEPARTMENTS.department_id%TYPE DEFAULT NULL) RETURN BOOLEAN IS
      deptname DEPARTMENTS.department_name%TYPE;
  BEGIN
    -- If no data found throw a exception
    SELECT department_name INTO deptname FROM DEPARTMENTS WHERE department_id = p_dept;
    -- Just send true, because the exception block, works...!
    RETURN TRUE;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('El departamento no existe');
        RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('Hay valores duplicados para este departamento');
        RETURN TRUE;
  END valid_department;


  /*===============================================================+
     PROCEDURE:    init_depts
     DESCRIPTION:  Procedimiento que crea una tabla en el esquema de ORA01
     ARGUMENTS:
                 IN

                 OUT

     RETURNS:      N/A
     NOTES:         Este procedimiento llama a una función después de que crea
                    una tabla para llenarla con datos válidos.

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creacion del procedimiento
  +================================================================*/
  PROCEDURE init_depts IS
     l_count_t NUMBER;
     l_catchval BOOLEAN;
  BEGIN
     SELECT
      COUNT(1) INTO l_count_t
       FROM SYS.USER_ALL_TABLES
      WHERE TABLE_NAME = 'VALID_DEPARTMENTS';

     IF l_count_t = 0
     THEN
       dbms_output.put_line('No hay ninguna tabla llamada: valid_departments');
       dbms_output.put_line('Creando la tabla de nombre: valid_departments');

       g_myquery :=  'CREATE TABLE ORA01.valid_departments
                       (
                          dept_id NUMBER(10) NOT NULL,
                          CONSTRAINT val_departs_pk PRIMARY KEY(dept_id)
                       )';

       EXECUTE IMMEDIATE g_myquery;
     ELSE
       dbms_output.put_line('Ya existe una tabla llamada: valid_departments');
     END IF;

     l_catchval := chk_init_depts;
  END init_depts;

 -- PRIVATE PROCEDURES AND FUNCTIONS

/*===============================================================+
   FUNCTION:    chk_init_depts
   DESCRIPTION: Función que llena la tabla VALID_DEPARTMENTS
   ARGUMENTS:
               IN

               OUT
   RETURNS:      BOOLEAN
   NOTES:        procedimiento de prueba

   HISTORY
   Version     Date         Author                    Change Reference
   1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función
+================================================================*/
FUNCTION chk_init_depts RETURN BOOLEAN IS
BEGIN
   FOR mydept IN (SELECT * FROM DEPARTMENTS) LOOP
      g_myquery := 'INSERT INTO ORA01.VALID_DEPARTMENTS(dept_id) VALUES ('||mydept.department_id||')';
      EXECUTE IMMEDIATE g_myquery;
   END LOOP;

   dbms_output.put_line('Departamentos inicializados.');
   RETURN TRUE;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      g_err_num := SQLCODE;
      g_err_msg := SQLERRM;
      dbms_output.put_line('Se está tratando de ingresar datos duplicados');
      dbms_output.put_line('Error: ' || g_err_num);
      dbms_output.put_line('Mensaje: ' || g_err_msg);
      RETURN FALSE;
    WHEN OTHERS THEN
      g_err_num := SQLCODE;
      g_err_msg := SQLERRM;
      dbms_output.put_line('Ha ocurrido un error inesperado, al tratar de ingresar los datos a la tabla');
      dbms_output.put_line('Error: ' || g_err_num);
      dbms_output.put_line('Mensaje: ' || g_err_msg);
      RETURN FALSE;
END chk_init_depts;

END EMP_PKG;
