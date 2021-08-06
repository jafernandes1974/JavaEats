-- vista cliente
CREATE VIEW v_cliente AS
    SELECT 
        *
    FROM
        utilizador
            JOIN
        cliente ON util_id = id_util;

SELECT 
    *
FROM
    v_cliente;

-- vista estafeta
CREATE VIEW v_estafeta AS
    SELECT 
        *
    FROM
        utilizador
            JOIN
        estafeta ON util_id = id_util;

SELECT 
    *
FROM
    v_estafeta;

-- vista estabelecimento

CREATE VIEW v_estabelecimento AS
    SELECT 
        *
    FROM
        utilizador
            JOIN
        estabelecimento ON util_id = id_util;
 
SELECT 
    *
FROM
    v_estabelecimento;
 
-- lista de concelhos servidos pelos estabelecimentos

SELECT 
    util_nome, conc_nome
FROM
    v_estabelecimento
        JOIN
    estabelecimento_serve_concelho ON estab_id = id_estab
        JOIN
    concelho ON conc_id = id_conc;
    
-- lista de concelhos servidos pelos estafetas;

SELECT 
    util_nome, conc_nome
FROM
    v_estafeta
        JOIN
    estafeta_entrega_concelho ON estaf_id = id_estaf
        JOIN
    concelho ON conc_id = id_conc;
    
    
-- vista de produtos servidos pelos estabelecimentos

create view lista_produtos_estabelecimentos as 
select prod_id, prod_nome, prod_descricao, estab_id, util_nome from v_estabelecimento join produto  on estab_id= id_estab
order by prod_id;

-- lista de estabelecimentos que servem ananás

select util_nome from lista_produtos_estabelecimentos 
where prod_descricao like "%ananás%"
group by util_nome;

-- lista de encomendas feitas pelos clientes

create view v_encomendas_clientes as
select * from v_cliente join encomenda  on cli_id=id_cli;   

select enc_id, util_nome, enc_data_entrega, enc_preco_total from  v_encomendas_clientes
order by enc_id;

-- lista dos gastos totais de cada cliente

select util_nome, sum(enc_preco_total) from  v_encomendas_clientes
group by util_nome
order by util_nome;
 
-- lista dos produtos de cada encomenda

create view produtos_encomenda as
select enc_id, enc_data_entrega, id_estaf, id_cli, id_prod, enc_prod_quantidade, enc_prod_preco_venda from encomenda join encomenda_contem_produto on enc_id=id_enc;


-- lista dos produtos de cada encomenda com pormenores

SELECT 
    enc_id,
    enc_data_entrega,
    e.util_nome,
    c.util_nome,
    enc_prod_quantidade,
    enc_prod_preco_venda,
    prod_nome
FROM
    produtos_encomenda
        JOIN
    produto ON id_prod = prod_id
    join
    v_estafeta as e on estaf_id=id_estaf
    join
    v_cliente as c on c.cli_id=id_cli;

 
 SELECT 
    cli_nome AS 'Nome',
    cli_morada AS 'Morada',
    cli_email AS 'Email',
    cli_telemovel AS 'Telefone',
    cli_nif AS 'NIF',
    cli_cartao_credito AS 'Cartão'
FROM
    listar_clientes
    where cli_nome="Tiago Landeiroto";
 
