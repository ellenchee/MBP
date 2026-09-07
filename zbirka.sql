-- mbr iminja i preziminja na korisnici
SELECT mbr, ime, prezime
FROM korisnici

-- podatocite za site korisnici od tip pospejd 
SELECT K.*
FROM Korisnici AS K 
WHERE K.tip = pospejd 

--telefonski broevi megju koi e pratena barem edna porka 
SELECT prakjach, primach 
FROM SMS AS S (shifrasms, vreme, sodrzhina, prakjach)
NATURAL JOIN Primachi as P (shifrasms, primach)

-- korisnici ime i prezime pomegju koi e pratena barem edna poraka 
SELECT K1.ime, K1.prezime, K2.ime, K2.prezime
FROM Korisnik K1, Korisnik K2, SMS AS S, telefonski_broj TB, Primach P
WHERE EXISTS K1.mbr = S.mbr AND K2.mbr = P.mbr AND S.shifrasms = P.shifrasms

-- za sekoj telefonski broj da se prikaze vkupniot broj na razzgovori vo koi uchestvuval vo
-- septemvri 2021 nema vrska dali e povikuvac ili povikan
SELECT TB.broj, SUM(R.traenje)
FROM Razgovor R, TelefonskiBroj TB
WHERE YEAR(TB.datum) = 2021 AND MONTH(TB.datum) = SEPTEMBER 
GROUP BY TB.broj 

-- ni treba sum traenje po telefonski broj 
-- РАЗГОВОР ( шифра, повикувач*, повикан*, тарифа*, датум, почеток, траење);
