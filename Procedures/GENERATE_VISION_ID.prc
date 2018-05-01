--
-- GENERATE_VISION_ID  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.GENERATE_VISION_ID AS

    CURSOR C IS SELECT
        SN
                FROM
        TEMP_VISION_ID
    ORDER BY
        SN;

    REC   C%ROWTYPE;
    S     VARCHAR2(100);
BEGIN
    S := '800000000';
    OPEN C;
    LOOP
        FETCH C INTO REC;
        EXIT WHEN C%NOTFOUND;
        UPDATE TEMP_VISION_ID
            SET
                ID = S
        WHERE
            SN = REC.SN;

        S := S + 1;
    END LOOP;

    CLOSE C;
END;
/

