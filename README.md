1. Análise do Dataset
O conjunto de dados utilizado neste projeto consiste em registros de transações de cartão de crédito provenientes de extratos mensais de fatura. Os dados são anonimizados e representam compras realizadas por titulares de cartão ao longo de um período de 12 meses.
Cada arquivo CSV corresponde a uma fatura mensal e segue a nomenclatura Fatura_AAAA-MM-DD.csv. No total foram analisados 12 arquivos, cobrindo o período de março de 2025 a fevereiro de 2026.
Os arquivos utilizam separador ponto e vírgula (;) e codificação UTF-8, contendo informações sobre data da compra, titular do cartão, estabelecimento, categoria da transação, parcelamento e valores financeiros.
Após a consolidação dos arquivos CSV, foram identificadas aproximadamente:
1945 transações


5 titulares/cartões distintos


36 categorias de transações


426 estabelecimentos diferentes


Esses dados foram utilizados como fonte para o processo de ETL (Extract, Transform, Load) e posteriormente carregados em um Data Warehouse modelado em esquema estrela (Star Schema).
Durante a etapa de transformação foram realizadas as seguintes padronizações:
Conversão de datas do formato DD/MM/AAAA para o tipo DATE


Conversão de valores monetários para tipo numérico


Tratamento de valores ausentes ou representados por "-"


Extração das informações de parcelamento (número da parcela e total de parcelas)


Padronização de categorias inexistentes como "Não categorizado"


Essas transformações permitiram preparar os dados para análise analítica em um Data Warehouse.

2. Desenho do Data Warehouse
Para armazenar os dados de forma otimizada para análises, foi utilizado um modelo dimensional no formato Star Schema.
Esse modelo organiza os dados em:
1 tabela fato


4 tabelas dimensão


A tabela fato contém as medidas numéricas (valores de transação), enquanto as dimensões armazenam os atributos descritivos utilizados para análise.
O modelo final ficou estruturado da seguinte forma:
             DIM_TITULAR
                  |
                  |
DIM_DATA ---- FATO_TRANSACAO ---- DIM_CATEGORIA
                  |
                  |
       DIM_ESTABELECIMENTO
Tabela fato
A tabela fato centraliza todas as transações realizadas pelos cartões.
FATO_TRANSACAO
---------------
id_data (FK)
id_titular (FK)
id_categoria (FK)
id_estabelecimento (FK)
valor_brl
valor_usd
cotacao
parcela_texto
num_parcela
total_parcelas

3. Dicionário de Dados
DIM_DATA
Tabela responsável por armazenar informações relacionadas ao tempo.
Campo
Tipo
Descrição
id_data
Integer (PK)
Identificador da data
data
Date
Data da transação
dia
Integer
Dia do mês
mes
Integer
Mês da transação
trimestre
Integer
Trimestre do ano
ano
Integer
Ano da transação
dia_semana
Varchar
Nome do dia da semana


DIM_TITULAR
Armazena informações do titular do cartão.
Campo
Tipo
Descrição
id_titular
Integer (PK)
Identificador do titular
nome_titular
Varchar
Nome do titular do cartão
final_cartao
Integer
Últimos 4 dígitos do cartão


DIM_CATEGORIA
Representa a categoria da transação.
Campo
Tipo
Descrição
id_categoria
Integer (PK)
Identificador da categoria
nome_categoria
Varchar
Nome da categoria da compra


DIM_ESTABELECIMENTO
Armazena os estabelecimentos onde ocorreram as compras.
Campo
Tipo
Descrição
id_estabelecimento
Integer (PK)
Identificador do estabelecimento
nome_estabelecimento
Varchar
Nome do estabelecimento


FATO_TRANSACAO
Tabela central contendo os eventos de compra.
Campo
Tipo
Descrição
id_data
FK
Referência para DIM_DATA
id_titular
FK
Referência para DIM_TITULAR
id_categoria
FK
Referência para DIM_CATEGORIA
id_estabelecimento
FK
Referência para DIM_ESTABELECIMENTO
valor_brl
Numeric
Valor da transação em reais
valor_usd
Numeric
Valor da transação em dólares
cotacao
Numeric
Cotação utilizada na conversão
parcela_texto
Varchar
Informação textual da parcela
num_parcela
Integer
Número da parcela
total_parcelas
Integer
Total de parcelas


4. Benefícios do Modelo
O modelo dimensional adotado oferece diversas vantagens para análise de dados:
Melhor desempenho em consultas analíticas


Estrutura simplificada para construção de dashboards


Facilidade de agregação de métricas


Suporte a análises temporais e comparativas


Esse modelo permite responder facilmente perguntas de negócio como:
evolução de gastos ao longo do tempo


comparação entre titulares


categorias de maior gasto


estabelecimentos com maior volume de transações

