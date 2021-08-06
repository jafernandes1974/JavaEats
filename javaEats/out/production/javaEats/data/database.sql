CREATE TABLE utilizador (
    util_id INTEGER NOT NULL PRIMARY KEY,
    util_nome VARCHAR(100) NOT NULL,
    util_email VARCHAR(50) UNIQUE NOT NULL,
    util_estado VARCHAR(15),
    util_nif VARCHAR(20) NOT NULL,
    util_telemovel VARCHAR(15) NOT NULL,
    util_password VARCHAR(20) NOT NULL,
    util_morada VARCHAR(200) NOT NULL,
    util_bloqueado INTEGER,
    util_perfil VARCHAR(30),
    util_falhas INTEGER);

CREATE TABLE cliente (
    cli_id INTEGER NOT NULL PRIMARY KEY,
    cli_data_nascimento VARCHAR(15) NOT NULL,
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

CREATE TABLE notificacao (
    not_id INTEGER NOT NULL PRIMARY KEY,
    not_data VARCHAR(15),
    not_hora VARCHAR(15),
    not_texto VARCHAR(100),
    id_cli INTEGER);

Create table cliente_estabelecimentos_favoritos (
    id_cli INTEGER NOT NULL,
    id_estab INTEGER NOT NULL,
    PRIMARY KEY (id_cli, id_estab));

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
    estab_iban,
    util_id AS 'estab_util_id',
    util_bloqueado
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
    util_telemovel AS 'estaf_telemovel',
    util_id AS 'estaf_util_id',
    util_bloqueado
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
        cli_data_nascimento,
        cli_foto_perfil,
        util_id AS 'cli_util_id',
        util_bloqueado  
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

INSERT INTO concelho (conc_id, conc_nome) 
VALUES 
    (1106, "Lisboa"),
    (1107, "Loures"),
    (1110, "Oeiras"),
    (1506, "Moita"),
    (1507, "Montijo"),
    (1508, "Palmela"),
    (1509, "Santiago do Cacém"),
    (1510, "Seixal"),
    (1511, "Sesimbra"),
    (1512, "Setúbal"),
    (1513, "Sines"),
    (1501, "Alcácer do Sal"),
    (1502, "Alcochete"),
    (1503, "Almada"),
    (1504, "Barreiro"),
    (1505, "Grândola");

INSERT INTO utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil, util_falhas) 
VALUES 
    ("Filipa Martins", "fma1@email.pt", "ativo", "346908344", "953284447", "1234", "Rua do Meio, 50, 2950-555, Palmela", 0, "administrador", 0),
    ("Fábio Bravo", "fbr2@email.pt", "ativo", "352240346", "954913951", "1234", "Rua do Início, 99, 2830-152 Barreiro", 0, "cliente", 0),
    ("Sandra Pereira", "spe3@email.pt", "ativo", "329939894", "923878710", "1234", "Avenida da Liberdade, 59, 1120-780, Lisboa", 0, "cliente", 0),
    ("João Messias", "jme4@email.pt", "ativo", "328564326", "964775283", "1234", "Rua do Alto, 33, 2900-455, Setúbal", 0, "cliente", 0),
    ("André Pombo", "apo5@email.pt", "ativo", "247694338", "953438013", "1234", "Rua de Cima, 28, 2950-155, Palmela", 0, "cliente", 0),
    ("Andreia Plácido", "apl6@email.pt", "ativo", "359076841", "923349296", "1234", "Avenida da República, 2B, 1100-034, Lisboa", 0, "cliente", 0),
    ("Catarina Cerejo", "cce7@email.pt", "ativo", "335894356", "919173299", "1234", "Praça da Virtude, 120-122, 2860-243, Moita", 0, "cliente", 0),
    ("Daniel Malhado", "dma8@email.pt", "ativo", "255931074", "952925859", "1234", "Rua 25 de Abril, 23A r/c dir 2860-524 Moita", 0, "cliente", 0),
    ("Júlio Simões", "jsi9@email.pt", "ativo", "346413527", "914609691", "1234", "Rua do Coreto, 8, 2950-458 Palmela", 0, "cliente", 0),
    ("Miguel Machado", "mma10@email.pt", "ativo", "229969578", "943566838", "1234", "Rua da Paz dos Anjos, s/n, 2830 Barreiro", 0, "cliente", 0),
    ("Paulo Costa", "pco11@email.pt", "ativo", "379046837", "966060111", "1234", "Rua de baixo, 340, 2950-575, Palmela", 0, "cliente", 0),
    ("Paulo Covas", "pco12@email.pt", "ativo", "285667241", "960965566", "1234", "Avenida da Liberdade, 111, 1100-241, Lisboa", 0, "cliente", 0),
    ("Tiago Landeiroto", "tla13@email.pt", "ativo", "213706474", "969570075", "1234", "Praça da Vitória,1, 2860-003, Moita", 0, "cliente", 0),
    ("Vítor Nuno", "vnu14@email.pt", "ativo", "202322873", "936246615", "1234", "Rua 1º de Maio, 43, 2955-253 Palmela", 0, "estafeta", 0),
    ("Wilson Veterano", "wve15@email.pt", "ativo", "219118782", "937276101", "1234", "Rua do Futuro,1 8, 2950-008 Palmela", 0, "estafeta", 0),
    ("José Fernandes", "jfe16@email.pt", "ativo", "359475457", "959685084", "1234", "Rua do Fim, 1, 1100-000, Lisboa", 0, "estafeta", 0),
    ("João Cunha", "jcu17@email.pt", "ativo", "345233522", "929515724", "1234", "Rua do Futuro,1 8, 2950-008 Palmela", 0, "estafeta", 0),
    ("João Morais", "jmo18@email.pt", "ativo", "322903749", "936003012", "1234", "Rua do Passado,32, 2950-014 Palmela", 1, "estafeta", 0),
    ("McDonalds", "mcDon@mail.pt", "ativo", "567536779", "922222321", "1234", "Parque das Merenda, 1a, 2830-125, Barreiro", 0, "estabelecimento", 0),
    ("PizzaHut", "pihu@mail.pt", "ativo", "567453691", "958212221", "1234", "Rua Fantasma, 13, 2900-725, Setúbal", 0, "estabelecimento", 0),
    ("KFC", "kfc@mail.pt", "ativo", "567452342", "925623892", "1234", "Centro Comercial do Comércio, 18C, 2830-125, Barreiro", 0, "estabelecimento", 0),
    ("Burger King", "buki@mail.pt", "ativo", "567467886", "915822214", "1234", "Travessa das Almas, 23, 1000-725, Lisboa", 0, "estabelecimento", 0),
    ("Ana Gama", "ambg@email.pt", "pendente", "345233375", "929515734", "1234", "Praça do Futuro,1 9, 2950-008 Palmela", 0, "estafeta", 0),
    ("SushiSan", "sushi@email.pt", "ativo", "245233375", "919515734", "1234", "Praça do Futuro,1 9, 2950-008 Palmela", 0, "estabelecimento", 0);

INSERT INTO cliente (cli_data_nascimento, cli_foto_perfil, id_conc, id_util) 
VALUES 
    ("28/10/1974", "/images/foto_perfil.png", 1504, 2),
    ("8/1/1971", "/images/foto_perfil.png", 1106, 3),
    ("7/5/1951", "/images/foto_perfil.png", 1512, 4),
    ("23/12/1957", "/images/foto_perfil.png", 1508, 5),
    ("4/1/1977", "/images/foto_perfil.png", 1106, 6),
    ("4/2/1995", "/images/foto_perfil.png", 1506, 7),
    ("21/5/1983", "/images/foto_perfil.png", 1506, 8),
    ("17/12/1986", "/images/foto_perfil.png", 1508, 9),
    ("20/7/1978", "/images/foto_perfil.png", 1504, 10),
    ("4/7/1982", "/images/foto_perfil.png", 1508, 11),
    ("14/3/1998", "/images/foto_perfil.png", 1506, 12),
    ("5/11/1975", "/images/foto_perfil.png", 1506, 13);

INSERT INTO estafeta (estaf_data_nascimento, estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) 
VALUES 
    ("5/3/1964", "A", "754121614754121614235", 0, "10166063921", 1, "/images/foto_perfil.png", 14),
    ("16/4/1982", "B", "835611026835611026754", 0, "22205783666", 1, "/images/foto_perfil.png", 15),
    ("11/10/1967", NULL, "394351678394351678001", 1, "16436533103", 0, "/images/foto_perfil.png", 16),
    ("28/11/1972", "A", "171688168171688168117", 1, "26407542113", 1, "/images/foto_perfil.png", 17),
    ("28/02/1994", "A", "151699168151699168633", 1, "23408442155", 1, "/images/foto_perfil.png", 18),
    ("17/05/1985", "A", "512065232512065232099", 1, "13407542109", 1, "/images/foto_perfil.png", 23);

INSERT INTO estabelecimento (estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util) 
VALUES 
    ("352343535342179095511", "Hamburgers",  "/images/McDonalds.png", "8:00-24:00", 19),
    ("255624562243685735665", "Pizzas", "/images/Pizzahut.png", "8:00-24:00", 20),
    ("259326558499858379474", "Frango", "/images/kfc.PNG", "8:00-24:00", 21),
    ("258711353411117582428", "Hamburgers",  "/images/burgerking.png", "8:00-24:00", 22),
    ("258711353480610791745", "Sushi",  "/images/sushisan.png", "8:00-24:00", 24);


INSERT INTO produto (prod_nome, prod_descricao, prod_preco_atual, prod_estado, id_estab, prod_foto) 
VALUES 
    ("BigMac", "Com tomate", 3.90, 1, 1, "/images/bigmac.jpg"),
    ("CBO", "Com queijo", 5.90, 1, 1, "/images/cbo.png"),
    ("Batatas pequenas", "Feitas na hora", 1.70, 1, 1, "/images/batatas_pequenas_mcdonalds.png"),
    ("Batatas médias", "Feitas na hora", 2.20, 1, 1, "/images/batatas_medias_mcdonalds.jpg"),
    ("Batatas grandes", "Feitas na hora", 2.50, 1, 1, "/images/batatas_grandes_mcdonalds.jpg"),
    ("Coca-cola pequena", "Em copo", 2.30, 1, 1, "/images/cocacola_mcdonalds.png"),
    ("Coca-cola média", "Em copo", 2.50, 1, 1, "/images/cocacola_mcdonalds.png"),
    ("Coca-cola grande", "Em copo", 2.60, 1, 1, "/images/cocacola_mcdonalds.png"),
    ("Cheeseham", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Fiambre e Mozzarella Extra: Tamanho médio", 14.60, 1, 2, "/images/cheeseham.png"),
    ("Serrana", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Chouriço, Cogumelos Frescos e Azeitonas: Tamanho médio", 14.60, 1, 2, "/images/serrana.jpg"),
    ("Veggie lovers", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Mistura de Vegetais, Milho, Tomate e Azeitonas: Tamanho médio", 14.60, 1, 2, "/images/veggielovers.jpg"),
    ("Summer", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Chouriço, Ananás e Cebola Crocante: Tamanho médio", 14.60, 1, 2, "/images/summer.jpg"),
    ("Prosciutto Lovers", "Molho de Tomate, 3 Queijos, Presunto, Presunto Extra e Orégãos: Tamanho médio", 14.60, 1, 2, "/images/prosciuttolovers.png"),
    ("Bacon lovers", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos e Bacon Extra: Tamanho médio", 16.30, 1, 2, "/images/baconlovers.png"),
    ("Pepperoni lovers", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos e Pepperoni Extra: Tamanho médio", 16.30, 1, 2, "/images/pepperonilovers.png"),
    ("Tropical", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Ananás, Fiambre e Cogumelos Frescos: Tamanho médio", 16.30, 1, 2, "/images/tropical.png"),
    ("Portuguesa", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Chouriço, Mistura de Pimentos: Tamanho médio", 16.30, 1, 2, "/images/portuguesa.png"),
    ("Gália", "Molho de Tomate, Queijo 100% Mozzarella, Orégãos, Frango, Pepperoni e Ovo Cozido: Tamanho médio", 16.30, 1, 2, "/images/galia.jpg"),
    ("Pepsi Max", "1,5L", 2.50, 1, 2, "/images/pepsi_max.jpg"),
    ("Água sem gás", "500 ml", 2.00, 1, 2, "/images/agua.png"),
    ("Double Krunch Queijo", "Sanduíche composta por 2 tiras de Frango marinado e panado, alface, queijo e ketchup", 3.50, 1, 3, "/images/double_krunch.jpg"),
    ("Original", "Sanduíche composta por 1 Filete de Frango marinado e panado, alface, bacon e ketchup", 3.50, 1, 3, "/images/original.png"),
    ("Chick&Share 6 Pedaços", "Pedaços de Frango marinado e panado de acordo com a receita secreta de 11 ervas e especiarias", 9.95, 1, 3, "/images/chick&share.jpg"),
    ("Pepsi", "Em lata", 2.50, 1, 3, "/images/pepsi.jpg"),
    ("Batatas médias", "Feitas na hora", 2.00, 1, 3, "/images/batatas_kfc.jpg"),
    ("Box de 8 Hotwings", "8 Asas de Frango marinados e panados, picantes", 9.95, 1, 3, "/images/hotwings.jpg"),
    ("DIP Maionese e Alho", "Uma deliciosa combinação. Experimenta com as nossas batatas", 0.50, 1, 3, "/images/dip.jpg"),
    ("Whopper", "O WHOPPER será sempre o nosso número um. Suculenta carne de vaca, tomate e alface fresca, cebola e plices saborosos", 4.50, 1, 4, "/images/whopper.png"),
    ("The Kink Bacon", "Duas carnes grelhadas deliciosas acompanhadas por fatias de bacon crocante com queijo, tomate e maionese de bacon", 6.95, 1, 4, "/images/kingbacon.png"),
    ("Bacon Cheese Bites (5)", "Quando juntas muito queijo e muito bacon, não há nada que possa sair mal. Os Bacon Cheese bites são sinónimos de sucesso garantido", 2.50, 1, 4, "/images/bacon_cheese_bites.png"),
    ("Queen Cheese", "A nossa rainha do Queijo no seu esplendor. A melhor combinação de ingredientes: queijo cheddar, queijo gouda de cabra e creme de queijo de cabra", 5.95, 1, 4, "/images/queencheese.png"),
    ("King Aros de Cebola (10)", "O Olimpo para os amantes de cebola. Estes King Rodelas de Cebola podem ser pedidos como entrada ou acompanhamento", 2.40, 1, 4, "/images/king_aros_cebola.png"),
    ("Molho barbecue", "Sabor intenso. O molho barbecue é um molho usado para dar um sabor mais forte à nossa comida", 0.50, 1, 4, "/images/molho_barbecue.png"),
    ("Coca-cola média", "Em copo", 2.50, 1, 4, "/images/cocacola.png"),
    ("Água sem gás", "500 ml", 2.00, 1, 4, "/images/agua.png"),
    ("Batatas médias", "Feitas na hora", 2.00, 1, 4, "/images/batatas_burgerking.png"),
    ("Combinado sushi 16 unidades", "Criado diariamente pelos nossos chefs. Composto por 16 peças de fusão", 17.50, 1, 5, "/images/combinado16.png"),
    ("6 Gunkans Lovers", "Arroz + Salmão + Extra Salmão + Philadelphia + Cebolinho", 7.50, 1, 5, "/images/gunkans.png"),
    ("Menu Tradicional", "3 Hosomaki salmão + 3 Hosomaki Atum + 2 Nigiris Salmão + 2 Nigiris Peixe Branco Braseado + 2 Gukans Jo + 3 Sasshimi Salmão + 3 Sashimi Atum", 17.50, 1, 5, "/images/tradicional.png"),
    ("Poke Bowl", "Arroz + Salmão + Abacate + Morango + Cebola Frita + Edamame + Maionese + Sementes Mistas", 14.50, 1, 5, "/images/pokebowl.png"),
    ("Menu Kids", "6 Mini-Nigiris Salmão + 4 Hosomakis Salmão + Bongo 8 Frutos", 11.00, 1, 5, "/images/menukids.png"),
    ("Coca-cola média", "Em copo", 2.50, 1, 5, "/images/cocacola.png"),
    ("Água sem gás", "500 ml", 2.00, 1, 5, "/images/agua.png");

INSERT INTO encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli) 
VALUES 
    (14.00, "26/2/2021", "9:24", "entregue", "26/2/2021", "10:04", 1, 2),
    (8.95, "26/2/2021", "9:37", "entregue", "26/2/2021", "10:17", 3, 5),
    (10.85, "26/2/2021", "10:48", "entregue", "26/2/2021", "11:28", 1, 5),
    (8.60, "26/2/2021", "11:30", "entregue", "26/2/2021", "12:10", 1, 1),
    (11.80, "26/2/2021", "15:54", "entregue", "26/2/2021", "16:34", 1, 8),
    (19.60, "26/2/2021", "16:21", "entregue", "26/2/2021", "17:01", 2, 6),
    (11.80, "26/2/2021", "17:01", "entregue", "26/2/2021", "17:41", 1, 4),
    (5.90, "26/2/2021", "17:23", "entregue", "26/2/2021", "18:03", 1, 4),
    (8.60, "26/2/2021", "21:38", "entregue", "26/2/2021", "22:18", 1, 9),
    (19.20, "27/2/2021", "8:55", "entregue", "27/2/2021", "9:35", 2, 10),
    (5.90, "27/2/2021", "10:40", "entregue", "27/2/2021", "11:20", 1, 4),
    (19.60, "27/2/2021", "15:13", "entregue", "27/2/2021", "15:53", 2, 3),
    (11.80, "27/2/2021", "19:34", "entregue", "27/2/2021", "20:14", 2, 6),
    (8.60, "27/2/2021", "20:14", "entregue", "27/2/2021", "20:54", 1, 10),
    (5.90, "28/2/2021", "8:45", "entregue", "28/2/2021", "9:25", 2, 8),
    (19.60, "28/2/2021", "13:38", "entregue", "28/2/2021", "14:18", 2, 4),
    (8.60, "28/2/2021", "15:57", "entregue", "28/2/2021", "16:37", 2, 4),
    (19.20, "28/2/2021", "19:51", "entregue", "28/2/2021", "20:31", 2, 10),
    (8.60, "28/2/2021", "23:20", "entregue", "1/3/2021", "0:00", 2, 8),
    (17.20, "1/3/2021", "8:55", "entregue", "1/3/2021", "9:35", 2, 12),
    (19.20, "1/3/2021", "11:21", "entregue", "1/3/2021", "12:01", 1, 6),
    (9.80, "1/3/2021", "13:43", "entregue", "1/3/2021", "14:23", 2, 8),
    (19.60, "1/3/2021", "17:02", "entregue", "1/3/2021", "17:42", 1, 4),
    (8.60, "1/3/2021", "21:58", "entregue", "1/3/2021", "22:38", 2, 11),
    (19.20, "2/3/2021", "9:21", "entregue", "2/3/2021", "10:01", 1, 11),
    (8.60, "2/3/2021", "13:43", "entregue", "2/3/2021", "14:23", 1, 4),
    (14.00, "2/3/2021", "15:47", "entregue", "2/3/2021", "16:27", 3, 2),
    (5.90, "2/3/2021", "19:18", "entregue", "2/3/2021", "19:58", 2, 7),
    (19.60, "2/3/2021", "23:34", "entregue", "3/3/2021", "0:14", 1, 10),
    (8.60, "2/3/2021", "23:40", "entregue", "3/3/2021", "0:20", 1, 11),
    (17.10, "3/3/2021", "11:16", "entregue", "3/3/2021", "11:56", 1, 6),
    (32.60, "3/3/2021", "14:18", "entregue", "3/3/2021", "14:58", 2, 12),
    (45.50, "3/3/2021", "18:34", "entregue", "3/3/2021", "19:14", 2, 3),
    (16.60, "3/3/2021", "19:59", "entregue", "3/3/2021", "20:39", 2, 7),
    (32.60, "3/3/2021", "21:45", "entregue", "3/3/2021", "22:25", 1, 7),
    (17.10, "3/3/2021", "23:08", "entregue", "3/3/2021", "23:48", 1, 1),
    (29.20, "4/3/2021", "8:09", "entregue", "4/3/2021", "8:49", 1, 9),
    (17.10, "4/3/2021", "10:35", "entregue", "4/3/2021", "11:15", 1, 1),
    (45.50, "4/3/2021", "10:42", "entregue", "4/3/2021", "11:22", 1, 2),
    (16.60, "4/3/2021", "15:17", "entregue", "4/3/2021", "15:57", 3, 5),
    (16.60, "4/3/2021", "16:28", "entregue", "4/3/2021", "17:08", 1, 9),
    (6.00, "4/3/2021", "21:22", "entregue", "4/3/2021", "22:02", 1, 3),
    (29.20, "5/3/2021", "9:21", "entregue", "5/3/2021", "10:01", 1, 1),
    (45.50, "5/3/2021", "11:19", "entregue", "5/3/2021", "11:59", 4, 2),
    (14.60, "5/3/2021", "13:02", "entregue", "5/3/2021", "13:42", 4, 5);
INSERT INTO encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, id_estaf, id_cli) 
VALUES 
    (45.50, "5/3/2021", "14:32", "atribuida", 1, 9),
    (16.60, "5/3/2021", "19:15", "atribuida",2, 7);
INSERT INTO encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega,  id_cli) 
VALUES 
    (14.60, "5/3/2021", "19:35", "aceite", 12),
    (29.85, "5/3/2021", "21:40", "pendente", 3),
    (5.50, "5/3/2021", "21:40", "pendente", 2);
INSERT INTO encomenda (enc_preco_total, enc_data_pedido, enc_hora_pedido,  enc_estado_entrega, enc_data_entrega, enc_hora_entrega, id_estaf, id_cli)
VALUES 
    (19.50, "25/3/2021", "11:19", "entregue", "25/3/2021", "11:59", 1, 6),
    (14.50, "10/2/2021", "13:20", "entregue", "10/2/2021", "13:59", 2, 7);

INSERT INTO encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, enc_prod_preco_venda) 
VALUES
    (1, 28, 2, 4.50),
    (1, 34, 2, 2.50),
    (2, 29, 1, 6.95),
    (2, 35, 1, 2.00),
    (3, 32, 1, 2.40),
    (3, 30, 1, 5.95),
    (3, 34, 1, 2.50),
    (4, 1, 1, 3.90),
    (4, 4, 1, 2.20),
    (4, 7, 1, 2.50),
    (5, 3, 2, 5.90),
    (6, 1, 2, 3.90),
    (6, 2, 2, 5.90),
    (7, 3, 2, 5.90),
    (8, 5, 1, 5.90),
    (9, 1, 1, 3.90),
    (9, 4, 1, 2.20),
    (9, 7, 1, 2.50),
    (10, 1, 1, 3.90),
    (10, 2, 1, 5.90),
    (10, 4, 2, 2.20),
    (10, 7, 2, 2.50),
    (11, 5, 1, 5.90),
    (12, 1, 2, 3.90),
    (12, 2, 2, 5.90),
    (13, 3, 2, 5.90),
    (14, 1, 1, 3.90),
    (14, 4, 1, 2.20),
    (14, 7, 1, 2.50),
    (15, 5, 1, 5.90),
    (16, 1, 2, 3.90),
    (16, 2, 2, 5.90),
    (17, 1, 1, 3.90),
    (17, 4, 1, 2.20),
    (17, 7, 1, 2.50),
    (18, 1, 1, 3.90),
    (18, 2, 1, 5.90),
    (18, 4, 2, 2.20),
    (18, 7, 2, 2.50),
    (19, 1, 1, 3.90),
    (19, 4, 1, 2.20),
    (19, 7, 1, 2.50),
    (20, 1, 2, 3.90),
    (20, 4, 2, 2.20),
    (20, 7, 2, 2.50),
    (21, 1, 1, 3.90),
    (21, 2, 1, 5.90),
    (21, 4, 2, 2.20),
    (21, 7, 2, 2.50),
    (22, 1, 1, 3.90),
    (22, 2, 1, 5.90),
    (23, 1, 2, 3.90),
    (23, 2, 2, 5.90),
    (24, 1, 1, 3.90),
    (24, 4, 1, 2.20),
    (24, 7, 1, 2.50),
    (25, 1, 1, 3.90),
    (25, 2, 1, 5.90),
    (25, 4, 2, 2.20),
    (25, 7, 2, 2.50),
    (26, 1, 2, 3.90),
    (26, 4, 2, 2.20),
    (26, 7, 2, 2.50),
    (27, 28, 2, 4.50),
    (27, 34, 2, 2.50),
    (28, 5, 1, 5.90),
    (29, 1, 2, 3.90),
    (29, 2, 2, 5.90),
    (30, 1, 1, 3.90),
    (30, 4, 1, 2.20),
    (30, 7, 1, 2.50),
    (31, 9, 1, 14.60),
    (31, 19, 1, 2.50),
    (32, 17, 2, 16.30),
    (33, 9, 1, 14.60),
    (33, 12, 1, 14.60),
    (33, 15, 1, 16.30),
    (34, 12, 1, 14.60),
    (34, 20, 1, 2.00),
    (35, 16, 2, 16.30),
    (36, 13, 1, 14.60),
    (36, 19, 1, 2.50),
    (37, 10, 2, 14.60),
    (38, 11, 1, 14.60),
    (38, 19, 1, 2.50),
    (39, 9, 1, 14.60),
    (39, 12, 1, 14.60),
    (39, 15, 1, 16.30),
    (40, 12, 1, 14.60),
    (40, 20, 1, 2.00),
    (41, 10, 1, 14.60),
    (41, 20, 1, 2.00),
    (42, 22, 1, 3.50),
    (42, 25, 1, 2.00),
    (42, 27, 1, 0.50),
    (43, 11, 2, 14.60),
    (44, 10, 1, 14.60),
    (44, 11, 1, 14.60),
    (44, 18, 1, 16.30),
    (45, 13, 1, 14.60),
    (46, 10, 1, 14.60),
    (46, 11, 1, 14.60),
    (46, 18, 1, 16.30),
    (47, 12, 1, 14.60),
    (47, 19, 1, 2.50),
    (48, 10, 1, 14.60),
    (49, 26, 1, 9.95),
    (49, 23, 2, 9.95),
    (50, 21, 1, 3.50),
    (50, 25, 1, 2.00),
    (51, 37, 1, 17.50),
    (51, 43, 1, 2.00),
    (52, 40, 1, 14.50);

INSERT INTO estabelecimento_serve_concelho (id_conc, id_estab) 
VALUES 
    (1506, 1),
    (1507, 1),
    (1510, 1),
    (1511, 1),
    (1512, 1),
    (1513, 1),
    (1502, 1),
    (1503, 1),
    (1504, 1),
    (1505, 1),
    (1106, 2),
    (1506, 2),
    (1507, 2),
    (1510, 2),
    (1511, 2),
    (1512, 2),
    (1513, 2),
    (1502, 2),
    (1503, 2),
    (1504, 2),
    (1503, 3),
    (1510, 3),
    (1511, 3),
    (1512, 3),
    (1106, 4),
    (1107, 4),
    (1110, 4),
    (1508, 5),
    (1511, 5),
    (1512, 5),
    (1502, 5),
    (1503, 5),
    (1506, 5);

INSERT INTO estafeta_entrega_concelho (id_conc, id_estaf) 
VALUES 
    (1506, 1),
    (1507, 1),
    (1510, 1),
    (1511, 1),
    (1512, 1),
    (1513, 1),
    (1508, 1),
    (1509, 1),
    (1501, 1),
    (1502, 1),
    (1106, 2),
    (1506, 2),
    (1507, 2),
    (1510, 2),
    (1511, 2),
    (1512, 2),
    (1513, 2),
    (1508, 2),
    (1509, 2),
    (1501, 2),
    (1503, 3),
    (1106, 3),
    (1107, 3),
    (1110, 3),
    (1106, 4),
    (1110, 4),
    (1110, 5);

INSERT INTO cliente_estabelecimentos_favoritos (id_cli, id_estab) 
VALUES 
    (2, 4),
    (3, 3),
    (5, 4),
    (5, 2);
