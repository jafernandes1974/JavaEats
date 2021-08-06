-- cliente João Messias consultar estabelecimentos que servem no seu concelho (Setubal conc_id = 1512) e que estão ativos
SELECT 
    estab_logo AS 'Logo',
    estab_nome AS 'Nome',
    estab_tipo_cozinha AS 'Tipo cozinha',
    estab_horario AS 'Horário'
FROM
    listar_estabelecimentos
        JOIN
    estabelecimento_serve_concelho ON estab_id = id_estab
WHERE
    id_conc = 1512 AND estab_estado = 'ativo';

-- cliente consultar produtos de um estabelecimento (KFC estab_id = 3)
SELECT 
    prod_nome AS 'Nome produto'
FROM
    produto
        JOIN
    listar_estabelecimentos ON id_estab = estab_id
WHERE
    estab_id = 3;
    
-- cliente consultar detalhes de um produto de um determinado estabelecimento (camponesa (prod_id = 11) do KFC)
SELECT 
    prod_foto AS 'Foto',
    prod_nome AS 'Nome',
    prod_descricao AS 'Descrição'
FROM
    produto
        JOIN
    listar_estabelecimentos ON id_estab = estab_id
WHERE
    estab_id = 3
        AND prod_id = 11;
        
-- cliente João Messias (cli_id = 3) consultar histórico das suas encomendas já entregues
SELECT 
    enc_data_entrega AS 'Data entrega',
    enc_hora_entrega AS 'Hora entrega',
    estaf_nome AS 'Nome estafeta',
    estab_nome AS 'Nome estabelecimento',
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço unitário',
    enc_preco_total AS 'Preço total encomenda'
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
        
-- cliente João Messias (id_cli = 3) consultar os seus pedidos em curso (enc_estado_entrega = pendente, aceite, atribuida)
SELECT 
    enc_data_pedido AS 'Data do pedido',
    enc_hora_pedido AS 'Hora do pedido',
    enc_estado_entrega AS 'Estado encomenda',
    estaf_nome AS 'Nome estafeta',
    estab_nome AS 'Nome estabelecimento',
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço unitário',
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
    id_cli = 3
        AND (enc_estado_entrega = 'pendente'
        OR enc_estado_entrega = 'aceite'
        OR enc_estado_entrega = 'atribuida');

-- cliente (João Messias cli_id = 3) consultar os seus dados pessoais
SELECT 
    cli_foto_perfil AS 'Foto perfil',
    util_nome AS 'Nome',
    cli_data_nascimento AS 'Data nascimento',
    util_email AS 'Email',
    util_morada AS 'Morada',
    conc_nome AS 'Concelho',
    cli_cartao_credito AS 'Cartão crédito',
    util_nif AS 'NIF',
    util_telemovel AS 'Telemóvel'
FROM
    utilizador
        JOIN
    cliente ON util_id = id_util
        JOIN
    concelho ON id_conc = conc_id
WHERE
    cli_id = 3;
    
-- Estabelecimento KFC (estab_id = 3) consultar encomendas pendentes
SELECT 
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço unitário',
    cli_nome AS 'Cliente',
    enc_estado_entrega AS 'Estado entrega',
    conc_nome AS 'Concelho entrega',
    enc_preco_total AS 'Preço total encomenda'
FROM
    encomenda
        JOIN
    encomenda_contem_produto ON enc_id = id_enc
        JOIN
    produto ON prod_id = id_prod
        JOIN
    listar_clientes_concelhos ON id_cli = cli_id
WHERE
    id_estab = 3
        AND enc_estado_entrega = 'pendente';
        
-- Estabelecimento KFC (estab_id = 3) consultar encomendas aceites
SELECT 
    enc_id AS 'Número encomenda',
    prod_nome AS 'Nome produto',
    enc_prod_quantidade AS 'Quantidade',
    enc_prod_preco_venda AS 'Preço unitário',
    cli_nome AS 'Cliente',
    enc_estado_entrega AS 'Estado entrega',
    conc_nome AS 'Concelho entrega',
    enc_preco_total AS 'Preço total encomenda',
    estaf_nome AS 'Estafeta'
FROM
    encomenda
        JOIN
    encomenda_contem_produto ON enc_id = id_enc
        JOIN
    produto ON prod_id = id_prod
        JOIN
    listar_clientes_concelhos ON id_cli = cli_id
        LEFT JOIN
    listar_estafetas ON id_estaf = estaf_id
WHERE
    id_estab = 3
        AND (enc_estado_entrega = 'aceite'
        OR enc_estado_entrega = 'atribuida'
        OR enc_estado_entrega = 'entregue');
        
-- Estabelecimento KFC (estab_id = 3) consultar dados pessoais
SELECT 
    estab_nome AS 'Nome',
    estab_logo AS 'Logo',
    estab_tipo_cozinha AS 'Tipo cozinha',
    estab_horario AS 'Horário',
    estab_morada AS 'Morada',
    estab_estado AS 'Estado',
    estab_email AS 'Email',
    estab_telemovel As 'Telemóvel',
    estab_nif AS 'NIF',
    estab_iban AS 'IBAN',
    conc_nome AS 'Concelhos servido'
FROM
    listar_estabelecimentos
        JOIN
    estabelecimento_serve_concelho ON estab_id = id_estab
        JOIN
    concelho ON conc_id = id_conc
WHERE
    estab_id = 3;
        
-- Estafeta Vitor Nuno (estaf_id = 1) consultar encomendas aceites pelos estabelecimentos nos concelhos em que entrega (enc_estado_entrega = 'aceite')
SELECT 
    enc_id AS 'Número encomenda',
    enc_data_pedido 'Data pedido',
    enc_hora_pedido 'Hora pedido',
    cli_nome AS 'Cliente',
    cli_morada AS 'Morada cliente',
	cli_conc AS 'Concelho cliente',
    y.estab_nome AS 'Estabelecimento',
    estab_morada AS 'Morada Estabelecimento'
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
        OR cli_conc = 1513
        OR cli_conc = 1106);

-- Estafeta Vitor Nuno (estaf_id = 1) consultar histórico das encomendas entregues que foram atribuidas a si 
SELECT 
    enc_id AS 'Número encomenda',
    enc_data_entrega AS 'Data entrega',
    enc_hora_entrega AS 'Hora entrega',
    cli_nome AS 'Cliente',
    cli_morada AS 'Morada cliente',
    cli_conc AS 'Concelho cliente',
    y.estab_nome AS 'Estabelecimento'
    
FROM
    encomenda e
        JOIN
    listar_clientes ON id_cli = cli_id
        JOIN
    listar_encomendas x ON enc_id = id_enc
        JOIN
    listar_estabelecimentos y ON x.estab_id = y.estab_id
WHERE
    enc_estado_entrega = 'entregue'
        AND e.id_estaf = 1;
        
-- Estafesta Vitor Nuno (estaf_id = 1= consulta os seus dados pessoais
SELECT 
    estaf_nome AS 'Nome',
    estaf_estado AS 'Estado',
    estaf_data_nascimento AS 'Data nascimento',
    estaf_veiculo_motorizado AS 'Veículo motorizado',
    estaf_categoria_carta AS 'Categoria carta condução',
    estaf_foto_perfil AS 'Foto perfil',
    estaf_niss AS 'NISS',
    estaf_email AS 'Email',
    estaf_morada AS 'Morada',
    estaf_nif AS 'NIF',
    estaf_telemovel AS 'Telemóvel',
    conc_nome AS 'Concelhos entrega'
FROM
    listar_estafetas
        JOIN
    estafeta_entrega_concelho ON estaf_id = id_estaf
        JOIN
    concelho ON conc_id = id_conc
WHERE
    estaf_id = 1;

-- Administrador consultar dados dos clientes
SELECT 
    cli_id AS 'id Cliente',
    cli_nome AS 'Nome',
    cli_morada AS 'Morada',
    cli_estado AS 'Estado',
    cli_email AS 'Email',
    cli_telemovel AS 'Telemóvel',
    cli_nif AS 'NIF',
    cli_cartao_credito AS 'Cartão crédito',
    cli_data_nascimento AS 'Data nascimento',
    cli_foto_perfil AS 'Foto perfil',
    conc_nome AS 'Concelho'
FROM
    listar_clientes
        JOIN
    concelho ON conc_id = cli_conc;

-- Administrador consultar dados dos estafetas
SELECT 
    estaf_id AS 'id Estafeta',
    estaf_nome AS 'Nome',
    estaf_estado AS 'Estado',
    estaf_data_nascimento AS 'Data nascimento',
    estaf_veiculo_motorizado AS 'Veiculo motorizado',
    estaf_categoria_carta AS 'Categoria carta condução',
    estaf_foto_perfil AS 'Foto perfil',
    estaf_niss AS 'NISS',
    estaf_email AS 'Email',
    estaf_morada AS 'Morada',
    estaf_nif AS 'NIF',
    estaf_telemovel AS 'Telemóvel',
    conc_nome AS 'Concelhos entrega'
FROM
    listar_estafetas
        JOIN
    estafeta_entrega_concelho ON estaf_id = id_estaf
        JOIN
    concelho ON conc_id = id_conc;
    
-- Administrador consulta dados dos estabelecimentos
SELECT 
    estab_id AS 'id Estabelecimento',
    estab_nome AS 'Nome',
    estab_logo AS 'Logo',
    estab_tipo_cozinha AS 'Tipo cozinha',
    estab_horario AS 'Horário',
    estab_morada AS 'Morada',
    estab_estado AS 'Estado',
    estab_email AS 'Email',
    estab_telemovel AS 'Telemóvel',
    estab_nif AS 'NIF',
    estab_iban AS 'IBAN',
    conc_nome AS 'Concelhos entrega'
FROM
    listar_estabelecimentos
        JOIN
    estabelecimento_serve_concelho ON estab_id = id_estab
        JOIN
    concelho ON conc_id = id_conc;
    
-- Adminnistrador consultar utilizadores pendentes 
SELECT 
    util_id AS 'id Utilizador',
    util_nome AS 'Nome',
    util_perfil AS 'Perfil'
FROM
    utilizador
WHERE
    util_estado = 'pendente';
    
-- Administrador consultar utilizadores bloqueados
SELECT 
    util_id AS 'id Utilizador',
    util_nome AS 'Nome',
    util_perfil AS 'Perfil'
FROM
    utilizador
WHERE
    util_bloqueado = TRUE;
    
-- Administrador consultar histórico encomendas
SELECT 
    enc_id AS 'Número encomenda',
    enc_estado_entrega AS 'Estado entrega',
    estab_nome AS 'Estabelecimento',
    enc_data_pedido AS 'Data pedido',
    enc_hora_pedido AS 'Hora pedido',
    cli_nome AS 'Cliente',
    cli_conc AS 'Concelho cliente',
    estaf_nome AS 'Estafeta'
FROM
    encomenda
        JOIN
    listar_encomendas ON id_enc = enc_id
        LEFT JOIN
    listar_estafetas ON id_estaf = estaf_id
        LEFT JOIN
    listar_clientes ON id_cli = cli_id;

       