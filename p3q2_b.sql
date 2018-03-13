-- Body package
CREATE OR REPLACE PACKAGE BODY JOB_PKG AS
  err_num NUMBER;
  err_msg VARCHAR2(255);
    
    -- Procedure ADD_JOB
  PROCEDURE ADD_JOB(
                    p_job_id  JOBS.JOB_ID%TYPE,
                    p_job_title JOBS.JOB_TITLE%TYPE,
                    p_job_min_salary JOBS.MIN_SALARY%TYPE DEFAULT 0,
                    p_job_max_salary JOBS.MAX_SALARY%TYPE DEFAULT 0
                    )
  IS BEGIN    
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
  
  
  
  --- Procedure UPD_JOB ---
  PROCEDURE UPD_JOB(
                    p_job_id JOBS.JOB_ID%TYPE, 
                    p_job_title JOBS.JOB_TITLE%TYPE,
                    p_job_min_sal JOBS.MIN_SALARY%TYPE,
                    p_job_max_sal JOBS.MAX_SALARY%TYPE) 
  IS
    re_q JOBS.JOB_ID%TYPE;
  BEGIN
    -- Check if the p_job_id exists if not, throws an exception
    SELECT job_id INTO re_q FROM JOBS WHERE JOB_ID = p_job_id;
    
    UPDATE JOBS
    SET 
      JOB_TITLE = p_job_title,
      MIN_SALARY = p_job_min_sal,
      MAX_SALARY = p_job_max_sal
    WHERE JOB_ID = p_job_id;
    COMMIT;
    
    -- if all runs ok, show a message of success
    dbms_output.put_line('El empledo se ha actualizado correctamente.');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el ID: ' || p_job_id);
  
  END UPD_JOB;
  
  
  
  --- Procedure DEL_JOB ---
  PROCEDURE DEL_JOB(p_job_id in JOBS.job_id%TYPE) IS
    ret_job JOBS.job_id%TYPE;
  BEGIN
    -- find the job id
    SELECT job_id INTO ret_job FROM JOBS WHERE job_id = p_job_id;

    -- Delete the row
    DELETE FROM JOBS WHERE job_id = p_job_id;
    COMMIT;

    dbms_output.put_line('Se ha eliminado el registro con id: ' || p_job_id || ' correctamente.');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el Id: ' || p_job_id);
  END DEL_JOB;
  
  
  
  --- Get job function ---
  FUNCTION GET_JOB(j_id JOBS.job_id%TYPE) RETURN JOBS.job_title%TYPE IS
  retval JOBS.job_title%TYPE;
  BEGIN
  
    SELECT job_title INTO retval FROM JOBS WHERE job_id = j_id;
    RETURN retval;
    
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No se han encontrado registros con el Id: ' || j_id);
      RETURN '';
  END GET_JOB;
  
  
END JOB_PKG;
/