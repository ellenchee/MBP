CREATE TRIGGER <trigger_name>
<trigger_time> <trigger_action> ON <trigger_name>
--BEFORE/AFTER --INSERT/UPDATE/DELETE
FOR EACH ROW
BEGIN 
<telo_na_trigger>
END;
-- AFTER -> da se smeni vo nekoja druga tabela 
-- BEFORE -> dali smee da se zapishe take podatokot 
CREATE TRIGGER trigger1 
AFTER UPDATE ON Vraboten
FOR EACH ROW 
BEGIN 
    UPDATE Shef 
    SET mbr = NEW.mbr 
    WHERE mbr = OLD.mbr 
END; 

CREATE TRIGGER trigger2 
AFTER DELETE ON Vraboten 
FOR EACH ROW 
BEGIN 
    UPDATE Shef
    SET mbr = 0
    WHERE mbr = OLD.mbr 
END; 
-- ZADACA 2 
--1. dokolku se postavi kraen datum na nekoj sobir, datumot se postavuva 
--i kaj vrabotenite koi go org sobirot 
CREATE TRIGGER trig_datum 
BEFORE UPDATE ON Sobir 
FOR EACH ROW
BEGIN
    IF (NEW.kraj IS NULL OR NEW.kraj = OLD.kraj) THEN 
        SET NEW.kraj = OLD.kraj
        ELSE 
        UPDATE Organizira
        SET do = NEW.kraj
        WHERE s# = NEW.S#
    END IF 
END; 
-- Da se proshiri tipsobir i kje se chuva kolku sobiri od toj tip bile organizirani
CREATE TRIGGER broj_sobiri
AFTER UPDATE ON Sobir 
FOR EACH ROW 
BEGIN 
    IF (NEW.Status = 'Zavrsheno' AND OLD.Status='Vo tek') THEN 
        UPDATE tipsobir
        SET BrSobiri = BrSobiri + 1
        WHERE TS# = NEW.TS# 
    END IF 
END; 
-- nov vraboten vo organizacija na sobirot -> se zgolemuva br na vrab sho go organiziraat
CREATE TRIGGER nov_vraboten
AFTER INSERT ON Organizira
FOR EACH ROW 
BEGIN 
    UPDATE Sobir 
    SET br_vrab = br_vrab + 1
    WHERE S# = NEW.S# 
END 
