import pandas as pd
import glob
from sqlalchemy import create_engine

# ---------------------------------------
# CONFIGURAÇÃO DO BANCO
# ---------------------------------------

DB_USER = "postgres"
DB_PASS = "masterkey"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "dw_transacoes_cartao"

engine = create_engine(
    f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ---------------------------------------
# 1 - EXTRACT
# ---------------------------------------

arquivos = glob.glob("Fatura_*.csv")

dfs = []

for arquivo in arquivos:
    print(f"Lendo {arquivo}")

    df_temp = pd.read_csv(
        arquivo,
        sep=";",
        encoding="utf-8"
    )

    dfs.append(df_temp)

df = pd.concat(dfs, ignore_index=True)

print("Registros carregados:", len(df))

# ---------------------------------------
# 2 - TRANSFORM
# ---------------------------------------

# Converter data

df["Data de Compra"] = pd.to_datetime(
    df["Data de Compra"],
    format="%d/%m/%Y"
)

# ---------------------------------------
# FUNÇÃO PARA CONVERTER VALORES
# ---------------------------------------

def converter_valor(col):

    col = col.astype(str)

    col = col.str.replace(",", ".", regex=False)
    col = col.replace("-", None)

    return pd.to_numeric(col, errors="coerce")

# valores monetários

df["Valor (em R$)"] = converter_valor(df["Valor (em R$)"])

if "Valor (em US$)" in df.columns:
    df["Valor (em US$)"] = converter_valor(df["Valor (em US$)"])

if "Cotação (em R$)" in df.columns:
    df["Cotação (em R$)"] = converter_valor(df["Cotação (em R$)"])

# ---------------------------------------
# LIMPEZA DE CATEGORIA
# ---------------------------------------

df["Categoria"] = df["Categoria"].replace("-", "Não categorizado")

# ---------------------------------------
# TRATAR PARCELAS
# ---------------------------------------

def extrair_parcelas(valor):

    if pd.isna(valor):
        return (None, None)

    valor = str(valor)

    if valor.lower() == "única":
        return (1, 1)

    if "/" in valor:
        n, t = valor.split("/")
        return (int(n), int(t))

    return (None, None)


parcelas = df["Parcela"].apply(extrair_parcelas)

df["num_parcela"] = parcelas.apply(lambda x: x[0])
df["total_parcelas"] = parcelas.apply(lambda x: x[1])

# ---------------------------------------
# DIM_DATA
# ---------------------------------------

dim_data = df[["Data de Compra"]].drop_duplicates().copy()

dim_data["dia"] = dim_data["Data de Compra"].dt.day
dim_data["mes"] = dim_data["Data de Compra"].dt.month
dim_data["ano"] = dim_data["Data de Compra"].dt.year
dim_data["trimestre"] = dim_data["Data de Compra"].dt.quarter
dim_data["dia_semana"] = dim_data["Data de Compra"].dt.day_name()

dim_data = dim_data.rename(columns={
    "Data de Compra": "data"
})

# ---------------------------------------
# DIM_TITULAR
# ---------------------------------------

dim_titular = df[[
    "Nome no Cartão",
    "Final do Cartão"
]].drop_duplicates()

dim_titular = dim_titular.rename(columns={
    "Nome no Cartão": "nome_titular",
    "Final do Cartão": "final_cartao"
})

# ---------------------------------------
# DIM_CATEGORIA
# ---------------------------------------

dim_categoria = df[["Categoria"]].drop_duplicates()

dim_categoria = dim_categoria.rename(columns={
    "Categoria": "nome_categoria"
})

# ---------------------------------------
# DIM_ESTABELECIMENTO
# ---------------------------------------

dim_estabelecimento = df[["Descrição"]].drop_duplicates()

dim_estabelecimento = dim_estabelecimento.rename(columns={
    "Descrição": "nome_estabelecimento"
})

# ---------------------------------------
# LOAD DIMENSÕES
# ---------------------------------------

dim_data.to_sql(
    "dim_data",
    engine,
    if_exists="append",
    index=False
)

dim_titular.to_sql(
    "dim_titular",
    engine,
    if_exists="append",
    index=False
)

dim_categoria.to_sql(
    "dim_categoria",
    engine,
    if_exists="append",
    index=False
)

dim_estabelecimento.to_sql(
    "dim_estabelecimento",
    engine,
    if_exists="append",
    index=False
)

print("Dimensões carregadas")

# ---------------------------------------
# CRIAR FATO
# ---------------------------------------

df_fato = df.copy()

# carregar dimensões do banco

dim_data_db = pd.read_sql("SELECT * FROM dim_data", engine)
dim_titular_db = pd.read_sql("SELECT * FROM dim_titular", engine)
dim_categoria_db = pd.read_sql("SELECT * FROM dim_categoria", engine)
dim_estabelecimento_db = pd.read_sql("SELECT * FROM dim_estabelecimento", engine)

# corrigir tipos para merge

dim_data_db["data"] = pd.to_datetime(dim_data_db["data"])
df_fato["Data de Compra"] = pd.to_datetime(df_fato["Data de Compra"])

# ---------------------------------------
# MERGE DIM_DATA
# ---------------------------------------

df_fato = df_fato.merge(
    dim_data_db,
    left_on="Data de Compra",
    right_on="data"
)

# ---------------------------------------
# MERGE DIM_TITULAR
# ---------------------------------------

df_fato = df_fato.merge(
    dim_titular_db,
    left_on=["Nome no Cartão", "Final do Cartão"],
    right_on=["nome_titular", "final_cartao"]
)

# ---------------------------------------
# MERGE DIM_CATEGORIA
# ---------------------------------------

df_fato = df_fato.merge(
    dim_categoria_db,
    left_on="Categoria",
    right_on="nome_categoria"
)

# ---------------------------------------
# MERGE DIM_ESTABELECIMENTO
# ---------------------------------------

df_fato = df_fato.merge(
    dim_estabelecimento_db,
    left_on="Descrição",
    right_on="nome_estabelecimento"
)

# ---------------------------------------
# MONTAR FATO
# ---------------------------------------

fato = df_fato[[
    "id_data",
    "id_titular",
    "id_categoria",
    "id_estabelecimento",
    "Valor (em R$)",
    "Valor (em US$)",
    "Cotação (em R$)",
    "Parcela",
    "num_parcela",
    "total_parcelas"
]]

fato = fato.rename(columns={
    "Valor (em R$)": "valor_brl",
    "Valor (em US$)": "valor_usd",
    "Cotação (em R$)": "cotacao",
    "Parcela": "parcela_texto"
})

# ---------------------------------------
# LOAD FATO
# ---------------------------------------

fato.to_sql(
    "fato_transacao",
    engine,
    if_exists="append",
    index=False
)

print("Fato carregada com sucesso")