--
-- GB_PKG_TEST  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.GB_PKG_TEST AS 
FUNCTION IS_ELIGIBLE(PL_ID VARCHAR2,ER_ID VARCHAR2,EE_ID VARCHAR2,MTH DATE) RETURN VARCHAR2;
function get_dep_status(CID VARCHAR2,pl varchar2,id1 varchar2,benefit varchar2,dt date) return varchar2;
function GET_BEN_COVERAGE(CID VARCHAR2,pl varchar2,id1 varchar2,BTYPE VARCHAR2,benefit varchar2,BDESC VARCHAR2,dt date,SX VARCHAR2,DOB DATE,SMK VARCHAR2,class1 varchar2) return VARCHAR2;
 function GET_BILL(CID VARCHAR2,pl varchar2,id1 varchar2,BTYPE VARCHAR2,benefit varchar2,BDESC VARCHAR2,dt date,SX VARCHAR2,DOB DATE,SMK VARCHAR2,class1 varchar2) return NUMBER;
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

END GB_PKG_TEST;
/

