-- Practice 9.

-- 1. Create a table called PERSONNEL by executing the script file,
-- The table contains the following attributs and data types.

EXECUTE make_table('PERSONNEL', 'last_name VARCHAR2(35), picture BLOB', TRUE);

SELECT *
  FROM PERSONNEL;

DESC PERSONNEL;

SELECT *
  FROM PERSONNEL;

INSERT
  INTO PERSONNEL
VALUES (2034, 'Allen', EMPTY_CLOB(), NULL);

INSERT
  INTO PERSONNEL
VALUES (2035, 'Bond', EMPTY_CLOB(), NULL);



DECLARE
   l_text VARCHAR2(4001);
   l_person PERSONNEL.rowtype;
BEGIN
   
    SELECT
         * INTO l_person
      FROM PERSONNEL
     WHERE personnel_id = 1;
     
    dbms_output.put_line('Text is: ' || dbms_lob.getlength(l_person.review));
END;
/

SELECT personnel_id,
       resume -- CLOB
  FROM PERSONNEL
 WHERE personnel_id = 1;







