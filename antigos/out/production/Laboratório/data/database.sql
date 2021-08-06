

CREATE TABLE utilizador (
    --util_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    util_id INTEGER NOT NULL PRIMARY KEY,
    util_nome VARCHAR(100) NOT NULL,
    util_email VARCHAR(50) UNIQUE NOT NULL,
    util_estado VARCHAR(15),
    util_nif VARCHAR(20) UNIQUE NOT NULL,
    util_telemovel VARCHAR(15) NOT NULL,
    util_password VARCHAR(20) NOT NULL,
    util_morada VARCHAR(200) NOT NULL,
    util_bloqueado INTEGER,
    --util_bloqueado BOOLEAN,
    util_perfil VARCHAR(30));

CREATE TABLE cliente (
    cli_id INTEGER NOT NULL PRIMARY KEY,
    cli_data_nascimento VARCHAR(15) NOT NULL,
    cli_cartao_credito VARCHAR(20) NOT NULL,
    cli_foto_perfil VARCHAR(100),
    id_conc INTEGER,
    id_util INTEGER UNIQUE NOT NULL);

CREATE TABLE estafeta (
    estaf_id INTEGER NOT NULL PRIMARY KEY, 
    estaf_data_nascimento VARCHAR(15) NOT NULL, 
    estaf_categoria_carta VARCHAR(10), 
    estaf_iban VARCHAR(20) NOT NULL, 
    estaf_disponivel INTEGER, 
    estaf_niss VARCHAR(20) UNIQUE NOT NULL, 
    estaf_veiculo_motorizado INTEGER, 
    estaf_foto_perfil VARCHAR(100),
    id_util INTEGER UNIQUE NOT NULL); 

CREATE TABLE estabelecimento (
    estab_id INTEGER NOT NULL PRIMARY KEY, 
    estab_iban VARCHAR(20), 
    estab_tipo_cozinha VARCHAR(50),
    estab_logo VARCHAR(100),
    estab_horario VARCHAR(20),
    id_util INTEGER UNIQUE NOT NULL);

CREATE TABLE concelho (
    conc_id INTEGER NOT NULL PRIMARY KEY,
    conc_nome VARCHAR(50) UNIQUE NOT NULL);

CREATE TABLE encomenda (
    enc_id INTEGER NOT NULL PRIMARY KEY, 
    enc_preco_total REAL,
    enc_data_entrega VARCHAR(15),
    enc_estado_entrega VARCHAR(30), 
    enc_data_pedido VARCHAR(15), 
    enc_hora_pedido VARCHAR(15), 
    enc_hora_entrega VARCHAR(15),
    id_estaf INTEGER,
    id_cli INTEGER); 

CREATE TABLE produto (
    prod_id INTEGER NOT NULL PRIMARY KEY, 
    prod_nome VARCHAR(50), 
    prod_descricao VARCHAR(200), 
    prod_preco_atual REAL, 
    prod_foto VARCHAR(100), 
    prod_estado INTEGER,
    id_estab INTEGER);

CREATE TABLE encomenda_contem_produto (
    id_enc INTEGER,
    id_prod INTEGER,
    enc_prod_quantidade INTEGER,
    enc_prod_preco_venda REAL,
    PRIMARY KEY (id_enc, id_prod));

CREATE TABLE estafeta_entrega_concelho (
    id_conc INTEGER,
    id_estaf INTEGER,
    PRIMARY KEY (id_conc, id_estaf));

CREATE TABLE estabelecimento_serve_concelho (
    id_conc INTEGER,
    id_estab INTEGER,
    PRIMARY KEY (id_conc, id_estab));

CREATE VIEW listar_estabelecimentos AS 
SELECT 
    estab_id, 
    util_nome AS 'estab_nome', 
    estab_logo, 
    estab_tipo_cozinha, 
    estab_horario, 
    util_morada AS 'estab_morada',
    util_estado AS 'estab_estado',
    util_email AS 'estab_email',
    util_telemovel AS 'estab_telemovel',
    util_nif AS 'estab_nif',
    estab_iban
FROM
    estabelecimento 
        JOIN
    utilizador ON util_id = id_util;

CREATE VIEW listar_estafetas AS
SELECT
	estaf_id, 
    util_nome AS 'estaf_nome', 
    util_estado AS 'estaf_estado',
    estaf_data_nascimento,
    estaf_veiculo_motorizado,
    estaf_categoria_carta,
    estaf_foto_perfil,
    estaf_niss,
    util_email AS 'estaf_email',
    util_morada AS 'estaf_morada',
    util_nif AS 'estaf_nif',
    util_telemovel AS 'estaf_telemovel'
FROM
	estafeta
		JOIN
	utilizador ON util_id = id_util;

CREATE VIEW listar_clientes AS
    SELECT 
        cli_id,
        util_nome AS 'cli_nome',
        util_morada AS 'cli_morada',
        id_conc AS 'cli_conc',
        util_estado AS 'cli_estado',
        util_email AS 'cli_email',
        util_telemovel AS 'cli_telemovel',
        util_nif AS 'cli_nif',
        cli_cartao_credito,
        cli_data_nascimento,
        cli_foto_perfil,
        util_id
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
        cli_nome, cli_id, conc_id, conc_nome
    FROM
        listar_clientes
            JOIN
        concelho ON cli_conc = conc_id;
        
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

insert into concelho (conc_id, conc_nome) values(1106,"Lisboa");
insert into concelho (conc_id, conc_nome) values(1107,"Loures");
insert into concelho (conc_id, conc_nome) values(1110,"Oeiras");
insert into concelho (conc_id, conc_nome) values(1506,"Moita");
insert into concelho (conc_id, conc_nome) values(1507,"Montijo");
insert into concelho (conc_id, conc_nome) values(1508,"Palmela");
insert into concelho (conc_id, conc_nome) values(1509,"Santiago do Cacém");
insert into concelho (conc_id, conc_nome) values(1510,"Seixal");
insert into concelho (conc_id, conc_nome) values(1511,"Sesimbra");
insert into concelho (conc_id, conc_nome) values(1512,"Setúbal");
insert into concelho (conc_id, conc_nome) values(1513,"Sines");
insert into concelho (conc_id, conc_nome) values(1501,"Alcácer do Sal");
insert into concelho (conc_id, conc_nome) values(1502,"Alcochete");
insert into concelho (conc_id, conc_nome) values(1503,"Almada");
insert into concelho (conc_id, conc_nome) values(1504,"Barreiro");
insert into concelho (conc_id, conc_nome) values(1505,"Grândola");

insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Filipa Martins","fma1@email.pt","ativo","346908344","953284447","1234","Rua do Meio, 50, 2950-555, Palmela",0,"administrador");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Fábio Bravo","fbr2@email.pt","ativo","352240346","954913951","1234","Rua do Início, 99, 2830-152 Barreiro",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Sandra Pereira","spe3@email.pt","ativo","329939894","923878710","1234","Avenida da Liberdade, 59, 1120-780, Lisboa",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("João Messias","jme4@email.pt","ativo","328564326","964775283","1234","Rua do Alto, 33, 2900-455, Setúbal",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("André Pombo","apo5@email.pt","ativo","247694338","953438013","1234","Rua de Cima, 28, 2950-155, Palmela",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Andreia Plácido","apl6@email.pt","ativo","359076841","923349296","1234","Avenida da República, 2B, 1100-034, Lisboa",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Catarina Cerejo","cce7@email.pt","ativo","335894356","919173299","1234","Praça da Virtude, 120-122, 2860-243, Moita",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Daniel Malhado","dma8@email.pt","ativo","255931074","952925859","1234","Rua 25 de Abril, 23A r/c dir 2860-524 Moita",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Júlio Simões","jsi9@email.pt","ativo","346413527","914609691","1234","Rua do Coreto, 8, 2950-458 Palmela",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Miguel Machado","mma10@email.pt","ativo","229969578","943566838","1234","Rua da Paz dos Anjos, s/n, 2830 Barreiro",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Paulo Costa","pco11@email.pt","ativo","379046837","966060111","1234","Rua de baixo, 340, 2950-575, Palmela",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Paulo Covas","pco12@email.pt","ativo","285667241","960965566","1234","Avenida da Liberdade, 111, 1100-241, Lisboa",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Tiago Landeiroto","tla13@email.pt","ativo","213706474","969570075","1234","Praça da Vitória,1, 2860-003, Moita",0,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Vítor Nuno","vnu14@email.pt","ativo","202322873","936246615","1234","Rua 1º de Maio, 43, 2955-253 Palmela",0,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Wilson Veterano","wve15@email.pt","ativo","219118782","937276101","1234","Rua do Futuro,1 8, 2950-008 Palmela",0,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("José Fernandes","jfe16@email.pt","ativo","359475457","959685084","1234","Rua do Fim, 1, 1100-000, Lisboa",0,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("João Cunha","jcu17@email.pt","ativo","345233522","929515724","1234","Rua do Futuro,1 8, 2950-008 Palmela",0,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("João Morais","jmo18@email.pt","ativo","322903749","936003012","1234","Rua do Passado,32, 2950-014 Palmela",1,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("McDonalds", "mcDon@mail.pt", "ativo", "56753677","922222321", "1234","Parque das Merenda, 1a, 2830-125, Barreiro",0,  "estabelecimento");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("PizzaHut", "pihu@mail.pt", "ativo", "567453691", "958212221", "1234", "Rua Fantasma, 13, 2900-725, Setúbal", 0,"estabelecimento"); 
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("KFC", "kfc@mail.pt", "ativo", "5674523423","92562389", "1234","Centro Comercial do Comércio, 18C, 2830-125, Barreiro",0, "estabelecimento"); 
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Burger King", "buki@mail.pt", "ativo", "56746788", "915822214", "1234", "Travessa das Almas, 23, 1000-725, Lisboa", 0,"estabelecimento");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Ana Gama","ambg@email.pt","pendente","345233375","929515734","1234","Praça do Futuro,1 9, 2950-008 Palmela",0,"estafeta");

insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("28/10/1974","153982046",@foto_cli,1504,2);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("8/1/1971","301508130",@foto_cli,1106,3);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("7/5/1951","221528190",@foto_cli,1512,4);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("23/12/1957","118356912",@foto_cli,1508,5);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("4/1/1977","389424002",@foto_cli,1106,6);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("4/2/1995","153106271",@foto_cli,1506,7);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("21/5/1983","170958235",@foto_cli,1506,8);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("17/12/1986","262998975",@foto_cli,1508,9);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("20/7/1978","152427881",@foto_cli,1504,10);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("4/7/1982","189373943",@foto_cli,1508,11);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("14/3/1998","136986328",@foto_cli,1506,12);
insert into cliente ( cli_data_nascimento, cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values ("5/11/1975","379753946",@foto_cli,1506,13);

insert into estafeta ( estaf_data_nascimento, estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values ("5/3/1964", "A","148423307", 1, 101660639, 1,@foto_cli,14);
insert into estafeta ( estaf_data_nascimento, estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values ("16/4/1982", "B","321349304", 1, 222057836, 1,@foto_cli,15);
insert into estafeta ( estaf_data_nascimento, estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values ("11/10/1967", NULL,"115751793", 1, 164365331, 0,@foto_cli,16);
insert into estafeta ( estaf_data_nascimento, estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values ("28/11/1972", "A","171688168", 1, 264075421, 1,@foto_cli,17);
insert into estafeta ( estaf_data_nascimento, estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values ("17/05/1985", "A","173388168", 1, 134075421, 1,@foto_cli,23);

insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util) values ("PT35234353534", "Hamburgers",  "https://logos-world.net/wp-content/uploads/2020/04/McDonalds-Logo.png", "8:00-24:00", 19);
insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util) values ("PT25562456224", "Pizas", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2JUSXrexn5gOHJrt0UwqVvy2K9u7f1wdlOQ&usqp=CAU%22,%228:00-24:00","8:00-24:00", 20);
insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util) values ("PT2593265584", "Frango", "https://upload.wikimedia.org/wikipedia/pt/b/bf/KFC_logo.svg", "8:00-24:00",21);
insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util) values ("PT2587113534", "Hamburgers",  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ--1MJsy7_DWpEDHBVdc8L7Vn-neqF-M_MyA&usqp=CAU", "8:00-24:00", 22);

insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("cheeseham","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Fiambre e Mozzarella Extra: Tamanho médio", 14.6,  @pizza_media,1, 1);	
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("serrana","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Chouriço, Cogumelos Frescos e Azeitonas: Tamanho médio", 14.6, @pizza_media,1, 2);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("veggie lovers","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Mistura de Vegetais, Milho, Tomate e Azeitonas: Tamanho médio", 14.6, @pizza_media,1, 3);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("summer","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Chouriço, Ananás e Cebola Crocante: Tamanho médio", 14.6, @pizza_media,1, 4);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Prosciutto Lovers","Molho de Tomate, 3 Queijos, Presunto, Presunto Extra e Orégãos: Tamanho médio", 14.6, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("bacon lovers","Molho de Tomate, Queijo 100% Mozzarella, Orégãos e Bacon Extra: Tamanho médio", 16.3, @pizza_media,1, 2);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("pepperoni lovers","Molho de Tomate, Queijo 100% Mozzarella, Orégãos e Pepperoni Extra: Tamanho médio", 16.3, @pizza_media,1, 3);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("tropical","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Ananás, Fiambre e Cogumelos Frescos: Tamanho médio", 16.3, @pizza_media,1, 4);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("portuguesa","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Chouriço, Mistura de Pimentos: Tamanho médio", 16.3, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("gália","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Frango, Pepperoni e Ovo Cozido: Tamanho médio", 16.3, @pizza_media,1, 2);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("camponesa","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Fiambre, Cogumelos Frescos e Tomate: Tamanho médio", 16.3, @pizza_media,1, 3);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("cheese lovers","Molho de Tomate, 3 Queijos, Queijo de Cabra e Orégãos: Tamanho médio", 16.3, @pizza_media,1, 4);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Prosciutto Garden","Molho de Tomate, Queijo 100% Mozzarella, Presunto, Tomate, Azeitonas e Orégãos.: Tamanho médio", 16.3, @pizza_media,1, 4);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("havaiana","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Atum, Camarão e Ananás: Tamanho médio", 18, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("garlic & bacon","Molho de Manteiga de Alho, Queijo 100% Mozzarella, Orégãos, Bacon, Cogumelos Frescos e Cebola: Tamanho médio", 18, @pizza_media,1, 2);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("suprema","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Pepperoni, Carne de Vaca, Mistura de Pimentos,Cogumelos Frescos e Cebola: Tamanho médio", 18, @pizza_media,1, 3);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("barbecue","Molho Barbecue, Queijo 100% Mozzarella, Orégãos, Bacon, Carne de Vaca e Cebola: Tamanho médio", 18, @pizza_media,1, 4);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("farm lovers","Molho Barbecue, Queijo 100% Mozzarella, Orégãos, Frango, Bacon, Milho e Cebola Crocante: Tamanho médio", 18, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("5 queijos ","Molho de Tomate, Queijo Mozzarella, Red Leicester, Monterey Jack, Queijo de Cabra,Parmesão e Orégãos: Tamanho médio", 18, @pizza_media,1, 2);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("super suprema ","Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Pepperoni, Carne de Vaca,Fiambre, Mistura de Pimentos, Cogumelos Frescos, Cebola e Azeitonas: Tamanho médio", 18, @pizza_media,TRUE, 3);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Prosciutto ","Gourmet Molho de Tomate, Queijo 100% Mozzarela, Presunto, Queijo de Cabra,Cebola Crocante e Orégãos: Tamanho médio", 18, @pizza_media,1, 4);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("BigMac","Com tomate", 3.9, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("CBO","Com queijo", 5.9, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Batatas pequenas","em pacote", 1.7, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Batatas médias","feitas na hora", 2.2, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Batatas grandes","feitas na hora", 2.5, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Coca-cola pequena","em garrafa", 2.3, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Coca-cola média","em copo", 2.5, @pizza_media,1, 1);
insert into produto (prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab)	values("Coca-cola grande","em copo", 2.6, @pizza_media,1, 1);

insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (117.50, "26/2/2021", "9:24","entregue", "26/2/2021" ,"10:04", 1,2);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (102.90, "26/2/2021", "9:37","entregue", "26/2/2021" ,"10:17", 3,5);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (114.10, "26/2/2021", "10:48","entregue", "26/2/2021" ,"11:28", 1,5);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (101.70, "26/2/2021", "11:30","entregue", "26/2/2021" ,"12:10", 1,1);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (121.40, "26/2/2021", "15:54","entregue", "26/2/2021" ,"16:34", 1,8);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (116.30, "26/2/2021", "16:21","entregue", "26/2/2021" ,"17:01", 2,6);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (58.40, "26/2/2021", "17:01","entregue", "26/2/2021" ,"17:41", 1,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (120.0, "26/2/2021", "17:23","entregue", "26/2/2021" ,"18:03", 1,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (105.40, "26/2/2021", "21:38","entregue", "26/2/2021" ,"22:18", 1,9);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (47.80, "27/2/2021", "8:55","entregue", "27/2/2021" ,"9:35", 2,10);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (103.70, "27/2/2021", "10:40","entregue", "27/2/2021" ,"11:20", 1,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (41.90, "27/2/2021", "15:13","entregue", "27/2/2021" ,"15:53", 2,3);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (119.20, "27/2/2021", "19:34","entregue", "27/2/2021" ,"20:14", 2,6);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (97.80, "27/2/2021", "20:14","entregue", "27/2/2021" ,"20:54", 1,10);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (102.90, "28/2/2021", "8:45","entregue", "28/2/2021" ,"9:25", 2,8);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (68.60, "28/2/2021", "13:38","entregue", "28/2/2021" ,"14:18", 2,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (66.90, "28/2/2021", "15:57","entregue", "28/2/2021" ,"16:37", 2,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (68.60, "28/2/2021", "19:51","entregue", "28/2/2021" ,"20:31", 2,10);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (19.70, "28/2/2021", "23:20","entregue", "1/3/2021" ,"0:00", 2,8);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (134.80, "1/3/2021", "8:55","entregue", "1/3/2021" ,"9:35", 2,12);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (20.20, "1/3/2021", "11:21","entregue", "1/3/2021" ,"12:01", 1,6);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (60.60, "1/3/2021", "13:43","entregue", "1/3/2021" ,"14:23", 2,8);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (120.80, "1/3/2021", "17:02","entregue", "1/3/2021" ,"17:42", 1,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (46.30, "1/3/2021", "21:58","entregue", "1/3/2021" ,"22:38", 2,11);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (101.80, "2/3/2021", "9:21","entregue", "2/3/2021" ,"10:01", 1,11);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (100.30, "2/3/2021", "13:43","entregue", "2/3/2021" ,"14:23", 1,4);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (36.0, "2/3/2021", "15:47","entregue", "2/3/2021" ,"16:27", 3,2);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (133.80, "2/3/2021", "19:18","entregue", "2/3/2021" ,"19:58", 2,7);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (54.0, "2/3/2021", "23:34","entregue", "3/3/2021" ,"0:14", 1,10);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (50.60, "2/3/2021", "23:40","entregue", "3/3/2021" ,"0:20", 1,11);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (117.50, "3/3/2021", "11:16","entregue", "3/3/2021" ,"11:56", 1,6);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (115.80, "3/3/2021", "14:18","entregue", "3/3/2021" ,"14:58", 2,12);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (117.50, "3/3/2021", "18:34","entregue", "3/3/2021" ,"19:14", 2,3);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (83.20, "3/3/2021", "19:59","entregue", "3/3/2021" ,"20:39", 2,7);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (83.20, "3/3/2021", "21:45","entregue", "3/3/2021" ,"22:25", 1,7);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (36.0, "3/3/2021", "23:08","entregue", "3/3/2021" ,"23:48", 1,1);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (96.10, "4/3/2021", "8:09","entregue", "4/3/2021" ,"8:49", 1,9);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (65.20, "4/3/2021", "10:35","entregue", "4/3/2021" ,"11:15", 1,1);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (81.50, "4/3/2021", "10:42","entregue", "4/3/2021" ,"11:22", 1,2);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (50.60, "4/3/2021", "15:17","entregue", "4/3/2021" ,"15:57", 3,5);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (32.60, "4/3/2021", "16:28","entregue", "4/3/2021" ,"17:08", 1,9);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (63.50, "4/3/2021", "21:22","entregue", "4/3/2021" ,"22:02", 1,3);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (63.51, "5/3/2021", "9:21","entregue", "5/3/2021" ,"10:01", 1,1);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (63.52, "5/3/2021", "11:19","entregue", "5/3/2021" ,"11:59", 4,2);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) values (63.53, "5/3/2021", "13:02","entregue", "5/3/2021" ,"13:42", 4,5);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, id_estaf, id_cli) values (97.80, "5/3/2021", "14:32","atribuida", 1,9);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, id_estaf, id_cli) values (115.80, "5/3/2021", "19:15","atribuida", 2,7);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega,  id_cli) values (68.60, "5/3/2021" ,"19:35","aceite",12);
insert into encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega,  id_cli) values (50.60, "5/3/2021", "21:40","pendente",3);

insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(1,21,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(1,17,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(1,13,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(1,8,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(1,4,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(2,21,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(2,17,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(2,13,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(2,8,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(3,21,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(3,13,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(3,12,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(3,8,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(3,4,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(4,22,2, 3.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(4,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(4,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(4,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(4,5,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(4,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(5,22,2, 3.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(5,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(5,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(5,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(5,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(5,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(6,22,1, 3.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(6,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(6,9,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(6,5,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(6,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(7,22,2, 3.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(7,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(7,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(8,23,2, 5.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(8,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(8,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(8,9,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(8,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(8,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(9,23,1, 5.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(9,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(9,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(9,9,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(9,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(9,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(10,23,2, 5.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(10,18,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(10,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(11,23,2, 5.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(11,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(11,9,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(11,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(12,23,1, 5.90);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(12,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(13,24,2, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(13,18,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(13,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(13,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(13,5,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(13,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(14,24,2, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(14,18,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(14,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(14,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(14,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(14,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(15,24,1, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(15,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(15,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(15,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(16,24,1, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(16,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(16,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(16,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(17,24,1, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(17,18,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(17,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(17,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(18,24,2, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(18,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(18,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(18,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(19,24,1, 1.70);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(19,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(20,25,1, 2.20);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(20,18,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(20,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(20,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(20,5,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(20,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(21,25,2, 2.20);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(21,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(22,25,1, 2.20);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(22,5,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(22,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(23,26,2, 2.50);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(23,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(23,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(23,9,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(23,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(24,26,1, 2.50);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(24,5,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(24,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(25,27,2, 2.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(25,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(25,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(25,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(25,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(26,28,2, 2.50);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(26,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(26,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(26,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(26,1,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(27,17,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(28,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(28,14,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(28,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(28,5,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(28,1,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(29,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(29,14,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(30,18,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(30,9,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(31,19,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(31,15,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(31,10,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(31,6,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(31,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(32,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(32,15,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(32,10,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(32,6,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(32,2,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(33,19,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(33,15,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(33,10,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(33,2,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(34,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(34,15,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(34,6,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(34,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(35,19,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(35,15,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(35,6,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(35,2,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(36,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(36,15,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(37,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(37,10,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(37,6,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(37,2,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(38,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(38,6,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(38,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(39,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(39,6,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(39,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(40,19,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(40,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(41,19,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(41,2,1, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(42,20,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(42,11,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(42,3,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(43,15,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(43,10,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(43,6,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(43,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(44,15,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(44,10,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(44,6,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(44,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(45,15,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(45,10,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(45,6,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(46,15,1, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(46,10,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(46,6,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(47,15,2, 18.0);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(47,10,2, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(48,10,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(48,6,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(48,2,2, 14.60);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(49,11,1, 16.30);
insert into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) values(49,7,2, 16.30);

insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1506, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1507, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1510, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1511, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1512, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1513, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1502, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1503, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1504, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1505, 1);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1106, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1506, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1507, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1510, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1511, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1512, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1513, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1502, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1503, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1504, 2);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1503, 3);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1510, 3);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1511, 3);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1512, 3);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1106, 4);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1107, 4);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1110, 4);
insert into estabelecimento_serve_concelho (id_conc, id_estab) values (1508, 1);

insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1506,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1507,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1510,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1511,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1512,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1513,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1508,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1509,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1501,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1502,	1);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1106,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1506,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1507,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1510,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1511,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1512,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1513,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1508,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1509,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1501,	2);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1503,	3);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1106,	3);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1107,	3);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1110,	3);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1106,	4);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1110,	4);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1110,	5);
insert into estafeta_entrega_concelho (id_conc , id_estaf) values(1106, 1);