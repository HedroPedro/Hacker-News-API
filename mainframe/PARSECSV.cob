       IDENTIFICATION DIVISION. 
       PROGRAM-ID. PARSECSV.
       AUTHOR. PEDRO.
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 
       SOURCE-COMPUTER. IBM-3081. 
       OBJECT-COMPUTER. IBM-3081. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CSV-FILE ASSIGN TO CSV ORGANIZATION IS LINE SEQUENTIAL
              ACCESS IS SEQUENTIAL.
              SELECT CLSTER-FILE ASSIGN TO CLSTER
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS CLSTER-KEY
               FILE STATUS IS WS-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD CSV-FILE
       01 CSV-REC.
           05 CSV-ID      PIC X(6).
           05 FILLER      PIC X VALUE ','.
           05 CSV-KARMA   PIC 9(6).
           05 FILLER      PIC X VALUE ','.
           05 CSV-COMMENT PIC 9(7).
           05 FILLER      PIC X(59) VALUE SPACE.
       FD CLSTER-FILE
       01 CLSTER-REC.
           05 CLSTER-KEY     PIC 9(6).
           05 CLSTER-POINT   PIC 9(11).
           05 CLSTER-COMMENT PIC 9(11).
       WORKING-STORAGE SECTION.
           05 WS-STATUS      PIC 9(2).
           05 WS-CUR-REC. 
              10 WS-CURRENT-KEY PIC 9(6) VALUE ZERO.
              10 WS-CUR-KARMA   PIC 9(10) VALUE ZERO.
              10 WS-CUR-COMMENT PIC 9(12) VALUE ZERO.
           05 WS-END         PIC X VALUE 'N'.
           05 WS-FIRST       PIC X VALUE 'Y'.
       PROCEDURE DIVISION.
       MAIN-LOGIC SECTION.
         000-START.
           OPEN INPUT CSV-FILE.
           OPEN OUTPUT CLSTER-FILE.
         010-PROCESS.
           PERFORM UNTIL WS-END EQUAL 'Y'
              READ CSV-FILE AT END 
                 MOVE 'Y' TO WS-END
                 WRITE CLSTER-REC FROM WS-CUR-REC
                 EXIT PERFORM
              END-READ
              IF WS-FIRST EQUAL 'Y'
                 PERFORM ADD-TO-CURRENT
                 MOVE 'N' TO WS-FIRST 
                 EXIT PERFORM CYCLE
              END-IF
              IF WS-CURRENT-KEY NOT EQUAL TO CSV-ID
                 WRITE CLSTER-REC FROM WS-CUR-REC
                 MOVE 'Y' TO WS-FIRST
                 MOVE ALL ZERO TO WS-CUR-REC 
              ELSE
                 PERFORM ADD-TO-CURRENT
              END-IF
           END-PERFORM. 
         020-END.
           CLOSE CSV-FILE.
           CLOSE CLSTER-FILE.
           GOBACK.
         ADD-TO-CURRENT.
           ADD CSV-KARMA TO WS-CUR-KARMA.
           ADD CSV-COMMENT TO WS-CUR-COMMENT. 