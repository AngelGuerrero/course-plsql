CREATE TABLE MYTEST(test_id NUMBER NOT NULL,
                  test_date DATE,
                  CONSTRAINT test_id_pk PRIMARY KEY(test_id));

SELECT * FROM MYTEST;

DROP TABLE TEST;


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
      dbms_output.put_line('Ha ocurrido un error en la ejecución de administración de jobs');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END;
/

EXECUTE proctest;
 

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
      dbms_output.put_line('Ha ocurrido un error en la ejecución de administración de jobs');
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