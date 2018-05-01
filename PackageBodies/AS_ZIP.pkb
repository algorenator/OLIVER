--
-- AS_ZIP  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER."AS_ZIP" IS 
-- 

    C_LOCAL_FILE_HEADER          CONSTANT RAW(4) := HEXTORAW('504B0304'); -- Local file header signature 
    C_END_OF_CENTRAL_DIRECTORY   CONSTANT RAW(4) := HEXTORAW('504B0506'); -- End of central directory signature 
-- 

    FUNCTION BLOB2NUM (
        P_BLOB   BLOB,
        P_LEN    INTEGER,
        P_POS    INTEGER
    ) RETURN NUMBER
        IS
    BEGIN
        RETURN UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(P_BLOB,P_LEN,P_POS),UTL_RAW.LITTLE_ENDIAN);
    END; 
-- 

    FUNCTION RAW2VARCHAR2 (
        P_RAW RAW,
        P_ENCODING VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN COALESCE(UTL_I18N.RAW_TO_CHAR(P_RAW,P_ENCODING),UTL_I18N.RAW_TO_CHAR(P_RAW,UTL_I18N.MAP_CHARSET(P_ENCODING,UTL_I18N.GENERIC_CONTEXT
,UTL_I18N.IANA_TO_ORACLE) ) );
    END; 
-- 

    FUNCTION LITTLE_ENDIAN (
        P_BIG     NUMBER,
        P_BYTES   PLS_INTEGER := 4
    ) RETURN RAW
        IS
    BEGIN
        RETURN UTL_RAW.SUBSTR(UTL_RAW.CAST_FROM_BINARY_INTEGER(P_BIG,UTL_RAW.LITTLE_ENDIAN),1,P_BYTES);
    END; 
-- 

    FUNCTION FILE2BLOB (
        P_DIR VARCHAR2,
        P_FILE_NAME VARCHAR2
    ) RETURN BLOB IS
        FILE_LOB    BFILE;
        FILE_BLOB   BLOB;
    BEGIN
        FILE_LOB := BFILENAME(P_DIR,P_FILE_NAME);
        DBMS_LOB.OPEN(FILE_LOB,DBMS_LOB.FILE_READONLY);
        DBMS_LOB.CREATETEMPORARY(FILE_BLOB,TRUE);
        DBMS_LOB.LOADFROMFILE(FILE_BLOB,FILE_LOB,DBMS_LOB.LOBMAXSIZE);
        DBMS_LOB.CLOSE(FILE_LOB);
        RETURN FILE_BLOB;
    EXCEPTION
        WHEN OTHERS THEN
            IF
                DBMS_LOB.ISOPEN(FILE_LOB) = 1
            THEN
                DBMS_LOB.CLOSE(FILE_LOB);
            END IF;

            IF
                DBMS_LOB.ISTEMPORARY(FILE_BLOB) = 1
            THEN
                DBMS_LOB.FREETEMPORARY(FILE_BLOB);
            END IF;

            RAISE;
    END; 
-- 

    FUNCTION GET_FILE_LIST (
        P_ZIPPED_BLOB   BLOB,
        P_ENCODING      VARCHAR2 := NULL
    ) RETURN FILE_LIST IS
        T_IND        INTEGER;
        T_HD_IND     INTEGER;
        T_RV         FILE_LIST;
        T_ENCODING   VARCHAR2(32767);
    BEGIN
        T_IND := DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB) - 21;
        LOOP
            EXIT WHEN T_IND < 1 OR DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,4,T_IND) = C_END_OF_CENTRAL_DIRECTORY;

            T_IND := T_IND - 1;
        END LOOP; 
-- 

        IF
            T_IND <= 0
        THEN
            RETURN NULL;
        END IF; 
-- 
        T_HD_IND := BLOB2NUM(P_ZIPPED_BLOB,4,T_IND + 16) + 1;
        T_RV := FILE_LIST ();
        T_RV.EXTEND(BLOB2NUM(P_ZIPPED_BLOB,2,T_IND + 10) );
        FOR I IN 1..BLOB2NUM(P_ZIPPED_BLOB,2,T_IND + 8) LOOP
            IF
                P_ENCODING IS NULL
            THEN
                IF
                    UTL_RAW.BIT_AND(DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,1,T_HD_IND + 9),HEXTORAW('08') ) = HEXTORAW('08')
                THEN
                    T_ENCODING := 'AL32UTF8'; -- utf8 
                ELSE
                    T_ENCODING := 'US8PC437'; -- IBM codepage 437 
                END IF;
            ELSE
                T_ENCODING := P_ENCODING;
            END IF;

            T_RV(I) := RAW2VARCHAR2(DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 28),T_HD_IND + 46),T_ENCODING);

            T_HD_IND := T_HD_IND + 46 + BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 28)  -- File name length 

             + BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 30)  -- Extra field length 

             + BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 32); -- File comment length 

        END LOOP; 
-- 

        RETURN T_RV;
    END; 
-- 

    FUNCTION GET_FILE_LIST (
        P_DIR        VARCHAR2,
        P_ZIP_FILE   VARCHAR2,
        P_ENCODING   VARCHAR2 := NULL
    ) RETURN FILE_LIST
        IS
    BEGIN
        RETURN GET_FILE_LIST(FILE2BLOB(P_DIR,P_ZIP_FILE),P_ENCODING);
    END; 
-- 

    FUNCTION GET_FILE (
        P_ZIPPED_BLOB   BLOB,
        P_FILE_NAME     VARCHAR2,
        P_ENCODING      VARCHAR2 := NULL
    ) RETURN BLOB IS

        T_TMP        BLOB;
        T_IND        INTEGER;
        T_HD_IND     INTEGER;
        T_FL_IND     INTEGER;
        T_ENCODING   VARCHAR2(32767);
        T_LEN        INTEGER;
    BEGIN
        T_IND := DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB) - 21;
        LOOP
            EXIT WHEN T_IND < 1 OR DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,4,T_IND) = C_END_OF_CENTRAL_DIRECTORY;

            T_IND := T_IND - 1;
        END LOOP; 
-- 

        IF
            T_IND <= 0
        THEN
            RETURN NULL;
        END IF; 
-- 
        T_HD_IND := BLOB2NUM(P_ZIPPED_BLOB,4,T_IND + 16) + 1;
        FOR I IN 1..BLOB2NUM(P_ZIPPED_BLOB,2,T_IND + 8) LOOP
            IF
                P_ENCODING IS NULL
            THEN
                IF
                    UTL_RAW.BIT_AND(DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,1,T_HD_IND + 9),HEXTORAW('08') ) = HEXTORAW('08')
                THEN
                    T_ENCODING := 'AL32UTF8'; -- utf8 
                ELSE
                    T_ENCODING := 'US8PC437'; -- IBM codepage 437 
                END IF;
            ELSE
                T_ENCODING := P_ENCODING;
            END IF;

            IF
                P_FILE_NAME = RAW2VARCHAR2(DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 28),T_HD_IND + 46),T_ENCODING)
            THEN
                T_LEN := BLOB2NUM(P_ZIPPED_BLOB,4,T_HD_IND + 24); -- uncompressed length  
                IF
                    T_LEN = 0
                THEN
                    IF
                        SUBSTR(P_FILE_NAME,-1) IN (
                            '/',
                            '\'
                        )
                    THEN  -- directory/folder 
                        RETURN NULL;
                    ELSE -- empty file 
                        RETURN EMPTY_BLOB ();
                    END IF;

                END IF; 
-- 

                IF
                    DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,2,T_HD_IND + 10) = HEXTORAW('0800') -- deflate 
                THEN
                    T_FL_IND := BLOB2NUM(P_ZIPPED_BLOB,4,T_HD_IND + 42);
                    T_TMP := HEXTORAW('1F8B0800000000000003'); -- gzip header 
                    DBMS_LOB.COPY(T_TMP,P_ZIPPED_BLOB,BLOB2NUM(P_ZIPPED_BLOB,4,T_HD_IND + 20),11,T_FL_IND + 31 + BLOB2NUM(P_ZIPPED_BLOB,2,T_FL_IND + 27) -- File name length 
                     + BLOB2NUM(P_ZIPPED_BLOB,2,T_FL_IND + 29) -- Extra field length 
                     );

                    DBMS_LOB.APPEND(T_TMP,UTL_RAW.CONCAT(DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,4,T_HD_IND + 16) -- CRC32 

                   ,LITTLE_ENDIAN(T_LEN) -- uncompressed length 

                     ) );

                    RETURN UTL_COMPRESS.LZ_UNCOMPRESS(T_TMP);
                END IF; 
-- 

                IF
                    DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,2,T_HD_IND + 10) = HEXTORAW('0000') -- The file is stored (no compression) 
                THEN
                    T_FL_IND := BLOB2NUM(P_ZIPPED_BLOB,4,T_HD_IND + 42);
                    DBMS_LOB.CREATETEMPORARY(T_TMP,TRUE);
                    DBMS_LOB.COPY(T_TMP,P_ZIPPED_BLOB,T_LEN,1,T_FL_IND + 31 + BLOB2NUM(P_ZIPPED_BLOB,2,T_FL_IND + 27) -- File name length 
                     + BLOB2NUM(P_ZIPPED_BLOB,2,T_FL_IND + 29) -- Extra field length 
                     );

                    RETURN T_TMP;
                END IF;

            END IF;

            T_HD_IND := T_HD_IND + 46 + BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 28)  -- File name length 

             + BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 30)  -- Extra field length 

             + BLOB2NUM(P_ZIPPED_BLOB,2,T_HD_IND + 32); -- File comment length 

        END LOOP; 
-- 

        RETURN NULL;
    END; 
-- 

    FUNCTION GET_FILE (
        P_DIR         VARCHAR2,
        P_ZIP_FILE    VARCHAR2,
        P_FILE_NAME   VARCHAR2,
        P_ENCODING    VARCHAR2 := NULL
    ) RETURN BLOB
        IS
    BEGIN
        RETURN GET_FILE(FILE2BLOB(P_DIR,P_ZIP_FILE),P_FILE_NAME,P_ENCODING);
    END; 
-- 

    PROCEDURE ADD1FILE (
        P_ZIPPED_BLOB IN OUT BLOB,
        P_NAME      VARCHAR2,
        P_CONTENT   BLOB
    ) IS

        T_NOW          DATE;
        T_BLOB         BLOB;
        T_LEN          INTEGER;
        T_CLEN         INTEGER;
        T_CRC32        RAW(4) := HEXTORAW('00000000');
        T_COMPRESSED   BOOLEAN := FALSE;
        T_NAME         RAW(32767);
    BEGIN
        T_NOW := SYSDATE;
        T_LEN := NVL(DBMS_LOB.GETLENGTH(P_CONTENT),0);
        IF
            T_LEN > 0
        THEN
            T_BLOB := UTL_COMPRESS.LZ_COMPRESS(P_CONTENT);
            T_CLEN := DBMS_LOB.GETLENGTH(T_BLOB) - 18;
            T_COMPRESSED := T_CLEN < T_LEN;
            T_CRC32 := DBMS_LOB.SUBSTR(T_BLOB,4,T_CLEN + 11);
        END IF;

        IF
            NOT T_COMPRESSED
        THEN
            T_CLEN := T_LEN;
            T_BLOB := P_CONTENT;
        END IF;
        IF
            P_ZIPPED_BLOB IS NULL
        THEN
            DBMS_LOB.CREATETEMPORARY(P_ZIPPED_BLOB,TRUE);
        END IF;
        T_NAME := UTL_I18N.STRING_TO_RAW(P_NAME,'AL32UTF8');
        DBMS_LOB.APPEND(P_ZIPPED_BLOB,UTL_RAW.CONCAT(C_LOCAL_FILE_HEADER -- Local file header signature 
       ,HEXTORAW('1400')  -- version 2.0 
       ,
            CASE
                WHEN T_NAME = UTL_I18N.STRING_TO_RAW(P_NAME,'US8PC437') THEN HEXTORAW('0000') -- no General purpose bits 
                ELSE HEXTORAW('0008') -- set Language encoding flag (EFS) 
            END,
            CASE
                WHEN T_COMPRESSED THEN HEXTORAW('0800') -- deflate 
                ELSE HEXTORAW('0000') -- stored 
            END,LITTLE_ENDIAN(TO_NUMBER(TO_CHAR(T_NOW,'ss') ) / 2 + TO_NUMBER(TO_CHAR(T_NOW,'mi') ) * 32 + TO_NUMBER(TO_CHAR(T_NOW,'hh24') ) * 2048,2) -- File last modification time 
           ,LITTLE_ENDIAN(TO_NUMBER(TO_CHAR(T_NOW,'dd') ) + TO_NUMBER(TO_CHAR(T_NOW,'mm') ) * 32 + (TO_NUMBER(TO_CHAR(T_NOW,'yyyy') ) - 1980) * 512,2) -- File last modification date 
           ,T_CRC32 -- CRC-32 
           ,LITTLE_ENDIAN(T_CLEN)                      -- compressed size 
           ,LITTLE_ENDIAN(T_LEN)                       -- uncompressed size 
           ,LITTLE_ENDIAN(UTL_RAW.LENGTH(T_NAME),2) -- File name length 
           ,HEXTORAW('0000')                           -- Extra field length 
           ,T_NAME                                       -- File name 
            ) );

        IF
            T_COMPRESSED
        THEN
            DBMS_LOB.COPY(P_ZIPPED_BLOB,T_BLOB,T_CLEN,DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB) + 1,11); -- compressed content 
        ELSIF T_CLEN > 0 THEN
            DBMS_LOB.COPY(P_ZIPPED_BLOB,T_BLOB,T_CLEN,DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB) + 1,1); --  content 
        END IF;

        IF
            DBMS_LOB.ISTEMPORARY(T_BLOB) = 1
        THEN
            DBMS_LOB.FREETEMPORARY(T_BLOB);
        END IF;

    END; 
-- 

    PROCEDURE FINISH_ZIP (
        P_ZIPPED_BLOB IN OUT BLOB
    ) IS

        T_CNT               PLS_INTEGER := 0;
        T_OFFS              INTEGER;
        T_OFFS_DIR_HEADER   INTEGER;
        T_OFFS_END_HEADER   INTEGER;
        T_COMMENT           RAW(32767) := UTL_RAW.CAST_TO_RAW('Implementation by Anton Scheffer');
    BEGIN
        T_OFFS_DIR_HEADER := DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB);
        T_OFFS := 1;
        WHILE DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,UTL_RAW.LENGTH(C_LOCAL_FILE_HEADER),T_OFFS) = C_LOCAL_FILE_HEADER LOOP
            T_CNT := T_CNT + 1;
            DBMS_LOB.APPEND(P_ZIPPED_BLOB,UTL_RAW.CONCAT(HEXTORAW('504B0102')      -- Central directory file header signature 
           ,HEXTORAW('1400')          -- version 2.0 
           ,DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,26,T_OFFS + 4),HEXTORAW('0000')          -- File comment length 
           ,HEXTORAW('0000')          -- Disk number where file starts 
           ,HEXTORAW('0000')          -- Internal file attributes =>  
                                                                   --     0000 binary file 
                                                                   --     0100 (ascii)text file 
           ,
                CASE
                    WHEN DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,1,T_OFFS + 30 + BLOB2NUM(P_ZIPPED_BLOB,2,T_OFFS + 26) - 1) IN(
                        HEXTORAW('2F') -- / 
                       ,HEXTORAW('5C') -- \ 
                    ) THEN HEXTORAW('10000000') -- a directory/folder 
                    ELSE HEXTORAW('2000B681') -- a file 
                END                         -- External file attributes 
               ,LITTLE_ENDIAN(T_OFFS - 1) -- Relative offset of local file header 
               ,DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,BLOB2NUM(P_ZIPPED_BLOB,2,T_OFFS + 26),T_OFFS + 30)            -- File name 
                 ) );

            T_OFFS := T_OFFS + 30 + BLOB2NUM(P_ZIPPED_BLOB,4,T_OFFS + 18)  -- compressed size 

             + BLOB2NUM(P_ZIPPED_BLOB,2,T_OFFS + 26)  -- File name length  

             + BLOB2NUM(P_ZIPPED_BLOB,2,T_OFFS + 28); -- Extra field length 

        END LOOP;

        T_OFFS_END_HEADER := DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB);
        DBMS_LOB.APPEND(P_ZIPPED_BLOB,UTL_RAW.CONCAT(C_END_OF_CENTRAL_DIRECTORY                                -- End of central directory signature 
       ,HEXTORAW('0000')                                        -- Number of this disk 
       ,HEXTORAW('0000')                                        -- Disk where central directory starts 
       ,LITTLE_ENDIAN(T_CNT,2)                                 -- Number of central directory records on this disk 
       ,LITTLE_ENDIAN(T_CNT,2)                                 -- Total number of central directory records 
       ,LITTLE_ENDIAN(T_OFFS_END_HEADER - T_OFFS_DIR_HEADER)    -- Size of central directory 
       ,LITTLE_ENDIAN(T_OFFS_DIR_HEADER)                        -- Offset of start of central directory, relative to start of archive 
       ,LITTLE_ENDIAN(NVL(UTL_RAW.LENGTH(T_COMMENT),0),2) -- ZIP file comment length 
       ,T_COMMENT) );

    END; 
-- 

    PROCEDURE SAVE_ZIP (
        P_ZIPPED_BLOB   BLOB,
        P_DIR           VARCHAR2 := 'MY_DIR',
        P_FILENAME      VARCHAR2 := 'my.zip'
    ) IS
        T_FH    UTL_FILE.FILE_TYPE;
        T_LEN   PLS_INTEGER := 32767;
    BEGIN
        T_FH := UTL_FILE.FOPEN(P_DIR,P_FILENAME,'wb');
        FOR I IN 0..TRUNC( (DBMS_LOB.GETLENGTH(P_ZIPPED_BLOB) - 1) / T_LEN) LOOP
            UTL_FILE.PUT_RAW(T_FH,DBMS_LOB.SUBSTR(P_ZIPPED_BLOB,T_LEN,I * T_LEN + 1) );
        END LOOP;

        UTL_FILE.FCLOSE(T_FH);
    END; 
-- 

END;
/

