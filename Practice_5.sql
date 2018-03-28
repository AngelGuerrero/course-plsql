CREATE OR REPLACE FUNCTION create_job(p_job_name IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
       
       dbms_output.put_line('Creando el job de nombre: ' || p_job_name || '...');
       dbms_scheduler.create_job(
                                  job_name => p_job_name,
                                  job_type => 'STORED_PROCEDURE',
                                  job_action => 'HELLO',
                                  start_date => SYSTIMESTAMP,
                                  repeat_interval => 'FREQ=SECONDLY',
                                  enabled => TRUE);
      dbms_output.put_line('Procedimiento creado correctamente.');
      
      RETURN TRUE;
END;
/


CREATE OR REPLACE PROCEDURE ADMIN_JOBS IS
   l_job_exists NUMBER;
   l_job_name VARCHAR2(200) := 'myjob';
   l_catchval BOOLEAN;
BEGIN
   SELECT COUNT(1) INTO l_job_exists
     FROM user_scheduler_jobs
    WHERE job_name = UPPER(l_job_name);
    
    IF l_job_exists = 1
    THEN
       dbms_output.put_line('Eliminando el JOB: ' || l_job_name);
       dbms_scheduler.drop_job(l_job_name);
      admin_jobs;
    ELSE
      dbms_output.put_line('El JOB con el nombre: ' || l_job_name || ' no existe.');
      
      l_catchval := create_job(l_job_name);
      dbms_output.put_line('Ejecuntando el JOB = ' || l_job_name ||  '.');
      dbms_scheduler.run_job(l_job_name);
      
    END IF;
    
EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en la ejecución de administración de jobs');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/


EXECUTE ADMIN_JOBS;

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

CREATE OR REPLACE DIRECTORY my_test_path AS '/home/oracle/Desktop/';

CREATE OR REPLACE PROCEDURE test_file IS
   l_file UTL_FILE.FILE_TYPE;
   l_employee EMPLOYEES%ROWTYPE;
   BEGIN      
      IF NOT UTL_FILE.IS_OPEN(l_file)
      THEN
         l_file := UTL_FILE.FOPEN('/home/oracle/Desktop/', 'test.txt', 'W');
         utl_file.put_line(l_file, 'Texto de prueba');
      ELSE
         dbms_output.put_line('No se puede escribir en el archivo ahora mismo');
      END IF;
  
  EXCEPTION
     WHEN OTHERS THEN
        dbms_output.put_line('Ha ocurrido un error en el procedimiento.');
        dbms_output.put_line('Error: ' || SQLCODE);
        dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/

EXECUTE test_file;