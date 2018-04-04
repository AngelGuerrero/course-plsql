/*===============================================================+
   procedure:    update_locator_id
   DESCRIPTION:  Actualiza el to_location_id y el to_locator
   ARGUMENTS:
               IN N/A

               OUT N/A

   RETURNS:      N/A
   NOTES:        Actualiza los campos del to_locator de acuerdo a la
                 columna new_locator que se crea de acuerdo a una decodificación
                 utilizando el to_subinventory_code.



   HISTORY
   Version     Date         Author                    Change Reference
   1.0         03/Abril/2018   Ángel Guerrero.           1.0
+================================================================*/
CREATE OR REPLACE PROCEDURE update_locator_id IS
   TYPE segments IS TABLE OF NUMBER INDEX BY VARCHAR2(64);
   l_segs_table segments;

   l_i VARCHAR2(64);

   l_inv_id VARCHAR2(100);

   l_counter NUMBER := 0;
   l_counter_err NUMBER := 0;
   l_counter_succ NUMBER := 0;

   l_tag_tracking xxgis.gis_tag_tracking_v%rowtype;
   l_item_loc mtl_item_locations_kfv%rowtype;
BEGIN
   -- Obtiene el inventory_location_id y el concatenated_segments
   -- para almacenar en variables
   FOR l_item_loc IN (SELECT *
                        FROM mtl_item_locations_kfv
                       WHERE organization_id = 157 -- San José
                         AND concatenated_segments IN ('PDVA1.0.0',
                                                       'CHIA1.0.0',
                                                       'DEVA1.0.0',
                                                       'RECIA1.0.0'))
   LOOP
      -- Llena la tabla hash
       l_segs_table(l_item_loc.concatenated_segments) := l_item_loc.inventory_location_id;
   END LOOP;


   FOR l_tag_tracking IN (SELECT tracking_id,
                                 folio_org,
                                 transaction_type_name,
                                 to_subinventory_code,
                                 tag_date,
                                 to_locator_id,
                                 decode(to_subinventory_code, '07', 'CHIA1.0.0',
                                                              'DEV', 'DEVA1.0.0',
                                                              'RECIBO', 'RECIA1.0.0',
                                                              'SPT', 'PDVA1.0.0',
                                                              'xxx') "NEW_LOCATOR"
                           FROM xxgis.gis_tag_tracking_v or1
                          WHERE TO_ORGANIZATION_ID = 157
                            AND or1.STATUS = 'ACTIVA'
                            AND or1.transaction_type_name <> 'Move Order Issue'
                            AND or1.to_locator_id IS NULL
                            AND or1.tracking_id = (SELECT MAX(or2.tracking_id)
                                                     FROM xxgis.gis_tag_tracking_v or2
                                                    WHERE or1.TAG_ID = or2.TAG_ID))
   LOOP
      -- Muestra los primeros 200 elementos
      IF l_counter < 200
      THEN
           dbms_output.put_line(l_tag_tracking.tracking_id || ' - ' ||
                                l_tag_tracking.folio_org || ' - ' ||
                                l_tag_tracking.to_subinventory_code || ' - ' ||
                                l_tag_tracking.new_locator || ' - ' ||
                                l_tag_tracking.to_locator_id);
      END IF;

      -- Cuenta los errores encontrados
      IF l_tag_tracking.new_locator = 'xxx'
      THEN
         l_counter_err := l_counter_err + 1;
      ELSE
         l_counter_succ := l_counter_succ + 1;
      END IF;
      l_counter := l_counter + 1;
   END LOOP;

   -- Muestra el número de registros actualizados
   dbms_output.put_line('Número de registros actualizados: ' || l_counter);

   -- Muestra el número de registros que se realizaron exitosamente
   dbms_output.put_line('Número de registros que se cambiaron exitosamente: ' || l_counter_succ);

   -- Muestra el número de registros que no se pudieron actualizar
   dbms_output.put_line('Número de registros con error: ' || l_counter_err);

   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Ha ocurrido un error en el procedimiento: update_locator_id');
         dbms_output.put_line('Código de error: ' || SQLCODE);
         dbms_output.put_line('Mensaje de error: ' || sqlerrm);
END update_locator_id;
/

EXECUTE update_locator_id;
