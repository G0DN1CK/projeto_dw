
 --1️ Gasto total por titular no período e por mês--
SELECT 
    t.nome_titular,
    d.ano,
    d.mes,
    SUM(f.valor_brl) AS gasto_total
FROM fato_transacao f
JOIN dim_titular t 
ON f.id_titular = t.id_titular
JOIN dim_data d 
ON f.id_data = d.id_data
WHERE f.valor_brl > 0
GROUP BY t.nome_titular, d.ano, d.mes
ORDER BY t.nome_titular, d.ano, d.mes;
--utilizei where pois quando se tem estornos na fatura entra valor negativo--


--Filtrar por período (exemplo):--
WHERE d.ano = 2023

---

--2 Gasto por categoria (Top 10)--
SELECT 
    c.nome_categoria,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_categoria c
ON f.id_categoria = c.id_categoria
GROUP BY c.nome_categoria
ORDER BY total_gasto DESC
LIMIT 10;

---

--3️ Evolução mensal do total gasto (série temporal)--
SELECT 
    d.ano,
    d.mes,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_data d
ON f.id_data = d.id_data
GROUP BY d.ano, d.mes
ORDER BY d.ano, d.mes;

---

--4️ Comparativo entre titulares--

--Quantidade + valor médio + total gasto.--
SELECT 
    t.nome_titular,
    COUNT(f.id_data) AS qtd_transacoes,
    AVG(f.valor_brl) AS valor_medio_transacao,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_titular t
ON f.id_titular = t.id_titular
GROUP BY t.nome_titular
ORDER BY total_gasto DESC;

---

--5️ Principais estabelecimentos por valor--
SELECT 
    e.nome_estabelecimento,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
JOIN dim_estabelecimento e
ON f.id_estabelecimento = e.id_estabelecimento
GROUP BY e.nome_estabelecimento
ORDER BY total_gasto DESC
LIMIT 10;

---

--6️ Comportamento de parcelamento--

--(À vista vs parcelado)--
SELECT 
    CASE 
        WHEN f.total_parcelas = 1 THEN 'À vista'
        ELSE 'Parcelado'
    END AS tipo_pagamento,
    COUNT(*) AS quantidade_transacoes,
    SUM(f.valor_brl) AS total_gasto
FROM fato_transacao f
GROUP BY tipo_pagamento;

---

--7️ Dia da semana com mais transações--

--Quantidade de transações:--
SELECT 
    d.dia_semana,
    COUNT(*) AS total_transacoes
FROM fato_transacao f
JOIN dim_data d
ON f.id_data = d.id_data
GROUP BY d.dia_semana
ORDER BY total_transacoes DESC;

--Maior volume financeiro:--
SELECT 
    d.dia_semana,
    SUM(f.valor_brl) AS volume_financeiro
FROM fato_transacao f
JOIN dim_data d
ON f.id_data = d.id_data
GROUP BY d.dia_semana
ORDER BY volume_financeiro DESC;

---

--8️ Estornos e créditos (impacto)--

--Total de estornos--
SELECT 
    SUM(valor_brl) AS total_estornos
FROM fato_transacao
WHERE valor_brl < 0;

---

--Impacto por titular--
SELECT 
    t.nome_titular,
    SUM(f.valor_brl) AS impacto
FROM fato_transacao f
JOIN dim_titular t
ON f.id_titular = t.id_titular
WHERE f.valor_brl < 0
GROUP BY t.nome_titular
ORDER BY impacto;

---

--Impacto por categoria--
SELECT 
    c.nome_categoria,
    SUM(f.valor_brl) AS impacto
FROM fato_transacao f
JOIN dim_categoria c
ON f.id_categoria = c.id_categoria
WHERE f.valor_brl < 0
GROUP BY c.nome_categoria
ORDER BY impacto; 

---

-- Consulta extra)--

--### Ticket médio por categoria--
SELECT 
    c.nome_categoria,
    AVG(f.valor_brl) AS ticket_medio
FROM fato_transacao f
JOIN dim_categoria c
ON f.id_categoria = c.id_categoria
GROUP BY c.nome_categoria
ORDER BY ticket_medio DESC;

---
