# Projeto Data Warehouse – Transações de Cartão

## Descrição

Este projeto tem como objetivo a construção de um **Data Warehouse** para análise de transações de cartão de crédito, utilizando dados provenientes de faturas em formato CSV.

O sistema foi desenvolvido seguindo o processo de **ETL (Extract, Transform, Load)** e modelado com base no conceito de **Star Schema**, permitindo análises eficientes e suporte à tomada de decisão.

---

## Processo ETL

O pipeline de dados foi implementado em Python utilizando as bibliotecas `pandas` e `sqlalchemy`.

### 🔹 Extract

* Leitura automática de múltiplos arquivos CSV (`Fatura_*.csv`)
* Consolidação dos dados em um único DataFrame

### 🔹 Transform

* Conversão de datas para formato padrão
* Tratamento de valores monetários (R$ e US$)
* Limpeza de categorias inválidas
* Extração de informações de parcelamento
* Padronização dos dados

### 🔹 Load

* Carga das dimensões no banco PostgreSQL
* Criação da tabela fato com chaves estrangeiras
* Armazenamento estruturado para análise

---

## Modelagem – Star Schema

O Data Warehouse foi modelado utilizando o padrão dimensional:


Se quiser uma versão ainda mais simples, em ASCII, para caso o Mermaid não renderize no seu README, use esta:

```markdown
## Modelagem – Star Schema

```text
                    +----------------------+
                    |       dim_data       |
                    +----------------------+
                    | id_data (PK)         |
                    | data                 |
                    | dia                  |
                    | mes                  |
                    | ano                  |
                    | trimestre            |
                    | dia_semana           |
                    +----------------------+
                               |
                               |
                               |
+----------------------+       |       +----------------------+
|    dim_titular       |       |       |    dim_categoria     |
+----------------------+       |       +----------------------+
| id_titular (PK)      |       |       | id_categoria (PK)    |
| nome_titular         |       |       | nome_categoria       |
| final_cartao         |       |       +----------------------+
+----------------------+       |
                               |
                               v
                  +-------------------------------+
                  |        fato_transacao         |
                  +-------------------------------+
                  | id_transacao (PK)             |
                  | id_data (FK)                  |
                  | id_titular (FK)               |
                  | id_categoria (FK)             |
                  | id_estabelecimento (FK)       |
                  | valor_brl                     |
                  | valor_usd                     |
                  | cotacao                       |
                  | parcela_texto                 |
                  | num_parcela                   |
                  | total_parcelas                |
                  +-------------------------------+
                               ^
                               |
                               |
                    +--------------------------+
                    |   dim_estabelecimento    |
                    +--------------------------+
                    | id_estabelecimento (PK)  |
                    | nome_estabelecimento     |
                    +--------------------------+


## Consultas Analíticas

O projeto inclui consultas SQL para análise de dados, como:

*  Gasto total por titular por mês
*  Top 10 categorias de gasto
*  Evolução mensal dos gastos
*  Comparativo entre titulares
*  Principais estabelecimentos
*  Análise de parcelamento
*  Distribuição por dia da semana
*  Análise de estornos e créditos
*  Ticket médio por categoria

---

##  Business Intelligence

O Data Warehouse foi preparado para integração com ferramentas de BI como:

* Power BI
* Metabase

Permitindo a criação de dashboards com:

* Indicadores de consumo
* Análises temporais
* Comportamento de clientes
* Padrões de gastos

---

##  Tecnologias Utilizadas

* Python (pandas, sqlalchemy)
* PostgreSQL
* SQL
* Git / GitHub

---

##  Estrutura do Projeto

```
projeto_dw/
│
├── data/                 # Arquivos CSV de entrada
├── sql/                  # Consultas analíticas
├── docs/                 # Diagramas e imagens
├── etl_dw.py             # Script ETL
├── README.md             # Documentação
```

---

##  Insights Possíveis

A partir do Data Warehouse, é possível identificar:

* Categorias com maior impacto financeiro
* Comportamento de consumo por titular
* Tendências ao longo do tempo
* Frequência de compras parceladas
* Impacto de estornos e créditos

---

##  Objetivo do Projeto

Demonstrar a aplicação prática de conceitos de:

* Data Warehouse
* Modelagem dimensional
* ETL
* Análise de dados
* Business Intelligence

---

##  Conclusão

O projeto transforma dados brutos de faturas em um modelo estruturado e analítico, permitindo a exploração eficiente das informações e geração de insights relevantes para tomada de decisão.

---
