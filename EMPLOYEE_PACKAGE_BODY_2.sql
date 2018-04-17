create or replace PACKAGE BODY EMP_PKG IS

   -- DECLARE GLOBAL VARIABLES
   g_myquery VARCHAR2(32767);

   -- DECLARE PRIVATE FUNCTIONS AND VARIABLES
   FUNCTION chk_init_depts RETURN BOOLEAN;

   l_emp_table g_emp_type;
   

   FUNCTION valid_department(p_dept departments.department_id%TYPE DEFAULT NULL) RETURN BOOLEAN;
   
   PROCEDURE audit_newemp(p_empname employees.first_name%type);
   
   ---------------------------------------------------------------------------------------------
   
   PROCEDURE audit_newemp(p_empname employees.first_name%type) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_user VARCHAR2(100);
   BEGIN
      SELECT USER
        INTO l_user
        FROM dual;
        
      INSERT INTO log_newemp 
      VALUES (log_new_emp_seq.NEXTVAL, l_user, SYSTIMESTAMP, p_empname);
      COMMIT;
      
      dbms_output.put_line('Registro de log actualizado correctamente');
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error al insertar un registro en log_newemp');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
   END audit_newemp;

   /*===============================================================+
   PROCEDURE:    add_employee
   DESCRIPTION:  Agrega un empleado en la tabla employees con argumentos por defecto
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
                           p_first_name employees.first_name%TYPE DEFAULT '',
                           p_last_name employees.last_name%TYPE DEFAULT '',
                           p_deptid employees.department_id%TYPE DEFAULT 30,
                           p_email employees.email%TYPE DEFAULT '',
                           p_job employees.job_id%TYPE DEFAULT 'SA_REP',
                           p_mgr employees.manager_id%TYPE DEFAULT 145,
                           p_sal employees.salary%TYPE DEFAULT 1000,
                           p_commission employees.commission_pct%TYPE DEFAULT 0,
                           p_hd employees.hire_date%TYPE DEFAULT TRUNC(SYSDATE)
                           ) IS
   -- Variables
   l_employees_seq employees.employee_id%TYPE;
   BEGIN
      IF valid_department(p_deptid) THEN
         SELECT MAX(employee_id) + 1 INTO l_employees_seq
           FROM employees;
          
         -- Inserta un nuevo registro en el log de la tabla de empleados
         audit_newemp(p_first_name);
         
         INSERT INTO employees (
            employee_id,
            first_name,
            last_name,
            email,
            job_id,
            manager_id,
            salary,
            commission_pct,
            hire_date,
            department_id
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
         dbms_output.put_line('El registro que se intenta agregar, ya está en la base de datos');
         dbms_output.put_line('Código de error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
       WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de ingresar el registro.');
         dbms_output.put_line('Código de error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
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
                          p_deptid employees.department_id%TYPE,
                          p_first_name employees.first_name%TYPE,
                          p_last_name employees.last_name%TYPE
                        ) IS
      custom_email employees.email%TYPE;
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

                 OUT x_emp_sal Almacena el salario del empleado a buscar.
                     x_emp_job_id Almacena el puesto del empleado a buscar.

     RETURNS:      N/A
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación del procedimiento
   +================================================================*/
   PROCEDURE get_employee(
                         p_emp_id IN employees.employee_id%TYPE DEFAULT NULL,
                         x_emp_sal OUT employees.salary%TYPE,
                         x_emp_job_id OUT employees.job_id%TYPE
                         ) IS
   BEGIN
      IF p_emp_id IS NOT NULL
      THEN
         SELECT job_id, salary INTO x_emp_job_id, x_emp_sal
           FROM employees
          WHERE employee_id = p_emp_id;

         dbms_output.put_line('Empleado: ' || p_emp_id);
      ELSE
         dbms_output.put_line('No se ha ingresado ningún parámetro');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No se han encontrado registros con el ID: ' || p_emp_id);

      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de recuperar un empleado');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line(sqlerrm);
   END get_employee;


   /*===============================================================+
     FUNCTION:    get_employee
     DESCRIPTION:  Obtiene un empleado según el identificador del empleado.
     ARGUMENTS:
                 IN emp_id Almacena un valor de tipo employee_id de la tabla
                           employees.


                 OUT

     RETURNS:      employees%ROWTYPE
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
   +================================================================*/
   FUNCTION get_employee(p_emp_id IN employees.employee_id%TYPE) RETURN employees%ROWTYPE IS
      l_retval employees%ROWTYPE;
   BEGIN
     SELECT * INTO l_retval
       FROM employees
      WHERE employee_id = p_emp_id;

      RETURN l_retval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No se han encontrado registros con el identificador: ' || p_emp_id);
         RETURN NULL;
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de obtener al usuario: ' || p_emp_id);
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
   END get_employee;


   /*===============================================================+
     FUNCTION:    get_employee
     DESCRIPTION:  Obtiene un empleado según el identificador del empleado.
     ARGUMENTS:
                 IN emp_id Almacena un valor de tipo employee_id de la tabla
                           employees.


                 OUT

     RETURNS:      Devuelve employees%ROWTYPE si ha encontrado el registro en la
                   tabla.

                   En caso de una exception o de no encontrar el registro solicitado
                   por medio de los parámetros devolverá un valor nulo.
     NOTES:

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
   +================================================================*/
   FUNCTION get_employee(p_family_name IN employees.last_name%TYPE) RETURN employees%ROWTYPE IS
      l_retval employees%ROWTYPE;
   BEGIN
      IF p_family_name IS NOT NULL
      THEN
         dbms_output.put_line('Buscando con el nombre de familia: ' || p_family_name || '...');
         SELECT * INTO l_retval
           FROM employees
          WHERE last_name = p_family_name;
         dbms_output.put_line('ok');
      ELSE
         dbms_output.put_line('No se ha ingresado nungún valor para el nombre de familia del empleado.');
         l_retval := NULL;
      END IF;

      RETURN l_retval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No se han encontrado registros con el nombre de familia: ' || p_family_name);
         RETURN NULL;
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de obtener al usuario con el apellido: ' || p_family_name);
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
         RETURN NULL;
   END get_employee;


   /*===============================================================+
     FUNCTION:    print_employee
     DESCRIPTION:  Imprime los datos de un empleado.
     ARGUMENTS:
                 IN p_employee Recibe un empleado de tipo employees.

                 OUT

     RETURNS:      VARCHAR2
     NOTES: Devuelve VARCHAR2 porque aunque no se necesita que devuelva nada,
            el problema especifica que se tiene que hacer una función y toda
            función debe devolver un valor, mas sin embargo este es una cadena
            "vacía".

     HISTORY
     Version     Date         Author                    Change Reference
     1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
   +================================================================*/
   FUNCTION print_employee(p_employee IN employees%ROWTYPE) RETURN VARCHAR2 IS
      l_employee_null EXCEPTION;
   BEGIN
      IF p_employee.employee_id IS NULL THEN
         RAISE l_employee_null;
      ELSE
         dbms_output.put_line('--------------------------');
         dbms_output.put_line('El id del departamento es: ' || p_employee.department_id);
         dbms_output.put_line('El id del empleado es: ' || p_employee.employee_id);
         dbms_output.put_line('El primer nombre del empleado es: ' || p_employee.first_name);
         dbms_output.put_line('El apellido del empleado es: ' || p_employee.last_name);
         dbms_output.put_line('El job id del empleado es: ' || p_employee.job_id);
         dbms_output.put_line('El salario del empleado es: ' || p_employee.salary);
      END IF;

      RETURN 'ok';
   EXCEPTION
      WHEN l_employee_null THEN
         dbms_output.put_line('Error: El objeto empleado que se ha mandado como parámetro está vacío.');
         RETURN 'fail';
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de imprimir al empleado con identificador: ' || p_employee.employee_id);
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
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
   FUNCTION valid_department(p_dept departments.department_id%TYPE DEFAULT NULL) RETURN BOOLEAN IS
      deptname departments.department_name%TYPE;
   BEGIN
    -- If no data found throw a exception
      SELECT department_name INTO deptname
        FROM departments
       WHERE department_id = p_dept;

      -- Just send true, because the exception block, works...!
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('El departamento no existe');
         RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN
         dbms_output.put_line('Hay valores duplicados para este departamento');
         RETURN TRUE;
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de validar el departamento.');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
         RETURN FALSE;
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
      SELECT COUNT(1) INTO l_count_t
        FROM SYS.USER_ALL_TABLES
       WHERE TABLE_NAME = UPPER('valid_departments');

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
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de inicializar los departamentos válidos.');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
   END init_depts;

   -- PRIVATE PROCEDURES AND FUNCTIONS

   /*===============================================================+
   FUNCTION:    chk_init_depts
   DESCRIPTION: Función que llena la tabla VALID_departments
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
      FOR mydept IN (SELECT * FROM departments) LOOP
         g_myquery := 'INSERT INTO ORA01.VALID_departments(dept_id) VALUES ('||mydept.department_id||')';
         EXECUTE IMMEDIATE g_myquery;
      END LOOP;

      dbms_output.put_line('Departamentos inicializados.');
      RETURN TRUE;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         dbms_output.put_line('Se está tratando de ingresar datos duplicados');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
         RETURN FALSE;
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error inesperado, al tratar de ingresar los datos a la tabla');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
         RETURN FALSE;
   END chk_init_depts;

   PROCEDURE get_employees(p_dept_id employees.department_id%type) IS
   BEGIN
      SELECT *
        BULK COLLECT INTO l_emp_table
        FROM employees
       WHERE department_id = p_dept_id;
       
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No se ha encontrado datos en la tabla de empleados con el parámentro: ' || p_dept_id);
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje de error: ' || sqlerrm);
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de obtener los datos con bulk');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje de error: ' || sqlerrm);
   END get_employees;
   
   PROCEDURE show_employees IS
   BEGIN
      IF l_emp_table.FIRST IS NULL
      THEN
         dbms_output.put_line('nulo');
      ELSE 
         FOR i IN 1.. l_emp_table.LAST
         LOOP
            dbms_output.put_line('Nombre: ' || l_emp_table(i).first_name || ' departamento: ' || l_emp_table(i).department_id);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error al tratar de mostrar los datos de los empleados');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje de error: ' || sqlerrm);
   END show_employees;

   END EMP_PKG;
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
