CREATE TABLE Migrant (
    M# INT PRIMARY KEY,
    Ime VARCHAR(30),
    Prezime VARCHAR(30),
    Datum_ragjanje DATE,
    Drzhavjanstvo VARCHAR(30),
    Nacionalnost VARCHAR(30),
    Tip_migrant VARCHAR(30),
    Pari FLOAT,
    Status VARCHAR(20),
    Rodnini_MK BOOLEAN
);

CREATE TABLE Rodnina (
    M1# INT,
    M2# INT,
    Tip_rodnina VARCHAR(30),

    PRIMARY KEY(M1#, M2#),

    FOREIGN KEY (M1#)
    REFERENCES Migrant(M#),

    FOREIGN KEY (M2#)
    REFERENCES Migrant(M#)
);

CREATE TABLE Policajec (
    P# INT PRIMARY KEY,
    Ime VARCHAR(30),
    Prezime VARCHAR(30),
    Datum_vrabotuvanje DATE,
    Broj_evidentirani INT
);

CREATE TABLE Ilegalen_Migrant (
    M# INT PRIMARY KEY,
    Datum_fakjanje DATE,
    Nachin_priveduvanje VARCHAR(50),
    Pritvor BOOLEAN,
    Vooruzhen BOOLEAN,

    FOREIGN KEY (M#)
    REFERENCES Migrant(M#)
);

CREATE TABLE Operacija (
    O# INT PRIMARY KEY,
    Datum DATE,
    Tip VARCHAR(20)
);

CREATE TABLE Operacija_Migrant (
    O# INT,
    M# INT,

    PRIMARY KEY(O#, M#),

    FOREIGN KEY (O#)
    REFERENCES Operacija(O#),

    FOREIGN KEY (M#)
    REFERENCES Ilegalen_Migrant(M#)
);

CREATE TABLE Policajec_Operacija (
    P# INT,
    O# INT,

    PRIMARY KEY(P#, O#),

    FOREIGN KEY (P#)
    REFERENCES Policajec(P#),

    FOREIGN KEY (O#)
    REFERENCES Operacija(O#)
);

CREATE TABLE Granichen_Premin (
    GP# INT PRIMARY KEY,
    Ime VARCHAR(50),
    Drzhava VARCHAR(30),
    Prosechen_dnevni INT,
    Status VARCHAR(20)
);

CREATE TABLE Legalen_Migrant (
    M# INT PRIMARY KEY,
    Datum_premin DATE,
    Tip_premin VARCHAR(30),
    GP# INT,

    FOREIGN KEY (M#)
    REFERENCES Migrant(M#),

    FOREIGN KEY (GP#)
    REFERENCES Granichen_Premin(GP#)
);

CREATE TABLE Ambasada (
    A# INT PRIMARY KEY,
    Ime VARCHAR(50),
    Adresa VARCHAR(50),
    Drzhava VARCHAR(30),
    Ambasador VARCHAR(50),
    Licenca_do YEAR
);

CREATE TABLE Baranje_Azil (
    B# INT PRIMARY KEY,
    Status VARCHAR(30),

    M# INT,
    A_podnesena# INT,
    A_baranje# INT,
    P# INT,

    FOREIGN KEY (M#)
    REFERENCES Legalen_Migrant(M#),

    FOREIGN KEY (A_podnesena#)
    REFERENCES Ambasada(A#),

    FOREIGN KEY (A_baranje#)
    REFERENCES Ambasada(A#),

    FOREIGN KEY (P#)
    REFERENCES Policajec(P#)
);
CREATE TABLE Tranziten_Migrant (
    M# INT PRIMARY KEY,
    Od_GP# INT,
    Kon_GP# INT,
    Datum_napushtanje DATE,

    FOREIGN KEY (M#)
    REFERENCES Migrant(M#),

    FOREIGN KEY (Od_GP#)
    REFERENCES Granichen_Premin(GP#),

    FOREIGN KEY (Kon_GP#)
    REFERENCES Granichen_Premin(GP#)
);
-- migranti * , podnele baranje za azil
-- ambasada stara = ambasada baranje 
-- godina stara = godina baranje 
-- LEGALEN MIGRANT IMA DATUM PREMIN 
SELECT M.* 
FROM Migrant M, Baranje_Azil BA, Ambasada A,  Legalen_Migrant LM
WHERE M.M# = BA.M# AND BA.A# = A.A# AND M.M# = LM.M# AND YEAR(LM.Datum_premin) = YEAR(BA.Datum_baranje)
-- migranti * , baranje za azil
-- nivnite roditeli nemaat baranje za azil
SELECT M.* 
FROM Migrant M, Rodnina R, Baranje_Azil BA 
WHERE M.M# = R.M1# AND BA.M#=M.M# AND R.M2# NOT IN ( SELECT M.*
FROM Migrant M, Baranje_Azil BA
WHERE M.M# = BA.M#
) AND R.Tip_rodnina = 'Roditel'
-- barame granicni premini 
-- povekje tranzitirani premini > evidentirani migranti
-- vo legalen migrant mozhe da znaeme kolku ja proshle granicata 
-- tranziten migrant OD_GP od koj granicen premin vlegol
-- gi praeme relaciite GP -> LM  i  GP -> TM 
SELECT GP.*
FROM Granichen_Premin GP, Legalen_Migrant LM, Tranziten_Migrant TM 
WHERE GP.GP# = LM.GP# AND GP.GP# = TM.Od_GP# 
GROUP BY GP.GP# 
HAVING COUNT(TM.M#) > COUNT(LM.M#)
-- se brishe granichen premin -- site povrzani podatoci so nego ne se brishat
ON DELETE SET NULL -- segde kade sho se koristi GP# vo druga tabela kako FK
-- se brishat podatocite za nekoja operacija -> se brishat site policajci vklucheni vo op
ON DELETE CASCADE -- vo operacija_migrant -> on delete set null za operacija i on delete cascade za policaec

CREATE TRIGGER trigger1
AFTER DELETE ON Operacija
FOR EACH ROW
BEGIN 
    DELETE FROM Policajec
    WHERE P# IN 
    (
        SELECT P# 
        FROM Policajec_Operacija
        WHERE O# = OLD.O#
    )
END 
