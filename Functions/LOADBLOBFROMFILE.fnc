--
-- LOADBLOBFROMFILE  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.LOADBLOBFROMFILE (
    P_DIR VARCHAR2,
    P_FILE_NAME VARCHAR2
) RETURN BLOB AS
    DEST_LOC   BLOB := EMPTY_BLOB ();
    SRC_LOC    BFILE := BFILENAME(P_DIR,P_FILE_NAME);
BEGIN
  -- Open source binary file from OS
    DBMS_LOB.OPEN(SRC_LOC,DBMS_LOB.LOB_READONLY);
  
  -- Create temporary LOB object
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => DEST_LOC,CACHE => TRUE,DUR => DBMS_LOB.SESSION);
    
  -- Open temporary lob

    DBMS_LOB.OPEN(DEST_LOC,DBMS_LOB.LOB_READWRITE);
  
  -- Load binary file into temporary LOB
    DBMS_LOB.LOADFROMFILE(DEST_LOB => DEST_LOC,SRC_LOB => SRC_LOC,AMOUNT => DBMS_LOB.GETLENGTH(SRC_LOC) );
  
  -- Close lob objects

    DBMS_LOB.CLOSE(DEST_LOC);
    DBMS_LOB.CLOSE(SRC_LOC);
  
  -- Return temporary LOB object
    RETURN DEST_LOC;
END LOADBLOBFROMFILE;
/

