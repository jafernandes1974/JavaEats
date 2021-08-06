DROP DATABASE IF EXISTS javaEats;

CREATE DATABASE javaEats;
USE javaEats;

CREATE TABLE utilizador (
util_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  
util_nome VARCHAR(100) NOT NULL,  
util_email VARCHAR(50) UNIQUE NOT NULL,  
util_estado VARCHAR(15),  
util_nif VARCHAR(20) UNIQUE NOT NULL,  
util_telemovel VARCHAR(15) NOT NULL,  
util_password VARCHAR(20) NOT NULL,  
util_morada VARCHAR(200) NOT NULL,
util_bloqueado BOOLEAN,
util_perfil VARCHAR(30));

CREATE TABLE cliente (
cli_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
cli_data_nascimento DATE NOT NULL,
cli_cartao_credito VARCHAR(20) NOT NULL,
cli_foto_perfil VARCHAR(100),
id_conc INT,
id_util INT UNIQUE NOT NULL);

CREATE TABLE estafeta (
estaf_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
estaf_data_nascimento DATE NOT NULL, 
estaf_categoria_carta VARCHAR(10), 
estaf_iban VARCHAR(20) NOT NULL, 
estaf_disponivel BOOLEAN, 
estaf_niss VARCHAR(20) UNIQUE NOT NULL, 
estaf_veiculo_motorizado BOOLEAN, 
estaf_foto_perfil VARCHAR(100),
id_util INT UNIQUE NOT NULL); 

CREATE TABLE estabelecimento (
estab_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
estab_iban VARCHAR(20), 
estab_tipo_cozinha VARCHAR(50),
estab_logo VARCHAR(100),
estab_horario VARCHAR(20),
id_util INT UNIQUE NOT NULL);

CREATE TABLE concelho (
conc_id INT NOT NULL PRIMARY KEY,
conc_nome VARCHAR(50) UNIQUE NOT NULL);

CREATE TABLE encomenda (
enc_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
enc_preco_total NUMERIC(6,2),
enc_data_entrega DATE,
enc_estado_entrega VARCHAR(30), 
enc_data_pedido DATE, 
enc_hora_pedido TIME, 
enc_hora_entrega TIME,
id_estaf INT,
id_cli INT); 

CREATE TABLE produto (
prod_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
prod_nome VARCHAR(50), 
prod_descricao VARCHAR(200), 
prod_preco_atual NUMERIC(5,2), 
prod_foto VARCHAR(100), 
prod_estado BOOLEAN,
id_estab INT);

CREATE TABLE encomenda_contem_produto (
id_enc INT,
id_prod INT,
enc_prod_quantidade INT,
enc_prod_preco_venda NUMERIC(5,2),
PRIMARY KEY (id_enc, id_prod));

CREATE TABLE estafeta_entrega_concelho (
id_conc INT,
id_estaf INT,
PRIMARY KEY (id_conc, id_estaf));

CREATE TABLE estabelecimento_serve_concelho (
id_conc INT,
id_estab INT,
PRIMARY KEY (id_conc, id_estab));

-- Chaves estrangeiras

ALTER TABLE cliente ADD CONSTRAINT cliente_fk_utilizador 
			FOREIGN KEY (id_util) REFERENCES utilizador(util_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE cliente ADD CONSTRAINT cliente_fk_concelho
            FOREIGN KEY (id_conc) REFERENCES concelho(conc_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE estafeta ADD CONSTRAINT estafeta_fk_utilizador
            FOREIGN KEY (id_util) REFERENCES utilizador(util_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE estabelecimento ADD CONSTRAINT estabelecimento_fk_utilizador
            FOREIGN KEY (id_util) REFERENCES utilizador(util_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE encomenda ADD CONSTRAINT encomenda_fk_estafeta
            FOREIGN KEY (id_estaf) REFERENCES estafeta(estaf_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE encomenda ADD CONSTRAINT encomenda_fk_cliente
            FOREIGN KEY (id_cli) REFERENCES cliente(cli_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE produto ADD CONSTRAINT produto_fk_estabelecimento
            FOREIGN KEY (id_estab) REFERENCES estabelecimento(estab_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE encomenda_contem_produto ADD CONSTRAINT enc_prod_fk_encomenda
            FOREIGN KEY (id_enc) REFERENCES encomenda(enc_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE encomenda_contem_produto ADD CONSTRAINT enc_prod_fk_produto
            FOREIGN KEY (id_prod) REFERENCES produto(prod_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE estafeta_entrega_concelho ADD CONSTRAINT estaf_conc_fk_estafeta
            FOREIGN KEY (id_estaf) REFERENCES estafeta(estaf_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE estafeta_entrega_concelho ADD CONSTRAINT estaf_conc_fk_concelho
            FOREIGN KEY (id_conc) REFERENCES concelho(conc_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE estabelecimento_serve_concelho ADD CONSTRAINT estab_conc_fk_concelho
            FOREIGN KEY (id_conc) REFERENCES concelho(conc_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
            
ALTER TABLE estabelecimento_serve_concelho ADD CONSTRAINT estab_conc_fk_estabelecimento
            FOREIGN KEY (id_estab) REFERENCES estabelecimento(estab_id) 
			ON DELETE NO ACTION ON UPDATE NO ACTION;
 
 -- Criar vistas
CREATE VIEW listar_estabelecimentos AS 
SELECT 
    estab_id, util_nome AS 'estab_nome', estab_logo, estab_tipo_cozinha, estab_horario, util_morada AS 'estab_morada'
FROM
    estabelecimento 
        JOIN
    utilizador ON util_id = id_util;

CREATE VIEW listar_estafetas AS
SELECT
	estaf_id, util_nome AS 'estaf_nome'
FROM
	estafeta
		JOIN
	utilizador ON util_id = id_util;
    
CREATE VIEW listar_clientes AS
SELECT
	cli_id, util_nome AS 'cli_nome', util_morada AS 'cli_morada', id_conc AS 'cli_conc', util_estado AS 'cli_estado', util_email AS 'cli_email', util_telemovel AS 'cli_telemovel', util_nif AS 'cli_nif', cli_cartao_credito
FROM
	cliente
		JOIN
	utilizador ON util_id = id_util;
    
CREATE VIEW listar_produtos AS
    SELECT 
        prod_id, prod_nome, estab_id, estab_nome
    FROM
        produto
            JOIN
        listar_estabelecimentos ON id_estab = estab_id;
        
CREATE VIEW listar_clientes_concelhos AS
    SELECT 
        cli_id, conc_id, conc_nome
    FROM
        cliente
            JOIN
        concelho ON id_conc = conc_id;
        
CREATE VIEW listar_encomendas AS
    SELECT 
        id_enc, prod_id, estab_id, estab_nome
    FROM
        produto
            JOIN
        listar_estabelecimentos ON id_estab = estab_id
            JOIN
        (SELECT 
            id_enc, MIN(id_prod) AS y
        FROM
            encomenda_contem_produto
        GROUP BY id_enc) x ON x.y = prod_id;