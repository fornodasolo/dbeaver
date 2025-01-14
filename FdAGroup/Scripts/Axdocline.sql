
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
--	LINENUM numeric(18,2) NULL
--);
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
-- DCLNTRIG              LINEAMOUNT
-- DCLFLD001             TIPO_ORDINE 
-- DCLFLD002             NAME [SALVO QUI LA DESCRIZIONE ARTICOLO]


DELETE FROM CED.IDOCLINE

DELETE FROM CED.IDOCLINEWK

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
DCLFLD001  ,  
DCLFLD002    
)
SELECT 
RRN(A), 
LEFT(TRIM(CUSTACCOUNT)||TRIM(SALESID)||TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')), 21),
SUBSTR(DIGITS(LINENUM), 13, 4),
(CASE WHEN TIPO_ORDINE IN ('AB', 'BE', 'BZ', 'LIZZI_LZ', 'RZ') THEN '002' ELSE '001' END),
TRIM(REPLACE(SUBSTR(TO_CHAR(DATE(DELIVERYDATE)), 3, 8), '-', '')),
'0'||SUBSTR(TRIM(CUSTACCOUNT), 2, 9),
LEFT(CUSTACCOUNT, 15),
LEFT(ITEMID, 15),
QTYORDERED,
LINEAMOUNT,
TIPO_ORDINE,  
NAME
FROM CED.AXDOCLINE A

COMMIT

SELECT * FROM CED.IDOCLINEWK

-- CREATA LA TABELLA IDOCLINE DEVO NORMARE IL CAMPO DCLID UNIFORMANDOLO PER ORDINE 
-- UTILIZZANDO UNA TABELLE DI APPOGGIO DOVE ESTRAGGO L'IDRECORD PER OGNI ORDINE
-- N.B. DEVO UTILIZZARE ANCHE UNA VERSIONE SENZA KEY DI IDOCLINE 

DROP TABLE  QTEMP.ORDERID

CREATE TABLE QTEMP.ORDERID (NREC DEC(10), IDORD CHAR(30), KORD DEC(10))

INSERT INTO QTEMP.ORDERID 
SELECT RRN(A), DCLORDCODE, 
MIN(DCLID) OVER(PARTITION BY DCLORDCODE) AS ORDID 
   FROM CED.IDOCLINEWK  A
ORDER BY ORDID

COMMIT

SELECT * FROM QTEMP.ORDERID

COMMIT

UPDATE CED.IDOCLINEWK 
SET DCLPLIST = (SELECT KORD FROM CED.ORDERID WHERE NREC=DCLID)


UPDATE CED.IDOCLINE SET DCLID = DCLPLIST 


INSERT INTO CED.IDOCLINE SELECT * FROM CED.IDOCLINEWK

SELECT * FROM CED.IDOCLINEWK


CREATE TABLE CED.KRNDSTR ( KEYSTR20 CHAR(20)) 

SELECT * FROM NBFDAT.XNBILN0F XF 

WITH X AS  (
SELECT TIPO_ORDINE, COUNT(TIPO_ORDINE ) AS NTORD FROM CED.AXDOCLINE GROUP BY TIPO_ORDINE
) 
SELECT NTORD, TTELEM,TTDESC FROM X LEFT JOIN SMEDATBND.TABEL00F ON TTELEM=X.TIPO_ORDINE 
WHERE TTSETT='XTO' AND TTELEM IN (SELECT TIPO_ORDINE FROM X)




SELECT * FROM CED.AXDOCLINE

   
SELECT * FROM CED.ORDERID

SELECT * FROM CED.IDOCLINE
   
SELECT * FROM QTEMP.ORDERID  PARTITION(IDORD)

MERGE INTO CED.IDOCLINE
USING QTEMP.ORDERID 
ON (DCLORDCODE = IDORD)
WHEN MATCHED THEN
UPDATE SET DCLID=KORD  

SELECT A.KORD,B.* FROM QTEMP.ORDERID A INNER JOIN CED.IDOCLINE B 
ON A.IDORD=B.DCLORDCODE 



