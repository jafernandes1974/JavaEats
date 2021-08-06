/*
delete from cliente;
delete from utilizador ;
delete from  estafeta;
delete from estabelecimento;
*/
SET @logo="C:\Users\José\Desktop\Laboratório\basedados\JavaEats.jpg";

SET @foto_cli="C:\Users\José\Desktop\Laboratório\basedados\foto_cli.jpg";

insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Filipa Martins","fma1@email.pt","ativo","346908344","953284447","72!GLgZH","Rua do Meio, 50, 2950-555, Palmela",FALSE,"administrador");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Fábio Bravo","fbr2@email.pt","ativo","352240346","954913951","44!SfT_b","Rua do Início, 99, 2830-152 Barreiro",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Sandra Pereira","spe3@email.pt","ativo","329939894","923878710","15!FGE]r","Avenida da Liberdade, 59, 1120-780, Lisboa",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("João Messias","jme4@email.pt","ativo","328564326","964775283","54!XXF^k","Rua do Alto, 33, 2900-455, Setúbal",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("André Pombo","apo5@email.pt","ativo","247694338","953438013","36!Nx]bS","Rua de Cima, 28, 2950-155, Palmela",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Andreia Plácido","apl6@email.pt","ativo","359076841","923349296","25!VCWUh","Avenida da República, 2B, 1100-034, Lisboa",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Catarina Cerejo","cce7@email.pt","ativo","335894356","919173299","53!PCW^o","Praça da Virtude, 120-122, 2860-243, Moita",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Daniel Malhado","dma8@email.pt","ativo","255931074","952925859","92!MpiUK","Rua 25 de Abril, 23A r/c dir 2860-524 Moita",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Júlio Simões","jsi9@email.pt","ativo","346413527","914609691","20!DA[Tw","Rua do Coreto, 8, 2950-458 Palmela",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Miguel Machado","mma10@email.pt","ativo","229969578","943566838","32!EPl^x","Rua da Paz dos Anjos, s/n, 2830 Barreiro",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Paulo Costa","pco11@email.pt","ativo","379046837","966060111","39!TNEBh","Rua de baixo, 340, 2950-575, Palmela",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Paulo Covas","pco12@email.pt","ativo","285667241","960965566","85!TVZee","Avenida da Liberdade, 111, 1100-241, Lisboa",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Tiago Landeiroto","tla13@email.pt","ativo","213706474","969570075","15!IY\tz","Praça da Vitória,1, 2860-003, Moita",FALSE,"cliente");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Vítor Nuno","vnu14@email.pt","ativo","202322873","936246615","28!W_xo`","Rua 1º de Maio, 43, 2955-253 Palmela",FALSE,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("Wilson Veterano","wve15@email.pt","ativo","219118782","937276101","47!FoWNO","Rua do Futuro,1 8, 2950-008 Palmela",FALSE,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("José Fernandes","jfe16@email.pt","ativo","359475457","959685084","87!B]ZVx","Rua do Fim, 1, 1100-000, Lisboa",FALSE,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("João Cunha","jcu17@email.pt","ativo","345233522","929515724","86!NXsPq","Rua do Futuro,1 8, 2950-008 Palmela",FALSE,"estafeta");
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil) values("João Morais","jmo18@email.pt","ativo","322903749","936003012","55!SFOyl","Rua do Passado,32, 2950-014 Palmela",TRUE,"estafeta");

select * from utilizador;

insert into estafeta ( estaf_data_nascimento,   estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values (STR_TO_DATE("5/3/1964", "%e/%c/%Y"),"A","148423307", TRUE, 101660639, TRUE,@foto_cli,14);
insert into estafeta ( estaf_data_nascimento,   estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values (STR_TO_DATE("16/4/1982", "%e/%c/%Y"),"B","321349304", TRUE, 222057836, TRUE,@foto_cli,15);
insert into estafeta ( estaf_data_nascimento,   estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values (STR_TO_DATE("11/10/1967", "%e/%c/%Y"),NULL,"115751793", TRUE, 164365331, TRUE,@foto_cli,16);
insert into estafeta ( estaf_data_nascimento,   estaf_categoria_carta, estaf_iban, estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil,  id_util) values (STR_TO_DATE("28/11/1972", "%e/%c/%Y"),"A","171688168", TRUE, 264075421, TRUE,@foto_cli,17);

insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("28/10/1974", "%e/%c/%Y"),"153982046",@foto_cli,1504,2);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("8/1/1971", "%e/%c/%Y"),"301508130",@foto_cli,1106,3); 
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("7/5/1951", "%e/%c/%Y"),"221528190",@foto_cli,1512,4);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("23/12/1957", "%e/%c/%Y"),"118356912",@foto_cli,1508,5);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("4/1/1977", "%e/%c/%Y"),"389424002",@foto_cli,1106,6);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("4/2/1995", "%e/%c/%Y"),"153106271",@foto_cli,1506,7);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("21/5/1983", "%e/%c/%Y"),"170958235",@foto_cli,1506,8);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("17/12/1986", "%e/%c/%Y"),"262998975",@foto_cli,1508,9);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("20/7/1978", "%e/%c/%Y"),"152427881",@foto_cli,1504,10);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("4/7/1982", "%e/%c/%Y"),"189373943",@foto_cli,1508,11);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("14/3/1998", "%e/%c/%Y"),"136986328",@foto_cli,1506,12);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("5/11/1975", "%e/%c/%Y"),"379753946",@foto_cli,1506,13);
insert into cliente ( cli_data_nascimento,   cli_cartao_credito, cli_foto_perfil, id_conc, id_util) values (STR_TO_DATE("17/1/1983", "%e/%c/%Y"),"297242313",@foto_cli,1508,14);


select * from utilizador;



 -- ESTABELECIMENTOS-----------------------------------------------------------------------ESTABELECIMENTOS----------------------------------
 
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil)
        values("Macdonalds", "macdon@mail.pt", "ativo", "56753677","922222321",
        "W#FFhty54","Parque das Merenda, 1a, 2830-125, Barreiro",FALSE,  "Estabelecimento"); 
       
insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util)
			values ("PT35234353534", "Hamburgers",  @logo, "8:00-24:00", 19);
      
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil)
        values("PizzaHut", "pihu@mail.pt", "ativo", "567453691", "958212221",
       "Q!ERT%4", "Rua Fantasma, 13, 2900-725, Setúbal", FALSE,"Estabelecimento");   
 
 insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util)
			values ("PT25562456224", "Pizas", @logo,"8:00-24:00", 20);
            	
   
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil)
        values("KFC", "kfc@mail.pt", "ativo", "5674523423","92562389",
        "56Y45654","Centro Comercial do Comércio, 18C, 2830-125, Barreiro",FALSE, "Estabelecimento");
        
 insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util)
			values ("PT2593265584", "Frango", @logo, "8:00-24:00",21);  
            
            
        
      
insert into utilizador (util_nome, util_email, util_estado, util_nif, util_telemovel, util_password, util_morada, util_bloqueado, util_perfil)
        values("Burger King", "buki@mail.pt", "ativo", "56746788", "915822214",
        "%E4345654", "Travessa das Almas, 23, 1000-725, Lisboa", FALSE,"Estabelecimento");  
        
insert into estabelecimento ( estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, id_util)
			values ("PT2587113534", "Hamburgers", @logo, "8:00-24:00", 22);        
  
  
        
 select * from cliente;