--
-- GB_PKG_200418  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.GB_PKG_200418 AS

    FUNCTION IS_ELIGIBLE (
        PL_ID   VARCHAR2,
        ER_ID   VARCHAR2,
        EE_ID   VARCHAR2,
        MTH     DATE
    ) RETURN VARCHAR2 AS
        CNT   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO
            CNT
        FROM
            TBL_HW
        WHERE
            HW_PLAN = PL_ID
            AND   HW_ID = EE_ID
            AND   MTH BETWEEN HW_EFF_DATE AND NVL(HW_TERM_DATE,MTH + 1);

        IF
            NVL(CNT,0) > 0
        THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;

    END IS_ELIGIBLE;

    FUNCTION GET_DEP_STATUS (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BENEFIT   VARCHAR2,
        DT        DATE
    ) RETURN VARCHAR2 IS
        CNT   NUMBER := 0;
        R     VARCHAR2(1);
    BEGIN
        IF
            BENEFIT IS NOT NULL
        THEN
            SELECT
                LTRIM(RTRIM(MAX(A.THW_WAIVER_COVERAGE) ) )
            INTO
                R
            FROM
                TBL_HW_WAIVER A
            WHERE
                A.THW_CLIENT = CID
                AND   A.THW_PLAN = PL
                AND   A.THW_MEM_ID = ID1
                AND   A.THW_BENEFIT = BENEFIT
                AND   NVL(A.THW_START_DATE,DT) = (
                    SELECT
                        NVL(MAX(B.THW_START_DATE),DT)
                    FROM
                        TBL_HW_WAIVER B
                    WHERE
                        B.THW_CLIENT = CID
                        AND   B.THW_PLAN = PL
                        AND   B.THW_MEM_ID = ID1
                        AND   B.THW_BENEFIT = BENEFIT
                        AND   NVL(B.THW_START_DATE,DT) <= DT
                );

        ELSE
            R := NULL;
        END IF;

        IF
            R IS NULL
        THEN
            SELECT
                LTRIM(RTRIM(MAX(HW_DEP_STATUS) ) )
            INTO
                R
            FROM
                TBL_HW
            WHERE
                HW_CLIENT = CID
                AND   HW_PLAN = PL
                AND   HW_ID = ID1;

            IF
                R IS NULL
            THEN
                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_HW_DEPENDANTS
                WHERE
                    HD_CLIENT = CID
                    AND   HD_PLAN = PL
                    AND   HD_ID = ID1
                    AND   HD_EFF_DATE <= DT
                    AND   NVL(HD_TERM_DATE,DT) >= DT;

                IF
                    NVL(CNT,0) = 0
                THEN
                    R := 'S';
                ELSIF NVL(CNT,0) = 1 THEN
                    R := 'C';
                ELSE
                    R := 'F';
                END IF;

            END IF;

        END IF;

        RETURN R;
    END;

    FUNCTION GET_BEN_COVERAGE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN VARCHAR2 AS

        R      VARCHAR2(100);
        DS     VARCHAR2(1);
        VREC   BENEFITS_VOLUME_BASED%ROWTYPE;
        DREC   BENEFITS_DEP_BASED%ROWTYPE;
        AREC   BENEFITS_AGE_BASED%ROWTYPE;
        VOL1   VARCHAR2(100);
        UT     NUMBER(12,2) := 1;
        RT     NUMBER(12,6) := 0;
        ADMN   NUMBER(12,6) := 0;
        AGT    NUMBER(12,6) := 0;
        AGE1   NUMBER(12,6) := 0;
        AGE    NUMBER(12,6) := 0;
        SL1    NUMBER(12,2) := 0;
    BEGIN
        IF
            NVL(BTYPE,'X') = 'V'
        THEN
            SELECT
                *
            INTO
                VREC
            FROM
                BENEFITS_VOLUME_BASED
            WHERE
                BVB_CLIENT_ID = CID
                AND   BVB_PLAN_ID = PL
                AND   BVB_CLASS = CLASS1
                AND   BVB_BENEFIT = BENEFIT
                AND   BVB_EFFECTIVE_DATE = (
                    SELECT
                        MAX(BVB_EFFECTIVE_DATE)
                    FROM
                        BENEFITS_VOLUME_BASED
                    WHERE
                        BVB_CLIENT_ID = CID
                        AND   BVB_PLAN_ID = PL
                        AND   BVB_CLASS = CLASS1
                        AND   BVB_BENEFIT = BENEFIT
                        AND   BVB_EFFECTIVE_DATE <= DT
                )
                AND   BVB_TERM_DATE IS NULL;
  --SELECT DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_MAX,0),NVL(VREC.BVB_NEM,0))) INTO VOL1 FROM DUAL;
  --SELECT DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_MAX,0),NVL(VREC.BVB_VOLUME,0))) INTO VOL1 FROM DUAL;
 -- SELECT DECODE(DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),NVL(VREC.BVB_VOLUME,0)),0,DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_MAX,0),NVL(VREC.BVB_VOLUME,0)),0) INTO VOL1 FROM DUAL;

            IF
                NVL(VREC.BVB_VOLUME,0) <> 0
            THEN
                VOL1 := LTRIM(RTRIM(VREC.BVB_VOLUME) );
            ELSIF NVL(VREC.BVB_NEM,0) <> 0 THEN
                VOL1 := VREC.BVB_NEM;
            ELSIF NVL(VREC.BVB_MAX,0) <> 0 THEN
                VOL1 := VREC.BVB_MAX;
            ELSE
                VOL1 := 0;
            END IF;

            IF
                NVL(VOL1,0) < 100 AND NVL(VOL1,0) <> 0
            THEN
                SL1 := SAL;
                IF
                    NVL(SL1,0) = 0
                THEN
                    SL1 := GET_SALARY(CID,PL,ID1,BENEFIT,DT);
                END IF;

                VOL1 := ROUND( ( (SL1 * (NVL(VOL1,0) / 100) ) ),2);

            END IF;

            IF
                BG = 'LTD'
            THEN
                VOL1 := VOL1 / 12;
            ELSIF BG = 'STD' THEN
                VOL1 := VOL1 / 52;
            END IF;

            RT := VREC.BVB_RATE;
            UT := VREC.BVB_UNIT;
            ADMN := VREC.BVB_ADMIN_RATE;
            AGT := VREC.BVB_AGENT;
        ELSIF NVL(BTYPE,'X') = 'D' THEN
            DS := DS1;
            IF
                DS IS NULL
            THEN
                DS := GET_DEP_STATUS(CID,PL,ID1,BG,DT);
            END IF;

            SELECT
                *
            INTO
                DREC
            FROM
                BENEFITS_DEP_BASED
            WHERE
                BDB_CLIENT_ID = CID
                AND   BDB_PLAN_ID = PL
                AND   BDB_CLASS = CLASS1
                AND   BDB_BENEFIT = BENEFIT
                AND   BDB_DEP_STATUS = DS
                AND   BDB_EFF_DATE = (
                    SELECT
                        MAX(BDB_EFF_DATE)
                    FROM
                        BENEFITS_DEP_BASED
                    WHERE
                        BDB_CLIENT_ID = CID
                        AND   BDB_PLAN_ID = PL
                        AND   BDB_CLASS = CLASS1
                        AND   BDB_BENEFIT = BENEFIT
                        AND   BDB_DEP_STATUS = DS
                        AND   BDB_EFF_DATE <= DT
                )
                AND   BDB_TERM_DATE IS NULL;

            VOL1 := DS;
            RT := DREC.BDB_RATE;
            UT := 1;
            ADMN := DREC.BDB_ADMIN_RATE;
            AGT := DREC.BDB_AGENT;
        ELSIF NVL(BTYPE,'X') = 'A' THEN
            AGE := ABS(AGE_CALC(CID,PL,DT,DOB) );
            SELECT
                MIN(BAB_AGE)
            INTO
                AGE1
            FROM
                BENEFITS_AGE_BASED
            WHERE
                BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE >= AGE;

            SELECT
                SUM(MVB_VOLUME),
                AVG(BAB_RATE),
                AVG(BAB_ADMIN_RATE),
                MAX(BAB_AGENT)
            INTO
                VOL1,RT,ADMN,AGT
            FROM
                BENEFITS_AGE_BASED,
                TBL_MEM_VOL_BENEFITS
            WHERE
                MVB_CLIENT = CID
                AND   MVB_PLAN = PL
                AND   MVB_BENEFIT = BENEFIT
                AND   MVB_ID = ID1
                AND   BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE = AGE1
                AND   BAB_EFF_DATE = (
                    SELECT
                        MAX(BAB_EFF_DATE)
                    FROM
                        BENEFITS_AGE_BASED
                    WHERE
                        BAB_CLIENT_ID = CID
                        AND   BAB_PLAN_ID = PL
                        AND   BAB_CLASS = CLASS1
                        AND   BAB_BENEFIT = BENEFIT
                        AND   BAB_GENDER = SX
                        AND   BAB_SMOKER = SMK
                        AND   BAB_AGE = AGE1
                        AND   BAB_EFF_DATE <= DT
                )
                AND   BAB_TERM_DATE IS NULL;
      --VOL1:=AREC.MVB_VOLUME;
     -- RT:=AREC.BAB_RATE;

            UT := 1;
      --ADMN:=AREC.BAB_ADMIN_RATE;
     -- AGT:=AREC.BAB_AGENT;
        END IF;

        R := VOL1;
        RETURN R;
    END;

    FUNCTION GET_BILL (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER AS

        R      NUMBER(12,2) := 0;
        DS     VARCHAR2(1);
        VREC   BENEFITS_VOLUME_BASED%ROWTYPE;
        DREC   BENEFITS_DEP_BASED%ROWTYPE;
        AREC   BENEFITS_AGE_BASED%ROWTYPE;
        VOL1   NUMBER(12,2) := 0;
        VOL2   NUMBER(12,6) := 0;
        UT     NUMBER(12,2) := 1;
        RT     NUMBER(12,6) := 0;
        ADMN   NUMBER(12,6) := 0;
        AGT    NUMBER(12,6) := 0;
        AGE1   NUMBER(12,6) := 0;
        AGE    NUMBER(12,6) := 0;
        SL1    NUMBER(12,2) := 0;
    BEGIN
        IF
            NVL(BTYPE,'X') = 'V'
        THEN
      --SELECT * INTO VREC FROM BENEFITS_VOLUME_BASED WHERE BVB_CLIENT_ID=CID AND BVB_PLAN_ID=PL and bvb_class=class1 AND BVB_BENEFIT=BENEFIT AND  BVB_EFFECTIVE_DATE=(SELECT MAX(BVB_EFFECTIVE_DATE) FROM BENEFITS_VOLUME_BASED WHERE BVB_CLIENT_ID=CID AND BVB_PLAN_ID=PL and bvb_class=class1 AND BVB_BENEFIT=BENEFIT AND BVB_EFFECTIVE_DATE<=DT) AND BVB_TERM_DATE IS NULL;
            SELECT
                *
            INTO
                VREC
            FROM
                BENEFITS_VOLUME_BASED
            WHERE
                BVB_CLIENT_ID = CID
                AND   BVB_PLAN_ID = PL
                AND   BVB_CLASS = CLASS1
                AND   BVB_BENEFIT = BENEFIT
                AND   BVB_EFFECTIVE_DATE = (
                    SELECT
                        MAX(BVB_EFFECTIVE_DATE)
                    FROM
                        BENEFITS_VOLUME_BASED
                    WHERE
                        BVB_CLIENT_ID = CID
                        AND   BVB_PLAN_ID = PL
                        AND   BVB_CLASS = CLASS1
                        AND   BVB_BENEFIT = BENEFIT
                        AND   BVB_EFFECTIVE_DATE <= DT
                )
                AND   BVB_TERM_DATE IS NULL;

            VOL2 := 0;
            IF
                NVL(VREC.BVB_VOLUME,0) <> 0
            THEN
                VOL1 := VREC.BVB_VOLUME;
            ELSIF NVL(VREC.BVB_NEM,0) <> 0 THEN
                VOL1 := VREC.BVB_NEM;
            ELSIF NVL(VREC.BVB_MAX,0) <> 0 THEN
                VOL1 := VREC.BVB_MAX;
            ELSE
                VOL1 := 0;
            END IF;
     --SELECT DECODE(DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),NVL(VREC.BVB_VOLUME,0)),0,DECODE(NVL(VREC.BVB_max,0),0,NVL(VREC.BVB_VOLUME,0),0)) INTO VOL1 FROM DUAL;

            IF
                NVL(VOL1,0) < 100 AND NVL(VOL1,0) <> 0
            THEN
                SL1 := SAL;
                IF
                    NVL(SL1,0) = 0
                THEN
                    SL1 := GET_SALARY(CID,PL,ID1,BENEFIT,DT);
                END IF;

                VOL1 := ROUND( ( (SL1 * (NVL(VOL1,0) / 100) ) ),2);

            END IF;

            IF
                BG = 'LTD'
            THEN
                VOL1 := VOL1 / 12;
            ELSIF BG = 'STD' THEN
                VOL1 := VOL1 / 52;
            END IF;

            RT := VREC.BVB_RATE;
            UT := VREC.BVB_UNIT;
            ADMN := VREC.BVB_ADMIN_RATE;
            AGT := VREC.BVB_AGENT_RATE;
            R := ( VOL1 / NVL(UT,1) ) * ( NVL(RT,0) + NVL(ADMN,0) + NVL(AGT,0) );

        ELSIF NVL(BTYPE,'X') = 'D' THEN
            DS := DS1;
            IF
                DS IS NULL
            THEN
                DS := GET_DEP_STATUS(CID,PL,ID1,BG,DT);
            END IF;

            SELECT
                *
            INTO
                DREC
            FROM
                BENEFITS_DEP_BASED
            WHERE
                BDB_CLIENT_ID = CID
                AND   BDB_PLAN_ID = PL
                AND   BDB_CLASS = CLASS1
                AND   BDB_BENEFIT = BENEFIT
                AND   BDB_DEP_STATUS = DS
                AND   BDB_EFF_DATE = (
                    SELECT
                        MAX(BDB_EFF_DATE)
                    FROM
                        BENEFITS_DEP_BASED
                    WHERE
                        BDB_CLIENT_ID = CID
                        AND   BDB_PLAN_ID = PL
                        AND   BDB_CLASS = CLASS1
                        AND   BDB_BENEFIT = BENEFIT
                        AND   BDB_DEP_STATUS = DS
                        AND   BDB_EFF_DATE <= DT
                )
                AND   BDB_TERM_DATE IS NULL;

            VOL1 := NULL;
            VOL2 := NULL;
            RT := DREC.BDB_RATE;
            UT := 1;
            ADMN := DREC.BDB_ADMIN_RATE;
            AGT := DREC.BDB_AGENT_RATE;
            R := NVL(RT,0) + NVL(ADMN,0) + NVL(AGT,0);

        ELSIF NVL(BTYPE,'X') = 'A' THEN
            AGE := AGE_CALC(CID,PL,DT,DOB);
            SELECT
                MIN(BAB_AGE)
            INTO
                AGE1
            FROM
                BENEFITS_AGE_BASED
            WHERE
                BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = NVL(SMK,'N')
                AND   BAB_AGE >= AGE;
      --SELECT * INTO AREC FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL and bab_class=class1 and  BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE=(SELECT MAX(BAB_EFF_DATE) FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL AND bab_class=class1 and BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE<=DT);

            SELECT
                AVG(BAB_RATE),
                AVG(BAB_ADMIN_RATE),
                MAX(BAB_AGENT)
            INTO
                RT,ADMN,AGT
            FROM
                BENEFITS_AGE_BASED,
                TBL_MEM_VOL_BENEFITS
            WHERE
                MVB_CLIENT = CID
                AND   MVB_PLAN = PL
                AND   MVB_BENEFIT = BENEFIT
                AND   MVB_ID = ID1
                AND   BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   NVL(BAB_SMOKER,'N') = NVL(SMK,'N')
                AND   BAB_AGE = AGE1
                AND   BAB_EFF_DATE = (
                    SELECT
                        MAX(BAB_EFF_DATE)
                    FROM
                        BENEFITS_AGE_BASED
                    WHERE
                        BAB_CLIENT_ID = CID
                        AND   BAB_PLAN_ID = PL
                        AND   BAB_CLASS = CLASS1
                        AND   BAB_BENEFIT = BENEFIT
                        AND   BAB_GENDER = SX
                        AND   NVL(BAB_SMOKER,'N') = NVL(SMK,'N')
                        AND   BAB_AGE = AGE1
                        AND   BAB_EFF_DATE <= DT
                )
                AND   BAB_TERM_DATE IS NULL;

            VOL1 := NULL;
            VOL2 := NULL;
      --RT:=AREC.BAB_RATE;
            UT := 1;
      --ADMN:=AREC.BAB_ADMIN_RATE;
     -- AGT:=AREC.BAB_AGENT_RATE;
            R := NVL(RT,0) + NVL(ADMN,0) + NVL(AGT,0);

        END IF;

        RETURN R;
    END;

    FUNCTION GET_ADMIN_AMT (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER AS

        R      NUMBER(12,2) := 0;
        DS     VARCHAR2(1);
        VREC   BENEFITS_VOLUME_BASED%ROWTYPE;
        DREC   BENEFITS_DEP_BASED%ROWTYPE;
        AREC   BENEFITS_AGE_BASED%ROWTYPE;
        VOL1   NUMBER(12,2) := 0;
        VOL2   NUMBER(12,6) := 0;
        UT     NUMBER(12,2) := 1;
        RT     NUMBER(12,6) := 0;
        ADMN   NUMBER(12,6) := 0;
        AGT    NUMBER(12,6) := 0;
        AGE1   NUMBER(12,6) := 0;
        AGE    NUMBER(12,6) := 0;
        SL1    NUMBER(12,2) := 0;
    BEGIN
        IF
            NVL(BTYPE,'X') = 'V'
        THEN
      --SELECT * INTO VREC FROM BENEFITS_VOLUME_BASED WHERE BVB_CLIENT_ID=CID AND BVB_PLAN_ID=PL and bvb_class=class1 AND BVB_BENEFIT=BENEFIT AND  BVB_EFFECTIVE_DATE=(SELECT MAX(BVB_EFFECTIVE_DATE) FROM BENEFITS_VOLUME_BASED WHERE BVB_CLIENT_ID=CID AND BVB_PLAN_ID=PL and bvb_class=class1 AND BVB_BENEFIT=BENEFIT AND BVB_EFFECTIVE_DATE<=DT) AND BVB_TERM_DATE IS NULL;
            SELECT
                *
            INTO
                VREC
            FROM
                BENEFITS_VOLUME_BASED
            WHERE
                BVB_CLIENT_ID = CID
                AND   BVB_PLAN_ID = PL
                AND   BVB_CLASS = CLASS1
                AND   BVB_BENEFIT = BENEFIT
                AND   BVB_EFFECTIVE_DATE = (
                    SELECT
                        MAX(BVB_EFFECTIVE_DATE)
                    FROM
                        BENEFITS_VOLUME_BASED
                    WHERE
                        BVB_CLIENT_ID = CID
                        AND   BVB_PLAN_ID = PL
                        AND   BVB_CLASS = CLASS1
                        AND   BVB_BENEFIT = BENEFIT
                        AND   BVB_EFFECTIVE_DATE <= DT
                )
                AND   BVB_TERM_DATE IS NULL;

            VOL2 := 0;
            IF
                NVL(VREC.BVB_VOLUME,0) <> 0
            THEN
                VOL1 := VREC.BVB_VOLUME;
            ELSIF NVL(VREC.BVB_NEM,0) <> 0 THEN
                VOL1 := VREC.BVB_NEM;
            ELSIF NVL(VREC.BVB_MAX,0) <> 0 THEN
                VOL1 := VREC.BVB_MAX;
            ELSE
                VOL1 := 0;
            END IF;
     --SELECT DECODE(DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),NVL(VREC.BVB_VOLUME,0)),0,DECODE(NVL(VREC.BVB_max,0),0,NVL(VREC.BVB_VOLUME,0),0)) INTO VOL1 FROM DUAL;

            IF
                NVL(VOL1,0) < 100 AND NVL(VOL1,0) <> 0
            THEN
                SL1 := SAL;
                IF
                    NVL(SL1,0) = 0
                THEN
                    SL1 := GET_SALARY(CID,PL,ID1,BENEFIT,DT);
                END IF;

                VOL1 := ROUND( ( (SL1 * (NVL(VOL1,0) / 100) ) ),2);

            END IF;

            IF
                BG = 'LTD'
            THEN
                VOL1 := VOL1 / 12;
            ELSIF BG = 'STD' THEN
                VOL1 := VOL1 / 52;
            END IF;

            RT := VREC.BVB_RATE;
            UT := VREC.BVB_UNIT;
            ADMN := VREC.BVB_ADMIN_RATE;
            AGT := VREC.BVB_AGENT_RATE;
            R := ( VOL1 / NVL(UT,1) ) * ( NVL(ADMN,0) + NVL(AGT,0) );

        ELSIF NVL(BTYPE,'X') = 'D' THEN
            DS := DS1;
            IF
                DS IS NULL
            THEN
                DS := GET_DEP_STATUS(CID,PL,ID1,BG,DT);
            END IF;

            SELECT
                *
            INTO
                DREC
            FROM
                BENEFITS_DEP_BASED
            WHERE
                BDB_CLIENT_ID = CID
                AND   BDB_PLAN_ID = PL
                AND   BDB_CLASS = CLASS1
                AND   BDB_BENEFIT = BENEFIT
                AND   BDB_DEP_STATUS = DS
                AND   BDB_EFF_DATE = (
                    SELECT
                        MAX(BDB_EFF_DATE)
                    FROM
                        BENEFITS_DEP_BASED
                    WHERE
                        BDB_CLIENT_ID = CID
                        AND   BDB_PLAN_ID = PL
                        AND   BDB_CLASS = CLASS1
                        AND   BDB_BENEFIT = BENEFIT
                        AND   BDB_DEP_STATUS = DS
                        AND   BDB_EFF_DATE <= DT
                )
                AND   BDB_TERM_DATE IS NULL;

            VOL1 := NULL;
            VOL2 := NULL;
            RT := DREC.BDB_RATE;
            UT := 1;
            ADMN := DREC.BDB_ADMIN_RATE;
            AGT := DREC.BDB_AGENT_RATE;
            R := NVL(ADMN,0) + NVL(AGT,0);
        ELSIF NVL(BTYPE,'X') = 'A' THEN
            AGE := AGE_CALC(CID,PL,DT,DOB);
            SELECT
                MIN(BAB_AGE)
            INTO
                AGE1
            FROM
                BENEFITS_AGE_BASED
            WHERE
                BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = NVL(SMK,'N')
                AND   BAB_AGE >= AGE;
      --SELECT * INTO AREC FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL and bab_class=class1 and  BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE=(SELECT MAX(BAB_EFF_DATE) FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL AND bab_class=class1 and BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE<=DT);

            SELECT
                AVG(BAB_RATE),
                AVG(BAB_ADMIN_RATE),
                MAX(BAB_AGENT)
            INTO
                RT,ADMN,AGT
            FROM
                BENEFITS_AGE_BASED,
                TBL_MEM_VOL_BENEFITS
            WHERE
                MVB_CLIENT = CID
                AND   MVB_PLAN = PL
                AND   MVB_BENEFIT = BENEFIT
                AND   MVB_ID = ID1
                AND   BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   NVL(BAB_SMOKER,'N') = NVL(SMK,'N')
                AND   BAB_AGE = AGE1
                AND   BAB_EFF_DATE = (
                    SELECT
                        MAX(BAB_EFF_DATE)
                    FROM
                        BENEFITS_AGE_BASED
                    WHERE
                        BAB_CLIENT_ID = CID
                        AND   BAB_PLAN_ID = PL
                        AND   BAB_CLASS = CLASS1
                        AND   BAB_BENEFIT = BENEFIT
                        AND   BAB_GENDER = SX
                        AND   NVL(BAB_SMOKER,'N') = NVL(SMK,'N')
                        AND   BAB_AGE = AGE1
                        AND   BAB_EFF_DATE <= DT
                )
                AND   BAB_TERM_DATE IS NULL;

            VOL1 := NULL;
            VOL2 := NULL;
      --RT:=AREC.BAB_RATE;
            UT := 1;
      --ADMN:=AREC.BAB_ADMIN_RATE;
     -- AGT:=AREC.BAB_AGENT_RATE;
            R := NVL(ADMN,0) + NVL(AGT,0);
        END IF;

        RETURN R;
    END;

    FUNCTION GET_CARRIER_RATE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER AS

        R      NUMBER(12,2) := 0;
        DS     VARCHAR2(1);
        VREC   BENEFITS_VOLUME_BASED%ROWTYPE;
        DREC   BENEFITS_DEP_BASED%ROWTYPE;
        AREC   BENEFITS_AGE_BASED%ROWTYPE;
        VOL1   NUMBER(12,2) := 0;
        UT     NUMBER(12,2) := 1;
        RT     NUMBER(12,6) := 0;
        ADMN   NUMBER(12,6) := 0;
        AGT    NUMBER(12,6) := 0;
        AGE1   NUMBER(12,6) := 0;
        AGE    NUMBER(12,6) := 0;
    BEGIN
        IF
            NVL(BTYPE,'X') = 'V'
        THEN
            SELECT
                *
            INTO
                VREC
            FROM
                BENEFITS_VOLUME_BASED
            WHERE
                BVB_CLIENT_ID = CID
                AND   BVB_PLAN_ID = PL
                AND   BVB_CLASS = CLASS1
                AND   BVB_BENEFIT = BENEFIT
                AND   BVB_EFFECTIVE_DATE = (
                    SELECT
                        MAX(BVB_EFFECTIVE_DATE)
                    FROM
                        BENEFITS_VOLUME_BASED
                    WHERE
                        BVB_CLIENT_ID = CID
                        AND   BVB_PLAN_ID = PL
                        AND   BVB_CLASS = CLASS1
                        AND   BVB_BENEFIT = BENEFIT
                        AND   BVB_EFFECTIVE_DATE <= DT
                )
                AND   BVB_TERM_DATE IS NULL;
     -- VOL1:=VREC.BVB_VOLUME;

            SELECT
                DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_MAX,0),NVL(VREC.BVB_NEM,0) ) )
            INTO
                VOL1
            FROM
                DUAL;

            RT := VREC.BVB_RATE;
            UT := VREC.BVB_UNIT;
            ADMN := VREC.BVB_ADMIN_RATE;
            AGT := VREC.BVB_AGENT_RATE;
        ELSIF NVL(BTYPE,'X') = 'D' THEN
            DS := GET_DEP_STATUS(CID,PL,ID1,BG,DT);
            SELECT
                *
            INTO
                DREC
            FROM
                BENEFITS_DEP_BASED
            WHERE
                BDB_CLIENT_ID = CID
                AND   BDB_PLAN_ID = PL
                AND   BDB_CLASS = CLASS1
                AND   BDB_BENEFIT = BENEFIT
                AND   BDB_DEP_STATUS = DS
                AND   BDB_EFF_DATE = (
                    SELECT
                        MAX(BDB_EFF_DATE)
                    FROM
                        BENEFITS_DEP_BASED
                    WHERE
                        BDB_CLIENT_ID = CID
                        AND   BDB_PLAN_ID = PL
                        AND   BDB_CLASS = CLASS1
                        AND   BDB_BENEFIT = BENEFIT
                        AND   BDB_DEP_STATUS = DS
                        AND   BDB_EFF_DATE <= DT
                )
                AND   BDB_TERM_DATE IS NULL;

            VOL1 := NULL;
            RT := DREC.BDB_RATE;
            UT := 1;
            ADMN := DREC.BDB_ADMIN_RATE;
            AGT := DREC.BDB_AGENT_RATE;
        ELSIF NVL(BTYPE,'X') = 'A' THEN
            AGE := AGE_CALC(CID,PL,DT,DOB);
            SELECT
                MIN(BAB_AGE)
            INTO
                AGE1
            FROM
                BENEFITS_AGE_BASED
            WHERE
                BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE >= AGE;
      --SELECT * INTO AREC FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL and bab_class=class1 and  BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE=(SELECT MAX(BAB_EFF_DATE) FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL AND bab_class=class1 and BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE<=DT);

            SELECT
                AVG(BAB_RATE),
                AVG(BAB_ADMIN_RATE),
                MAX(BAB_AGENT)
            INTO
                RT,ADMN,AGT
            FROM
                BENEFITS_AGE_BASED,
                TBL_MEM_VOL_BENEFITS
            WHERE
                MVB_CLIENT = CID
                AND   MVB_PLAN = PL
                AND   MVB_BENEFIT = BENEFIT
                AND   MVB_ID = ID1
                AND   BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE = AGE1
                AND   BAB_EFF_DATE = (
                    SELECT
                        MAX(BAB_EFF_DATE)
                    FROM
                        BENEFITS_AGE_BASED
                    WHERE
                        BAB_CLIENT_ID = CID
                        AND   BAB_PLAN_ID = PL
                        AND   BAB_CLASS = CLASS1
                        AND   BAB_BENEFIT = BENEFIT
                        AND   BAB_GENDER = SX
                        AND   BAB_SMOKER = SMK
                        AND   BAB_AGE = AGE1
                        AND   BAB_EFF_DATE <= DT
                )
                AND   BAB_TERM_DATE IS NULL;

            VOL1 := NULL;
            RT := AREC.BAB_RATE;
            UT := 1;
            ADMN := AREC.BAB_ADMIN_RATE;
            AGT := AREC.BAB_AGENT_RATE;
        END IF;

        RETURN NVL(RT,0);
    END;

    FUNCTION GET_ADMIN_RATE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER AS

        R      NUMBER(12,2) := 0;
        DS     VARCHAR2(1);
        VREC   BENEFITS_VOLUME_BASED%ROWTYPE;
        DREC   BENEFITS_DEP_BASED%ROWTYPE;
        AREC   BENEFITS_AGE_BASED%ROWTYPE;
        VOL1   NUMBER(12,2) := 0;
        UT     NUMBER(12,2) := 1;
        RT     NUMBER(12,6) := 0;
        ADMN   NUMBER(12,6) := 0;
        AGT    NUMBER(12,6) := 0;
        AGE1   NUMBER(12,6) := 0;
        AGE    NUMBER(12,6) := 0;
    BEGIN
        IF
            NVL(BTYPE,'X') = 'V'
        THEN
            SELECT
                *
            INTO
                VREC
            FROM
                BENEFITS_VOLUME_BASED
            WHERE
                BVB_CLIENT_ID = CID
                AND   BVB_PLAN_ID = PL
                AND   BVB_CLASS = CLASS1
                AND   BVB_BENEFIT = BENEFIT
                AND   BVB_EFFECTIVE_DATE = (
                    SELECT
                        MAX(BVB_EFFECTIVE_DATE)
                    FROM
                        BENEFITS_VOLUME_BASED
                    WHERE
                        BVB_CLIENT_ID = CID
                        AND   BVB_PLAN_ID = PL
                        AND   BVB_CLASS = CLASS1
                        AND   BVB_BENEFIT = BENEFIT
                        AND   BVB_EFFECTIVE_DATE <= DT
                )
                AND   BVB_TERM_DATE IS NULL;
      --VOL1:=VREC.BVB_VOLUME;

            SELECT
                DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_MAX,0),NVL(VREC.BVB_NEM,0) ) )
            INTO
                VOL1
            FROM
                DUAL;

            RT := VREC.BVB_RATE;
            UT := VREC.BVB_UNIT;
            ADMN := VREC.BVB_ADMIN_RATE;
            AGT := VREC.BVB_AGENT_RATE;
        ELSIF NVL(BTYPE,'X') = 'D' THEN
            DS := GET_DEP_STATUS(CID,PL,ID1,BG,DT);
            SELECT
                *
            INTO
                DREC
            FROM
                BENEFITS_DEP_BASED
            WHERE
                BDB_CLIENT_ID = CID
                AND   BDB_PLAN_ID = PL
                AND   BDB_CLASS = CLASS1
                AND   BDB_BENEFIT = BENEFIT
                AND   BDB_DEP_STATUS = DS
                AND   BDB_EFF_DATE = (
                    SELECT
                        MAX(BDB_EFF_DATE)
                    FROM
                        BENEFITS_DEP_BASED
                    WHERE
                        BDB_CLIENT_ID = CID
                        AND   BDB_PLAN_ID = PL
                        AND   BDB_CLASS = CLASS1
                        AND   BDB_BENEFIT = BENEFIT
                        AND   BDB_DEP_STATUS = DS
                        AND   BDB_EFF_DATE <= DT
                )
                AND   BDB_TERM_DATE IS NULL;

            VOL1 := NULL;
            RT := DREC.BDB_RATE;
            UT := 1;
            ADMN := DREC.BDB_ADMIN_RATE;
            AGT := DREC.BDB_AGENT_RATE;
        ELSIF NVL(BTYPE,'X') = 'A' THEN
            AGE := AGE_CALC(CID,PL,DT,DOB);
            SELECT
                MIN(BAB_AGE)
            INTO
                AGE1
            FROM
                BENEFITS_AGE_BASED
            WHERE
                BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE >= AGE;
      --SELECT * INTO AREC FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL and bab_class=class1 and  BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE=(SELECT MAX(BAB_EFF_DATE) FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL AND bab_class=class1 and BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE<=DT);

            SELECT
                AVG(BAB_RATE),
                AVG(BAB_ADMIN_RATE),
                MAX(BAB_AGENT)
            INTO
                RT,ADMN,AGT
            FROM
                BENEFITS_AGE_BASED,
                TBL_MEM_VOL_BENEFITS
            WHERE
                MVB_CLIENT = CID
                AND   MVB_PLAN = PL
                AND   MVB_BENEFIT = BENEFIT
                AND   MVB_ID = ID1
                AND   BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE = AGE1
                AND   BAB_EFF_DATE = (
                    SELECT
                        MAX(BAB_EFF_DATE)
                    FROM
                        BENEFITS_AGE_BASED
                    WHERE
                        BAB_CLIENT_ID = CID
                        AND   BAB_PLAN_ID = PL
                        AND   BAB_CLASS = CLASS1
                        AND   BAB_BENEFIT = BENEFIT
                        AND   BAB_GENDER = SX
                        AND   BAB_SMOKER = SMK
                        AND   BAB_AGE = AGE1
                        AND   BAB_EFF_DATE <= DT
                )
                AND   BAB_TERM_DATE IS NULL;

            VOL1 := NULL;
            RT := AREC.BAB_RATE;
            UT := 1;
            ADMN := AREC.BAB_ADMIN_RATE;
            AGT := AREC.BAB_AGENT_RATE;
        END IF;

        RETURN NVL(ADMN,0);
    END;

    FUNCTION GET_AGENT_RATE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER AS

        R      NUMBER(12,2) := 0;
        DS     VARCHAR2(1);
        VREC   BENEFITS_VOLUME_BASED%ROWTYPE;
        DREC   BENEFITS_DEP_BASED%ROWTYPE;
        AREC   BENEFITS_AGE_BASED%ROWTYPE;
        VOL1   NUMBER(12,2) := 0;
        UT     NUMBER(12,2) := 1;
        RT     NUMBER(12,6) := 0;
        ADMN   NUMBER(12,6) := 0;
        AGT    NUMBER(12,6) := 0;
        AGE1   NUMBER(12,6) := 0;
        AGE    NUMBER(12,6) := 0;
    BEGIN
        IF
            NVL(BTYPE,'X') = 'V'
        THEN
            SELECT
                *
            INTO
                VREC
            FROM
                BENEFITS_VOLUME_BASED
            WHERE
                BVB_CLIENT_ID = CID
                AND   BVB_PLAN_ID = PL
                AND   BVB_CLASS = CLASS1
                AND   BVB_BENEFIT = BENEFIT
                AND   BVB_EFFECTIVE_DATE = (
                    SELECT
                        MAX(BVB_EFFECTIVE_DATE)
                    FROM
                        BENEFITS_VOLUME_BASED
                    WHERE
                        BVB_CLIENT_ID = CID
                        AND   BVB_PLAN_ID = PL
                        AND   BVB_CLASS = CLASS1
                        AND   BVB_BENEFIT = BENEFIT
                        AND   BVB_EFFECTIVE_DATE <= DT
                )
                AND   BVB_TERM_DATE IS NULL;
     -- VOL1:=VREC.BVB_VOLUME;

            SELECT
                DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_NEM,0),DECODE(NVL(VREC.BVB_VOLUME,0),0,NVL(VREC.BVB_MAX,0),NVL(VREC.BVB_NEM,0) ) )
            INTO
                VOL1
            FROM
                DUAL;

            RT := VREC.BVB_RATE;
            UT := VREC.BVB_UNIT;
            ADMN := VREC.BVB_ADMIN_RATE;
            AGT := VREC.BVB_AGENT_RATE;
        ELSIF NVL(BTYPE,'X') = 'D' THEN
            DS := GET_DEP_STATUS(CID,PL,ID1,BG,DT);
            SELECT
                *
            INTO
                DREC
            FROM
                BENEFITS_DEP_BASED
            WHERE
                BDB_CLIENT_ID = CID
                AND   BDB_PLAN_ID = PL
                AND   BDB_CLASS = CLASS1
                AND   BDB_BENEFIT = BENEFIT
                AND   BDB_DEP_STATUS = DS
                AND   BDB_EFF_DATE = (
                    SELECT
                        MAX(BDB_EFF_DATE)
                    FROM
                        BENEFITS_DEP_BASED
                    WHERE
                        BDB_CLIENT_ID = CID
                        AND   BDB_PLAN_ID = PL
                        AND   BDB_CLASS = CLASS1
                        AND   BDB_BENEFIT = BENEFIT
                        AND   BDB_DEP_STATUS = DS
                        AND   BDB_EFF_DATE <= DT
                )
                AND   BDB_TERM_DATE IS NULL;

            VOL1 := NULL;
            RT := DREC.BDB_RATE;
            UT := 1;
            ADMN := DREC.BDB_ADMIN_RATE;
            AGT := DREC.BDB_AGENT_RATE;
        ELSIF NVL(BTYPE,'X') = 'A' THEN
            AGE := AGE_CALC(CID,PL,DT,DOB);
            SELECT
                MIN(BAB_AGE)
            INTO
                AGE1
            FROM
                BENEFITS_AGE_BASED
            WHERE
                BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE >= AGE;
      --SELECT * INTO AREC FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL and bab_class=class1 and  BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE=(SELECT MAX(BAB_EFF_DATE) FROM BENEFITS_AGE_BASED WHERE BAB_CLIENT_ID=CID AND BAB_PLAN_ID=PL AND bab_class=class1 and BAB_BENEFIT=BENEFIT AND BAB_GENDER=SX AND BAB_SMOKER=SMK AND BAB_AGE=AGE1 AND  BAB_EFF_DATE<=DT);

            SELECT
                AVG(BAB_RATE),
                AVG(BAB_ADMIN_RATE),
                MAX(BAB_AGENT)
            INTO
                RT,ADMN,AGT
            FROM
                BENEFITS_AGE_BASED,
                TBL_MEM_VOL_BENEFITS
            WHERE
                MVB_CLIENT = CID
                AND   MVB_PLAN = PL
                AND   MVB_BENEFIT = BENEFIT
                AND   MVB_ID = ID1
                AND   BAB_CLIENT_ID = CID
                AND   BAB_PLAN_ID = PL
                AND   BAB_CLASS = CLASS1
                AND   BAB_BENEFIT = BENEFIT
                AND   BAB_GENDER = SX
                AND   BAB_SMOKER = SMK
                AND   BAB_AGE = AGE1
                AND   BAB_EFF_DATE = (
                    SELECT
                        MAX(BAB_EFF_DATE)
                    FROM
                        BENEFITS_AGE_BASED
                    WHERE
                        BAB_CLIENT_ID = CID
                        AND   BAB_PLAN_ID = PL
                        AND   BAB_CLASS = CLASS1
                        AND   BAB_BENEFIT = BENEFIT
                        AND   BAB_GENDER = SX
                        AND   BAB_SMOKER = SMK
                        AND   BAB_AGE = AGE1
                        AND   BAB_EFF_DATE <= DT
                )
                AND   BAB_TERM_DATE IS NULL;

            VOL1 := NULL;
            RT := AREC.BAB_RATE;
            UT := 1;
            ADMN := AREC.BAB_ADMIN_RATE;
            AGT := AREC.BAB_AGENT_RATE;
        END IF;

        RETURN NVL(AGT,0);
    END;

    PROCEDURE GB_ADJ (
        CID               VARCHAR2,
        PL                VARCHAR2,
        ID1               VARCHAR2,
        SX                VARCHAR2,
        DOB               DATE,
        OLD_SMK           VARCHAR2,
        NEW_SMK           VARCHAR2,
        OLD_SMK_DATE      DATE,
        NEW_SMK_DATE      DATE,
        OLD_CLASS         VARCHAR2,
        NEW_CLASS         VARCHAR2,
        OLD_DEP_STATUS    VARCHAR2,
        NEW_DEP_STATUS    VARCHAR2,
        OLD_DS_DATE       DATE,
        NEW_DS_DATE       DATE,
        OLD_SALARY_DATE   DATE,
        NEW_SALARY_DATE   DATE,
        OLD_SALARY        NUMBER,
        NEW_SALARY        NUMBER,
        EDATE             DATE,
        TDATE             DATE,
        BD                DATE
    ) AS

        ST_DATE    DATE;
        END_DATE   DATE;
        DIFF_SAL   NUMBER(12,2) := 0;
        FLAG       VARCHAR2(1);
    BEGIN
        IF
            OLD_SALARY_DATE IS NULL AND OLD_DS_DATE IS NULL AND EDATE IS NOT NULL AND TDATE IS NULL AND TRUNC(EDATE) < TRUNC(BD)
        THEN
    -- RETRO_ENROLL;
            FLAG := NULL;
            ST_DATE := TRUNC(EDATE,'MM');
            END_DATE := BD;
            DELETE FROM MEMBER_BENEFITS_ADJ_TEMP
            WHERE
                CLIENT_ID = CID
                AND   PLAN_ID = PL
                AND   MEM_ID = ID1;

            LOOP
                IF
                    ST_DATE >= END_DATE
                THEN
                    EXIT;
                END IF;
                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL) COVERGAE,
                        GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP,
NULL,NULL,NULL,NULL,NULL) BEN_BILL,
                        HW_SMOKER,
                        GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                ST_DATE := ADD_MONTHS(ST_DATE,1);
            END LOOP;

        ELSIF OLD_SALARY_DATE IS NULL AND OLD_DS_DATE IS NULL AND TDATE IS NOT NULL AND TRUNC(TDATE) < TRUNC(BD) THEN
    --RETRO_TERM;
            FLAG := NULL;
            ST_DATE := TRUNC(TDATE,'MM');
            END_DATE := BD;
            DELETE FROM MEMBER_BENEFITS_ADJ_TEMP
            WHERE
                CLIENT_ID = CID
                AND   PLAN_ID = PL
                AND   MEM_ID = ID1;

            LOOP
                IF
                    ST_DATE >= END_DATE
                THEN
                    EXIT;
                END IF;
                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL) COVERGAE,
                        -1 * GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL) BEN_BILL,
                        HW_SMOKER,
                        -1 * GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        -1 * GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        -1 * GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                ST_DATE := ADD_MONTHS(ST_DATE,1);
            END LOOP;

            NULL;
        ELSIF ( OLD_SALARY_DATE IS NULL AND NEW_SALARY_DATE IS NOT NULL AND NEW_SALARY_DATE < BD ) OR ( OLD_SALARY_DATE IS NOT NULL AND NEW_SALARY_DATE IS NOT NULL
AND TRUNC(OLD_SALARY_DATE) <> TRUNC(NEW_SALARY_DATE) ) THEN
    --SALARY CHANGE;
            FLAG := 'V';
            ST_DATE := TRUNC(NEW_SALARY_DATE,'MM');
            END_DATE := BD;
            DIFF_SAL := NVL(NEW_SALARY,0) - NVL(OLD_SALARY,0);
            DELETE FROM MEMBER_BENEFITS_ADJ_TEMP
            WHERE
                CLIENT_ID = CID
                AND   PLAN_ID = PL
                AND   MEM_ID = ID1
                AND   BM_BEN_TYPE = 'V';

            LOOP
                IF
                    ST_DATE >= END_DATE
                THEN
                    EXIT;
                END IF;
                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,DIFF_SAL,NULL,NULL,NULL) COVERGAE,
                        GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP,
NULL,DIFF_SAL,NULL,NULL,NULL) BEN_BILL,
                        HW_SMOKER,
                        GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,DIFF_SAL,NULL,NULL,NULL),
                        GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,DIFF_SAL,NULL,NULL,NULL),
                        GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NULL,DIFF_SAL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        BM_BEN_TYPE = 'V'
                        AND   MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                ST_DATE := ADD_MONTHS(ST_DATE,1);
            END LOOP;

            NULL;
        ELSIF ( OLD_DS_DATE IS NULL AND NEW_DS_DATE IS NOT NULL AND NEW_DS_DATE < BD ) OR ( OLD_DS_DATE IS NOT NULL AND NEW_DS_DATE IS NOT NULL AND TRUNC(OLD_DS_DATE
) <> TRUNC(NEW_DS_DATE) ) THEN
    --DEP_STAT_CHANGE;
            FLAG := 'D';
            ST_DATE := TRUNC(NEW_DS_DATE,'MM');
            END_DATE := BD;
            DELETE FROM MEMBER_BENEFITS_ADJ_TEMP
            WHERE
                CLIENT_ID = CID
                AND   PLAN_ID = PL
                AND   MEM_ID = ID1
                AND   BM_BEN_TYPE = 'D';

            LOOP
                IF
                    ST_DATE >= END_DATE
                THEN
                    EXIT;
                END IF;
                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,OLD_DEP_STATUS,NULL,NULL,NULL,NULL) COVERGAE,
                        -1 * GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,OLD_DEP_STATUS,NULL,NULL,NULL,NULL) BEN_BILL,
                        HW_SMOKER,
                        -1 * GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,OLD_DEP_STATUS,NULL,NULL,NULL,NULL),
                        -1 * GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,OLD_DEP_STATUS,NULL,NULL,NULL,NULL),
                        -1 * GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,OLD_DEP_STATUS,NULL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        BM_BEN_TYPE = 'D'
                        AND   MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NEW_DEP_STATUS,NULL,NULL,NULL,NULL) COVERGAE,
                        GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP,
NEW_DEP_STATUS,NULL,NULL,NULL,NULL) BEN_BILL,
                        HW_SMOKER,
                        GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NEW_DEP_STATUS,NULL,NULL,NULL,NULL),
                        GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NEW_DEP_STATUS,NULL,NULL,NULL,NULL),
                        GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,HW_SMOKER,HW_CLASS,BM_BEN_GROUP
,NEW_DEP_STATUS,NULL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        BM_BEN_TYPE = 'D'
                        AND   MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                ST_DATE := ADD_MONTHS(ST_DATE,1);
            END LOOP;

        ELSIF NVL(OLD_SMK,'X') <> NVL(NEW_SMK,'X') AND NVL(NEW_SMK_DATE,BD) < BD THEN
     ---SMOKER CHANGE
            FLAG := 'A';
            ST_DATE := TRUNC(NEW_SMK_DATE,'MM');
            END_DATE := BD;
            DELETE FROM MEMBER_BENEFITS_ADJ_TEMP
            WHERE
                CLIENT_ID = CID
                AND   PLAN_ID = PL
                AND   MEM_ID = ID1
                AND   BM_BEN_TYPE = 'A';

            LOOP
                IF
                    ST_DATE >= END_DATE
                THEN
                    EXIT;
                END IF;
                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,OLD_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL) COVERGAE,
                        -1 * GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,OLD_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL) BEN_BILL,
                        OLD_SMK,
                        -1 * GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,OLD_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        -1 * GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,OLD_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        -1 * GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,OLD_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        BM_BEN_TYPE = 'A'
                        AND   MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                INSERT INTO MEMBER_BENEFITS_ADJ_TEMP (
                    BM_BEN_GROUP,
                    EMPLOYER,
                    BM_BEN_TYPE,
                    CLIENT_ID,
                    PLAN_ID,
                    MEM_ID,
                    BEN_CLASS,
                    CODE,
                    BENDESC,
                    MEM_LAST_NAME,
                    MEM_FIRST_NAME,
                    MEM_DOB,
                    MEM_GENDER,
                    COVERGAE,
                    BEN_BILL,
                    HW_SMOKER,
                    CARRIER_RATE,
                    ADMIN_RATE,
                    AGENT_RATE,
                    MEM_SALARY,
                    MEM_DEP_STATUS,
                    MEM_EFF_DATE,
                    MEM_TERM_DATE,
                    BILLING_DATE,
                    MEM_CLASS
                )
                    ( SELECT
                        BM_BEN_GROUP,
                        HR_BANK_PKG.GET_EMPLOYER(CLIENTID,PLANID,HW_ID,ST_DATE) EMPLOYER,
                        BM_BEN_TYPE,
                        CLIENTID CLIENT_ID,
                        PLANID PLAN_ID,
                        HW_ID MEM_ID,
                        CLASSID BEN_CLASS,
                        BENEFITID CODE,
                        BENDESC,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_DOB,
                        MEM_GENDER,
                        GB_PKG.GET_BEN_COVERAGE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,NEW_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL) COVERGAE,
                        GB_PKG.GET_BILL(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,NEW_SMK,HW_CLASS,BM_BEN_GROUP,NULL
,NULL,NULL,NULL,NULL) BEN_BILL,
                        HW_SMOKER,
                        GB_PKG.GET_CARRIER_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,NEW_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        GB_PKG.GET_ADMIN_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,NEW_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        GB_PKG.GET_AGENT_RATE(HW_CLIENT,HW_PLAN,HW_ID,BM_BEN_TYPE,BENEFITID,BENDESC,ST_DATE,MEM_GENDER,MEM_DOB,NEW_SMK,HW_CLASS,BM_BEN_GROUP
,NULL,NULL,NULL,NULL,NULL),
                        NULL,
                        NULL,
                        ST_DATE,
                        NULL,
                        BD,
                        HW_CLASS
                      FROM
                        VW_CLASS_BENEFITS,
                        TBL_HW,
                        TBL_MEMBER
                      WHERE
                        BM_BEN_TYPE = 'A'
                        AND   MEM_CLIENT_ID = CID
                        AND   MEM_PLAN = PL
                        AND   MEM_ID = ID1
                        AND   MEM_CLIENT_ID = HW_CLIENT
                        AND   MEM_CLIENT_ID = CLIENTID
                        AND   MEM_PLAN = HW_PLAN
                        AND   MEM_PLAN = PLANID
                        AND   MEM_ID = HW_ID
                        AND   HW_CLASS = CLASSID
                    );

                ST_DATE := ADD_MONTHS(ST_DATE,1);
            END LOOP;

        END IF;

        INSERT INTO MEMBER_BENEFITS_ADJ (
            BM_BEN_GROUP,
            EMPLOYER,
            BM_BEN_TYPE,
            CLIENT_ID,
            PLAN_ID,
            MEM_ID,
            BEN_CLASS,
            CODE,
            BENDESC,
            MEM_LAST_NAME,
            MEM_FIRST_NAME,
            MEM_DOB,
            MEM_GENDER,
            COVERGAE,
            BEN_BILL,
            HW_SMOKER,
            CARRIER_RATE,
            ADMIN_RATE,
            AGENT_RATE,
            MEM_SALARY,
            MEM_DEP_STATUS,
            MEM_EFF_DATE,
            MEM_TERM_DATE,
            BILLING_DATE,
            MEM_CLASS
        )
            ( SELECT
                BM_BEN_GROUP,
                EMPLOYER,
                BM_BEN_TYPE,
                CLIENT_ID,
                PLAN_ID,
                MEM_ID,
                BEN_CLASS,
                CODE,
                BENDESC,
                MEM_LAST_NAME,
                MEM_FIRST_NAME,
                MEM_DOB,
                MEM_GENDER,
                MAX(COVERGAE),
                SUM(BEN_BILL),
                MAX(NVL(NEW_SMK,HW_SMOKER) ),
                AVG(CARRIER_RATE),
                AVG(ADMIN_RATE),
                AVG(AGENT_RATE),
                MAX(NVL(NEW_SALARY,MEM_SALARY) ),
                MAX(NVL(NEW_DEP_STATUS,MEM_DEP_STATUS) ),
                MAX(EDATE),
                MAX(MEM_TERM_DATE),
                BILLING_DATE,
                MAX(NVL(NEW_CLASS,MEM_CLASS) )
              FROM
                MEMBER_BENEFITS_ADJ_TEMP
              WHERE
                CLIENT_ID = CID
                AND   PLAN_ID = PL
                AND   MEM_ID = ID1
                AND   NVL(BM_BEN_TYPE,'%') LIKE NVL(FLAG,'%')
              GROUP BY
                BM_BEN_GROUP,
                EMPLOYER,
                BM_BEN_TYPE,
                CLIENT_ID,
                PLAN_ID,
                MEM_ID,
                BEN_CLASS,
                CODE,
                BENDESC,
                MEM_LAST_NAME,
                MEM_FIRST_NAME,
                MEM_DOB,
                MEM_GENDER,
                BILLING_DATE
            );

        NULL;
    END;

END GB_PKG_200418;
/

