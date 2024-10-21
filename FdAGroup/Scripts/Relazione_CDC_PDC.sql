

SELECT TTELEM AS CNT, TTDESC AS DNT FROM SMEDATGRU5.TABELG0F WHERE TTSETT='C5B'

SELECT * FROM SMEDATBND.TABEL00F 

SELECT *  FROM SMEDATBND.C£CONR0F  WHERE C£TPRC='C5B' AND C£NUMP='X01'

SELECT C£CD01 AS CNT,  C£CDVA AS CDC FROM SMEDATBND.C£CONR0F 
--INNER JOIN SMEDATGRU5.TABELG0F ON TTSETT=C£TPRC
WHERE C£TPRC='C5B' AND C£NUMP='X01' 

WITH X AS (
SELECT TTELEM AS CDC,
TRIM(TTDESC||LEFT(TTLIBE, 70)) AS DSC, 
SUBSTR(TTLIBE, 71, 1) AS COM, 
SUBSTR(TTLIBE, 72, 1) AS NOC 
FROM SMEDATBND.TABEL00F 
WHERE TTSETT='XCE'
), 
Y AS (SELECT TTELEM AS CNT, TTDESC AS DNT FROM SMEDATGRU5.TABELG0F WHERE TTSETT='C5B')
SELECT C£CD01, Y.DNT, C£CDVA , X.DSC FROM SMEDATBND.C£CONR0F S LEFT JOIN Y ON Y.CNT=C£CD01 
LEFT JOIN  X ON C£CDVA=X.CDC
WHERE C£TPRC='C5B' AND C£NUMP='X01' 
 
