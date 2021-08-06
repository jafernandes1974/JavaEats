-- mostra administrador

select * from utilizador where util_perfil="administrador";

-- mostra clientes

select * from utilizador where util_perfil="cliente";

-- mostra estafetas

select * from utilizador where util_perfil="estafeta";

-- mostra estabelecimentos

select * from utilizador where util_perfil="estabelecimento";

-- mostra estafetas com carta de condução

select *  from estafeta where estaf_categoria_carta is not null;

-- mostra moradas dos estabelecimentos

SELECT util_nome, util_morada from utilizador where util_perfil="estabelecimento";

-- mostra produtos
 
select * from produto;

-- mostra produtos servidos pelo estabelecimento 1

select * from produto where id_estab=1;



