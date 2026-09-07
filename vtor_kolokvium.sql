Elektrichno_Vozilo (shifra, procent_baterija, statuss, GPS)
Velosiped (shifra*, broj_servisi)
Trotinet (shifra*, tip_gumi)
Korisnik (K#, ime, prezime, email, lozinka, datum_registracija, parichnik, kk_datum, kk_broj, kk_ccv)
Firma (F#, ime, markica, adresa, tip, kapital, tip_pretplata)
Fizicko_Iznajmuvanje (K#*, shifra*, datumvreme_pochetok, datumvreme_kraj, minuti, kilometri, tip_naplata, statuss, slika)
Iznajmuvanje_preku_Firma (F#, shifra*, datumvreme_pochetok, datumvreme_kraj, minuti, kilometri, tip_naplata, statuss, slika)
Povrzuvanje (K#*, F#*, datum, statuss)

-- trotineti 2013 iznajmuvanje (firma, fizicko lice)
-- kje probame fizicko lice join trotinet shifra 1 = shifra 2 
CREATE VIEW FI_Trotineti (shifra, datum_iznajmuvanje) AS (
    SELECT T.shifra, FI.datum_iznajmuvanje
    FROM Fizicko_Iznajmuvanje FI 
    JOIN Trotinet T
    ON T.shifra = FI.shifra 
);
SELECT T.*
FROM Trotinet T, Iznajmuvanje_preku_Firma IPF, FI_Trotineti FIT
WHERE ( T.shifra = FIT.shifra AND  FIT.datum_iznajmuvanje = 'xx.04.2013' )
    OR ( T.shifra = IPF.shifra AND IPF.datum_iznajmuvanje = 'xx.04.2013' )

-- korisnici, vkupno vozenje 2h+ 
SELECT K.K#, SUM(FI.minuti) AS minuti 
FROM Korisnik K, Fizicko_Iznajmuvanje FI
WHERE K.K# = FI.K# 
GROUP BY K.K# 
HAVING minuti > 120 

-- uredi koi ne bile iznajmeni od 2023 i navaka
SELECT EV.*
FROM Elektrichno_Vozilo EV
WHERE NOT EXISTS (
    SELECT  FI.*
    FROM  Fizicko_Iznajmuvanje FI 
    WHERE FI.datum > 'xx.xx.2023' AND FI.datum < CURRENT_DATE AND FI.shifra=EV.shifra
) AND NOT EXISTS ( 
    SELECT IPF.*
    FROM Iznajmuvanje_preku_Firma IPF
     WHERE IPF.datum > 'xx.xx.2023' AND IPF.datum < CURRENT_DATE AND IPF.shifra=EV.shifra
)

-- trotineti shto imaat izvozeno nad 500 minuti ili 100 km 
SELECT T.shifra, SUM(FF.minuti) AS minuti, SUM(FF.kilometri) AS kilometri
FROM Elektrichno_Vozilo AS EV, Trotinet AS T,
    (SELECT * FROM Fizicko_Iznajmuvanje UNION ALL SELECT * FROM Iznajmuvanje_preku_Firma) AS FF
WHERE EV.shifra = FF.shifra AND EV.shifra = T.shifra 
GROUP BY T.shifra 
HAVING minuti > 500 OR kilometri > 100 

--kolku vkupno ima plateno sekoj korisnik
-- 9 denari od minuta + 10 denari za iznajmuvanje 
SELECT K.K#, SUM(FF.minuti)*9+10 
FROM  Korisnik K, 
    (SELECT * FROM Fizicko_Iznajmuvanje UNION ALL SELECT * FROM Iznajmuvanje_preku_Firma) AS FF
WHERE FF.K# = K.K# 
GROUP BY K.K# 

-- dokolku se iznajmi na fizicko lice -> status vo zafateno i obratno 
CREATE TRIGGER trig1 
BEFORE UPDATE ON Fizicko_Iznajmuvanje
FOR EACH ROW 
BEGIN 
    IF (OLD.status<>NEW.status) THEN  
        IF (OLD.status = 'slobodno') THEN 
            UPDATE Elektrichno_Vozilo
            SET status = 'zafateno'
            WHERE shifra = NEW.shifra; 
        ELSE 
            UPDATE Elektrichno_Vozilo
            SET status = 'slobodno'
            WHERE shifra = NEW.shifra;
        END IF; 
    END IF;
END 

-- JUNI 2023 
-- astronauti misija 1 stanica od koja ne se del
SELECT A.* 
FROM astronauti A, M1 M, AsrrM1 AS AM 
WHERE A.shifra = AM.shifra AND AM.M# = M.M# AND NOT EXISTS (
    SELECT *
    FROM Ekipazh E
    WHERE E.A# = A.A# AND M.S# = E.S# 
)

-- astronauti koi nemaat maloletni rodnini (imaat barem eden rodjina)
SELECT a.*
FROM astronaut as a, Civil as c, AC 
WHERE EXISTS (
    SELECT AC.*
    FROM astronaut as a, Civil as c, AC 
    WHERE a.shifra=ac.shifra and ac.shifra=c.shifra
) AND NOT EXISTS (
    SELECT AC.*
    FROM astronaut as a, Civil as c, AC 
    WHERE a.shifra=ac.shifra and ac.shifra=c.shifra AND c.Vozdrast<18
) 

-- astr civ misija 2 neuspeshna 
SELECT A.shifra, C.shifra 
FROM M2 , Astronaut A, Civil C 
WHERE M2.status = 'neuspeshna' AND 

-- vs so najmnogu misii 
SELECT  S.*
FROM (SELECT M1.M#  
FROM M1
UNION ALL 
SELECT M2.M# 
FROM M2  ) AS M , STANICA S 
WHERE POVRZHUESH SO STANICA 
GROUP BY S.S# 
HAVING MAX(VKUPNO)
ORDER BY COUNT (M.M#) DESC LIMIT 1 

CREATE TRIGGER Budzet 
AFTER INSERT ON M2
FOR EACH ROW 
BEGIN 
    UPDATE VStanica 
    SET budzet = budzet + NEW.cena 
    WHERE S# = NEW.S#;
END 