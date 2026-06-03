//CREATE   JOB  001,NOTIFY=&SYSUID
//IDCAMS   EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
 DEFINE    CLUSTER  (NAME(&SYSUID..HN.CLSTER)                 -
                    TRACKS(2 1)                               -
                    RECORDSIZE(26 26)                         -
                    SPACE(197 10)
                    KEYS(4 0)                                 -
                    INDEXED)                                  -
           INDEX    (NAME(&SYSUID..HN.INDEX))
/*
//