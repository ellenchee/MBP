CREATE TABLE Antivirusen (
    ime CHAR(20) NOT NULL ,
    verzija FLOAT NOT NULL CHECK (verzija>2.0),
    korporacija VARCHAR(20) CHECK korporacija IN ('ESET', 'KASPERSKY', 'AVAST', 'NORTON'),
    datum DATETIME,
    CONSTRAINT Antivirusen_pk PRIMARY KEY (ime, verzija),
); 
CREATE TABLE MobilnaVerzija(
    ime CHAR(20) NOT NULL, 
    verzija FLOAT NOT NULL, 
    datum DATETIME, 
    efikasnost INT, 
    CONSTRAINT mobilna_pk PRIMARY KEY (ime, verzija), 
    CONSTRAINT mobilna_fk FOREIGN KEY (ime, verzija) REFERENCES Antivirusen(ime, verzija)
    ON DELETE CASCADE
); 
CREATE TABLE Virus(
    ime CHAR(20) NOT NULL, 
    datum DATETIME NOT NULL,
    CONSTRAINT Virus_pk PRIMARY KEY (ime, datum)
);
CREATE TABLE Zashtita (
    antivirus CHAR(20) NOT NULL, 
    verzija FLOAT NOT NULL, 
    virus CHAR(20) NOT NULL, 
    datum DATETIME NOT NULL, 
    nivo INT, 
    CONSTRAINT Zashtita_pk PRIMARY KEY (antivirus, verzija, virus, datum), 
    CONSTRAINT Zashtita_pk1 FOREIGN KEY (antivirus, verzija) REFERENCES Antivirusen (ime, verzija)
    ON DELETE CASCADE
    CONSTRAINT Zashtita_fk2 FOREIGN KEY (virus,datum) REFERENCES Virus (ime, datum) 
    ON DELETE SET NULL
); 
CREATE TRIGGER trigger1 
AFTER UPDATE ON virus 
FOR EACH ROW 
BEGIN 
    UPDATE Zashtita
    SET virus = NEW.ime, datum = NEW.datum 
    WHERE virus = OLD.ime AND datum = OLD.datum

    UPDATE Trojanec 
    SET ime = NEW.ime, datum = NEW.datum
    WHERE ime = OLD.ime AND datum=OLD.datum

    UPDATE Spy 
    SET ime = NEW.ime, datum = NEW.datum
    WHERE ime = OLD.ime AND datum = OLD.datum
END; 
CREATE TRIGGER trigger2
AFTER UPDATE ON Antivirusen
FOR EACH ROW
BEGIN
    UPDATE MobilnaVerzija
    SET datum = NEW.datum
    WHERE ime = OLD.ime AND verzija = OLD.verzija AND datum < NEW.datum
    
    UPDATE Testiranje
    SET datum = NEW.datum
    WHERE ime = OLD.ime AND verzija = OLD.verzija AND datum < NEW.datum
END; 


CREATE TRIGGER trig_datum 
BEFORE UPDATE ON sobir 
FOR EACH ROW 
BEGIN 
    IF (NEW.kraj IS NULL OR NEW.kraj = OLD.kraj ) THEN 
        SET NEW.kraj = OLD.kraj 
    ELSE 
        UPDATE Organizira 
        SET do = NEW.kraj
        WHERE s# = NEW.s#
    END IF 
END 

CREATE TRIGGER broj_sobiri
AFTER UPDATE ON sobir
FOR EACH ROW 
BEGIN  
    IF (NEW.status='Zavrsheno' AND OLD.status='Vo tek') THEN 
        UPDATE tipsobir 
        SET BrSobiri = BrSobiri + 1 
        WHERE TS# = NEW.TS# 
    END IF 
END 

CREATE TRIGGER vraboteni_sobir 
AFTER INSERT ON Organizira
FOR EACH ROW
BEGIN 
    UPDATE Sobir 
    SET br_vrab = br_vrab + 1 
    WHERE S# = NEW.S# 
END 

CREATE TRIGGER norm1 
BEFORE INSERT ON Uchesnik 
FOR EACH ROW 
BEGIN 
    SET NEW.ime = upper(left(NEW.ime, 1)+lower(substring(NEW.ime, 2, LEN(NEW.ime))))
    SET NEW.prezime = upper(left(NEW.prezime, 1)+lower(substring(NEW.prezime, 2, LEN(NEW.prezime))))
END
CREATE TRIGGER norm2 
BEFORE UPDATE ON Uchesnik
FOR EACH ROW 
BEGIN 
    SET NEW.ime = upper(left(NEW.ime, 1)+lower(substring(NEW.ime, 2, LEN(NEW.ime))))
    SET NEW.prezime = upper(left(NEW.prezime)+lower(substring(NEW.prezime,2,LEN(NEW.prezime))))
END

CREATE TRIGGER cena_promena
BEFORE UPDATE ON Nastan
FOR EACH ROW 
BEGIN 
    IF(OLD.cena <> NEW.cena) THEN
    UPDATE Regularni 
    SET Namaluvanje = Namaluvanje * (NEW.cena / OLD.cena)
    WHERE N#=NEW.N#
    END IF
END 

CREATE TRIGGER capital
BEFORE UPDATE ON Firma 
FOR EACH ROW 
BEGIN 
    IF (OLD.Kapital > NEW.Kapital) THEN 
        UPDATE Prodazhba_Arhitekt 
        SET Procent = Procent - Procent*0.01; 
        WHERE GF# = NEW.GF#
    END IF 
END 

CREATE TRIGGER Kvadratura_trigger
BEFORE UPDATE ON Objekt 
FOR EACH ROW 
BEGIN 
    IF (OLD.kvadratura <> NEW.kvadratura) THEN 
        SET NEW.cena = 0
    END IF 
END 

