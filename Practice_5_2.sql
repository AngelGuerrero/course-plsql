-- Crear la tabla de prueba
CREATE TABLE MYTEST(test_id NUMBER NOT NULL,
                  test_date DATE,
                  CONSTRAINT test_id_pk PRIMARY KEY(test_id));


CREATE OR REPLACE PROCEDURE proctest IS
   l_count_seq NUMBER;
   l_sql_stmt VARCHAR2(200);
BEGIN
   -- Verifica si la secuencia existe
   l_sql_stmt := 'SELECT COUNT(*)
                    FROM user_sequences
                   WHERE sequence_name = :seqname';

   EXECUTE IMMEDIATE l_sql_stmt INTO l_count_seq USING 'SIM_SEQ';

   -- Si la secuencia existe
   IF l_count_seq = 1
   THEN
      l_sql_stmt := 'INSERT INTO MYTEST VALUES (SIM_SEQ.NEXTVAL, SYSTIMESTAMP)';

      EXECUTE IMMEDIATE l_sql_stmt;

      dbms_output.put_line('Dato ingresado en la tabla correctamente');
   ELSE
      dbms_output.put_line('La secuncia no est谩 creada');

      dbms_output.put_line('Creando secuencia.');

      l_sql_stmt := 'CREATE SEQUENCE sim_seq';

     EXECUTE IMMEDIATE l_sql_stmt;
     dbms_output.put_line('Secuecia creada satisfactoriamente.');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en la ejecuci贸n de administraci贸n de jobs');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/


CREATE OR REPLACE
FUNCTION create_job(
                    p_job_name IN VARCHAR2,
                    p_job_type IN VARCHAR2,
                    p_job_action IN VARCHAR2
                    ) RETURN BOOLEAN IS
BEGIN

       dbms_output.put_line('Creando el job de nombre: ' || p_job_name || '...');
       dbms_scheduler.create_job(
                                  job_name => p_job_name,
                                  job_type => p_job_type,
                                  job_action => p_job_action,
                                  start_date => SYSTIMESTAMP,
                                  repeat_interval => 'FREQ=SECONDLY;INTERVAL=5',
                                  enabled => TRUE);

      dbms_output.put_line('Job creado correctamente.');
      dbms_output.put_line('job name: ' || p_job_name);
      dbms_output.put_line('job type: ' || p_job_type);
      dbms_output.put_line('job action: ' || p_job_action);

      RETURN TRUE;
END;
/


CREATE OR REPLACE PROCEDURE ADMIN_JOBS(
                                        p_job_name IN VARCHAR2,
                                        p_job_type IN VARCHAR2,
                                        p_job_action IN VARCHAR) IS
   l_job_exists NUMBER;
   l_catchval BOOLEAN;
BEGIN
   SELECT COUNT(1) INTO l_job_exists
     FROM user_scheduler_jobs
    WHERE job_name = UPPER(p_job_name);

    IF l_job_exists = 1
    THEN
       dbms_output.put_line('Eliminando el JOB: ' || p_job_name);
       dbms_scheduler.drop_job(p_job_name);
       admin_jobs(p_job_name, p_job_type, p_job_action);
    ELSE
      dbms_output.put_line('El JOB con el nombre: ' || p_job_name || ' no existe.');

      l_catchval := create_job(p_job_name, p_job_type, p_job_action);

      dbms_output.put_line('Ejecuntando el JOB = ' || p_job_name ||  '.');

      dbms_scheduler.run_job(p_job_name);

    END IF;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en la ejecuci贸n de administraci贸n de jobs');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/


EXECUTE ADMIN_JOBS('myjob', 'STORED_PROCEDURE', 'proctest');

SELECT * FROM MYTEST;

SELECT * FROM user_scheduler_jobs;




--1. Create a procedure called EMPLOYEE_REPORT that generates and employee report
--in a file in the operating system, using the UTL_FILE package. The report should
--generate a list of employees who have exceded the avarage salary of their
--departments.
--
--   a. Yout program should accept two parameters. The first parameter is the output
--   directory. The second parameter is the name of the text file that is written.
--   Note: Use the directory location value UTL_FILE. Add an exception-handling
--   section to handle errors that my be encountered when using the UTL_FILE
--   package.
--
--   b. Invoke the program, using the second parameter with a name such as sal_rptxx.txt,
--   where xx represents your user number (for example, 01, 15, and so on).
--
--  Note: The data displays the employee's last name, department ID, and salary.
--  Ask your instrutor to provide instructios on how to obtain the report file
--  from the server using the Putty PSFTP utility.

CREATE OR REPLACE DIRECTORY temp_path AS 'C:\temp';

CREATE OR REPLACE PROCEDURE employee_report(p_dir_name IN VARCHAR2, 
                                            p_filename IN VARCHAR2) IS
   l_file UTL_FILE.FILE_TYPE;
   l_catchval BOOLEAN;
   l_employee employees%rowtype;
BEGIN
   l_catchval := utl_file.is_open(l_file);
   IF l_catchval
   THEN
      dbms_output.put_line('No se puede escribir en el archivo en este momento.');
   ELSE
      dbms_output.put_line('Generando reporte de empleados que han excedido el salario de sus departamentos...');
      l_file := utl_file.fopen(upper(p_dir_name), p_filename, 'w');
      utl_file.put(l_file, '**Reporte de empleados que han excedido el salario de sus departamentos.**');
      utl_file.putf(l_file, '\n\nReporte generado: ' || SYSDATE);
      utl_file.putf(l_file, '\n\nLast name ' || CHR(9) || 'Department' || CHR(9) || 'Salary\n');
      
      FOR j IN 1..50 LOOP
         utl_file.putf(l_file, '-');
      END LOOP;
      
      FOR l_employee IN (SELECT *
                           FROM employees e1
                          WHERE salary > (SELECT AVG(salary)
                                            FROM employees e2
                                           WHERE e1.department_id = e2.department_id
                                        GROUP BY department_id)
                       ORDER BY department_id) LOOP
                       
         utl_file.putf(l_file, '\n' || l_employee.last_name);
         IF LENGTH(l_employee.last_name) >= 8
         THEN
            utl_file.putf(l_file, CHR(9));
         ELSE 
            utl_file.putf(l_file, CHR(9) || CHR(9)); 
         END IF;
         
         utl_file.putf(l_file, l_employee.department_id || CHR(9) || CHR(9) || '$' || ROUND(l_employee.salary,2));
         
      END LOOP;
      dbms_output.put_line('Reporte generado correctamente.');
      utl_file.fclose(l_file);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   dbms_output.put_line('Ha ocurrido un error al tratar de generar el reportee solicitado.');
   dbms_output.put_line('C骴igo de error: ' || SQLCODE);
   dbms_output.put_line('Mensaje: ' || sqlerrm);
END EMPLOYEE_REPORT;
/

EXECUTE employee_report('temp_path', 'sal_rpt01.txt');

SELECT last_name, salary, department_id FROM employees WHERE department_id = &dept;


-- 2. Create a new procedure called WEB_EMPLOYEE_REPORT that generates the same
-- data as the EMPLOYEE_REPORT.

--a. First, execute ESET SERVEROUTPUT ON, and then execute
--htp.print('helo') followeb by executing OWA_UTIL.SHOWPAGE.
--The exception messages genrated can be ignored.
--
--b. Write the WEB_EMPLOYEE_REPORT procedure by using the HTP package to generate
--and HTML report of employees with a salary greater that the average for their
--departments. If you know HTML, create an HTML table; otherwise, create a simple
--lines of data
--
--Hint: Copit the cursos definition and the FOR loop from EMPLOYEE_REPORT procedure
--for the basis struture for your web report.
--
--c. Execute the procedure using iSQLPlus to generate the HTML data into a server
--buffer, and execute the OWA_UTIL.SHOWPAGE procedure to display contents of the
--buffer. Remember that SERVEROUTPUT should be ON before yyou execute the code.
--
--d. Create an HTML file called web_employee_report.html containing the output
--result text that you select and copy from the opening <HTML> tag to the
--closing </HTML> tag. Paste the copied text into the file and save it to disk.
--Double-click the file to display the results in your default browser.


