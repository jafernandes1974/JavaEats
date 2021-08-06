<nav class="navbar sticky-top navbar-dark bg-dark navbar-expand-sm">
    <div>
        <ul class="navbar-nav mr-auto mt2 mt-lg0">
            <li class="nav-item"><a class="nav-link" href="/homepage/">HOME</a></li>
            <#if utilizador.util_perfil == "cliente">
                <li class="nav-item"><a class="nav-link" href="">ESTABELECIMENTOS</a></li>
                <li class="nav-item"><a class="nav-link" href="/pedidos_em_curso/">PEDIDOS</a></li>
                <li class="nav-item"><a class="nav-link" href="/carrinho/">CARRINHO</a></li>
                <li class="nav-item"><a class="nav-link" href="/historico_pedidos_cliente/">HISTORICO</a></li>
            </#if>
            <li class="nav-item"><a class="nav-link" href="/conta/">CONTA</a></li>
            <li class="nav-item d-flex"><a class="nav-link" href="/logout/">LOGOUT</a></li>
        </ul>
    </div>
</nav>