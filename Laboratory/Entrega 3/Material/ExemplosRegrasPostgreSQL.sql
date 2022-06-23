/************************************************************************************** 
    ESQUEMA DA BASE DE DADOS PCS 
   Definicao de tabelas, indices, regras, views, autorizacoes,etc 
   Exemplos variados de restricoes de integridade implicitas e explicitas implementadas de diferentes formas 
**************************************************************************************/ 
  
CREATE TABLE produto 
     ( marca                    CHAR(1)          CHECK (marca BETWEEN 'A' AND 'Z'), 
       modelo                  SMALLINT      PRIMARY KEY, 
       tipo                        CHAR(10)        CHECK (tipo IN ('pc','portatil','impressora')), 

      CONSTRAINT prod_modelotipo CHECK ( modelo BETWEEN 1000 AND 1999 AND tipo='pc' OR 
                                                                          modelo BETWEEN 2000 AND 2999 AND tipo='portatil' OR 
                                                                          modelo BETWEEN 3000 AND 3999 AND tipo='impressora') 
     ); 
  

CREATE TABLE pc 
      ( modelo                      SMALLINT        CHECK (modelo BETWEEN 1000 AND 1999)  PRIMARY KEY   REFERENCES produto, 
       velocidade                  SMALLINT        CHECK (velocidade > 100)        DEFAULT 200, 
       ram                             SMALLINT        CHECK (ram >=16)                    DEFAULT 32, 
       hd                               NUMERIC(3,2)  CHECK (hd >1)                          DEFAULT 3.2, 
       cd                               CHAR(3)            CHECK (cd IN ('6x','8x','10x'))  DEFAULT '8x', 
       preco                          SMALLINT        CHECK (preco > 1300), 

      CONSTRAINT pc_velpreco                  CHECK (velocidade >= 150 OR preco <=1600) 
      ); 

--outra sintaxe 
CREATE TABLE portatil( 
       modelo                    SMALLINT, 
       velocidade               SMALLINT            DEFAULT 200, 
       ram                         SMALLINT             DEFAULT 32, 
       hd                           NUMERIC(3,2)       DEFAULT 3.2, 
       ecran                       NUMERIC(3,1)      DEFAULT 12.1, 
       preco                      SMALLINT, 

       PRIMARY KEY  (modelo), 
       FOREIGN KEY (modelo) REFERENCES  produto, 
       CHECK (modelo BETWEEN 2000 AND 2999), 
       CHECK (velocidade >= 100), 
       CHECK (ram >=8), 
       CHECK (hd >0), 
       CHECK (ecran >9), 
       CHECK (preco > 1500), 
       CHECK (ecran >=11 OR hd >= 1 OR preco<2000) 
     ); 
  

CREATE TABLE impressora 
     ( modelo                  SMALLINT   CHECK (modelo BETWEEN 3000 AND 3999)   PRIMARY KEY, 
       cores                     BOOL                                                                                          DEFAULT 'true', 
       tipo                       CHAR(10)     CHECK (tipo IN ('ink-jet','dry','laser'))                   DEFAULT 'laser', 
       preco                    SMALLINT   CHECK (preco > 100), 

       FOREIGN KEY (modelo) REFERENCES produto  ON DELETE CASCADE 
                                                                                        ON UPDATE CASCADE 

     ); 
  

-- Restriccao de integridade que nao permite a existencia de marcas que fabriquem pcs e portateis (ambos). 
-- NOTA: nao funciona em POSTGRESQL 

CREATE ASSERTION pcportatil CHECK ( NOT EXISTS (SELECT marca FROM produto WERE tipo='pc' 
                                                                                               INTERSECT 
                                                                                               SELECT marca FROM produto WHERE tipo='portatil') 
                                                                       ); 

-- Alternativa (aceite em POSTGRESQL) 

     CREATE RULE  pcportatil_i AS 
     ON INSERT TO produto WHERE NEW.tipo='pc' AND 
                                                            NEW.marca IN (SELECT marca 
                                                                                      FROM produto 
                                                                                      WHERE tipo='portatil') 
                                                            OR 
                                                            NEW.tipo='portatil' AND 
                                                            NEW.marca IN (SELECT marca 
                                                                                      FROM produto 
                                                                                       WHERE tipo='pc') 
     DO INSTEAD NOTHING; 

     CREATE RULE  pcportatil_u AS 
     ON UPDATE TO produto WHERE NEW.tipo='pc' AND 
                                                             NEW.marca IN   (SELECT marca 
                                                                                         FROM produto 
                                                                                         WHERE tipo='portatil') 
                                                            OR 
                                                            NEW.tipo='portatil' AND 
                                                            NEW.marca IN   (SELECT marca 
                                                                                        FROM produto 
                                                                                        WHERE tipo='pc') 
     DO INSTEAD NOTHING; 
  

-- Restriccao de integridade que nao permite a existencia de menos de 9 marcas 
-- Quando é que se deve activar? 
-- NOTA: não funciona em POSTGRESQL 

    CREATE ASSERTION marcas9 CHECK ( (SELECT COUNT(DINSTINCT marca) 
                                                                          FROM produto)>9 
                                                                       ); 

-- Alternativa (aceite em POSTGRESQL) 

     CREATE RULE minmarcas_d AS 
     ON DELETE TO produto WHERE  ( SELECT COUNT(DISTINCT marca) 
                                                                 FROM produto) <= 9 
     DO INSTEAD NOTHING; 
  

    CREATE RULE minmarcas_u AS 
    ON UPDATE TO produto    WHERE (SELECT COUNT(DISTINCT marca) 
                                                                 FROM produto) <= 9 
    DO INSTEAD NOTHING; 
  

--Implementacao de uma restricção de integridade (dinamica) 
-- Regra que não permite que o preco das impressoras aumente. 

     CREATE RULE  precoimpressora AS 
     ON UPDATE TO impressora WHERE NEW.preco > OLD.preco 
     DO INSTEAD NOTHING; 
  

-- Cria uma view com as impressoras laser 
CREATE VIEW laser AS ( SELECT marca, produto.modelo,cores,preco 
                                           FROM produto, impressora 
                                          WHERE produto.modelo = impressora.modelo 
                                                         AND impressora.tipo='laser' 
                                          ); 
  

-- Cria um indice, nao unico, com o nome tipo sobre o atributo tipo da tabela produto 
CREATE INDEX  tipo_idx ON produto(tipo); 
  

-- Da autorizacao a todos os utilizadores de executarem SELECTs sobre as tabelas: produto, pc, portatil, impressora, produto e a view laser 
GRANT SELECT ON produto, pc, portatil, impressora, produto, laser  TO PUBLIC; 
