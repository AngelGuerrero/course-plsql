CREATE OR REPLACE PACKAGE compile_pkg IS

   -- Global variables
   g_dir VARCHAR2(100) := 'UTL_FILE';
   
   PROCEDURE make(p_nameprogram VARCHAR2);
   
   PROCEDURE regenerate(p_nameprogram VARCHAR2);

END compile_pkg;