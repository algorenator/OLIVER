--
-- TABLE_AUDIT_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.TABLE_AUDIT_PKG AS

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN VARCHAR2,
        L_OLD     IN VARCHAR2,
        L_ROWID   IN VARCHAR2
    )
        IS
    BEGIN
        IF
            ( L_NEW <> L_OLD OR ( L_NEW IS NULL AND L_OLD IS NOT NULL ) OR ( L_NEW IS NOT NULL AND L_OLD IS NULL ) )
        THEN
            INSERT INTO AUDIT_TBL (
                ID,
                TIMESTAMP,
                WHO,
                TNAME,
                CNAME,
                OLD,
                NEW,
                RID
            ) VALUES (
                DUMMY_SEQ.NEXTVAL,
                SYSDATE,
                USER,
                UPPER(L_TNAME),
                UPPER(L_CNAME),
                L_OLD,
                L_NEW,
                L_ROWID
            );

        END IF;
    END;

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN DATE,
        L_OLD     IN DATE,
        L_ROWID   IN VARCHAR2
    )
        IS
    BEGIN
        IF
            ( L_NEW <> L_OLD OR ( L_NEW IS NULL AND L_OLD IS NOT NULL ) OR ( L_NEW IS NOT NULL AND L_OLD IS NULL ) )
        THEN
            INSERT INTO AUDIT_TBL (
                ID,
                TIMESTAMP,
                WHO,
                TNAME,
                CNAME,
                OLD,
                NEW,
                RID
            ) VALUES (
                DUMMY_SEQ.NEXTVAL,
                SYSDATE,
                USER,
                UPPER(L_TNAME),
                UPPER(L_CNAME),
                TO_CHAR(L_OLD,'dd-mon-yyyy hh24:mi:ss'),
                TO_CHAR(L_NEW,'dd-mon-yyyy hh24:mi:ss'),
                L_ROWID
            );

        END IF;
    END;

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN NUMBER,
        L_OLD     IN NUMBER,
        L_ROWID   IN VARCHAR2
    )
        IS
    BEGIN
        IF
            ( L_NEW <> L_OLD OR ( L_NEW IS NULL AND L_OLD IS NOT NULL ) OR ( L_NEW IS NOT NULL AND L_OLD IS NULL ) )
        THEN
            INSERT INTO AUDIT_TBL (
                ID,
                TIMESTAMP,
                WHO,
                TNAME,
                CNAME,
                OLD,
                NEW,
                RID
            ) VALUES (
                DUMMY_SEQ.NEXTVAL,
                SYSDATE,
                USER,
                UPPER(L_TNAME),
                UPPER(L_CNAME),
                L_OLD,
                L_NEW,
                L_ROWID
            );

        END IF;
    END;

    PROCEDURE CHECK_VAL (
        L_TNAME   IN VARCHAR2,
        L_CNAME   IN VARCHAR2,
        L_NEW     IN TIMESTAMP,
        L_OLD     IN TIMESTAMP,
        L_ROWID   IN VARCHAR2
    )
        IS
    BEGIN
        IF
            ( L_NEW <> L_OLD OR ( L_NEW IS NULL AND L_OLD IS NOT NULL ) OR ( L_NEW IS NOT NULL AND L_OLD IS NULL ) )
        THEN
            INSERT INTO AUDIT_TBL (
                ID,
                TIMESTAMP,
                WHO,
                TNAME,
                CNAME,
                OLD,
                NEW,
                RID
            ) VALUES (
                DUMMY_SEQ.NEXTVAL,
                SYSDATE,
                USER,
                UPPER(L_TNAME),
                UPPER(L_CNAME),
                TO_CHAR(L_OLD,'DD-MON-YYYY HH24:MI:SSxFF'),
                TO_CHAR(L_NEW,'DD-MON-YYYY HH24:MI:SSxFF'),
                L_ROWID
            );

        END IF;
    END;

END TABLE_AUDIT_PKG;
/

