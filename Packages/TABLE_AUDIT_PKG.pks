--
-- TABLE_AUDIT_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.TABLE_AUDIT_PKG AS
    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN VARCHAR2,
        L_OLD     IN VARCHAR2,
        L_ROWID   IN VARCHAR2
    );

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN DATE,
        L_OLD     IN DATE,
        L_ROWID   IN VARCHAR2
    );

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN NUMBER,
        L_OLD     IN NUMBER,
        L_ROWID   IN VARCHAR2
    );

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN TIMESTAMP,
        L_OLD     IN TIMESTAMP,
        L_ROWID   IN VARCHAR2
    );

END TABLE_AUDIT_PKG;
/

