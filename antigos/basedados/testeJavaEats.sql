-- cliente consultar estabelecimentos que servem no seu concelho (Almada)
SELECT 
    estab_logo AS 'Logo',
    estab_nome AS 'Nome',
    estab_tipo_cozinha AS 'Tipo de cozinha',
    estab_horario AS 'horário de funcionamento'
FROM
    listar_estabelecimentos
        JOIN
    estabelecimento_serve_concelho ON estab_id = id_estab
WHERE
    id_conc = 1503;

-- cliente consultar produtos de um estabelecimento (PizzaHut)
SELECT 
    prod_nome AS 'Nome do produto'
FROM
    produto
        JOIN
    listar_estabelecimentos ON id_estab = estab_id
WHERE
    estab_nome = 'PizzaHut';
    
-- ciente consultar detalhes de um produto de um determinado estabelecimento (serrana da pizzahut)
SELECT 
    prod_foto AS 'Foto',
    prod_nome AS 'Nome do produto',
    prod_descricao AS 'Descrição do produto'
FROM
    produto
        JOIN
    listar_estabelecimentos ON id_estab = estab_id
WHERE
    estab_nome = 'PizzaHut'
        AND prod_nome = 'serrana';
        
-- cliente sandra pereira (cli_id = 2) consultar histórico das suas encomendas já entregues
SELECT 
    enc_data_entrega AS 'Data entrega',
    enc_hora_entrega AS 'Hora entrega',
    estaf_nome AS 'Nome estafeta',
    estab_nome AS 'Nome estabelecimento',
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço de venda',
    enc_preco_total AS 'Preço total'
FROM
    encomenda
        JOIN
    encomenda_contem_produto ON enc_id = id_enc
        JOIN
    produto ON id_prod = prod_id
        JOIN
    listar_estafetas ON estaf_id = id_estaf
        JOIN
    listar_estabelecimentos ON id_estab = estab_id
WHERE
    id_cli = 2
        AND enc_estado_entrega = 'entregue';
        
-- cliente sandra pereira (id_cli = 2) consultar os seus pedidos em curso (enc_estado_entrega = pendente, aceite, atribuida)
SELECT 
    enc_data_pedido AS 'Data do pedido',
    enc_hora_pedido AS 'Hora do pedido',
    enc_estado_entrega AS 'Estado da encomenda',
    estaf_nome AS 'Nome estafeta',
    estab_nome AS 'Nome estabelecimento',
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço de venda',
    enc_preco_total AS 'Preço total'
FROM
    encomenda
        JOIN
    encomenda_contem_produto ON enc_id = id_enc
        JOIN
    produto ON id_prod = prod_id
        JOIN
    listar_estabelecimentos ON estab_id = id_estab
        LEFT JOIN
    listar_estafetas ON estaf_id = id_estaf
WHERE
    id_cli = 2
        AND (enc_estado_entrega = 'pendente'
        OR enc_estado_entrega = 'aceite'
        OR enc_estado_entrega = 'atribuida');

-- cliente (Fábio Bravo cli_id = 1) consultar os seus dados pessoais
SELECT 
    cli_foto_perfil AS 'Foto de perfil',
    util_nome AS 'Nome',
    cli_data_nascimento AS 'Data de nascimento',
    util_email AS 'Email',
    util_morada AS 'Morada',
    conc_nome AS 'Concelho',
    cli_cartao_credito AS 'Cartão de crédito',
    util_nif AS 'NIF',
    util_telemovel AS 'Telemóvel'
FROM
    utilizador
        JOIN
    cliente ON util_id = id_util
        JOIN
    concelho ON id_conc = conc_id
WHERE
    cli_id = 1;
    
-- Estabelecimento MacDonalds (estab_id = 1) consultar encomendas pendentes
SELECT 
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço de venda',
    id_cli AS 'Cliente',
    enc_estado_entrega,
    id_estab,
    conc_nome AS 'Concelho de entrega',
    enc_preco_total AS 'Preço total'
FROM
    encomenda
        JOIN
    encomenda_contem_produto ON enc_id = id_enc
        JOIN
    produto ON prod_id = id_prod
        JOIN
    listar_clientes_concelhos ON id_cli = cli_id
WHERE
    id_estab = 1
        AND enc_estado_entrega = 'pendente';
        
-- Estabelecimento MacDonalds (estab_id = 1) consultar encomendas aceites
SELECT 
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço de venda',
    id_cli AS 'Cliente',
    enc_estado_entrega,
    id_estab,
    conc_nome AS 'Concelho de entrega',
    enc_preco_total AS 'Preço total',
    id_estaf AS 'Estafeta'
FROM
    encomenda
        JOIN
    encomenda_contem_produto ON enc_id = id_enc
        JOIN
    produto ON prod_id = id_prod
        JOIN
    listar_clientes_concelhos ON id_cli = cli_id
WHERE
    id_estab = 1
        AND (enc_estado_entrega = 'aceite'
        OR enc_estado_entrega = 'atribuida'
        OR enc_estado_entrega = 'entregue');
        
-- Estafeta Vitor Nuno (estaf_id = 1) consultar encomendas aceites pelos estabelecimentos nos concelhos em que entrega (enc_estado_entrega = 'aceite')
SELECT 
    enc_id,
    enc_data_pedido,
    enc_hora_pedido,
    cli_nome,
    cli_morada,
    y.estab_nome,
    cli_conc,
    estab_morada
FROM
    encomenda e
        JOIN
    listar_clientes ON id_cli = cli_id
        JOIN
    listar_encomendas x ON enc_id = id_enc
        JOIN
    listar_estabelecimentos y ON x.estab_id = y.estab_id
WHERE
    enc_estado_entrega = 'aceite'
        AND (cli_conc = 1501 OR cli_conc = 1502
        OR cli_conc = 1506
        OR cli_conc = 1507
        OR cli_conc = 1508
        OR cli_conc = 1509
        OR cli_conc = 1510
        OR cli_conc = 1511
        OR cli_conc = 1512
        OR cli_conc = 1513);

-- Estafeta Vitor Nuno (estaf_id = 1) consultar histórico das encomendas entregues que foram atribuidas a si 
SELECT 
    enc_id,
    enc_data_entrega,
    enc_hora_entrega,
    cli_nome,
    cli_morada,
    y.estab_nome,
    cli_conc
FROM
    encomenda e
        JOIN
    listar_clientes ON id_cli = cli_id
        JOIN
    listar_encomendas x ON enc_id = id_enc
        JOIN
    listar_estabelecimentos y ON x.estab_id = y.estab_id
WHERE 
enc_estado_entrega = 'entregue' and e.id_estaf = 1;

-- Administrador consultar dados dos clientes
select * from listar_clientes;