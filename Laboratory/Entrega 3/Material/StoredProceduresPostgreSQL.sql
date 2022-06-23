ter, 18/12/2007 - 17:08 — ribafs 
Funções e Triggers Definidas pelo Usuário 

O PostgreSQL oferece quatro tipos de funções:
- Funções escritas em SQL
- Funções em linguagens de procedimento (PL/pgSQL, PL/Tcl, PL/php, PL/Java, etc)
- Funções internas (rount(), now(), max(), count(), etc).
- Funções na linguagem C

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

Para reforçar a segurança é interessante usar o parâmetro SECURITY DEFINER, que especifica que a função será executada com os privilégios do usuário que a criou. 

SECURITY INVOKER indica que a função deve ser executada com os privilégios do usuário que a chamou (padrão). 

SECURITY DEFINER especifica que a função deve ser executada com os privilégios do usuário que a criou.

Uma grande força do PostgreSQL é que ele permite a criação de funções pelo usuário em diversas linguagens: SQL, PlpgSQL, TCL, Perl, Phyton, Ruby.

Para ter exemplos a disposição vamos instalar os do diretório "tutorial" dos fontes do PostgreSQL:

Acessar /usr/local/src/postgresql-8.1.3/src/tutorial e executar:

make install

Feito isso teremos 5 arquivos .sql. 

O syscat.sql traz consultas sobre o catálogo de sistema, o que se chama de metadados (metadata).
O basic.sql e o advanced.sql são consultas SQL.
O complex.sql trata da criação de um tipo de dados pelo usuário e seu uso.
O func.sql traz algumas funções em SQL e outras em C.

Funções em SQL

O que outros SGBDs chamam de stored procedures o PostgreSQL chama de funções, que podem ser em diversas linguagens.

CREATE OR REPLACE FUNCTION olamundo() RETURNS int4
AS 'SELECT 1' LANGUAGE 'sql';

SELECT olamundo() ;

CREATE OR REPLACE FUNCTION add_numeros(nr1 int4, nr2 int4) RETURNS int4
AS 'SELECT $1 + $2' LANGUAGE 'sql';
SELECT add_numeros(300, 700) AS resposta ;

Podemos passar como parâmetro o nome de uma tabela:

CREATE TEMP TABLE empregados (
nome text,
salario numeric,
idade integer,
baia point
);

INSERT INTO empregados VALUES('João',2200,21,point('(1,1)'));
INSERT INTO empregados VALUES('José',4200,30,point('(2,1)'));

CREATE FUNCTION dobrar_salario(empregados) RETURNS numeric AS $$
SELECT $1.salario * 2 AS salario;
$$ LANGUAGE SQL;

SELECT nome, dobrar_salario(emp.*) AS sonho
FROM empregados
WHERE empregados.baia ~= point '(2,1)';

Algumas vezes é prático gerar o valor do argumento composto em tempo de execução. Isto pode ser feito através da construção ROW. 

SELECT nome, dobrar_salario(ROW(nome, salario*1.1, idade, baia)) AS sonho
FROM empregados;

Função que retorna um tipo composto. Função que retorna uma única linha da tabela empregados:

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

Funções SQL como fontes de tabelas

CREATE TEMP TABLE teste (testeid int, testesubid int, testename text);
INSERT INTO teste VALUES (1, 1, 'João');
INSERT INTO teste VALUES (1, 2, 'José');
INSERT INTO teste VALUES (2, 1, 'Maria');

CREATE FUNCTION getteste(int) RETURNS teste AS $$
SELECT * FROM teste WHERE testeid = $1;
$$ LANGUAGE SQL;

SELECT *, upper(testename) FROM getteste(1) AS t1;

Tabelas Temporárias - criar tabelas temporárias (TEMP), faz com que o servidor se encarregue de removê-la (o que faz logo que a conexão seja encerrada).

CREATE TEMP TABLE nometabela (campo tipo);

Funções SQL retornando conjunto

CREATE FUNCTION getteste(int) RETURNS SETOF teste AS $$
SELECT * FROM teste WHERE testeid = $1;
$$ LANGUAGE SQL;

SELECT * FROM getteste(1) AS t1;

Funções SQL polimórficas
As funções SQL podem ser declaradas como recebendo e retornando os tipos polimórficos anyelement e anyarray.

CREATE FUNCTION constroi_matriz(anyelement, anyelement) RETURNS anyarray AS $$
SELECT ARRAY[$1, $2];
$$ LANGUAGE SQL;

SELECT constroi_matriz(1, 2) AS intarray, constroi_matriz('a'::text, 'b') AS textarray;

CREATE FUNCTION eh_maior(anyelement, anyelement) RETURNS boolean AS $$
SELECT $1 > $2;
$$ LANGUAGE SQL;
SELECT eh_maior(1, 2);
Mais detalhes no capítulo 31 do manual.
7.2 - Funções em PlpgSQL

As funções em linguagens procedurais no PostgreSQL, como a PlpgSQL são correspondentes ao que se chama comumente de Stored Procedures.

Por default o PostgreSQL só traz suporte às funções na linguagem SQL. Para dar suporte à funções em outras linguagens temos que efetuar procedimentos como a seguir.
Para que o banco postgres tenha suporte à linguagem de procedimento PlPgSQL executamos na linha de comando como super usuário do PostgreSQL:

createlang plpgsql –U nomeuser nomebanco
A PlpgSQL é a linguagem de procedimentos armazenados mais utilizada no PostgreSQL, devido ser a mais madura e com mais recursos.

CREATE FUNCTION func_escopo() RETURNS integer AS $$
DECLARE
quantidade integer := 30;
BEGIN
RAISE NOTICE 'Aqui a quantidade é %', quantidade; -- A quantidade aqui é 30
quantidade := 50;
--
-- Criar um sub-bloco
--
DECLARE
quantidade integer := 80;
BEGIN
RAISE NOTICE 'Aqui a quantidade é %', quantidade; -- A quantidade aqui é 80
END;
RAISE NOTICE 'Aqui a quantidade é %', quantidade; -- A quantidade aqui é 50
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

Utilização de tipo composto:
CREATE FUNCTION mesclar_campos(t_linha nome_da_tabela) RETURNS text AS $$
DECLARE
t2_linha nome_tabela2%ROWTYPE;
BEGIN
SELECT * INTO t2_linha FROM nome_tabela2 WHERE ... ;
RETURN t_linha.f1 || t2_linha.f3 || t_linha.f5 || t2_linha.f7;
END;
$$ LANGUAGE plpgsql;

SELECT mesclar_campos(t.*) FROM nome_da_tabela t WHERE ... ;

Temos uma tabela (datas) com dois campos (data e hora) e queremos usar uma função para manipular os dados desta tabela:

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
Mais Detalhes no capítulo 35 do manual oficial.

Funções que Retornam Conjuntos de Registros (SETS)
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

Funções que retornam Registro
Para criar funções em plpgsql que retornem um registro, antes precisamos criar uma variável composta do tipo ROWTYPE, descrevendo o registro (tupla) de saída
da função.

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

Funções que Retornam Conjunto de Registros (SETOF, Result Set)
Também requerem a criação de uma variável (tipo definidopelo user)

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

Capítulo 32 do manual oficial. e:
http://pgdocptbr.sourceforge.net/pg80/sql-createtrigger.html
Até a versão atual não existe como criar funções de gatilho na linguagem SQL.

Ocorrem em eventos que acontecem em tabelas.
Uma função de gatilho pode ser criada para executar antes (BEFORE) ou após (AFTER) as consultas INSERT, UPDATE OU DELETE, uma vez para cada registro (linha) modificado ou por instrução SQL. Logo que ocorre um desses eventos do gatilho a função do gatilho é disparada automaticamente para tratar o evento.

A função de gatilho deve ser declarada como uma função que não recebe argumentos e que retorna o tipo TRIGGER.
Após criar a função de gatilho, estabelecemos o gatilho pelo comando CREATE TRIGGER. Uma função de gatilho pode ser utilizada por vários gatilhos.

As funções de gatilho chamadas por gatilhos-por-instrução devem sempre retornar NULL. 

As funções de gatilho chamadas por gatilhos-por-linha podem retornar uma linha da tabela (um valor do tipo HeapTuple) para o executor da chamada, se assim o decidirem. 

Sintaxe:
CREATE TRIGGER nome { BEFORE | AFTER } { evento [ OR ... ] }
ON tabela [ FOR [ EACH ] { ROW | STATEMENT } ]
EXECUTE PROCEDURE nome_da_função ( argumentos )

O gatilho fica associado à tabela especificada e executa a função especificada nome_da_função quando determinados eventos ocorrerem.

O gatilho pode ser especificado para disparar antes de tentar realizar a operação na linha (antes das restrições serem verificadas e o comando INSERT, UPDATE ou DELETE ser tentado), ou após a operação estar completa (após as restrições serem verificadas e o INSERT, UPDATE ou DELETE ter completado). 

evento
Um entre INSERT, UPDATE ou DELETE; especifica o evento que dispara o gatilho. Vários eventos podem ser especificados utilizando OR. 

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
-- Verificar se foi fornecido o nome e o salário do empregado
IF NEW.nome IS NULL THEN
RAISE EXCEPTION 'O nome do empregado não pode ser nulo';
END IF;
IF NEW.salario IS NULL THEN
RAISE EXCEPTION '% não pode ter um salário nulo', NEW.nome;
END IF;

-- Quem paga para trabalhar?
IF NEW.salario < 0 THEN
RAISE EXCEPTION '% não pode ter um salário negativo', NEW.nome;
END IF;

-- Registrar quem alterou a folha de pagamento e quando
NEW.ultima_data := 'now';
NEW.ultimo_usuario := current_user;
RETURN NEW;
END;
$empregados_gatilho$ LANGUAGE plpgsql;
CREATE TRIGGER empregados_gatilho BEFORE INSERT OR UPDATE ON empregados
FOR EACH ROW EXECUTE PROCEDURE empregados_gatilho();

INSERT INTO empregados (codigo,nome, salario) VALUES (5,'João',1000);
INSERT INTO empregados (codigo,nome, salario) VALUES (6,'José',1500);
INSERT INTO empregados (codigo,nome, salario) VALUES (7,'Maria',2500);

SELECT * FROM empregados;

INSERT INTO empregados (codigo,nome, salario) VALUES (5,NULL,1000);
NEW – Para INSERT e UPDATE
OLD – Para DELETE

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
-- Cria uma linha na tabela emp_audit para refletir a operação
-- realizada na tabela emp. Utiliza a variável especial TG_OP
-- para descobrir a operação sendo realizada.
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
RETURN NULL; -- o resultado é ignorado uma vez que este é um gatilho AFTER
END;
$emp_audit$ language plpgsql;

CREATE TRIGGER emp_audit
AFTER INSERT OR UPDATE OR DELETE ON empregados
FOR EACH ROW EXECUTE PROCEDURE processa_emp_audit();

INSERT INTO empregados (nome, salario) VALUES ('João',1000);
INSERT INTO empregados (nome, salario) VALUES ('José',1500);
INSERT INTO empregados (nome, salario) VALUES ('Maria',250);
UPDATE empregados SET salario = 2500 WHERE nome = 'Maria';
DELETE FROM empregados WHERE nome = 'João';

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
-- Não permitir atualizar a chave primária
--
IF (NEW.codigo <> OLD.codigo) THEN
RAISE EXCEPTION 'Não é permitido atualizar o campo codigo';
END IF;
--
-- Inserir linhas na tabela emp_audit para refletir as alterações
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
RETURN NULL; -- o resultado é ignorado uma vez que este é um gatilho AFTER
END;
$emp_audit$ language plpgsql;

CREATE TRIGGER emp_audit
AFTER UPDATE ON empregados
FOR EACH ROW EXECUTE PROCEDURE processa_emp_audit();

INSERT INTO empregados (nome, salario) VALUES ('João',1000);
INSERT INTO empregados (nome, salario) VALUES ('José',1500);
INSERT INTO empregados (nome, salario) VALUES ('Maria',2500);
UPDATE empregados SET salario = 2500 WHERE id = 2;
UPDATE empregados SET nome = 'Maria Cecília' WHERE id = 3;
UPDATE empregados SET codigo=100 WHERE codigo=1;
ERRO: Não é permitido atualizar o campo codigo
SELECT * FROM empregados;

SELECT * FROM empregados_audit;

Crie a mesma função que insira o nome da empresa e o nome do cliente retornando o id de ambos
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

Crie uma função onde passamos como parâmetro o id do cliente e seja retornado o seu nome
create or replace function id_nome_cliente(integer) returns text as
'
declare
r record;
begin
select into r * from clientes where id = $1;
if not found then
raise exception ''Cliente não existente !'';
end if;
return r.nome;
end;
'
language 'plpgsql';
Crie uma função que retorne os nome de toda a tabela clientes concatenados em um só campo
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

