-- Practice 3

-- Crate a packages specification and body, called JOB__PKG, containing a copy of your
-- ADD_JOB, UPD_JOB_ and DEL_JOB procedures as well as your GET_JOB function.

-- Tip. Consider saving the package specification and body in two separate files
-- (for example, p3q2_s.sql and p3q1_b.sql) for the package specification and body,
-- respectively). Include a SHOW ERRORS after the CREATE PACKAGE statement in each file.

-- Note: User the code in your previously saved script files when creating the package.

-- a. Create the package specification including the procedures and function headings
-- as public constructs.
-- Note: Consider wheather you still need the stand-alone procedures and functions
-- you just packaged.

-- b. Create the package body with the imlementations for each of the subprograms.

-- c. Invoke your ADD_JOB package procedure by passing the values IT_SYSAN and
-- SYSTEMS_ANALYST as parameters.

-- d. Query the JOBS table to see the result


-- Specification package

CREATE OR REPLACE PACKAGE JOB_PKG IS

     PROCEDURE ADD_JOB(
                      p_job_id  JOBS.JOB_ID%TYPE,
                      p_job_title JOBS.JOB_TITLE%TYPE,
                      p_job_min_salary JOBS.MIN_SALARY%TYPE,
                      p_job_max_salary JOBS.MAX_SALARY%TYPE
                      );
     -- 
     --  PROCEDURE UPD_JOB();
     -- 
     --  PROCEDURE DEL_JOB();

      FUNCTION GET_JOB(j_id JOBS.job_id%TYPE) RETURN JOBS.job_title%TYPE;
      
END JOB_PKG;
/


DESCRIBE JOBS;

-- Body package BODY
CREATE OR REPLACE PACKAGE BODY JOB_PKG AS
    err_num NUMBER;
    err_msg VARCHAR2(255);
    
    -- Procedure ADD_JOB
    PROCEDURE ADD_JOB(
                      p_job_id  JOBS.JOB_ID%TYPE,
                      p_job_title JOBS.JOB_TITLE%TYPE,
                      p_job_min_salary JOBS.MIN_SALARY%TYPE,
                      p_job_max_salary JOBS.MAX_SALARY%TYPE
                      )
    IS BEGIN
      dbms_output.put_line('Agregando un empleo...');
      
      INSERT INTO JOBS(
                        JOB_ID,
                        JOB_TITLE,
                        MIN_SALARY,
                        MAX_SALARY
                      )
                  VALUES(
                        p_job_id,
                        p_job_title,
                        p_job_min_salary,
                        p_job_max_salary);
      COMMIT;              
      dbms_output.put_line('--------------------------');
      dbms_output.put_line('Registro agregado.');
      dbms_output.put_line('Id: ' || p_job_id);
      dbms_output.put_line('Title: ' || p_job_title);
      dbms_output.put_line('Min salary: ' || p_job_min_salary);
      dbms_output.put_line('Max salary: ' || p_job_max_salary);
      
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          err_num := SQLCODE;
          err_msg := SQLERRM;
          dbms_output.put_line('El regitro que se intenta agregar ya está en la base de datos');
          dbms_output.put_line('Código de error: ' || err_num);
          dbms_output.put_line('Mensaje: ' || err_msg);
        WHEN OTHERS THEN
          err_num := SQLCODE;
          err_msg := SQLERRM;
          dbms_output.put_line('Ha ocurrido un error al tratar de ingresar el registro.');
          dbms_output.put_line('Código de error: ' || err_num);
          dbms_output.put_line('Mensaje: ' || err_msg);
    END ADD_JOB;
                      
  
  -- Get job function
  FUNCTION GET_JOB(j_id JOBS.job_id%TYPE)
  RETURN JOBS.job_title%TYPE IS
  
  retval JOBS.job_title%TYPE;
  
  BEGIN
    SELECT job_title INTO retval FROM JOBS WHERE job_id = j_id;

    RETURN retval;
  END GET_JOB;
  
END JOB_PKG;
/



EXECUTE DBMS_OUTPUT.PUT_LINE(JOB_PKG.GET_JOB('AD_PRES'));

EXECUTE JOB_PKG.ADD_JOB('Desarrollador web', 16000, 25000);

SELECT * FROM JOBS;