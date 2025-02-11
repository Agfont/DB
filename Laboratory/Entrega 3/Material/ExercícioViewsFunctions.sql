ter, 18/12/2007 - 17:25 � ribafs 
Estes exerc�cios foram parte do treinamento para a empresa Computex.

View

Uma view � uma consulta armazenada no banco.

Criar uma view que trabalhe na tabela clientes do esquema clientea (datas no estilo dmy).

CREATE VIEW v_clientes_aniversariantes AS
SELECT nome, data_nascimento
FROM clientea.clientes
WHERE SUBSTRING(data_nascimento FROM 1 FOR 5) =
SUBSTRING(CURRENT_DATE FROM 1 FOR 5);

Executar a view (como se fosse uma tabela):

SELECT * FROM v_clientes_aniversariantes;

ou

SELECT * FROM v_clientes_aniversariantes
ORDER BY data_nascimento DESC LIMIT 10;

Caso n�o tenha nenhum registro retornando, alterar um registro para que sua data_nascimento seja hoje:

update clientea.clientes set data_nascimento=current_date where data_nascimento='12/07/1965';

Como acidentalmente se pode executar comandos insert, update e delete em views, podemos prevenir isso com uma rule:

CREATE RULE v_clientes_ins_protect AS ON INSERT TO v_clientes_aniversariantes
DO INSTEAD NOTHING;
CREATE RULE v_clientes_upd_protect AS ON UPDATE TO v_clientes_aniversariantes
DO INSTEAD NOTHING;
CREATE RULE v_clientes_del_protect AS ON DELETE TO v_clientes_aniversariantes
DO INSTEAD NOTHING;

Fun��o em SQL

Fun��o para debitar numa conta banc�ria:

create database banco;
\c banco
create temp table conta(
numero int not null primary key,
saldo numeric(12,2)
);

insert into conta values (1, 1000);

$1 - retorno do primeiro par�metro (integer, numero)
$2 - retorno do segundo par�metro (numeric, saldo)

CREATE FUNCTION debitar (integer, numeric) RETURNS integer AS $$
UPDATE conta
SET saldo = saldo - $2
WHERE numero = $1;
SELECT 1;
$$ LANGUAGE SQL;

Executando:

SELECT debitar(1, 100.0);

Este exemplo retornar� o saldo:

CREATE OR REPLACE FUNCTION debitar (integer, numeric) RETURNS numeric AS $$
UPDATE conta
SET saldo = saldo - $2
WHERE numero = $1;
SELECT saldo FROM conta WHERE numero = $1;
$$ LANGUAGE SQL;

SELECT debitar(1, 100.0) AS saldo;

Mais um exemplo, agora retornando o dobro do sal�rio de um empregado:

CREATE TABLE empregado (
nome text,
salario numeric,
idade integer,
localizacao point
);
insert into empregado values ('Jo�o Brito', 800.00, 35, '(2,1)');

CREATE FUNCTION dobrar_salario(empregado) RETURNS numeric AS $$
SELECT $1.salario * 2 AS salario;
$$ LANGUAGE SQL;
SELECT nome, dobrar_salario(empregado.*) AS pretensao
FROM empregado
WHERE empregado.localizacao ~= point '(2,1)'; 

Toda fun��o SQL deve ser usada numa cl�usula FROM de uma consulta.

Fun��es SQL com tabelas:

CREATE TABLE teste (codigo int, sub int, nome text);
INSERT INTO teste VALUES (1, 1, 'Jo�o');
INSERT INTO teste VALUES (1, 2, 'Pedro');
INSERT INTO teste VALUES (2, 1, 'Maria');

CREATE FUNCTION getteste(int) RETURNS teste AS $$
SELECT * FROM teste WHERE codigo = $1;
$$ LANGUAGE SQL;

SELECT *, upper(nome) AS "Mai�sculo" FROM getteste(1) AS retorno;

Fun��es SQL retornando registros de tabelas
Para isso usamos a palavra reservada SETOF

CREATE FUNCTION getteste2(int) RETURNS SETOF teste AS $$
SELECT * FROM teste WHERE codigo = $1;
$$ LANGUAGE SQL;

SELECT * FROM getteste(1) AS teste2;
SELECT * FROM getteste(2) AS teste2;

Outros exemplos:

CREATE FUNCTION listchildren(text) RETURNS SETOF text AS $$
SELECT name FROM nodes WHERE parent = $1
$$ LANGUAGE SQL;

SELECT * FROM nodes;
name | parent
-----------+--------
Top |
Child1 | Top
Child2 | Top
Child3 | Top
SubChild1 | Child1
SubChild2 | Child1
(6 rows)

SELECT listchildren('Top');
listchildren
--------------
Child1
Child2
Child3
(3 rows)

SELECT name, listchildren(name) FROM nodes;
name | listchildren
--------+--------------
Top | Child1
Top | Child2
Top | Child3
Child1 | SubChild1
Child1 | SubChild2
(5 rows)

