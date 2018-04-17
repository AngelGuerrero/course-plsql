

-- Cabeceras de etiquetas
SELECT *
  FROM XXGIS.GIS_TAG_HEADERS
WHERE ORGANIZATION_ID = 157;

SELECT *
  FROM XXGIS.GIS_TAG_HEADERS
   WHERE 1 = 1
   AND ORGANIZATION_ID = 157
   AND STATUS = 'ACTIVA'
   AND LPN_ID IS NULL;
   
SELECT *
  FROM XXGIS.GIS_TAG_HEADERS
   WHERE 1 = 1
   AND ORGANIZATION_ID = 157
   AND STATUS <> 'ACTIVA'
   AND LPN_ID IS NULL;

DECLARE
BEGIN
   
END;


SELECT *
 FROM XXGIS.GIS_TAG_TRACKING_V
WHERE TAG_ID = 178
ORDER BY 5;

-- Etiquetas de San José
SELECT *
  FROM XXGIS.GIS_TAG_TRACKING_V or1
WHERE TO_ORGANIZATION_ID = 157
  AND or1.STATUS = 'ACTIVA'
  AND or1.TRANSACTION_TYPE_NAME <> 'Move Order Issue'
  AND or1.TO_LOCATOR_ID IS NULL
  AND or1.TRACKING_ID = (SELECT
                            MAX(or2.TRACKING_ID)
                           FROM XXGIS.GIS_TAG_TRACKING_V or2
                          WHERE or1.TAG_ID = or2.TAG_ID);


-- Campos a necesitar
SELECT TRACKING_ID,
       FOLIO_ORG,
       TRANSACTION_TYPE_NAME,
       TO_SUBINVENTORY_CODE,
       TAG_DATE,
       TO_LOCATOR_ID
 FROM XXGIS.GIS_TAG_TRACKING_V or1
 WHERE TO_ORGANIZATION_ID = 157
  AND or1.STATUS = 'ACTIVA'
  AND or1.TRANSACTION_TYPE_NAME <> 'Move Order Issue'
  AND or1.TO_LOCATOR_ID IS NULL
  AND or1.TRACKING_ID = (SELECT MAX(or2.TRACKING_ID)
                           FROM XXGIS.GIS_TAG_TRACKING_V or2
                          WHERE or1.TAG_ID = or2.TAG_ID);


 -- Ver los campos de la vista
 SELECT *
  FROM XXGIS.GIS_TAG_TRACKING_V or1
 WHERE TO_ORGANIZATION_ID = 157
  AND or1.STATUS = 'ACTIVA'
  AND or1.TRANSACTION_TYPE_NAME <> 'Move Order Issue'
  --AND or1.TO_LOCATOR_ID IS NULL
  AND or1.TRACKING_ID = (SELECT MAX(or2.TRACKING_ID)
                           FROM XXGIS.GIS_TAG_TRACKING_V or2
                          WHERE or1.TAG_ID = or2.TAG_ID);



 SELECT inventory_location_id,
                     concatenated_segments
                FROM mtl_item_locations_kfv
               WHERE 1 = 1
                 AND organization_id = 157
                 AND CONCATENATED_SEGMENTS IN ('PDVA1.0.0', 'CHIA1.0.0', 'DEVA1.0.0', 'RECIA1.0.0');

SELECT *
 FROM mtl_item_locations_kfv
 WHERE organization_id = 157 AND CONCATENATED_SEGMENTS IN ('PDVA1.0.0', 'CHIA1.0.0', 'DEVA1.0.0', 'RECIA1.0.0');

SELECT *
 FROM mtl_item_locations_kfv
 WHERE inventory_item_id IS NOT NULL; -- SUBINVENTORY_CODE

   SELECT *
     FROM mtl_item_locations_kfv
    WHERE organization_id = 157
      AND concatenated_segments IN ('PDVA1.0.0', 'CHIA1.0.0', 'DEVA1.0.0', 'RECIA1.0.0')
      AND subinventory_code = 'SPT';

SELECT COUNT(1),
      FOLIO_ORG
  FROM XXGIS.GIS_TAG_TRACKING_V
WHERE TO_ORGANIZATION_ID = 157
  AND STATUS = 'ACTIVA'
HAVING COUNT(1) > 1
GROUP BY FOLIO_ORG;


SELECT *
  FROM XXGIS.GIS_TAG_TRACKING_V
WHERE TO_ORGANIZATION_ID = 157
  AND STATUS = 'ACTIVA'
  AND FOLIO_ORG = 39840;


  --AND FOLIO_ORG = 39840



SELECT ORGANIZATION_CODE,
       WMS_ENABLED_FLAG,
       LPN_PREFIX,
       LPN_SUFFIX
  FROM INV.MTL_PARAMETERS
WHERE organization_id = 157; -- Organización: inventarios de San José 2 (SJ2)

SELECT *
 FROM HR.HR_ALL_ORGANIZATION_UNITS
WHERE ORGANIZATION_ID = 157;


FOLIO FORTUNE KEY: PDM-2012






SELECT * FROM XXGIS.GIS_TAG_TRACKING_V where TO_ORGANIZATION_ID = 157;

   SELECT CONCATENATED_SEGMENTS,
          SUBINVENTORY_CODE
     FROM mtl_item_locations_kfv
    WHERE organization_id = 157
      AND concatenated_segments IN ('PDVA1.0.0', 'CHIA1.0.0', 'DEVA1.0.0', 'RECIA1.0.0');

DESC mtl_item_locations_kfv;

SELECT TRACKING_ID,
       FOLIO_ORG,
       TRANSACTION_TYPE_NAME,
       TAG_DATE,
       TO_SUBINVENTORY_CODE,
       decode(TO_SUBINVENTORY_CODE, '07', 'CHIA1.0.0',
                                    'DEV', 'DEVA1.0.0',
                                    'RECIBO', 'RECIA1.0.0',
                                    'SPT', 'PDVA1.0.0') "NEW_LOCATOR_ID",

       decode("NEW_LOCATOR_ID", '93437', 'PDVA1.0.0',
                                    '93408', 'CHIA1.0.0',
                                    '93415', 'DEVA1.0.0',
                                    '99682', 'RECIA1.0.0') "NEW_LOCATOR"

 FROM XXGIS.GIS_TAG_TRACKING_V or1
WHERE TO_ORGANIZATION_ID = 157
  AND or1.STATUS = 'ACTIVA'
  AND or1.TRANSACTION_TYPE_NAME <> 'Move Order Issue'
  AND or1.TO_LOCATOR_ID IS NULL
  AND or1.TRACKING_ID = (SELECT MAX(or2.TRACKING_ID)
                           FROM XXGIS.GIS_TAG_TRACKING_V or2
                          WHERE or1.TAG_ID = or2.TAG_ID);


--   l_segs_table('93437') := 'PDVA1.0.0';
--   l_segs_table('93408') := 'CHIA1.0.0';
--   l_segs_table('93415') := 'DEVA1.0.0';
--   l_segs_table('99682') := 'RECIA1.0.0';

SELECT *
 FROM XXGIS.GIS_TAG_TRACKING_V or1
WHERE TO_ORGANIZATION_ID = 157
  AND or1.STATUS = 'ACTIVA'
  AND or1.TRANSACTION_TYPE_NAME <> 'Move Order Issue'
  --AND or1.TO_LOCATOR_ID IS NULL
  AND or1.TRACKING_ID = (SELECT MAX(or2.TRACKING_ID)
                           FROM XXGIS.GIS_TAG_TRACKING_V or2
                          WHERE or1.TAG_ID = or2.TAG_ID);

DESC XXGIS.GIS_TAG_TRACKING_V;

SELECT *
  FROM XXGIS.GIS_TAG_TRACKING_V
 WHERE 1 = 1
   AND 
   AND STATUS = 'ACTIVA'
   AND LPN_ID IS NULL;