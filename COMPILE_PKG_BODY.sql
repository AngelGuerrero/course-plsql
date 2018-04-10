CREATE OR REPLACE PACKAGE BODY compile_pkg IS
   -- Private function
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
      l_object all_objects%rowtype := NULL;
      l_retval VARCHAR2(100);
   BEGIN
      dbms_output.put_line('Obteniendo el tipo de dato del objecto');
      
      SELECT * INTO l_object
        FROM all_objects
       WHERE object_name = upper(p_obname);
      
      l_retval := l_object.object_type;
      dbms_output.put_line('El tipo de objeto es: ' || l_retval);
   
      RETURN l_retval;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No hay objetos con el nombre: ' || p_obname);
         RETURN '';
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error en la función al buscar el objeto: ' || p_obname);
         dbms_output.put_line('Error: ' || SQLCODE);
         dbms_output.put_line('Mensaje: ' || sqlerrm);
         RETURN '';
   END get_type;
   
END compile_pkg;