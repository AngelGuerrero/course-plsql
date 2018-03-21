/*=============================================================================+
   Filename: EMPLOYEE_PACKAGE_SPEC.sql
   Component: Package
   Package: EMPLOYEE_PACKAGE
   Designer: Luis Ángel De Santiago Guerrero
   Developer: Luis Ángel De Santiago Guerrero
   Version: 1.0
   Description: Paquete para el manejo de datos en la tabla EMPLOYEES
/*============================================================================*/


/*===================================================================+
    SPECIFICATION PACKAGE
+===================================================================*/

CREATE OR REPLACE PACKAGE EMP_PKG IS

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
                          p_first_name IN EMPLOYEES.first_name%TYPE DEFAULT '',
                          p_last_name IN EMPLOYEES.last_name%TYPE DEFAULT '',
                          p_deptid IN EMPLOYEES.department_id%TYPE DEFAULT 30,
                          p_email IN EMPLOYEES.email%TYPE DEFAULT '',
                          p_job IN EMPLOYEES.job_id%TYPE DEFAULT 'SA_REP',
                          p_mgr IN EMPLOYEES.manager_id%TYPE DEFAULT 145,
                          p_sal IN EMPLOYEES.salary%TYPE DEFAULT 1000,
                          p_commission IN EMPLOYEES.commission_pct%TYPE DEFAULT 0,
                          p_hd IN EMPLOYEES.hire_date%TYPE DEFAULT TRUNC(SYSDATE)
                         );


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
                          p_deptid IN EMPLOYEES.department_id%TYPE,
                          p_first_name IN EMPLOYEES.first_name%TYPE,
                          p_last_name IN EMPLOYEES.last_name%TYPE
                        );


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
                         );


   /*===============================================================+
      FUNCTION:    get_employee
      DESCRIPTION:  Obtiene un empleado según el identificador del empleado.
      ARGUMENTS:
                  IN p_emp_id Almacena un valor de tipo employee_id de la tabla
                            EMPLOYEES.


                  OUT

      RETURNS:      EMPLOYEES%ROWTYPE
      NOTES:

      HISTORY
      Version     Date         Author                    Change Reference
      1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
   +================================================================*/
   FUNCTION get_employee(p_emp_id IN EMPLOYEES.employee_id%TYPE)
      RETURN EMPLOYEES%ROWTYPE;


   /*===============================================================+
      FUNCTION:    get_employee
      DESCRIPTION:  Obtiene el empleado según el apellido de éste.
      ARGUMENTS:
                  IN p_family_name Almacena el apellido del empleado.

                  OUT

      RETURNS:      EMPLOYEES%ROWTYPE
      NOTES:

      HISTORY
      Version     Date         Author                    Change Reference
      1.0         21/03/2018   Ángel Guerrero.           1. Creación de la función.
   +================================================================*/
   FUNCTION get_employee(p_family_name IN EMPLOYEES.last_name%TYPE)
      RETURN EMPLOYEES%ROWTYPE;


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
   FUNCTION print_employee(p_employee IN EMPLOYEES%ROWTYPE)
      RETURN varchar2;


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
   PROCEDURE init_depts;

END EMP_PKG;
