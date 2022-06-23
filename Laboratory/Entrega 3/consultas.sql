-- 2.b1)
SELECT ((SELECT COUNT(DISTINCT codigo) FROM conflitos WHERE tipo = 'Religioso')
        (SELECT COUNT(DISTINCT codigo) FROM conflitos WHERE tipo = 'Econômico')
        (SELECT COUNT(DISTINCT codigo) FROM conflitos WHERE tipo = 'Territorial')
        (SELECT COUNT(DISTINCT codigo) FROM conflitos WHERE tipo = 'Étnico'));

-- 2.b2)
SELECT traficantes.nome_traficante, grupos_armados.nome_grupo, nome_arma
FROM fornece 
JOIN traficantes ON id_traficante = traficantes.id_traficante
JOIN grupos_armados ON codigo_grupo = grupos_armados.id
WHERE nome_arma = 'Barret M82' OR nome_arma = 'M200 intervention';

-- 2.b3)
SELECT nome, num_mortos
FROM conflitos ORDER BY num_mortos DESC LIMIT 5;

-- 2.b4)
SELECT nome_org, COUNT(*) as num_intermed
FROM organizacoes_m
JOIN EntraMed ON organizacoes_m.codigo_org = EntraMed.codigo_org
GROUP BY EntraMed.codigo_org
HAVING COUNT (*)
ORDER BY num_intermed DESC LIMIT 5;

-- 2.b5)
SELECT codigo_grupo, SUM(num_armas) as total
FROM fornece
GROUP BY codigo_grupo
ORDER BY total DESC LIMIT 5;

-- 2.b6)
SELECT regiao, COUNT(codigo) as count_conf
FROM conflitos
JOIN ConfRegiao ON conflitos.codigo = ConfRegiao.conflito_id
JOIN ConfRelig ON conflitos.codigo = ConfRelig.conflito_id
GROUP BY regiao
ORDER BY count_conf DESC LIMIT 1;