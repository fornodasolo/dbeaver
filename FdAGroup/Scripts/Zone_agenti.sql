
SELECT
       GREATEST((COALESCE(AGE.C£DTAG,AGE.C£DTIS) * 1000000) + COALESCE(AGE.C£ORAG,AGE.C£ORIN, 0), (COALESCE(AGE.C£DTIN,0)*1000000)+HOUR(CURRENT_TIME)*10000+MINUTE(CURRENT_TIME)*100+SECOND(CURRENT_TIME)) AS TS1,
       GREATEST((COALESCE(TXZA.C£DTAG,TXZA.C£DTIS) * 1000000) + COALESCE(TXZA.C£ORAG,TXZA.C£ORIN, 0), (COALESCE(TXZA.C£DTIN,0)*1000000)+HOUR(CURRENT_TIME)*10000+MINUTE(CURRENT_TIME)*100+SECOND(CURRENT_TIME)) AS TS2,
       GREATEST((COALESCE(ISP.C£DTAG,ISP.C£DTIS) * 1000000) + COALESCE(ISP.C£ORAG,ISP.C£ORIN, 0), (COALESCE(ISP.C£DTIN,0)*1000000)+HOUR(CURRENT_TIME)*10000+MINUTE(CURRENT_TIME)*100+SECOND(CURRENT_TIME)) AS TS3,
       GREATEST((ZON.TTDTIN * 1000000) + ZON.TTORIN , (ZON.TTDTAG * 1000000) + ZON.TTORAG) AS TS4,
       GREATEST((XZI.TTDTIN * 1000000) + XZI.TTORIN , (XZI.TTDTAG * 1000000) + XZI.TTORAG) AS TS5,
       GREATEST((XZA.TTDTIN * 1000000) + XZA.TTORIN , (XZA.TTDTAG * 1000000) + XZA.TTORAG) AS TS6,
       GREATEST((XCA.TTDTIN * 1000000) + XCA.TTORIN , (XCA.TTDTAG * 1000000) + XCA.TTORAG) AS TS7,
       0 AS ZONID,
       AGE.C£CD01 AS ZONCODE,
             ZON.TTDESC AS ZONDESC,
             substring(ZON.TTUSER,26,2) AS ZONPLANT,
             substring(ZON.TTUSER,14,1) AS ZONISUPDEN,
             substring(ZON.TTUSER,15,1) AS ZONISCONEN,
             CASE
                 WHEN substring(ZON.TTUSER,22,1)='1' THEN '1'
                 ELSE '0'
             END AS ZONISNOGEO,
             substring(ZON.TTUSER,17,3) AS ZONTYPE,
             '' AS ZONLIST,
             substring(ZON.TTUSER,31,1) AS ZONEABITV,
             substring(ZON.TTUSER,35,2) AS ZONTVMAG,
             substring(ZON.TTUSER,32,2) AS ZONTVLIST,
             CASE
                 WHEN substring(ZON.TTUSER,31,1)='1' THEN CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT('OA',substring(ZON.TTUSER,38,3)),'OA'),substring(ZON.TTUSER,41,3)),'  '),substring(ZON.TTUSER,44,3)),'  '),substring(ZON.TTUSER,47,3)),'  '),substring(ZON.TTUSER,50,3))
                 ELSE ''
             END AS ZONMODD,
             '' AS ZONEFLD3,
             '0' AS ZONISDELET,
             '1' AS ZONISFULL,
             substring(ZON.TTUSER,56,3) AS VETTORE,
             AGE.C£CDVA AS AGECODE,
                   XZA.TTELEM AS CODICEAREA,
                   XCA.TTELEM AS CODICECAPOAREA,
                   XZI.TTELEM AS CODICEDISTRETTO,
                   ISP.C£CDVA AS CODICECAPODISTRETTO
FROM SMEDATBND.C£CONR0F AGE
LEFT OUTER JOIN SMEDATBND.TABEL00F ZON ON AGE.C£TPRC = 'ZON' AND AGE.C£NUMP = 'ZAG' AND AGE.C£CD01=ZON.TTELEM
LEFT OUTER JOIN SMEDATBND.TABEL00F XZI ON XZI.TTSETT='XZI'AND XZI.TTELEM=LEFT(ZON.TTUSER, 3)
LEFT JOIN SMEDATBND.TABEL00F XZA ON XZA.TTSETT='XZA' AND XZA.TTELEM=left(trim(XZI.TTLIBE),3)
LEFT JOIN SMEDATBND.C£CONR0F TXZA ON TXZA.C£TPRC='XZA' AND TXZA.C£CD01=XZA.TTELEM
LEFT JOIN SMEDATBND.TABEL00F XCA ON XCA.TTSETT='XCA' AND TXZA.C£CDVA=XCA.TTELEM
LEFT OUTER JOIN SMEDATBND.C£CONR0F ISP ON ISP.C£TPRC='XZI' AND ISP.C£NUMP='XZA' AND TRIM(ISP.C£CD01)=TRIM(XZI.TTELEM)
WHERE ZON.TTSETT='ZON'
AND coalesce(AGE.C£DTIN,0) <= VARCHAR_FORMAT(CURRENT_DATE,'YYYYMMDD') AND coalesce(case when AGE.C£DTFN = 0 then 99999999 else AGE.C£DTFN end,99999999) >= VARCHAR_FORMAT(CURRENT_DATE,'YYYYMMDD')
AND coalesce(TXZA.C£DTIN,0) <= VARCHAR_FORMAT(CURRENT_DATE,'YYYYMMDD') AND coalesce(case when TXZA.C£DTFN = 0 then 99999999 else TXZA.C£DTFN end,99999999) >= VARCHAR_FORMAT(CURRENT_DATE,'YYYYMMDD')
AND coalesce(ISP.C£DTIN,0) <= VARCHAR_FORMAT(CURRENT_DATE,'YYYYMMDD') AND coalesce(case when ISP.C£DTFN = 0 then 99999999 else ISP.C£DTFN end,99999999) >= VARCHAR_FORMAT(CURRENT_DATE,'YYYYMMDD')


SELECT * FROM SMEDATBND.C£CONR0F

SELECT * FROM smetstbnd.brenti0f WHERE e§trag='PVE' 
AND e§crag IN (
SELECT t§cods FROM smetstbnd.v5tdoc0f 
WHERE t§cod1='F3DET' 
AND T§CODF IN (
SELECT C£cd01 FROM smetstbnd.c£conr0f WHERE c£nump='X79' AND c£cdva='1'
))


SELECT * FROM smetstbnd.brenti0f 
UPDATE smetstbnd.brenti0f 
SET 
WHERE e§trag='PVE' AND e§crag IN ('0226292', '0227245', '0239529', '0225052', '0217188', '0210487')



CREATE TABLE CED.RIFATT0009 (
	SIP_016_CUSTACCOUNT char(20)  DEFAULT ' ' NOT NULL,
	SIP_016_CUSTSALESDATE CHAR(10) DEFAULT ' '  NOT NULL,
	SIP_016_CUSTSALESID char(10) DEFAULT ' '  NOT NULL,
	SIP_016_DATE CHAR(10) DEFAULT ' ' NOT NULL,
	SIP_016_DEALERID char(20) DEFAULT ' ' NOT NULL,
	SIP_016_DEALERPACKINGSLIPID char(50) DEFAULT ' '   NOT NULL,
	SIP_016_ITEMID char(20) DEFAULT ' '  NOT NULL,
	SIP_016_LINENUM DECIMAL(4,0) DEFAULT 0 NOT NULL,
	SIP_016_QTY DECIMAL(21,6) DEFAULT 0 NOT NULL,
	SIP_016_DLVREASON char(10) DEFAULT ' '  NOT NULL,
	SIP_016_YEAR DECIMAL(4,0) DEFAULT 0 NOT NULL,
	SIP_016_DLVREASONFREE CHAR(1) DEFAULT ' ' NOT NULL,
	DT_SYS CHAR(10) DEFAULT ' ' NOT NULL,
	COMPANY char(50) DEFAULT ' ' NOT   NULL
)

DROP TABLE CED.RIFATT0009 






