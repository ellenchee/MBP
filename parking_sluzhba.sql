CREATE TABLE Sopstvenik (
    S# INT PRIMARY KEY,
    Ime VARCHAR(20),
    Prezime VARCHAR(30), 
    Adresa VARCHAR(50),
    Vozdrast INT, 
    Firma VARCHAR(50)
);
CREATE TABLE Avtomobil (
    A# INT PRIMARY KEY, 
    Marka VARCHAR(30), 
    Model VARCHAR (50),
    Proizvoditel VARCHAR(50), 
    Godina YEAR,
    Seriski_broj INT, 
    Registracija VARCHAR(10),
    S# INT,
    FOREIGN KEY (S#) REFERENCES Sopstvenik(S#)
);
CREATE TABLE Parking_Lokacija (
    PL# INT PRIMARY KEY,
    Kapacitet INT, 
    Cena FLOAT, 
    Adresa VARCHAR(50),
    Grad VARCHAR(50),
    Momentalno INT
);
CREATE TABLE Parking_Sluzhba (
    PS# INT PRIMARY KEY,
    Ime VARCHAR(50),
    Brv VARCHAR(50),
    Adresa VARCHAR(50),
    Tip VARCHAR(50),
    Budzet FLOAT
);
CREATE TABLE Vraboten (
    Mbr INT PRIMARY KEY,
    Ime VARCHAR(20),
    Prezime VARCHAR(30),
    Honorar INT,
    Datum_ragjanje DATE,
    Datum_vrabotuvanje DATE, 
    Smetka INT,
    PS# INT, 
    FOREIGN KEY (PS#) REFERENCES Parking_Sluzhba(PS#)
);
CREATE TABLE Naplata (
    Mbr INT,
    A# INT,
    PRIMARY KEY (Mbr),
    FOREIGN KEY (Mbr) REFERENCES Vraboten(Mbr),
    FOREIGN KEY (A#) REFERENCES Avtomobil(A#)
);
CREATE TABLE Kontrola (
    Mbr INT,
    PL# INT,
    PRIMARY KEY (Mbr),
    FOREIGN KEY (Mbr) REFERENCES Vraboten(Mbr),
    FOREIGN KEY (PL#) REFERENCES Parking_Lokacija(PL#)
);
CREATE TABLE Polnomoshnik (
    A# INT,
    S# INT,
    PRIMARY KEY (A#, S#),
    CONSTRAINT fk1 FOREIGN KEY (A#) REFERENCES Avtomobil(A#),
    CONSTRAINT fk2 FOREIGN KEY (S#) REFERENCES Sopstvenik(S#)
);
CREATE TABLE Parkiranje (
    A# INT,
    PL# INT,
    Mesto VARCHAR(30),
    Zaminat BOOLEAN, 
    Datum DATE,
    PRIMARY KEY(A#, PL#),
    CONSTRAINT fk1 FOREIGN KEY (A#) REFERENCES Avtomobil(A#),
    CONSTRAINT fk2 FOREIGN KEY (PL#) REFERENCES Parking_Lokacija(PL#) 
);
CREATE TABLE Vozila_Kontrola (
    A# INT,
    Mbr INT,
    PRIMARY KEY (A#, Mbr),
    CONSTRAINT fk1 FOREIGN KEY (A#) REFERENCES Avtomobil(A#),
    CONSTRAINT fk2 FOREIGN KEY (Mbr) REFERENCES Kontrola(Mbr)
);
CREATE TABLE Kontrolira (
    PL# INT,
    Mbr INT,
    PRIMARY KEY(PL#, Mbr),
    CONSTRAINT fk1 FOREIGN KEY (PL#) REFERENCES Parking_Lokacija(PL#),
    CONSTRAINT fk2 FOREIGN KEY (Mbr) REFERENCES Kontrola(Mbr)
);
CREATE TABLE Istorijat (
    A# INT,
    PL# INT,
    Vreme TIME, 
    Den VARCHAR(10),
    PRIMARY KEY (A#, PL#),
    CONSTRAINT fk1 FOREIGN KEY (A#) REFERENCES Avtomobil(A#),
    CONSTRAINT fk2 FOREIGN KEY (PL#) REFERENCES Parking_Lokacija(PL#) 
);

SELECT S.*
FROM Avtomobil A, Sopstvenik S, Parkiranje P, Parking_Lokacija PL, Kontrola K
WHERE S.S# = A.S# AND A.A# = P.A# AND P.PL# = PL.PL# AND PL.PL# = K.PL# AND PL.Cena=0
-- cena = 0 
SELECT A.A#, S.ime
FROM Avtomobil A, Sopstvenik S, Parkiranje AS P, Parking_Lokacija AS PL, Istorijat AS I 
WHERE S.S# = A.S# AND A.A# = P.A# AND P.PL# = PL.PL# AND I.A# = A.A# AND I.PL# = PL.PL#
    AND I.Den = 'Chetvrtok' AND P.Zaminat = FALSE  
SELECT A.*
FROM Avtomobil A, Parkiranje PRK
WHERE  PRK.A# = A.A# AND PRK.Zaminat = FALSE AND A.A# NOT IN (
    SELECT P.A#
    FROM Polnomoshnik P
)
GROUP BY A.A# 
HAVING COUNT (DISTINCT PRK.PL#) >= 2 
-- se parkirani na parking mesto zaminat = false 
-- treba da platat cena > 0 
-- ne se registrirani ??? nema od kj da go znaeme ovoj podatok 
SELECT A.*
FROM Avtomobil A, Parkiranje P, Parking_Lokacija PL
WHERE A.A# = P.A# AND P.Zaminat = FALSE AND P.PL# = PL.PL# AND PL.Cena > 0 
-- povekje od sho treba
-- count momentalno na parking lokacijata
-- imame pole kapacitet
-- ILI count zaminat = false
SELECT PL.*
FROM Parking_Lokacija PL
WHERE PL.Kapacitet < PL.Momentalno 
-- 2 nachin: 
SELECT PL.*
FROM Parking_Lokacija PL, Parkiranje P
WHERE PL.PL# = P.PL# AND P.Zaminat = FALSE 
GROUP BY PL.PL# 
HAVING COUNT (P.A#) > PL.Kapacitet
--po sopstvenik kolku treba da plati 
-- pl -> cena 
-- i kade se parkiral
SELECT S.*, PL.PL#, PL.Adresa, SUM(PL.Cena) AS Vkupna_Cena
FROM Sopstvenik S, Parkiranje P, Parking_Lokacija PL, Avtomobil A
WHERE S.S# = A.S# AND A.A# = P.A# AND P.PL# = PL.PL# AND PL.Cena > 0 
GROUP BY S.S# 
CREATE TRIGGER promena_registracija
AFTER UPDATE ON Avtomobil
FOR EACH ROW 
BEGIN 
    IF (OLD.Registracija <> NEW.Registracija) THEN
    UPDATE Istorijat
    SET Registracija = NEW.Registracija
    WHERE Registracija = OLD.Registracija; 
    END IF 
END 