CREATE TABLE "lideres_politicos" (
  "id" SERIAL PRIMARY KEY,
  "nome_l" varchar,
  "apoios" varchar,
  "codigo_chefe_militar" varchar
);

CREATE TABLE "grupos_armados_lideres_politicos" (
  "grupo_armado_id" int,
  "lider_politico_id" int
);

CREATE TABLE "lideres_politicos_organizacoes_m" (
  "lider_politico_id" int,
  "organizacoes_id" int
);

CREATE TABLE "chefes_militares" (
  "codigo_chef" int PRIMARY KEY,
  "faixa" varchar
);

CREATE TABLE "divisoes_chefes_militares" (
  "divisao_id" int,
  "chefe_militar_id" int
);

CREATE TABLE "organizacoes_m" (
  "codigo_org" int PRIMARY KEY,
  "nome_org" varchar,
  "tipo_ajuda" varchar,
  "num_pessoas" int,
  "tipo" char
);

CREATE TABLE "organizacoes_organizacoes" (
  "organizacao_mae_id" int,
  "organizacoes_filha_id" int
);

CREATE TABLE "divisoes" (
  "nro_divisao" int PRIMARY KEY,
  "num_baixas_d" int,
  "barcos" int,
  "tanques" int,
  "avioes" int,
  "homens" int
);

CREATE TABLE "grupos_armados" (
  "codigo_g" int PRIMARY KEY,
  "nome_grupo" varchar,
  "num_baixas_g" int,
  "divisao_nro" int
);

CREATE TABLE "conflitos" (
  "codigo" int PRIMARY KEY,
  "nome" varchar,
  "pais" varchar,
  "num_mortos" int,
  "num_feridos" int,
  "tipo" varchar
);

CREATE TABLE "regioes" (
  "codigo" int,
  "regiao" varchar
);

CREATE TABLE "religioes" (
  "codigo" int,
  "religiao" varchar
);

CREATE TABLE "mat_primas" (
  "codigo" int,
  "mat_prima" varchar
);

CREATE TABLE "etnias" (
  "codigo" int,
  "etnia" varchar
);

CREATE TABLE "conflitos_grupos_armados" (
  "grupo_armado_id" int,
  "conflito_id" int,
  "de_grupo" timestamp,
  "ds_grupo" timestamp
);

CREATE TABLE "conflitos_organizacoes" (
  "conflito_id" int,
  "organizacao_id" int,
  "de_media" timestamp,
  "ds_media" timestamp
);

CREATE TABLE "tipo_armas" (
  "nome_arma" varchar PRIMARY KEY,
  "indicador" int
);

CREATE TABLE "traficantes" (
  "nome_traf" varchar PRIMARY KEY
);

CREATE TABLE "tipo_armas_traficantes" (
  "nome_arma" varchar,
  "nome_traf" varchar,
  "quantidade" int
);

CREATE TABLE "grupos_armados_tipo_armas" (
  "grupo_armado_id" int,
  "tipo_arma_id" int,
  "traficante_id" int,
  "num_armas" int
);

ALTER TABLE "chefes_militares" ADD FOREIGN KEY ("codigo_chef") REFERENCES "lideres_politicos" ("codigo_chefe_militar");

ALTER TABLE "grupos_armados_lideres_politicos" ADD FOREIGN KEY ("grupo_armado_id") REFERENCES "grupos_armados" ("codigo_g");

ALTER TABLE "grupos_armados_lideres_politicos" ADD FOREIGN KEY ("lider_politico_id") REFERENCES "lideres_politicos" ("id");

ALTER TABLE "lideres_politicos_organizacoes_m" ADD FOREIGN KEY ("lider_politico_id") REFERENCES "lideres_politicos" ("id");

ALTER TABLE "lideres_politicos_organizacoes_m" ADD FOREIGN KEY ("organizacoes_id") REFERENCES "organizacoes_m" ("codigo_org");

ALTER TABLE "divisoes_chefes_militares" ADD FOREIGN KEY ("divisao_id") REFERENCES "divisoes" ("nro_divisao");

ALTER TABLE "divisoes_chefes_militares" ADD FOREIGN KEY ("chefe_militar_id") REFERENCES "chefes_militares" ("codigo_chef");

ALTER TABLE "organizacoes_organizacoes" ADD FOREIGN KEY ("organizacao_mae_id") REFERENCES "organizacoes_m" ("codigo_org");

ALTER TABLE "organizacoes_organizacoes" ADD FOREIGN KEY ("organizacoes_filha_id") REFERENCES "organizacoes_m" ("codigo_org");

ALTER TABLE "divisoes" ADD FOREIGN KEY ("nro_divisao") REFERENCES "grupos_armados" ("divisao_nro");

ALTER TABLE "conflitos" ADD FOREIGN KEY ("codigo") REFERENCES "regioes" ("codigo");

ALTER TABLE "conflitos" ADD FOREIGN KEY ("codigo") REFERENCES "religioes" ("codigo");

ALTER TABLE "conflitos" ADD FOREIGN KEY ("codigo") REFERENCES "mat_primas" ("codigo");

ALTER TABLE "conflitos" ADD FOREIGN KEY ("codigo") REFERENCES "etnias" ("codigo");

ALTER TABLE "conflitos_grupos_armados" ADD FOREIGN KEY ("grupo_armado_id") REFERENCES "grupos_armados" ("codigo_g");

ALTER TABLE "conflitos_grupos_armados" ADD FOREIGN KEY ("conflito_id") REFERENCES "conflitos" ("codigo");

ALTER TABLE "conflitos_organizacoes" ADD FOREIGN KEY ("conflito_id") REFERENCES "conflitos" ("codigo");

ALTER TABLE "conflitos_organizacoes" ADD FOREIGN KEY ("organizacao_id") REFERENCES "organizacoes_m" ("codigo_org");

ALTER TABLE "tipo_armas_traficantes" ADD FOREIGN KEY ("nome_arma") REFERENCES "tipo_armas" ("nome_arma");

ALTER TABLE "tipo_armas_traficantes" ADD FOREIGN KEY ("nome_traf") REFERENCES "traficantes" ("nome_traf");

ALTER TABLE "grupos_armados_tipo_armas" ADD FOREIGN KEY ("grupo_armado_id") REFERENCES "grupos_armados" ("codigo_g");

ALTER TABLE "grupos_armados_tipo_armas" ADD FOREIGN KEY ("tipo_arma_id") REFERENCES "tipo_armas" ("nome_arma");

ALTER TABLE "grupos_armados_tipo_armas" ADD FOREIGN KEY ("traficante_id") REFERENCES "traficantes" ("nome_traf");
