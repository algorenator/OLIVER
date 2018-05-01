--
-- AS_PDF3_MOD  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.AS_PDF3_MOD IS
--

    TYPE THEX IS
        TABLE OF PLS_INTEGER INDEX BY VARCHAR2(2);
    LHEX                    THEX;
    TYPE TP_PLS_TAB IS
        TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    TYPE TP_OBJECTS_TAB IS
        TABLE OF NUMBER(10) INDEX BY PLS_INTEGER;
    TYPE TP_PAGES_TAB IS
        TABLE OF BLOB INDEX BY PLS_INTEGER;
    TYPE TP_SETTINGS IS RECORD ( PAGE_WIDTH              NUMBER,
    PAGE_HEIGHT             NUMBER,
    MARGIN_LEFT             NUMBER,
    MARGIN_RIGHT            NUMBER,
    MARGIN_TOP              NUMBER,
    MARGIN_BOTTOM           NUMBER );
    TYPE TP_SETTINGS_TAB IS
        TABLE OF TP_SETTINGS INDEX BY PLS_INTEGER;
    TYPE TP_FONT IS RECORD ( STANDARD                BOOLEAN,
    FAMILY                  VARCHAR2(100),
    STYLE                   VARCHAR2(2)  -- N Normal
                         -- I Italic
                         -- B Bold
                         -- BI Bold Italic
   ,
    SUBTYPE                 VARCHAR2(15),
    NAME                    VARCHAR2(100),
    FONTNAME                VARCHAR2(100),
    CHAR_WIDTH_TAB          TP_PLS_TAB,
    ENCODING                VARCHAR2(100),
    CHARSET                 VARCHAR2(1000),
    COMPRESS_FONT           BOOLEAN := TRUE,
    FONTSIZE                NUMBER,
    UNIT_NORM               NUMBER,
    BB_XMIN                 PLS_INTEGER,
    BB_YMIN                 PLS_INTEGER,
    BB_XMAX                 PLS_INTEGER,
    BB_YMAX                 PLS_INTEGER,
    FLAGS                   PLS_INTEGER,
    FIRST_CHAR              PLS_INTEGER,
    LAST_CHAR               PLS_INTEGER,
    ITALIC_ANGLE            NUMBER,
    ASCENT                  PLS_INTEGER,
    DESCENT                 PLS_INTEGER,
    CAPHEIGHT               PLS_INTEGER,
    STEMV                   PLS_INTEGER,
    DIFF                    VARCHAR2(32767),
    CID                     BOOLEAN := FALSE,
    FONTFILE2               BLOB,
    TTF_OFFSET              PLS_INTEGER,
    USED_CHARS              TP_PLS_TAB,
    NUMGLYPHS               PLS_INTEGER,
    INDEXTOLOCFORMAT        PLS_INTEGER,
    LOCA                    TP_PLS_TAB,
    CODE2GLYPH              TP_PLS_TAB,
    HMETRICS                TP_PLS_TAB );
    TYPE TP_FONT_TAB IS
        TABLE OF TP_FONT INDEX BY PLS_INTEGER;
    TYPE TP_IMG IS RECORD ( ADLER32                 VARCHAR2(8),
    WIDTH                   PLS_INTEGER,
    HEIGHT                  PLS_INTEGER,
    COLOR_RES               PLS_INTEGER,
    COLOR_TAB               RAW(768),
    GREYSCALE               BOOLEAN,
    PIXELS                  BLOB,
    TYPE                    VARCHAR2(5),
    NR_COLORS               PLS_INTEGER,
    TRANSPARANCY_INDEX      PLS_INTEGER );
    TYPE TP_IMG_TAB IS
        TABLE OF TP_IMG INDEX BY PLS_INTEGER;
    TYPE TP_INFO IS RECORD ( TITLE                   VARCHAR2(1024),
    AUTHOR                  VARCHAR2(1024),
    SUBJECT                 VARCHAR2(1024),
    KEYWORDS                VARCHAR2(32767) );
    TYPE TP_PAGE_PRCS IS
        TABLE OF CLOB INDEX BY PLS_INTEGER;
--
-- globals
    G_PDF_DOC               BLOB; -- the PDF-document being constructed
    G_OBJECTS               TP_OBJECTS_TAB;
    G_PAGES                 TP_PAGES_TAB;
    G_SETTINGS_PER_PAGE     TP_SETTINGS_TAB;
    G_SETTINGS              TP_SETTINGS;
    G_FONTS                 TP_FONT_TAB;
    G_USED_FONTS            TP_PLS_TAB;
    G_CURRENT_FONT          PLS_INTEGER;
    G_CURRENT_FONT_RECORD   TP_FONT;
    G_IMAGES                TP_IMG_TAB;
    G_X                     NUMBER;  -- current x-location of the "cursor"
    G_Y                     NUMBER;  -- current y-location of the "cursor"
    G_INFO                  TP_INFO;
    G_PAGE_NR               PLS_INTEGER;
    G_PAGE_PRCS             TP_PAGE_PRCS;
--
-- constants
    C_NL                    CONSTANT VARCHAR2(2) := CHR(13)
    || CHR(10);
--

    FUNCTION NUM2RAW (
        P_VALUE NUMBER
    ) RETURN RAW
        IS
    BEGIN
        RETURN HEXTORAW(TO_CHAR(P_VALUE,'FM0XXXXXXX') );
    END;
--

    FUNCTION RAW2NUM (
        P_VALUE RAW
    ) RETURN NUMBER
        IS
    BEGIN
        RETURN TO_NUMBER(RAWTOHEX(P_VALUE),'XXXXXXXX');
    END;
--

    FUNCTION RAW2NUM (
        P_VALUE   RAW,
        P_POS     PLS_INTEGER,
        P_LEN     PLS_INTEGER
    ) RETURN PLS_INTEGER
        IS
    BEGIN
        RETURN TO_NUMBER(RAWTOHEX(UTL_RAW.SUBSTR(P_VALUE,P_POS,P_LEN) ),'XXXXXXXX');
    END;
--

    FUNCTION TO_SHORT (
        P_VAL      RAW,
        P_FACTOR   NUMBER := 1
    ) RETURN NUMBER IS
        T_RV   NUMBER;
    BEGIN
        T_RV := TO_NUMBER(RAWTOHEX(P_VAL),'XXXXXXXXXX');
        IF
            T_RV > 32767
        THEN
            T_RV := T_RV - 65536;
        END IF;
        RETURN T_RV * P_FACTOR;
    END;
--

    FUNCTION BLOB2NUM (
        P_BLOB   BLOB,
        P_LEN    INTEGER,
        P_POS    INTEGER
    ) RETURN NUMBER
        IS
    BEGIN
        RETURN TO_NUMBER(RAWTOHEX(DBMS_LOB.SUBSTR(P_BLOB,P_LEN,P_POS) ),'xxxxxxxx');
    END;
--

    FUNCTION FILE2BLOB (
        P_DIR VARCHAR2,
        P_FILE_NAME VARCHAR2
    ) RETURN BLOB IS
        T_RAW    RAW(32767);
        T_BLOB   BLOB;
        FH       UTL_FILE.FILE_TYPE;
    BEGIN
        FH := UTL_FILE.FOPEN(P_DIR,P_FILE_NAME,'rb');
        DBMS_LOB.CREATETEMPORARY(T_BLOB,TRUE);
        LOOP
            BEGIN
                UTL_FILE.GET_RAW(FH,T_RAW);
                DBMS_LOB.APPEND(T_BLOB,T_RAW);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    EXIT;
            END;
        END LOOP;

        UTL_FILE.FCLOSE(FH);
        RETURN T_BLOB;
    EXCEPTION
        WHEN OTHERS THEN
            IF
                UTL_FILE.IS_OPEN(FH)
            THEN
                UTL_FILE.FCLOSE(FH);
            END IF;
            RAISE;
    END;
--

    PROCEDURE INIT_CORE_FONTS IS

        FUNCTION UNCOMPRESS_WITHS (
            P_COMPRESSED_TAB VARCHAR2
        ) RETURN TP_PLS_TAB IS
            T_RV    TP_PLS_TAB;
            T_TMP   RAW(32767);
        BEGIN
            IF
                P_COMPRESSED_TAB IS NOT NULL
            THEN
                T_TMP := UTL_COMPRESS.LZ_UNCOMPRESS(UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(P_COMPRESSED_TAB) ) );

                FOR I IN 0..255 LOOP
                    T_RV(I) := TO_NUMBER(UTL_RAW.SUBSTR(T_TMP,I * 4 + 1,4),'0xxxxxxx');
                END LOOP;

            END IF;

            RETURN T_RV;
        END;
--

        PROCEDURE INIT_CORE_FONT (
            P_IND              PLS_INTEGER,
            P_FAMILY           VARCHAR2,
            P_STYLE            VARCHAR2,
            P_NAME             VARCHAR2,
            P_COMPRESSED_TAB   VARCHAR2
        )
            IS
        BEGIN
            G_FONTS(P_IND).FAMILY := P_FAMILY;
            G_FONTS(P_IND).STYLE := P_STYLE;
            G_FONTS(P_IND).NAME := P_NAME;
            G_FONTS(P_IND).FONTNAME := P_NAME;
            G_FONTS(P_IND).STANDARD := TRUE;
            G_FONTS(P_IND).ENCODING := 'WE8MSWIN1252';
            G_FONTS(P_IND).CHARSET := SYS_CONTEXT('userenv','LANGUAGE');
            G_FONTS(P_IND).CHARSET := SUBSTR(G_FONTS(P_IND).CHARSET,1,INSTR(G_FONTS(P_IND).CHARSET,'.') )
            || G_FONTS(P_IND).ENCODING;

            G_FONTS(P_IND).CHAR_WIDTH_TAB := UNCOMPRESS_WITHS(P_COMPRESSED_TAB);
        END;

    BEGIN
        INIT_CORE_FONT(1,'helvetica','N','Helvetica','H4sIAAAAAAAAC81Tuw3CMBC94FQMgMQOLAGVGzNCGtc0dAxAT+8lsgE7RKJFomOA'
        || 'SLT4frHjBEFJ8XSX87372C8A1Qr+Ax5gsWGYU7QBAK4x7gTnGLOS6xJPOd8w5NsM'
        || '2OvFvQidAP04j1nyN3F7iSNny3E6DylPeeqbNqvti31vMpfLZuzH86oPdwaeo6X+'
        || '5X6Oz5VHtTqJKfYRNVu6y0ZyG66rdcxzXJe+Q/KJ59kql+bTt5K6lKucXvxWeHKf'
        || '+p6Tfersfh7RHuXMZjHsdUkxBeWtM60gDjLTLoHeKsyDdu6m8VK3qhnUQAmca9BG'
        || 'Dq3nP+sV/4FcD6WOf9K/ne+hdav+DTuNLeYABAAA');
--

        INIT_CORE_FONT(2,'helvetica','I','Helvetica-Oblique','H4sIAAAAAAAAC81Tuw3CMBC94FQMgMQOLAGVGzNCGtc0dAxAT+8lsgE7RKJFomOA'
        || 'SLT4frHjBEFJ8XSX87372C8A1Qr+Ax5gsWGYU7QBAK4x7gTnGLOS6xJPOd8w5NsM'
        || '2OvFvQidAP04j1nyN3F7iSNny3E6DylPeeqbNqvti31vMpfLZuzH86oPdwaeo6X+'
        || '5X6Oz5VHtTqJKfYRNVu6y0ZyG66rdcxzXJe+Q/KJ59kql+bTt5K6lKucXvxWeHKf'
        || '+p6Tfersfh7RHuXMZjHsdUkxBeWtM60gDjLTLoHeKsyDdu6m8VK3qhnUQAmca9BG'
        || 'Dq3nP+sV/4FcD6WOf9K/ne+hdav+DTuNLeYABAAA');
--

        INIT_CORE_FONT(3,'helvetica','B','Helvetica-Bold','H4sIAAAAAAAAC8VSsRHCMAx0SJcBcgyRJaBKkxXSqKahYwB6+iyRTbhLSUdHRZUB'
        || 'sOWXLF8SKCn+ZL/0kizZuaJ2/0fn8XBu10SUF28n59wbvoCr51oTD61ofkHyhBwK'
        || '8rXusVaGAb4q3rXOBP4Qz+wfUpzo5FyO4MBr39IH+uLclFvmCTrz1mB5PpSD52N1'
        || 'DfqS988xptibWfbw9Sa/jytf+dz4PqQz6wi63uxxBpCXY7uUj88jNDNy1mYGdl97'
        || '856nt2f4WsOFed4SpzumNCvlT+jpmKC7WgH3PJn9DaZfA42vlgh96d+wkHy0/V95'
        || 'xyv8oj59QbvBN2I/iAuqEAAEAAA=');
--

        INIT_CORE_FONT(4,'helvetica','BI','Helvetica-BoldOblique','H4sIAAAAAAAAC8VSsRHCMAx0SJcBcgyRJaBKkxXSqKahYwB6+iyRTbhLSUdHRZUB'
        || 'sOWXLF8SKCn+ZL/0kizZuaJ2/0fn8XBu10SUF28n59wbvoCr51oTD61ofkHyhBwK'
        || '8rXusVaGAb4q3rXOBP4Qz+wfUpzo5FyO4MBr39IH+uLclFvmCTrz1mB5PpSD52N1'
        || 'DfqS988xptibWfbw9Sa/jytf+dz4PqQz6wi63uxxBpCXY7uUj88jNDNy1mYGdl97'
        || '856nt2f4WsOFed4SpzumNCvlT+jpmKC7WgH3PJn9DaZfA42vlgh96d+wkHy0/V95'
        || 'xyv8oj59QbvBN2I/iAuqEAAEAAA=');
--

        INIT_CORE_FONT(5,'times','N','Times-Roman','H4sIAAAAAAAAC8WSKxLCQAyG+3Bopo4bVHbwHGCvUNNT9AB4JEwvgUBimUF3wCNR'
        || 'qAoGRZL9twlQikR8kzTvZBtF0SP6O7Ej1kTnSRfEhHw7+Jy3J4XGi8w05yeZh2sE'
        || '4j312ZDeEg1gvSJy6C36L9WX1urr4xrolfrSrYmrUCeDPGMu5+cQ3Ur3OXvQ+TYf'
        || '+2FGexOZvTM1L3S3o5fJjGQJX2n68U2ur3X5m3cTvfbxsk9pcsMee60rdTjnhNkc'
        || 'Zip9HOv9+7/tI3Oif3InOdV/oLdx3gq2HIRaB1Ob7XPk35QwwxDyxg3e09Dv6nSf'
        || 'rxQjvty8ywDce9CXvdF9R+4y4o+7J1P/I9sABAAA');
--

        INIT_CORE_FONT(6,'times','I','Times-Italic','H4sIAAAAAAAAC8WSPQ6CQBCFF+i01NB5g63tPcBegYZTeAB6SxNLjLUH4BTEeAYr'
        || 'Kwpj5ezsW2YgoKXFl2Hnb9+wY4x5m7+TOOJMdIFsRywodkfMBX9aSz7bXGp+gj6+'
        || 'R4TvOtJ3CU5Eq85tgGsbxG3QN8iFZY1WzpxXwkckFTR7e1G6osZGWT1bDuBnTeP5'
        || 'KtW/E71c0yB2IFbBphuyBXIL9Y/9fPvhf8se6vsa8nmeQtU6NSf6ch9fc8P9DpqK'
        || 'cPa5/I7VxDwruTN9kV3LDvQ+h1m8z4I4x9LIbnn/Fv6nwOdyGq+d33jk7/cxztyq'
        || 'XRhTz/it7Mscg7fT5CO+9ahnYk20Hww5IrwABAAA');
--

        INIT_CORE_FONT(7,'times','B','Times-Bold','H4sIAAAAAAAAC8VSuw3CQAy9XBqUAVKxAZkgHQUNEiukySxpqOjTMQEDZIrUDICE'
        || 'RHUVVfy9c0IQJcWTfbafv+ece7u/Izs553cgAyN/APagl+wjgN3XKZ5kmTg/IXkw'
        || 'h4JqXUEfAb1I1VvwFYysk9iCffmN4+gtccSr5nlwDpuTepCZ/MH0FZibDUnO7MoR'
        || 'HXdDuvgjpzNxgevG+dF/hr3dWfoNyEZ8Taqn+7d7ozmqpGM8zdMYruFrXopVjvY2'
        || 'in9gXe+5vBf1KfX9E6TOVBsb8i5iqwQyv9+a3Gg/Cv+VoDtaQ7xdPwfNYRDji09g'
        || 'X/FvLNGmO62B9jSsoFwgfM+jf1z/SPwrkTMBOkCTBQAEAAA=');
--

        INIT_CORE_FONT(8,'times','BI','Times-BoldItalic','H4sIAAAAAAAAC8WSuw2DMBCGHegYwEuECajIAGwQ0TBFBnCfPktkAKagzgCRIqWi'
        || 'oso9fr+Qo5RB+nT2ve+wMWYzf+fgjKmOJFelPhENnS0xANJXHfwHSBtjfoI8nMMj'
        || 'tXo63xKW/Cx9ONRn3US6C/wWvYeYNr+LH2IY6cHGPkJfvsc5kX7mFjF+Vqs9iT6d'
        || 'zwEL26y1Qz62nWlvD5VSf4R9zPuon/ne+C45+XxXf5lnTGLTOZCXPx8v9Qfdjdid'
        || '5vD/f/+/pE/Ur14kG+xjTHRc84pZWsC2Hjk2+Hgbx78j4Z8W4DlL+rBnEN5Bie6L'
        || 'fsL+1u/InuYCdsdaeAs+RxftKfGdfQDlDF/kAAQAAA==');
--

        INIT_CORE_FONT(9,'courier','N','Courier',NULL);
        FOR I IN 0..255 LOOP
            G_FONTS(9).CHAR_WIDTH_TAB(I) := 600;
        END LOOP;
--

        INIT_CORE_FONT(10,'courier','I','Courier-Oblique',NULL);
        G_FONTS(10).CHAR_WIDTH_TAB := G_FONTS(9).CHAR_WIDTH_TAB;
--
        INIT_CORE_FONT(11,'courier','B','Courier-Bold',NULL);
        G_FONTS(11).CHAR_WIDTH_TAB := G_FONTS(9).CHAR_WIDTH_TAB;
--
        INIT_CORE_FONT(12,'courier','BI','Courier-BoldOblique',NULL);
        G_FONTS(12).CHAR_WIDTH_TAB := G_FONTS(9).CHAR_WIDTH_TAB;
--
        INIT_CORE_FONT(13,'symbol','N','Symbol','H4sIAAAAAAAAC82SIU8DQRCFZ28xIE+cqcbha4tENKk/gQCJJ6AweIK9H1CHqKnp'
        || 'D2gTFBaDIcFwCQkJSTG83fem7SU0qYNLvry5nZ25t7NnZkv7c8LQrFhAP6GHZvEY'
        || 'HOB9ylxGubTfNVRc34mKpFonzBQ/gUZ6Ds7AN6i5lv1dKv8Ab1eKQYSV4hUcgZFq'
        || 'J/Sec7fQHtdTn3iqfvdrb7m3e2pZW+xDG3oIJ/Li3gfMr949rlU74DyT1/AuTX1f'
        || 'YGhOzTP8B0/RggsEX/I03vgXPrrslZjfM8/pGu40t2ZjHgud97F7337mXP/GO4h9'
        || '3WmPPaOJ/jrOs9yC52MlrtUzfWupfTX51X/L+13Vl/J/s4W2S3pSfSh5DmeXerMf'
        || '+LXhWQAEAAA=');
--

        INIT_CORE_FONT(14,'zapfdingbats','N','ZapfDingbats','H4sIAAAAAAAAC83ROy9EQRjG8TkzjdJl163SSHR0EpdsVkSi2UahFhUljUKUIgoq'
        || 'CrvJCtFQyG6EbSSERGxhC0ofQAQFxbIi8T/7PoUPIOEkvzxzzsycdy7O/fUTtToX'
        || 'bnCuvHPOV8gk4r423ovkGQ5od5OTWMeesmBz/RuZIWv4wCAY4z/xjipeqflC9qAD'
        || 'aRwxrxkJievSFzrRh36tZ1zttL6nkGX+A27xrLnttE/IBji9x7UvcIl9nPJ9AL36'
        || 'd1L9hyihoDW10L62cwhNyhntryZVExYl3kMj+zym+CrJv6M8VozPmfr5L8uwJORL'
        || 'tox7NFHG/Obj79FlwhqZ1X292xn6CbAXP/fjjv6rJYyBtUdl1vxEO6fcRB7bMmJ3'
        || 'GYZsTN0GdrDL/Ao5j1GZNr5kwqydX5z1syoiYEq5gCtlSrXi+mVbi3PfVAuhoQAE'
        || 'AAA=');
--

    END;
--

    FUNCTION TO_CHAR_ROUND (
        P_VALUE       NUMBER,
        P_PRECISION   PLS_INTEGER := 2
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN TO_CHAR(ROUND(P_VALUE,P_PRECISION),'TM9','NLS_NUMERIC_CHARACTERS=.,');
    END;
--

    PROCEDURE RAW2PDFDOC (
        P_RAW BLOB
    )
        IS
    BEGIN
        DBMS_LOB.APPEND(G_PDF_DOC,P_RAW);
    END;
--

    PROCEDURE TXT2PDFDOC (
        P_TXT VARCHAR2
    )
        IS
    BEGIN
        RAW2PDFDOC(UTL_RAW.CAST_TO_RAW(P_TXT
        || C_NL) );
    END;
--

    FUNCTION ADD_OBJECT (
        P_TXT VARCHAR2 := NULL
    ) RETURN NUMBER IS
        T_SELF   NUMBER(10);
    BEGIN
        T_SELF := G_OBJECTS.COUNT ();
        G_OBJECTS(T_SELF) := DBMS_LOB.GETLENGTH(G_PDF_DOC);
--
        IF
            P_TXT IS NULL
        THEN
            TXT2PDFDOC(T_SELF
            || ' 0 obj');
        ELSE
            TXT2PDFDOC(T_SELF
            || ' 0 obj'
            || C_NL
            || '<<'
            || P_TXT
            || '>>'
            || C_NL
            || 'endobj');
        END IF;
--

        RETURN T_SELF;
    END;
--

    PROCEDURE ADD_OBJECT (
        P_TXT VARCHAR2 := NULL
    ) IS
        T_DUMMY   NUMBER(10) := ADD_OBJECT(P_TXT);
    BEGIN
        NULL;
    END;
--

    FUNCTION ADLER32 (
        P_SRC IN BLOB
    ) RETURN VARCHAR2 IS

        S1          PLS_INTEGER := 1;
        S2          PLS_INTEGER := 0;
        N           PLS_INTEGER;
        STEP_SIZE   NUMBER;
        TMP         VARCHAR2(32766);
        C65521      CONSTANT PLS_INTEGER := 65521;
    BEGIN
        STEP_SIZE := TRUNC(16383 / DBMS_LOB.GETCHUNKSIZE(P_SRC) ) * DBMS_LOB.GETCHUNKSIZE(P_SRC);

        FOR J IN 0..TRUNC( (DBMS_LOB.GETLENGTH(P_SRC) - 1) / STEP_SIZE) LOOP
            TMP := RAWTOHEX(DBMS_LOB.SUBSTR(P_SRC,STEP_SIZE,J * STEP_SIZE + 1) );

            FOR I IN 1..LENGTH(TMP) / 2 LOOP
                N := LHEX(SUBSTR(TMP,I * 2 - 1,2) );--n := to_number( substr( tmp, i * 2 - 1, 2 ), 'xx' );

                S1 := S1 + N;
                IF
                    S1 >= C65521
                THEN
                    S1 := S1 - C65521;
                END IF;
                S2 := S2 + S1;
                IF
                    S2 >= C65521
                THEN
                    S2 := S2 - C65521;
                END IF;
            END LOOP;

        END LOOP;

        RETURN TO_CHAR(S2,'fm0XXX')
        || TO_CHAR(S1,'fm0XXX');
    END;
--

    FUNCTION FLATE_ENCODE (
        P_VAL BLOB
    ) RETURN BLOB IS
        T_BLOB   BLOB;
    BEGIN
        T_BLOB := HEXTORAW('789C');
        DBMS_LOB.COPY(T_BLOB,UTL_COMPRESS.LZ_COMPRESS(P_VAL),DBMS_LOB.LOBMAXSIZE,3,11);

        DBMS_LOB.TRIM(T_BLOB,DBMS_LOB.GETLENGTH(T_BLOB) - 8);
        DBMS_LOB.APPEND(T_BLOB,HEXTORAW(ADLER32(P_VAL) ) );
        RETURN T_BLOB;
    END;
--

    PROCEDURE PUT_STREAM (
        P_STREAM     BLOB,
        P_COMPRESS   BOOLEAN := TRUE,
        P_EXTRA      VARCHAR2 := '',
        P_TAG        BOOLEAN := TRUE
    ) IS
        T_BLOB       BLOB;
        T_COMPRESS   BOOLEAN := FALSE;
    BEGIN
        IF
            P_COMPRESS AND NVL(DBMS_LOB.GETLENGTH(P_STREAM),0) > 0
        THEN
            T_COMPRESS := TRUE;
            T_BLOB := FLATE_ENCODE(P_STREAM);
        ELSE
            T_BLOB := P_STREAM;
        END IF;

        TXT2PDFDOC(
            CASE
                WHEN P_TAG THEN '<<'
            END
        ||
            CASE
                WHEN T_COMPRESS THEN '/Filter /FlateDecode '
            END
        || '/Length '
        || NVL(LENGTH(T_BLOB),0)
        || P_EXTRA
        || '>>');

        TXT2PDFDOC('stream');
        RAW2PDFDOC(T_BLOB);
        TXT2PDFDOC('endstream');
        IF
            DBMS_LOB.ISTEMPORARY(T_BLOB) = 1
        THEN
            DBMS_LOB.FREETEMPORARY(T_BLOB);
        END IF;

    END;
--

    FUNCTION ADD_STREAM (
        P_STREAM     BLOB,
        P_EXTRA      VARCHAR2 := '',
        P_COMPRESS   BOOLEAN := TRUE
    ) RETURN NUMBER IS
        T_SELF   NUMBER(10);
    BEGIN
        T_SELF := ADD_OBJECT;
        PUT_STREAM(P_STREAM,P_COMPRESS,P_EXTRA);
        TXT2PDFDOC('endobj');
        RETURN T_SELF;
    END;
--

    FUNCTION SUBSET_FONT (
        P_INDEX PLS_INTEGER
    ) RETURN BLOB IS

        T_TMP             BLOB;
        T_HEADER          BLOB;
        T_TABLES          BLOB;
        T_LEN             PLS_INTEGER;
        T_CODE            PLS_INTEGER;
        T_GLYPH           PLS_INTEGER;
        T_OFFSET          PLS_INTEGER;
        T_FACTOR          PLS_INTEGER;
        T_UNICODE         PLS_INTEGER;
        T_USED_GLYPHS     TP_PLS_TAB;
        T_FMT             VARCHAR2(10);
        T_UTF16_CHARSET   VARCHAR2(1000);
        T_RAW             RAW(32767);
        T_V               VARCHAR2(32767);
        T_TABLE_RECORDS   RAW(32767);
    BEGIN
        IF
            G_FONTS(P_INDEX).CID
        THEN
            T_USED_GLYPHS := G_FONTS(P_INDEX).USED_CHARS;
            T_USED_GLYPHS(0) := 0;
        ELSE
            T_UTF16_CHARSET := SUBSTR(G_FONTS(P_INDEX).CHARSET,1,INSTR(G_FONTS(P_INDEX).CHARSET,'.') )
            || 'AL16UTF16';

            T_USED_GLYPHS(0) := 0;
            T_CODE := G_FONTS(P_INDEX).USED_CHARS.FIRST;
            WHILE T_CODE IS NOT NULL LOOP
                T_UNICODE := TO_NUMBER(RAWTOHEX(UTL_RAW.CONVERT(HEXTORAW(TO_CHAR(T_CODE,'fm0x') ),T_UTF16_CHARSET,G_FONTS(P_INDEX).CHARSET  -- ???? database characterset ?????
                ) ),'XXXXXXXX');

                IF
                    G_FONTS(P_INDEX).FLAGS = 4 -- a symbolic font
                THEN
-- assume code 32, space maps to the first code from the font
                    T_USED_GLYPHS(G_FONTS(P_INDEX).CODE2GLYPH(G_FONTS(P_INDEX).CODE2GLYPH.FIRST + T_UNICODE - 32) ) := 0;

                ELSE
                    T_USED_GLYPHS(G_FONTS(P_INDEX).CODE2GLYPH(T_UNICODE) ) := 0;
                END IF;

                T_CODE := G_FONTS(P_INDEX).USED_CHARS.NEXT(T_CODE);
            END LOOP;

        END IF;
--

        DBMS_LOB.CREATETEMPORARY(T_TABLES,TRUE);
        T_HEADER := UTL_RAW.CONCAT(HEXTORAW('00010000'),DBMS_LOB.SUBSTR(G_FONTS(P_INDEX).FONTFILE2,8,G_FONTS(P_INDEX).TTF_OFFSET + 4) );

        T_OFFSET := 12 + BLOB2NUM(G_FONTS(P_INDEX).FONTFILE2,2,G_FONTS(P_INDEX).TTF_OFFSET + 4) * 16;

        T_TABLE_RECORDS := DBMS_LOB.SUBSTR(G_FONTS(P_INDEX).FONTFILE2,BLOB2NUM(G_FONTS(P_INDEX).FONTFILE2,2,G_FONTS(P_INDEX).TTF_OFFSET + 4) *
16,G_FONTS(P_INDEX).TTF_OFFSET + 12);

        FOR I IN 1..BLOB2NUM(G_FONTS(P_INDEX).FONTFILE2,2,G_FONTS(P_INDEX).TTF_OFFSET + 4) LOOP
            CASE
                UTL_RAW.CAST_TO_VARCHAR2(UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 15,4) )
                WHEN 'post' THEN
                    DBMS_LOB.APPEND(T_HEADER,UTL_RAW.CONCAT(UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 15,4) -- tag
                   ,HEXTORAW('00000000') -- checksum
                   ,NUM2RAW(T_OFFSET + DBMS_LOB.GETLENGTH(T_TABLES) ) -- offset
                   ,NUM2RAW(32) -- length
                     ) );

                    DBMS_LOB.APPEND(T_TABLES,UTL_RAW.CONCAT(HEXTORAW('00030000'),DBMS_LOB.SUBSTR(G_FONTS(P_INDEX).FONTFILE2,28,RAW2NUM(T_TABLE_RECORDS
,I * 16 - 7,4) + 5) ) );

                WHEN 'loca' THEN
                    IF
                        G_FONTS(P_INDEX).INDEXTOLOCFORMAT = 0
                    THEN
                        T_FMT := 'fm0XXX';
                    ELSE
                        T_FMT := 'fm0XXXXXXX';
                    END IF;

                    T_RAW := NULL;
                    DBMS_LOB.CREATETEMPORARY(T_TMP,TRUE);
                    T_LEN := 0;
                    FOR G IN 0..G_FONTS(P_INDEX).NUMGLYPHS - 1 LOOP
                        T_RAW := UTL_RAW.CONCAT(T_RAW,HEXTORAW(TO_CHAR(T_LEN,T_FMT) ) );

                        IF
                            UTL_RAW.LENGTH(T_RAW) > 32770
                        THEN
                            DBMS_LOB.APPEND(T_TMP,T_RAW);
                            T_RAW := NULL;
                        END IF;

                        IF
                            T_USED_GLYPHS.EXISTS(G)
                        THEN
                            T_LEN := T_LEN + G_FONTS(P_INDEX).LOCA(G + 1) - G_FONTS(P_INDEX).LOCA(G);
                        END IF;

                    END LOOP;

                    T_RAW := UTL_RAW.CONCAT(T_RAW,HEXTORAW(TO_CHAR(T_LEN,T_FMT) ) );

                    DBMS_LOB.APPEND(T_TMP,T_RAW);
                    DBMS_LOB.APPEND(T_HEADER,UTL_RAW.CONCAT(UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 15,4) -- tag
                   ,HEXTORAW('00000000') -- checksum
                   ,NUM2RAW(T_OFFSET + DBMS_LOB.GETLENGTH(T_TABLES) ) -- offset
                   ,NUM2RAW(DBMS_LOB.GETLENGTH(T_TMP) ) -- length
                     ) );

                    DBMS_LOB.APPEND(T_TABLES,T_TMP);
                    DBMS_LOB.FREETEMPORARY(T_TMP);
                WHEN 'glyf' THEN
                    IF
                        G_FONTS(P_INDEX).INDEXTOLOCFORMAT = 0
                    THEN
                        T_FACTOR := 2;
                    ELSE
                        T_FACTOR := 1;
                    END IF;

                    T_RAW := NULL;
                    DBMS_LOB.CREATETEMPORARY(T_TMP,TRUE);
                    FOR G IN 0..G_FONTS(P_INDEX).NUMGLYPHS - 1 LOOP
                        IF
                            ( T_USED_GLYPHS.EXISTS(G) AND G_FONTS(P_INDEX).LOCA(G + 1) > G_FONTS(P_INDEX).LOCA(G) )
                        THEN
                            T_RAW := UTL_RAW.CONCAT(T_RAW,DBMS_LOB.SUBSTR(G_FONTS(P_INDEX).FONTFILE2, (G_FONTS(P_INDEX).LOCA(G + 1) - G_FONTS(P_INDEX).LOCA(G) ) * T_FACTOR
,G_FONTS(P_INDEX).LOCA(G) * T_FACTOR + RAW2NUM(T_TABLE_RECORDS,I * 16 - 7,4) + 1) );

                            IF
                                UTL_RAW.LENGTH(T_RAW) > 32000
                            THEN
                                DBMS_LOB.APPEND(T_TMP,T_RAW);
                                T_RAW := NULL;
                            END IF;

                        END IF;
                    END LOOP;

                    IF
                        UTL_RAW.LENGTH(T_RAW) > 0
                    THEN
                        DBMS_LOB.APPEND(T_TMP,T_RAW);
                    END IF;

                    DBMS_LOB.APPEND(T_HEADER,UTL_RAW.CONCAT(UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 15,4) -- tag

                   ,HEXTORAW('00000000') -- checksum

                   ,NUM2RAW(T_OFFSET + DBMS_LOB.GETLENGTH(T_TABLES) ) -- offset

                   ,NUM2RAW(DBMS_LOB.GETLENGTH(T_TMP) ) -- length

                     ) );

                    DBMS_LOB.APPEND(T_TABLES,T_TMP);
                    DBMS_LOB.FREETEMPORARY(T_TMP);
                ELSE
                    DBMS_LOB.APPEND(T_HEADER,UTL_RAW.CONCAT(UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 15,4)    -- tag
                   ,UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 11,4)    -- checksum
                   ,NUM2RAW(T_OFFSET + DBMS_LOB.GETLENGTH(T_TABLES) ) -- offset
                   ,UTL_RAW.SUBSTR(T_TABLE_RECORDS,I * 16 - 3,4)     -- length
                     ) );

                    DBMS_LOB.COPY(T_TABLES,G_FONTS(P_INDEX).FONTFILE2,RAW2NUM(T_TABLE_RECORDS,I * 16 - 3,4),DBMS_LOB.GETLENGTH(T_TABLES) + 1,RAW2NUM(T_TABLE_RECORDS
,I * 16 - 7,4) + 1);

            END CASE;
        END LOOP;

        DBMS_LOB.APPEND(T_HEADER,T_TABLES);
        DBMS_LOB.FREETEMPORARY(T_TABLES);
        RETURN T_HEADER;
    END;
--

    FUNCTION ADD_FONT (
        P_INDEX PLS_INTEGER
    ) RETURN NUMBER IS

        T_SELF            NUMBER(10);
        T_FONTFILE        NUMBER(10);
        T_FONT_SUBSET     BLOB;
        T_USED            PLS_INTEGER;
        T_USED_GLYPHS     TP_PLS_TAB;
        T_W               VARCHAR2(32767);
        T_UNICODE         PLS_INTEGER;
        T_UTF16_CHARSET   VARCHAR2(1000);
        T_WIDTH           NUMBER;
    BEGIN
        IF
            G_FONTS(P_INDEX).STANDARD
        THEN
            RETURN ADD_OBJECT('/Type/Font'
            || '/Subtype/Type1'
            || '/BaseFont/'
            || G_FONTS(P_INDEX).NAME
            || '/Encoding/WinAnsiEncoding' -- code page 1252
            );
        END IF;
--

        IF
            G_FONTS(P_INDEX).CID
        THEN
            T_SELF := ADD_OBJECT;
            TXT2PDFDOC('<</Type/Font/Subtype/Type0/Encoding/Identity-H'
            || '/BaseFont/'
            || G_FONTS(P_INDEX).NAME
            || '/DescendantFonts '
            || TO_CHAR(T_SELF + 1)
            || ' 0 R'
            || '/ToUnicode '
            || TO_CHAR(T_SELF + 8)
            || ' 0 R'
            || '>>');

            TXT2PDFDOC('endobj');
            ADD_OBJECT;
            TXT2PDFDOC('['
            || TO_CHAR(T_SELF + 2)
            || ' 0 R]');
            TXT2PDFDOC('endobj');
            ADD_OBJECT('/Type/Font/Subtype/CIDFontType2/CIDToGIDMap/Identity/DW 1000'
            || '/BaseFont/'
            || G_FONTS(P_INDEX).NAME
            || '/CIDSystemInfo '
            || TO_CHAR(T_SELF + 3)
            || ' 0 R'
            || '/W '
            || TO_CHAR(T_SELF + 4)
            || ' 0 R'
            || '/FontDescriptor '
            || TO_CHAR(T_SELF + 5)
            || ' 0 R');

            ADD_OBJECT('/Ordering(Identity) /Registry(Adobe) /Supplement 0');
--
            T_UTF16_CHARSET := SUBSTR(G_FONTS(P_INDEX).CHARSET,1,INSTR(G_FONTS(P_INDEX).CHARSET,'.') )
            || 'AL16UTF16';

            T_USED_GLYPHS := G_FONTS(P_INDEX).USED_CHARS;
            T_USED_GLYPHS(0) := 0;
            T_USED := T_USED_GLYPHS.FIRST ();
            WHILE T_USED IS NOT NULL LOOP
                IF
                    G_FONTS(P_INDEX).HMETRICS.EXISTS(T_USED)
                THEN
                    T_WIDTH := G_FONTS(P_INDEX).HMETRICS(T_USED);
                ELSE
                    T_WIDTH := G_FONTS(P_INDEX).HMETRICS(G_FONTS(P_INDEX).HMETRICS.LAST() );
                END IF;

                T_WIDTH := TRUNC(T_WIDTH * G_FONTS(P_INDEX).UNIT_NORM);
                IF
                    T_USED_GLYPHS.PRIOR(T_USED) = T_USED - 1
                THEN
                    T_W := T_W
                    || ' '
                    || T_WIDTH;
                ELSE
                    T_W := T_W
                    || '] '
                    || T_USED
                    || ' ['
                    || T_WIDTH;
                END IF;

                T_USED := T_USED_GLYPHS.NEXT(T_USED);
            END LOOP;

            T_W := '['
            || LTRIM(T_W,'] ')
            || ']]';
            ADD_OBJECT;
            TXT2PDFDOC(T_W);
            TXT2PDFDOC('endobj');
            ADD_OBJECT('/Type/FontDescriptor'
            || '/FontName/'
            || G_FONTS(P_INDEX).NAME
            || '/Flags '
            || G_FONTS(P_INDEX).FLAGS
            || '/FontBBox ['
            || G_FONTS(P_INDEX).BB_XMIN
            || ' '
            || G_FONTS(P_INDEX).BB_YMIN
            || ' '
            || G_FONTS(P_INDEX).BB_XMAX
            || ' '
            || G_FONTS(P_INDEX).BB_YMAX
            || ']'
            || '/ItalicAngle '
            || TO_CHAR_ROUND(G_FONTS(P_INDEX).ITALIC_ANGLE)
            || '/Ascent '
            || G_FONTS(P_INDEX).ASCENT
            || '/Descent '
            || G_FONTS(P_INDEX).DESCENT
            || '/CapHeight '
            || G_FONTS(P_INDEX).CAPHEIGHT
            || '/StemV '
            || G_FONTS(P_INDEX).STEMV
            || '/FontFile2 '
            || TO_CHAR(T_SELF + 6)
            || ' 0 R');

            T_FONTFILE := ADD_STREAM(G_FONTS(P_INDEX).FONTFILE2,'/Length1 '
            || DBMS_LOB.GETLENGTH(G_FONTS(P_INDEX).FONTFILE2),G_FONTS(P_INDEX).COMPRESS_FONT);

            T_FONT_SUBSET := SUBSET_FONT(P_INDEX);
            T_FONTFILE := ADD_STREAM(T_FONT_SUBSET,'/Length1 '
            || DBMS_LOB.GETLENGTH(T_FONT_SUBSET),G_FONTS(P_INDEX).COMPRESS_FONT);

            DECLARE
                T_G2C       TP_PLS_TAB;
                T_CODE      PLS_INTEGER;
                T_C_START   PLS_INTEGER;
                T_MAP       VARCHAR2(32767);
                T_CMAP      VARCHAR2(32767);
                T_COR       PLS_INTEGER;
                T_CNT       PLS_INTEGER;
            BEGIN
                T_CODE := G_FONTS(P_INDEX).CODE2GLYPH.FIRST;
                IF
                    G_FONTS(P_INDEX).FLAGS = 4 -- a symbolic font
                THEN
-- assume code 32, space maps to the first code from the font
                    T_COR := T_CODE - 32;
                ELSE
                    T_COR := 0;
                END IF;

                WHILE T_CODE IS NOT NULL LOOP
                    T_G2C(G_FONTS(P_INDEX).CODE2GLYPH(T_CODE) ) := T_CODE - T_COR;
                    T_CODE := G_FONTS(P_INDEX).CODE2GLYPH.NEXT(T_CODE);
                END LOOP;

                T_CNT := 0;
                T_USED_GLYPHS := G_FONTS(P_INDEX).USED_CHARS;
                T_USED := T_USED_GLYPHS.FIRST ();
                WHILE T_USED IS NOT NULL LOOP
                    T_MAP := T_MAP
                    || '<'
                    || TO_CHAR(T_USED,'FM0XXX')
                    || '> <'
                    || TO_CHAR(T_G2C(T_USED),'FM0XXX')
                    || '>'
                    || CHR(10);

                    IF
                        T_CNT = 99
                    THEN
                        T_CNT := 0;
                        T_CMAP := T_CMAP
                        || CHR(10)
                        || '100 beginbfchar'
                        || CHR(10)
                        || T_MAP
                        || 'endbfchar';

                        T_MAP := '';
                    ELSE
                        T_CNT := T_CNT + 1;
                    END IF;

                    T_USED := T_USED_GLYPHS.NEXT(T_USED);
                END LOOP;

                IF
                    T_CNT > 0
                THEN
                    T_CMAP := T_CNT
                    || ' beginbfchar'
                    || CHR(10)
                    || T_MAP
                    || 'endbfchar';
                END IF;

                T_FONTFILE := ADD_STREAM(UTL_RAW.CAST_TO_RAW('/CIDInit /ProcSet findresource begin 12 dict begin
begincmap
/CIDSystemInfo
<< /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def
/CMapName /Adobe-Identity-UCS def /CMapType 2 def
1 begincodespacerange
<0000> <FFFF>
endcodespacerange
'
                || T_CMAP
                || '
endcmap
CMapName currentdict /CMap defineresource pop
end
end') );

            END;

            RETURN T_SELF;
        END IF;
--

        G_FONTS(P_INDEX).FIRST_CHAR := G_FONTS(P_INDEX).USED_CHARS.FIRST ();

        G_FONTS(P_INDEX).LAST_CHAR := G_FONTS(P_INDEX).USED_CHARS.LAST ();

        T_SELF := ADD_OBJECT;
        TXT2PDFDOC('<</Type /Font '
        || '/Subtype /'
        || G_FONTS(P_INDEX).SUBTYPE
        || ' /BaseFont /'
        || G_FONTS(P_INDEX).NAME
        || ' /FirstChar '
        || G_FONTS(P_INDEX).FIRST_CHAR
        || ' /LastChar '
        || G_FONTS(P_INDEX).LAST_CHAR
        || ' /Widths '
        || TO_CHAR(T_SELF + 1)
        || ' 0 R'
        || ' /FontDescriptor '
        || TO_CHAR(T_SELF + 2)
        || ' 0 R'
        || ' /Encoding '
        || TO_CHAR(T_SELF + 3)
        || ' 0 R'
        || ' >>');

        TXT2PDFDOC('endobj');
        ADD_OBJECT;
        TXT2PDFDOC('[');
        BEGIN
            FOR I IN G_FONTS(P_INDEX).FIRST_CHAR..G_FONTS(P_INDEX).LAST_CHAR LOOP
                TXT2PDFDOC(G_FONTS(P_INDEX).CHAR_WIDTH_TAB(I) );
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('**** '
                || G_FONTS(P_INDEX).NAME);
        END;

        TXT2PDFDOC(']');
        TXT2PDFDOC('endobj');
        ADD_OBJECT('/Type /FontDescriptor'
        || ' /FontName /'
        || G_FONTS(P_INDEX).NAME
        || ' /Flags '
        || G_FONTS(P_INDEX).FLAGS
        || ' /FontBBox ['
        || G_FONTS(P_INDEX).BB_XMIN
        || ' '
        || G_FONTS(P_INDEX).BB_YMIN
        || ' '
        || G_FONTS(P_INDEX).BB_XMAX
        || ' '
        || G_FONTS(P_INDEX).BB_YMAX
        || ']'
        || ' /ItalicAngle '
        || TO_CHAR_ROUND(G_FONTS(P_INDEX).ITALIC_ANGLE)
        || ' /Ascent '
        || G_FONTS(P_INDEX).ASCENT
        || ' /Descent '
        || G_FONTS(P_INDEX).DESCENT
        || ' /CapHeight '
        || G_FONTS(P_INDEX).CAPHEIGHT
        || ' /StemV '
        || G_FONTS(P_INDEX).STEMV
        || CASE
            WHEN G_FONTS(P_INDEX).FONTFILE2 IS NOT NULL THEN ' /FontFile2 '
            || TO_CHAR(T_SELF + 4)
            || ' 0 R'
        END);

        ADD_OBJECT('/Type /Encoding /BaseEncoding /WinAnsiEncoding '
        || G_FONTS(P_INDEX).DIFF
        || ' ');
        IF
            G_FONTS(P_INDEX).FONTFILE2 IS NOT NULL
        THEN
            T_FONT_SUBSET := SUBSET_FONT(P_INDEX);
            T_FONTFILE := ADD_STREAM(T_FONT_SUBSET,'/Length1 '
            || DBMS_LOB.GETLENGTH(T_FONT_SUBSET),G_FONTS(P_INDEX).COMPRESS_FONT);

        END IF;

        RETURN T_SELF;
    END;
--

    PROCEDURE ADD_IMAGE (
        P_IMG TP_IMG
    ) IS
        T_PALLET   NUMBER(10);
    BEGIN
        IF
            P_IMG.COLOR_TAB IS NOT NULL
        THEN
            T_PALLET := ADD_STREAM(P_IMG.COLOR_TAB);
        ELSE
            T_PALLET := ADD_OBJECT;  -- add an empty object
            TXT2PDFDOC('endobj');
        END IF;

        ADD_OBJECT;
        TXT2PDFDOC('<</Type /XObject /Subtype /Image'
        || ' /Width '
        || TO_CHAR(P_IMG.WIDTH)
        || ' /Height '
        || TO_CHAR(P_IMG.HEIGHT)
        || ' /BitsPerComponent '
        || TO_CHAR(P_IMG.COLOR_RES) );
--

        IF
            P_IMG.TRANSPARANCY_INDEX IS NOT NULL
        THEN
            TXT2PDFDOC('/Mask ['
            || P_IMG.TRANSPARANCY_INDEX
            || ' '
            || P_IMG.TRANSPARANCY_INDEX
            || ']');
        END IF;

        IF
            P_IMG.COLOR_TAB IS NULL
        THEN
            IF
                P_IMG.GREYSCALE
            THEN
                TXT2PDFDOC('/ColorSpace /DeviceGray');
            ELSE
                TXT2PDFDOC('/ColorSpace /DeviceRGB');
            END IF;
        ELSE
            TXT2PDFDOC('/ColorSpace [/Indexed /DeviceRGB '
            || TO_CHAR(UTL_RAW.LENGTH(P_IMG.COLOR_TAB) / 3 - 1)
            || ' '
            || TO_CHAR(T_PALLET)
            || ' 0 R]');
        END IF;
--

        IF
            P_IMG.TYPE = 'jpg'
        THEN
            PUT_STREAM(P_IMG.PIXELS,FALSE,'/Filter /DCTDecode',FALSE);
        ELSIF P_IMG.TYPE = 'png' THEN
            PUT_STREAM(P_IMG.PIXELS,FALSE,' /Filter /FlateDecode /DecodeParms <</Predictor 15 '
            || '/Colors '
            || P_IMG.NR_COLORS
            || '/BitsPerComponent '
            || P_IMG.COLOR_RES
            || ' /Columns '
            || P_IMG.WIDTH
            || ' >> ',FALSE);
        ELSE
            PUT_STREAM(P_IMG.PIXELS,P_TAG => FALSE);
        END IF;

        TXT2PDFDOC('endobj');
    END;
--

    FUNCTION ADD_RESOURCES RETURN NUMBER IS
        T_IND     PLS_INTEGER;
        T_SELF    NUMBER(10);
        T_FONTS   TP_OBJECTS_TAB;
    BEGIN
--
        T_IND := G_USED_FONTS.FIRST;
        WHILE T_IND IS NOT NULL LOOP
            T_FONTS(T_IND) := ADD_FONT(T_IND);
            T_IND := G_USED_FONTS.NEXT(T_IND);
        END LOOP;
--

        T_SELF := ADD_OBJECT;
        TXT2PDFDOC('<</ProcSet [/PDF /Text]');
--
        IF
            G_USED_FONTS.COUNT () > 0
        THEN
            TXT2PDFDOC('/Font <<');
            T_IND := G_USED_FONTS.FIRST;
            WHILE T_IND IS NOT NULL LOOP
                TXT2PDFDOC('/F'
                || TO_CHAR(T_IND)
                || ' '
                || TO_CHAR(T_FONTS(T_IND) )
                || ' 0 R');

                T_IND := G_USED_FONTS.NEXT(T_IND);
            END LOOP;

            TXT2PDFDOC('>>');
        END IF;
--

        IF
            G_IMAGES.COUNT () > 0
        THEN
            TXT2PDFDOC('/XObject <<');
            FOR I IN G_IMAGES.FIRST..G_IMAGES.LAST LOOP
                TXT2PDFDOC('/I'
                || TO_CHAR(I)
                || ' '
                || TO_CHAR(T_SELF + 2 * I)
                || ' 0 R');
            END LOOP;

            TXT2PDFDOC('>>');
        END IF;
--

        TXT2PDFDOC('>>');
        TXT2PDFDOC('endobj');
--
        IF
            G_IMAGES.COUNT () > 0
        THEN
            FOR I IN G_IMAGES.FIRST..G_IMAGES.LAST LOOP
                ADD_IMAGE(G_IMAGES(I) );
            END LOOP;
        END IF;

        RETURN T_SELF;
    END;
--

    PROCEDURE ADD_PAGE (
        P_PAGE_IND    PLS_INTEGER,
        P_PARENT      NUMBER,
        P_RESOURCES   NUMBER
    ) IS
        T_CONTENT   NUMBER(10);
    BEGIN
        T_CONTENT := ADD_STREAM(G_PAGES(P_PAGE_IND) );
        ADD_OBJECT;
        TXT2PDFDOC('<< /Type /Page');
        TXT2PDFDOC('/Parent '
        || TO_CHAR(P_PARENT)
        || ' 0 R');
    -- AW: Add a mediabox to each page
        TXT2PDFDOC('/MediaBox [0 0 '
        || TO_CHAR_ROUND(G_SETTINGS_PER_PAGE(P_PAGE_IND).PAGE_WIDTH,0)
        || ' '
        || TO_CHAR_ROUND(G_SETTINGS_PER_PAGE(P_PAGE_IND).PAGE_HEIGHT,0)
        || ']');

        TXT2PDFDOC('/Contents '
        || TO_CHAR(T_CONTENT)
        || ' 0 R');
        TXT2PDFDOC('/Resources '
        || TO_CHAR(P_RESOURCES)
        || ' 0 R');
        TXT2PDFDOC('>>');
        TXT2PDFDOC('endobj');
    END;
--

    FUNCTION ADD_PAGES RETURN NUMBER IS
        T_SELF        NUMBER(10);
        T_RESOURCES   NUMBER(10);
    BEGIN
        T_RESOURCES := ADD_RESOURCES;
        T_SELF := ADD_OBJECT;
        TXT2PDFDOC('<</Type/Pages/Kids [');
--
        FOR I IN G_PAGES.FIRST..G_PAGES.LAST LOOP
            TXT2PDFDOC(TO_CHAR(T_SELF + I * 2 + 2)
            || ' 0 R');
        END LOOP;
--
    -- AW: take the settings from page 1 as global settings

        IF
            G_SETTINGS_PER_PAGE.EXISTS(0)
        THEN
            G_SETTINGS := G_SETTINGS_PER_PAGE(0);
        END IF;

        TXT2PDFDOC(']');
        TXT2PDFDOC('/Count '
        || G_PAGES.COUNT() );
        TXT2PDFDOC('/MediaBox [0 0 '
        || TO_CHAR_ROUND(G_SETTINGS.PAGE_WIDTH,0)
        || ' '
        || TO_CHAR_ROUND(G_SETTINGS.PAGE_HEIGHT,0)
        || ']');

        TXT2PDFDOC('>>');
        TXT2PDFDOC('endobj');
--
        IF
            G_PAGES.COUNT () > 0
        THEN
            FOR I IN G_PAGES.FIRST..G_PAGES.LAST LOOP
                ADD_PAGE(I,T_SELF,T_RESOURCES);
            END LOOP;
        END IF;
--

        RETURN T_SELF;
    END;
--

    FUNCTION ADD_CATALOGUE RETURN NUMBER
        IS
    BEGIN
        RETURN ADD_OBJECT('/Type/Catalog'
        || '/Pages '
        || TO_CHAR(ADD_PAGES)
        || ' 0 R'
        || '/OpenAction [0 /XYZ null null 0.77]');
    END;
--

    FUNCTION ADD_INFO RETURN NUMBER IS
        T_BANNER   VARCHAR2(1000);
    BEGIN
        BEGIN
            SELECT
                'running on '
                || REPLACE(REPLACE(REPLACE(SUBSTR(BANNER,1,950),'\','\\'),'(','\('),')','\)')
            INTO
                T_BANNER
            FROM
                V$VERSION
            WHERE
                INSTR(UPPER(BANNER),'DATABASE') > 0;

            T_BANNER := '/Producer ('
            || T_BANNER
            || ')';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
--

        RETURN ADD_OBJECT(TO_CHAR(SYSDATE,'"/CreationDate (D:"YYYYMMDDhh24miss")"')
        || '/Creator (AS-PDF 0.3.0 by Anton Scheffer)'
        || T_BANNER
        || '/Title <FEFF'
        || UTL_I18N.STRING_TO_RAW(G_INFO.TITLE,'AL16UTF16')
        || '>'
        || '/Author <FEFF'
        || UTL_I18N.STRING_TO_RAW(G_INFO.AUTHOR,'AL16UTF16')
        || '>'
        || '/Subject <FEFF'
        || UTL_I18N.STRING_TO_RAW(G_INFO.SUBJECT,'AL16UTF16')
        || '>'
        || '/Keywords <FEFF'
        || UTL_I18N.STRING_TO_RAW(G_INFO.KEYWORDS,'AL16UTF16')
        || '>');

    END;
--

    PROCEDURE FINISH_PDF IS
        T_XREF        NUMBER;
        T_INFO        NUMBER(10);
        T_CATALOGUE   NUMBER(10);
    BEGIN
        IF
            G_PAGES.COUNT = 0
        THEN
            NEW_PAGE;
        END IF;
        IF
            G_PAGE_PRCS.COUNT > 0
        THEN
            FOR I IN G_PAGES.FIRST..G_PAGES.LAST LOOP
                G_PAGE_NR := I;
                FOR P IN G_PAGE_PRCS.FIRST..G_PAGE_PRCS.LAST LOOP
                    BEGIN
                        EXECUTE IMMEDIATE REPLACE(REPLACE(G_PAGE_PRCS(P),'#PAGE_NR#',I + 1),'"PAGE_COUNT#',G_PAGES.COUNT);

                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                    END;
                END LOOP;

            END LOOP;

        END IF;

        DBMS_LOB.CREATETEMPORARY(G_PDF_DOC,TRUE);
        TXT2PDFDOC('%PDF-1.3');
        RAW2PDFDOC(HEXTORAW('25E2E3CFD30D0A') );          -- add a hex comment
        T_INFO := ADD_INFO;
        T_CATALOGUE := ADD_CATALOGUE;
        T_XREF := DBMS_LOB.GETLENGTH(G_PDF_DOC);
        TXT2PDFDOC('xref');
        TXT2PDFDOC('0 '
        || TO_CHAR(G_OBJECTS.COUNT() ) );
        TXT2PDFDOC('0000000000 65535 f ');
        FOR I IN 1..G_OBJECTS.COUNT () - 1 LOOP
            TXT2PDFDOC(TO_CHAR(G_OBJECTS(I),'fm0000000000')
            || ' 00000 n');
                        -- this line should be exactly 20 bytes, including EOL
        END LOOP;

        TXT2PDFDOC('trailer');
        TXT2PDFDOC('<< /Root '
        || TO_CHAR(T_CATALOGUE)
        || ' 0 R');
        TXT2PDFDOC('/Info '
        || TO_CHAR(T_INFO)
        || ' 0 R');
        TXT2PDFDOC('/Size '
        || TO_CHAR(G_OBJECTS.COUNT() ) );
        TXT2PDFDOC('>>');
        TXT2PDFDOC('startxref');
        TXT2PDFDOC(TO_CHAR(T_XREF) );
        TXT2PDFDOC('%%EOF');
--
        G_OBJECTS.DELETE;
        FOR I IN G_PAGES.FIRST..G_PAGES.LAST LOOP
            DBMS_LOB.FREETEMPORARY(G_PAGES(I) );
        END LOOP;

        G_OBJECTS.DELETE;
        G_PAGES.DELETE;
    -- AW: Page-settings
        G_SETTINGS_PER_PAGE.DELETE;
        G_FONTS.DELETE;
        G_USED_FONTS.DELETE;
        G_PAGE_PRCS.DELETE;
        IF
            G_IMAGES.COUNT () > 0
        THEN
            FOR I IN G_IMAGES.FIRST..G_IMAGES.LAST LOOP
                IF
                    DBMS_LOB.ISTEMPORARY(G_IMAGES(I).PIXELS) = 1
                THEN
                    DBMS_LOB.FREETEMPORARY(G_IMAGES(I).PIXELS);
                END IF;
            END LOOP;

            G_IMAGES.DELETE;
        END IF;

    END;
--

    FUNCTION CONV2UU (
        P_VALUE NUMBER,
        P_UNIT VARCHAR2
    ) RETURN NUMBER IS
        C_INCH   CONSTANT NUMBER := 25.40025;
    BEGIN
        RETURN ROUND(
            CASE LOWER(P_UNIT)
                WHEN 'mm' THEN P_VALUE * 72 / C_INCH
                WHEN 'cm' THEN P_VALUE * 720 / C_INCH
                WHEN 'pt' THEN P_VALUE          -- also point
                WHEN 'point' THEN P_VALUE
                WHEN 'inch' THEN P_VALUE * 72
                WHEN 'in' THEN P_VALUE * 72  -- also inch
                WHEN 'pica' THEN P_VALUE * 12
                WHEN 'p' THEN P_VALUE * 12  -- also pica
                WHEN 'pc' THEN P_VALUE * 12  -- also pica
                WHEN 'em' THEN P_VALUE * 12  -- also pica
                WHEN 'px' THEN P_VALUE       -- pixel voorlopig op point zetten
                WHEN 'px' THEN P_VALUE * 0.8 -- pixel
                ELSE NULL
            END,3);
    END;
--

    PROCEDURE SET_PAGE_SIZE (
        P_WIDTH    NUMBER,
        P_HEIGHT   NUMBER,
        P_UNIT     VARCHAR2 := 'cm'
    )
        IS
    BEGIN
        G_SETTINGS.PAGE_WIDTH := CONV2UU(P_WIDTH,P_UNIT);
        G_SETTINGS.PAGE_HEIGHT := CONV2UU(P_HEIGHT,P_UNIT);
    END;
--

    PROCEDURE SET_PAGE_FORMAT (
        P_FORMAT VARCHAR2 := 'A4'
    )
        IS
    BEGIN
        CASE
            UPPER(P_FORMAT)
            WHEN 'A3' THEN
                SET_PAGE_SIZE(420,297,'mm');
            WHEN 'A4' THEN
                SET_PAGE_SIZE(297,210,'mm');
            WHEN 'A5' THEN
                SET_PAGE_SIZE(210,148,'mm');
            WHEN 'A6' THEN
                SET_PAGE_SIZE(148,105,'mm');
            WHEN 'LEGAL' THEN
                SET_PAGE_SIZE(14,8.5,'in');
            WHEN 'LETTER' THEN
                SET_PAGE_SIZE(11,8.5,'in');
            WHEN 'QUARTO' THEN
                SET_PAGE_SIZE(11,9,'in');
            WHEN 'EXECUTIVE' THEN
                SET_PAGE_SIZE(10.5,7.25,'in');
            ELSE
                NULL;
        END CASE;
    END;
--

    PROCEDURE SET_PAGE_ORIENTATION (
        P_ORIENTATION VARCHAR2 := 'PORTRAIT'
    ) IS
        T_TMP   NUMBER;
    BEGIN
        IF
            ( ( UPPER(P_ORIENTATION) IN (
                'L',
                'LANDSCAPE'
            ) AND G_SETTINGS.PAGE_HEIGHT > G_SETTINGS.PAGE_WIDTH ) OR ( UPPER(P_ORIENTATION) IN (
                'P',
                'PORTRAIT'
            ) AND G_SETTINGS.PAGE_HEIGHT < G_SETTINGS.PAGE_WIDTH ) )
        THEN
            T_TMP := G_SETTINGS.PAGE_WIDTH;
            G_SETTINGS.PAGE_WIDTH := G_SETTINGS.PAGE_HEIGHT;
            G_SETTINGS.PAGE_HEIGHT := T_TMP;
        END IF;
    END;
--

    PROCEDURE SET_MARGINS (
        P_TOP      NUMBER := NULL,
        P_LEFT     NUMBER := NULL,
        P_BOTTOM   NUMBER := NULL,
        P_RIGHT    NUMBER := NULL,
        P_UNIT     VARCHAR2 := 'cm'
    ) IS
        T_TMP   NUMBER;
    BEGIN
        T_TMP := NVL(CONV2UU(P_TOP,P_UNIT),-1);
        IF
            T_TMP < 0 OR T_TMP > G_SETTINGS.PAGE_HEIGHT
        THEN
            T_TMP := CONV2UU(3,'cm');
        END IF;

        G_SETTINGS.MARGIN_TOP := T_TMP;
        T_TMP := NVL(CONV2UU(P_BOTTOM,P_UNIT),-1);
        IF
            T_TMP < 0 OR T_TMP > G_SETTINGS.PAGE_HEIGHT
        THEN
            T_TMP := CONV2UU(4,'cm');
        END IF;

        G_SETTINGS.MARGIN_BOTTOM := T_TMP;
        T_TMP := NVL(CONV2UU(P_LEFT,P_UNIT),-1);
        IF
            T_TMP < 0 OR T_TMP > G_SETTINGS.PAGE_WIDTH
        THEN
            T_TMP := CONV2UU(1,'cm');
        END IF;

        G_SETTINGS.MARGIN_LEFT := T_TMP;
        T_TMP := NVL(CONV2UU(P_RIGHT,P_UNIT),-1);
        IF
            T_TMP < 0 OR T_TMP > G_SETTINGS.PAGE_WIDTH
        THEN
            T_TMP := CONV2UU(1,'cm');
        END IF;

        G_SETTINGS.MARGIN_RIGHT := T_TMP;
--
        IF
            G_SETTINGS.MARGIN_TOP + G_SETTINGS.MARGIN_BOTTOM + CONV2UU(1,'cm') > G_SETTINGS.PAGE_HEIGHT
        THEN
            G_SETTINGS.MARGIN_TOP := 0;
            G_SETTINGS.MARGIN_BOTTOM := 0;
        END IF;

        IF
            G_SETTINGS.MARGIN_LEFT + G_SETTINGS.MARGIN_RIGHT + CONV2UU(1,'cm') > G_SETTINGS.PAGE_WIDTH
        THEN
            G_SETTINGS.MARGIN_LEFT := 0;
            G_SETTINGS.MARGIN_RIGHT := 0;
        END IF;

    END;
--

    PROCEDURE SET_INFO (
        P_TITLE      VARCHAR2 := NULL,
        P_AUTHOR     VARCHAR2 := NULL,
        P_SUBJECT    VARCHAR2 := NULL,
        P_KEYWORDS   VARCHAR2 := NULL
    )
        IS
    BEGIN
        G_INFO.TITLE := SUBSTR(P_TITLE,1,1024);
        G_INFO.AUTHOR := SUBSTR(P_AUTHOR,1,1024);
        G_INFO.SUBJECT := SUBSTR(P_SUBJECT,1,1024);
        G_INFO.KEYWORDS := SUBSTR(P_KEYWORDS,1,16383);
    END;
--

    PROCEDURE INIT
        IS
    BEGIN
        G_OBJECTS.DELETE;
        G_PAGES.DELETE;
    -- AW: Page-settings
        G_SETTINGS_PER_PAGE.DELETE;
        G_FONTS.DELETE;
        G_USED_FONTS.DELETE;
        G_PAGE_PRCS.DELETE;
        G_IMAGES.DELETE;
        G_SETTINGS := NULL;
        G_CURRENT_FONT := NULL;
        G_X := NULL;
        G_Y := NULL;
        G_INFO := NULL;
        G_PAGE_NR := NULL;
        G_OBJECTS(0) := 0;
        INIT_CORE_FONTS;
        SET_PAGE_FORMAT;
        SET_PAGE_ORIENTATION;
        SET_MARGINS;
    END;
--

    FUNCTION GET_PDF RETURN BLOB
        IS
    BEGIN
        FINISH_PDF;
        RETURN G_PDF_DOC;
    END;
--

    PROCEDURE SAVE_PDF (
        P_DIR        VARCHAR2 := 'MY_DIR',
        P_FILENAME   VARCHAR2 := 'my.pdf',
        P_FREEBLOB   BOOLEAN := TRUE
    ) IS
        T_FH    UTL_FILE.FILE_TYPE;
        T_LEN   PLS_INTEGER := 32767;
    BEGIN
        FINISH_PDF;
        T_FH := UTL_FILE.FOPEN(P_DIR,P_FILENAME,'wb');
        FOR I IN 0..TRUNC( (DBMS_LOB.GETLENGTH(G_PDF_DOC) - 1) / T_LEN) LOOP
            UTL_FILE.PUT_RAW(T_FH,DBMS_LOB.SUBSTR(G_PDF_DOC,T_LEN,I * T_LEN + 1) );
        END LOOP;

        UTL_FILE.FCLOSE(T_FH);
        IF
            P_FREEBLOB
        THEN
            DBMS_LOB.FREETEMPORARY(G_PDF_DOC);
        END IF;
    END;
--

    PROCEDURE RAW2PAGE (
        P_TXT RAW
    )
        IS
    BEGIN
        IF
            G_PAGES.COUNT () = 0
        THEN
            NEW_PAGE;
        END IF;
        DBMS_LOB.APPEND(G_PAGES(COALESCE(G_PAGE_NR,G_PAGES.COUNT() - 1) ),UTL_RAW.CONCAT(P_TXT,HEXTORAW('0D0A') ) );

    END;
--

    PROCEDURE TXT2PAGE (
        P_TXT VARCHAR2
    )
        IS
    BEGIN
        RAW2PAGE(UTL_RAW.CAST_TO_RAW(P_TXT) );
    END;
--

    PROCEDURE OUTPUT_FONT_TO_DOC (
        P_OUTPUT_TO_DOC BOOLEAN
    )
        IS
    BEGIN
        IF
            P_OUTPUT_TO_DOC
        THEN
            TXT2PAGE('BT /F'
            || G_CURRENT_FONT
            || ' '
            || TO_CHAR_ROUND(G_FONTS(G_CURRENT_FONT).FONTSIZE)
            || ' Tf ET');

        END IF;
    END;
--

    PROCEDURE SET_FONT (
        P_INDEX           PLS_INTEGER,
        P_FONTSIZE_PT     NUMBER,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    )
        IS
    BEGIN
        IF
            P_INDEX IS NOT NULL
        THEN
            G_USED_FONTS(P_INDEX) := 0;
            G_FONTS(P_INDEX).FONTSIZE := P_FONTSIZE_PT;
            G_CURRENT_FONT_RECORD.FONTSIZE := P_FONTSIZE_PT;
            IF
                NVL(G_CURRENT_FONT,-1) != P_INDEX
            THEN -- aw set only if different
                G_CURRENT_FONT := P_INDEX;
                G_CURRENT_FONT_RECORD := G_FONTS(P_INDEX);
            END IF;

            OUTPUT_FONT_TO_DOC(P_OUTPUT_TO_DOC);
        END IF;
    END;
--

    FUNCTION SET_FONT (
        P_FONTNAME        VARCHAR2,
        P_FONTSIZE_PT     NUMBER,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    ) RETURN PLS_INTEGER IS
        T_FONTNAME   VARCHAR2(100);
    BEGIN
        IF
            P_FONTNAME IS NULL
        THEN
            IF
                ( G_CURRENT_FONT IS NOT NULL AND P_FONTSIZE_PT != G_FONTS(G_CURRENT_FONT).FONTSIZE )
            THEN
                G_FONTS(G_CURRENT_FONT).FONTSIZE := P_FONTSIZE_PT;
                G_CURRENT_FONT_RECORD := G_FONTS(G_CURRENT_FONT);
                OUTPUT_FONT_TO_DOC(P_OUTPUT_TO_DOC);
            END IF;

            RETURN G_CURRENT_FONT;
        END IF;
--

        T_FONTNAME := LOWER(P_FONTNAME);
        FOR I IN G_FONTS.FIRST..G_FONTS.LAST LOOP
            IF
                LOWER(G_FONTS(I).FONTNAME) = T_FONTNAME
            THEN
                EXIT WHEN G_CURRENT_FONT = I AND G_FONTS(I).FONTSIZE = P_FONTSIZE_PT AND G_PAGE_NR IS NULL;

                G_FONTS(I).FONTSIZE := COALESCE(P_FONTSIZE_PT,G_FONTS(NVL(G_CURRENT_FONT,I) ).FONTSIZE,12);

                G_CURRENT_FONT := I;
                G_CURRENT_FONT_RECORD := G_FONTS(I);
                G_USED_FONTS(I) := 0;
                OUTPUT_FONT_TO_DOC(P_OUTPUT_TO_DOC);
                RETURN G_CURRENT_FONT;
            END IF;
        END LOOP;

        RETURN NULL;
    END;
--

    PROCEDURE SET_FONT (
        P_FONTNAME        VARCHAR2,
        P_FONTSIZE_PT     NUMBER,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    ) IS
        T_DUMMY   PLS_INTEGER;
    BEGIN
        T_DUMMY := SET_FONT(P_FONTNAME,P_FONTSIZE_PT,P_OUTPUT_TO_DOC);
    END;
--

    FUNCTION SET_FONT (
        P_FAMILY          VARCHAR2,
        P_STYLE           VARCHAR2 := 'N',
        P_FONTSIZE_PT     NUMBER := NULL,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    ) RETURN PLS_INTEGER IS
        T_FAMILY   VARCHAR2(100);
        T_STYLE    VARCHAR2(100);
    BEGIN
        IF
            P_FAMILY IS NULL AND G_CURRENT_FONT IS NULL
        THEN
            RETURN NULL;
        END IF;
        IF
            P_FAMILY IS NULL AND P_STYLE IS NULL AND P_FONTSIZE_PT IS NULL
        THEN
            RETURN NULL;
        END IF;

        T_FAMILY := COALESCE(LOWER(P_FAMILY),G_FONTS(G_CURRENT_FONT).FAMILY);
        T_STYLE := UPPER(P_STYLE);
        T_STYLE :=
            CASE T_STYLE
                WHEN 'NORMAL' THEN 'N'
                WHEN 'REGULAR' THEN 'N'
                WHEN 'BOLD' THEN 'B'
                WHEN 'ITALIC' THEN 'I'
                WHEN 'OBLIQUE' THEN 'I'
                ELSE T_STYLE
            END;

        T_STYLE := COALESCE(T_STYLE,
            CASE
                WHEN G_CURRENT_FONT IS NULL THEN 'N'
                ELSE G_FONTS(G_CURRENT_FONT).STYLE
            END
        );
--

        FOR I IN G_FONTS.FIRST..G_FONTS.LAST LOOP
            IF
                ( G_FONTS(I).FAMILY = T_FAMILY AND G_FONTS(I).STYLE = T_STYLE )
            THEN
                RETURN SET_FONT(G_FONTS(I).FONTNAME,P_FONTSIZE_PT,P_OUTPUT_TO_DOC);
            END IF;
        END LOOP;

        RETURN NULL;
    END;
--

    PROCEDURE SET_FONT (
        P_FAMILY          VARCHAR2,
        P_STYLE           VARCHAR2 := 'N',
        P_FONTSIZE_PT     NUMBER := NULL,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    ) IS
        T_DUMMY   PLS_INTEGER;
    BEGIN
        T_DUMMY := SET_FONT(P_FAMILY,P_STYLE,P_FONTSIZE_PT,P_OUTPUT_TO_DOC);
    END;
--

    PROCEDURE NEW_PAGE
        IS
    BEGIN
        G_PAGES(G_PAGES.COUNT() ) := NULL;
        G_SETTINGS_PER_PAGE(G_SETTINGS_PER_PAGE.COUNT() ) := G_SETTINGS;
        DBMS_LOB.CREATETEMPORARY(G_PAGES(G_PAGES.COUNT() - 1),TRUE);
        IF
            G_CURRENT_FONT IS NOT NULL AND G_PAGES.COUNT () > 0
        THEN
            TXT2PAGE('BT /F'
            || G_CURRENT_FONT
            || ' '
            || TO_CHAR_ROUND(G_FONTS(G_CURRENT_FONT).FONTSIZE)
            || ' Tf ET');
        END IF;

        G_X := NULL;
        G_Y := NULL;
    END;
--

    FUNCTION PDF_STRING (
        P_TXT IN BLOB
    ) RETURN BLOB IS

        T_RV      BLOB;
        T_IND     INTEGER;
        TYPE TP_TAB_RAW IS
            TABLE OF RAW(1);
        TAB_RAW   TP_TAB_RAW := TP_TAB_RAW(UTL_RAW.CAST_TO_RAW('\'),UTL_RAW.CAST_TO_RAW('('),UTL_RAW.CAST_TO_RAW(')') );
    BEGIN
        T_RV := P_TXT;
        FOR I IN TAB_RAW.FIRST..TAB_RAW.LAST LOOP
            T_IND :=-1;
            LOOP
                T_IND := DBMS_LOB.INSTR(T_RV,TAB_RAW(I),T_IND + 2);

                EXIT WHEN T_IND <= 0;
                DBMS_LOB.COPY(T_RV,T_RV,DBMS_LOB.LOBMAXSIZE,T_IND + 1,T_IND);

                DBMS_LOB.COPY(T_RV,UTL_RAW.CAST_TO_RAW('\'),1,T_IND,1);

            END LOOP;

        END LOOP;

        RETURN T_RV;
    END;
--

    FUNCTION TXT2RAW (
        P_TXT VARCHAR2
    ) RETURN RAW IS
        T_RV        RAW(32767);
        T_UNICODE   PLS_INTEGER;
    BEGIN
        IF
            G_CURRENT_FONT IS NULL
        THEN
            SET_FONT('helvetica');
        END IF;
        IF
            G_FONTS(G_CURRENT_FONT).CID
        THEN
            FOR I IN 1..LENGTH(P_TXT) LOOP
                T_UNICODE := UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(SUBSTR(P_TXT,I,1) ),'AMERICAN_AMERICA.AL16UTF16',SYS_CONTEXT
('userenv','LANGUAGE')  -- ???? font characterset ?????
                 ) );

                IF
                    G_FONTS(G_CURRENT_FONT).FLAGS = 4 -- a symbolic font
                THEN
-- assume code 32, space maps to the first code from the font
                    T_UNICODE := G_FONTS(G_CURRENT_FONT).CODE2GLYPH.FIRST + T_UNICODE - 32;
                END IF;

                IF
                    G_CURRENT_FONT_RECORD.CODE2GLYPH.EXISTS(T_UNICODE)
                THEN
                    G_FONTS(G_CURRENT_FONT).USED_CHARS(G_CURRENT_FONT_RECORD.CODE2GLYPH(T_UNICODE) ) := 0;
                    T_RV := UTL_RAW.CONCAT(T_RV,UTL_RAW.CAST_TO_RAW(TO_CHAR(G_CURRENT_FONT_RECORD.CODE2GLYPH(T_UNICODE),'FM0XXX') ) );

                ELSE
                    T_RV := UTL_RAW.CONCAT(T_RV,UTL_RAW.CAST_TO_RAW('0000') );
                END IF;

            END LOOP;

            T_RV := UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW('<'),T_RV,UTL_RAW.CAST_TO_RAW('>') );

        ELSE
            T_RV := UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(P_TXT),G_FONTS(G_CURRENT_FONT).CHARSET,SYS_CONTEXT('userenv','LANGUAGE') );

            FOR I IN 1..UTL_RAW.LENGTH(T_RV) LOOP
                G_FONTS(G_CURRENT_FONT).USED_CHARS(RAW2NUM(T_RV,I,1) ) := 0;
            END LOOP;

            T_RV := UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW('('),PDF_STRING(T_RV),UTL_RAW.CAST_TO_RAW(')') );

        END IF;

        RETURN T_RV;
    END;
--

    PROCEDURE PUT_RAW (
        P_X                  NUMBER,
        P_Y                  NUMBER,
        P_TXT                RAW,
        P_DEGREES_ROTATION   NUMBER := NULL
    ) IS

        C_PI    CONSTANT NUMBER := 3.14159265358979323846264338327950288419716939937510;
        T_TMP   VARCHAR2(32767);
        T_SIN   NUMBER;
        T_COS   NUMBER;
    BEGIN
        T_TMP := TO_CHAR_ROUND(P_X)
        || ' '
        || TO_CHAR_ROUND(P_Y);
        IF
            P_DEGREES_ROTATION IS NULL
        THEN
            T_TMP := T_TMP
            || ' Td ';
        ELSE
            T_SIN := SIN(P_DEGREES_ROTATION / 180 * C_PI);
            T_COS := COS(P_DEGREES_ROTATION / 180 * C_PI);
            T_TMP := TO_CHAR_ROUND(T_COS,5)
            || ' '
            || T_TMP;
            T_TMP := TO_CHAR_ROUND(-T_SIN,5)
            || ' '
            || T_TMP;
            T_TMP := TO_CHAR_ROUND(T_SIN,5)
            || ' '
            || T_TMP;
            T_TMP := TO_CHAR_ROUND(T_COS,5)
            || ' '
            || T_TMP;
            T_TMP := T_TMP
            || ' Tm ';
        END IF;

        RAW2PAGE(UTL_RAW.CONCAT(UTL_RAW.CAST_TO_RAW('BT '
        || T_TMP),P_TXT,UTL_RAW.CAST_TO_RAW(' Tj ET') ) );

    END;
--

    PROCEDURE PUT_TXT (
        P_X                  NUMBER,
        P_Y                  NUMBER,
        P_TXT                VARCHAR2,
        P_DEGREES_ROTATION   NUMBER := NULL
    )
        IS
    BEGIN
        IF
            P_TXT IS NOT NULL
        THEN
            PUT_RAW(P_X,P_Y,TXT2RAW(P_TXT),P_DEGREES_ROTATION);
        END IF;
    END;
--

    FUNCTION STR_LEN (
        P_TXT IN VARCHAR2
    ) RETURN NUMBER IS
        T_WIDTH   NUMBER;
        T_CHAR    PLS_INTEGER;
        T_RTXT    RAW(32767);
        T_TMP     NUMBER;
    --t_font tp_font;
    BEGIN
        IF
            P_TXT IS NULL
        THEN
            RETURN 0;
        END IF;
--
        T_WIDTH := 0;
        IF
            G_CURRENT_FONT_RECORD.CID
        THEN
            T_RTXT := UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(P_TXT),'AMERICAN_AMERICA.AL16UTF16' -- 16 bit font => 2 bytes per char
           ,SYS_CONTEXT('userenv','LANGUAGE')  -- ???? font characterset ?????
             );

            FOR I IN 1..UTL_RAW.LENGTH(T_RTXT) / 2 LOOP
                T_CHAR := TO_NUMBER(UTL_RAW.SUBSTR(T_RTXT,I * 2 - 1,2),'xxxx');

                IF
                    G_CURRENT_FONT_RECORD.FLAGS = 4
                THEN
-- assume code 32, space maps to the first code from the font
                    T_CHAR := G_CURRENT_FONT_RECORD.CODE2GLYPH.FIRST + T_CHAR - 32;
                END IF;

                IF
                    ( G_CURRENT_FONT_RECORD.CODE2GLYPH.EXISTS(T_CHAR) AND G_CURRENT_FONT_RECORD.HMETRICS.EXISTS(G_CURRENT_FONT_RECORD.CODE2GLYPH(T_CHAR)
) )
                THEN
                    T_TMP := G_CURRENT_FONT_RECORD.HMETRICS(G_CURRENT_FONT_RECORD.CODE2GLYPH(T_CHAR) );
                ELSE
                    T_TMP := G_CURRENT_FONT_RECORD.HMETRICS(G_CURRENT_FONT_RECORD.HMETRICS.LAST() );
                END IF;

                T_WIDTH := T_WIDTH + T_TMP;
            END LOOP;

            T_WIDTH := T_WIDTH * G_CURRENT_FONT_RECORD.UNIT_NORM;
            T_WIDTH := T_WIDTH * G_CURRENT_FONT_RECORD.FONTSIZE / 1000;
        ELSE
            T_RTXT := UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(P_TXT),G_CURRENT_FONT_RECORD.CHARSET  -- should be an 8 bit font
           ,SYS_CONTEXT('userenv','LANGUAGE') );

            FOR I IN 1..UTL_RAW.LENGTH(T_RTXT) LOOP
                T_CHAR := TO_NUMBER(UTL_RAW.SUBSTR(T_RTXT,I,1),'xx');

                T_WIDTH := T_WIDTH + G_CURRENT_FONT_RECORD.CHAR_WIDTH_TAB(T_CHAR);
            END LOOP;

            T_WIDTH := T_WIDTH * G_CURRENT_FONT_RECORD.FONTSIZE / 1000;
        END IF;

        RETURN T_WIDTH;
    END;
--

    PROCEDURE WRITE (
        P_TXT           IN VARCHAR2,
        P_X             IN NUMBER := NULL,
        P_Y             IN NUMBER := NULL,
        P_LINE_HEIGHT   IN NUMBER := NULL,
        P_START         IN NUMBER := NULL  -- left side of the available text box
       ,
        P_WIDTH         IN NUMBER := NULL  -- width of the available text box
       ,
        P_ALIGNMENT     IN VARCHAR2 := NULL
    ) IS

        T_LINE_HEIGHT   NUMBER;
        T_X             NUMBER;
        T_Y             NUMBER;
        T_START         NUMBER;
        T_WIDTH         NUMBER;
        T_LEN           NUMBER;
        T_CNT           PLS_INTEGER;
        T_IND           PLS_INTEGER;
        T_ALIGNMENT     VARCHAR2(100);
    BEGIN
        IF
            P_TXT IS NULL
        THEN
            RETURN;
        END IF;
--
        IF
            G_CURRENT_FONT IS NULL
        THEN
            SET_FONT('helvetica');
        END IF;
--
        T_LINE_HEIGHT := NVL(P_LINE_HEIGHT,G_FONTS(G_CURRENT_FONT).FONTSIZE);
        IF
            ( T_LINE_HEIGHT < G_FONTS(G_CURRENT_FONT).FONTSIZE OR T_LINE_HEIGHT > ( G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT ) / 4 )
        THEN
            T_LINE_HEIGHT := G_FONTS(G_CURRENT_FONT).FONTSIZE;
        END IF;

        T_START := NVL(P_START,G_SETTINGS.MARGIN_LEFT);
        IF
            ( T_START < G_SETTINGS.MARGIN_LEFT OR T_START > G_SETTINGS.PAGE_WIDTH - G_SETTINGS.MARGIN_RIGHT - G_SETTINGS.MARGIN_LEFT )
        THEN
            T_START := G_SETTINGS.MARGIN_LEFT;
        END IF;

        T_WIDTH := NVL(P_WIDTH,G_SETTINGS.PAGE_WIDTH - G_SETTINGS.MARGIN_RIGHT - G_SETTINGS.MARGIN_LEFT);

        IF
            ( T_WIDTH < STR_LEN('   ') OR T_WIDTH > G_SETTINGS.PAGE_WIDTH - G_SETTINGS.MARGIN_RIGHT - G_SETTINGS.MARGIN_LEFT )
        THEN
            T_WIDTH := G_SETTINGS.PAGE_WIDTH - G_SETTINGS.MARGIN_RIGHT - G_SETTINGS.MARGIN_LEFT;
        END IF;

        T_X := COALESCE(P_X,G_X,G_SETTINGS.MARGIN_LEFT);
        T_Y := COALESCE(P_Y,G_Y,G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT);

        IF
            T_Y < 0
        THEN
            T_Y := COALESCE(G_Y,G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT) - T_LINE_HEIGHT;
        END IF;

        IF
            T_X > T_START + T_WIDTH
        THEN
            T_X := T_START;
            T_Y := T_Y - T_LINE_HEIGHT;
        ELSIF T_X < T_START THEN
            T_X := T_START;
        END IF;

        IF
            T_Y < G_SETTINGS.MARGIN_BOTTOM
        THEN
            NEW_PAGE;
            T_X := T_START;
            T_Y := G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT;
        END IF;
--

        T_IND := INSTR(P_TXT,CHR(10) );
        IF
            T_IND > 0
        THEN
            G_X := T_X;
            G_Y := T_Y;
            WRITE(RTRIM(SUBSTR(P_TXT,1,T_IND - 1),CHR(13) ),T_X,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);

            T_Y := G_Y - T_LINE_HEIGHT;
            IF
                T_Y < G_SETTINGS.MARGIN_BOTTOM
            THEN
                NEW_PAGE;
                T_Y := G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT;
            END IF;

            G_X := T_START;
            G_Y := T_Y;
            WRITE(SUBSTR(P_TXT,T_IND + 1),T_START,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);

            RETURN;
        END IF;
--

        T_LEN := STR_LEN(P_TXT);
        IF
            T_LEN <= T_WIDTH - T_X + T_START
        THEN
            T_ALIGNMENT := LOWER(SUBSTR(P_ALIGNMENT,1,100) );
            IF
                INSTR(T_ALIGNMENT,'right') > 0 OR INSTR(T_ALIGNMENT,'end') > 0
            THEN
                T_X := T_START + T_WIDTH - T_LEN;
            ELSIF INSTR(T_ALIGNMENT,'center') > 0 THEN
                T_X := ( T_WIDTH + T_X + T_START - T_LEN ) / 2;
            END IF;

            PUT_TXT(T_X,T_Y,P_TXT);
            G_X := T_X + T_LEN + STR_LEN(' ');
            G_Y := T_Y;
            RETURN;
        END IF;
--

        T_CNT := 0;
        WHILE ( INSTR(P_TXT,' ',1,T_CNT + 1) > 0 AND STR_LEN(SUBSTR(P_TXT,1,INSTR(P_TXT,' ',1,T_CNT + 1) - 1) ) <= T_WIDTH - T_X + T_START ) LOOP
            T_CNT := T_CNT + 1;
        END LOOP;

        IF
            T_CNT > 0
        THEN
            T_IND := INSTR(P_TXT,' ',1,T_CNT);
            WRITE(SUBSTR(P_TXT,1,T_IND - 1),T_X,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);

            T_Y := T_Y - T_LINE_HEIGHT;
            IF
                T_Y < G_SETTINGS.MARGIN_BOTTOM
            THEN
                NEW_PAGE;
                T_Y := G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT;
            END IF;

            WRITE(SUBSTR(P_TXT,T_IND + 1),T_START,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);

            RETURN;
        END IF;
--

        IF
            T_X > T_START AND T_LEN < T_WIDTH
        THEN
            T_Y := T_Y - T_LINE_HEIGHT;
            IF
                T_Y < G_SETTINGS.MARGIN_BOTTOM
            THEN
                NEW_PAGE;
                T_Y := G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT;
            END IF;

            WRITE(P_TXT,T_START,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);
        ELSE
            IF
                LENGTH(P_TXT) = 1
            THEN
                IF
                    T_X > T_START
                THEN
                    T_Y := T_Y - T_LINE_HEIGHT;
                    IF
                        T_Y < G_SETTINGS.MARGIN_BOTTOM
                    THEN
                        NEW_PAGE;
                        T_Y := G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT;
                    END IF;

                END IF;

                WRITE(P_TXT,T_X,T_Y,T_LINE_HEIGHT,T_START,T_LEN);
            ELSE
                T_IND := 2; -- start with 2 to make sure we get amaller string!
                WHILE STR_LEN(SUBSTR(P_TXT,1,T_IND) ) <= T_WIDTH - T_X + T_START LOOP
                    T_IND := T_IND + 1;
                END LOOP;

                WRITE(SUBSTR(P_TXT,1,T_IND - 1),T_X,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);

                T_Y := T_Y - T_LINE_HEIGHT;
                IF
                    T_Y < G_SETTINGS.MARGIN_BOTTOM
                THEN
                    NEW_PAGE;
                    T_Y := G_SETTINGS.PAGE_HEIGHT - G_SETTINGS.MARGIN_TOP - T_LINE_HEIGHT;
                END IF;

                WRITE(SUBSTR(P_TXT,T_IND),T_START,T_Y,T_LINE_HEIGHT,T_START,T_WIDTH,P_ALIGNMENT);

            END IF;
        END IF;

    END;
--

    FUNCTION LOAD_TTF_FONT (
        P_FONT       BLOB,
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE,
        P_OFFSET     NUMBER := 1
    ) RETURN PLS_INTEGER IS

        THIS_FONT      TP_FONT;
        TYPE TP_FONT_TABLE IS RECORD ( OFFSET         PLS_INTEGER,
        LENGTH         PLS_INTEGER );
        TYPE TP_TABLES IS
            TABLE OF TP_FONT_TABLE INDEX BY VARCHAR2(4);
        T_TABLES       TP_TABLES;
        T_TAG          VARCHAR2(4);
        T_BLOB         BLOB;
        T_OFFSET       PLS_INTEGER;
        NR_HMETRICS    PLS_INTEGER;
        SUBTYPE TP_GLYPHNAME IS VARCHAR2(250);
        TYPE TP_GLYPHNAMES IS
            TABLE OF TP_GLYPHNAME INDEX BY PLS_INTEGER;
        T_GLYPHNAMES   TP_GLYPHNAMES;
        T_GLYPH2NAME   TP_PLS_TAB;
        T_FONT_IND     PLS_INTEGER;
    BEGIN
        IF
            DBMS_LOB.SUBSTR(P_FONT,4,P_OFFSET) != HEXTORAW('00010000') --  OpenType Font
        THEN
            RETURN NULL;
        END IF;

        FOR I IN 1..BLOB2NUM(P_FONT,2,P_OFFSET + 4) LOOP
            T_TAG := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(P_FONT,4,P_OFFSET - 4 + I * 16) );

            T_TABLES(T_TAG).OFFSET := BLOB2NUM(P_FONT,4,P_OFFSET + 4 + I * 16) + 1;

            T_TABLES(T_TAG).LENGTH := BLOB2NUM(P_FONT,4,P_OFFSET + 8 + I * 16);

        END LOOP;
--

        IF
            ( NOT T_TABLES.EXISTS('cmap') OR NOT T_TABLES.EXISTS('glyf') OR NOT T_TABLES.EXISTS('head') OR NOT T_TABLES.EXISTS('hhea') OR NOT T_TABLES.EXISTS
('hmtx') OR NOT T_TABLES.EXISTS('loca') OR NOT T_TABLES.EXISTS('maxp') OR NOT T_TABLES.EXISTS('name') OR NOT T_TABLES.EXISTS('post') )
        THEN
            RETURN NULL;
        END IF;
--

        DBMS_LOB.CREATETEMPORARY(T_BLOB,TRUE);
        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('maxp').LENGTH,1,T_TABLES('maxp').OFFSET);

        THIS_FONT.NUMGLYPHS := BLOB2NUM(T_BLOB,2,5);
--
        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('cmap').LENGTH,1,T_TABLES('cmap').OFFSET);

        FOR I IN 0..BLOB2NUM(T_BLOB,2,3) - 1 LOOP
            IF
                ( DBMS_LOB.SUBSTR(T_BLOB,2,5 + I * 8) = HEXTORAW('0003') -- Windows
                 AND DBMS_LOB.SUBSTR(T_BLOB,2,5 + I * 8 + 2) IN (
                    HEXTORAW('0000') -- Symbol
                   ,
                    HEXTORAW('0001') -- Unicode BMP (UCS-2)
                ) )
            THEN
                IF
                    DBMS_LOB.SUBSTR(T_BLOB,2,5 + I * 8 + 2) = HEXTORAW('0000') -- Symbol
                THEN
                    THIS_FONT.FLAGS := 4; -- symbolic
                ELSE
                    THIS_FONT.FLAGS := 32; -- non-symbolic
                END IF;

                T_OFFSET := BLOB2NUM(T_BLOB,4,5 + I * 8 + 4) + 1;

                IF
                    DBMS_LOB.SUBSTR(T_BLOB,2,T_OFFSET) != HEXTORAW('0004')
                THEN
                    RETURN NULL;
                END IF;

                DECLARE
                    T_SEG_CNT              PLS_INTEGER;
                    T_END_OFFS             PLS_INTEGER;
                    T_START_OFFS           PLS_INTEGER;
                    T_IDDELTA_OFFS         PLS_INTEGER;
                    T_IDRANGEOFFSET_OFFS   PLS_INTEGER;
                    T_TMP                  PLS_INTEGER;
                    T_START                PLS_INTEGER;
                BEGIN
                    T_SEG_CNT := BLOB2NUM(T_BLOB,2,T_OFFSET + 6) / 2;
                    T_END_OFFS := T_OFFSET + 14;
                    T_START_OFFS := T_END_OFFS + T_SEG_CNT * 2 + 2;
                    T_IDDELTA_OFFS := T_START_OFFS + T_SEG_CNT * 2;
                    T_IDRANGEOFFSET_OFFS := T_IDDELTA_OFFS + T_SEG_CNT * 2;
                    FOR SEG IN 0..T_SEG_CNT - 1 LOOP
                        T_TMP := BLOB2NUM(T_BLOB,2,T_IDRANGEOFFSET_OFFS + SEG * 2);
                        IF
                            T_TMP = 0
                        THEN
                            T_TMP := BLOB2NUM(T_BLOB,2,T_IDDELTA_OFFS + SEG * 2);
                            FOR C IN BLOB2NUM(T_BLOB,2,T_START_OFFS + SEG * 2)..BLOB2NUM(T_BLOB,2,T_END_OFFS + SEG * 2) LOOP
                                THIS_FONT.CODE2GLYPH(C) := MOD(C + T_TMP,65536);
                            END LOOP;

                        ELSE
                            T_START := BLOB2NUM(T_BLOB,2,T_START_OFFS + SEG * 2);
                            FOR C IN T_START..BLOB2NUM(T_BLOB,2,T_END_OFFS + SEG * 2) LOOP
                                THIS_FONT.CODE2GLYPH(C) := BLOB2NUM(T_BLOB,2,T_IDRANGEOFFSET_OFFS + T_TMP + (SEG + C - T_START) * 2);
                            END LOOP;

                        END IF;

                    END LOOP;

                END;

                EXIT;
            END IF;
        END LOOP;
--

        T_GLYPHNAMES(0) := '.notdef';
        T_GLYPHNAMES(1) := '.null';
        T_GLYPHNAMES(2) := 'nonmarkingreturn';
        T_GLYPHNAMES(3) := 'space';
        T_GLYPHNAMES(4) := 'exclam';
        T_GLYPHNAMES(5) := 'quotedbl';
        T_GLYPHNAMES(6) := 'numbersign';
        T_GLYPHNAMES(7) := 'dollar';
        T_GLYPHNAMES(8) := 'percent';
        T_GLYPHNAMES(9) := 'ampersand';
        T_GLYPHNAMES(10) := 'quotesingle';
        T_GLYPHNAMES(11) := 'parenleft';
        T_GLYPHNAMES(12) := 'parenright';
        T_GLYPHNAMES(13) := 'asterisk';
        T_GLYPHNAMES(14) := 'plus';
        T_GLYPHNAMES(15) := 'comma';
        T_GLYPHNAMES(16) := 'hyphen';
        T_GLYPHNAMES(17) := 'period';
        T_GLYPHNAMES(18) := 'slash';
        T_GLYPHNAMES(19) := 'zero';
        T_GLYPHNAMES(20) := 'one';
        T_GLYPHNAMES(21) := 'two';
        T_GLYPHNAMES(22) := 'three';
        T_GLYPHNAMES(23) := 'four';
        T_GLYPHNAMES(24) := 'five';
        T_GLYPHNAMES(25) := 'six';
        T_GLYPHNAMES(26) := 'seven';
        T_GLYPHNAMES(27) := 'eight';
        T_GLYPHNAMES(28) := 'nine';
        T_GLYPHNAMES(29) := 'colon';
        T_GLYPHNAMES(30) := 'semicolon';
        T_GLYPHNAMES(31) := 'less';
        T_GLYPHNAMES(32) := 'equal';
        T_GLYPHNAMES(33) := 'greater';
        T_GLYPHNAMES(34) := 'question';
        T_GLYPHNAMES(35) := 'at';
        T_GLYPHNAMES(36) := 'A';
        T_GLYPHNAMES(37) := 'B';
        T_GLYPHNAMES(38) := 'C';
        T_GLYPHNAMES(39) := 'D';
        T_GLYPHNAMES(40) := 'E';
        T_GLYPHNAMES(41) := 'F';
        T_GLYPHNAMES(42) := 'G';
        T_GLYPHNAMES(43) := 'H';
        T_GLYPHNAMES(44) := 'I';
        T_GLYPHNAMES(45) := 'J';
        T_GLYPHNAMES(46) := 'K';
        T_GLYPHNAMES(47) := 'L';
        T_GLYPHNAMES(48) := 'M';
        T_GLYPHNAMES(49) := 'N';
        T_GLYPHNAMES(50) := 'O';
        T_GLYPHNAMES(51) := 'P';
        T_GLYPHNAMES(52) := 'Q';
        T_GLYPHNAMES(53) := 'R';
        T_GLYPHNAMES(54) := 'S';
        T_GLYPHNAMES(55) := 'T';
        T_GLYPHNAMES(56) := 'U';
        T_GLYPHNAMES(57) := 'V';
        T_GLYPHNAMES(58) := 'W';
        T_GLYPHNAMES(59) := 'X';
        T_GLYPHNAMES(60) := 'Y';
        T_GLYPHNAMES(61) := 'Z';
        T_GLYPHNAMES(62) := 'bracketleft';
        T_GLYPHNAMES(63) := 'backslash';
        T_GLYPHNAMES(64) := 'bracketright';
        T_GLYPHNAMES(65) := 'asciicircum';
        T_GLYPHNAMES(66) := 'underscore';
        T_GLYPHNAMES(67) := 'grave';
        T_GLYPHNAMES(68) := 'a';
        T_GLYPHNAMES(69) := 'b';
        T_GLYPHNAMES(70) := 'c';
        T_GLYPHNAMES(71) := 'd';
        T_GLYPHNAMES(72) := 'e';
        T_GLYPHNAMES(73) := 'f';
        T_GLYPHNAMES(74) := 'g';
        T_GLYPHNAMES(75) := 'h';
        T_GLYPHNAMES(76) := 'i';
        T_GLYPHNAMES(77) := 'j';
        T_GLYPHNAMES(78) := 'k';
        T_GLYPHNAMES(79) := 'l';
        T_GLYPHNAMES(80) := 'm';
        T_GLYPHNAMES(81) := 'n';
        T_GLYPHNAMES(82) := 'o';
        T_GLYPHNAMES(83) := 'p';
        T_GLYPHNAMES(84) := 'q';
        T_GLYPHNAMES(85) := 'r';
        T_GLYPHNAMES(86) := 's';
        T_GLYPHNAMES(87) := 't';
        T_GLYPHNAMES(88) := 'u';
        T_GLYPHNAMES(89) := 'v';
        T_GLYPHNAMES(90) := 'w';
        T_GLYPHNAMES(91) := 'x';
        T_GLYPHNAMES(92) := 'y';
        T_GLYPHNAMES(93) := 'z';
        T_GLYPHNAMES(94) := 'braceleft';
        T_GLYPHNAMES(95) := 'bar';
        T_GLYPHNAMES(96) := 'braceright';
        T_GLYPHNAMES(97) := 'asciitilde';
        T_GLYPHNAMES(98) := 'Adieresis';
        T_GLYPHNAMES(99) := 'Aring';
        T_GLYPHNAMES(100) := 'Ccedilla';
        T_GLYPHNAMES(101) := 'Eacute';
        T_GLYPHNAMES(102) := 'Ntilde';
        T_GLYPHNAMES(103) := 'Odieresis';
        T_GLYPHNAMES(104) := 'Udieresis';
        T_GLYPHNAMES(105) := 'aacute';
        T_GLYPHNAMES(106) := 'agrave';
        T_GLYPHNAMES(107) := 'acircumflex';
        T_GLYPHNAMES(108) := 'adieresis';
        T_GLYPHNAMES(109) := 'atilde';
        T_GLYPHNAMES(110) := 'aring';
        T_GLYPHNAMES(111) := 'ccedilla';
        T_GLYPHNAMES(112) := 'eacute';
        T_GLYPHNAMES(113) := 'egrave';
        T_GLYPHNAMES(114) := 'ecircumflex';
        T_GLYPHNAMES(115) := 'edieresis';
        T_GLYPHNAMES(116) := 'iacute';
        T_GLYPHNAMES(117) := 'igrave';
        T_GLYPHNAMES(118) := 'icircumflex';
        T_GLYPHNAMES(119) := 'idieresis';
        T_GLYPHNAMES(120) := 'ntilde';
        T_GLYPHNAMES(121) := 'oacute';
        T_GLYPHNAMES(122) := 'ograve';
        T_GLYPHNAMES(123) := 'ocircumflex';
        T_GLYPHNAMES(124) := 'odieresis';
        T_GLYPHNAMES(125) := 'otilde';
        T_GLYPHNAMES(126) := 'uacute';
        T_GLYPHNAMES(127) := 'ugrave';
        T_GLYPHNAMES(128) := 'ucircumflex';
        T_GLYPHNAMES(129) := 'udieresis';
        T_GLYPHNAMES(130) := 'dagger';
        T_GLYPHNAMES(131) := 'degree';
        T_GLYPHNAMES(132) := 'cent';
        T_GLYPHNAMES(133) := 'sterling';
        T_GLYPHNAMES(134) := 'section';
        T_GLYPHNAMES(135) := 'bullet';
        T_GLYPHNAMES(136) := 'paragraph';
        T_GLYPHNAMES(137) := 'germandbls';
        T_GLYPHNAMES(138) := 'registered';
        T_GLYPHNAMES(139) := 'copyright';
        T_GLYPHNAMES(140) := 'trademark';
        T_GLYPHNAMES(141) := 'acute';
        T_GLYPHNAMES(142) := 'dieresis';
        T_GLYPHNAMES(143) := 'notequal';
        T_GLYPHNAMES(144) := 'AE';
        T_GLYPHNAMES(145) := 'Oslash';
        T_GLYPHNAMES(146) := 'infinity';
        T_GLYPHNAMES(147) := 'plusminus';
        T_GLYPHNAMES(148) := 'lessequal';
        T_GLYPHNAMES(149) := 'greaterequal';
        T_GLYPHNAMES(150) := 'yen';
        T_GLYPHNAMES(151) := 'mu';
        T_GLYPHNAMES(152) := 'partialdiff';
        T_GLYPHNAMES(153) := 'summation';
        T_GLYPHNAMES(154) := 'product';
        T_GLYPHNAMES(155) := 'pi';
        T_GLYPHNAMES(156) := 'integral';
        T_GLYPHNAMES(157) := 'ordfeminine';
        T_GLYPHNAMES(158) := 'ordmasculine';
        T_GLYPHNAMES(159) := 'Omega';
        T_GLYPHNAMES(160) := 'ae';
        T_GLYPHNAMES(161) := 'oslash';
        T_GLYPHNAMES(162) := 'questiondown';
        T_GLYPHNAMES(163) := 'exclamdown';
        T_GLYPHNAMES(164) := 'logicalnot';
        T_GLYPHNAMES(165) := 'radical';
        T_GLYPHNAMES(166) := 'florin';
        T_GLYPHNAMES(167) := 'approxequal';
        T_GLYPHNAMES(168) := 'Delta';
        T_GLYPHNAMES(169) := 'guillemotleft';
        T_GLYPHNAMES(170) := 'guillemotright';
        T_GLYPHNAMES(171) := 'ellipsis';
        T_GLYPHNAMES(172) := 'nonbreakingspace';
        T_GLYPHNAMES(173) := 'Agrave';
        T_GLYPHNAMES(174) := 'Atilde';
        T_GLYPHNAMES(175) := 'Otilde';
        T_GLYPHNAMES(176) := 'OE';
        T_GLYPHNAMES(177) := 'oe';
        T_GLYPHNAMES(178) := 'endash';
        T_GLYPHNAMES(179) := 'emdash';
        T_GLYPHNAMES(180) := 'quotedblleft';
        T_GLYPHNAMES(181) := 'quotedblright';
        T_GLYPHNAMES(182) := 'quoteleft';
        T_GLYPHNAMES(183) := 'quoteright';
        T_GLYPHNAMES(184) := 'divide';
        T_GLYPHNAMES(185) := 'lozenge';
        T_GLYPHNAMES(186) := 'ydieresis';
        T_GLYPHNAMES(187) := 'Ydieresis';
        T_GLYPHNAMES(188) := 'fraction';
        T_GLYPHNAMES(189) := 'currency';
        T_GLYPHNAMES(190) := 'guilsinglleft';
        T_GLYPHNAMES(191) := 'guilsinglright';
        T_GLYPHNAMES(192) := 'fi';
        T_GLYPHNAMES(193) := 'fl';
        T_GLYPHNAMES(194) := 'daggerdbl';
        T_GLYPHNAMES(195) := 'periodcentered';
        T_GLYPHNAMES(196) := 'quotesinglbase';
        T_GLYPHNAMES(197) := 'quotedblbase';
        T_GLYPHNAMES(198) := 'perthousand';
        T_GLYPHNAMES(199) := 'Acircumflex';
        T_GLYPHNAMES(200) := 'Ecircumflex';
        T_GLYPHNAMES(201) := 'Aacute';
        T_GLYPHNAMES(202) := 'Edieresis';
        T_GLYPHNAMES(203) := 'Egrave';
        T_GLYPHNAMES(204) := 'Iacute';
        T_GLYPHNAMES(205) := 'Icircumflex';
        T_GLYPHNAMES(206) := 'Idieresis';
        T_GLYPHNAMES(207) := 'Igrave';
        T_GLYPHNAMES(208) := 'Oacute';
        T_GLYPHNAMES(209) := 'Ocircumflex';
        T_GLYPHNAMES(210) := 'apple';
        T_GLYPHNAMES(211) := 'Ograve';
        T_GLYPHNAMES(212) := 'Uacute';
        T_GLYPHNAMES(213) := 'Ucircumflex';
        T_GLYPHNAMES(214) := 'Ugrave';
        T_GLYPHNAMES(215) := 'dotlessi';
        T_GLYPHNAMES(216) := 'circumflex';
        T_GLYPHNAMES(217) := 'tilde';
        T_GLYPHNAMES(218) := 'macron';
        T_GLYPHNAMES(219) := 'breve';
        T_GLYPHNAMES(220) := 'dotaccent';
        T_GLYPHNAMES(221) := 'ring';
        T_GLYPHNAMES(222) := 'cedilla';
        T_GLYPHNAMES(223) := 'hungarumlaut';
        T_GLYPHNAMES(224) := 'ogonek';
        T_GLYPHNAMES(225) := 'caron';
        T_GLYPHNAMES(226) := 'Lslash';
        T_GLYPHNAMES(227) := 'lslash';
        T_GLYPHNAMES(228) := 'Scaron';
        T_GLYPHNAMES(229) := 'scaron';
        T_GLYPHNAMES(230) := 'Zcaron';
        T_GLYPHNAMES(231) := 'zcaron';
        T_GLYPHNAMES(232) := 'brokenbar';
        T_GLYPHNAMES(233) := 'Eth';
        T_GLYPHNAMES(234) := 'eth';
        T_GLYPHNAMES(235) := 'Yacute';
        T_GLYPHNAMES(236) := 'yacute';
        T_GLYPHNAMES(237) := 'Thorn';
        T_GLYPHNAMES(238) := 'thorn';
        T_GLYPHNAMES(239) := 'minus';
        T_GLYPHNAMES(240) := 'multiply';
        T_GLYPHNAMES(241) := 'onesuperior';
        T_GLYPHNAMES(242) := 'twosuperior';
        T_GLYPHNAMES(243) := 'threesuperior';
        T_GLYPHNAMES(244) := 'onehalf';
        T_GLYPHNAMES(245) := 'onequarter';
        T_GLYPHNAMES(246) := 'threequarters';
        T_GLYPHNAMES(247) := 'franc';
        T_GLYPHNAMES(248) := 'Gbreve';
        T_GLYPHNAMES(249) := 'gbreve';
        T_GLYPHNAMES(250) := 'Idotaccent';
        T_GLYPHNAMES(251) := 'Scedilla';
        T_GLYPHNAMES(252) := 'scedilla';
        T_GLYPHNAMES(253) := 'Cacute';
        T_GLYPHNAMES(254) := 'cacute';
        T_GLYPHNAMES(255) := 'Ccaron';
        T_GLYPHNAMES(256) := 'ccaron';
        T_GLYPHNAMES(257) := 'dcroat';
--
        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('post').LENGTH,1,T_TABLES('post').OFFSET);

        THIS_FONT.ITALIC_ANGLE := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,5) ) + TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,7) ) / 65536;

        CASE
            RAWTOHEX(DBMS_LOB.SUBSTR(T_BLOB,4,1) )
            WHEN '00010000' THEN
                FOR G IN 0..257 LOOP
                    T_GLYPH2NAME(G) := G;
                END LOOP;
            WHEN '00020000' THEN
                T_OFFSET := BLOB2NUM(T_BLOB,2,33) * 2 + 35;
                WHILE NVL(BLOB2NUM(T_BLOB,1,T_OFFSET),0) > 0 LOOP
                    T_GLYPHNAMES(T_GLYPHNAMES.COUNT) := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(T_BLOB,BLOB2NUM(T_BLOB,1,T_OFFSET),T_OFFSET + 1) );

                    T_OFFSET := T_OFFSET + BLOB2NUM(T_BLOB,1,T_OFFSET) + 1;
                END LOOP;

                FOR G IN 0..BLOB2NUM(T_BLOB,2,33) - 1 LOOP
                    T_GLYPH2NAME(G) := BLOB2NUM(T_BLOB,2,35 + 2 * G);
                END LOOP;

            WHEN '00025000' THEN
                FOR G IN 0..BLOB2NUM(T_BLOB,2,33) - 1 LOOP
                    T_OFFSET := BLOB2NUM(T_BLOB,1,35 + G);
                    IF
                        T_OFFSET > 127
                    THEN
                        T_GLYPH2NAME(G) := G - T_OFFSET;
                    ELSE
                        T_GLYPH2NAME(G) := G + T_OFFSET;
                    END IF;

                END LOOP;
            WHEN '00030000' THEN
                T_GLYPHNAMES.DELETE;
            ELSE
                DBMS_OUTPUT.PUT_LINE('no post '
                || DBMS_LOB.SUBSTR(T_BLOB,4,1) );
        END CASE;
--

        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('head').LENGTH,1,T_TABLES('head').OFFSET);

        IF
            DBMS_LOB.SUBSTR(T_BLOB,4,13) = HEXTORAW('5F0F3CF5')  -- magic
        THEN
            DECLARE
                T_TMP   PLS_INTEGER := BLOB2NUM(T_BLOB,2,45);
            BEGIN
                IF
                    BITAND(T_TMP,1) = 1
                THEN
                    THIS_FONT.STYLE := 'B';
                END IF;

                IF
                    BITAND(T_TMP,2) = 2
                THEN
                    THIS_FONT.STYLE := THIS_FONT.STYLE
                    || 'I';
                    THIS_FONT.FLAGS := THIS_FONT.FLAGS + 64;
                END IF;

                THIS_FONT.STYLE := NVL(THIS_FONT.STYLE,'N');
                THIS_FONT.UNIT_NORM := 1000 / BLOB2NUM(T_BLOB,2,19);
                THIS_FONT.BB_XMIN := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,37),THIS_FONT.UNIT_NORM);

                THIS_FONT.BB_YMIN := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,39),THIS_FONT.UNIT_NORM);

                THIS_FONT.BB_XMAX := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,41),THIS_FONT.UNIT_NORM);

                THIS_FONT.BB_YMAX := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,43),THIS_FONT.UNIT_NORM);

                THIS_FONT.INDEXTOLOCFORMAT := BLOB2NUM(T_BLOB,2,51); -- 0 for short offsets, 1 for long
            END;
        END IF;
--

        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('hhea').LENGTH,1,T_TABLES('hhea').OFFSET);

        IF
            DBMS_LOB.SUBSTR(T_BLOB,4,1) = HEXTORAW('00010000') -- version 1.0
        THEN
            THIS_FONT.ASCENT := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,5),THIS_FONT.UNIT_NORM);

            THIS_FONT.DESCENT := TO_SHORT(DBMS_LOB.SUBSTR(T_BLOB,2,7),THIS_FONT.UNIT_NORM);

            THIS_FONT.CAPHEIGHT := THIS_FONT.ASCENT;
            NR_HMETRICS := BLOB2NUM(T_BLOB,2,35);
        END IF;
--

        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('hmtx').LENGTH,1,T_TABLES('hmtx').OFFSET);

        FOR J IN 0..NR_HMETRICS - 1 LOOP
            THIS_FONT.HMETRICS(J) := BLOB2NUM(T_BLOB,2,1 + 4 * J);
        END LOOP;
--

        DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('name').LENGTH,1,T_TABLES('name').OFFSET);

        IF
            DBMS_LOB.SUBSTR(T_BLOB,2,1) = HEXTORAW('0000') -- format 0
        THEN
            T_OFFSET := BLOB2NUM(T_BLOB,2,5) + 1;
            FOR J IN 0..BLOB2NUM(T_BLOB,2,3) - 1 LOOP
                IF
                    ( DBMS_LOB.SUBSTR(T_BLOB,2,7 + J * 12) = HEXTORAW('0003') -- Windows
                     AND DBMS_LOB.SUBSTR(T_BLOB,2,11 + J * 12) = HEXTORAW('0409') -- English United States
                     )
                THEN
                    CASE
                        RAWTOHEX(DBMS_LOB.SUBSTR(T_BLOB,2,13 + J * 12) )
                        WHEN '0001' THEN
                            THIS_FONT.FAMILY := UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(T_BLOB,BLOB2NUM(T_BLOB,2,15 + J * 12),T_OFFSET + BLOB2NUM(T_BLOB,2,17 + J * 12) ),'AL16UTF16'
);
                        WHEN '0006' THEN
                            THIS_FONT.NAME := UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(T_BLOB,BLOB2NUM(T_BLOB,2,15 + J * 12),T_OFFSET + BLOB2NUM(T_BLOB,2,17 + J * 12) ),'AL16UTF16'
);
                        ELSE
                            NULL;
                    END CASE;

                END IF;
            END LOOP;

        END IF;
--

        IF
            THIS_FONT.ITALIC_ANGLE != 0
        THEN
            THIS_FONT.FLAGS := THIS_FONT.FLAGS + 64;
        END IF;

        THIS_FONT.SUBTYPE := 'TrueType';
        THIS_FONT.STEMV := 50;
        THIS_FONT.FAMILY := LOWER(THIS_FONT.FAMILY);
        THIS_FONT.ENCODING := UTL_I18N.MAP_CHARSET(P_ENCODING,UTL_I18N.GENERIC_CONTEXT,UTL_I18N.IANA_TO_ORACLE);

        THIS_FONT.ENCODING := NVL(THIS_FONT.ENCODING,UPPER(P_ENCODING) );
        THIS_FONT.CHARSET := SYS_CONTEXT('userenv','LANGUAGE');
        THIS_FONT.CHARSET := SUBSTR(THIS_FONT.CHARSET,1,INSTR(THIS_FONT.CHARSET,'.') )
        || THIS_FONT.ENCODING;

        THIS_FONT.CID := UPPER(P_ENCODING) IN (
            'CID',
            'AL16UTF16',
            'UTF',
            'UNICODE'
        );

        THIS_FONT.FONTNAME := THIS_FONT.NAME;
        THIS_FONT.COMPRESS_FONT := P_COMPRESS;
--
        IF
            ( P_EMBED OR THIS_FONT.CID ) AND T_TABLES.EXISTS('OS/2')
        THEN
            DBMS_LOB.COPY(T_BLOB,P_FONT,T_TABLES('OS/2').LENGTH,1,T_TABLES('OS/2').OFFSET);

            IF
                BLOB2NUM(T_BLOB,2,9) != 2
            THEN
                THIS_FONT.FONTFILE2 := P_FONT;
                THIS_FONT.TTF_OFFSET := P_OFFSET;
                THIS_FONT.NAME := DBMS_RANDOM.STRING('u',6)
                || '+'
                || THIS_FONT.NAME;
--

                T_BLOB := DBMS_LOB.SUBSTR(P_FONT,T_TABLES('loca').LENGTH,T_TABLES('loca').OFFSET);

                DECLARE
                    T_SIZE   PLS_INTEGER := 2 + THIS_FONT.INDEXTOLOCFORMAT * 2; -- 0 for short offsets, 1 for long
                BEGIN
                    FOR I IN 0..THIS_FONT.NUMGLYPHS LOOP
                        THIS_FONT.LOCA(I) := BLOB2NUM(T_BLOB,T_SIZE,1 + I * T_SIZE);
                    END LOOP;
                END;

            END IF;

        END IF;
--

        IF
            NOT THIS_FONT.CID
        THEN
            IF
                THIS_FONT.FLAGS = 4 -- a symbolic font
            THEN
                DECLARE
                    T_REAL   PLS_INTEGER;
                BEGIN
                    FOR T_CODE IN 32..255 LOOP
                        T_REAL := THIS_FONT.CODE2GLYPH.FIRST + T_CODE - 32; -- assume code 32, space maps to the first code from the font
                        IF
                            THIS_FONT.CODE2GLYPH.EXISTS(T_REAL)
                        THEN
                            THIS_FONT.FIRST_CHAR := LEAST(NVL(THIS_FONT.FIRST_CHAR,255),T_CODE);

                            THIS_FONT.LAST_CHAR := T_CODE;
                            IF
                                THIS_FONT.HMETRICS.EXISTS(THIS_FONT.CODE2GLYPH(T_REAL) )
                            THEN
                                THIS_FONT.CHAR_WIDTH_TAB(T_CODE) := TRUNC(THIS_FONT.HMETRICS(THIS_FONT.CODE2GLYPH(T_REAL) ) * THIS_FONT.UNIT_NORM);
                            ELSE
                                THIS_FONT.CHAR_WIDTH_TAB(T_CODE) := TRUNC(THIS_FONT.HMETRICS(THIS_FONT.HMETRICS.LAST() ) * THIS_FONT.UNIT_NORM);
                            END IF;

                        ELSE
                            THIS_FONT.CHAR_WIDTH_TAB(T_CODE) := TRUNC(THIS_FONT.HMETRICS(0) * THIS_FONT.UNIT_NORM);
                        END IF;

                    END LOOP;

                END;

            ELSE
                DECLARE
                    T_UNICODE           PLS_INTEGER;
                    T_PRV_DIFF          PLS_INTEGER;
                    T_UTF16_CHARSET     VARCHAR2(1000);
                    T_WINANSI_CHARSET   VARCHAR2(1000);
                    T_GLYPHNAME         TP_GLYPHNAME;
                BEGIN
                    T_PRV_DIFF :=-1;
                    T_UTF16_CHARSET := SUBSTR(THIS_FONT.CHARSET,1,INSTR(THIS_FONT.CHARSET,'.') )
                    || 'AL16UTF16';

                    T_WINANSI_CHARSET := SUBSTR(THIS_FONT.CHARSET,1,INSTR(THIS_FONT.CHARSET,'.') )
                    || 'WE8MSWIN1252';

                    FOR T_CODE IN 32..255 LOOP
                        T_UNICODE := UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.CONVERT(HEXTORAW(TO_CHAR(T_CODE,'fm0x') ),T_UTF16_CHARSET,THIS_FONT.CHARSET) );

                        T_GLYPHNAME := '';
                        THIS_FONT.CHAR_WIDTH_TAB(T_CODE) := TRUNC(THIS_FONT.HMETRICS(THIS_FONT.HMETRICS.LAST() ) * THIS_FONT.UNIT_NORM);

                        IF
                            THIS_FONT.CODE2GLYPH.EXISTS(T_UNICODE)
                        THEN
                            THIS_FONT.FIRST_CHAR := LEAST(NVL(THIS_FONT.FIRST_CHAR,255),T_CODE);

                            THIS_FONT.LAST_CHAR := T_CODE;
                            IF
                                THIS_FONT.HMETRICS.EXISTS(THIS_FONT.CODE2GLYPH(T_UNICODE) )
                            THEN
                                THIS_FONT.CHAR_WIDTH_TAB(T_CODE) := TRUNC(THIS_FONT.HMETRICS(THIS_FONT.CODE2GLYPH(T_UNICODE) ) * THIS_FONT.UNIT_NORM);
                            END IF;

                            IF
                                T_GLYPH2NAME.EXISTS(THIS_FONT.CODE2GLYPH(T_UNICODE) )
                            THEN
                                IF
                                    T_GLYPHNAMES.EXISTS(T_GLYPH2NAME(THIS_FONT.CODE2GLYPH(T_UNICODE) ) )
                                THEN
                                    T_GLYPHNAME := T_GLYPHNAMES(T_GLYPH2NAME(THIS_FONT.CODE2GLYPH(T_UNICODE) ) );
                                END IF;
                            END IF;

                        END IF;
--

                        IF
                            ( T_GLYPHNAME IS NOT NULL AND T_UNICODE != UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.CONVERT(HEXTORAW(TO_CHAR(T_CODE,'fm0x') ),T_WINANSI_CHARSET
,THIS_FONT.CHARSET) ) )
                        THEN
                            THIS_FONT.DIFF := THIS_FONT.DIFF
                            ||
                                CASE
                                    WHEN T_PRV_DIFF != T_CODE - 1 THEN ' '
                                    || T_CODE
                                END
                            || ' /'
                            || T_GLYPHNAME;

                            T_PRV_DIFF := T_CODE;
                        END IF;

                    END LOOP;

                END;

                IF
                    THIS_FONT.DIFF IS NOT NULL
                THEN
                    THIS_FONT.DIFF := '/Differences ['
                    || THIS_FONT.DIFF
                    || ']';
                END IF;

            END IF;
        END IF;
--

        T_FONT_IND := G_FONTS.COUNT () + 1;
        G_FONTS(T_FONT_IND) := THIS_FONT;
/*
--
dbms_output.put_line( this_font.fontname || ' ' || this_font.family || ' ' || this_font.style
|| ' ' || this_font.flags
|| ' ' || this_font.code2glyph.first
|| ' ' || this_font.code2glyph.prior( this_font.code2glyph.last )
|| ' ' || this_font.code2glyph.last
|| ' nr glyphs: ' || this_font.numGlyphs
 ); */
--
        RETURN T_FONT_IND;
    END;
--

    PROCEDURE LOAD_TTF_FONT (
        P_FONT       BLOB,
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE,
        P_OFFSET     NUMBER := 1
    ) IS
        T_TMP   PLS_INTEGER;
    BEGIN
        T_TMP := LOAD_TTF_FONT(P_FONT,P_ENCODING,P_EMBED,P_COMPRESS);
    END;
--

    FUNCTION LOAD_TTF_FONT (
        P_DIR        VARCHAR2 := 'MY_FONTS',
        P_FILENAME   VARCHAR2 := 'BAUHS93.TTF',
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    ) RETURN PLS_INTEGER
        IS
    BEGIN
        RETURN LOAD_TTF_FONT(FILE2BLOB(P_DIR,P_FILENAME),P_ENCODING,P_EMBED,P_COMPRESS);
    END;
--

    PROCEDURE LOAD_TTF_FONT (
        P_DIR        VARCHAR2 := 'MY_FONTS',
        P_FILENAME   VARCHAR2 := 'BAUHS93.TTF',
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    )
        IS
    BEGIN
        LOAD_TTF_FONT(FILE2BLOB(P_DIR,P_FILENAME),P_ENCODING,P_EMBED,P_COMPRESS);
    END;
--

    PROCEDURE LOAD_TTC_FONTS (
        P_TTC        BLOB,
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    ) IS

        TYPE TP_FONT_TABLE IS RECORD ( OFFSET       PLS_INTEGER,
        LENGTH       PLS_INTEGER );
        TYPE TP_TABLES IS
            TABLE OF TP_FONT_TABLE INDEX BY VARCHAR2(4);
        T_TABLES     TP_TABLES;
        T_TAG        VARCHAR2(4);
        T_BLOB       BLOB;
        T_OFFSET     PLS_INTEGER;
        T_FONT_IND   PLS_INTEGER;
    BEGIN
        IF
            UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(P_TTC,4,1) ) != 'ttcf'
        THEN
            RETURN;
        END IF;

        FOR F IN 0..BLOB2NUM(P_TTC,4,9) - 1 LOOP
            T_FONT_IND := LOAD_TTF_FONT(P_TTC,P_ENCODING,P_EMBED,P_COMPRESS,BLOB2NUM(P_TTC,4,13 + F * 4) + 1);
        END LOOP;

    END;
--

    PROCEDURE LOAD_TTC_FONTS (
        P_DIR        VARCHAR2 := 'MY_FONTS',
        P_FILENAME   VARCHAR2 := 'CAMBRIA.TTC',
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    )
        IS
    BEGIN
        LOAD_TTC_FONTS(FILE2BLOB(P_DIR,P_FILENAME),P_ENCODING,P_EMBED,P_COMPRESS);
    END;
--

    FUNCTION RGB (
        P_HEX_RGB VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN TO_CHAR_ROUND(NVL(TO_NUMBER(SUBSTR(LTRIM(P_HEX_RGB,'#'),1,2),'xx') / 255,0),5)
        || ' '
        || TO_CHAR_ROUND(NVL(TO_NUMBER(SUBSTR(LTRIM(P_HEX_RGB,'#'),3,2),'xx') / 255,0),5)
        || ' '
        || TO_CHAR_ROUND(NVL(TO_NUMBER(SUBSTR(LTRIM(P_HEX_RGB,'#'),5,2),'xx') / 255,0),5)
        || ' ';
    END;
--

    PROCEDURE SET_COLOR (
        P_RGB      VARCHAR2 := '000000',
        P_BACKGR   BOOLEAN
    )
        IS
    BEGIN
        TXT2PAGE(RGB(P_RGB)
        || CASE
            WHEN P_BACKGR THEN 'RG'
            ELSE 'rg'
        END);
    END;
--

    PROCEDURE SET_COLOR (
        P_RGB VARCHAR2 := '000000'
    )
        IS
    BEGIN
        SET_COLOR(P_RGB,FALSE);
    END;
--

    PROCEDURE SET_COLOR (
        P_RED     NUMBER := 0,
        P_GREEN   NUMBER := 0,
        P_BLUE    NUMBER := 0
    )
        IS
    BEGIN
        IF
            ( P_RED BETWEEN 0 AND 255 AND P_BLUE BETWEEN 0 AND 255 AND P_GREEN BETWEEN 0 AND 255 )
        THEN
            SET_COLOR(TO_CHAR(P_RED,'fm0x')
            || TO_CHAR(P_GREEN,'fm0x')
            || TO_CHAR(P_BLUE,'fm0x'),FALSE);

        END IF;
    END;
--

    PROCEDURE SET_BK_COLOR (
        P_RGB VARCHAR2 := 'ffffff'
    )
        IS
    BEGIN
        SET_COLOR(P_RGB,TRUE);
    END;
--

    PROCEDURE SET_BK_COLOR (
        P_RED     NUMBER := 0,
        P_GREEN   NUMBER := 0,
        P_BLUE    NUMBER := 0
    )
        IS
    BEGIN
        IF
            ( P_RED BETWEEN 0 AND 255 AND P_BLUE BETWEEN 0 AND 255 AND P_GREEN BETWEEN 0 AND 255 )
        THEN
            SET_COLOR(TO_CHAR(P_RED,'fm0x')
            || TO_CHAR(P_GREEN,'fm0x')
            || TO_CHAR(P_BLUE,'fm0x'),TRUE);

        END IF;
    END;
--

    PROCEDURE HORIZONTAL_LINE (
        P_X            NUMBER,
        P_Y            NUMBER,
        P_WIDTH        NUMBER,
        P_LINE_WIDTH   NUMBER := 0.5,
        P_LINE_COLOR   VARCHAR2 := '000000'
    ) IS
        T_USE_COLOR   BOOLEAN;
    BEGIN
        TXT2PAGE('q '
        || TO_CHAR_ROUND(P_LINE_WIDTH,5)
        || ' w');
        T_USE_COLOR := SUBSTR(P_LINE_COLOR,-6) != '000000';
        IF
            T_USE_COLOR
        THEN
            SET_COLOR(P_LINE_COLOR);
            SET_BK_COLOR(P_LINE_COLOR);
        ELSE
            TXT2PAGE('0 g');
        END IF;

        TXT2PAGE(TO_CHAR_ROUND(P_X,5)
        || ' '
        || TO_CHAR_ROUND(P_Y,5)
        || ' m '
        || TO_CHAR_ROUND(P_X + P_WIDTH,5)
        || ' '
        || TO_CHAR_ROUND(P_Y,5)
        || ' l b');

        TXT2PAGE('Q');
    END;
--

    PROCEDURE VERTICAL_LINE (
        P_X            NUMBER,
        P_Y            NUMBER,
        P_HEIGHT       NUMBER,
        P_LINE_WIDTH   NUMBER := 0.5,
        P_LINE_COLOR   VARCHAR2 := '000000'
    ) IS
        T_USE_COLOR   BOOLEAN;
    BEGIN
        TXT2PAGE('q '
        || TO_CHAR_ROUND(P_LINE_WIDTH,5)
        || ' w');
        T_USE_COLOR := SUBSTR(P_LINE_COLOR,-6) != '000000';
        IF
            T_USE_COLOR
        THEN
            SET_COLOR(P_LINE_COLOR);
            SET_BK_COLOR(P_LINE_COLOR);
        ELSE
            TXT2PAGE('0 g');
        END IF;

        TXT2PAGE(TO_CHAR_ROUND(P_X,5)
        || ' '
        || TO_CHAR_ROUND(P_Y,5)
        || ' m '
        || TO_CHAR_ROUND(P_X,5)
        || ' '
        || TO_CHAR_ROUND(P_Y + P_HEIGHT,5)
        || ' l b');

        TXT2PAGE('Q');
    END;
--

    PROCEDURE RECT (
        P_X            NUMBER,
        P_Y            NUMBER,
        P_WIDTH        NUMBER,
        P_HEIGHT       NUMBER,
        P_LINE_COLOR   VARCHAR2 := NULL,
        P_FILL_COLOR   VARCHAR2 := NULL,
        P_LINE_WIDTH   NUMBER := 0.5
    )
        IS
    BEGIN
        TXT2PAGE('q');
        IF
            SUBSTR(P_LINE_COLOR,-6) != SUBSTR(P_FILL_COLOR,-6)
        THEN
            TXT2PAGE(TO_CHAR_ROUND(P_LINE_WIDTH,5)
            || ' w');
        END IF;

        IF
            SUBSTR(P_LINE_COLOR,-6) != '000000'
        THEN
            SET_BK_COLOR(P_LINE_COLOR);
        ELSE
            TXT2PAGE('0 g');
        END IF;

        IF
            P_FILL_COLOR IS NOT NULL
        THEN
            SET_COLOR(P_FILL_COLOR);
        END IF;
        TXT2PAGE(TO_CHAR_ROUND(P_X,5)
        || ' '
        || TO_CHAR_ROUND(P_Y,5)
        || ' '
        || TO_CHAR_ROUND(P_WIDTH,5)
        || ' '
        || TO_CHAR_ROUND(P_HEIGHT,5)
        || ' re '
        || CASE
            WHEN P_FILL_COLOR IS NULL THEN 'S'
            ELSE
                CASE
                    WHEN P_LINE_COLOR IS NULL THEN 'f'
                    ELSE 'b'
                END
        END);

        TXT2PAGE('Q');
    END;
--

    FUNCTION GET (
        P_WHAT PLS_INTEGER
    ) RETURN NUMBER
        IS
    BEGIN
        RETURN
            CASE P_WHAT
                WHEN C_GET_PAGE_WIDTH THEN G_SETTINGS.PAGE_WIDTH
                WHEN C_GET_PAGE_HEIGHT THEN G_SETTINGS.PAGE_HEIGHT
                WHEN C_GET_MARGIN_TOP THEN G_SETTINGS.MARGIN_TOP
                WHEN C_GET_MARGIN_RIGHT THEN G_SETTINGS.MARGIN_RIGHT
                WHEN C_GET_MARGIN_BOTTOM THEN G_SETTINGS.MARGIN_BOTTOM
                WHEN C_GET_MARGIN_LEFT THEN G_SETTINGS.MARGIN_LEFT
                WHEN C_GET_X THEN G_X
                WHEN C_GET_Y THEN G_Y
                WHEN C_GET_FONTSIZE THEN G_FONTS(G_CURRENT_FONT).FONTSIZE
                WHEN C_GET_CURRENT_FONT THEN G_CURRENT_FONT
            END;
    END;
--

    FUNCTION PARSE_JPG (
        P_IMG_BLOB BLOB
    ) RETURN TP_IMG IS
        BUF     RAW(4);
        T_IMG   TP_IMG;
        T_IND   INTEGER;
    BEGIN
        IF
            ( DBMS_LOB.SUBSTR(P_IMG_BLOB,2,1) != HEXTORAW('FFD8')                                      -- SOI Start of Image
             OR DBMS_LOB.SUBSTR(P_IMG_BLOB,2,DBMS_LOB.GETLENGTH(P_IMG_BLOB) - 1) != HEXTORAW('FFD9')   -- EOI End of Image
             )
        THEN  -- this is not a jpg I can handle
            RETURN NULL;
        END IF;
--

        T_IMG.PIXELS := P_IMG_BLOB;
        T_IMG.TYPE := 'jpg';
        IF
            DBMS_LOB.SUBSTR(T_IMG.PIXELS,2,3) IN (
                HEXTORAW('FFE0')  -- a APP0 jpg
               ,
                HEXTORAW('FFE1')  -- a APP1 jpg
            )
        THEN
            T_IMG.COLOR_RES := 8;
            T_IMG.HEIGHT := 1;
            T_IMG.WIDTH := 1;
--
            T_IND := 3;
            T_IND := T_IND + 2 + BLOB2NUM(T_IMG.PIXELS,2,T_IND + 2);

            LOOP
                BUF := DBMS_LOB.SUBSTR(T_IMG.PIXELS,2,T_IND);
                EXIT WHEN BUF = HEXTORAW('FFDA');  -- SOS Start of Scan
                EXIT WHEN BUF = HEXTORAW('FFD9');  -- EOI End Of Image
                EXIT WHEN SUBSTR(RAWTOHEX(BUF),1,2) != 'FF';
                IF
                    RAWTOHEX(BUF) IN (
                        'FFD0'                                                          -- RSTn
                       ,
                        'FFD1',
                        'FFD2',
                        'FFD3',
                        'FFD4',
                        'FFD5',
                        'FFD6',
                        'FFD7',
                        'FF01'  -- TEM
                    )
                THEN
                    T_IND := T_IND + 2;
                ELSE
                    IF
                        BUF = HEXTORAW('FFC0')       -- SOF0 (Start Of Frame 0) marker
                    THEN
                        T_IMG.COLOR_RES := BLOB2NUM(T_IMG.PIXELS,1,T_IND + 4);
                        T_IMG.HEIGHT := BLOB2NUM(T_IMG.PIXELS,2,T_IND + 5);
                        T_IMG.WIDTH := BLOB2NUM(T_IMG.PIXELS,2,T_IND + 7);
                    END IF;

                    T_IND := T_IND + 2 + BLOB2NUM(T_IMG.PIXELS,2,T_IND + 2);

                END IF;

            END LOOP;

        END IF;
--

        RETURN T_IMG;
    END;
--

    FUNCTION PARSE_PNG (
        P_IMG_BLOB BLOB
    ) RETURN TP_IMG IS
        T_IMG        TP_IMG;
        BUF          RAW(32767);
        LEN          INTEGER;
        IND          INTEGER;
        COLOR_TYPE   PLS_INTEGER;
    BEGIN
        IF
            RAWTOHEX(DBMS_LOB.SUBSTR(P_IMG_BLOB,8,1) ) != '89504E470D0A1A0A'  -- not the right signature
        THEN
            RETURN NULL;
        END IF;

        DBMS_LOB.CREATETEMPORARY(T_IMG.PIXELS,TRUE);
        IND := 9;
        LOOP
            LEN := BLOB2NUM(P_IMG_BLOB,4,IND);  -- length
            EXIT WHEN LEN IS NULL OR IND > DBMS_LOB.GETLENGTH(P_IMG_BLOB);
            CASE
                UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(P_IMG_BLOB,4,IND + 4) )  -- Chunk type
                WHEN 'IHDR' THEN
                    T_IMG.WIDTH := BLOB2NUM(P_IMG_BLOB,4,IND + 8);
                    T_IMG.HEIGHT := BLOB2NUM(P_IMG_BLOB,4,IND + 12);
                    T_IMG.COLOR_RES := BLOB2NUM(P_IMG_BLOB,1,IND + 16);
                    COLOR_TYPE := BLOB2NUM(P_IMG_BLOB,1,IND + 17);
                    T_IMG.GREYSCALE := COLOR_TYPE IN (
                        0,
                        4
                    );
                WHEN 'PLTE' THEN
                    T_IMG.COLOR_TAB := DBMS_LOB.SUBSTR(P_IMG_BLOB,LEN,IND + 8);
                WHEN 'IDAT' THEN
                    DBMS_LOB.COPY(T_IMG.PIXELS,P_IMG_BLOB,LEN,DBMS_LOB.GETLENGTH(T_IMG.PIXELS) + 1,IND + 8);
                WHEN 'IEND' THEN
                    EXIT;
                ELSE
                    NULL;
            END CASE;

            IND := IND + 4 + 4 + LEN + 4;  -- Length + Chunk type + Chunk data + CRC
        END LOOP;
--

        T_IMG.TYPE := 'png';
        T_IMG.NR_COLORS :=
            CASE COLOR_TYPE
                WHEN 0 THEN 1
                WHEN 2 THEN 3
                WHEN 3 THEN 1
                WHEN 4 THEN 2
                ELSE 4
            END;
--

        RETURN T_IMG;
    END;
--

    FUNCTION LZW_DECOMPRESS (
        P_BLOB BLOB,
        P_BITS PLS_INTEGER
    ) RETURN BLOB IS

        POWERS            TP_PLS_TAB;
--
        G_LZW_IND         PLS_INTEGER;
        G_LZW_BITS        PLS_INTEGER;
        G_LZW_BUFFER      PLS_INTEGER;
        G_LZW_BITS_USED   PLS_INTEGER;
--
        TYPE TP_LZW_DICT IS
            TABLE OF RAW(1000) INDEX BY PLS_INTEGER;
        T_LZW_DICT        TP_LZW_DICT;
        T_CLR_CODE        PLS_INTEGER;
        T_NXT_CODE        PLS_INTEGER;
        T_NEW_CODE        PLS_INTEGER;
        T_OLD_CODE        PLS_INTEGER;
        T_BLOB            BLOB;
--

        FUNCTION GET_LZW_CODE RETURN PLS_INTEGER IS
            T_RV   PLS_INTEGER;
        BEGIN
            WHILE G_LZW_BITS_USED < G_LZW_BITS LOOP
                G_LZW_IND := G_LZW_IND + 1;
                G_LZW_BUFFER := BLOB2NUM(P_BLOB,1,G_LZW_IND) * POWERS(G_LZW_BITS_USED) + G_LZW_BUFFER;

                G_LZW_BITS_USED := G_LZW_BITS_USED + 8;
            END LOOP;

            T_RV := BITAND(G_LZW_BUFFER,POWERS(G_LZW_BITS) - 1);
            G_LZW_BITS_USED := G_LZW_BITS_USED - G_LZW_BITS;
            G_LZW_BUFFER := TRUNC(G_LZW_BUFFER / POWERS(G_LZW_BITS) );
            RETURN T_RV;
        END;
--

    BEGIN
        FOR I IN 0..30 LOOP
            POWERS(I) := POWER(2,I);
        END LOOP;
--

        T_CLR_CODE := POWERS(P_BITS - 1);
        T_NXT_CODE := T_CLR_CODE + 2;
        FOR I IN 0..LEAST(T_CLR_CODE - 1,255) LOOP
            T_LZW_DICT(I) := HEXTORAW(TO_CHAR(I,'fm0X') );
        END LOOP;

        DBMS_LOB.CREATETEMPORARY(T_BLOB,TRUE);
        G_LZW_IND := 0;
        G_LZW_BITS := P_BITS;
        G_LZW_BUFFER := 0;
        G_LZW_BITS_USED := 0;
--
        T_OLD_CODE := NULL;
        T_NEW_CODE := GET_LZW_CODE ();
        LOOP
            CASE
                NVL(T_NEW_CODE,T_CLR_CODE + 1)
                WHEN T_CLR_CODE + 1 THEN
                    EXIT;
                WHEN T_CLR_CODE THEN
                    T_NEW_CODE := NULL;
                    G_LZW_BITS := P_BITS;
                    T_NXT_CODE := T_CLR_CODE + 2;
                ELSE
                    IF
                        T_NEW_CODE = T_NXT_CODE
                    THEN
                        T_LZW_DICT(T_NXT_CODE) := UTL_RAW.CONCAT(T_LZW_DICT(T_OLD_CODE),UTL_RAW.SUBSTR(T_LZW_DICT(T_OLD_CODE),1,1) );

                        DBMS_LOB.APPEND(T_BLOB,T_LZW_DICT(T_NXT_CODE) );
                        T_NXT_CODE := T_NXT_CODE + 1;
                    ELSIF T_NEW_CODE > T_NXT_CODE THEN
                        EXIT;
                    ELSE
                        DBMS_LOB.APPEND(T_BLOB,T_LZW_DICT(T_NEW_CODE) );
                        IF
                            T_OLD_CODE IS NOT NULL
                        THEN
                            T_LZW_DICT(T_NXT_CODE) := UTL_RAW.CONCAT(T_LZW_DICT(T_OLD_CODE),UTL_RAW.SUBSTR(T_LZW_DICT(T_NEW_CODE),1,1) );

                            T_NXT_CODE := T_NXT_CODE + 1;
                        END IF;

                    END IF;

                    IF
                        BITAND(T_NXT_CODE,POWERS(G_LZW_BITS) - 1) = 0 AND G_LZW_BITS < 12
                    THEN
                        G_LZW_BITS := G_LZW_BITS + 1;
                    END IF;

            END CASE;

            T_OLD_CODE := T_NEW_CODE;
            T_NEW_CODE := GET_LZW_CODE ();
        END LOOP;

        T_LZW_DICT.DELETE;
--
        RETURN T_BLOB;
    END;
--

    FUNCTION PARSE_GIF (
        P_IMG_BLOB BLOB
    ) RETURN TP_IMG IS
        IMG     TP_IMG;
        BUF     RAW(4000);
        IND     INTEGER;
        T_LEN   PLS_INTEGER;
    BEGIN
        IF
            DBMS_LOB.SUBSTR(P_IMG_BLOB,3,1) != UTL_RAW.CAST_TO_RAW('GIF')
        THEN
            RETURN NULL;
        END IF;

        IND := 7;
        BUF := DBMS_LOB.SUBSTR(P_IMG_BLOB,7,7);  --  Logical Screen Descriptor
        IND := IND + 7;
        IMG.COLOR_RES := RAW2NUM(UTL_RAW.BIT_AND(UTL_RAW.SUBSTR(BUF,5,1),HEXTORAW('70') ) ) / 16 + 1;

        IMG.COLOR_RES := 8;
        IF
            RAW2NUM(BUF,5,1) > 127
        THEN
            T_LEN := 3 * POWER(2,RAW2NUM(UTL_RAW.BIT_AND(UTL_RAW.SUBSTR(BUF,5,1),HEXTORAW('07') ) ) + 1);

            IMG.COLOR_TAB := DBMS_LOB.SUBSTR(P_IMG_BLOB,T_LEN,IND); -- Global Color Table
            IND := IND + T_LEN;
        END IF;
--

        LOOP
            CASE
                DBMS_LOB.SUBSTR(P_IMG_BLOB,1,IND)
                WHEN HEXTORAW('3B') -- trailer
                 THEN
                    EXIT;
                WHEN HEXTORAW('21') -- extension
                 THEN
                    IF
                        DBMS_LOB.SUBSTR(P_IMG_BLOB,1,IND + 1) = HEXTORAW('F9')
                    THEN -- Graphic Control Extension
                        IF
                            UTL_RAW.BIT_AND(DBMS_LOB.SUBSTR(P_IMG_BLOB,1,IND + 3),HEXTORAW('01') ) = HEXTORAW('01')
                        THEN -- Transparent Color Flag set
                            IMG.TRANSPARANCY_INDEX := BLOB2NUM(P_IMG_BLOB,1,IND + 6);
                        END IF;
                    END IF;

                    IND := IND + 2; -- skip sentinel + label
                    LOOP
                        T_LEN := BLOB2NUM(P_IMG_BLOB,1,IND); -- Block Size
                        EXIT WHEN T_LEN = 0;
                        IND := IND + 1 + T_LEN; -- skip Block Size + Data Sub-block
                    END LOOP;

                    IND := IND + 1;           -- skip last Block Size
                WHEN HEXTORAW('2C')       -- image
                 THEN
                    DECLARE
                        IMG_BLOB        BLOB;
                        MIN_CODE_SIZE   PLS_INTEGER;
                        CODE_SIZE       PLS_INTEGER;
                        FLAGS           RAW(1);
                    BEGIN
                        IMG.WIDTH := UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(P_IMG_BLOB,2,IND + 5),UTL_RAW.LITTLE_ENDIAN);

                        IMG.HEIGHT := UTL_RAW.CAST_TO_BINARY_INTEGER(DBMS_LOB.SUBSTR(P_IMG_BLOB,2,IND + 7),UTL_RAW.LITTLE_ENDIAN);

                        IMG.GREYSCALE := FALSE;
                        IND := IND + 1 + 8;                   -- skip sentinel + img sizes
                        FLAGS := DBMS_LOB.SUBSTR(P_IMG_BLOB,1,IND);
                        IF
                            UTL_RAW.BIT_AND(FLAGS,HEXTORAW('80') ) = HEXTORAW('80')
                        THEN
                            T_LEN := 3 * POWER(2,RAW2NUM(UTL_RAW.BIT_AND(FLAGS,HEXTORAW('07') ) ) + 1);

                            IMG.COLOR_TAB := DBMS_LOB.SUBSTR(P_IMG_BLOB,T_LEN,IND + 1);          -- Local Color Table
                        END IF;

                        IND := IND + 1;                                -- skip image Flags
                        MIN_CODE_SIZE := BLOB2NUM(P_IMG_BLOB,1,IND);
                        IND := IND + 1;                      -- skip LZW Minimum Code Size
                        DBMS_LOB.CREATETEMPORARY(IMG_BLOB,TRUE);
                        LOOP
                            T_LEN := BLOB2NUM(P_IMG_BLOB,1,IND); -- Block Size
                            EXIT WHEN T_LEN = 0;
                            DBMS_LOB.APPEND(IMG_BLOB,DBMS_LOB.SUBSTR(P_IMG_BLOB,T_LEN,IND + 1) ); -- Data Sub-block

                            IND := IND + 1 + T_LEN;      -- skip Block Size + Data Sub-block
                        END LOOP;

                        IND := IND + 1;                            -- skip last Block Size
                        IMG.PIXELS := LZW_DECOMPRESS(IMG_BLOB,MIN_CODE_SIZE + 1);
--
                        IF
                            UTL_RAW.BIT_AND(FLAGS,HEXTORAW('40') ) = HEXTORAW('40')
                        THEN                                        --  interlaced
                            DECLARE
                                PASS       PLS_INTEGER;
                                PASS_IND   TP_PLS_TAB;
                            BEGIN
                                DBMS_LOB.CREATETEMPORARY(IMG_BLOB,TRUE);
                                PASS_IND(1) := 1;
                                PASS_IND(2) := TRUNC( (IMG.HEIGHT - 1) / 8) + 1;

                                PASS_IND(3) := PASS_IND(2) + TRUNC( (IMG.HEIGHT + 3) / 8);

                                PASS_IND(4) := PASS_IND(3) + TRUNC( (IMG.HEIGHT + 1) / 4);

                                PASS_IND(2) := PASS_IND(2) * IMG.WIDTH + 1;
                                PASS_IND(3) := PASS_IND(3) * IMG.WIDTH + 1;
                                PASS_IND(4) := PASS_IND(4) * IMG.WIDTH + 1;
                                FOR I IN 0..IMG.HEIGHT - 1 LOOP
                                    PASS :=
                                        CASE MOD(I,8)
                                            WHEN 0 THEN 1
                                            WHEN 4 THEN 2
                                            WHEN 2 THEN 3
                                            WHEN 6 THEN 3
                                            ELSE 4
                                        END;

                                    DBMS_LOB.APPEND(IMG_BLOB,DBMS_LOB.SUBSTR(IMG.PIXELS,IMG.WIDTH,PASS_IND(PASS) ) );

                                    PASS_IND(PASS) := PASS_IND(PASS) + IMG.WIDTH;
                                END LOOP;

                                IMG.PIXELS := IMG_BLOB;
                            END;
                        END IF;
--

                        DBMS_LOB.FREETEMPORARY(IMG_BLOB);
                    END;
                ELSE
                    EXIT;
            END CASE;
        END LOOP;
--

        IMG.TYPE := 'gif';
        RETURN IMG;
    END;
--

    FUNCTION PARSE_IMG (
        P_BLOB      IN BLOB,
        P_ADLER32   IN VARCHAR2 := NULL,
        P_TYPE      IN VARCHAR2 := NULL
    ) RETURN TP_IMG IS
        T_IMG   TP_IMG;
    BEGIN
        T_IMG.TYPE := P_TYPE;
        IF
            T_IMG.TYPE IS NULL
        THEN
            IF
                RAWTOHEX(DBMS_LOB.SUBSTR(P_BLOB,8,1) ) = '89504E470D0A1A0A'
            THEN
                T_IMG.TYPE := 'png';
            ELSIF DBMS_LOB.SUBSTR(P_BLOB,3,1) = UTL_RAW.CAST_TO_RAW('GIF') THEN
                T_IMG.TYPE := 'gif';
            ELSE
                T_IMG.TYPE := 'jpg';
            END IF;

        END IF;
--

        T_IMG :=
            CASE LOWER(T_IMG.TYPE)
                WHEN 'gif' THEN PARSE_GIF(P_BLOB)
                WHEN 'png' THEN PARSE_PNG(P_BLOB)
                WHEN 'jpg' THEN PARSE_JPG(P_BLOB)
                ELSE NULL
            END;
--

        IF
            T_IMG.TYPE IS NOT NULL
        THEN
            T_IMG.ADLER32 := COALESCE(P_ADLER32,ADLER32(P_BLOB) );
        END IF;

        RETURN T_IMG;
    END;
--

    PROCEDURE PUT_IMAGE (
        P_IMG       BLOB,
        P_X         NUMBER,
        P_Y         NUMBER,
        P_WIDTH     NUMBER := NULL,
        P_HEIGHT    NUMBER := NULL,
        P_ALIGN     VARCHAR2 := 'center',
        P_VALIGN    VARCHAR2 := 'top',
        P_ADLER32   VARCHAR2 := NULL
    ) IS

        T_X         NUMBER;
        T_Y         NUMBER;
        T_IMG       TP_IMG;
        T_IND       PLS_INTEGER;
        T_ADLER32   VARCHAR2(8) := P_ADLER32;
    BEGIN
        IF
            P_IMG IS NULL
        THEN
            RETURN;
        END IF;
        IF
            T_ADLER32 IS NULL
        THEN
            T_ADLER32 := ADLER32(P_IMG);
        END IF;
        T_IND := G_IMAGES.FIRST;
        WHILE T_IND IS NOT NULL LOOP
            EXIT WHEN G_IMAGES(T_IND).ADLER32 = T_ADLER32;
            T_IND := G_IMAGES.NEXT(T_IND);
        END LOOP;
--

        IF
            T_IND IS NULL
        THEN
            T_IMG := PARSE_IMG(P_IMG,T_ADLER32);
            IF
                T_IMG.ADLER32 IS NULL
            THEN
                RETURN;
            END IF;
            T_IND := G_IMAGES.COUNT () + 1;
            G_IMAGES(T_IND) := T_IMG;
        END IF;
--

        T_X :=
            CASE SUBSTR(UPPER(P_ALIGN),1,1)
                WHEN 'L' THEN P_X -- left
                WHEN 'S' THEN P_X -- start
                WHEN 'R' THEN P_X + NVL(P_WIDTH,0) - G_IMAGES(T_IND).WIDTH -- right
                WHEN 'E' THEN P_X + NVL(P_WIDTH,0) - G_IMAGES(T_IND).WIDTH -- end
                ELSE ( P_X + NVL(P_WIDTH,0) - G_IMAGES(T_IND).WIDTH ) / 2       -- center
            END;

        T_Y :=
            CASE SUBSTR(UPPER(P_VALIGN),1,1)
                WHEN 'C' THEN ( P_Y - NVL(P_HEIGHT,0) + G_IMAGES(T_IND).HEIGHT ) / 2  -- center
                WHEN 'B' THEN P_Y - NVL(P_HEIGHT,0) + G_IMAGES(T_IND).HEIGHT -- bottom
                ELSE P_Y                                          -- top
            END;
--

        TXT2PAGE('q '
        || TO_CHAR_ROUND(LEAST(NVL(P_WIDTH,G_IMAGES(T_IND).WIDTH),G_IMAGES(T_IND).WIDTH) )
        || ' 0 0 '
        || TO_CHAR_ROUND(LEAST(NVL(P_HEIGHT,G_IMAGES(T_IND).HEIGHT),G_IMAGES(T_IND).HEIGHT) )
        || ' '
        || TO_CHAR_ROUND(T_X)
        || ' '
        || TO_CHAR_ROUND(T_Y)
        || ' cm /I'
        || TO_CHAR(T_IND)
        || ' Do Q');

    END;
--

    PROCEDURE PUT_IMAGE (
        P_DIR         VARCHAR2,
        P_FILE_NAME   VARCHAR2,
        P_X           NUMBER,
        P_Y           NUMBER,
        P_WIDTH       NUMBER := NULL,
        P_HEIGHT      NUMBER := NULL,
        P_ALIGN       VARCHAR2 := 'center',
        P_VALIGN      VARCHAR2 := 'top',
        P_ADLER32     VARCHAR2 := NULL
    ) IS
        T_BLOB   BLOB;
    BEGIN
        T_BLOB := FILE2BLOB(P_DIR,P_FILE_NAME);
        PUT_IMAGE(T_BLOB,P_X,P_Y,P_WIDTH,P_HEIGHT,P_ALIGN,P_VALIGN,P_ADLER32);

        DBMS_LOB.FREETEMPORARY(T_BLOB);
    END;
--

    PROCEDURE PUT_IMAGE (
        P_URL       VARCHAR2,
        P_X         NUMBER,
        P_Y         NUMBER,
        P_WIDTH     NUMBER := NULL,
        P_HEIGHT    NUMBER := NULL,
        P_ALIGN     VARCHAR2 := 'center',
        P_VALIGN    VARCHAR2 := 'top',
        P_ADLER32   VARCHAR2 := NULL
    ) IS
        T_BLOB   BLOB;
    BEGIN
        T_BLOB := HTTPURITYPE(P_URL).GETBLOB ();
        PUT_IMAGE(T_BLOB,P_X,P_Y,P_WIDTH,P_HEIGHT,P_ALIGN,P_VALIGN,P_ADLER32);

        DBMS_LOB.FREETEMPORARY(T_BLOB);
    END;
--

    PROCEDURE SET_PAGE_PROC (
        P_SRC CLOB
    )
        IS
    BEGIN
        G_PAGE_PRCS(G_PAGE_PRCS.COUNT) := P_SRC;
    END;
--

    PROCEDURE CURSOR2TABLE (
        P_C         INTEGER,
        P_WIDTHS    TP_COL_WIDTHS := NULL,
        P_HEADERS   TP_HEADERS := NULL
    ) IS

        T_COL_CNT       INTEGER;
$IF DBMS_DB_VERSION.VER_LE_10 $THEN

        T_DESC_TAB      DBMS_SQL.DESC_TAB2;
$ELSE
    t_desc_tab dbms_sql.desc_tab3;
$END
        D_TAB           DBMS_SQL.DATE_TABLE;
        N_TAB           DBMS_SQL.NUMBER_TABLE;
        V_TAB           DBMS_SQL.VARCHAR2_TABLE;
        T_BULK_SIZE     PLS_INTEGER := 200;
        T_R             INTEGER;
        T_CUR_ROW       PLS_INTEGER;
        TYPE TP_INTEGER_TAB IS
            TABLE OF INTEGER;
        T_CHARS         TP_INTEGER_TAB := TP_INTEGER_TAB(1,8,9,96,112);
        T_DATES         TP_INTEGER_TAB := TP_INTEGER_TAB(12,178,179,180,181,231);
        T_NUMERICS      TP_INTEGER_TAB := TP_INTEGER_TAB(2,100,101);
        T_WIDTHS        TP_COL_WIDTHS;
        T_TMP           NUMBER;
        T_X             NUMBER;
        T_Y             NUMBER;
        T_START_X       NUMBER;
        T_LINEHEIGHT    NUMBER;
        T_PADDING       NUMBER := 2;
        T_NUM_FORMAT    VARCHAR2(100) := 'tm9';
        T_DATE_FORMAT   VARCHAR2(100) := 'dd.mm.yyyy';
        T_TXT           VARCHAR2(32767);
        C_RF            NUMBER := 0.2; -- raise factor of text above cell bottom
--

        PROCEDURE SHOW_HEADER
            IS
        BEGIN
            IF
                P_HEADERS IS NOT NULL AND P_HEADERS.COUNT > 0
            THEN
                T_X := T_START_X;
                FOR C IN 1..T_COL_CNT LOOP
                    RECT(T_X,T_Y,T_WIDTHS(C),T_LINEHEIGHT);
                    IF
                        C <= P_HEADERS.COUNT
                    THEN
                        PUT_TXT(T_X + T_PADDING,T_Y + C_RF * T_LINEHEIGHT,P_HEADERS(C) );
                    END IF;

                    T_X := T_X + T_WIDTHS(C);
                END LOOP;

                T_Y := T_Y - T_LINEHEIGHT;
            END IF;
        END;
--

    BEGIN
$IF DBMS_DB_VERSION.VER_LE_10 $THEN

        DBMS_SQL.DESCRIBE_COLUMNS2(P_C,T_COL_CNT,T_DESC_TAB);
$ELSE
    dbms_sql.describe_columns3( p_c, t_col_cnt, t_desc_tab );
$END
        IF
            P_WIDTHS IS NULL OR P_WIDTHS.COUNT < T_COL_CNT
        THEN
            T_TMP := GET(C_GET_PAGE_WIDTH) - GET(C_GET_MARGIN_LEFT) - GET(C_GET_MARGIN_RIGHT);
            T_WIDTHS := TP_COL_WIDTHS ();
            T_WIDTHS.EXTEND(T_COL_CNT);
            FOR C IN 1..T_COL_CNT LOOP
                T_WIDTHS(C) := ROUND(T_TMP / T_COL_CNT,1);
            END LOOP;

        ELSE
            T_WIDTHS := P_WIDTHS;
        END IF;
--

        IF
            GET(C_GET_CURRENT_FONT) IS NULL
        THEN
            SET_FONT('helvetica',12);
        END IF;
--
        FOR C IN 1..T_COL_CNT LOOP
            CASE
                WHEN T_DESC_TAB(C).COL_TYPE MEMBER OF T_NUMERICS THEN
                    DBMS_SQL.DEFINE_ARRAY(P_C,C,N_TAB,T_BULK_SIZE,1);
                WHEN T_DESC_TAB(C).COL_TYPE MEMBER OF T_DATES THEN
                    DBMS_SQL.DEFINE_ARRAY(P_C,C,D_TAB,T_BULK_SIZE,1);
                WHEN T_DESC_TAB(C).COL_TYPE MEMBER OF T_CHARS THEN
                    DBMS_SQL.DEFINE_ARRAY(P_C,C,V_TAB,T_BULK_SIZE,1);
                ELSE
                    NULL;
            END CASE;
        END LOOP;
--

        T_START_X := GET(C_GET_MARGIN_LEFT);
        T_LINEHEIGHT := GET(C_GET_FONTSIZE) * 1.2;
        T_Y := COALESCE(GET(C_GET_Y) - T_LINEHEIGHT,GET(C_GET_PAGE_HEIGHT) - GET(C_GET_MARGIN_TOP) ) - T_LINEHEIGHT;
--

        SHOW_HEADER;
--
        LOOP
            T_R := DBMS_SQL.FETCH_ROWS(P_C);
            FOR I IN 0..T_R - 1 LOOP
                IF
                    T_Y < GET(C_GET_MARGIN_BOTTOM)
                THEN
                    NEW_PAGE;
                    T_Y := GET(C_GET_PAGE_HEIGHT) - GET(C_GET_MARGIN_TOP) - T_LINEHEIGHT;
                    SHOW_HEADER;
                END IF;

                T_X := T_START_X;
                FOR C IN 1..T_COL_CNT LOOP
                    CASE
                        WHEN T_DESC_TAB(C).COL_TYPE MEMBER OF T_NUMERICS THEN
                            N_TAB.DELETE;
                            DBMS_SQL.COLUMN_VALUE(P_C,C,N_TAB);
                            RECT(T_X,T_Y,T_WIDTHS(C),T_LINEHEIGHT);
                            T_TXT := TO_CHAR(N_TAB(I + N_TAB.FIRST() ),T_NUM_FORMAT);

                            IF
                                T_TXT IS NOT NULL
                            THEN
                                PUT_TXT(T_X + T_WIDTHS(C) - T_PADDING - STR_LEN(T_TXT),T_Y + C_RF * T_LINEHEIGHT,T_TXT);
                            END IF;

                            T_X := T_X + T_WIDTHS(C);
                        WHEN T_DESC_TAB(C).COL_TYPE MEMBER OF T_DATES THEN
                            D_TAB.DELETE;
                            DBMS_SQL.COLUMN_VALUE(P_C,C,D_TAB);
                            RECT(T_X,T_Y,T_WIDTHS(C),T_LINEHEIGHT);
                            T_TXT := TO_CHAR(D_TAB(I + D_TAB.FIRST() ),T_DATE_FORMAT);

                            IF
                                T_TXT IS NOT NULL
                            THEN
                                PUT_TXT(T_X + T_PADDING,T_Y + C_RF * T_LINEHEIGHT,T_TXT);
                            END IF;

                            T_X := T_X + T_WIDTHS(C);
                        WHEN T_DESC_TAB(C).COL_TYPE MEMBER OF T_CHARS THEN
                            V_TAB.DELETE;
                            DBMS_SQL.COLUMN_VALUE(P_C,C,V_TAB);
                            RECT(T_X,T_Y,T_WIDTHS(C),T_LINEHEIGHT);
                            T_TXT := V_TAB(I + V_TAB.FIRST() );
                            IF
                                T_TXT IS NOT NULL
                            THEN
                                PUT_TXT(T_X + T_PADDING,T_Y + C_RF * T_LINEHEIGHT,T_TXT);
                            END IF;

                            T_X := T_X + T_WIDTHS(C);
                        ELSE
                            NULL;
                    END CASE;
                END LOOP;

                T_Y := T_Y - T_LINEHEIGHT;
            END LOOP;

            EXIT WHEN T_R != T_BULK_SIZE;
        END LOOP;

        G_Y := T_Y;
    END;
--

    PROCEDURE QUERY2TABLE (
        P_QUERY     VARCHAR2,
        P_WIDTHS    TP_COL_WIDTHS := NULL,
        P_HEADERS   TP_HEADERS := NULL
    ) IS
        T_CX      INTEGER;
        T_DUMMY   INTEGER;
    BEGIN
        T_CX := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(T_CX,P_QUERY,DBMS_SQL.NATIVE);
        T_DUMMY := DBMS_SQL.EXECUTE(T_CX);
        CURSOR2TABLE(T_CX,P_WIDTHS,P_HEADERS);
        DBMS_SQL.CLOSE_CURSOR(T_CX);
    END;

    PROCEDURE PR_GOTO_PAGE (
        I_NPAGE IN NUMBER
    )
        IS
    BEGIN
        IF
            I_NPAGE <= G_PAGES.COUNT
        THEN
            G_PAGE_NR := I_NPAGE - 1;
        END IF;
    END;

    PROCEDURE PR_GOTO_CURRENT_PAGE
        IS
    BEGIN
        G_PAGE_NR := NULL;
    END;

    FUNCTION FK_GET_PAGE RETURN NUMBER
        IS
    BEGIN
        RETURN G_PAGE_NR;
    END;

    PROCEDURE PR_LINE (
        I_NX1           IN NUMBER,
        I_NY1           IN NUMBER,
        I_NX2           IN NUMBER,
        I_NY2           IN NUMBER,
        I_VCLINECOLOR   IN VARCHAR2 DEFAULT NULL,
        I_NLINEWIDTH    IN NUMBER DEFAULT 0.5,
        I_VCSTROKE      IN VARCHAR2 DEFAULT NULL
    )
        IS
    BEGIN
        TXT2PAGE('q ');
        TXT2PAGE(TO_CHAR_ROUND(I_NLINEWIDTH,5)
        || ' w');
        IF
            SUBSTR(I_VCLINECOLOR,-6) != '000000'
        THEN
            SET_BK_COLOR(I_VCLINECOLOR);
        ELSE
            TXT2PAGE('0 g');
        END IF;

        TXT2PAGE('n ');
        IF
            I_VCSTROKE IS NOT NULL
        THEN
            TXT2PAGE(I_VCSTROKE
            || ' d ');
        END IF;
        TXT2PAGE(TO_CHAR_ROUND(I_NX1,5)
        || ' '
        || TO_CHAR_ROUND(I_NY1,5)
        || ' m ');

        TXT2PAGE(TO_CHAR_ROUND(I_NX2,5)
        || ' '
        || TO_CHAR_ROUND(I_NY2,5)
        || ' l S Q');

    END;

    PROCEDURE PR_POLYGON (
        I_LXS           IN TVERTICES,
        I_LYS           IN TVERTICES,
        I_VCLINECOLOR   IN VARCHAR2 DEFAULT NULL,
        I_VCFILLCOLOR   IN VARCHAR2 DEFAULT NULL,
        I_NLINEWIDTH    IN NUMBER DEFAULT 0.5
    ) IS
        VCBUFFER   VARCHAR2(32767);
    BEGIN
        IF
            I_LXS.COUNT > 0 AND I_LXS.COUNT = I_LYS.COUNT
        THEN
            TXT2PAGE('q ');
            IF
                SUBSTR(I_VCLINECOLOR,-6) != SUBSTR(I_VCFILLCOLOR,-6)
            THEN
                TXT2PAGE(TO_CHAR_ROUND(I_NLINEWIDTH,5)
                || ' w');
            END IF;

            IF
                SUBSTR(I_VCLINECOLOR,-6) != '000000'
            THEN
                SET_BK_COLOR(I_VCLINECOLOR);
            ELSE
                TXT2PAGE('0 g');
            END IF;

            IF
                I_VCFILLCOLOR IS NOT NULL
            THEN
                SET_COLOR(I_VCFILLCOLOR);
            END IF;
            TXT2PAGE(' 2.00000 M ');
            TXT2PAGE('n ');
            VCBUFFER := TO_CHAR_ROUND(I_LXS(1),5)
            || ' '
            || TO_CHAR_ROUND(I_LYS(1),5)
            || ' m ';

            FOR I IN 2..I_LXS.COUNT LOOP
                VCBUFFER := VCBUFFER
                || TO_CHAR_ROUND(I_LXS(I),5)
                || ' '
                || TO_CHAR_ROUND(I_LYS(I),5)
                || ' l ';
            END LOOP;

            VCBUFFER := VCBUFFER
            || TO_CHAR_ROUND(I_LXS(1),5)
            || ' '
            || TO_CHAR_ROUND(I_LYS(1),5)
            || ' l ';

            VCBUFFER := VCBUFFER
            || CASE
                WHEN I_VCFILLCOLOR IS NULL THEN 'S'
                ELSE
                    CASE
                        WHEN I_VCLINECOLOR IS NULL THEN 'f'
                        ELSE 'b'
                    END
            END;

            TXT2PAGE(VCBUFFER
            || ' Q');
        END IF;
    END;

    PROCEDURE PR_PATH (
        I_LPATH         IN TPATH,
        I_VCLINECOLOR   IN VARCHAR2 DEFAULT NULL,
        I_VCFILLCOLOR   IN VARCHAR2 DEFAULT NULL,
        I_NLINEWIDTH    IN NUMBER DEFAULT 0.5
    ) IS
        VCBUFFER   VARCHAR2(32767);
    BEGIN
        TXT2PAGE('q ');
        IF
            SUBSTR(I_VCLINECOLOR,-6) != SUBSTR(I_VCFILLCOLOR,-6)
        THEN
            TXT2PAGE(TO_CHAR_ROUND(I_NLINEWIDTH,5)
            || ' w');
        END IF;

        IF
            SUBSTR(I_VCLINECOLOR,-6) != '000000'
        THEN
            SET_BK_COLOR(I_VCLINECOLOR);
        ELSE
            TXT2PAGE('0 g');
        END IF;

        IF
            I_VCFILLCOLOR IS NOT NULL
        THEN
            SET_COLOR(I_VCFILLCOLOR);
        END IF;
        TXT2PAGE('n ');
        FOR I IN 1..I_LPATH.COUNT LOOP
            IF
                I_LPATH(I).NTYPE = PATH_MOVE_TO
            THEN
                VCBUFFER := VCBUFFER
                || TO_CHAR_ROUND(I_LPATH(I).NVAL1,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL2,5)
                || ' m ';

            ELSIF I_LPATH(I).NTYPE = PATH_LINE_TO THEN
                VCBUFFER := VCBUFFER
                || TO_CHAR_ROUND(I_LPATH(I).NVAL1,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL2,5)
                || ' l ';
            ELSIF I_LPATH(I).NTYPE = PATH_CURVE_TO THEN
                VCBUFFER := VCBUFFER
                || TO_CHAR_ROUND(I_LPATH(I).NVAL1,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL2,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL3,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL4,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL5,5)
                || ' '
                || TO_CHAR_ROUND(I_LPATH(I).NVAL6,5)
                || ' c ';
            ELSIF I_LPATH(I).NTYPE = PATH_CLOSE THEN
                VCBUFFER := VCBUFFER
                || CASE
                    WHEN I_VCFILLCOLOR IS NULL THEN 'S'
                    ELSE
                        CASE
                            WHEN I_VCLINECOLOR IS NULL THEN 'f'
                            ELSE 'b'
                        END
                END;
            END IF;
        END LOOP;

        TXT2PAGE(VCBUFFER
        || ' Q');
    END;
$IF not DBMS_DB_VERSION.VER_LE_10 $THEN
--

    PROCEDURE REFCURSOR2TABLE (
        P_RC        SYS_REFCURSOR,
        P_WIDTHS    TP_COL_WIDTHS := NULL,
        P_HEADERS   TP_HEADERS := NULL
    ) IS
        T_CX   INTEGER;
        T_RC   SYS_REFCURSOR;
    BEGIN
        T_RC := P_RC;
        T_CX := DBMS_SQL.TO_CURSOR_NUMBER(T_RC);
        CURSOR2TABLE(T_CX,P_WIDTHS,P_HEADERS);
        DBMS_SQL.CLOSE_CURSOR(T_CX);
    END;
$END

BEGIN
    FOR I IN 0..255 LOOP
        LHEX(TO_CHAR(I,'FM0X') ) := I;
    END LOOP;
END;
/

