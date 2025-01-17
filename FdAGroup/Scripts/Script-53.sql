
-- ESTRAZIONE ELENCO DEI CLIENTI BLOCCATI IN SEGUITO AI NUOVI VALORI SOGLIA IMPOSTATI
-- L'ELENCO RIPORTA L'ENTE CLI CON RELATIVO STATO, L'ENTE PVE DI RIFERIMENTO, CON STATO, ZONA E MAGAZZINO DI SERVIZIO  
WITH M AS (
SELECT E§CRAG AS CDPVE,
E§STAT AS STPVE,
E§NMNE AS SIGPVE,
E§RAGS AS RAGPVE, 
E§COD1 AS MAGPVE,
E§ZONA AS ZONPVE,
(SELECT SUBSTRING(TTUSER, 11, 3)  FROM SMEDATBND.TABEL00F WHERE TTSETT='ZON' AND TTELEM=E§ZONA) AS GGZONBLOC,
(SELECT P£CDVA FROM SMEDATBND.C£ESO00F WHERE P£NUMP='D15' AND P£CD01=E§CRAG) AS INSPVE
FROM SMEDATBND.BRENTI0F 
WHERE E§TRAG='PVE' 
AND E§DINV <  VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD') 
AND E§DFNV >= VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD')
), 
 N AS ( SELECT  
(
(SELECT COALESCE(SUM(S5IMPO-S5IMPA),0) FROM SMEDATBND.C5RATE3L 
WHERE S5TPOG = 'CNCLI' AND S5AZIE='10' AND S5CDOG=E§CRAG AND S5DAAV = 'D' AND S5SCAD <= VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD')) 
-
(SELECT COALESCE(SUM(S5IMPO-S5IMPA),0) FROM SMEDATBND.C5RATE3L 
WHERE S5TPOG = 'CNCLI' AND S5AZIE='10' AND S5CDOG=E§CRAG AND S5DAAV = 'A' AND S5SCAD <= VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD'))
) AS SCADUTO,
E§CRAG AS CDCLI, E§STAT AS STATOCLI, E§RAGS AS RAGSCLI,
 E§NUM3 AS GGCLIBLOC,  
(SELECT C£CDVA FROM SMEDATBND.C£CONR0F WHERE C£TPRC='CLI' AND C£NUMP='X14' AND C£CD01=E§CRAG) AS GRPCLI,
E§CCRR AS PVERIF, M.*
FROM SMEDATBND.BRENTI0F INNER JOIN M ON E§CCRR=CDPVE
WHERE E§TRAG='CLI'  
AND E§DINV <  VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD')  
AND E§DFNV >= VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD')
ORDER BY MAGPVE,ZONPVE 
) 
SELECT * FROM N WHERE SCADUTO<>0