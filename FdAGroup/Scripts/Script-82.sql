


SELECT syslog_facility, syslog_severity, cast(syslog_event as varchar(2048) CCSID 37) FROM TABLE (QSYS2.DISPLAY_JOURNAL('QSYS','QAUDJRN',GENERATE_SYSLOG => 'RFC5424')) AS X WHERE syslog_event IS NOT NULL

SELECT syslog_facility, syslog_severity, syslog_event FROM TABLE (QSYS2.HISTORY_LOG_INFO(START_TIME => CURRENT DATE,GENERATE_SYSLOG => 'RFC5424')) AS X

--############

SELECT syslog_facility, syslog_severity, syslog_event FROM TABLE (QSYS2.DISPLAY_JOURNAL('QSYS','QAUDJRN',GENERATE_SYSLOG => 'RFC5424')) AS X WHERE syslog_event LIKE '%192.9.207.200%'

SELECT syslog_facility, syslog_severity, cast(syslog_event as varchar(2048) CCSID 37) FROM TABLE (QSYS2.DISPLAY_JOURNAL('QSYS','QAUDJRN',GENERATE_SYSLOG => 'RFC5424')) AS X WHERE syslog_event LIKE '%192.9.207.200%'

SELECT syslog_facility, syslog_severity, syslog_event FROM TABLE (QSYS2.HISTORY_LOG_INFO(START_TIME => CURRENT DATE,GENERATE_SYSLOG => 'RFC5424')) AS X 
WHERE syslog_event LIKE '%192.9%'


SELECT * 
--cast(MESSAGE_TOKENS as varchar(2048) CCSID 1144 )
FROM TABLE (QSYS2.HISTORY_LOG_INFO(START_TIME => CURRENT DATE, GENERATE_SYSLOG => 'RFC5424')) AS X
WHERE FROM_JOB_USER='EDP01' AND MESSAGE_ID='CPC1234' AND message_text NOT LIKE '%SMESQL2/SMEJOBD%'

SELECT *  FROM TABLE(QSYS2.HISTORY_LOG_INFO())

  SELECT MESSAGE_ID AS "Id",
         MESSAGE_TYPE AS "Type",
         SEVERITY AS "Sev",
         MESSAGE_TIMESTAMP "Msg time",
         FROM_USER AS "From user",
         FROM_JOB AS "From job",
         FROM_JOB_NAME,
         FROM_JOB_USER
   FROM TABLE(QSYS2.HISTORY_LOG_INFO())
   WHERE FROM_USER <> FROM_JOB_USER
   ORDER BY ORDINAL_POSITION DESC
   LIMIT 5
   
SELECT * FROM TABLE (QSYS2.DISPLAY_JOURNAL('QSYS','QAUDJRN',GENERATE_SYSLOG => 'RFC5424'))  AS X  WHERE  JOB_USER = 'F1BND' -- log_event LIKE '%192.9.207.200%'  

--AND JOB_NAME = 'WMS_EEIS4'



SELECT * FROM SMEDATFDA.TABEL00F WHERE TTELEM ='AMP-GIAC'

SELECT * FROM SMEDATFDA.MEDAV00F WHERE "MD£PGM"  ='M5FO01G'

SELECT * FROM QUSRSYS.QATOCSTART q 
