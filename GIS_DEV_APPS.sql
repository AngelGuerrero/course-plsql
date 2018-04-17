SELECT *
  FROM XXGIS.GIS_TAG_HEADERS
 WHERE 1 = 1
   AND ORGANIZATION_ID = 157
   AND STATUS <> 'ACTIVA'
   AND LAST_UPDATE_DATE > SYSDATE - 1
   AND LPN_ID IS NULL;


DESC XXGIS.GIS_TAG_HEADERS;

-- Procedimiento de cancelación de etiquetas con estatus ACTIVA y LPN_ID igual a NULL
DECLARE
   TYPE tag_headers_type IS TABLE OF XXGIS.GIS_TAG_HEADERS%ROWTYPE
      INDEX BY PLS_INTEGER;
      
   l_container tag_headers_type;
   l_elegible  tag_headers_type;
   
   -- Datos control
   l_count     NUMBER := 0;
   l_count_err NUMBER := 0;
   l_count_ok  NUMBER := 0;
BEGIN
   SELECT *
     BULK COLLECT
     INTO l_container
     FROM XXGIS.GIS_TAG_HEADERS
    WHERE 1 = 1
      AND ORGANIZATION_ID = 157
      AND STATUS = 'ACTIVA'
      AND LPN_ID IS NULL;
   
   dbms_output.put_line('Total de registros a actualizar: ' || l_container.COUNT);
   
   BEGIN
      FORALL indx IN 1 .. l_container.COUNT
         UPDATE XXGIS.GIS_TAG_HEADERS gt
            SET gt.STATUS = 'CANCELADA'
         WHERE 1 = 1
           AND gt.ORGANIZATION_ID = 157
           AND gt.STATUS = 'ACTIVA'
           AND gt.LPN_ID IS NULL
           AND gt.TAG_ID = l_container(indx).TAG_ID;
      
      -- Obtiene el total de registros procesados
      l_count := l_container.COUNT;
      
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('Ha ocurrido un error al actualizar los datos');
            dbms_output.put_line('Código de error: ' || SQLCODE);
            dbms_output.put_line('Mensaje de error: ' || sqlerrm);
            -- Incrementa el número de registros procesados con error
            l_count_err := l_count_err + 1;
   END;
   
   -- Obtiene el total de registros actualizados correctamente
   l_count_ok := l_count - l_count_err;
   
   -- Mensajes para el usuario --
   dbms_output.put_line('----------- CIFRAS CONTROL -----------');
   dbms_output.put_line('Total de registros procesados: ' || l_count);
   dbms_output.put_line('Total de registros fallidos: ' || l_count_err);
   dbms_output.put_line('Total de registros actualizados correctamente: ' || l_count_ok);
   
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error en el procedimiento principal');
         dbms_output.put_line('Código de error: ' || SQLCODE);
         dbms_output.put_line('Mensaje de error: ' || sqlerrm);
END;
/

