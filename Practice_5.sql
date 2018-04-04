

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
      dbms_output.put_line('La secuncia no está creada');

      dbms_output.put_line('Creando secuencia.');

      l_sql_stmt := 'CREATE SEQUENCE sim_seq';

     EXECUTE IMMEDIATE l_sql_stmt;
     dbms_output.put_line('Secuecia creada satisfactoriamente.');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en la ejecuci?n de administraci?n de jobs');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/












--1. CREATE a PROCEDURE called EMPLOYEE_REPORT that generates and employee report
--IN a file IN the operating system, using the UTL_FILE package. The report should
--generate a list of employees who have exceded the avarage salary of their
--departments.
--
--   a. Yout program should accept two parameters. The first parameter is the output
--   directory. The second parameter is the name of the text file that is written.
--   Note: Use the directory location value UTL_FILE. Add an exception-handling
--   section to handle errors that my be encountered when using the UTL_FILE
--   package.
--
--   b. Invoke the program, using the second parameter with a name such IS sal_rptxx.txt,
--   where xx represents your user NUMBER (FOR example, 01, 15, and so on).
--
--  Note: The data displays the employee's last name, department ID, and salary.
--  Ask your instrutor to provide instructios on how to obtain the report file
--  from the server using the Putty PSFTP utility.

CREATE OR REPLACE DIRECTORY temp_path IS 'C:\temp';

CREATE OR REPLACE PROCEDURE employee_report(p_dir_name IN VARCHAR2,
                                            p_filename IN VARCHAR2) IS
   l_file utl_file.file_type;
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
      utl_file.putf(l_file, '\n\nReporte generado: ' || TO_CHAR(systimestamp, 'YYYY-MM-DD HH24:MI:SS'));
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
   dbms_output.put_line('C?digo de error: ' || SQLCODE);
   dbms_output.put_line('Mensaje: ' || sqlerrm);
END EMPLOYEE_REPORT;
/

EXECUTE employee_report('temp_path', 'sal_rpt01.txt');

SELECT last_name, salary, department_id FROM employees WHERE department_id = &dept;


-- 2. CREATE a new PROCEDURE called WEB_EMPLOYEE_REPORT that generates the same
-- data IS the EMPLOYEE_REPORT.

--a. First, execute SET SERVEROUTPUT ON, and then execute
--htp.print('helo') followeb by executing OWA_UTIL.SHOWPAGE.
--The exception messages genrated can be ignored.
--
--b. Write the WEB_EMPLOYEE_REPORT PROCEDURE by using the HTP package to generate
--and HTML report of employees with a salary greater that the average FOR their
--departments. If you know HTML, CREATE an HTML table; otherwise, CREATE a simple
--lines of data
--
--Hint: Copit the cursos definition and the FOR LOOP from EMPLOYEE_REPORT PROCEDURE
--FOR the basis struture FOR your web report.
--
--c. Execute the PROCEDURE using iSQLPlus to generate the HTML data into a server
--buffer, and execute the OWA_UTIL.SHOWPAGE PROCEDURE to display contents of the
--buffer. Remember that SERVEROUTPUT should be ON before you execute the code.
--
--d. CREATE an HTML file called web_employee_report.html containing the output
--result text that you select and copy from the opening <HTML> tag to the
--closing </HTML> tag. Paste the copied text into the file and save it to disk.
--Double-click the file to display the results IN your DEFAULT browser.

CREATE OR REPLACE PROCEDURE web_employee_report IS
   l_employee employees%rowtype;
   l_counter NUMBER := 1;
BEGIN
   htp.htmlopen;
   htp.headopen;
   htp.p('<meta charset="UTF-8">');
   htp.title('Reporte de empleados.');
   htp.headclose;
   htp.bodyopen;
   htp.header(1, 'Reporte de empleados.');
   htp.header(3, 'Reporte de empleados que ganan más que el promedio de sus departamentos.');
   htp.p('Reporte generado: ' || sysdate || '<br>');
  
   htp.p('<table style="border: 1px solid; width: 100%; text-align: center;">');
   htp.p('<thead>');
   htp.p('<tr>');
   htp.p('<th>');
   htp.p('Num');
   htp.p('</th>');
   htp.p('<th>');
   htp.p('Empleado');
   htp.p('</th>');
   htp.p('<th>');
   htp.p('Departamento');
   htp.p('</th>');
   htp.p('<th>');
   htp.p('Salario');
   htp.p('</th>');
   htp.p('</tr>');
   htp.p('</thead>');
   htp.p('<tbody>');

   FOR l_employee IN (SELECT *
                        FROM employees e1
                       WHERE salary > (SELECT AVG(salary)
                                         FROM employees e2
                                         WHERE e1.department_id = e2.department_id
                                      GROUP BY department_id)
                    ORDER BY department_id)
   LOOP
     htp.p('<tr>');
    
     htp.p('<td>');
     htp.p(l_counter);
     htp.p('</td>');
     htp.p('<td>');
     htp.p(l_employee.last_name);
     htp.p('</td>');
     htp.p('<td>');
     htp.p(l_employee.department_id);
     htp.p('</td>');
     htp.p('<td>');
     htp.p('$' || l_employee.salary);
     htp.p('</td>');
     
     htp.p('</tr>');
     l_counter := l_counter + 1;
   END LOOP;

   htp.p('</tbody>');
   htp.p('</table>');
   htp.bodyclose;
   htp.htmlclose;

END web_employee_report;
/

/*===============================================================+
   PROCEDURE:    dump_page
   DESCRIPTION:  Crea un archivo para una pï¿½gina web

   ARGUMENTS:
               IN p_dir Nombre del directorio donde se encontrarï¿½ el archivo

               OUT p_fname Nombre del archivo que se generarï¿½

   RETURNS:      N/A
   NOTES:        Obtiene el buffer de una pï¿½gina web creado con OWA_UTIL, y escribe en el archivo especificado.

   HISTORY
   Version     Date         Author                    Change Reference
   1.0         03/Abril/2018   ??ngel Guerrero.           1.0
+================================================================*/
CREATE OR REPLACE PROCEDURE dump_page(p_dir IN VARCHAR2,
                                      p_fname IN VARCHAR2)
IS
  l_page htp.htbuf_arr;
  l_file utl_file.file_type;
  l_lines NUMBER DEFAULT 99999999;
BEGIN

     l_file := utl_file.fopen(upper(p_dir), p_fname, 'w');
     owa.get_page(l_page, l_lines);
     FOR i IN 1 .. l_lines LOOP
        utl_file.put(l_file, l_page(i));
     END LOOP;
     utl_file.fclose(l_file);

END dump_page;
/

DECLARE
nm owa.vc_arr;
vl owa.vc_arr;
begin
   nm(1) := 'SERVER_PORT';
   vl(1) := '80';
   owa.init_cgi_env( 1, nm, vl );
   web_employee_report;
  dump_page('temp_path', 'index.html');
END;
/


-- 3. Your boss wants to run the employee report frequently. You create a procedure
--  that uses the DBMS_SCHEDULER package to shecule the employee_report procedure
--  for execution. You should use parameters to specify a frequency, and an optional
--  argument to specify the number of minutes after which the sheduled job should be
--  terminated.

-- a - Create a procedure called SCHEDULER_REPORT that provides the following two
--   parameters:
--   internal: To specify a string indicating the frequency of the sheduled job
--   minutes: To specify the total life in minutes (default of 10) for the
--   sheduled job, after which it is terminated. The code divides the duration by
--   the quantity(24 X 50) when it is added to the current date and time to specify
--   the termination time.

-- When the procedure creates a job, with the name of EMPSAL_REPORT by calling
-- dbms_shceduler.create_job, the job should be enabled and scheduled for the PL/SQL
-- block to start immediately. Yu must schedule an anonmous block to invoke the
-- EMPLOYEE_REPORT procedure so that the file name can be updated with a new time,
-- each time thte report is executed. The EMPLOYEE_REPORT is given the directory name
-- supplied by your instructor for task 1, and the file name parameter is specified
-- in the following format:
-- sasl_rptxx_hh24-mi-ss.txt, where xx is your assigned user number and hh24-mi-ss
-- represents the hours, minutes, and seconds.

--Use the following local PLSQL variable to construct a PLSQL block:
plsql_block VARCHAR2(200) :=
   'BEGIN' || 
   ' EMPLOYEE_REPORT(''UTL_FILE'','||
   '''sal_rptXX''||to_char(sysdate, ''HH24-MI-SS'') || ''.txt'');'||
   'END;';
-- This code is provided help you because it is a nontrivial PLSQL string to 
-- construct. In the PLSQL block, XX is your student number.

-- b. Test the SCHEDULER_REPORT procedure by executing it with a parameter
-- specifying a frequency of every two minutes and termination time 100 minutes
-- after it starts.
-- Note: You must connect to the database server by using PSFTP to check whether
-- your filed are created.

-- c. During and after the process, you can query the job_name and enabled columns
-- from the USER_SCHEDULER_JOBS table to check whether the job still exists.
-- Note: This query should return no rows after 10 minutes have elapsed.

CREATE OR REPLACE
FUNCTION create_job(
                    p_job_name   IN VARCHAR2,
                    p_job_type   IN VARCHAR2,
                    p_job_action IN VARCHAR2,
                    p_internal   IN VARCHAR2,
                    p_freq       IN VARCHAR2
                    ) RETURN BOOLEAN IS
BEGIN

       dbms_output.put_line('Creando el job de nombre: ' || p_job_name || '...');
       dbms_scheduler.create_job(
                                  job_name => p_job_name,
                                  job_type => p_job_type,
                                  job_action => p_job_action,
                                  start_date => SYSTIMESTAMP,
                                  repeat_interval => 'FREQ='||p_freq||';INTERVAL='||p_internal,
                                  enabled => TRUE);

      dbms_output.put_line('Job creado correctamente.');
      dbms_output.put_line('job name: ' || p_job_name);
      dbms_output.put_line('job type: ' || p_job_type);
      dbms_output.put_line('job action: ' || p_job_action);
      dbms_output.put_line('job freq: ' || p_freq);
      dbms_output.put_line('job internal: ' || p_internal);

      RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error tratando de crear el job: ' || p_job_name);
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/

CREATE OR REPLACE PROCEDURE ADMIN_JOBS(p_job_name   IN VARCHAR2,
                                       p_job_type   IN VARCHAR2,
                                       p_job_action IN VARCHAR2,
                                       p_internal   IN VARCHAR2,
                                       p_freq       IN VARCHAR2) IS
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
       admin_jobs(p_job_name, p_job_type, p_job_action, p_internal, p_freq);
    ELSE
      dbms_output.put_line('El JOB con el nombre: ' || p_job_name || ' no existe.');

      l_catchval := create_job(p_job_name, p_job_type, p_job_action, p_internal, p_freq);

      dbms_output.put_line('Ejecuntando el JOB : ' || p_job_name ||  '.');

      dbms_scheduler.run_job(p_job_name);

    END IF;
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en la ejecución de administración de jobs');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/

CREATE OR REPLACE PROCEDURE emp_rep_file
IS
   l_d VARCHAR2(100);
BEGIN
   l_d := to_char(SYSTIMESTAMP, 'HH24-MI-SS');
   l_d := l_d || '-report.txt';
   
   employee_report('temp_path', l_d); 
END;
/

CREATE OR REPLACE PROCEDURE schedule_report(p_minut VARCHAR2 DEFAULT 'MINUTELY', p_inter VARCHAR2 DEFAULT '10')
IS
   l_plsql_block VARCHAR2(200) :=
   'BEGIN employee_report(''temp_path'', ''' || TO_CHAR(systimestamp, 'HH24-MI-SS') || '-report.txt''); END;';
BEGIN
   dbms_output.put_line('Bloque: ' || l_plsql_block);
   
   dbms_scheduler.create_job(job_name => 'job_file_report',
                             job_type => 'STORED_PROCEDURE',
                             job_action => 'emp_rep_file',
                             start_date => SYSTIMESTAMP,
                             repeat_interval => 'FREQ='||p_minut||';INTERVAL='||p_inter,
                             enabled => TRUE);
                             
END schedule_report;
/

-- EXECUTE ADMIN_JOBS('myjob', 'STORED_PROCEDURE', 'proctest');

EXECUTE schedule_report(p_inter => '1');

BEGIN dbms_scheduler.drop_job('job_file_report'); END;
