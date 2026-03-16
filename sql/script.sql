CREATE TABLE dim_titular (
    id_titular SERIAL PRIMARY KEY,
    nome_titular VARCHAR(200) NOT NULL,
    final_cartao INTEGER NOT NULL
);

CREATE TABLE dim_data (
    id_data SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    dia INTEGER,
    mes INTEGER,
    trimestre INTEGER,
    ano INTEGER,
    dia_semana VARCHAR(15)
);

CREATE TABLE dim_categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(200)
);

CREATE TABLE dim_estabelecimento (
    id_estabelecimento SERIAL PRIMARY KEY,
    nome_estabelecimento VARCHAR(255)
);

CREATE TABLE fato_transacao (

    id_transacao SERIAL PRIMARY KEY,

    id_data INTEGER NOT NULL,
    id_titular INTEGER NOT NULL,
    id_categoria INTEGER,
    id_estabelecimento INTEGER,

    valor_brl NUMERIC(12,2),
    valor_usd NUMERIC(12,2),
    cotacao NUMERIC(10,4),

    parcela_texto VARCHAR(20),
    num_parcela INTEGER,
    total_parcelas INTEGER,

    CONSTRAINT fk_data
        FOREIGN KEY (id_data)
        REFERENCES dim_data(id_data),

    CONSTRAINT fk_titular
        FOREIGN KEY (id_titular)
        REFERENCES dim_titular(id_titular),

    CONSTRAINT fk_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES dim_categoria(id_categoria),

    CONSTRAINT fk_estabelecimento
        FOREIGN KEY (id_estabelecimento)
        REFERENCES dim_estabelecimento(id_estabelecimento)

);

CREATE INDEX idx_fato_data ON fato_transacao(id_data);
CREATE INDEX idx_fato_categoria ON fato_transacao(id_categoria);
CREATE INDEX idx_fato_titular ON fato_transacao(id_titular);