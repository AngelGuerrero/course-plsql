CREATE OR REPLACE PACKAGE BODY compile_pkg IS
   
   FUNCTION get_type(p_obname VARCHAR2) RETURN VARCHAR2;
   
   
   PROCEDURE make(p_nameprogram VARCHAR2) IS
      l_catchval VARCHAR2(200) := '';
      l_stmt VARCHAR2(200);
   BEGIN
      dbms_output.put_line('Inicio del paquete de make...');
      l_catchval := get_type(p_nameprogram);
      
      IF l_catchval IS NULL
      THEN
         dbms_output.put_line('No ha devuelto un valor');
      ELSE
         dbms_output.put_line('Compilando el objeto...');
            
         CASE l_catchval
            WHEN 'PACKAGE'   THEN l_stmt := 'ALTER '||l_catchval||' '||p_nameprogram||' COMPILE PACKAGE';
            WHEN 'PROCEDURE' THEN l_stmt := 'ALTER '||l_catchval||' '||p_nameprogram||' COMPILE';
         END CASE;
        
         dbms_output.put_line(l_stmt);
         EXECUTE IMMEDIATE l_stmt;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error en el procedimiento');
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
   END make;
   
   
   FUNCTION get_type(p_obname VARCHAR2) RETURN VARCHAR2 IS
      l_object all_objects.object_type%type := NULL;
      l_retval VARCHAR2(100) := 'fail';
   BEGIN
      dbms_output.put_line('Obteniendo el tipo de dato del objecto');
      
      SELECT object_type INTO l_object
        FROM all_objects
       WHERE object_name = upper(p_obname)
         AND ROWNUM <= 1;
      
      l_retval := l_object;
      dbms_output.put_line('El tipo de objeto es: ' || l_retval);
   
      RETURN l_retval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No hay objetos con el nombre: ' || p_obname);
         RETURN l_retval;
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error en la función al buscar el objeto: ' || p_obname);
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
         RETURN l_retval;
   END get_type;
   
   PROCEDURE regenerate(p_nameprogram VARCHAR2) IS
      l_catchtype VARCHAR2(200);
      l_catchclob CLOB;
      l_file utl_file.file_type;
      l_filename VARCHAR2(200);
   BEGIN
      l_catchtype := get_type(p_nameprogram);
      
      EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY g_dir AS ''C:\temp''';
     
      IF l_catchtype = 'fail'
      THEN
         dbms_output.put_line('El objeto no existe');
      ELSE
         l_catchclob := dbms_metadata.get_ddl(l_catchtype, p_nameprogram);
         
         l_filename := lower(g_dir) || '_' || lower(l_catchtype) || '_' || lower(p_nameprogram) || '.sql';
         
         dbms_output.put_line(l_filename);
         
         l_file := utl_file.fopen(upper('g_dir'), l_filename, 'w');
         utl_file.put(l_file, l_catchclob);
         utl_file.fclose(l_file);
         
         dbms_output.put_line('Sentencias escritas correctamente');
         
      END IF;
   END regenerate;
   
END compile_pkg;