-- Practice 8
-- a. Can a table or a synonym be invalidated?
-- b. Consider the following dependency example:
--    The stand-alone procedure MY_PROC depends on the MY_PROC_PACK
--    package procedudre. The MY_PROC_PACK procedure's definition is changed by
--    recompiling the package body. The MY_PROC_PAC procedure's declaration
--    is not altered in the package specification.
--    In this scenario, is the stand-alone procedure MY_PROC invalidated?

-- 2. Create a tree structure showing all dependencies involving yout add_employee
--    procedure and your valid_deptid function.

--    Note: add_employee and valid_deptid where created in the lesson titled
--    "Creating Stored Functions". You can run the solution scripts for Practice 2
--    if you need to create the procedure and function.
--    a.  Load and execute the utldtree.sql script, which is located in the
--    temp labs

--    b. Execute the deptree_fill proceddure for the add_employee procedure.
--    c. Execute the depttree view to see tour results
--    d. Query the deptree_fill procedure for the valid_deptid function.
--    e. Query the idetree view to see your results.

deptree_fill('TABLE', 'HR', 'TEMP_EMP');

select * from ideptree;
