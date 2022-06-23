ter, 18/12/2007 - 17:08 � ribafs 
Fun��es e Triggers Definidas pelo Usu�rio 

O PostgreSQL oferece quatro tipos de fun��es:
- Fun��es escritas em SQL
- Fun��es em linguagens de procedimento (PL/pgSQL, PL/Tcl, PL/php, PL/Java, etc)
- Fun��es internas (rount(), now(), max(), count(), etc).
- Fun��es na linguagem C

CREATE [ OR REPLACE ] FUNCTION
name ( [ [ argmode ] [ argname ] argtype [, ...] ] )
[ RETURNS rettype ]
{ LANGUAGE langname
| IMMUTABLE | STABLE | VOLATILE
| CALLED ON NULL INPUT | RETURNS NULL ON NULL INPUT | STRICT
| [ EXTERNAL ] SECURITY INVOKER | [ EXTERNAL ] SECURITY DEFINER
| AS 'definition'
| AS 'obj_file', 'link_symbol'
} ...
[ WITH ( attribute [, ...] ) ]

Para refor�ar a seguran�a � interessante usar o par�metro SECURITY DEFINER, que especifica que a fun��o ser� executada com os privil�gios do usu�rio que a criou. 

SECURITY INVOKER indica que a fun��o deve ser executada com os privil�gios do usu�rio que a chamou (padr�o). 

SECURITY DEFINER especifica que a fun��o deve ser executada com os privil�gios do usu�rio que a criou.

Uma grande for�a do PostgreSQL � que ele permite a cria��o de fun��es pelo usu�rio em diversas linguagens: SQL, PlpgSQL, TCL, Perl, Phyton, Ruby.

Para ter exemplos a disposi��o vamos instalar os do diret�rio "tutorial" dos fontes do PostgreSQL:

Acessar /usr/local/src/postgresql-8.1.3/src/tutorial e executar:

make install

Feito isso teremos 5 arquivos .sql. 

O syscat.sql traz consultas sobre o cat�logo de sistema, o que se chama de metadados (metadata).
O basic.sql e o advanced.sql s�o consultas SQL.
O complex.sql trata da cria��o de um tipo de dados pelo usu�rio e seu uso.
O func.sql traz algumas fun��es em SQL e outras em C.

Fun��es em SQL

O que outros SGBDs chamam de stored procedures o PostgreSQL chama de fun��es, que podem ser em diversas linguagens.

CREATE OR REPLACE FUNCTION olamundo() RETURNS int4
AS 'SELECT 1' LANGUAGE 'sql';

SELECT olamundo() ;

CREATE OR REPLACE FUNCTION add_numeros(nr1 int4, nr2 int4) RETURNS int4
AS 'SELECT $1 + $2' LANGUAGE 'sql';
SELECT add_numeros(300, 700) AS resposta ;

Podemos passar como par�metro o nome de uma tabela:

CREATE TEMP TABLE empregados (
nome text,
salario numeric,
idade integer,
baia point
);

INSERT INTO empregados VALUES('Jo�o',2200,21,point('(1,1)'));
INSERT INTO empregados VALUES('Jos�',4200,30,point('(2,1)'));

CREATE FUNCTION dobrar_salario(empregados) RETURNS numeric AS $$
SELECT $1.salario * 2 AS salario;
$$ LANGUAGE SQL;

SELECT nome, dobrar_salario(emp.*) AS sonho
FROM empregados
WHERE empregados.baia ~= point '(2,1)';

Algumas vezes � pr�tico gerar o valor do argumento composto em tempo de execu��o. Isto pode ser feito atrav�s da constru��o ROW. 

SELECT nome, dobrar_salario(ROW(nome, salario*1.1, idade, baia)) AS sonho
FROM empregados;

Fun��o que retorna um tipo composto. Fun��o que retorna uma �nica linha da tabela empregados:

CREATE FUNCTION novo_empregado() RETURNS empregados AS $$
SELECT text 'Nenhum' AS nome,
1000.0 AS salario,
25 AS idade,
point '(2,2)' AS baia;
$$ LANGUAGE SQL;

Ou
CREATE OR REPLACE FUNCTION novo_empregado() RETURNS empregados AS $$
SELECT ROW('Nenhum', 1000.0, 25, '(2,2)')::empregados;
$$ LANGUAGE SQL;

Chamar assim:
SELECT novo_empregado();

ou
SELECT * FROM novo_empregado();

Fun��es SQL como fontes de tabelas

CREATE TEMP TABLE teste (testeid int, testesubid int, testename text);
INSERT INTO teste VALUES (1, 1, 'Jo�o');
INSERT INTO teste VALUES (1, 2, 'Jos�');
INSERT INTO teste VALUES (2, 1, 'Maria');

CREATE FUNCTION getteste(int) RETURNS teste AS $$
SELECT * FROM teste WHERE testeid = $1;
$$ LANGUAGE SQL;

SELECT *, upper(testename) FROM getteste(1) AS t1;

Tabelas Tempor�rias - criar tabelas tempor�rias (TEMP), faz com que o servidor se encarregue de remov�-la (o que faz logo que a conex�o seja encerrada).

CREATE TEMP TABLE nometabela (campo tipo);

Fun��es SQL retornando conjunto

CREATE FUNCTION getteste(int) RETURNS SETOF teste AS $$
SELECT * FROM teste WHERE testeid = $1;
$$ LANGUAGE SQL;

SELECT * FROM getteste(1) AS t1;

Fun��es SQL polim�rficas
As fun��es SQL podem ser declaradas como recebendo e retornando os tipos polim�rficos anyelement e anyarray.

CREATE FUNCTION constroi_matriz(anyelement, anyelement) RETURNS anyarray AS $$
SELECT ARRAY[$1, $2];
$$ LANGUAGE SQL;

SELECT constroi_matriz(1, 2) AS intarray, constroi_matriz('a'::text, 'b') AS textarray;

CREATE FUNCTION eh_maior(anyelement, anyelement) RETURNS boolean AS $$
SELECT $1 > $2;
$$ LANGUAGE SQL;
SELECT eh_maior(1, 2);
Mais detalhes no cap�tulo 31 do manual.
7.2 - Fun��es em PlpgSQL

As fun��es em linguagens procedurais no PostgreSQL, como a PlpgSQL s�o correspondentes ao que se chama comumente de Stored Procedures.

Por default o PostgreSQL s� traz suporte �s fun��es na linguagem SQL. Para dar suporte � fun��es em outras linguagens temos que efetuar procedimentos como a seguir.
Para que o banco postgres tenha suporte � linguagem de procedimento PlPgSQL executamos na linha de comando como super usu�rio do PostgreSQL:

createlang plpgsql �U nomeuser nomebanco
A PlpgSQL � a linguagem de procedimentos armazenados mais utilizada no PostgreSQL, devido ser a mais madura e com mais recursos.

CREATE FUNCTION func_escopo() RETURNS integer AS $$
DECLARE
quantidade integer := 30;
BEGIN
RAISE NOTICE 'Aqui a quantidade � %', quantidade; -- A quantidade aqui � 30
quantidade := 50;
--
-- Criar um sub-bloco
--
DECLARE
quantidade integer := 80;
BEGIN
RAISE NOTICE 'Aqui a quantidade � %', quantidade; -- A quantidade aqui � 80
END;
RAISE NOTICE 'Aqui a quantidade � %', quantidade; -- A quantidade aqui � 50
RETURN quantidade;
END;
$$ LANGUAGE plpgsql;

=> SELECT func_escopo();

CREATE FUNCTION instr(varchar, integer) RETURNS integer AS $$
DECLARE
v_string ALIAS FOR $1;
index ALIAS FOR $2;
BEGIN
-- algum processamento neste ponto
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION concatenar_campos_selecionados(in_t nome_da_tabela) RETURNS text AS $$
BEGIN
RETURN in_t.f1 || in_t.f3 || in_t.f5 || in_t.f7;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION somar_tres_valores(v1 anyelement, v2 anyelement, v3 anyelement)
RETURNS anyelement AS $$
DECLARE
resultado ALIAS FOR $0;
BEGIN
resultado := v1 + v2 + v3;
RETURN resultado;
END;
$$ LANGUAGE plpgsql;

SELECT somar_tres_valores(10,20,30);

Utiliza��o de tipo composto:
CREATE FUNCTION mesclar_campos(t_linha nome_da_tabela) RETURNS text AS $$
DECLARE
t2_linha nome_tabela2%ROWTYPE;
BEGIN
SELECT * INTO t2_linha FROM nome_tabela2 WHERE ... ;
RETURN t_linha.f1 || t2_linha.f3 || t_linha.f5 || t2_linha.f7;
END;
$$ LANGUAGE plpgsql;

SELECT mesclar_campos(t.*) FROM nome_da_tabela t WHERE ... ;

Temos uma tabela (datas) com dois campos (data e hora) e queremos usar uma fun��o para manipular os dados desta tabela:

CREATE or REPLACE FUNCTION data_ctl(opcao char, fdata date, fhora time) RETURNS char(10) AS '
DECLARE
opcao ALIAS FOR $1;
vdata ALIAS FOR $2;
vhora ALIAS FOR $3;
retorno char(10);
BEGIN
IF opcao = ''I'' THEN
insert into datas (data, hora) values (vdata, vhora);
retorno := ''INSERT'';
END IF;
IF opcao = ''U'' THEN
update datas set data = vdata, hora = vhora where data=''1995-11-01'';
retorno := ''UPDATE'';
END IF;
IF opcao = ''D'' THEN
delete from datas where data = vdata;
retorno := ''DELETE'';
ELSE
retorno := ''NENHUMA'';
END IF;
RETURN retorno;
END;
' LANGUAGE plpgsql;
//select data_ctl('I','1996-11-01', '08:15');
select data_ctl('U','1997-11-01','06:36');
select data_ctl('U','1997-11-01','06:36');
Mais Detalhes no cap�tulo 35 do manual oficial.

Fun��es que Retornam Conjuntos de Registros (SETS)
CREATE OR REPLACE FUNCTION codigo_empregado (codigo INTEGER)
RETURNS SETOF INTEGER AS '
DECLARE
registro RECORD;
retval INTEGER;
BEGIN
FOR registro IN SELECT * FROM empregados WHERE salario >= $1 LOOP
RETURN NEXT registro.departamento_cod;
END LOOP;
RETURN;
END;
' language 'plpgsql';

select * from codigo_empregado (0);
select count (*), g from codigo_empregado (5000) g group by g;

Fun��es que retornam Registro
Para criar fun��es em plpgsql que retornem um registro, antes precisamos criar uma vari�vel composta do tipo ROWTYPE, descrevendo o registro (tupla) de sa�da
da fun��o.

CREATE TABLE empregados(
nome_emp text,
salario int4,
codigo int4 NOT NULL,
departamento_cod int4,
CONSTRAINT empregados_pkey PRIMARY KEY (codigo),
CONSTRAINT empregados_departamento_cod_fkey FOREIGN KEY (departamento_cod)
REFERENCES departamentos (codigo) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION
) 

CREATE TABLE departamentos (codigo INT primary key, nome varchar);

CREATE TYPE dept_media AS (minsal INT, maxsal INT, medsal INT);

create or replace function media_dept() returns dept_media as
'
declare
r dept_media%rowtype;
dept record;
bucket int8;
counter int;
begin
bucket := 0;
counter := 0;
r.maxsal :=0;
r.minsal :=0;
for dept in select sum(salario) as salario, d.codigo as departamento
from empregados e, departamentos d where e.departamento_cod = d.codigo
group by departamento loop
counter := counter + 1;
bucket := bucket + dept.salario;
if r.maxsal <= dept.salario or r.maxsal = 0 then
r.maxsal := dept.salario;
end if;
if r.minsal <= dept.salario or r.minsal = 0 then
r.minsal := dept.salario;
end if;
end loop;

r.medsal := bucket/counter;

return r;
end
' language 'plpgsql';

Fun��es que Retornam Conjunto de Registros (SETOF, Result Set)
Tamb�m requerem a cria��o de uma vari�vel (tipo definidopelo user)

CREATE TYPE media_sal AS
(deptcod int, minsal int, maxsal int, medsal int);

CREATE OR REPLACE FUNCTION medsal() RETURNS SETOF media_sal AS
'
DECLARE
s media_sal%ROWTYPE;
salrec RECORD;
bucket int;
counter int;
BEGIN
bucket :=0;
counter :=0;
s.maxsal :=0;
s.minsal :=0;
s.deptcod :=0;
FOR salrec IN SELECT salario AS salario, d.codigo AS departamento
FROM empregados e, departamentos d WHERE e.departamento_cod = d.codigo ORDER BY d.codigo LOOP
IF s.deptcod = 0 THEN
s.deptcod := salrec.departamento;
s.minsal := salrec.salario;
s.maxsal := salrec.salario;
counter := counter + 1;
bucket := bucket + salrec.salario;
ELSE
IF s.deptcod = salrec.departamento THEN
IF s.maxsal <= salrec.salario THEN
s.maxsal := salrec.salario;
END IF;
IF s.minsal >= salrec.salario THEN
s.minsal := salrec.salario;
END IF;
counter := counter +1;
ELSE
s.medsal := bucket/counter;
RETURN NEXT s;
s.deptcod := salrec.departamento;
s.minsal := salrec.salario;
s.maxsal := salrec.salario;
counter := 1;
bucket := salrec.salario;
END IF;
END IF;
END LOOP;
s.medsal := bucket/counter;
RETURN NEXT s;
RETURN;
END '
LANGUAGE 'plpgsql';

select * from medsal()

Relacionando:
select d.nome, a.minsal, a.maxsal, a.medsal
from medsal() a, departamentos d
where d.codigo = a.deptcod

Triggers (Gatilhos)

Cap�tulo 32 do manual oficial. e:
http://pgdocptbr.sourceforge.net/pg80/sql-createtrigger.html
At� a vers�o atual n�o existe como criar fun��es de gatilho na linguagem SQL.

Ocorrem em eventos que acontecem em tabelas.
Uma fun��o de gatilho pode ser criada para executar antes (BEFORE) ou ap�s (AFTER) as consultas INSERT, UPDATE OU DELETE, uma vez para cada registro (linha) modificado ou por instru��o SQL. Logo que ocorre um desses eventos do gatilho a fun��o do gatilho � disparada automaticamente para tratar o evento.

A fun��o de gatilho deve ser declarada como uma fun��o que n�o recebe argumentos e que retorna o tipo TRIGGER.
Ap�s criar a fun��o de gatilho, estabelecemos o gatilho pelo comando CREATE TRIGGER. Uma fun��o de gatilho pode ser utilizada por v�rios gatilhos.

As fun��es de gatilho chamadas por gatilhos-por-instru��o devem sempre retornar NULL. 

As fun��es de gatilho chamadas por gatilhos-por-linha podem retornar uma linha da tabela (um valor do tipo HeapTuple) para o executor da chamada, se assim o decidirem. 

Sintaxe:
CREATE TRIGGER nome { BEFORE | AFTER } { evento [ OR ... ] }
ON tabela [ FOR [ EACH ] { ROW | STATEMENT } ]
EXECUTE PROCEDURE nome_da_fun��o ( argumentos )

O gatilho fica associado � tabela especificada e executa a fun��o especificada nome_da_fun��o quando determinados eventos ocorrerem.

O gatilho pode ser especificado para disparar antes de tentar realizar a opera��o na linha (antes das restri��es serem verificadas e o comando INSERT, UPDATE ou DELETE ser tentado), ou ap�s a opera��o estar completa (ap�s as restri��es serem verificadas e o INSERT, UPDATE ou DELETE ter completado). 

evento
Um entre INSERT, UPDATE ou DELETE; especifica o evento que dispara o gatilho. V�rios eventos podem ser especificados utilizando OR. 

Exemplos:
CREATE TABLE empregados(
codigo int4 NOT NULL,
nome varchar,
salario int4,
departamento_cod int4,
ultima_data timestamp,
ultimo_usuario varchar(50),
CONSTRAINT empregados_pkey PRIMARY KEY (codigo) ) 

CREATE FUNCTION empregados_gatilho() RETURNS trigger AS $empregados_gatilho$
BEGIN
-- Verificar se foi fornecido o nome e o sal�rio do empregado
IF NEW.nome IS NULL THEN
RAISE EXCEPTION 'O nome do empregado n�o pode ser nulo';
END IF;
IF NEW.salario IS NULL THEN
RAISE EXCEPTION '% n�o pode ter um sal�rio nulo', NEW.nome;
END IF;

-- Quem paga para trabalhar?
IF NEW.salario < 0 THEN
RAISE EXCEPTION '% n�o pode ter um sal�rio negativo', NEW.nome;
END IF;

-- Registrar quem alterou a folha de pagamento e quando
NEW.ultima_data := 'now';
NEW.ultimo_usuario := current_user;
RETURN NEW;
END;
$empregados_gatilho$ LANGUAGE plpgsql;
CREATE TRIGGER empregados_gatilho BEFORE INSERT OR UPDATE ON empregados
FOR EACH ROW EXECUTE PROCEDURE empregados_gatilho();

INSERT INTO empregados (codigo,nome, salario) VALUES (5,'Jo�o',1000);
INSERT INTO empregados (codigo,nome, salario) VALUES (6,'Jos�',1500);
INSERT INTO empregados (codigo,nome, salario) VALUES (7,'Maria',2500);

SELECT * FROM empregados;

INSERT INTO empregados (codigo,nome, salario) VALUES (5,NULL,1000);
NEW � Para INSERT e UPDATE
OLD � Para DELETE

CREATE TABLE empregados (
nome varchar NOT NULL,
salario integer
);

CREATE TABLE empregados_audit(
operacao char(1) NOT NULL,
usuario varchar NOT NULL,
data timestamp NOT NULL,
nome varchar NOT NULL,
salario integer
);

CREATE OR REPLACE FUNCTION processa_emp_audit() RETURNS TRIGGER AS $emp_audit$
BEGIN
--
-- Cria uma linha na tabela emp_audit para refletir a opera��o
-- realizada na tabela emp. Utiliza a vari�vel especial TG_OP
-- para descobrir a opera��o sendo realizada.
--
IF (TG_OP = 'DELETE') THEN
INSERT INTO emp_audit SELECT 'E', user, now(), OLD.*;
RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
INSERT INTO emp_audit SELECT 'A', user, now(), NEW.*;
RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
INSERT INTO emp_audit SELECT 'I', user, now(), NEW.*;
RETURN NEW;
END IF;
RETURN NULL; -- o resultado � ignorado uma vez que este � um gatilho AFTER
END;
$emp_audit$ language plpgsql;

CREATE TRIGGER emp_audit
AFTER INSERT OR UPDATE OR DELETE ON empregados
FOR EACH ROW EXECUTE PROCEDURE processa_emp_audit();

INSERT INTO empregados (nome, salario) VALUES ('Jo�o',1000);
INSERT INTO empregados (nome, salario) VALUES ('Jos�',1500);
INSERT INTO empregados (nome, salario) VALUES ('Maria',250);
UPDATE empregados SET salario = 2500 WHERE nome = 'Maria';
DELETE FROM empregados WHERE nome = 'Jo�o';

SELECT * FROM empregados;

SELECT * FROM empregados_audit;
Outro exemplo:

CREATE TABLE empregados (
codigo serial PRIMARY KEY,
nome varchar NOT NULL,
salario integer
);

CREATE TABLE empregados_audit(
usuario varchar NOT NULL,
data timestamp NOT NULL,
id integer NOT NULL,
coluna text NOT NULL,
valor_antigo text NOT NULL,
valor_novo text NOT NULL
);

CREATE OR REPLACE FUNCTION processa_emp_audit() RETURNS TRIGGER AS $emp_audit$
BEGIN
--
-- N�o permitir atualizar a chave prim�ria
--
IF (NEW.codigo <> OLD.codigo) THEN
RAISE EXCEPTION 'N�o � permitido atualizar o campo codigo';
END IF;
--
-- Inserir linhas na tabela emp_audit para refletir as altera��es
-- realizada na tabela emp.
--
IF (NEW.nome <> OLD.nome) THEN
INSERT INTO emp_audit SELECT current_user, current_timestamp,
NEW.id, 'nome', OLD.nome, NEW.nome;
END IF;
IF (NEW.salario <> OLD.salario) THEN
INSERT INTO emp_audit SELECT current_user, current_timestamp,
NEW.codigo, 'salario', OLD.salario, NEW.salario;
END IF;
RETURN NULL; -- o resultado � ignorado uma vez que este � um gatilho AFTER
END;
$emp_audit$ language plpgsql;

CREATE TRIGGER emp_audit
AFTER UPDATE ON empregados
FOR EACH ROW EXECUTE PROCEDURE processa_emp_audit();

INSERT INTO empregados (nome, salario) VALUES ('Jo�o',1000);
INSERT INTO empregados (nome, salario) VALUES ('Jos�',1500);
INSERT INTO empregados (nome, salario) VALUES ('Maria',2500);
UPDATE empregados SET salario = 2500 WHERE id = 2;
UPDATE empregados SET nome = 'Maria Cec�lia' WHERE id = 3;
UPDATE empregados SET codigo=100 WHERE codigo=1;
ERRO: N�o � permitido atualizar o campo codigo
SELECT * FROM empregados;

SELECT * FROM empregados_audit;

Crie a mesma fun��o que insira o nome da empresa e o nome do cliente retornando o id de ambos
create or replace function empresa_cliente_id(varchar,varchar) returns _int4 as
'
declare
nempresa alias for $1;
ncliente alias for $2;
empresaid integer;
clienteid integer;
begin
insert into empresas(nome) values(nempresa);
insert into clientes(fkempresa,nome) values (currval (''empresas_id_seq''), ncliente);
empresaid := currval(''empresas_id_seq'');
clienteid := currval(''clientes_id_seq'');

return ''{''|| empresaid ||'',''|| clienteid ||''}'';
end;
'
language 'plpgsql';

Crie uma fun��o onde passamos como par�metro o id do cliente e seja retornado o seu nome
create or replace function id_nome_cliente(integer) returns text as
'
declare
r record;
begin
select into r * from clientes where id = $1;
if not found then
raise exception ''Cliente n�o existente !'';
end if;
return r.nome;
end;
'
language 'plpgsql';
Crie uma fun��o que retorne os nome de toda a tabela clientes concatenados em um s� campo
create or replace function clientes_nomes() returns text as
'
declare
x text;
r record;
begin
x:=''Inicio'';
for r in select * from clientes order by id loop
x:= x||'' : ''||r.nome;
end loop;
return x||'' : fim'';
end;
'
language 'plpgsql';

