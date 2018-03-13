-- Specification package

CREATE OR REPLACE PACKAGE JOB_PKG IS

  PROCEDURE ADD_JOB(
                    p_job_id  JOBS.JOB_ID%TYPE,
                    p_job_title JOBS.JOB_TITLE%TYPE,
                    p_job_min_salary JOBS.MIN_SALARY%TYPE DEFAULT 0,
                    p_job_max_salary JOBS.MAX_SALARY%TYPE DEFAULT 0
                    );
    
  PROCEDURE UPD_JOB(
                    p_job_id JOBS.JOB_ID%TYPE, 
                    p_job_title JOBS.JOB_TITLE%TYPE,
                    p_job_min_sal JOBS.MIN_SALARY%TYPE,
                    p_job_max_sal JOBS.MAX_SALARY%TYPE
                    );
  
  PROCEDURE DEL_JOB(p_job_id JOBS.JOB_ID%TYPE);

  FUNCTION GET_JOB(j_id JOBS.job_id%TYPE) RETURN JOBS.job_title%TYPE;
      
END JOB_PKG;
/