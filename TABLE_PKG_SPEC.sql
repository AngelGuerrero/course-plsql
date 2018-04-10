CREATE OR REPLACE PACKAGE TABLE_PKG IS
   
   PROCEDURE make_table(p_tablename VARCHAR2, p_options VARCHAR2, p_override BOOLEAN DEFAULT FALSE);
   
   PROCEDURE del_table(p_tablename VARCHAR2);
   
   PROCEDURE add_row(p_tablename VARCHAR2, p_values VARCHAR2);
   
   PROCEDURE upd_row(p_tablename VARCHAR2, p_cond VARCHAR2, p_assoc_val VARCHAR2);
   
   PROCEDURE del_row(p_tablename VARCHAR2, p_column VARCHAR2, p_val VARCHAR2);
   
   FUNCTION t_exists(p_tablename VARCHAR2) RETURN BOOLEAN;
   
   FUNCTION row_exists(p_tablename VARCHAR2, p_column VARCHAR2, p_val VARCHAR2) RETURN BOOLEAN;
   
END;
