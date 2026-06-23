       IDENTIFICATION DIVISION. 
       PROGRAM-ID. GETHN.
       AUTHOR. PEDRO.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT JSON-FD ASSIGN TO RESULT.
           SELECT CLSTER-FD ASSIGN TO CLSTER
              ORGANIZATION IS INDEXED
              ACCESS MODE IS RANDOM
              RECORD KEY IS CLSTER-KEY
              FILE STATUS IS VSAM-FLAGS.
       DATA DIVISION.
       FILE SECTION.
       FD JSON-FD.
       01 JSON-DATA PIC X(10000).
       FD CLSTER-FD.
       01 CLSTER-REC.
           05 CLSTER-KEY     PIC X(6).
           05 CLSTER-SCORE   PIC 9(11).
           05 CLSTER-COMMENT PIC 9(11).
       WORKING-STORAGE SECTION.
       01  WS-FLAGS.
           05 VSAM-FLAGS     PIC 9(2) VALUE ZERO.
           05 JSON-FLAGS     PIC 9(2) VALUE ZERO.
           05 ANY-VAL        PIC X VALUE 'N'.
       01  JSON-REC.
           05 TYPE-INFO      PIC X(5).
           05 TOTAL-SCORE    PIC 9(11).
           05 TOTAL-COMMENTS PIC 9(11).
           05 AVG-SCORE      PIC 9(11)V99 VALUE ZERO.
           05 AVG-COMMENT    PIC 9(11)V99 VALUE ZERO.
       01 ERROR-JSON.
           05 TYPE-INFO  PIC X(5) VALUE 'ERROR'.
           05 REASON     PIC X(25).
           05 ERR-CODE   PIC 9(3).
      *
       01 WS-ID.
           05 WS-YEAR   PIC 9(4).
           05 WS-MON    PIC 9(2).
       01 WS-COUNTERS.
           05 WS-YEAR-CTR  PIC 9(4).
           05 WS-MON-CTR   PIC 9(2).
           05 WS-TOTAL-CTR PIC 9(4).  
       01 WS-TEMP-VALS VALUE ZERO.
           05 TMP-AVG-SCORE    PIC 9(22).
           05 TMP-AVG-COMMENTS PIC 9(22).
       LINKAGE SECTION.
       01 PARMDATA.
           05 STRINGLEN PIC  S9(4) USAGE COMP.
           05 STRINGPARM PIC X(80).
       PROCEDURE DIVISION USING PARMDATA.
       000-MAIN.
           OPEN OUTPUT JSON-FD.
           OPEN INPUT CLSTER-FD.
           PERFORM PROCESS-ARGS.
       010-END.
           CLOSE JSON-FD.
           CLOSE CLSTER-FD.
           GOBACK.
      *       
       PROCESS-ARGS.
           IF STRINGLEN EQUAL ZERO
              MOVE 'MUST HAVE YEAR OR MONTH' TO REASON
              MOVE 500 TO ERR-CODE
              PERFORM GEN-ERROR-JSON
           END-IF. 
           IF STRINGPARM(1:5) EQUAL TO 'YEAR='
              SUBTRACT 5 FROM STRINGLEN
              IF STRINGLEN NOT EQUAL TO 4
                 MOVE 'YEAR MUST HAVE 4 DIGITS' TO REASON
                 MOVE 500 TO ERR-CODE
                 PERFORM GEN-ERROR-JSON 
                 EXIT PARAGRAPH
              END-IF
              MOVE STRINGPARM(6:4) TO STRINGPARM
              IF STRINGPARM IS NOT NUMERIC
                 MOVE 'EXPECTED NUMBERS' TO REASON
                 MOVE 500 TO ERR-CODE
                 PERFORM GEN-ERROR-JSON
                 EXIT PARAGRAPH
              END-IF
              MOVE STRINGPARM(1:4) TO WS-YEAR 
              PERFORM GET-ALL-SAME-YEAR
              EXIT PARAGRAPH
           END-IF.
           IF STRINGPARM(1:6) EQUAL TO 'MONTH='
              SUBTRACT 6 FROM STRINGLEN
              IF STRINGLEN NOT EQUAL TO 2
                 MOVE 'MONTH MUST HAVE 2 DIGITS' TO REASON
                 MOVE 500 TO ERR-CODE
                 PERFORM GEN-ERROR-JSON
                 EXIT PARAGRAPH
              END-IF
              MOVE STRINGPARM(7:2) TO STRINGPARM
              IF STRINGPARM IS NOT NUMERIC
                 MOVE 'EXPECTED NUMBERS' TO REASON
                 MOVE 500 TO ERR-CODE
                 PERFORM GEN-ERROR-JSON
                 EXIT PARAGRAPH
              END-IF
              MOVE STRINGPARM(1:2) TO WS-MON
              PERFORM GET-ALL-SAME-MON
              EXIT PARAGRAPH
           END-IF
           IF STRINGPARM(1:10) EQUAL TO 'YEARMONTH='
              SUBTRACT 10 FROM STRINGLEN
              IF STRINGLEN NOT EQUAL TO 6
                 MOVE 'ID MUST HAVE 6 DIGITS' TO REASON
                 MOVE 500 TO ERR-CODE
                 PERFORM GEN-ERROR-JSON
                 EXIT PARAGRAPH
              END-IF
              MOVE STRINGPARM(11:6) TO STRINGPARM
              IF STRINGPARM IS NOT NUMERIC
                 MOVE 'EXPECTED NUMBERS' TO REASON
                 MOVE 500 TO ERR-CODE
                 PERFORM GEN-ERROR-JSON
                 EXIT PARAGRAPH
              END-IF
              MOVE STRINGPARM(1:6) TO CLSTER-KEY
              PERFORM GET-ID
              EXIT PARAGRAPH
           END-IF.
           MOVE 'INVALID ARGUMENT' TO ERROR-JSON.
           MOVE 500 TO ERR-CODE.
           PERFORM GEN-ERROR-JSON.
       GEN-JSON-GENERIC.
           JSON GENERATE JSON-DATA FROM JSON-REC.
           WRITE JSON-DATA.
       GEN-ERROR-JSON.
           JSON GENERATE JSON-DATA FROM ERROR-JSON.
           WRITE JSON-DATA.
       READ-VSAM.
           READ CLSTER-FD
              INVALID KEY CONTINUE
              NOT INVALID KEY
                 MOVE 'Y' TO ANY-VAL
                 ADD CLSTER-SCORE TO TMP-AVG-SCORE
                 ADD CLSTER-COMMENT TO TMP-AVG-COMMENTS
                 ADD 1 TO WS-TOTAL-CTR
           END-READ.
       CALC-AVG.
           DIVIDE TMP-AVG-SCORE BY WS-TOTAL-CTR 
              GIVING AVG-SCORE ROUNDED.
           DIVIDE TMP-AVG-COMMENTS BY WS-TOTAL-CTR 
              GIVING AVG-COMMENT ROUNDED.
       GET-ALL-SAME-YEAR.
           PERFORM VARYING WS-MON-CTR
            FROM 1 BY 1
            UNTIL WS-MON-CTR > 12
              MOVE WS-MON-CTR TO WS-MON
              MOVE WS-ID TO CLSTER-KEY
              PERFORM READ-VSAM
           END-PERFORM.
           IF ANY-VAL EQUAL 'N'
              MOVE 'DATA NOT FOUND' TO REASON
              MOVE 404 TO ERR-CODE
              PERFORM GEN-ERROR-JSON
           ELSE
              PERFORM CALC-AVG
              MOVE 'YEAR' TO TYPE-INFO IN JSON-REC
              PERFORM GEN-JSON-GENERIC
           END-IF.
       GET-ALL-SAME-MON.
           MOVE 2006 TO WS-YEAR
           PERFORM UNTIL VSAM-FLAGS NOT EQUAL 0
               MOVE WS-ID TO CLSTER-KEY
               PERFORM READ-VSAM
               ADD 1 TO WS-YEAR
           END-PERFORM.
           IF ANY-VAL EQUAL 'N'
              MOVE 'DATA NOT FOUND' TO REASON
              MOVE 404 TO ERR-CODE
              PERFORM GEN-ERROR-JSON
           ELSE
              PERFORM CALC-AVG
              MOVE 'MONTH' TO TYPE-INFO IN JSON-REC
              PERFORM GEN-JSON-GENERIC
           END-IF.
       GET-ID.
           PERFORM READ-VSAM.
           IF ANY-VAL NOT EQUAL TO 'Y'
              MOVE 'ID NOT FOUND' TO REASON
              MOVE 404 TO ERR-CODE
              PERFORM GEN-ERROR-JSON
           ELSE
              MOVE 'ID' TO TYPE-INFO IN JSON-REC 
              MOVE CLSTER-SCORE TO TOTAL-SCORE
              MOVE CLSTER-COMMENT TO TOTAL-COMMENTS
              JSON GENERATE JSON-DATA FROM JSON-REC
                 SUPPRESS AVG-SCORE, AVG-COMMENT
              END-JSON
              WRITE JSON-DATA
           END-IF.