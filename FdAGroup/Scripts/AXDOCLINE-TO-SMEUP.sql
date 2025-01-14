
-- ##################################################################################
--  
-- Script utilizzato per importare Ordini dall'interfaccia di Tiziano unico file
-- EDO_ESTR_ORDINATO_TEST.
-- AXIB.dbo.EDO_ESTR_ORDINATO_TEST definition
-- Drop table
-- DROP TABLE AXIB.dbo.EDO_ESTR_ORDINATO_TEST;
--CREATE TABLE AXIB.dbo.EDO_ESTR_ORDINATO_TEST (
--	CUSTACCOUNT nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
--	SALESID nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
--	DELIVERYDATE datetime NULL,
--	CustomerRef nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
--	ITEMID nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
--	NAME nvarchar(500) COLLATE Latin1_General_CI_AS NULL,
--	QTYORDERED numeric(18,2) NULL,
--	LINEAMOUNT numeric(18,2) NULL,
--	TIPO_ORDINE nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
--	LINENUM numeric(18,2) NULL,
--	CAUSALE nvarchar(50) COLLATE Latin1_General_CI_AS NULL
--);
-- IN AS400 VIENE CONVERTITA COME SEGUE
--DROP TABLE CED.AXDOCLINE
--CREATE TABLE CED.AXDOCLINE (
--	CUSTACCOUNT nvarchar(50) ,
--	SALESID nvarchar(50) ,
--	DELIVERYDATE timestamp, 
--	CustomerRef nvarchar(100) ,
--	ITEMID nvarchar(50) ,
--	NAME nvarchar(500) ,
--	QTYORDERED numeric(18,2) ,
--	LINEAMOUNT numeric(18,2) ,
--	TIPO_ORDINE nvarchar(50) ,
--	LINENUM numeric(18,2) ,
--	CAUSALE nvarchar(50) 
--);
--COMMIT;
-- Il dato viene caricato nella tabella AXDOCLINE in CED via insert SQL e da questa
-- tradotto in righe IDOCLINE e testate IDOCHEADER per l'interfaccia in smeup 
-- N.B. vengono usate copie delle tabelle usate in NBFDATXXXX
-- ##################################################################################

-- fase 2) inizia dopo aver popolato la tabella CED.AXDOCLINE
-- scan tabella per vedere quanti enti sono movimentati 
-- nel ns caso 3997 PVE
SELECT    
DISTINCT TRIM(CUSTACCOUNT), 
TRIM(REPLACE(REPLACE(LEFT(TO_CHAR(DELIVERYDATE), 10),'-', ''), '.', '')) AS DAYCONS
FROM CED.AXDOCLINE  

-- Effettuo prima normalizzazione delle righe secondo formato IDOCLINE
-- generando uncampo univoco DCLORDCODE come cocat dei campi in AXDOCLINE
-- CUSTACCOUNT E SALESID(Ordine generato in AX)
-- in generale mantengo questa relazione tra AXDOCLINE
-- IDOCLINE              AXDOCLINE
-- DCLID                 viene valorizzato solo dopo aver acaricato gli altri dati
-- DCLORDCODE            LEFT(TRIM(CUSTACCOUNT)||TRIM(SALESID)||TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')), 21)
-- DCLLINENRO            SUBSTR(DIGITS(LINENUM), 13, 4)
-- DCLLINETYP            (CASE WHEN TIPO_ORDINE IN ('AB', 'BE', 'BZ', 'LIZZI_LZ', 'RZ') THEN '002' ELSE '001' END),
-- DCLTIMESTP            TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')) [DATA CONSEGNA] 
-- DCLIDMATRI            CUSTACCOUNT='0'||substr(TRIM(CUSTACCOUNT), 2, 9) (CODICE PVE IN SMEUP)
-- DCLQRCODE             CUSTACCOUNT  ( LO SALVO QUI PER CREARE LE TESTATE POI)
-- DCLPRDCODE            ITEMID
-- DCLQTA                QTYORDERED
-- DCHEXTORD  ,  --Numero ordine esterno
-- DCHEXTDAT  ,  --Data ordine esterno  
-- DCLNTRIG              LINEAMOUNT
-- DCLFLD001             TIPO_ORDINE 
-- DCLFLD002             NAME [SALVO QUI LA DESCRIZIONE ARTICOLO]


-- VERIFICA UNIVOCITA' NUMERO RIGA
SELECT SUBSTR(DIGITS(LINENUM), 13, 4) AS INTFRACT, (LINENUM - FLOOR(LINENUM)) AS FRACT FROM CED.AXDOCLINE --WHERE (LINENUM - FLOOR(LINENUM)) >0


DELETE FROM CED.IDOCLINE

DELETE FROM CED.IDOCLINEWK

COMMIT

INSERT INTO CED.IDOCLINEWK ( 
DCLID      , 
DCLORDCODE ,  
DCLLINENRO ,  
DCLLINETYP ,  
DCLTIMESTP ,  
DCLIDMATRI ,  
DCLQRCODE  ,  
DCLPRDCODE ,  
DCLQTA     ,
DCLNTRIG   ,  
DCLFLD1  ,  
DCLFLD2,
DCLFLD001, --DCHEXTORD  ,  --Numero ordine esterno
DCLFLD002 --DCHEXTDAT  ,  --Data ordine esterno  
)
SELECT 
RRN(A), 
--LEFT(TRIM(CUSTACCOUNT)||TRIM(SALESID)||TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')), 21),
TRIM(CUSTACCOUNT)||TRIM(SALESID),
--CAST(LINENUM AS DEC(4, 0)),-- SUBSTR(DIGITS(LINENUM), 13, 4),
INT(LINENUM), 
(CASE WHEN TIPO_ORDINE IN ('AB', 'BE', 'BZ', 'LIZZI_LZ', 'RZ') THEN '002' ELSE '001' END),
TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')),
'0'||SUBSTR(TRIM(CUSTACCOUNT), 2, 9),
LEFT(CUSTACCOUNT, 15),
LEFT(ITEMID, 15),
QTYORDERED,
LINEAMOUNT,
TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')), 
LEFT(NAME, 15), 
LEFT(SALESID, 15)  ,  --Numero ordine esterno
TIPO_ORDINE
FROM CED.AXDOCLINE A 
ORDER BY TRIM(CUSTACCOUNT)||TRIM(SALESID), LINENUM 

COMMIT

SELECT * FROM CED.IDOCLINEWK

-- CREATA LA TABELLA IDOCLINE DEVO NORMARE IL CAMPO DCLID UNIFORMANDOLO PER ORDINE 
-- UTILIZZANDO UNA TABELLE DI APPOGGIO DOVE ESTRAGGO L'IDRECORD PER OGNI ORDINE
-- N.B. DEVO UTILIZZARE ANCHE UNA VERSIONE SENZA KEY DI IDOCLINE 

-- CREO TABELLA DI APPOGGIO PER ESTRARRE GLI ID UNIVOCI PER CLIENTE|ORDINE
DROP TABLE  QTEMP.ORDERID

CREATE TABLE QTEMP.ORDERID (NREC DEC(10), IDORD CHAR(30), KORD DEC(10))

INSERT INTO QTEMP.ORDERID (NREC, IDORD, KORD)
WITH 
X AS (
SELECT B.*, ROW_NUMBER() OVER (PARTITION  BY DCLORDCODE ORDER BY DCLORDCODE ) AS RN FROM CED.IDOCLINEWK AS B
), Z AS ( 
SELECT X.* FROM X WHERE RN=1 
)
SELECT RRN(A),  DCLORDCODE, DCLID  FROM  Z A

COMMIT

SELECT * FROM QTEMP.ORDERID 

SELECT * FROM CED.IDOCLINEWK 

COMMIT

UPDATE CED.IDOCLINEWK X 
SET X.DCLID = (SELECT Y.KORD FROM QTEMP.ORDERID Y WHERE  X.DCLORDCODE = Y.IDORD )

SELECT DISTINCT DCLID FROM CED.IDOCLINEWK i 


INSERT INTO CED.IDOCLINE SELECT * FROM CED.IDOCLINEWK

SELECT * FROM CED.IDOCLINEWK

--CREATE TABLE CED.KRNDSTR ( KEYSTR20 CHAR(20)) 
--SELECT * FROM NBFDAT.XNBILN0F XF 
-- WITH X AS  (
--SELECT TIPO_ORDINE, COUNT(TIPO_ORDINE ) AS NTORD FROM CED.AXDOCLINE GROUP BY TIPO_ORDINE)
--SELECT NTORD, TTELEM,TTDESC FROM X LEFT JOIN SMEDATBND.TABEL00F ON TTELEM=X.TIPO_ORDINE 
--WHERE TTSETT='XTO' AND TTELEM IN (SELECT TIPO_ORDINE FROM X)




INSERT INTO  CED.IDOCHEADER (DCHID, DCHORDCODE, DCHDOCTYPE, DCHMODTYPE, DCHCLITYPE )
SELECT 
KORD, IDORD, 'OA1', '001', 'PVE' FROM QTEMP.ORDERID --, TRIM(DCLIDMATRI), DCLTIMESTP, DCLTIMSTP FROM 


UPDATE CED.IDOCHEADER A 
SET A.DCHPVECODE = (
SELECT DISTINCT B.DCLIDMATRI FROM CED.IDOCLINE B WHERE B.DCLORDCODE=A.DCHORDCODE 
) 

UPDATE CED.IDOCHEADER A 
SET A.DCHEXTORD = (
SELECT DISTINCT B.DCLFLD001 FROM CED.IDOCLINE B WHERE B.DCLORDCODE=A.DCHORDCODE 
) 

UPDATE CED.IDOCHEADER A 
SET A.DCHEXTDAT = (
SELECT DISTINCT LEFT(B.DCLFLD1, 8) FROM CED.IDOCLINE B WHERE B.DCLORDCODE=A.DCHORDCODE 
) 

UPDATE CED.IDOCHEADER A 
SET A.DCHNOTE= (
SELECT DISTINCT DCLFLD002 FROM CED.IDOCLINE B WHERE B.DCLORDCODE=A.DCHORDCODE 
) 


INSERT INTO NBFDATSTBN.IDOCLINE SELECT * FROM CED.IDOCLINE 

INSERT INTO NBFDATSTBN.IDOCHEADER SELECT * FROM CED.IDOCHEADER

COMMIT



UPDATE CED.IDOCHEADER A
--SET A.DCHPLTCODE= (SELECT E§COD1 FROM SMETSTBND.BRENTI0F WHERE E§TRAG='PVE' AND E§CRAG=A.DCHPVECODE)
SET A.DCHZONCODE= (SELECT E§ZONA FROM SMETSTBND.BRENTI0F WHERE E§TRAG='PVE' AND E§CRAG=A.DCHPVECODE)

COMMIT

SELECT DISTINCT DCHPVECODE FROM CED.IDOCHEADER 
		
SELECT E§ZONA, E§COD1, E§COD2, E§COD3, E§COD4 FROM SMETSTBND.BRENTI0F  
WHERE E§TRAG='PVE' AND E§CRAG IN (SELECT DCHPVECODE FROM CED.IDOCHEADER)


INSERT INTO NBFDATSTBN.IDOCLINE 
SELECT * FROM CED.IDOCLINE 
WHERE dclordcode IN (
SELECT  dchordcode FROM ced.idocheader WHERE DCHMODTYPE='051'
)

INSERT INTO NBFDATSTBN.IDOCHEADER 
SELECT * FROM CED.IDOCHEADER 
WHERE DCHMODTYPE='051'

COMMIT 

SELECT * FROM SMETSTBND.V5TDOC0F WHERE T§DTIN >=20230220


SELECT E§CCON FROM SMETSTBND.BRENTI0F 
WHERE E§TRAG='PVE' AND E§CRAG IN (SELECT DISTINCT DCHPVECODE FROM CED.IDOCHEADER)

UPDATE CED.IDOCHEADER A 
SET A.DCHCLICODE = (SELECT B.E§CCON FROM SMETSTBND.BRENTI0F B WHERE B.E§TRAG='PVE' AND B.E§CRAG= A.DCHPVECODE -- IN (SELECT DISTINCT DCHPVECODE FROM CED.IDOCHEADER)
)

COMMIT

UPDATE CED.IDOCHEADER 
SET DCHMODTYPE='051' 
WHERE DCHCLICODE IN (
SELECT E§CRAG FROM SMETSTBND.BRENTI0F 
WHERE E§TRAG='CLI' AND E§CRAG IN (SELECT DISTINCT DCHCLICODE FROM CED.IDOCHEADER) 
AND E§CNAZ<>'IT'
)


COMMIT

SELECT * FROM SMETSTBND.V5TDOC0F WHERE T§DTIN >=20230220 AND T§USIN='SMEUPBND'

DELETE  FROM SMETSTBND.V5RDOC0F 
WHERE R§DTIN>=20230220 AND R§USIN='SMEUPBND'


DELETE  FROM SMETSTBND.V5TDOC0F 
WHERE T§DTIN>=20230220 AND T§USIN='SMEUPBND'

COMMIT



SELECT   *
--DISTINCT h§cdcl 
FROM NBFDATSTBN.idocheader WHERE DCHORDCODE NOT IN (SELECT DISTINCT dclordcode FROM nbfdatstbn.idocline) 

SELECT * FROM nbfdatstbn.xnbiln0f 

UPDATE nbfdatstbn.xnbiln0f SET l§fl01='' WHERE l§fl01='4'

UPDATE nbfdatstbn.xnbihe0f SET h§fl01='' WHERE h§fl01='4'

COMMIT 




SELECT  --H§HEAK, 
H§CDMG, H§ZONA, H§CODF,
(SELECT E§RAGS FROM SMETSTBND.BRENTI0F WHERE E§TRAG='CLI' AND E§CRAG=H§CODF) AS RAGSOC, 
H§CDCL, 
(SELECT E§NMNE FROM SMETSTBND.BRENTI0F WHERE E§TRAG='PVE' AND E§CRAG=H§CDCL) AS PVESPE,
COUNT(H§NDOC) AS NRORD FROM NBFDATSTBN.XNBIHE0F 
WHERE H§NDOC <>'' 
GROUP BY --H§HEAK, 
H§CDMG, H§ZONA, H§CODF, H§CDCL


SELECT  --*
T§CD09 AS TIPO_ORDINE,
T§ORAQ AS AXORD, 
T§DOAQ AS AXDTCONS,
T§NDOC,T§CODF, 
(SELECT E§RAGS FROM SMEDATREP.BRENTI0F WHERE T§CODF=E§CRAG AND E§TRAG='CLI')  AS RAGSOCCLI, 
(SELECT  E§CNAZ FROM SMEDATREP.BRENTI0F WHERE T§CODF=E§CRAG AND E§TRAG='CLI')  AS NAZI,
T§CODS, 
(SELECT E§NMNE FROM SMEDATREP.BRENTI0F WHERE T§CODS=E§CRAG AND E§TRAG='PVE')  AS AXCDPVE,
T§CORD
FROM SMEDATREP.V5TDOC0F WHERE T§DTIN >=20230220 AND T§USIN='SMRC' AND T§NBOL='' 

SELECT  *
--DISTINCT T§NDOC,T§CODF, T§CODS   
FROM SMEDATFDA.V5TDOC0F WHERE T§DTIN >=20230220 --AND T§USIN='SMEUPBND' 


INSERT INTO nbfdatstbn.idocheader 
SELECT * FROM ced.IDOCHEADER i WHERE rrn(i) BETWEEN 11 AND 5000 -- <= 10 

commit

INSERT INTO nbfdatstbn.idocline 
(SELECT * FROM ced.idocline WHERE DCLORDCODE IN (SELECT dchordcode FROM nbfdatstbn.idocheader))

DELETE FROM NBFDATSTBN.IDOCline 
WHERE DCLORDCODE NOT IN (SELECT dchordcode FROM NBFDATSTBN.idocheader) 


SELECT * FROM smeDATREP.v5tdoc0f 
WHERE T§DTIN >=20230222 AND T§USIN='SMRC' AND T§NBOL='' --<>'' 


SELECT

SELECT DCHSHDATE, '20'||DCHEXTDAT FROM ced.idocheader  

UPDATE  CED.IDOCLINE
SET DCLLINENRO=SUBSTR(DIGITS(DCLLINENRO), 29, 4)



UPDATE CED.IDOCHEADER 
SET DCHPLTCODE='F1'


UPDATE SMEDATREP.V5TDOC0F A
SET A.T§CD09=(SELECT TRIM(B.H§NOTA) FROM NBFDATSTBN.XNBIHE0F B WHERE B.H§ORAQ=A.T§ORAQ) 
WHERE A.T§ORAQ IN (SELECT H§ORAQ FROM NBFDATSTBN.XNBIHE0F) 

COMMIT

SELECT --DIGITS(DCLLINENRO) FROM CED.IDOCLINE 
SUBSTR(DIGITS(DCLLINENRO), 29, 4) FROM CED.IDOCLINE 

SELECT * FROM SMETSTBND.V5TDOC0F WHERE 
T§TDOC='OA' AND T§NDOC IN 
(SELECT T§NDOC FROM SMEDATREP.V5TDOC0F 
WHERE T§DTIN >=20230222 AND T§USIN='SMRC' AND T§NBOL=''
)

SELECT * FROM CED.IDOCHEADER i 


SELECT * FROM SMEDATREP.V5TDOC0F WHERE 
 T§DTIN >=20230222 AND T§USIN='SMRC' AND T§NBOL=''
 
SELECT * FROM SMEDATREP.V5RDOC0F WHERE 
 R§DTIN >=20230222 AND R§USIN='SMRC' AND T§NBOL=''

 
INSERT INTO  SMETSTBND.V5TDOC0F 
(SELECT * FROM SMEDATREP.V5TDOC0F WHERE 
 T§DTIN >=20230222 AND T§USIN='SMRC' AND T§NBOL='' 
 AND T§NDOC>'230000042')
 
INSERT INTO  SMETSTBND.V5RDOC0F 
(SELECT * FROM SMEDATREP.V5RDOC0F WHERE 
 R§DTIN >=20230222 AND R§USIN='SMRC'  
 AND R§NDOC>'230000042') 
 COMMIT
 