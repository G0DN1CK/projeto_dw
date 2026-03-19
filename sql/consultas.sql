

-- 1) Gasto total por titular por mês
SELECT 
    t.nome_titular,
    d.ano,
    d.mes,
    SUM(f.valor_brl) AS gasto_total
FROM fato_transacao f
JOIN dim_titular t ON f.id_titular = t.id_titular
JOIN dim_data d ON f.id_data = d.id_data
WHERE f.valor_brl > 0
GROUP BY t.nome_titular, d.ano, d.mes
ORDER BY t.nome_titular, d.ano, d.mes;

-- =========================================

-- 2) Gasto por categoria (Top 10)
SELECT 
    c.nome_categoria,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_categoria c ON f.id_categoria = c.id_categoria
WHERE f.valor_brl > 0
GROUP BY c.nome_categoria
ORDER BY total_gasto DESC
LIMIT 10;

-- =========================================

-- 3) Evolução mensal do total gasto
SELECT 
    d.ano,
    d.mes,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_data d ON f.id_data = d.id_data
WHERE f.valor_brl > 0
GROUP BY d.ano, d.mes
ORDER BY d.ano, d.mes;

-- =========================================

-- 4) Comparativo entre titulares
SELECT 
    t.nome_titular,
    COUNT(*) AS qtd_transacoes,
    AVG(f.valor_brl) AS valor_medio,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_titular t ON f.id_titular = t.id_titular
WHERE f.valor_brl > 0
GROUP BY t.nome_titular
ORDER BY total_gasto DESC;

-- =========================================

-- 5) Principais estabelecimentos
SELECT 
    e.nome_estabelecimento,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_estabelecimento e 
ON f.id_estabelecimento = e.id_estabelecimento
WHERE f.valor_brl > 0
GROUP BY e.nome_estabelecimento
ORDER BY total_gasto DESC
LIMIT 10;

-- =========================================

-- 6) Comportamento de parcelamento
SELECT 
    CASE 
        WHEN f.total_parcelas = 1 THEN 'À vista'
        WHEN f.total_parcelas > 1 THEN 'Parcelado'
        ELSE 'Não informado'
    END AS tipo_pagamento,
    COUNT(*) AS quantidade,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
WHERE f.valor_brl > 0
GROUP BY tipo_pagamento;

-- =========================================

-- 7) Dia da semana com mais transações (quantidade)
SELECT 
    d.dia_semana,
    COUNT(*) AS total_transacoes
FROM fato_transacao f
JOIN dim_data d ON f.id_data = d.id_data
WHERE f.valor_brl > 0
GROUP BY d.dia_semana
ORDER BY total_transacoes DESC;

-- =========================================

-- 7b) Dia da semana com maior volume financeiro
SELECT 
    d.dia_semana,
    SUM(f.valor_brl) AS volume_total
FROM fato_transacao f
JOIN dim_data d ON f.id_data = d.id_data
WHERE f.valor_brl > 0
GROUP BY d.dia_semana
ORDER BY volume_total DESC;

-- =========================================

-- 8) Total de estornos
SELECT 
    SUM(f.valor_brl) AS total_estornos
FROM fato_transacao f
WHERE f.valor_brl < 0;

-- =========================================

-- 8b) Estornos por titular
SELECT 
    t.nome_titular,
    SUM(f.valor_brl) AS total_estorno
FROM fato_transacao f
JOIN dim_titular t ON f.id_titular = t.id_titular
WHERE f.valor_brl < 0
GROUP BY t.nome_titular
ORDER BY total_estorno;

-- =========================================

-- 8c) Estornos por categoria
SELECT 
    c.nome_categoria,
    SUM(f.valor_brl) AS total_estorno
FROM fato_transacao f
JOIN dim_categoria c ON f.id_categoria = c.id_categoria
WHERE f.valor_brl < 0
GROUP BY c.nome_categoria
ORDER BY total_estorno;

-- =========================================

-- 9) Ticket médio por categoria
SELECT 
    c.nome_categoria,
    AVG(f.valor_brl) AS ticket_medio
FROM fato_transacao f
JOIN dim_categoria c ON f.id_categoria = c.id_categoria
WHERE f.valor_brl > 0
GROUP BY c.nome_categoria
ORDER BY ticket_medio DESC;

-- =========================================

-- 10) Crescimento mês a mês (com comparação)
SELECT 
    d.ano,
    d.mes,
    SUM(f.valor_brl) AS total_gasto,
    LAG(SUM(f.valor_brl)) OVER (ORDER BY d.ano, d.mes) AS mes_anterior
FROM fato_transacao f
JOIN dim_data d ON f.id_data = d.id_data
WHERE f.valor_brl > 0
GROUP BY d.ano, d.mes;

-- =========================================