<nav class="navbar sticky-top navbar-dark bg-dark navbar-expand-sm">
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto mt2 mt-lg0">
            <li class="nav-item"><a class="nav-link" href="/homepage/">HOME</a></li>
            <#if utilizador.util_perfil == "cliente">
                <li class="nav-item"><a class="nav-link" href="/pedidos_em_curso/">PEDIDOS</a></li>
                <li class="nav-item"><a class="nav-link" href="/carrinho/">CARRINHO</a></li>
                <li class="nav-item"><a class="nav-link" href="/historico_pedidos_cliente/">HISTORICO</a></li>
                <li class="nav-item"><a class="nav-link" href="/conta/">CONTA</a></li>
                <li class="nav-item"><a class="nav-link" href="/notificacoes/">NOTIFICAÇÕES</a></li>
            </#if>
            <#if utilizador.util_perfil == "estabelecimento">
                <li class="nav-item"><a class="nav-link" href="/catalogo_estabelecimento/">CATÁLOGO</a></li>
                <li class="nav-item"><a class="nav-link" href="/historico_pedidos_estabelecimento/">HISTORICO</a></li>
                <li class="nav-item"><a class="nav-link" href="/conta/">CONTA</a></li>
            </#if>
            <#if utilizador.util_perfil == "estafeta">
                <li class="nav-item"><a class="nav-link" href="/historico_pedidos_estafeta/">HISTORICO</a></li>
                <li class="nav-item"><a class="nav-link" href="/conta/">CONTA</a></li>
            </#if>
            <#if utilizador.util_perfil == "administrador">
                <li class="nav-item"><a class="nav-link" href="/consultar/clientes/">CLIENTES</a></li>
                <li class="nav-item"><a class="nav-link" href="/consultar/estabelecimentos/">ESTABELECIMENTOS</a></li>
                <li class="nav-item"><a class="nav-link" href="/consultar/estafetas/">ESTAFETAS</a></li>
                <li class="nav-item"><a class="nav-link" href="/consultar/encomendas/">ENCOMENDAS</a></li>
                <li class="nav-item"><a class="nav-link" href="/consultar/bloqueados/">BLOQUEADOS</a></li>
            </#if>
            <li class="nav-item d-flex"><a  style="color: red;" class="nav-link" href="/logout/">LOGOUT</a></li>
        </ul>
    </div>
</nav>
