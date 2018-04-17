-- Procedimiento de cancelación de etiquetas con estatus ACTIVA y LPN_ID igual a NULL
DECLARE
   TYPE tag_headers_type IS TABLE OF XXGIS.GIS_TAG_HEADERS.TAG_ID%TYPE
      INDEX BY PLS_INTEGER;
      
   l_tagid tag_headers_type;
   
   -- Datos control
   l_count     NUMBER := 0;
   l_count_err NUMBER := 0;
   l_count_ok  NUMBER := 0;
   
BEGIN
   SELECT TAG_ID
     BULK COLLECT
     INTO l_tagid
     FROM XXGIS.GIS_TAG_HEADERS
    WHERE 1 = 1
      AND ORGANIZATION_ID = 157 -- San José 2
      AND STATUS = 'ACTIVA'
      AND LPN_ID IS NULL;
   
   dbms_output.put_line('Total de registros a actualizar: ' || l_tagid.COUNT);
   
   -- Inicia la actualización de los registros --
   dbms_output.put_line('Inicia proceso de cancelación de etiquetas de SJ2');
   BEGIN
      FORALL indx IN 1 .. l_tagid.COUNT
         UPDATE XXGIS.GIS_TAG_HEADERS gt
            SET gt.STATUS = 'CANCELADA',
                gt.LAST_UPDATE_DATE = SYSDATE,
                gt.LAST_UPDATED_BY = 0
         WHERE 1 = 1
           AND gt.TAG_ID = l_tagid(indx);
      
      -- Obtiene el total de registros procesados
      l_count := l_tagid.COUNT;
      
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('Ha ocurrido un error al actualizar los datos');
            dbms_output.put_line('Código de error: ' || SQLCODE);
            dbms_output.put_line('Mensaje de error: ' || sqlerrm);
            -- Incrementa el número de registros procesados con error
            l_count_err := l_count_err + 1;
   END;
   -------
   dbms_output.put_line('Termina proceso de cancelación de etiquetas');
   
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

