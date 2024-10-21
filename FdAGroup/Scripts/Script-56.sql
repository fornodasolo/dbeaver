
WITH F AS (
SELECT
DISTINCT T5USIN   
FROM SMEDATFDA.C5TREG0F INNER JOIN SMEDATFDA.C5RREG0F ON R5PROG=T5PROG INNER JOIN SMEDATGRU5.TABELG0F          
ON TTSETT='C5B' AND TTELEM=R5CONT WHERE T5AZIE IN 
('01', '02', '06', '07', '11') -- FDA
--('09')  -- LIZZI                   
--('10', '12')  -- SIPA
AND T5DREG BETWEEN 20240101 AND 20240331   -- primo   trim 
--AND T5DREG BETWEEN 20240401 AND 20240630   -- secondo trim
--AND T5DREG BETWEEN 20240701 AND 20240930   -- terzo   trim
--AND T5DREG BETWEEN 20241001 AND 20241231   -- quarto trim
--AND T5DREG BETWEEN 20240101 AND 20241231   -- Anno intero
AND T5FL01<='2' AND T5FL02='6' AND R5FL19='1'                                  
AND T5TPRO<>'**' AND (R5IMPO<>0 OR R5IMVA<>0) 
)
SELECT 'FDA', F.T5USIN Profilo, B.DESU01 Descrizione  
FROM F LEFT JOIN SMEDATGRU5.SPLUSR01 B ON F.T5USIN=B.USER01
 


WITH U AS (
SELECT
DISTINCT T5USIN   
FROM SMEDATLIZ.C5TREG0F INNER JOIN SMEDATLIZ.C5RREG0F ON R5PROG=T5PROG INNER JOIN SMEDATGRU5.TABELG0F          
ON TTSETT='C5B' AND TTELEM=R5CONT WHERE T5AZIE IN 
-- ('03', '04', '05', '08') 
---('01', '02', '06', '07') -- FDA
('09')  -- LIZZI                      
AND T5DREG BETWEEN 20210101 AND 20210930 
AND T5FL01<='2' AND T5FL02='6' AND R5FL19='1'                                  
AND T5TPRO<>'**' AND (R5IMPO<>0 OR R5IMVA<>0) 
)
SELECT U.T5USIN Profilo, B.DESU01 Descrizione  
FROM U LEFT JOIN SMEDATGRU5.SPLUSR01 B ON U.T5USIN=B.USER01