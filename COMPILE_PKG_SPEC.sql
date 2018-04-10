CREATE OR REPLACE PACKAGE compile_pkg IS

   PROCEDURE make(p_nameprogram VARCHAR2);
   
   PROCEDURE regenerate(p_nameprogram VARCHAR2);

END compile_pkg;