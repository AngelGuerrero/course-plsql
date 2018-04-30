CREATE OR REPLACE PROCEDURE CHECK_SALARY(
                                         p_jobid  IN  employees.job_id%type
                                        ,p_salary IN  employees.salary%type
                                        ) IS
   l_rs jobs%rowtype; -- Contains the result set
   
   l_invalid_salary_range EXCEPTION; -- Custom exception
   PRAGMA EXCEPTION_INIT(l_invalid_salary_range, -20001);
   
BEGIN
   SELECT *
     INTO l_rs
     FROM jobs
    WHERE 1 = 1
      AND job_id = p_jobid
        ;
    
   IF p_salary BETWEEN l_rs.min_salary AND l_rs.max_salary
   THEN
      dbms_output.put_line('Puesto: ' || l_rs.job_id || ' está en el rango del salario');
   ELSE
      raise_application_error(-20001, 'INVALID SALARY <'|| p_salary ||'>. salaries for job <'|| p_jobid ||'> must be betweeen <'|| l_rs.min_salary ||'> and <'|| l_rs.max_salary ||'>');
   END IF;
   
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('No existe un registro con el id: '|| p_jobid);
   WHEN l_invalid_salary_range THEN
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
   WHEN OTHERS THEN
      dbms_output.put_line('Ha ocurrido un error en el procedimiento tratando de verificar el salario');
      dbms_output.put_line('Error: ' || SQLCODE);
      dbms_output.put_line('Mensaje: ' || sqlerrm);
END CHECK_SALARY;
