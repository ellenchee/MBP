-- create table sintaksa
CREATE TABLE Firma (
    firma# INT PRIMARY KEY, 
    ime VARCHAR(30),
    adresa VARCHAR(50),
    danochen_broj INT 
);
CREATE TABLE Vraboten (
    mbr INT PRIMARY KEY, 
    ime VARCHAR(20),
    prezime VARCHAR(30),
    plata FLOAT,
    e_shef_na INT,
    CONSTRAINT fk1 FOREIGN KEY (e_shef_na) REFERENCES Firma(firma#)
);
CREATE TABLE Raboti_vo (
    mbr INT,
    firma# INT, 
    Datum_vrabotuvanje DATE,
    CONSTRAINT Raboti_vo_pk  PRIMARY KEY (mbr, firma#),
    FOREIGN KEY fk1 FOREIGN KEY mbr REFERENCES vraboten(mbr),
    FOREIGN KEY fk2 FOREIGN KEY firma# REFERENCES Firma(firma#)
);
-- zadacha 1 
CREATE TABLE igrach (
    k_ime CHAR(20) NOT NULL, 
    CONSTRAINT igrach_pk PRIMARY KEY (k_ime)
);
CREATE TABLE Registriran (
    k_ime CHAR(20),
    ime VARCHAR(20),
    prezime VARCHAR(30),
    lozinka VARCHAR(30),
    email VARCHAR(50),
    Vozdrast INT CHECK (Vozdrast>0 AND Vozdrast<99), 
    datum DATE,
    Najava DATETIME,
    CONSTRAINT pk PRIMARY KEY k_ime,
    CONSTRAINT fk FOREIGN KEY (k_ime) REFERENCES igrach(k_ime)
);
CREATE TABLE NeRegistriran (
    k_ime CHAR(20),
    datum DATE,
    vreme TIME,
    adresa VARCHAR(50),
    CONSTRAINT pk PRIMARY KEY k_ime,
    CONSTRAINT fk FOREIGN KEY (k_ime) REFERENCES igrach(k_ime)
);
CREATE TABLE Admin (
    k_ime CHAR(20),
    nivo INT,
    ime VARCHAR(30),
    k_ime2 CHAR(20),
    CONSTRAINT aPk PRIMARY KEY k_ime,
    CONSTRAINT fk1 FOREIGN KEY (k_ime) REFERENCES registrirani(k_ime),
    CONSTRAINT fk2_administrira FOREIGN KEY (ime) REFERENCES igra(Ime),
    CONSTRAINT fk3_preporaka FOREIGN KEY (k_ime2) REFERENCES admin(k_ime)
);
CREATE TABLE igra (
    ime VARCHAR(30) PRIMARY KEY,
    nasilstvo VARCHAR(20),
    k_ime CHAR(20),
    CONSTRAINT fk_administrira FOREIGN KEY (k_ime) REFERENCES admin(k_ime)
);
CREATE TABLE Platena (
    ime VARCHAR(30) PRIMARY KEY, 
    cena FLOAT, 
    CONSTRAINT fk FOREIGN KEY (ime) REFERENCES igra(ime)
);
CREATE TABLE Besplatna (
    ime VARCHAR(30) PRIMARY KEY,
    max_igrachi INT,
    CONSTRAINT fk1 FOREIGN KEY (ime) REFERENCES igra(ime)
);
CREATE TABLE Prijatelstvo (
    k_ime1 CHAR(20),
    k_ime2 CHAR(20),
    datum DATE,
    CONSTRAINT pk12 PRIMARY KEY (k_ime1, k_ime2),
    CONSTRAINT fk12 FOREIGN KEY (k_ime1, k_ime2) REFERENCES registrirani(k_ime1, k_ime2)
);
CREATE TABLE Platil (
    k_ime CHAR(20),
    ime VARCHAR(30),
    datum DATE, 
    CONSTRAINT pk12 PRIMARY KEY (k_ime, ime),
    CONSTRAINT fk1 FOREIGN KEY (k_ime) REFERENCES registrirani(k_ime),
    CONSTRAINT fk2 FOREIGN KEY (ime) REFERENCES Platena(ime) 
);
CREATE TABLE IgraBesplatno (
    k_ime CHAR(20),
    ime VARCHAR(30),
    CONSTRAINT pk12 PRIMARY KEY (k_ime, ime),
    CONSTRAINT fk1 FOREIGN KEY (k_ime) REFERENCES igrach(k_ime),
    CONSTRAINT fk2 FOREIGN KEY (ime) REFERENCES Besplatna(ime)
);

-- SQL PRASHANJA 
-- 1. proekt 312 , plata > 10.000
SELECT V.ime, V.prezime
FROM Vraboten V, Raboti_na RN
WHERE V.mbr = RN.mbr AND RN.Proekt# = '312' AND V.plata > 10000

-- 2. vrabotenite po plata opagjachki
SELECT ime, prezime, plata
FROM Vraboten  
ORDER BY plata DESC

-- 3. prosechna plata na vrabotenite po proekt 
SELECT RN.Proekt#, AVERAGE(V.plata)
FROM Vraboten V, Raboti_na RN 
WHERE V.mbr = RN.mbr 
GROUP BY RN.Proekt#

-- 4. proektite so prosechna plata nad 20.000
SELECT RN.Proekt#, AVERAGE(V.plata) AS prosek
FROM Vraboten V, Raboti_na RN 
WHERE RN.mbr = V.mbr
GROUP BY RN.Proekt#
HAVING prosek > 20000

-- 5. vraboten so najgolema plata
SELECT V.*
FROM Vraboten V
WHERE V.plata = (
    SELECT MAX(VV.plata)
    FROM Vraboten AS VV 
)

-- 6. mbr na vraboteni shto imaat barem eden proekt 
SELECT DISTINCT mbr -- distinct bez duplikati
FROM Raboti_na

-- 7. vraboteni od oblasta ekologija 'eko'
SELECT V.*
FROM Vraboten V, Raboti_na RN, Proekt P 
WHERE V.mbr = RN.mbr AND RN.Proekt# = P.Proekt# AND P.oblast LIKE '%eko%'

-- 8. status na site sobiri od 2012 
SELECT S.status 
FROM Sobir AS S 
WHERE datum='xx.xx.2012'

-- 9. Vraboteni koi organizirale sobir vo 2012
SELECT V.*
FROM vraboteni_sobir VS, sobir S, Vraboten V 
WHERE VS.s# = S.s# AND V.v# = VS.v# AND s.datum = 'xx.xx.2012' 

-- 10. uchesnici na ETAI 2013 
SELECT U.*
FROM Uchesnik U, Sobir S, UchesnikSobir US, TipSobir TS
WHERE U.u# = US.u# AND US.s# = S.s# AND S.TS# = TS.TS# 
        AND S.datum = 'xx.xx.2013' AND TS.Tip = 'ETAI'

-- 11. vkupna cena na regularnite nastani po sobir 
SELECT R.TS#, SUM(N.cena*(1-R.Namaluvanje))
FROM Regularni AS R, Nastan AS N 
WHERE N.N# = R.N# 
GROUP BY R.TS# 

-- 12. lista od profesori shto uchestvuvale na ETAI 2013
SELECT U.*
FROM Uchesnik U, Sobir S, UchesnikSobir US, TipSobir TS
WHERE U.u# = US.u# AND US.s# = S.s# AND S.TS# = TS.TS# 
        AND S.datum = 'xx.xx.2013' AND TS.Tip = 'ETAI'
        AND U.titula = 'profesor'

-- 13. lista od pochesni gosti na etai
SELECT PG.*
FROM PochesniGosti AS PG, TipSobir AS TS 
WHERE TS.ime = 'ETAI' AND TS.TS# = PG.TS# 

-- 14. iminja na site sobiri shto ne zavrshile - status=tekovno
SELECT TS.ime 
FROM TipSobir TS, Sobir S 
WHERE TS.TS# = S.TS# AND S.status = 'tekovno'

-- 15. Vraboteni koi bile odgovorni za etai konferenciiite 
SELECT DISTINCT V.*
FROM Vraboten AS V, Odgovoren AS O, Sobir AS S, TipSobir AS TS 
WHERE TS.ime = 'ETAI' AND V.V# = O.V# AND S.S# = O.S# AND S.TS# = TS.TS#

-- 16. spisok na site vraboteni zaedno so brojot na ucestva vo organizacija na konf za 
-- bazi na podatoci (vo svoeto ime da sodrzhi zbor 'podato')
SELECT V.*, COUNT(O.V#)
FROM Vraboten V, Odgovoren AS O, Sobir AS S, TipSobir AS TS 
WHERE V.V# = O.V# AND O.S# = S.S# AND TS.TS# = S.TS# AND TS.ime LIKE '%podato%'
GROUP BY O.V#

-- 17. samo vrabotenite so nad 2 uchevstva vo opagjacki redosled 
SELECT V.*, COUNT (O.V#) AS uchestvo 
FROM  Vraboten V, Odgovoren O, Sobir S, TipSobir TS 
WHERE V.V# = O.V# AND O.S# = S.S# AND TS.TS# = S.TS# AND TS.ime LIKE '%podato%'
GROUP BY O.V# 
HAVING uchestvo > 2 
ORDER BY ucestvo DESC 

-- 18. Gradezhni firmi koi se vo izgradba i prodazhba ? 
SELECT GF.*
FROM GradezhnaFirma AS GF, Izgradba AS I, Prodazhba AS P 
WHERE GF.GF# = I.GF# AND GF.GF# = P.GF# 

-- 19. Gradezhni firmi koi sklucile partnerstvo so nad 50%
SELECT GF.*
FROM GradezhnaFirma GF, partnerstvo P 
WHERE GF.GF# = P.GF# AND P.Procent > 50 

-- 20. Vraboteni koi vrshat prodazhba so procent pogolem od 30
SELECT A.*
FROM Arhitekt A, Prodazhba_Arhitekt PA, 
WHERE PA.A# = A.A# AND PA.Procent > 30 

-- 21. Zavrsheni nedvizhnosti 
SELECT *
FROM nedvizhnosti
WHERE status = 'zavrsheno'

-- pogledi i slozheni operatori 
-- 22. ime i prezime na vraboten koj rabotel najmnogu proekti vo 2012 
CREATE VIEW Pregled (Vraboten, Vkupno) AS (
    SELECT RN.mbr, COUNT(RN.Proekt#)
    FROM Raboti_na RN, Proekt P 
    WHERE RN.Proekt# = P.Proekt# AND P.Datum = 'xx.xx.2012' 
    GROUP BY RN.mbr
);
SELECT V.ime, V.prezime 
FROM Vraboten V, Pregled P
WHERE V.mbr = P.Vraboten AND P.Vkupno = ( SELECT MAX(Vkupno) FROM Pregled )

-- 23. mbr na vraboteni koi se vo oddeli so shifri 312 352 613 615 
SELECT mbr 
FROM Raboti_na RN 
WHERE shifra IN (312, 352, 613, 615)

-- 24. vraboteni koi ne rabotele na nitu eden proekt vo 2012
SELECT V.*
FROM Vraboten V, Raboti_na RN 
WHERE NOT EXISTS (
    SELECT P.Proekt#  
    FROM Proekt AS P, Raboti_na AS RN 
    WHERE P.Proekt# = RN.Proekt# AND P.datum_pochetok = 'xx.xx.2012' AND RN.mbr = V.mbr
)

-- 25. vraboteni koi nemaat najniska plata vo odnos na kolegite shto rabotaat na isti proekti 
SELECT V.* 
FROM Vraboten AS V, Raboti_na AS RN 
WHERE V.mbr = RN.mbr AND V.plata > ANY (
    SELECT VV.plata 
    FROM Vraboten VV, Raboti_na RNN 
    WHERE VV.mbr = RNN.mbr AND RNN.Proekt# = RN.Proekt#
)

-- 26. vraboteni koi zemaat najvisoka plata vo odnos na kolegite shto rabotaat na ist proekt 
SELECT V.* 
FROM Vraboten V, Raboti_na RN 
WHERE V.mbr = RN.mbr AND V.plata > ALL (
    SELECT VV.plata 
    FROM Vraboten VV, Raboti_na RNN 
    WHERE VV.mbr = RNN.mbr AND RN.Proekt# = RNN.Proekt# 
)

-- 27. Vraboten so najmnogu uchestva za 2012 na sobiri od oblast bazi na podatoci 
CREATE VIEW Broj_Uchevstva (Vraboten, Kolku) AS (
    SELECT V.V#, COUNT (O.V#)
    FROM Vraboten V, Odgovoren O, Sobir S, TipSobir TS 
    WHERE V.V# = O.V# AND O.S# = S.S# AND TS.TS# = S.TS# AND TS.tip LIKE '%podato%'
    GROUP BY O.V# 
)
SELECT V.*
FROM Vraboten V, Broj_Uchevstva BU 
WHERE V.V# = BU.Vraboten AND BU.Kolku = ( 
    SELECT MAX (KOLKU)
    FROM Broj_Uchevstva
)

--28. ime na site uchesnici koi se registrirale za sobir na koj ne se pochesni gosti
SELECT DISTINCT U.ime  
FROM Uchesnik U, Sobir S, Registracija R 
WHERE U.U# = R.U# AND R.S# = S.S# AND NOT EXISTS (
    SELECT PG.*
    FROM PochesniGosti PG 
    WHERE PG.U# = U.U# AND PG.TS# = S.TS# 
)

--29. Uchesnici koi se registrirale na sobir koj ne go posetile 
SELECT R.U# 
FROM Uchesnik U, Registracija R 
WHERE NOT EXISTS (
    SELECT P.* 
    FROM Poseta P 
    WHERE P.S# = R.S# AND R.U# = P.U# 
)

-- 30. lista od sobiri zaedno so broj na uchesnici po sobir 
SELECT S#, COUNT (DISTINCT U#)
FROM Registracija 
GROUP BY S# 

--31. datum na pochetok na sobir so najgolema posetenost 
CREATE VIEW Posetenost (Sobir, Vkupno) AS (
    SELECT S#, COUNT (U#)
    FROM Poseta 
    GROUP BY S# 
);
SELECT  P.Sobir 
FROM Posetenost AS P 
WHERE P.vkupno = ( 
    SELECT MAX (Vkupno) 
    FROM Posetenost 
)

-- 32. Firmi so najmalku 3 skulcheni partnerstva 
CREATE VIEW Pom (firma) AS (
    SELECT GF1  
    FROM partnerstva
    UNION 
    SELECT GF2 
    FROM partnerstva 
);
SELECT firma, COUNT (firma) AS kolku  
FROM Pom 
HAVING kolku > 3 

-- 33. da se najde nedvizhnosta shto e najskapa 
CREATE VIEW Nedv_cena (Nedvizhnost, Cena) AS (
    SELECT N.N#, SUM(O.Kvadrat * O.Cena)
    FROM Nedvizhnost N, Objekt O 
    WHERE N.N# = O.N# 
    GROUP BY N.N# 
)
SELECT NC.Nedvizhnost
FROM Nedv_cena AS NC 
WHERE NC.Cena = (
    SELECT MAX (CN1.Cena)
    FROM Nedv_cena CN1 
)


-- 34. da se najdat firmite shto prodavaat samo luksuzni nedvizhnini (so cena nad 500.000)
CREATE VIEW Kolku_Nedvizhnini (Firma, Kolku) AS (
    SELECT GF#, COUNT(GF#)
    FROM Nedvizhnost
    GROUP BY GF# 
);
CREATE VIEW Kolku_nad_500 (Firma, Kolku) AS (
    SELECT N.GF#, COUNT (N.GF#)
    FROM Nedvizhnost N, Cena_Nedvizhnost AS CN 
    WHERE N.N# = CN.N# AND CN.Cena > 500000
);
SELECT KN.Firma 
FROM Kolku_Nedvizhnini KN, Kolku_nad_500 KNP 
WHERE KN.Firma = KNP.Firma AND KN.Kolku = KNP.Kolku 

--35. firmi koi imaat vraboteno arhitekti bez diploma 
-- Arhitekti minus arhitekti bez diploma 
CREATE VIEW Arh_bez_D (Arhitekt) AS (
    SELECT A.V#
    FROM Arhitekt A
    WHERE NOT EXISTS (
        SELECT D.D#
        FROM diploma D 
        WHERE A.V# = D.V# 
    )
); 
SELECT DISTINCT V.GF# 
FROM Vraboten AS V, Arh_bez_D AS ABD 
WHERE V.V# = ABD.Arhitekt 

-- TRIGGERI 
-- 36. Dokolku se promeni mbr na nekoj vraboten shefot na koj se menuva mbr isto taka da ja 
-- promeni svojata vrednost, no dokolku se izbrishe nekoj od vraboten da ne se izbrishe i od shef

CREATE TRIGGER trigger1 
AFTER UPDATE ON Vraboten 
FOR EACH ROW 
BEGIN 
    UPDATE Shef 
    SET mbr = NEW.mbr 
    WHERE mbr = OLD.mbr 
END ;

CREATE TRIGGER trigger2 
AFTER DELETE ON Vraboten 
FOR EACH ROW 
BEGIN 
    UPDATE Shef 
    SET mbr = 0 
    WHERE mbr = OLD.mbr 
END; 

-- 37. trigger koj kje se aktivira po promenata na nekoj virus taka shto taa promena kje 
-- rezultira vo celata baza 
CREATE TRIGGER trigger1 
AFTER UPDATE ON Virus 
FOR EACH ROW 
BEGIN 
    UPDATE Zashtita 
    SET Virus = NEW.ime, datum = NEW.datum 
    WHERE Virus = OLD.ime , datum = OLD.datum 
    -- za svite se istive dva reda 
END 

-- 38. dokolku se promeni datumot na izleguvanje na nekoj softver:
-- 1. nema mobilna verzija na antivirusen softver shto e objavena pred samiot antivirusen soft
-- 2. testerite ne mozhat da izvrshat testiranje na antiv. softver pred toj da bide objaven 

CREATE TRIGGER trigger2 
AFTER UPDATE ON Antivirusen
FOR EACH ROW 
BEGIN 
    UPDATE MobilnaVerzija 
    SET datum = NEW.datum 
    WHERE ime=OLD.ime AND verzija=OLD.verzija AND datum < NEW.datum 

    UPDATE Testiranje 
    SET datum = NEW.datum 
    WHERE ime = OLD.ime AND verzija = OLD.verzija AND datum < NEW.datum 
END 

-- 39. dokolku se postavi kraen datum na nekoj sobir toj se postavuva i kaj site vraboteni
-- koi go organiziraat sobirot 
CREATE TRIGGER trig_datum 
BEFORE UPDATE ON Sobir 
FOR EACH ROW 
BEGIN 
    IF (NEW.kraj IS NULL OR NEW.kraj = OLD.kraj )  THEN     
        SET NEW.kraj = OLD.kraj 
    ELSE 
        UPDATE Organizira 
        SET do = NEW.kraj
        WHERE S# = NEW.S# 
    END IF 
END 

-- 40. Da se proshiri entitetot tip sobir taka shto kje se chuva kolku sobiri se imaat 
-- otkazano od toj tip na sobir 
CREATE TRIGGER otkazano 
AFTER UPDATE ON sobir 
FOR EACH ROW 
BEGIN 
    IF (NEW.Status = 'Zavrsheno' AND OLD.Status = 'vo tek') THEN 
    UPDATE TipSobir 
    SET BrSobiri = BrSobiri + 1 
    WHERE TS# = NEW.TS# 
    END IF 
END 

-- 41. Dokolku nekoj vraboten bide vkluchen vo organiziranje na sobirot da se zgolemi
-- brojot na organizatorite 
CREATE TRIGGER org 
AFTER INSERT ON Organizira
FOR EACH ROW 
BEGIN 
    UPDATE Sobir 
    SET br_vrab = br_vrab + 1 
    WHERE S# = NEW.S# 
END 
