/*
CREATE TABLE "Estudante" (
  "estid" int PRIMARY KEY,
  "estnome" varchar,
  "areaPesq" varchar,
  "nivel" varchar,
  "idade" int
);
CREATE TABLE "Aula" (
  "anome" varchar PRIMARY KEY,
  "dia_hora" varchar,
  "sala" varchar,
  "profid" int
);
CREATE TABLE "Matriculado" (
  "esitid" varchar,
  "anome" varchar,
   PRIMARY KEY ("esitid", "anome")
);
CREATE TABLE "Professor" (
  "profid" int PRIMARY KEY,
  "profnome" varchar,
  "deptoid" int
);*/
--INSERT  INTO ESTUDANTE (estid, estnome, areaPesq, nivel, idade) VALUES(1,"Joao","P1",10,20);
--INSERT  INTO ESTUDANTE (estid, estnome, areaPesq, nivel, idade) VALUES(2,"Lucas","P2",10,20);
--INSERT  INTO ESTUDANTE (estid, estnome, areaPesq, nivel, idade) VALUES(3,"Arthur","P3",10,50);
--INSERT  INTO ESTUDANTE (estid, estnome, areaPesq, nivel, idade) VALUES(4,"Rafael","P4",10,40);
--INSERT INTO Professor (profid, profnome, deptoid) VALUES(1, "Albert", 1);
--INSERT INTO Aula (anome, dia_hora, sala, profid) VALUES("Fisica", "10", "sala1" ,0);
--INSERT INTO Matriculado (esitid, anome) VALUES(4, "Fisica");
-- UPDATE ESTUDANTE SET idade = 60
-- WHERE estid = 4;

--a)
--INSERT  INTO ESTUDANTE (estid, estnome, areaPesq, nivel, idade) VALUES(5,"Tha","P5",10,80);
/*SELECT MAX(idade)
FROM Estudante 
LEFT OUTER JOIN Matriculado ON Matriculado.esitid == Estudante.estid 
LEFT OUTER JOIN Aula ON Aula.anome == Matriculado.anome
LEFT OUTER JOIN Professor ON Aula.profid == Professor.profid
WHERE areaPesq = "Historia" OR Professor.profnome = "Albert";*/
--INSERT INTO Matriculado (esitid, anome) VALUES (1, "Fisica");
--INSERT INTO Matriculado (esitid, anome) VALUES (2, "Fisica");
--INSERT INTO Matriculado (esitid, anome) VALUES (3, "Fisica");
--INSERT INTO Matriculado (esitid, anome) VALUES (5, "Fisica");
--INSERT INTO Aula (anome, dia_hora, sala, profid) VALUES("Mat", "10", "R128", 0);

--b)-----------------------
--INSERT INTO Matriculado (esitid, anome) VALUES (5, "Mat");
/*SELECT Aula.anome
FROM Aula
LEFT OUTER JOIN Matriculado ON Aula.anome = Matriculado.anome
GROUP BY Aula.anome
HAVING COUNT(Aula.anome) >= 5 OR sala = "R128"*/

--c)
--INSERT INTO Aula (anome, dia_hora, sala, profid) VALUES("Mat", "10", "sala2", 0);
--INSERT INTO Matriculado (esitid, anome) VALUES (4, "Mat");
--INSERT INTO Matriculado (esitid, anome) VALUES (1, "Mat");
/*SELECT estnome    
FROM Estudante JOIN Matriculado ON Estudante.estid = Matriculado.esitid 
JOIN Aula ON Matriculado.anome = Aula.anome
GROUP BY estid, dia_hora
HAVING COUNT(estid) >= 2 
*/

--d)
--INSERT INTO Professor (profid, profnome, deptoid) VALUES(0, "Pitagoras", 1);
--INSERT INTO Matriculado (esitid, anome) VALUES (1, "Mat");
--INSERT INTO Matriculado (esitid, anome) VALUES (2, "Mat");
--INSERT INTO Matriculado (esitid, anome) VALUES (3, "Mat");
--INSERT INTO Matriculado (esitid, anome) VALUES (5, "Mat");
/*SELECT DISTINCT (profnome)
FROM Professor JOIN Aula ON Professor.profid == Aula.profid 
JOIN Matriculado ON Matriculado.anome == Aula.anome
GROUP BY Professor.profid, Aula.anome
HAVING COUNT(profnome) < 5
*/

--e)--------
SELECT estnome
FROM Estudante JOIN Matriculado ON  Estudante.estid = Matriculado.esitid
GROUP BY estid
ORDER BY COUNT(estid) DESC LIMIT 1
--INSERT INTO Aula (anome, dia_hora, sala, profid) VALUES("Arte", "10", "ABC", 0);
--INSERT INTO Matriculado (esitid, anome) VALUES (4, "Arte");
/*SELECT estnome
FROM Estudante 
JOIN Matriculado ON Estudante.estid = Matriculado.esitid
GROUP BY estid
HAVING COUNT(*) = (SELECT COUNT(*)
			       FROM Aula)*/
