import com.google.gson.Gson;
import spark.Request;
import spark.Response;
import utils.freemarker.FreemarkerContext;
import utils.freemarker.FreemarkerEngine;
import utils.sqlite3.DBRow;
import utils.sqlite3.DBRowList;
import utils.sqlite3.SQLiteConn;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Objects;
import static spark.Spark.*;

public class Application {

    //variável data controlo do formulário
    public static DateTimeFormatter formatterDate = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    public static LocalDate dataControlo = LocalDate.now().minusYears(18);

    private static String getSessionUserID(Request request){
        DBRow utilizador = request.session().attribute("utilizador");
        return utilizador.get("util_id").toString();
    }

    private static ArrayList<String> data(){
        ArrayList<String> data = new ArrayList<>();
        DateTimeFormatter formatterDate, formatterHour;
        formatterDate = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        formatterHour = DateTimeFormatter.ofPattern("HH:mm");
        String dia = LocalDate.now().format(formatterDate);
        String hora = LocalTime.now().format(formatterHour);
        data.add(dia);
        data.add(hora);
        return data;
    }

    private static void enviarNotificacao(String texto, SQLiteConn conn, DBRow pedido) {
        ArrayList<String> data = data();
        String sql = String.format("insert into notificacao (not_data, not_hora, not_texto, id_cli) values ('%s', '%s', '%s', %s)", data.get(0), data.get(1), texto, pedido.get("id_cli"));
        conn.executeUpdate(sql);
    }

    private static FreemarkerContext getDadosCliente(FreemarkerContext context, SQLiteConn conn, Request request, DBRow utilizador) {
        String util_id = getSessionUserID(request);
        String sql = "select * from cliente where id_util=" + util_id;
        DBRow cliente = conn.executeQuery(sql).first();
        context.put("cliente", cliente);
        sql = "select * from concelho where conc_id= " + cliente.get("id_conc");
        DBRow concelho = conn.executeQuery(sql).first();
        context.put("concelho", concelho);
        context.put("utilizador", utilizador);
        DBRow concelhoAtual = conn.executeQuery("select * from concelho join cliente on conc_id = id_conc where cli_id =" + cliente.get("cli_id")).first();
        context.put("concelhoAtual", concelhoAtual);
        DBRowList concelhos = conn.executeQuery("select * from concelho where NOT conc_id = " + concelhoAtual.get("conc_id"));
        context.put("concelhos", concelhos);
        context.put("dataControlo", dataControlo);  
        return context;
    }

    private static FreemarkerContext getDadosEstabelecimento(FreemarkerContext context, SQLiteConn conn, Request request, DBRow utilizador) {
        String util_id = getSessionUserID(request);
        context.put("utilizador", utilizador);
        String sql = "select * from estabelecimento where id_util=" + util_id;
        DBRow estabelecimento = conn.executeQuery(sql).first();
        context.put("estabelecimento", estabelecimento);
        DBRowList concelhosAtuais = conn.executeQuery("select *  from estabelecimento_serve_concelho join concelho on id_conc = conc_id where id_estab =" + estabelecimento.get("estab_id"));
        DBRowList concelhos = conn.executeQuery("select * from concelho join estabelecimento_serve_concelho on conc_id = id_conc where NOT id_estab = " + estabelecimento.get("estab_id") + " group by id_estab");
        String[] horario = estabelecimento.get("estab_horario").toString().split("-");
        String abertura = horario[0];
        String fecho = horario[1];
        context.put("concelhosAtuais", concelhosAtuais);
        context.put("concelhos", concelhos);
        context.put("abertura", abertura);
        context.put("fecho", fecho);
        return context;
    }

    private static FreemarkerContext getDadosEstafeta(FreemarkerContext context, SQLiteConn conn, Request request, DBRow utilizador) {
        context.put("utilizador", utilizador);
        String util_id = getSessionUserID(request);
        String sql = "select * from estafeta where id_util=" + util_id;
        DBRow estafeta = conn.executeQuery(sql).first();
        context.put("estafeta", estafeta);
        String transporte;
        if ((Integer) estafeta.get("estaf_veiculo_motorizado") == 1) {
            transporte = "Sim";
        } else {
            transporte = "Não";
        }
        context.put("transporte", transporte);
        String categoria = (String) estafeta.get("estaf_categoria_carta");
        if (categoria == null) {
            categoria = "-";
        }
        context.put("categoria", categoria);
        sql = "select * from estafeta_entrega_concelho join concelho on conc_id = id_conc where id_estaf=" + estafeta.get("estaf_id");
        DBRowList concelhosAtuais = conn.executeQuery(sql);
        context.put("concelhosAtuais", concelhosAtuais);
        DBRowList concelhos = conn.executeQuery("select * from concelho join estafeta_entrega_concelho on conc_id = id_conc where NOT id_estaf = " + estafeta.get("estaf_id") + " group by id_estaf");
        context.put("concelhos", concelhos);
        context.put("dataControlo", dataControlo);  
        return context;
    }

    //Método para inicializar os contextos para os gets dos registos
    private static FreemarkerContext iniciaContexto (Request request, SQLiteConn conn, String perfil){
        //inicia um contexto vazio
        FreemarkerContext context = new FreemarkerContext();
        String nome = "";
        context.put("nome", nome);
        String email = "";
        context.put("email", email);
        String telemovel = "";
        context.put("telemovel", telemovel);
        String nif = "";
        context.put("nif", nif);
        String morada = "";
        context.put("morada", morada);
        DBRowList concelhos = conn.executeQuery("select * from concelho");
        context.put("concelhos", concelhos);

        String dataNascimento = "";
        String horario = "";
        String cozinha = "";
        String niss = "";
        String iban="";

        if (!perfil.equals("estabelecimento")){
            context.put("dataNascimento", dataNascimento);
            context.put("dataControlo", dataControlo.format(formatterDate));
        }else{
            context.put("horario", horario);
            context.put("cozinha", cozinha);
        }

        if(!perfil.equals("cliente")) {
            context.put("iban", iban);
        }

        if(perfil.equals("estafeta")){
            context.put("niss", niss);
        }
        return  context;
    }

    //Verificacao se o utilizador é novo //REVER
    private static FreemarkerContext novoUtilizador(Request request, SQLiteConn conn, String perfil) {
        // verifica se o utilizador já existe
        String nome = request.queryParams("nome");
        String telemovel = request.queryParams("telemovel");
        String morada = request.queryParams("morada");
        String email = request.queryParams("email");
        String nif = request.queryParams("nif");
        String niss=" ";

        FreemarkerContext context = iniciaContexto (request, conn, perfil);
        String sql;

        sql = String.format("select * from utilizador where util_email='%s'", email);

        DBRow utilizador = conn.executeQuery(sql).first();

        if (utilizador != null) {
            context.put("nome", nome);
            context.put("telemovel", telemovel);
            context.put("morada", morada);
            context.put("nif", nif);
            context.put("repetido", email);
            return context;
        }

        if (perfil.equals("estafeta")) {
            niss = request.queryParams("niss");

            sql = String.format("select * from estafeta where estaf_niss='%s'", niss);

            utilizador = conn.executeQuery(sql).first();

            if (utilizador != null) {
                context.put("nome", nome);
                context.put("telemovel", telemovel);
                context.put("morada", morada);
                context.put("nif", nif);
                context.put("repetido", niss);
                return context;
            }
        }
        context= new FreemarkerContext();
        return context;
    }

    public static void main(String[] args) {

        // Configure Spark
        port(8000);
        staticFiles.externalLocation("src/resources");

        // Configure freemarker engine
        FreemarkerEngine engine = new FreemarkerEngine("src/resources/templates");

        // Configure database connection
        SQLiteConn conn = SQLiteConn.getSharedInstance();
        conn.init("src/data/database.db");
        conn.recreate("src/data/database.sql");

        // Set up gson
        Gson gson = new Gson();

        // Set up endpoints
        get("/", (request, response) -> {
            //return engine.render(null, "homepage.html");
            response.redirect("/login/");
            return "";
        });

        //--------------------------------------------------------------------------------------------------------------------------------- CONTROLO DE ACESSO
        //controlo
        //<------------------------------------------------------------------------------------------------------------- LOGIN
        get("/login/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null) {
                return engine.render(null, "login.html");
            }else{
                String perfil = utilizador.get("util_perfil").toString();

                switch(perfil){
                    case "cliente": response.redirect("/homepage_cliente/");
                        break;
                    case "estabelecimento": response.redirect("/homepage_estabelecimento/");
                        break;
                    case "estafeta": response.redirect("/homepage_estafeta/");
                        break;
                    case "administrador": response.redirect("/homepage/");
                        break;
                }
                return "";
            }
        });

        post("/login/", (request, response) -> {
            FreemarkerContext context = new FreemarkerContext();
            String email = request.queryParams("email");
            String password = request.queryParams("password");
            String sql = String.format("select * from utilizador where util_email='%s' and util_password='%s'", email, password);
            DBRow utilizador = conn.executeQuery(sql).first();

            if (utilizador != null) {
                request.session().attribute("utilizador", utilizador);
                String perfil = (String) utilizador.get("util_perfil");

                if(utilizador.get("util_estado").equals("pendente")) {
                    context.put("pendente", true);
                    return engine.render(context, "login.html");
                }
                if(utilizador.get("util_estado").equals("inativo")) {
                    context.put("inativo", true);
                    return engine.render(context, "login.html");
                }
                if(utilizador.get("util_bloqueado").equals(1)) {
                    context.put("bloqueado", true);
                    return engine.render(context, "login.html");
                }
                if(!(utilizador.get("util_falhas").equals(0))) {
                    sql=String.format("update utilizador set util_falhas=0 where util_email='%s'", email);
                    conn.executeUpdate(sql);
                }

                switch (perfil) {
                    case "cliente":
                        response.redirect("/homepage_cliente/");
                        break;
                    case "estabelecimento":
                        response.redirect("/homepage_estabelecimento/");
                        break;
                    case "estafeta":
                        response.redirect("/homepage_estafeta/");
                        break;
                    case "administrador":
                        response.redirect("/homepage/");
                        break;
                }
                return "";
            }
            context.put("login_error", true);

            sql = String.format("select * from utilizador where util_email='%s' ", email);
            DBRow utilizadorFalhou = conn.executeQuery(sql).first();

            if(utilizadorFalhou != null) {
                int falhas=Integer.parseInt(utilizadorFalhou.get("util_falhas").toString());
                falhas++;

                sql=String.format("update utilizador set util_falhas=%s where util_email='%s'", falhas, email);
                conn.executeUpdate(sql);

                if (falhas>=3){
                    sql=String.format("update utilizador set util_bloqueado=1 where util_email='%s'", email);
                    conn.executeUpdate(sql);
                    context.put("bloqueado", true);
                    return engine.render(context, "login.html");
                }
            }
            return engine.render(context, "login.html");
        });

        //<------------------------------------------------------------------------------------------------------------- LOGOUT
        get("/logout/", (request, response) -> {
            request.session().removeAttribute("utilizador");
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- PEDIDO RECUPERAR PASSWORD

        get("/recuperar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null) {
                return engine.render(null, "recuperar.html");

            }
            //request.session().attribute("utilizador", utilizador);
            response.redirect("/login/");
            return "";

        });

        post("/recuperar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador == null) {
                String email = request.queryParams("email");
                String sql = String.format("select util_email from utilizador where util_email='%s'", email);
                DBRow emailAlvo = conn.executeQuery(sql).first();

                if (emailAlvo != null) {
                    request.session().attribute("email", emailAlvo);
                    response.redirect("/recuperar_password/");
                    return "";
                }
                FreemarkerContext context = new FreemarkerContext();
                context.put("email_not_found", true);
                return engine.render(context, "recuperar.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ESCOLHER NOVA PASSWORD
        get("/recuperar_password/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador == null) {
                DBRow email = request.session().attribute("email");

                if (email != null) {
                    return engine.render(null, "recuperar_password.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        post("/recuperar_password/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null) {
                String password1 = request.queryParams("password1");
                String password2 = request.queryParams("password2");

                DBRow email = request.session().attribute("email");
                String emailAlvo = email.get("util_email").toString();

                if (password1.equals(password2)){
                    String sql = String.format("update utilizador set util_password = '%s' where util_email = '%s'", password1, emailAlvo);
                    conn.executeUpdate(sql);
                    request.session().removeAttribute("email");
                    response.redirect("/login/");
                    return "";
                }
                FreemarkerContext context = new FreemarkerContext();
                context.put("passwords_not_equal", true);
                return engine.render(context, "recuperar_password.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ALTERAR PASSWORD UTILIZADOR REGISTADO
        get("/alterar_password/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null) {
                FreemarkerContext context = new FreemarkerContext();
                String util_id = request.params(":id");
                if (utilizador.get("util_id").toString().equals(util_id)) {
                    context.put("utilizador", utilizador);
                    return engine.render(context, "alterar_password.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        post("/alterar_password/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            String util_id = request.params(":id");
            if (utilizador != null && Objects.equals(utilizador.get("util_id"), util_id)) {
                String password1 = request.queryParams("password1");
                String password2 = request.queryParams("password2");
                String password3 = request.queryParams("password3");
                FreemarkerContext context = new FreemarkerContext();

                if (utilizador.get("util_password").equals(password1)) {
                    if (password2.equals(password3)) {
                        String sql = String.format("update utilizador set util_password = '%s' where util_id = %s", password2, utilizador.get("util_id"));
                        conn.executeUpdate(sql);
                        context.put("passwordAlterada", true);
                        String perfil = utilizador.get("util_perfil").toString();
                        switch (perfil) {
                            case "cliente":
                                context = getDadosCliente(context, conn, request, utilizador);
                                return engine.render(context, "alterar_dados_cliente.html");
                            case "estabelecimento":
                                context = getDadosEstabelecimento(context, conn, request, utilizador);
                                return engine.render(context, "alterar_dados_estabelecimento.html");
                            case "estafeta":
                                context = getDadosEstafeta(context, conn, request, utilizador);
                                return engine.render(context, "alterar_dados_estafeta.html");
                        }
                        return "";
                    } else {
                        context.put("passwords_not_equal", true);
                        context.put("utilizador", utilizador);
                        return engine.render(context, "alterar_password.html");
                    }
                } else {
                    context.put("wrong_password", true);
                    context.put("utilizador", utilizador);
                    return engine.render(context, "alterar_password.html");
                }
            } else {
                response.redirect("/login/");
                return "";
            }
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES DE CONTA
        get("/conta/", (Request request, Response response) -> {
            if (request.session().attribute("utilizador") != null) {
                FreemarkerContext context = new FreemarkerContext();
                DBRow utilizador = request.session().attribute("utilizador");
                String perfil = utilizador.get("util_perfil").toString();
                context.put("utilizador", utilizador);

                switch (perfil) {
                    case "cliente":
                        context = getDadosCliente(context, conn, request, utilizador);
                        return engine.render(context, "conta_cliente.html");
                    case "estabelecimento":
                        context = getDadosEstabelecimento(context, conn, request, utilizador);
                        return engine.render(context, "conta_estabelecimento.html");
                    case "estafeta":
                        context = getDadosEstafeta(context, conn, request, utilizador);
                        return engine.render(context, "conta_estafeta.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ALTERAR CONTA
        get("/conta/alterar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            FreemarkerContext context = new FreemarkerContext();

            if (utilizador != null){
                switch(utilizador.get("util_perfil").toString()){
                    case "cliente":
                        context = getDadosCliente(context, conn, request, utilizador);
                        return engine.render(context, "alterar_dados_cliente.html");
                    case "estafeta":
                        context = getDadosEstafeta(context, conn, request, utilizador);
                        return engine.render(context, "alterar_dados_estafeta.html");

                    case "estabelecimento":
                        context = getDadosEstabelecimento(context, conn, request, utilizador);
                        return engine.render(context, "alterar_dados_estabelecimento.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DESATIVAR CONTA
        get("/desativar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null) {
                FreemarkerContext context = new FreemarkerContext();
                String perfil = utilizador.get("util_perfil").toString();
                context.put("utilizador", utilizador);

                //Controlo para processos a decorrer, dependentes da conta
                switch (perfil){
                    case "estafeta":
                        context = getDadosEstafeta(context, conn, request, utilizador);
                        String sql = "select * from estafeta where estaf_disponivel = 0 and id_util=" + utilizador.get("util_id");
                        DBRow disponivel = conn.executeQuery(sql).first();
                        if (disponivel != null) {
                            context.put("naoDesativa", true);
                            return engine.render(context, "conta_estafeta.html");
                        }
                        break;

                    case "estabelecimento":
                        context = getDadosEstabelecimento(context, conn, request, utilizador);

                        sql = "select * from listar_encomendas as lenc join encomenda as e on lenc.id_enc = e.enc_id join listar_estabelecimentos as le on lenc.estab_id = le.estab_id where (NOT enc_estado_entrega = 'entregue') and le.estab_util_id =" + utilizador.get("util_id");

                        DBRow encomendas = conn.executeQuery(sql).first();
                        if(encomendas != null) {
                            if(!(encomendas.get("enc_estado_entrega").toString().equals("entregue"))) {
                            context.put("naoDesativa", true);
                            return engine.render(context, "conta_estabelecimento.html");
                            }
                        }
                        break;

                    case "cliente":
                        context = getDadosCliente(context, conn, request, utilizador);

                        sql = "select * from encomenda join listar_clientes on id_cli = cli_id where (NOT enc_estado_entrega = 'entregue') and cli_util_id =" + utilizador.get("util_id");
                        encomendas = conn.executeQuery(sql).first();
                        if(encomendas != null) {
                            if (!(encomendas.get("enc_estado_entrega").toString().equals("entregue"))) {
                                context.put("naoDesativa", true);
                                return engine.render(context, "conta_cliente.html");
                            }
                        }
                        break;
                }
                return engine.render(context, "desativar.html");
            }
            response.redirect("/login/");
            return "";
        });

        post("/desativar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null)  {
                String sql="update utilizador set util_estado='inativo' where util_id="+utilizador.get("util_id");
                conn.executeUpdate(sql);

                request.session().removeAttribute("utilizador");
                request.session().attribute("utilizador");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- REATIVAR CONTA
        get("/reativar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador != null) {
                request.session().removeAttribute("utilizador");
            }
            return engine.render(null, "reativar.html");
        });

        post("/reativar/", (request, response) -> {
            String email = request.queryParams("email");
            String sql = String.format("select * from utilizador where util_email='%s'", email);
            DBRow utilizador = conn.executeQuery(sql).first();
            FreemarkerContext context= new FreemarkerContext();

            if (utilizador != null && utilizador.get("util_estado").equals("inativo")) {

                sql= String.format("update utilizador set util_estado='ativo' where util_id='%s'", utilizador.get("util_id"));
                conn.executeUpdate(sql);

                context.put("reativacao", true);

                return engine.render(context, "login.html");
            }
            context.put("email_not_found", true);
            return engine.render(context, "reativar.html");
        });


        //--------------------------------------------------------------------------------------------------------------------------------- REGISTO DE UTILIZADOR
        //registo
        //<------------------------------------------------------------------------------------------------------------- REGISTO (CLIENTE)
        get("/registo_cliente/", (request, response) -> {
            if (request.session().attribute("utilizador") == null){
                return engine.render(iniciaContexto (request, conn,"cliente"), "registo_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        post("/registo_cliente/add/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null) {
                String password1 = request.queryParams("password1");
                String password2 = request.queryParams("password2");
                String nome = request.queryParams("nome");
                String email = request.queryParams("email");
                String nif = request.queryParams("nif");
                String telemovel = request.queryParams("telemovel");
                String morada = request.queryParams("morada");
                String dataNascimento = request.queryParams("dataNascimento");
                String foto = "/images/" + request.queryParams("foto");
                String concelho = request.queryParams("concelho");

                FreemarkerContext context =novoUtilizador(request, conn, "cliente");

                if (!context.isEmpty()) {
                    return engine.render(context, "registo_cliente.html");
                }

                if (LocalDate.parse(dataNascimento, formatterDate).isAfter(dataControlo)) {
                    context = iniciaContexto (request, conn, "cliente");
                    context.put("menor", true);
                    return engine.render(context, "registo_cliente.html");
                }

                if (password1.equals(password2)){
                    //insert into utilizador

                    String sql = String.format("insert into utilizador (util_nome, util_email, util_estado, util_nif, " +
                            "util_telemovel, util_password, util_morada, util_bloqueado, util_perfil, util_falhas) " +
                            "values ('%s', '%s', 'ativo', '%s', '%s', '%s', '%s', 0,'cliente', 0)", nome, email, nif, telemovel, password1, morada);

                    //id do ultimo insert
                    int util_id = conn.executeUpdate(sql);

                    //insert into cliente
                    DBRow getConcID = conn.executeQuery("select * from concelho where conc_nome= '" + concelho + "'").first();
                    int conc_id = (Integer) getConcID.get("conc_id");

                    sql = String.format("insert into cliente (cli_data_nascimento, cli_foto_perfil, id_conc, id_util) " +
                            "values ('%s', '%s', %s, %s)", dataNascimento, foto, conc_id, util_id);
                    conn.executeUpdate(sql);
                    context = new FreemarkerContext();
                    context.put("sucesso", true);
                    return engine.render(context, "login.html");
                }
                context = new FreemarkerContext();
                context.put("nome", nome);
                context.put("email", email);
                context.put("telemovel", telemovel);
                context.put("nif", nif);
                context.put("morada", morada);
                context.put("dataNascimento", dataNascimento);
                context.put("dataControlo", dataControlo.format(formatterDate));
                DBRowList concelhos = conn.executeQuery("select * from concelho");
                context.put("concelhos", concelhos);
                context.put("passwords_not_equal", true);
                return engine.render(context, "registo_cliente.html");

            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- REGISTO (ESTABELECIMENTO)
        get("/registo_estabelecimento/", (request, response) -> {
            if (request.session().attribute("utilizador") == null) {
                return engine.render(iniciaContexto (request, conn,"estabelecimento"), "registo_estabelecimento.html");
            }
            response.redirect("/login/");
            return "";
        });

        post("/registo_estabelecimento/add/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null) {
                String nome = request.queryParams("nome");
                String email = request.queryParams("email");
                String telemovel = request.queryParams("telemovel");
                String morada = request.queryParams("morada");
                String[] concelhos = request.queryParamsValues("concelhos");
                String logo = "/images/" + request.queryParams("logo");
                String horario = request.queryParams("abertura") + " - " + request.queryParams("fecho");
                String cozinha = request.queryParams("cozinha");
                String nif = request.queryParams("nif");
                String iban = request.queryParams("iban");
                String password1 = request.queryParams("password1");
                String password2 = request.queryParams("password2");

                 
                FreemarkerContext context =novoUtilizador(request, conn, "estabelecimento");

                if (!context.isEmpty()) {
                    return engine.render(context, "registo_estabelecimento.html");
                }

                if (password1.equals(password2)){

                    //insert into utilizador
                    String sql = String.format("insert into utilizador (util_nome, util_email, util_estado, util_nif, " +
                            "util_telemovel, util_password, util_morada, util_bloqueado, util_perfil, util_falhas) " +
                            "values ('%s', '%s', 'pendente', '%s', '%s', '%s', '%s', 0,'estabelecimento', 0)", nome, email, nif, telemovel, password1, morada);

                    int util_id = conn.executeUpdate(sql); //Update base de dados + id do ultimo insert (id utilizador)

                    //insert into estabelecimento
                    sql = String.format("insert into estabelecimento (estab_iban, estab_tipo_cozinha, estab_logo, estab_horario, " +
                            "id_util) values ('%s', '%s', '%s', '%s', %s)", iban, cozinha, logo, horario, util_id);

                    int estab_id = conn.executeUpdate(sql); //Update base de dados + id do ultimo insert (id estabelecimento)

                    //insert into estabelecimento_serve_concelho
                    DBRow getConcID;
                    int conc_id;

                    for(String concelho: concelhos){
                        getConcID = conn.executeQuery("select * from concelho where conc_nome= '" + concelho + "'").first();
                        conc_id = (Integer) getConcID.get("conc_id"); //id do concelho
                        sql = String.format("insert into estabelecimento_serve_concelho (id_conc, id_estab) values (%s, %s)", conc_id, estab_id);
                        conn.executeUpdate(sql);
                    }
                    context = new FreemarkerContext();
                    context.put("sucesso", true);
                    context.put("pendente", true);
                    return engine.render(context, "login.html");
                }
                context = new FreemarkerContext();
                context.put("nome", nome);
                context.put("email", email);
                context.put("telemovel", telemovel);
                context.put("morada", morada);
                context.put("horario", horario);
                context.put("cozinha", cozinha);
                context.put("nif", nif);
                context.put("iban", iban);
                DBRowList concelhos2 = conn.executeQuery("select * from concelho");
                context.put("concelhos", concelhos2);
                context.put("passwords_not_equal", true);
                return engine.render(context, "registo_estabelecimento.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- REGISTO (ESTAFETA)
        get("/registo_estafeta/", (request, response) -> {
            if (request.session().attribute("utilizador") == null) {
                return engine.render(iniciaContexto (request, conn,"estafeta"), "registo_estafeta.html");
            }
            response.redirect("/login/");
            return "";
        });

        post("/registo_estafeta/add/", (request, response) -> {

            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador == null) {
                String nome = request.queryParams("nome");
                String foto = "/images/" + request.queryParams("estafFoto");
                String dataNascimento= request.queryParams("dataNascimento");
                String email= request.queryParams("email");
                String telemovel= request.queryParams("telemovel");
                String nif= request.queryParams("nif");
                String iban = request.queryParams("iban");
                String niss= request.queryParams("niss");
                String transporte = request.queryParams("transporte");
                String categoria;
                String morada = request.queryParams("morada");
                String[] concelhos = request.queryParamsValues("concelhos");

                String password1 = request.queryParams("password1");
                String password2 = request.queryParams("password2");

                 
                FreemarkerContext context =novoUtilizador(request, conn, "estafeta");

                if (!context.isEmpty()) {
                    return engine.render(context, "registo_estafeta.html");
                }

                if (LocalDate.parse(dataNascimento, formatterDate).isAfter(dataControlo)) {
                    context = iniciaContexto (request, conn, "estafeta");
                    context.put("menor", true);
                    return engine.render(context, "registo_estafeta.html");
                }

                if (password1.equals(password2)){

                    //insert into utilizador
                    String sql = String.format("insert into utilizador (util_nome, util_email, util_estado, util_nif, " +
                            "util_telemovel, util_password, util_morada, util_bloqueado, util_perfil, util_falhas) " +
                            "values ('%s', '%s', 'pendente', '%s', '%s', '%s', '%s', 0,'estafeta', 0)", nome, email, nif, telemovel, password1, morada);

                    int util_id = conn.executeUpdate(sql);//Update base de dados + id do ultimo insert (id utilizador)

                    //GET transporte + categoria
                    if (transporte.equals("0")){
                        categoria="NULL";
                    }else{
                        categoria=transporte;
                        transporte="1";
                    }

                    //insert into estafeta
                    sql = String.format("insert into estafeta (estaf_data_nascimento, estaf_categoria_carta, estaf_iban, " +
                                    "estaf_disponivel, estaf_niss, estaf_veiculo_motorizado, estaf_foto_perfil, id_util) " +

                                    "values ('%s', '%s', '%s', 1, '%s', %s, '%s', %s)", dataNascimento, categoria, iban,
                            niss, transporte, foto, util_id);

                    int estaf_id = conn.executeUpdate(sql); //Update base de dados + id do ultimo insert (id estafeta)

                    //insert into estafeta_entrega_concelho
                    DBRow getConcID;
                    int conc_id;

                    for(String concelho: concelhos){
                        getConcID = conn.executeQuery("select * from concelho where conc_nome= '" + concelho + "'").first();
                        conc_id = (Integer) getConcID.get("conc_id"); //id do concelho
                        sql = String.format("insert into estafeta_entrega_concelho (id_conc, id_estaf) values (%s, %s)", conc_id, estaf_id);
                        conn.executeUpdate(sql);
                    }
                    context = new FreemarkerContext();
                    context.put("sucesso", true);
                    context.put("pendente", true);
                    return engine.render(context, "login.html");
                }
                context = new FreemarkerContext();
                context.put("nome", nome);
                context.put("dataNascimento", dataNascimento);
                context.put("email", email);
                context.put("telemovel", telemovel);
                context.put("morada", morada);
                context.put("nif", nif);
                context.put("iban", iban);
                context.put("niss", niss);
                context.put("dataControlo", dataControlo.format(formatterDate));

                DBRowList concelhos2 = conn.executeQuery("select * from concelho");
                context.put("concelhos", concelhos2);
                context.put("passwords_not_equal", true);
                return engine.render(context, "registo_estafeta.html");
            }
            response.redirect("/login/");
            return "";
        });

        get("/condicoes/", (request, response) -> engine.render(null, "condicoes.html"));

        //--------------------------------------------------------------------------------------------------------------------------------- PERFIL - ADMIN
        //admin
        //<------------------------------------------------------------------------------------------------------------- HOMEPAGE ADMIN
        get("/homepage/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null){
                response.redirect("/login/");
                return "";
            }else{
                FreemarkerContext context = new FreemarkerContext();
                String util_id = getSessionUserID(request);

                utilizador = conn.executeQuery("select * from utilizador where util_id=" + util_id).first();

                context.put("utilizador", utilizador);

                String perfil = utilizador.get("util_perfil").toString();

                if (perfil.equals("administrador")) {
                    String sql = "select * from utilizador where util_perfil = 'estafeta' and util_estado = 'pendente'";
                    DBRowList estafetas = conn.executeQuery(sql);
                    context.put("estafetas", estafetas);

                    if (estafetas.first() == null){
                        context.put("sem_estafeta", true);
                    }

                    sql = "select * from utilizador where util_perfil = 'estabelecimento' and util_estado = 'pendente'";
                    DBRowList estabelecimentos = conn.executeQuery(sql);
                    context.put("estabelecimentos", estabelecimentos);

                    if (estabelecimentos.first() == null){
                        context.put("sem_estabelecimento", true);
                    }

                    sql = "select * from utilizador where util_id=" + util_id;
                    DBRow administrador = conn.executeQuery(sql).first();
                    context.put("administrador", administrador);
                    return engine.render(context, "homepage.html");
                }

                response.redirect("/login/");
                return "";
            }
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR CLIENTES (ADMIN)
        get("/consultar/clientes/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                FreemarkerContext context = new FreemarkerContext();
                String sql = "select * from utilizador where util_perfil = 'cliente' and util_estado = 'ativo'";
                DBRowList clientes = conn.executeQuery(sql);
                context.put("clientes", clientes);
                context.put("utilizador", utilizador);

                return engine.render(context, "consultar_clientes.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES CLIENTE (ADMIN)
        get("/consultar/clientes/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                    FreemarkerContext context = new FreemarkerContext();
                    String util_id = request.params(":id");
                    String sql = String.format("select * from listar_clientes join concelho on conc_id = cli_conc where cli_util_id = %s", util_id);
                    DBRow cliente = conn.executeQuery(sql).first();
                    context.put("cliente", cliente);
                    context.put("utilizador", utilizador);
                    String estado;
                    if ((Integer) cliente.get("util_bloqueado") == 0) {
                        estado = "Desbloqueado";
                    } else {
                        estado = "Bloqueado";
                    }
                    context.put("estado", estado);
                    return engine.render(context, "detalhes_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR ESTABELECIMENTOS (ADMIN)
        get("/consultar/estabelecimentos/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                FreemarkerContext context = new FreemarkerContext();
                String sql = "select * from utilizador where util_perfil = 'estabelecimento' and util_estado = 'ativo'";
                DBRowList estabelecimentos = conn.executeQuery(sql);
                context.put("utilizador", utilizador);
                context.put("estabelecimentos", estabelecimentos);
                return engine.render(context, "consultar_estabelecimentos.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES ESTABELECIMENTO (ADMIN)
        get("/consultar/estabelecimentos/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                    FreemarkerContext context = new FreemarkerContext();
                    String util_id = request.params(":id");
                    String sql = String.format("select * from listar_estabelecimentos where estab_util_id = %s", util_id);
                    DBRow estabelecimento = conn.executeQuery(sql).first();
                    DBRowList concelhos = conn.executeQuery(String.format("select * from listar_estabelecimentos join estabelecimento_serve_concelho on estab_id = id_estab join concelho on conc_id = id_conc where estab_util_id = %s", util_id));
                    context.put("estabelecimento", estabelecimento);
                    context.put("concelhos", concelhos);
                    context.put("utilizador", utilizador);
                    String estado;
                    if ((Integer) estabelecimento.get("util_bloqueado") == 0) {
                        estado = "Desbloqueado";
                    } else {
                        estado = "Bloqueado";
                    }
                    context.put("estado", estado);
                    return engine.render(context, "detalhes_estabelecimento.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR ESTAFETAS (ADMIN)
        get("/consultar/estafetas/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                FreemarkerContext context = new FreemarkerContext();
                String sql = "select * from utilizador where util_perfil = 'estafeta' and util_estado = 'ativo'";
                DBRowList estafetas = conn.executeQuery(sql);
                context.put("estafetas", estafetas);
                context.put("utilizador", utilizador);
                return engine.render(context, "consultar_estafetas.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES ESTAFETA (ADMIN)
        get("/consultar/estafetas/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                    FreemarkerContext context = new FreemarkerContext();
                    String util_id = request.params(":id");
                    String sql = String.format("select * from listar_estafetas where estaf_util_id = %s", util_id);
                    DBRow estafeta = conn.executeQuery(sql).first();
                    DBRowList concelhos = conn.executeQuery(String.format("select * from listar_estafetas join estafeta_entrega_concelho on estaf_id = id_estaf join concelho on conc_id = id_conc where estaf_util_id = %s", util_id));
                    context.put("estafeta", estafeta);
                    context.put("concelhos", concelhos);
                    context.put("utilizador", utilizador);
                    String transporte;
                    if ((Integer) estafeta.get("estaf_veiculo_motorizado") == 1) {
                        transporte = "Sim";
                    } else {
                        transporte = "Não";
                    }
                    context.put("transporte", transporte);
                    context.put("transporte", transporte);
                    String categoria = (String) estafeta.get("estaf_categoria_carta");
                    if (categoria == null) {
                        categoria = "-";
                    }
                    context.put("categoria", categoria);
                    String estado;
                    if ((Integer) estafeta.get("util_bloqueado") == 0) {
                        estado = "Desbloqueado";
                    } else {
                        estado = "Bloqueado";
                    }
                    context.put("estado", estado);
                    return engine.render(context, "detalhes_estafeta.html");

            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR BLOQUEADOS (ADMIN)
        get("/consultar/bloqueados/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);

                String sql = "select * from utilizador where util_bloqueado = 1";
                DBRowList utilizadores = conn.executeQuery(sql);
                context.put("utilizadores", utilizadores);

                if (utilizadores.first() == null){
                    context.put("sem_utilizadores", true);
                }

                return engine.render(context, "consultar_bloqueados.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DESBLOQUEAR CONTA (ADMIN)
        get("/consultar/:perfil/detalhes/:id/desbloquear/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            String util_id = request.params(":id");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                String sql = "update utilizador set util_bloqueado = 0, util_falhas=0 where util_id=" + util_id;
                conn.executeUpdate(sql);
                response.redirect("/consultar/bloqueados/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- BLOQUEAR CONTA (ADMIN)
        get("/consultar/:perfil/detalhes/:id/bloquear/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            String util_id = request.params(":id");
            String perfil = request.params(":perfil");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                String sql = "update utilizador set util_bloqueado = 1 where util_id=" + util_id;
                conn.executeUpdate(sql);
                response.redirect("/consultar/"+perfil+"/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ACEITAR PRE-REGISTOS (ADMIN)
        get("/consultar/:perfil/detalhes/:id/aceitar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            String util_id = request.params(":id");
            String perfil = request.params(":perfil");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador") && (perfil.equals("estafetas") || perfil.equals("estabelecimentos"))) {
                String sql = "update utilizador set util_estado = 'ativo' where util_id=" + util_id;
                conn.executeUpdate(sql);
                response.redirect("/homepage/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- REJEITAR PRE-REGISTOS (ADMIN)
        get("/consultar/:perfil/detalhes/:id/rejeitar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            String util_id = request.params(":id");
            String perfil = request.params(":perfil");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                if(perfil.equals("estafetas")) {
                    String sql = "delete from estafeta where id_util =" + util_id;
                    conn.executeUpdate(sql);
                    sql = "delete from utilizador where util_id=" + util_id;
                    conn.executeUpdate(sql);
                }
                if(perfil.equals("estabelecimentos")) {
                    String sql = "delete from estabelecimento where id_util =" + util_id;
                    conn.executeUpdate(sql);
                    sql = "delete from utilizador where util_id=" + util_id;
                    conn.executeUpdate(sql);
                }

                response.redirect("/homepage/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });


        //<------------------------------------------------------------------------------------------------------------- CONSULTAR ENCOMENDAS (ADMIN)
        get("/consultar/encomendas/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                FreemarkerContext context = new FreemarkerContext();
                String sql = "select * from encomenda join listar_encomendas on id_enc = enc_id left join listar_estafetas on id_estaf = estaf_id left join listar_clientes on id_cli = cli_id WHERE NOT enc_estado_entrega = 'em curso'";
                DBRowList encomendas = conn.executeQuery(sql);

                if (encomendas.first() == null) {
                    context.put("sem_pedidos", true);
                }
                context.put("utilizador", utilizador);
                context.put("encomendas", encomendas);
                return engine.render(context, "historico_encomendas_admin.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES ENCOMENDA (ADMIN)
        get("/consultar/encomendas/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("administrador")) {
                String enc_id = request.params(":id");
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                String sql = "select * from encomenda join listar_encomendas on id_enc = enc_id left join listar_estafetas on id_estaf = estaf_id left join listar_clientes on id_cli = cli_id left join concelho on cli_conc = conc_id where enc_id = " + enc_id;
                DBRow encomenda = conn.executeQuery(sql).first();
                context.put("encomenda", encomenda);
                // produtos do pedido
                DBRowList items = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id where enc_id = %s", enc_id));
                context.put("items", items);
                // estafeta
                String estafeta;
                if (encomenda.get("estaf_nome") == null) {
                    estafeta = "-";
                } else {
                    estafeta = encomenda.get("estaf_nome").toString();
                }
                context.put("estafeta", estafeta);
                // estabelecimento
                String estabelecimento;
                if (encomenda.get("estab_nome") == null) {
                    estabelecimento = "-";
                } else {
                    estabelecimento = encomenda.get("estab_nome").toString();
                }
                context.put("estabelecimento", estabelecimento);
                // estabelecimento
                String data_entrega;
                if (encomenda.get("enc_data_entrega") == null) {
                    data_entrega = "-";
                } else {
                    data_entrega = encomenda.get("enc_data_entrega").toString();
                }
                context.put("data_entrega", data_entrega);
                // estabelecimento
                String hora_entrega;
                if (encomenda.get("enc_hora_entrega") == null) {
                    hora_entrega = "-";
                } else {
                    hora_entrega = encomenda.get("enc_hora_entrega").toString();
                }
                context.put("hora_entrega", hora_entrega);
                return engine.render(context, "detalhes_encomenda.html");
            }
            response.redirect("/login/");
            return "";
        });

        //--------------------------------------------------------------------------------------------------------------------------------- PERFIL - CLIENTE
        //cliente
        //<------------------------------------------------------------------------------------------------------------- HOMEPAGE CLIENTE
        get("/homepage_cliente/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null) {
                response.redirect("/login/");
                return "";
            } else {
                FreemarkerContext context = new FreemarkerContext();
                //get user id
                String util_id = getSessionUserID(request);
                //get user
                utilizador = conn.executeQuery("select * from utilizador where util_id=" + util_id).first();
                context.put("utilizador", utilizador);
                //get perfil
                String perfil = utilizador.get("util_perfil").toString();

                if (perfil.equals("cliente")) {
                    String sql = "select * from  estabelecimento_serve_concelho as esc " +
                            "join listar_estabelecimentos as le on esc.id_estab=le.estab_id " +
                            "join cliente as c on esc.id_conc=c.id_conc " +
                            "where estab_estado = 'ativo' and c.id_util= " + util_id;

                    DBRowList estabelecimentos = conn.executeQuery(sql);

                    context.put("estabelecimentos", estabelecimentos);

                    DBRow cliente = conn.executeQuery("select * from cliente where id_util=" + utilizador.get("util_id")).first();

                    sql = "select distinct estab_tipo_cozinha from estabelecimento " +
                            "join estabelecimento_serve_concelho on estab_id = id_estab " +
                            "where id_conc=" + cliente.get("id_conc");

                    DBRowList tipos = conn.executeQuery(sql);
                    context.put("tipos", tipos);

                    sql="select * from cliente_estabelecimentos_favoritos as cef " +
                            "join listar_clientes as lc on cef.id_cli= lc.cli_id " +
                            "join listar_estabelecimentos as le on cef.id_estab=le.estab_id " +
                            "where cli_util_id="+util_id;
                    DBRowList favoritos = conn.executeQuery(sql);
                    if(!favoritos.isEmpty()) {
                        context.put("listaFavoritos", true);
                    }
                    return engine.render(context, "homepage_cliente.html");
                }
                response.redirect("/login/");
                return "";
            }
        });

        //<------------------------------------------------------------------------------------------------------------- FILTRAR RESTAURANTES
        post("/filtrar/", (request, response) -> {
            FreemarkerContext context = new FreemarkerContext();
            DBRow utilizador = request.session().attribute("utilizador");
            String util_id = getSessionUserID(request);

            if (utilizador != null) {
                context.put("utilizador", utilizador);
                String tipo_cozinha = request.queryParams("tipo_cozinha");

                String sql="select * from cliente_estabelecimentos_favoritos as cef " +
                        "join listar_clientes as lc on cef.id_cli= lc.cli_id " +
                        "join listar_estabelecimentos as le on cef.id_estab=le.estab_id " +
                        "where cli_util_id="+util_id;
                DBRowList favoritos = conn.executeQuery(sql);

                if (!favoritos.isEmpty()){
                    context.put("listaFavoritos", true);
                }

                if (!tipo_cozinha.equals("favoritos")){
                    sql = "select * from  estabelecimento_serve_concelho as esc join listar_estabelecimentos as le" +
                            " on esc.id_estab=le.estab_id join cliente as c on esc.id_conc=c.id_conc" +
                            " where c.id_util=" + utilizador.get("util_id") + " and estab_tipo_cozinha = '" + tipo_cozinha + "'";
                    context.put("escolhido", tipo_cozinha);
                }

                DBRowList estabelecimentos = conn.executeQuery(sql);
                context.put("estabelecimentos", estabelecimentos);

                DBRow cliente = conn.executeQuery("select * from cliente where id_util=" + utilizador.get("util_id")).first();

                sql =String.format("select distinct estab_tipo_cozinha from estabelecimento " +
                        "join estabelecimento_serve_concelho on estab_id = id_estab " +
                        "where id_conc=%s and estab_tipo_cozinha !='%s'", cliente.get("id_conc"), tipo_cozinha);

                DBRowList tipos = conn.executeQuery(sql);
                context.put("tipos", tipos);
                return engine.render(context, "homepage_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- NOTIFICAÇÕES
        get("/notificacoes/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                //cliente
                DBRow cliente = conn.executeQuery("select * from cliente where id_util =" + getSessionUserID(request)).first();
                //pedidos em curso
                DBRowList notificacoes = conn.executeQuery(String.format("select * from notificacao where id_cli = %s", cliente.get("cli_id")));
                context.put("notificacoes", notificacoes);

                if (notificacoes.first() == null) {
                    context.put("sem_notificacoes", true);
                }
                return engine.render(context, "notificacoes.html");

            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ALTERAR DADOS (CLIENTE)

        post("/conta/alterar/cliente/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").toString().equals("cliente")) {
                String nome = request.queryParams("altnome");
                String nif = request.queryParams("altnif");
                String telemovel = request.queryParams("alttelemovel");
                String morada = request.queryParams("altmorada");
                String dataNascimento = request.queryParams("altdnasc");
                String foto = "/images/" + request.queryParams("altfoto");
                String concelho = request.queryParams("altconcelho");

                // update utilizador
                String sql = String.format("update utilizador set util_nome = '%s', util_telemovel = '%s', util_morada = '%s', util_nif = '%s' where util_id = %s", nome, telemovel, morada, nif, getSessionUserID(request));
                conn.executeUpdate(sql);

                //update foto
                //validação necessária para ser compatível com diferentes browsers
                if (!foto.equals("/images/null") && !foto.equals("/images/")){
                    conn.executeUpdate(String.format("update cliente set cli_foto_perfil = '%s' where id_util = %s", foto, getSessionUserID(request)));
                }

                if (LocalDate.parse(dataNascimento, formatterDate).isAfter(dataControlo)) {
                    FreemarkerContext context;
                    context = iniciaContexto (request, conn, "cliente");
                    context.put("menor", true);
                    return engine.render(context, "alterar_dados_cliente.html");
                }

                //update cliente
                DBRow getConcID = conn.executeQuery("select * from concelho where conc_nome= '" + concelho + "'").first();
                int conc_id = (Integer) getConcID.get("conc_id");

                sql = String.format("update cliente set cli_data_nascimento = '%s', id_conc= %s where id_util = %s", dataNascimento, conc_id, getSessionUserID(request));
                conn.executeUpdate(sql);

                //atualizar utilizador da sessão
                sql = String.format("select * from utilizador where util_id = %s", getSessionUserID(request));
                utilizador = conn.executeQuery(sql).first();
                request.session().attribute("utilizador", utilizador);
                response.redirect("/conta/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR PEDIDOS EM CURSO (CLIENTE)
        get("/pedidos_em_curso/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                //cliente
                DBRow cliente = conn.executeQuery("select * from cliente where id_util =" + getSessionUserID(request)).first();
                //pedidos em curso
                DBRowList pedidos_em_curso = conn.executeQuery(String.format("select * from encomenda where id_cli = %s and (enc_estado_entrega = 'pendente' or enc_estado_entrega = 'aceite' or enc_estado_entrega = 'atribuida')", cliente.get("cli_id")));
                context.put("pedidos_em_curso", pedidos_em_curso);
                if (pedidos_em_curso.first() == null) {
                    context.put("sem_pedidos", true);
                }
                return engine.render(context, "pedidos_em_curso_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR DETALHES DE PEDIDOS EM CURSO (CLIENTE)
        get("/pedidos_em_curso/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                // cliente
                DBRow cliente = conn.executeQuery("select * from cliente where id_util =" + getSessionUserID(request)).first();
                // id da encomenda
                String id = request.params(":id");
                //detalhes do pedido
                DBRow pedido = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto ON enc_id = id_enc join produto on id_prod = prod_id join listar_estabelecimentos on estab_id = id_estab left join listar_estafetas on estaf_id = id_estaf where enc_id=%s", id)).first();
                if (pedido.get("id_cli").equals(cliente.get("cli_id"))) {
                    context.put("pedido", pedido);
                    // produtos do pedido
                    DBRowList items = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id where enc_id = %s", id));
                    context.put("items", items);
                    // estafeta
                    String estafeta;
                    if (pedido.get("estaf_nome") == null) {
                        estafeta = "-";
                    } else {
                        estafeta = pedido.get("estaf_nome").toString();
                    }
                    context.put("estafeta", estafeta);
                    // estabelecimento
                    String estabelecimento;
                    if (pedido.get("estab_nome") == null) {
                        estabelecimento = "-";
                    } else {
                        estabelecimento = pedido.get("estab_nome").toString();
                    }
                    context.put("estabelecimento", estabelecimento);
                    return engine.render(context, "detalhes_pedido_em_curso_cliente.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR HISTORICO DE PEDIDOS (CLIENTE)
        get("/historico_pedidos_cliente/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null) {
                if (utilizador.get("util_perfil").equals("cliente")) {
                    FreemarkerContext context = new FreemarkerContext();
                    //cliente
                    DBRow cliente = conn.executeQuery("select * from cliente where id_util =" + getSessionUserID(request)).first();
                    //historico de pedidos entregues
                    DBRowList pedidos = conn.executeQuery(String.format("select * from encomenda where id_cli = %s and enc_estado_entrega = 'entregue'", cliente.get("cli_id")));
                    context.put("pedidos", pedidos);
                    context.put("utilizador", utilizador);
                    if (pedidos.first() == null) {
                        context.put("sem_pedidos", true);
                    }
                    return engine.render(context, "historico_pedidos_cliente.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR DETALHES DE PEDIDOS ENTREGUES (CLIENTE)
        get("/detalhes_pedido_entregue/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                // id da encomenda
                String id = request.params(":id");
                // cliente
                DBRow cliente = conn.executeQuery(String.format("select * from cliente join encomenda on cli_id = id_cli where id_util = %s and enc_id = %s", getSessionUserID(request), id)).first();
                if (cliente != null) {
                    FreemarkerContext context = new FreemarkerContext();
                    //detalhes do pedido
                    DBRow pedido = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto ON enc_id = id_enc join produto on id_prod = prod_id join listar_estabelecimentos on estab_id = id_estab left join listar_estafetas on estaf_id = id_estaf where enc_id=%s", id)).first();
                    context.put("pedido", pedido);
                    // produtos do pedido
                    DBRowList items = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id where enc_id = %s", id));
                    context.put("items", items);
                    context.put("utilizador", utilizador);
                    return engine.render(context, "detalhes_pedido_entregue_cliente.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR CARRINHO (CLIENTE)
        get("/carrinho/", (request, response) -> {

            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                FreemarkerContext context = new FreemarkerContext();
                //get user
                utilizador = conn.executeQuery("select * from utilizador where util_id=" + getSessionUserID(request)).first();
                context.put("utilizador", utilizador);

                DBRow cliente = conn.executeQuery("select * from cliente where id_util= " + utilizador.get("util_id")).first();
                context.put("cliente", cliente);

                //get encomenda em curso
                DBRow getIdPedido = conn.executeQuery("select * from encomenda where id_cli= " +cliente.get("cli_id")+ " and enc_estado_entrega = 'em curso'").first();
                context.put("getIdPedido", getIdPedido);

                //verifica se existe encomenda em andamento
                if (getIdPedido != null){
                    context.put("pedido", true);
                    //get conteudo do carrinho
                    DBRowList conteudo_carrinho = conn.executeQuery("select * from encomenda join encomenda_contem_produto ON enc_id = id_enc join produto on id_prod = prod_id where enc_id= " + getIdPedido.get("enc_id"));
                    //if tem produtos na encomenda, retorna conteudo. Else, retorna vazio
                    if(conteudo_carrinho.first() != null){
                        double prod, a, b, total = 0.0;
                        for (DBRow item: conteudo_carrinho){
                            a = Double.parseDouble(item.get("enc_prod_preco_venda").toString());
                            b = Double.parseDouble(item.get("enc_prod_quantidade").toString());
                            prod = a *b;
                            total += prod;
                        }

                        context.put("total", total);
                        context.put("conteudo_carrinho", conteudo_carrinho);
                    }else{
                        context.put("vazio", true);
                    }
                }
                return engine.render(context, "carrinho.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- APAGAR DO CARRINHO (CLIENTE)
        get("/carrinho/:id/delete/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {

                //get id do produto a eliminar
                String id_prod = request.params(":id");

                String util_id = utilizador.get("util_id").toString();
                DBRow cliente = conn.executeQuery("select * from cliente where id_util= " + util_id).first();

                //get ID encomenda
                DBRow getIdPedido = conn.executeQuery("select * from encomenda where id_cli= " +cliente.get("cli_id") + " and enc_estado_entrega = 'em curso'").first();
                if (getIdPedido != null) {
                    int enc_id = (Integer) getIdPedido.get("enc_id");
                    DBRow encomenda = conn.executeQuery("select * from encomenda where enc_id= " + enc_id).first();

                    if (encomenda != null && encomenda.get("id_cli").toString().equals(cliente.get("cli_id").toString())) {
                        String sql = String.format("delete from encomenda_contem_produto where id_prod= %s", id_prod);
                        conn.executeUpdate(sql);
                    }
                }
                response.redirect("/carrinho/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ATUALIZAR CARRINHO (CLIENTE)
        post("/carrinho/:id/atualizar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {

                //get id do produto e qtd a atualizar
                String id_prod = request.params(":id");
                int qtd = Integer.parseInt(request.queryParams("qtd"));

                String util_id = utilizador.get("util_id").toString();
                DBRow cliente = conn.executeQuery("select * from cliente where id_util= " + util_id).first();

                //get ID encomenda
                DBRow getIdPedido = conn.executeQuery("select * from encomenda where id_cli= " +cliente.get("cli_id") + " and enc_estado_entrega = 'em curso'").first();
                if (getIdPedido != null) {
                    int enc_id = (Integer) getIdPedido.get("enc_id");
                    DBRow encomenda = conn.executeQuery("select * from encomenda where enc_id= " + enc_id).first();

                    if (encomenda != null && encomenda.get("id_cli").equals(cliente.get("cli_id"))) {
                        String sql = String.format("update encomenda_contem_produto set enc_prod_quantidade = %s where id_enc=%s and id_prod=%s", qtd, enc_id, id_prod);
                        conn.executeUpdate(sql);
                    }
                }
                response.redirect("/carrinho/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONFIRMAR ENCOMENDA (CLIENTE)
        get("/carrinho/confirmar/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if(utilizador != null && utilizador.get("util_perfil").equals("cliente")){
                DBRow cliente = conn.executeQuery("select * from cliente where id_util = " + utilizador.get("util_id")).first();
                //get ID encomenda
                DBRow getIdPedido = conn.executeQuery("select * from encomenda where id_cli= " +cliente.get("cli_id") + " and enc_estado_entrega = 'em curso'").first();
                int enc_id = Integer.parseInt(request.params(":id"));
                if(getIdPedido.get("enc_id").equals(enc_id)) {
                    //detalhes do pedido
                    DBRowList conteudo = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto ON enc_id = id_enc join produto on id_prod = prod_id join listar_estabelecimentos on estab_id = id_estab left join listar_estafetas on estaf_id = id_estaf where enc_id=%s", enc_id));

                    //get total do pedido
                    double prod, a, b, total = 0.0;
                    for (DBRow item: conteudo){
                        a = Double.parseDouble(item.get("enc_prod_preco_venda").toString());
                        b = Double.parseDouble(item.get("enc_prod_quantidade").toString());
                        prod = a *b;
                        total += prod;
                    }
                    DBRow pedido = conteudo.first();
                    FreemarkerContext context = new FreemarkerContext();

                    ArrayList<String> data = data();
                    context.put("utilizador", utilizador);
                    context.put("total", total);
                    context.put("data", data.get(0));
                    context.put("hora", data.get(1));
                    context.put("datas", data);
                    context.put("conteudo", conteudo);
                    context.put("pedido", pedido);

                    return engine.render(context, "confirmar_encomenda_cliente.html");
                }}
            response.redirect("/login/");
            return "";
        });

        get("/carrinho/confirmar/:id/finalizar/:total/", (request, response) ->{
            DBRow utilizador = request.session().attribute("utilizador");
            if(utilizador != null && utilizador.get("util_perfil").equals("cliente")){
                String id = request.params(":id");
                String total = request.params(":total");

                total = total.replace(",", ".");
                ArrayList<String> datas = data();

                String data = datas.get(0);
                String hora = datas.get(1);

                String sql = String.format("update encomenda set " +
                        "enc_preco_total = %s, " +
                        "enc_data_pedido ='%s', " +
                        "enc_hora_pedido ='%s'," +
                        "enc_estado_entrega ='%s' where enc_id = %s", total, data, hora, "pendente", id);
                conn.executeUpdate(sql);

                //confirmar se foi bem sucedido
                String erroEnc = sql;
                if (erroEnc == null){
                    FreemarkerContext context = new FreemarkerContext();
                    context.put("erroEnc", erroEnc);
                    context.put("utilizador", utilizador);
                    return engine.render(context, "homepage_cliente.html");
                }
            }
            response.redirect("/homepage_cliente/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CATALOGO (CLIENTE)
        //entra no catálogo a partir da homepage
        get("/catalogo/:estabelecimento/", (request, response) -> {
            DBRow utilizador=request.session().attribute("utilizador");

            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")){
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);

                String estab = request.params(":estabelecimento");
                String sql = "select * from listar_estabelecimentos where estab_nome= '" + estab + "'";
                DBRow estabelecimento = conn.executeQuery(sql).first();
                context.put("estabelecimento", estabelecimento);

                sql = "select * from listar_produtos as lp join produto as p on lp.prod_id=p.prod_id  where prod_estado=1 and estab_nome= '" + estab + "'";

                DBRowList produtos = conn.executeQuery(sql);
                context.put("produtos", produtos);

                sql = "select * from listar_clientes where cli_util_id= " + utilizador.get("util_id");
                DBRow cliente = conn.executeQuery(sql).first();
                context.put("cliente", cliente);

                sql ="select * from cliente_estabelecimentos_favoritos where id_cli="+cliente.get("cli_id");
                DBRowList favoritos = conn.executeQuery(sql);

                int isFavorito=0;

                for(DBRow est: favoritos ) {
                    if (favoritos!=null && est.get("id_estab").toString().equals(estabelecimento.get("estab_id").toString()))
                        isFavorito=1;
                }
                context.put("isFavorito", isFavorito);
                return engine.render(context, "catalogo_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        //-------------------------------------------------------------------------------------------------------------- ADICIONA AO CARRINHO (CLIENTE)
        //adiciona produto a uma encomenda na BD, ou cria uma encomenda e adiciona produto
        post("/adicionar_produto/:estabelecimento/:prod_id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {

                String sql = "select * from estafeta_entrega_concelho e join cliente c on e.id_conc = c.id_conc where id_util = " + utilizador.get("util_id");
                DBRow estafetas = conn.executeQuery(sql).first();
                if(estafetas == null) {
                    FreemarkerContext context = new FreemarkerContext();
                    DBRow cliente = conn.executeQuery("select * from cliente where id_util=" + utilizador.get("util_id")).first();

                    sql = "select * from  estabelecimento_serve_concelho as esc join listar_estabelecimentos as le" +
                            " on esc.id_estab=le.estab_id join cliente as c on esc.id_conc=c.id_conc" +
                            " where c.id_util= " + utilizador.get("util_id");

                    DBRowList estabelecimentos = conn.executeQuery(sql);

                    sql = "select distinct estab_tipo_cozinha from estabelecimento join estabelecimento_serve_concelho on estab_id = id_estab where id_conc=" + cliente.get("id_conc");

                    DBRowList tipos = conn.executeQuery(sql);
                    context.put("tipos", tipos);
                    context.put("sem_estafetas", true);
                    context.put("utilizador", utilizador);
                    context.put("estabelecimentos", estabelecimentos);
                    return engine.render(context, "homepage_cliente.html");
                }

                //apanha ID produto + estabelecimento + quantidade introduzida
                String prod_id = request.params(":prod_id");
                String estab = request.params(":estabelecimento");
                int quant = Integer.parseInt(request.queryParams("quantidade"));

                //get produto a ser adicionado
                sql = "select *  from produto where prod_id='" + prod_id + "'";
                DBRow prod = conn.executeQuery(sql).first();

                //validar se encomenda existe
                DBRow cliente = conn.executeQuery("select * from listar_clientes where cli_util_id= " + utilizador.get("util_id")).first();
                DBRow getIdPedido = conn.executeQuery("select * from encomenda where id_cli= " +cliente.get("cli_id")+ " and enc_estado_entrega = 'em curso'").first();
                int enc_id;

                //se encomenda não existe, cria nova. Else, insere na existente
                if (getIdPedido != null){
                    enc_id = (Integer) getIdPedido.get("enc_id");
                }else{
                    sql = String.format("insert into encomenda (enc_estado_entrega, id_cli) values ('em curso', %s)", cliente.get("cli_id"));
                    enc_id = conn.executeUpdate(sql);
                }

                //verificar se tem quantidade inserida
                sql = String.format("select * from encomenda_contem_produto where id_enc=%s and id_prod=%s", enc_id, prod_id);
                DBRow ecp = conn.executeQuery(sql).first();

                //se sim, adiciona à quantidade existente
                if (ecp != null) {
                    int quantidade = Integer.parseInt(ecp.get("enc_prod_quantidade").toString());
                    quant += quantidade;
                }

                sql = "select * from encomenda_contem_produto join encomenda on id_enc = enc_id join produto on id_prod = prod_id join listar_estabelecimentos on id_estab = estab_id where id_enc = " + enc_id;
                DBRow estab2 = conn.executeQuery(sql).first();

                //Verifica se estabelecimento é o mesmo
                if(estab2 != null){
                    if (estab2.get("estab_nome").toString().equals(estab)) {

                        sql = String.format("replace into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, " +
                                "enc_prod_preco_venda) values( %s, %s, %s, %s) ", enc_id, prod_id, quant, prod.get("prod_preco_atual"));
                        conn.executeUpdate(sql);
                    }else{
                        FreemarkerContext context = new FreemarkerContext();
                        sql = "select * from  estabelecimento_serve_concelho as esc join listar_estabelecimentos as le"+
                                " on esc.id_estab=le.estab_id join cliente as c on esc.id_conc=c.id_conc"+
                                " where c.id_util= "+utilizador.get("util_id");

                        DBRowList estabelecimentos = conn.executeQuery(sql);
                        context.put("estab2", estab2);
                        context.put("estabelecimentos", estabelecimentos);
                        context.put("utilizador", utilizador);
                        context.put("erroEstab",true);

                        sql = "select distinct estab_tipo_cozinha from estabelecimento " +
                                "join estabelecimento_serve_concelho on estab_id = id_estab " +
                                "where id_conc=" + cliente.get("id_conc");

                        DBRowList tipos = conn.executeQuery(sql);
                        context.put("tipos", tipos);

                        return engine.render(context, "homepage_cliente.html");
                    }
                }else{
                    sql = String.format("replace into encomenda_contem_produto (id_enc, id_prod, enc_prod_quantidade, " +
                            "enc_prod_preco_venda) values( %s, %s, %s, %s) ", enc_id, prod_id, quant, prod.get("prod_preco_atual"));
                    conn.executeUpdate(sql);
                }
                response.redirect(String.format("/catalogo/%s/", estab));
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //-------------------------------------------------------------------------------------------------------------- ADICIONA AOS FAVORITOS (CLIENTE)
        post("/adicionar_favorito/:estabNome/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                String sql = "select * from listar_clientes where cli_util_id= " + getSessionUserID(request);
                FreemarkerContext context = new FreemarkerContext();

                context.put("utilizador", utilizador);

                DBRow cliente = conn.executeQuery(sql).first();
                String estabNome = request.params("estabNome");

                sql ="select * from listar_estabelecimentos where estab_nome='"+estabNome+"'";
                DBRow estabelecimento = conn.executeQuery(sql).first();

                sql = "select * from cliente_estabelecimentos_favoritos";
                DBRowList fav = conn.executeQuery(sql);

                sql = String.format("replace into cliente_estabelecimentos_favoritos (id_cli, id_estab) values (%s,%s)",
                        cliente.get("cli_id"), estabelecimento.get("estab_id"));
                conn.executeUpdate(sql);

                sql = "select * from cliente_estabelecimentos_favoritos";
                DBRowList fav1 = conn.executeQuery(sql);
                context.put("estabelecimento",estabelecimento);

                sql="select * from produto as p join listar_produtos as lp on p.prod_id=lp.prod_id where estab_nome= '"+ estabNome+"'";
                DBRowList produtos = conn.executeQuery(sql);
                context.put("produtos",produtos);
                context.put("isFavorito",1);

                return engine.render(context, "catalogo_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        //-------------------------------------------------------------------------------------------------------------- REMOVER DOS FAVORITOS (CLIENTE)
        post("/retirar_favorito/:estabnome/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador != null && utilizador.get("util_perfil").equals("cliente")) {
                String sql = "select * from listar_clientes where cli_util_id= " + getSessionUserID(request);
                FreemarkerContext context = new FreemarkerContext();

                DBRow cliente = conn.executeQuery(sql).first();
                String estabNome = request.params("estabnome");

                sql ="select * from listar_estabelecimentos where estab_nome='"+estabNome+"'";
                DBRow estabelecimento = conn.executeQuery(sql).first();

                sql = "select * from cliente_estabelecimentos_favoritos";
                DBRowList fav = conn.executeQuery(sql);

                sql=String.format("delete from cliente_estabelecimentos_favoritos where id_cli=%s and id_estab=%s",
                        cliente.get("cli_id"), estabelecimento.get("estab_id"));
                conn.executeUpdate(sql);

                sql="select * from cliente_estabelecimentos_favoritos";
                DBRowList fav1= conn.executeQuery(sql);

                context.put("estabelecimento",estabelecimento);
                context.put("utilizador", utilizador);

                sql="select * from produto as p join listar_produtos as lp on p.prod_id=lp.prod_id where estab_nome= '"+ estabNome+"'";

                DBRowList produtos = conn.executeQuery(sql);
                context.put("produtos",produtos);
                context.put("isFavorito",0);

                return engine.render(context, "catalogo_cliente.html");
            }
            response.redirect("/login/");
            return "";
        });

        //--------------------------------------------------------------------------------------------------------------------------------- PERFIL - ESTAFETA
        //estaf
        //<------------------------------------------------------------------------------------------------------------- HOMEPAGE ESTAFETA
        get("/homepage_estafeta/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador == null){
                response.redirect("/login/");
                return "";
            }else{
                FreemarkerContext context = new FreemarkerContext();
                //get user id
                String util_id = getSessionUserID(request);
                //get user
                utilizador = conn.executeQuery("select * from utilizador where util_id=" + util_id).first();
                context.put("utilizador", utilizador);
                //get perfil
                String perfil = utilizador.get("util_perfil").toString();
                if (perfil.equals("estafeta")) {
                    //estafeta
                    DBRow estafeta = conn.executeQuery("select * from estafeta where id_util =" + getSessionUserID(request)).first();
                    //entrega em curso?
                    DBRow entregaAtual = conn.executeQuery(String.format("select * from encomenda where id_estaf = %s and enc_estado_entrega = 'atribuida'", estafeta.get("estaf_id"))).first();

                    if (entregaAtual == null) {
                        //historico de pedidos pendentes
                        DBRowList pedidos = conn.executeQuery("select * from encomenda e "
                                + "join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id "
                                + "join listar_encomendas x on enc_id = id_enc "
                                + "join listar_estabelecimentos y on x.estab_id = y.estab_id "
                                + "join estafeta_entrega_concelho ec on id_conc = conc_id "
                                + "where enc_estado_entrega = 'aceite' and ec.id_estaf =" + estafeta.get("estaf_id"));
                        context.put("pedidos", pedidos);

                        if (pedidos.first() == null){
                            context.put("sem_pedidos_pendentes", true);
                        }
                        return engine.render(context, "homepage_estafeta.html");
                    }
                    String enc_id = entregaAtual.get("enc_id").toString();
                    DBRow pedido = conn.executeQuery("select * from encomenda e "
                            + "join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id "
                            + "join listar_encomendas x on enc_id = id_enc "
                            + "join listar_estabelecimentos y on x.estab_id = y.estab_id "
                            + "where enc_id=" + enc_id).first();
                    context.put("pedido", pedido);
                    context.put("entregaEmCurso", true);
                    return engine.render(context, "homepage_estafeta.html");
                }
                response.redirect("/login/");
                return "";
            }
        });

        //<------------------------------------------------------------------------------------------------------------- ALTERAR DADOS (ESTAFETA)

        post("/conta/alterar/estafeta/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estafeta")) {
                String nome = request.queryParams("altnome");
                String dataNascimento = request.queryParams("altdnasc");
                String telemovel = request.queryParams("alttelemovel");
                String morada = request.queryParams("altmorada");
                String[] concelhos = request.queryParamsValues("altconcelhos");
                String nif = request.queryParams("altnif");
                String iban = request.queryParams("altiban");
                String niss = request.queryParams("altniss");
                String transporte = request.queryParams("altcategoria");
                String categoria;
                String foto = "/images/" + request.queryParams("altfoto");

                DBRow niss2 = conn.executeQuery("select * from estafeta where estaf_niss=" + niss).first();
                DBRow estafeta = conn.executeQuery("select * from estafeta where id_util=" + getSessionUserID(request)).first();
                if(niss2 != null && !niss2.equals(estafeta)) {
                    FreemarkerContext context = new FreemarkerContext();
                    context = getDadosEstafeta(context, conn, request, utilizador);
                    context.put("niss", true);
                    return engine.render(context, "alterar_dados_estafeta.html");
                }

                //update utilizador
                String sql = String.format("update utilizador set util_nome = '%s', util_telemovel = '%s', util_morada = '%s', util_nif = '%s' where util_id = %s ",
                        nome, telemovel, morada, nif, getSessionUserID(request));
                conn.executeUpdate(sql);

                //update foto
                if (!foto.equals("/images/null") && !foto.equals("/images/")){
                    conn.executeUpdate(String.format("update estafeta set estaf_foto_perfil = '%s' "
                            + "where id_util = %s", foto, getSessionUserID(request)));
                }

                //GET transporte + categoria
                if (transporte.equals("0")){
                    categoria=null;
                }else{
                    categoria=transporte;
                    transporte="1";
                }

                //update estafeta
                sql = String.format("update estafeta set estaf_data_nascimento = '%s', estaf_iban = '%s', estaf_niss = '%s', estaf_veiculo_motorizado = '%s', estaf_categoria_carta = '%s' where id_util = %s",
                        dataNascimento, iban, niss, transporte, categoria, getSessionUserID(request));
                conn.executeUpdate(sql);
                estafeta = conn.executeQuery("select * from estafeta where id_util=" + getSessionUserID(request)).first();
                //update estafeta_entrega_concelho
                estafeta = conn.executeQuery("select * from estafeta where id_util = " + getSessionUserID(request)).first();
                sql = "delete from estafeta_entrega_concelho where id_estaf = " + estafeta.get("estaf_id");
                conn.executeUpdate(sql);
                DBRow getConcID;
                int conc_id;
                for(String concelho: concelhos){
                    getConcID = conn.executeQuery("select * from concelho where conc_nome= '" + concelho + "'").first();
                    conc_id = (Integer) getConcID.get("conc_id"); //id do concelho
                    sql = String.format("insert into estafeta_entrega_concelho (id_conc, id_estaf) values (%s, %s)", conc_id, estafeta.get("estaf_id"));
                    conn.executeUpdate(sql);
                }

                //atualizar utilizador da sessão
                sql = String.format("select * from utilizador where util_id = %s", getSessionUserID(request));
                utilizador = conn.executeQuery(sql).first();
                request.session().attribute("utilizador", utilizador);
                response.redirect("/conta/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR HISTORICO DE PEDIDOS ENTREGUES (ESTAFETA)
        get("/historico_pedidos_estafeta/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estafeta")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                //estafeta
                DBRow estafeta = conn.executeQuery("select * from estafeta where id_util =" + getSessionUserID(request)).first();
                //historico de pedidos entregues
                DBRowList pedidos = conn.executeQuery(String.format("select * from encomenda e "
                        + "join listar_clientes on id_cli = cli_id join listar_encomendas x on enc_id = id_enc "
                        + "join listar_estabelecimentos y on x.estab_id = y.estab_id "
                        + "where id_estaf = %s and enc_estado_entrega = 'entregue'", estafeta.get("estaf_id")));
                context.put("pedidos", pedidos);
                return engine.render(context, "historico_pedidos_estafeta.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES DO PEDIDO (ESTAFETA)
        get("/pedidos_estafeta/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estafeta")) {
                FreemarkerContext context = new FreemarkerContext();
                //id encomenda
                String enc_id = request.params(":id");
                //estafeta
                DBRow estafeta = conn.executeQuery("select * from estafeta where id_util =" + getSessionUserID(request)).first();
                //detalhes pedido
                DBRow pedido = conn.executeQuery("select * from encomenda e "
                        + "join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id "
                        + "join listar_encomendas x on enc_id = id_enc "
                        + "join listar_estabelecimentos y on x.estab_id = y.estab_id "
                        + "join estafeta_entrega_concelho ec on id_conc = conc_id "
                        + "where enc_id=" + enc_id).first();
                if (pedido != null && pedido.get("enc_estado_entrega").equals("aceite")) {

                    context.put("pedido", pedido);
                    context.put("utilizador", utilizador);
                    return engine.render(context, "detalhes_pedidos_estafeta.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ACEITAR PEDIDO (ESTAFETA)
        get("/pedidos_estafeta/detalhes/:id/aceitar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estafeta")) {
                FreemarkerContext context = new FreemarkerContext();
                //id encomenda
                String enc_id = request.params(":id");
                //estafeta
                DBRow estafeta = conn.executeQuery("select * from estafeta where id_util =" + getSessionUserID(request)).first();
                DBRow pedido = conn.executeQuery("select * from encomenda e "
                        + "join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id "
                        + "join listar_encomendas x on enc_id = id_enc "
                        + "join listar_estabelecimentos y on x.estab_id = y.estab_id "
                        + "join estafeta_entrega_concelho ec on id_conc = conc_id "
                        + "where enc_id=" + enc_id).first();
                if (pedido != null && pedido.get("enc_estado_entrega").equals("aceite")) {
                    //update do estado da encomenda
                    String sql = String.format("update encomenda set enc_estado_entrega = 'atribuida', id_estaf = %s where enc_id = %s", estafeta.get("estaf_id"), enc_id);
                    conn.executeUpdate(sql);
                    String texto = "O teu pedido #" + pedido.get("enc_id") + " foi atribuído ao estafeta " + utilizador.get("util_nome");
                    enviarNotificacao(texto, conn, pedido);

                    conn.executeUpdate("update estafeta set estaf_disponivel = 0 where estaf_id =" + estafeta.get("estaf_id"));

                    response.redirect("/homepage_estafeta/");
                    return "";
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONFIRMAR ENTREGA HOMEPAGE (ESTAFETA)
        get("/homepage_estafeta/confirmar/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estafeta")) {
                FreemarkerContext context = new FreemarkerContext();
                //id encomenda
                String enc_id = request.params(":id");
                //estafeta
                DBRow estafeta = conn.executeQuery("select * from estafeta where id_util =" + getSessionUserID(request)).first();
                DBRow pedido = conn.executeQuery(String.format("select * from encomenda where enc_id = %s and id_estaf = %s and enc_estado_entrega = 'atribuida'", enc_id, estafeta.get("estaf_id"))).first();
                if (pedido != null) {
                    //atualizar base dados
                    ArrayList<String> data = data();
                    String sql = String.format("update encomenda set enc_estado_entrega = 'entregue', enc_data_entrega = '%s', enc_hora_entrega = '%s' where enc_id = %s", data.get(0), data.get(1), enc_id);
                    conn.executeUpdate(sql);
                    conn.executeUpdate("update estafeta set estaf_disponivel = 1 where estaf_id =" + estafeta.get("estaf_id"));
                    String texto = "O teu pedido #" + pedido.get("enc_id") + " foi entregue";
                    enviarNotificacao(texto, conn, pedido);
                    response.redirect("/homepage_estafeta/");
                    return "";
                }
            }
            response.redirect("/login/");
            return "";
        });
        //--------------------------------------------------------------------------------------------------------------------------------- PERFIL - ESTABELECIMENTO
        //estab
        //<------------------------------------------------------------------------------------------------------------- HOMEPAGE ESTABELECIMENTO
        get("/homepage_estabelecimento/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");

            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")){
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);

                String sql = "select * from estabelecimento where id_util=" + utilizador.get("util_id");
                DBRow estabelecimento = conn.executeQuery(sql).first();
                context.put("estabelecimento", estabelecimento);

                //pedidos pendentes
                DBRowList pedidosPendentes = conn.executeQuery("SELECT * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id WHERE enc_estado_entrega = 'pendente' and id_estab = " + estabelecimento.get("estab_id") + " group by id_enc ");

                if (pedidosPendentes.first() == null) {
                    context.put("sem_pedidos_pendentes", true);
                }

                context.put("pedidosPendentes", pedidosPendentes);

                //pedidos aceites
                DBRowList pedidosAceites = conn.executeQuery("SELECT * from encomenda  join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id join listar_clientes_concelhos on id_cli = cli_id where (enc_estado_entrega = 'aceite' OR enc_estado_entrega = 'atribuida') and id_estab = " + estabelecimento.get("estab_id") + " group by id_enc ");
                context.put("pedidosAceites", pedidosAceites);
                if (pedidosAceites.first() == null) {
                    context.put("sem_pedidos_aceites", true);
                }

                return engine.render(context, "homepage_estabelecimento.html");
            }
            response.redirect("/login/");
            return "";
        });
        //<------------------------------------------------------------------------------------------------------------- ALTERAR DADOS (ESTABELECIMENTO)

        post("/conta/alterar/estabelecimento/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            String nome = request.queryParams("altnome");
            String telemovel = request.queryParams("alttelemovel");
            String morada = request.queryParams("altmorada");
            String[] concelhos = request.queryParamsValues("altconcelhos");
            String horario = request.queryParams("altabertura") + " - " + request.queryParams("altfecho");
            String cozinha = request.queryParams("altcozinha");
            String nif = request.queryParams("altnif");
            String iban = request.queryParams("altiban");
            String foto = "/images/" + request.queryParams("altfoto");

            //update utilizador
            String sql = String.format("update utilizador set util_nome = '%s', util_telemovel = '%s', util_morada = '%s', util_nif = '%s' where util_id = %s ",
                    nome, telemovel, morada, nif, getSessionUserID(request));
            conn.executeUpdate(sql);

            //update foto
            if (!foto.equals("/images/null") && !foto.equals("/images/")){
                conn.executeUpdate(String.format("update estabelecimento set estab_logo = '%s' "
                        + "where id_util = %s", foto, getSessionUserID(request)));
            }

            //update estabelecimento
            sql = String.format("update estabelecimento set estab_horario = '%s', estab_tipo_cozinha = '%s', estab_iban = '%s' where id_util = %s",
                    horario, cozinha, iban, getSessionUserID(request));
            conn.executeUpdate(sql);

            //update estabelecimento_serve_concelho
            DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util = " + getSessionUserID(request)).first();
            sql = "delete from estabelecimento_serve_concelho where id_estab = " + estabelecimento.get("estab_id");
            conn.executeUpdate(sql);
            DBRow getConcID;
            int conc_id;

            for(String concelho: concelhos){
                getConcID = conn.executeQuery("select * from concelho where conc_nome= '" + concelho + "'").first();
                conc_id = (Integer) getConcID.get("conc_id"); //id do concelho
                sql = String.format("insert into estabelecimento_serve_concelho (id_conc, id_estab) values (%s, %s)", conc_id, estabelecimento.get("estab_id"));
                conn.executeUpdate(sql);
            }

            //atualizar utilizador da sessão
            sql = String.format("select * from utilizador where util_id = %s", getSessionUserID(request));
            utilizador = conn.executeQuery(sql).first();
            request.session().attribute("utilizador", utilizador);
            response.redirect("/conta/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CONSULTAR HISTÓRICO DE PEDIDOS (ESTABELECIMENTO)
        get("/historico_pedidos_estabelecimento/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                //estabelecimento
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                context.put("estabelecimento", estabelecimento);
                //historico de pedidos entregues
                DBRowList pedidos = conn.executeQuery("SELECT * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id WHERE enc_estado_entrega = 'entregue' and id_estab = " + estabelecimento.get("estab_id") + " group by id_enc ");
                context.put("pedidos", pedidos);
                context.put("utilizador", utilizador);
                if (pedidos.first() == null) {
                    context.put("sem_pedidos", true);
                }
                return engine.render(context, "historico_pedidos_estabelecimento.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES DE PEDIDOS NO HISTÓRICO (ESTABELECIMENTO)

        get("/detalhes_pedido_entregue_estabelecimento/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                // id da encomenda
                String id = request.params(":id");
                // estabelecimento
                DBRow estabelecimento = conn.executeQuery(String.format("select * from estabelecimento where id_util = %s ", getSessionUserID(request))).first();

                FreemarkerContext context = new FreemarkerContext();
                //detalhes do pedido
                DBRow pedido = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto ON enc_id = id_enc join produto on id_prod = prod_id join listar_estabelecimentos on estab_id = id_estab left join listar_estafetas on estaf_id = id_estaf where enc_id=%s", id)).first();
                if (pedido.get("estab_id").equals(estabelecimento.get("estab_id"))) {
                    context.put("pedido", pedido);
                    context.put("utilizador", utilizador);
                    // produtos do pedido
                    DBRowList items = conn.executeQuery(String.format("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id where enc_id = %s", id));
                    context.put("items", items);
                    return engine.render(context, "detalhes_pedido_entregue_estabelecimento.html");
                }
                response.redirect("/login/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });
        //<------------------------------------------------------------------------------------------------------------- DETALHES DE PEDIDOS PENDENTES (ESTABELECIMENTO)
        get("/pedidos_estabelecimento/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                //id encomenda
                String enc_id = request.params(":id");
                //estafeta
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                //detalhes pedido
                DBRow pedido = conn.executeQuery("select * from encomenda  join encomenda_contem_produto on enc_id = id_enc "
                        + "join produto on id_prod = prod_id join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id where enc_id = " + enc_id).first();
                if (pedido.get("id_estab").equals(estabelecimento.get("estab_id"))) {
                    context.put("pedido", pedido);
                    context.put("utilizador", utilizador);
                    //lista de produtos da encomenda
                    DBRowList items = conn.executeQuery("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id where enc_id =" + enc_id);
                    context.put("items", items);
                    return engine.render(context, "detalhes_pedidos_pendentes_estabelecimento.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ACEITAR PEDIDO PENDENTE (ESTABELECIMENTO)
        get("/pedidos_estabelecimento/detalhes/:id/aceitar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                //id encomenda
                String enc_id = request.params(":id");
                //estabelecimento
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                //pedido
                DBRow pedido = conn.executeQuery("select * from encomenda  join encomenda_contem_produto on enc_id = id_enc "
                        + "join produto on id_prod = prod_id join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id where enc_id = " + enc_id).first();
                if (pedido.get("id_estab").equals(estabelecimento.get("estab_id"))) {
                    //update estado da encomenda
                    String sql = String.format("update encomenda set enc_estado_entrega = 'aceite' where enc_id = %s", enc_id);
                    conn.executeUpdate(sql);

                    String texto = "O estabelecimento " + utilizador.get("util_nome") + " aceitou o teu pedido #" + pedido.get("enc_id");
                    enviarNotificacao(texto, conn, pedido);
                    response.redirect("/homepage_estabelecimento/");
                    return "";
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- REJEITAR PEDIDO PENDENTE (ESTABELECIMENTO)
        get("/pedidos_estabelecimento/detalhes/:id/rejeitar/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                //id encomenda
                String enc_id = request.params(":id");
                //estabelecimento
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                //pedido
                DBRow pedido = conn.executeQuery("select * from encomenda  join encomenda_contem_produto on enc_id = id_enc "
                        + "join produto on id_prod = prod_id join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id where enc_id = " + enc_id).first();
                if (pedido.get("id_estab").equals(estabelecimento.get("estab_id"))) {
                    //update estado da encomenda
                    String sql = String.format("update encomenda set enc_estado_entrega = 'rejeitado' where enc_id = %s", enc_id);
                    conn.executeUpdate(sql);

                    String texto = "O estabelecimento " + utilizador.get("util_nome") + " rejeitou o teu pedido #" + pedido.get("enc_id");
                    enviarNotificacao(texto, conn, pedido);
                    response.redirect("/homepage_estabelecimento/");
                    return "";
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- CATÁLOGO (ESTABELECIMENTO)
        get("/catalogo_estabelecimento/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                //estabelecimento
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                context.put("estabelecimento", estabelecimento);
                //catálogo
                DBRowList catalogo = conn.executeQuery("SELECT * from produto where id_estab =  " + estabelecimento.get("estab_id"));
                context.put("catalogo", catalogo);
                if (catalogo.first() == null) {
                    context.put("sem_produtos", true);
                }
                return engine.render(context, "catalogo_estabelecimento.html");
            } else {
                response.redirect("/login/");
                return "";
            }
        });

        //<------------------------------------------------------------------------------------------------------------- PEDIDOS ACEITES (ESTABELECIMENTO)
        get("/pedidos_aceites_estabelecimento/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                //estabelecimento
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                context.put("estabelecimento", estabelecimento);
                //pendentes
                DBRowList pedidos = conn.executeQuery("SELECT * from encomenda  join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id join listar_clientes_concelhos on id_cli = cli_id where (enc_estado_entrega = 'aceite' OR enc_estado_entrega = 'atribuida') and id_estab = " + estabelecimento.get("estab_id") + " group by id_enc ");
                context.put("pedidos", pedidos);
                context.put("utilizador", utilizador);
                if (pedidos.first() == null) {
                    context.put("sem_pedidos", true);
                }
                return engine.render(context, "pedidos_aceites_estabelecimento.html");
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- DETALHES PEDIDOS ACEITES (ESTABELECIMENTO)
        get("/pedidos_aceites_estabelecimento/detalhes/:id/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                context.put("utilizador", utilizador);
                //id encomenda
                String enc_id = request.params(":id");
                //estabelecimento
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + getSessionUserID(request)).first();
                //detalhes pedido
                DBRow pedido = conn.executeQuery("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id join listar_clientes on id_cli = cli_id join concelho on cli_conc = conc_id where enc_id = " + enc_id).first();
                if(pedido.get("id_estab").equals(estabelecimento.get("estab_id")) && (pedido.get("enc_estado_entrega").equals("aceite") || pedido.get("enc_estado_entrega").equals("atribuida"))) {
                    context.put("pedido", pedido);
                    context.put("utilizador", utilizador);
                    //lista de produtos da encomenda
                    DBRowList items = conn.executeQuery("select * from encomenda join encomenda_contem_produto on enc_id = id_enc join produto on id_prod = prod_id where enc_id =" + enc_id);
                    context.put("items", items);
                    return engine.render(context, "detalhes_pedidos_aceites_estabelecimento.html");
                } }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ALTERAR CATÁLOGO (ESTABELECIMENTO)
        get("/alterar_produto/:prodId/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util=" + getSessionUserID(request)).first();
                String prodId = request.params(":prodId");

                String sql = "select * from produto as p join listar_produtos  as le on p.prod_id=le.prod_id where p.prod_id= "+prodId;

                DBRow produto=conn.executeQuery(sql).first();
                if(produto.get("id_estab").equals(estabelecimento.get("estab_id"))) {

                    if(produto.get("prod_estado").equals(1)){
                        context.put("disponivel", true);
                    }
                    context.put("produto", produto);
                    context.put("utilizador", utilizador);

                    return engine.render(context, "alterar_produto.html");
                }
            }
            response.redirect("/login/");
            return "";
        });

        post("/alterar_produto/:prodId/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                String prodId = request.params(":prodId");
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util =" + utilizador.get("util_id")).first();
                DBRow produto = conn.executeQuery("select * from produto where prod_id=" + prodId).first();
                if (estabelecimento.get("estab_id").equals(produto.get("id_estab"))) {
                    String prodNome = request.queryParams("prod_nome");
                    String prodDesc = request.queryParams("prod_descricao");
                    String prodPreco = request.queryParams("prod_preco_atual");
                    String prodEstado = request.queryParams("alteraEstado");
                    String prodFoto = "/images/" + request.queryParams("prod_foto");

                    //atualizar foto
                    if (!prodFoto.equals("/images/null") && !prodFoto.equals("/images/")){
                        conn.executeUpdate(String.format("update produto set prod_foto = '%s' where prod_id = %s", prodFoto, prodId));
                    }

                    String sql = String.format("update produto set prod_nome='%s', prod_descricao='%s', prod_preco_atual='%s'"
                            + " where prod_id='%s'", prodNome, prodDesc, prodPreco, prodId);
                    conn.executeUpdate(sql);

                    if (prodEstado != null) {
                        if (prodEstado.equals(0)) {
                            conn.executeUpdate("update produto set prod_estado= " + prodEstado + " where prod_id=" + prodId);
                        } else {
                            conn.executeUpdate("update produto set prod_estado= " + prodEstado + " where prod_id=" + prodId);
                        }
                    }
                    produto = conn.executeQuery("select * from produto where prod_id= " + prodId).first();
                    response.redirect("/catalogo_estabelecimento/");
                    return "";
                }
            }
            response.redirect("/login/");
            return "";
        });

        //<------------------------------------------------------------------------------------------------------------- ADICIONAR PRODUTO AO CATÁLOGO (ESTABELECIMENTO)
        get("/adicionar_produto_catalogo/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {
                FreemarkerContext context = new FreemarkerContext();
                //estabelecimento
                DBRow addProd = conn.executeQuery("select * from estabelecimento join produto on estab_id = id_estab where id_util =" + getSessionUserID(request)).first();
                context.put("addProd", addProd);
                context.put("utilizador", utilizador);

                return engine.render(context, "adicionar_produto_catalogo.html");
            }

            response.redirect("/login/");
            return "";
        });

        post("/adicionar_produto_catalogo/add/", (request, response) -> {
            DBRow utilizador = request.session().attribute("utilizador");
            if (utilizador != null && utilizador.get("util_perfil").equals("estabelecimento")) {

                String addProdNome = request.queryParams("prod_nome");
                String addProdDesc = request.queryParams("prod_descricao");
                String addProdPreco = request.queryParams("prod_preco_atual");
                String addProdFoto = "/images/" + request.queryParams("prod_foto");
                DBRow estabelecimento = conn.executeQuery("select * from estabelecimento where id_util = " + getSessionUserID(request)).first();
                String sql = String.format("insert into produto ( prod_nome, prod_descricao, prod_preco_atual, prod_foto, prod_estado, id_estab) values('%s', '%s', '%s', '%s', '1', %s)",
                        addProdNome, addProdDesc, addProdPreco, addProdFoto, estabelecimento.get("estab_id"));
                conn.executeUpdate(sql);
                sql = String.format("select * from utilizador where util_id = %s", getSessionUserID(request));
                utilizador = conn.executeQuery(sql).first();
                request.session().attribute("utilizador", utilizador);

                response.redirect("/catalogo_estabelecimento/");
                return "";
            }
            response.redirect("/login/");
            return "";
        });
    }
}