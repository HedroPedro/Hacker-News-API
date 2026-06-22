//CREATE   JOB  001,NOTIFY=&SYSUID
//IDCAMS   EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
 DEFINE    CLUSTER  (NAME(UID.HN.CLSTER)                      -
                    TRACKS(2 2)                               -
                    RECORDSIZE(28 28)                         -
                    KEYS(6 0)                                 -
                    INDEXED)                                  -
           DATA     (NAME(UID.HN.DATA))                       -
           INDEX    (NAME(UID.HN.INDEX))
/*
//