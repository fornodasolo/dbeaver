
SELECT 
E�NMNE AS "Vecchio Codice", 
E�CRAG AS "Codice", 
E�RAGS AS "Ragione Sociale",
E�STAT AS "Stato ente",  
E�INDI AS "Indirizzo",
E�CCOM AS "Comune",
E�LOCA AS "Localit�",
E�CAPA AS "Cap",
E�PROV AS "Provincia", 
(SELECT TTDESC FROM SMEDATBND.TABELV0F WHERE TTSETT='V�R' AND TTELEM=E�CREG) AS "Regione", 
E�CNAZ AS "Nazione", 
E�ZONA AS "Zona", 
--E�COD1 AS "Magazzino",  
(SELECT substr(ttuser, 26, 3) FROM smedatbnd.tabel00f WHERE ttsett='ZON' AND ttelem=e�zona) AS Magazzino, 
(SELECT TTDESC FROM SMEDATBND.C�CONR0F LEFT JOIN  SMEDATBND.TABEL00F ON  C�CDVA=TTELEM   
WHERE  C�TPRC='PVE' AND C�CD01=E�CRAG  AND C�NUMP='X06'  AND TTSETT='XB*06' ) AS "Canale di vendita fatturazione", 
(SELECT TTDESC FROM SMEDATBND.C�CONR0F LEFT JOIN  SMEDATBND.TABEL00F ON  C�CDVA=TTELEM   
WHERE  C�TPRC='PVE' AND C�CD01=E�CRAG  AND C�NUMP='X06'  AND TTSETT='XB*07' ) AS "Sottocanale di vendita fatturazione",  
(SELECT TTDESC FROM SMEDATBND.C�CONR0F LEFT JOIN  SMEDATBND.TABEL00F ON  C�CDVA=TTELEM   
WHERE  C�TPRC='PVE' AND C�CD01=E�CRAG  AND C�NUMP='X06'  AND TTSETT='XB*08' ) AS "Area Manager",   
(SELECT TTDESC FROM SMEDATBND.C�CONR0F LEFT JOIN  SMEDATBND.TABEL00F ON  C�CDVA=TTELEM   
WHERE  C�TPRC='PVE' AND C�CD01=E�CRAG  AND C�NUMP='X06'  AND TTSETT='XB*09' ) AS "District Manager",
(SELECT TTDESC FROM SMEDATBND.C�CONR0F LEFT JOIN  SMEDATBND.TABEL00F ON  C�CDVA=TTELEM   
WHERE  C�TPRC='PVE' AND C�CD01=E�CRAG  AND C�NUMP='X06'  AND TTSETT='XB*10' ) AS "Ispettore",
(SELECT TTDESC FROM SMEDATBND.C�CONR0F LEFT JOIN  SMEDATBND.TABEL00F ON  C�CDVA=TTELEM   
WHERE  C�TPRC='PVE' AND C�CD01=E�CRAG  AND C�NUMP='X06'  AND TTSETT='XB*11' ) AS "Promoter"  
FROM SMEDATBND.BRENTI0F WHERE E�TRAG='PVE' AND E�COD1<>''  OR E�ZONA<>''



SELECT ttsett,ttelem, substr(ttuser, 26, 3) FROM smedatbnd.tabel00f WHERE ttsett='ZON' 

SELECT * FROM SMEDATBND.C�CONR0F WHERE C�TPRC='PVE' AND C�NUMP='X66'   -- organizzazione di vendita 

SELECT * FROM SMEDATBND.C�CONR0F WHERE C�TPRC='PVE' AND C�NUMP='XA1'   -- ID cliente capo organizzazione di vendita  

SELECT DISTINCT C�CDVA FROM SMEDATBND.C�CONR0F WHERE C�TPRC='PVE' AND C�NUMP='XA1'  

SELECT * FROM SMEDATBND.BRENTI0F WHERE E�NMNE IN 
(
SELECT DISTINCT C�CDVA FROM SMEDATBND.C�CONR0F WHERE C�TPRC='PVE' AND C�NUMP='XA1'  
) 
AND E�TRAG='CLI'




