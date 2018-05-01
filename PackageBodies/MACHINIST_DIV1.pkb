--
-- MACHINIST_DIV1  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.MACHINIST_DIV1 AS

    FUNCTION STANDARD_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER AS

        R          NUMBER(12,2) := 0;
        IR         NUMBER(12,6) := 0;
        YR         NUMBER;
        ST         VARCHAR2(10);
        NRD        DATE;
        DEF_YRS    NUMBER;
        DEF_MTHS   NUMBER;
        AGE        NUMBER(12,6) := 0;
    BEGIN
        SELECT
            MAX(PENM_STATUS)
        INTO
            ST
        FROM
            TBL_PENMAST
        WHERE
            PENM_CLIENT = CLTID
            AND   PENM_PLAN = PLID
            AND   PENM_ID = MEMID;
    -- IF NVL(ST,'X') NOT IN ('A','C','VP') THEN
    -- R:=0;
    -- ELSE

        IF
            TO_NUMBER(TO_CHAR(DT,'RRRR') ) <= 2010
        THEN
            SELECT
                SUM(NVL(ANN_ER_CONTS,0) + NVL(ER_INT,0) )
            INTO
                R
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = CLTID
                AND   ANN_PLAN = PLID
                AND   ANN_ID = MEMID
                AND   ANN_YEAR <= TO_NUMBER(TO_CHAR(DT,'RRRR') );

        ELSE
            BEGIN
                SELECT
                    NVL(SUM(NVL(ANN_ER_CONTS,0) + NVL(ER_INT,0) ),0)
                INTO
                    R
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR <= 2010;

                YR := 2011;
                LOOP
                    IF
                        YR > TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    THEN
                        EXIT;
                    END IF;
                    SELECT
                        NVL(MAX(EIR_RATE),0)
                    INTO
                        IR
                    FROM
                        CONT_INT_RATES
                    WHERE
                        EIR_CLIENT = CLTID
                        AND   EIR_PLAN = PLID
                        AND   TRUNC(EIR_EFF_DATE) = TO_DATE('01-JAN-'
                        || TO_CHAR(YR),'DD-MON-RRRR');

                    R := ( NVL(R,0) * ( 1 + ( NVL(IR,0) / 100 ) ) );

                    YR := YR + 1;
                END LOOP;

            END;
        END IF;

        IF
            NVL(INT_PCT_INC,0) <> 0
        THEN
            IF
                DOB IS NOT NULL AND DOB < SYSDATE
            THEN
                NRD := ADD_MONTHS(LAST_DAY(DOB - 1) + 1,65 * 12);

                AGE := ( NRD - DOB ) / 365.25;
                DEF_YRS := TRUNC( (NRD - DT) / 365.25,0);
                DEF_MTHS := ( ROUND( ( (NRD - DT) / 365.25 - DEF_YRS) * 12,0) );

                IF
                    NRD <= DT + 1
                THEN
                    DEF_YRS := 0;
                    DEF_MTHS := 0;
                END IF;

                IF
                    NVL(DEF_YRS,0) < 0
                THEN
                    DEF_YRS := 0;
                END IF;
                IF
                    NVL(DEF_MTHS,0) < 0
                THEN
                    DEF_MTHS := 0;
                END IF;
            END IF;

            IF
                NVL(DEF_YRS,0) + NVL(DEF_MTHS,0) > 0
            THEN
                R := ROUND(R * POWER( ( (1 + (NVL(INT_PCT_INC,0) / 100) ) ), (DEF_YRS + (DEF_MTHS / 12) ) ),2);

            END IF;

        END IF;
    -- END IF;

        RETURN NVL(R,0);
    END STANDARD_ACCOUNT;

    FUNCTION STANDARD_ACCOUNT_PENSION (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER IS

        SA           NUMBER(12,2) := 0;
        R            NUMBER(12,2) := 0;
        PP           NUMBER(12,2) := 0;
        ST           VARCHAR2(20);
        TOTCONTS     NUMBER(12,2) := 0;
        TOTCONTS1    NUMBER(12,2) := 0;
        DEF_YRS      NUMBER;
        DEF_MTHS     NUMBER;
        CURR_CONTS   NUMBER(12,2) := 0;
        NRD          DATE;
        AGE          NUMBER(12,6) := 0;
    BEGIN
        IF
            DOB IS NOT NULL AND DOB < SYSDATE
        THEN
            IF
                DOB IS NOT NULL AND DOB < SYSDATE
            THEN
                NRD := ADD_MONTHS(LAST_DAY(DOB - 1) + 1,65 * 12);

                AGE := ( NRD - DOB ) / 365.25;
                DEF_YRS := TRUNC( (NRD - DT) / 365.25,0);
                DEF_MTHS := ( ROUND( ( (NRD - DT) / 365.25 - DEF_YRS) * 12,0) );

            END IF;

            IF
                NRD <= DT + 1
            THEN
                DEF_YRS := 0;
                DEF_MTHS := 0;
            END IF;

            SELECT
                NVL(MAX(PENM_STATUS),'X'),
                NVL(SUM(PENM_PAST_PENSION),0)
            INTO
                ST,PP
            FROM
                TBL_PENMAST
            WHERE
                PENM_CLIENT = CLTID
                AND   PENM_PLAN = PLID
                AND   PENM_ID = MEMID;
      --IF ST IN ('A','C','VP','T') THEN

            SA := STANDARD_ACCOUNT(CLTID,PLID,MEMID,DT,PROJ_PCT_INC,INT_PCT_INC,STOP_WORKING,DOB);

            R := GREATEST(PP,NVL(SA,0) / (14.0850 * 12) );

            SELECT
                NVL(ROUND(SUM(NVL(ANN_EE_CONTS,0) + NVL(ANN_VOL_UNITS,0) + NVL(EE_INT,0) + NVL(VOL_INT,0) ),2),0)
            INTO
                TOTCONTS
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = CLTID
                AND   ANN_PLAN = PLID
                AND   ANN_ID = MEMID
                AND   ANN_YEAR <= TO_NUMBER(TO_CHAR(DT,'RRRR') );

            SELECT
                NVL(ROUND(SUM(NVL(ANN_EE_CONTS,0) + NVL(ANN_VOL_UNITS,0) + NVL(ANN_ER_CONTS,0) ),2),0)
            INTO
                CURR_CONTS
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = CLTID
                AND   ANN_PLAN = PLID
                AND   ANN_ID = MEMID
                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(DT,'RRRR') );
      /*
      IF NVL(STOP_WORKING,'N')='N' THEN
      if nvl(def_yrs,0)+nvl(def_mths,0)<>0 then
      TOTCONTS:=NVL(TOTCONTS,0)+(NVL(CURR_CONTS,0)*(NVL(DEF_YRS,0)+(NVL(DEF_MTHS,0))/12));
      end if;
      */
      --  IF NVL(STOP_WORKING,'N')='Y' THEN

            TOTCONTS := NVL(TOTCONTS,0) + NVL(SUPP_ACCOUNT(CLTID,PLID,MEMID,DT,PROJ_PCT_INC,INT_PCT_INC,STOP_WORKING,DOB),0);

            IF
                NVL(INT_PCT_INC,0) <> 0
            THEN
                TOTCONTS := ROUND(NVL(TOTCONTS,0) * POWER( ( (1 + (NVL(INT_PCT_INC,0) / 100) ) ), (DEF_YRS + (DEF_MTHS / 12) ) ),2);
            END IF;
      -- ELSE
      -- NULL;
      -- END IF;
      -- END IF;
      --DBMS_OUTPUT.PUT_LINE(TOTCONTS||' '||SA);

            R := ROUND( (1 + (NVL(PROJ_PCT_INC,0) / 100) ) * (NVL(R,0) + (NVL(TOTCONTS,0) / 12 / 14.0850) ),2);
      --ELSE
      --  R:=0;
      --END IF;

        ELSE
            R := 0;
        END IF;

        RETURN R;
    END;

    FUNCTION SUPP_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER IS

        R              NUMBER(12,2) := 0;
        CURR_CONTS     NUMBER(12,2) := 0;
        LATEST_CONTS   NUMBER(12,2) := 0;
        IR             NUMBER(12,6) := 0;
        YR             NUMBER;
        YR1            NUMBER;
        R1             NUMBER(12,2) := 0;
        ST             VARCHAR2(10);
        NRD            DATE;
        DEF_YRS        NUMBER;
        DEF_MTHS       NUMBER;
        AGE            NUMBER(12,6) := 0;
    BEGIN
        SELECT
            MAX(PENM_STATUS)
        INTO
            ST
        FROM
            TBL_PENMAST
        WHERE
            PENM_CLIENT = CLTID
            AND   PENM_PLAN = PLID
            AND   PENM_ID = MEMID;

        IF
            TO_NUMBER(TO_CHAR(DT,'RRRR') ) <= 2010
        THEN
            R := 0;
        ELSE
            BEGIN
                SELECT
                    NVL(MIN(ANN_YEAR),TO_NUMBER(TO_CHAR(DT,'RRRR') ) )
                INTO
                    YR1
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR >= 2011
                    AND   ANN_YEAR <= TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    AND   NVL(ANN_ER_CONTS,0) > 0;

                SELECT
                    NVL(SUM(NVL(ANN_ER_CONTS,0) ),0)
                INTO
                    R
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR = YR1;

                YR := YR1;
                LOOP
                    IF
                        YR > TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    THEN
                        EXIT;
                    END IF;
                    SELECT
                        NVL(MAX(EIR_RATE),0)
                    INTO
                        IR
                    FROM
                        CONT_INT_RATES
                    WHERE
                        EIR_CLIENT = CLTID
                        AND   EIR_PLAN = PLID
                        AND   TRUNC(EIR_EFF_DATE) = TO_DATE('01-JAN-'
                        || TO_CHAR(YR),'DD-MON-RRRR');

                    IF
                        YR = YR1
                    THEN
                        R := R + ( NVL(R,0) * ( ( ( NVL(IR / 2,0) / 100 ) ) ) );
                    ELSE
                        SELECT
                            NVL(SUM(NVL(ANN_ER_CONTS,0) ),0)
                        INTO
                            CURR_CONTS
                        FROM
                            TBL_ANNUAL
                        WHERE
                            ANN_CLIENT = CLTID
                            AND   ANN_PLAN = PLID
                            AND   ANN_ID = MEMID
                            AND   ANN_YEAR = YR;

                        R := R + ( NVL(R,0) * ( ( NVL(IR,0) / 100 ) ) ) + ( NVL(CURR_CONTS,0) * ( 1 + ( ( NVL(IR / 2,0) / 100 ) ) ) );

                    END IF;

                    YR := YR + 1;
                END LOOP;

            END;
        END IF;

        IF
            DOB IS NOT NULL AND DOB < SYSDATE
        THEN
            NRD := ADD_MONTHS(LAST_DAY(DOB - 1) + 1,65 * 12);

            AGE := ( NRD - DOB ) / 365.25;
            DEF_YRS := TRUNC( (NRD - DT) / 365.25,0);
            DEF_MTHS := ( ROUND( ( (NRD - DT) / 365.25 - DEF_YRS) * 12,0) );

            IF
                NRD <= DT + 1
            THEN
                DEF_YRS := 0;
                DEF_MTHS := 0;
            END IF;

        END IF;

        IF
            NVL(INT_PCT_INC,0) <> 0 AND NVL(STOP_WORKING,'N') = 'Y'
        THEN
            IF
                DEF_YRS > 0 OR ( NVL(DEF_YRS,0) = 0 AND NVL(DEF_MTHS,0) > 0 )
            THEN
                R := ROUND(R * POWER( ( (1 + (NVL(INT_PCT_INC,0) / 100) ) ), (DEF_YRS + (DEF_MTHS / 12) ) ),2);

            END IF;
        END IF;

        IF
            NVL(STOP_WORKING,'N') = 'N' AND NVL(DEF_YRS,0) + NVL(DEF_MTHS,0) > 0 AND NVL(R,0) <> 0
        THEN
            SELECT
                NVL(SUM(NVL(ANN_ER_CONTS,0) ),0)
            INTO
                LATEST_CONTS
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = CLTID
                AND   ANN_PLAN = PLID
                AND   ANN_ID = MEMID
                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(DT,'rrrr') );
        -- R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+(DEF_MTHS/12)))+(NVL(LATEST_CONTS,0))*(DEF_YRS+(DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+(DEF_MTHS/12))/2)),2);
           ---R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12))+((NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);
         --  R:=ROUND(R*POWER((1+(NVL(INT_PCT_INC,0)/100)),(DEF_YRS+(DEF_MTHS/12)))+(NVL(LATEST_CONTS,0))*(DEF_YRS+(DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+(DEF_MTHS/12))/2)),2);
       --  R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),(DEF_YRS+DEF_MTHS/12)))+((LATEST_CONTS)*(DEF_YRS+DEF_MTHS/12))*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+DEF_MTHS/12)/2)),2);
       --SELECT       ROUND((19622.40*POWER((1+(6/100)),(18+4/12)))+((6836.21+1680.48+3461.42)*(18+4/12)*POWER((1+(6/100)),((18+4/12)/2))),2) FROM DUAL;

              --R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+DEF_MTHS)/12)))+((LATEST_CONTS)*((DEF_YRS+DEF_MTHS)/12)*POWER((1+(INT_PCT_INC/100)),(((DEF_YRS+DEF_MTHS)/12)/2))),2);

            R := ROUND( (R * POWER( (1 + (INT_PCT_INC / 100) ), (DEF_YRS + DEF_MTHS / 12) ) ) + ( (LATEST_CONTS) * (DEF_YRS + DEF_MTHS / 12) * POWER( (1 + (INT_PCT_INC / 100) )
, ( (DEF_YRS + DEF_MTHS / 12) / 2) ) ),2);

            NULL;
        END IF;

        RETURN R;
    END;

    FUNCTION VOL_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER IS

        R              NUMBER(12,2) := 0;
        CURR_CONTS     NUMBER(12,2) := 0;
        LATEST_CONTS   NUMBER(12,2) := 0;
        IR             NUMBER(12,6) := 0;
        YR             NUMBER;
        YR1            NUMBER;
        R1             NUMBER(12,2) := 0;
        ST             VARCHAR2(10);
        NRD            DATE;
        DEF_YRS        NUMBER;
        DEF_MTHS       NUMBER;
        AGE            NUMBER(12,6) := 0;
    BEGIN
        SELECT
            MAX(PENM_STATUS)
        INTO
            ST
        FROM
            TBL_PENMAST
        WHERE
            PENM_CLIENT = CLTID
            AND   PENM_PLAN = PLID
            AND   PENM_ID = MEMID;

        IF
            TO_NUMBER(TO_CHAR(DT,'RRRR') ) <= 2010
        THEN
            R := 0;
        ELSE
            BEGIN
                SELECT
                    NVL(MIN(ANN_YEAR),TO_NUMBER(TO_CHAR(DT,'RRRR') ) )
                INTO
                    YR1
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR <= TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    AND   NVL(ANN_VOL_UNITS,0) > 0;

                SELECT
                    NVL(SUM(NVL(ANN_VOL_UNITS,0) ),0)
                INTO
                    R
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR = YR1;

                YR := YR1;
                LOOP
                    IF
                        YR > TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    THEN
                        EXIT;
                    END IF;
                    SELECT
                        NVL(MAX(EIR_RATE),0)
                    INTO
                        IR
                    FROM
                        CONT_INT_RATES
                    WHERE
                        EIR_CLIENT = CLTID
                        AND   EIR_PLAN = PLID
                        AND   TRUNC(EIR_EFF_DATE) = TO_DATE('01-JAN-'
                        || TO_CHAR(YR),'DD-MON-RRRR');

                    IF
                        YR = YR1
                    THEN
                        R := ( NVL(R,0) * ( 1 + ( ( NVL(IR / 2,0) / 100 ) ) ) );
                    ELSE
                        SELECT
                            NVL(SUM(NVL(ANN_VOL_UNITS,0) ),0)
                        INTO
                            CURR_CONTS
                        FROM
                            TBL_ANNUAL
                        WHERE
                            ANN_CLIENT = CLTID
                            AND   ANN_PLAN = PLID
                            AND   ANN_ID = MEMID
                            AND   ANN_YEAR = YR;

                        R := ( NVL(R,0) * ( 1 + ( NVL(IR,0) / 100 ) ) ) + ( NVL(CURR_CONTS,0) * ( 1 + ( ( NVL(IR / 2,0) / 100 ) ) ) );

                    END IF;

                    YR := YR + 1;
                END LOOP;

            END;
        END IF;

        IF
            DOB IS NOT NULL AND DOB < SYSDATE
        THEN
            NRD := ADD_MONTHS(LAST_DAY(DOB - 1) + 1,65 * 12);

            AGE := ( NRD - DOB ) / 365.25;
            DEF_YRS := TRUNC( (NRD - DT) / 365.25,0);
            DEF_MTHS := ( ROUND( ( (NRD - DT) / 365.25 - DEF_YRS) * 12,0) );

            IF
                NRD <= DT + 1
            THEN
                DEF_YRS := 0;
                DEF_MTHS := 0;
            END IF;

        END IF;

        IF
            NVL(INT_PCT_INC,0) <> 0 AND NVL(STOP_WORKING,'N') = 'Y'
        THEN
            IF
                DEF_YRS > 0 OR ( NVL(DEF_YRS,0) = 0 AND NVL(DEF_MTHS,0) > 0 )
            THEN
                R := ROUND(R * POWER( ( (1 + (NVL(INT_PCT_INC,0) / 100) ) ), (DEF_YRS + (DEF_MTHS / 12) ) ),2);

            END IF;
        END IF;

        IF
            NVL(STOP_WORKING,'N') = 'N' AND NVL(DEF_YRS,0) + NVL(DEF_MTHS,0) > 0 AND NVL(R,0) <> 0
        THEN
            SELECT
                NVL(SUM(NVL(ANN_VOL_UNITS,0) ),0)
            INTO
                LATEST_CONTS
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = CLTID
                AND   ANN_PLAN = PLID
                AND   ANN_ID = MEMID
                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(DT,'rrrr') );
        -- R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+(DEF_MTHS/12)))+(NVL(LATEST_CONTS,0))*(DEF_YRS+(DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+(DEF_MTHS/12))/2)),2);
          -- R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12))+((NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);
           --R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12))+(NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12)*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);
           
          -- R:=ROUND(R*POWER((1+(NVL(INT_PCT_INC,0)/100)),(DEF_YRS+DEF_MTHS/12))+(NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12)*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);
         -- R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),(DEF_YRS+DEF_MTHS/12)))+((LATEST_CONTS)*(DEF_YRS+DEF_MTHS/12))*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+DEF_MTHS/12)/2)),2);
              --  R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),(DEF_YRS+(DEF_MTHS/12))))+((LATEST_CONTS)*(DEF_YRS+(DEF_MTHS/12))*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+(DEF_MTHS/12))/2))),2);
               --  R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+DEF_MTHS)/12)))+((LATEST_CONTS)*((DEF_YRS+DEF_MTHS)/12)*POWER((1+(INT_PCT_INC/100)),(((DEF_YRS+DEF_MTHS)/12)/2))),2);

            R := ROUND( (R * POWER( (1 + (INT_PCT_INC / 100) ), (DEF_YRS + DEF_MTHS / 12) ) ) + ( (LATEST_CONTS) * (DEF_YRS + DEF_MTHS / 12) * POWER( (1 + (INT_PCT_INC / 100) )
, ( (DEF_YRS + DEF_MTHS / 12) / 2) ) ),2);

            NULL;
        END IF;

        RETURN R;
    END;

    FUNCTION MEM_REQD_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER IS

        R              NUMBER(12,2) := 0;
        CURR_CONTS     NUMBER(12,2) := 0;
        LATEST_CONTS   NUMBER(12,2) := 0;
        IR             NUMBER(12,6) := 0;
        YR             NUMBER;
        R1             NUMBER(12,2) := 0;
        YR1            NUMBER;
        ST             VARCHAR2(10);
        NRD            DATE;
        DEF_YRS        NUMBER;
        AGE            NUMBER(12,6) := 0;
        DEF_MTHS       NUMBER;
    BEGIN
        SELECT
            MAX(PENM_STATUS)
        INTO
            ST
        FROM
            TBL_PENMAST
        WHERE
            PENM_CLIENT = CLTID
            AND   PENM_PLAN = PLID
            AND   PENM_ID = MEMID;

        IF
            TO_NUMBER(TO_CHAR(DT,'RRRR') ) <= 2010
        THEN
            R := 0;
        ELSE
            BEGIN
                SELECT
                    NVL(MIN(ANN_YEAR),TO_NUMBER(TO_CHAR(DT,'RRRR') ) )
                INTO
                    YR1
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR <= TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    AND   NVL(ANN_EE_CONTS,0) > 0;

                SELECT
                    NVL(SUM(NVL(ANN_EE_CONTS,0) ),0)
                INTO
                    R
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_CLIENT = CLTID
                    AND   ANN_PLAN = PLID
                    AND   ANN_ID = MEMID
                    AND   ANN_YEAR = YR1;

                YR := YR1;
                LOOP
                    IF
                        YR > TO_NUMBER(TO_CHAR(DT,'RRRR') )
                    THEN
                        EXIT;
                    END IF;
                    SELECT
                        NVL(MAX(EIR_RATE),0)
                    INTO
                        IR
                    FROM
                        CONT_INT_RATES
                    WHERE
                        EIR_CLIENT = CLTID
                        AND   EIR_PLAN = PLID
                        AND   TRUNC(EIR_EFF_DATE) = TO_DATE('01-JAN-'
                        || TO_CHAR(YR),'DD-MON-RRRR');

                    IF
                        YR = YR1
                    THEN
                        R := ( NVL(R,0) * ( 1 + ( ( NVL(IR / 2,0) / 100 ) ) ) );
                    ELSE
                        SELECT
                            NVL(SUM(NVL(ANN_EE_CONTS,0) ),0)
                        INTO
                            CURR_CONTS
                        FROM
                            TBL_ANNUAL
                        WHERE
                            ANN_CLIENT = CLTID
                            AND   ANN_PLAN = PLID
                            AND   ANN_ID = MEMID
                            AND   ANN_YEAR = YR;

                        R := ( NVL(R,0) * ( 1 + ( NVL(IR,0) / 100 ) ) ) + ( NVL(CURR_CONTS,0) * ( 1 + ( ( NVL(IR / 2,0) / 100 ) ) ) );

                    END IF;

                    YR := YR + 1;
                END LOOP;

            END;
        END IF;

        IF
            DOB IS NOT NULL AND DOB < SYSDATE
        THEN
            NRD := ADD_MONTHS(LAST_DAY(DOB - 1) + 1,65 * 12);

            AGE := ( NRD - DOB ) / 365.25;
            DEF_YRS := TRUNC( (NRD - DT) / 365.25,0);
            DEF_MTHS := ( ROUND( ( (NRD - DT) / 365.25 - DEF_YRS) * 12,0) );

            IF
                NRD <= DT + 1
            THEN
                DEF_YRS := 0;
                DEF_MTHS := 0;
            END IF;

        END IF;

        IF
            NVL(INT_PCT_INC,0) <> 0 AND NVL(STOP_WORKING,'N') = 'Y'
        THEN
            IF
                DEF_YRS > 0 OR ( NVL(DEF_YRS,0) = 0 AND NVL(DEF_MTHS,0) > 0 )
            THEN
                R := ROUND(R * POWER( ( ( (NVL(INT_PCT_INC,0) / 100) ) ), (DEF_YRS + (DEF_MTHS / 12) ) ),2);

            END IF;
        END IF;

        IF
            NVL(STOP_WORKING,'N') = 'N' AND NVL(DEF_YRS,0) + NVL(DEF_MTHS,0) > 0 AND NVL(R,0) <> 0
        THEN
            SELECT
                NVL(SUM(NVL(ANN_EE_CONTS,0) ),0)
            INTO
                LATEST_CONTS
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = CLTID
                AND   ANN_PLAN = PLID
                AND   ANN_ID = MEMID
                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(DT,'rrrr') );
        -- R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+(DEF_MTHS/12)))+(NVL(LATEST_CONTS,0))*(DEF_YRS+(DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+(DEF_MTHS/12))/2)),2);
      --  R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12))+((NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12))*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);
       --- R:=ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12))+(NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12)*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);
       
      -- R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),(DEF_YRS+(DEF_MTHS/12))))+((LATEST_CONTS)*(DEF_YRS+(DEF_MTHS/12))*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+(DEF_MTHS/12))/2))),2);
      
         --R:=ROUND((R*POWER((1+(INT_PCT_INC/100)),((DEF_YRS+DEF_MTHS)/12)))+((LATEST_CONTS)*((DEF_YRS+DEF_MTHS)/12)*POWER((1+(INT_PCT_INC/100)),(((DEF_YRS+DEF_MTHS)/12)/2))),2);

            R := ROUND( (R * POWER( (1 + (INT_PCT_INC / 100) ), (DEF_YRS + DEF_MTHS / 12) ) ) + ( (LATEST_CONTS) * (DEF_YRS + DEF_MTHS / 12) * POWER( (1 + (INT_PCT_INC / 100) )
, ( (DEF_YRS + DEF_MTHS / 12) / 2) ) ),2);
      --R:= ROUND(R*POWER((1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12)+(LATEST_CONTS)*(DEF_YRS+DEF_MTHS/12))*POWER(1+NVL(INT_PCT_INC,0)/100),(DEF_YRS+DEF_MTHS/12)/2),2);
     --  R:=ROUND(R*POWER((1+(NVL(INT_PCT_INC,0)/100)),(DEF_YRS+DEF_MTHS/12))+(NVL(LATEST_CONTS,0))*(DEF_YRS+DEF_MTHS/12)*POWER((1+NVL(INT_PCT_INC,0)/100),((DEF_YRS+DEF_MTHS/12)/2)),2);

            NULL;
        END IF;

        RETURN R;
    END;

END MACHINIST_DIV1;
/

