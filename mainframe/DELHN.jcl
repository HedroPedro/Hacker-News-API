//DELETE   JOB  001,NOTIFY=&SYSUID
//IDCAMS   EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
     DELETE &SYSUID..HN.CLSTER  -
          PURGE                               
/*
//
