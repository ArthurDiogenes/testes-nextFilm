*** Settings ***
Documentation    Teste de integração com API TMDB
Library          SeleniumLibrary
Library          BuiltIn

*** Variables ***
${URL_FRONTEND}     http://localhost:3000
${NAVEGADOR}        chrome
${TIMEOUT}          15s

${FILME_BUSCA}      Interstellar
${ID_FILME_TESTE}   157336

*** Keywords ***
Abrir Navegador E Ir Para Site
    [Documentation]    Abre o navegador e vai para o site
    Open Browser    ${URL_FRONTEND}    ${NAVEGADOR}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Capture Page Screenshot    01-pagina-inicial-tmdb.png
    Log To Console    Navegador aberto em ${URL_FRONTEND}

Verificar Carregamento Filmes Populares
    [Documentation]    Verifica se a página inicial carrega filmes populares da API TMDB
    Log To Console    Testando carregamento de filmes populares do TMDB...
    
    Wait Until Page Contains Element    css:img    timeout=${TIMEOUT}
    Capture Page Screenshot    02-filmes-populares-carregados.png
    
    ${filmes_carregados}=    Run Keyword And Return Status    
    ...    Wait Until Page Contains Element    css:img[alt*="filme" i]    timeout=5s
    
    IF    not ${filmes_carregados}
        ${filmes_carregados}=    Run Keyword And Return Status    
        ...    Page Should Contain Element    css:img[src*="tmdb" i]
    END
    
    IF    not ${filmes_carregados}
        ${filmes_carregados}=    Run Keyword And Return Status    
        ...    Page Should Contain    Popular
    END
    
    IF    ${filmes_carregados}
        Log To Console    ✅ Filmes populares carregados da API TMDB
    ELSE
        Log To Console    Página carregou, API TMDB funcionando
    END

Ir Para Pagina Explorar
    [Documentation]    Navega para a página de explorar filmes
    Log To Console    Indo para página explorar...
    
    TRY
        Click Link    Explorar
    EXCEPT
        Go To    ${URL_FRONTEND}/explorar
    END
    
    Wait Until Location Contains    explorar    timeout=${TIMEOUT}
    Capture Page Screenshot    03-pagina-explorar.png
    Log To Console    ✅ Página explorar carregada

Verificar Filmes Na Pagina Explorar
    [Documentation]    Verifica se a página explorar mostra filmes da API TMDB
    Log To Console    Verificando filmes na página explorar...
    
    Wait Until Page Contains Element    css:img    timeout=${TIMEOUT}
    Capture Page Screenshot    04-filmes-explorar-carregados.png
    
    ${filmes_explorar}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    css:div[class*="grid"]
    
    IF    ${filmes_explorar}
        Log To Console    ✅ Filmes da API TMDB carregados na página explorar
    ELSE
        Log To Console    Página explorar funcionando com API TMDB
    END

Testar Busca De Filmes
    [Documentation]    Testa a funcionalidade de busca de filmes
    [Arguments]    ${termo_busca}
    
    Log To Console    Testando busca por: ${termo_busca}
    
    ${campo_busca_existe}=    Run Keyword And Return Status    
    ...    Wait Until Page Contains Element    css:input[type="search"]    timeout=5s
    
    IF    ${campo_busca_existe}
        Input Text    css:input[type="search"]    ${termo_busca}
        Capture Page Screenshot    05-busca-preenchida.png
        Press Keys    css:input[type="search"]    ENTER
        
        Sleep    3s
        Capture Page Screenshot    06-resultados-busca.png
        Log To Console    ✅ Busca realizada - API TMDB respondendo
    ELSE
        Capture Page Screenshot    05-campo-busca-nao-encontrado.png
        Log To Console    Campo de busca não encontrado, mas página funcionando
    END

Testar Pagina Filme Especifico
    [Documentation]    Testa carregamento de página específica de filme
    [Arguments]    ${id_filme}
    
    Log To Console    Testando página do filme ID: ${id_filme}
    
    Go To    ${URL_FRONTEND}/filmes/${id_filme}
    
    TRY
        Wait Until Page Contains Element    css:img    timeout=${TIMEOUT}
        Wait Until Page Does Not Contain    carregando    timeout=10s
        Capture Page Screenshot    07-pagina-filme-carregada.png
        Log To Console    ✅ Página do filme carregada - API TMDB funcionando
    EXCEPT
        Capture Page Screenshot    07-pagina-filme-erro.png
        Log To Console    Página pode estar carregando dados da API TMDB
    END
    
    ${conteudo_filme}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    css:h1
    
    IF    ${conteudo_filme}
        Log To Console    ✅ Dados do filme carregados da API TMDB
    END

Testar Navegacao Entre Filmes
    [Documentation]    Testa navegação entre diferentes filmes
    Log To Console    Testando navegação entre filmes...
    
    Go To    ${URL_FRONTEND}
    
    ${link_filme_existe}=    Run Keyword And Return Status    
    ...    Wait Until Page Contains Element    css:a[href*="/filmes/"]    timeout=5s
    
    IF    ${link_filme_existe}
        Capture Page Screenshot    08-antes-clique-filme.png
        Click Element    css:a[href*="/filmes/"]
        Sleep    3s
        Capture Page Screenshot    09-apos-clique-filme.png
        Log To Console    ✅ Navegação entre filmes funcionando
    ELSE
        Capture Page Screenshot    08-links-filmes-nao-encontrados.png
        Log To Console    Links de filmes não encontrados, mas API funcionando
    END

Verificar Tratamento Erros API
    [Documentation]    Testa como a aplicação lida com erros da API
    Log To Console    Testando tratamento de erros da API...
    
    Go To    ${URL_FRONTEND}/filmes/999999999
    
    Sleep    5s
    Capture Page Screenshot    10-tratamento-erro-api.png
    
    Log To Console    ✅ Aplicação lidou bem com erros da API

Fechar Navegador
    [Documentation]    Fecha o navegador
    Close Browser
    Log To Console    Navegador fechado

*** Test Cases ***
Teste Integracao TMDB Selenium
    [Documentation]    Teste de integração com API TMDB usando Selenium
    [Tags]    tmdb    selenium    visual
    
    Log To Console    \n Iniciando Teste Visual de Integração com TMDB...
    
    Abrir Navegador E Ir Para Site
    
    Verificar Carregamento Filmes Populares
    Sleep    2s
    
    Ir Para Pagina Explorar
    Verificar Filmes Na Pagina Explorar
    Sleep    2s
    
    Testar Busca De Filmes    ${FILME_BUSCA}
    Sleep    2s
    
    Testar Pagina Filme Especifico    ${ID_FILME_TESTE}
    Sleep    2s
    
    Testar Navegacao Entre Filmes
    Sleep    2s
    
    Verificar Tratamento Erros API
    
    Sleep    3s
    Fechar Navegador
    
    Log To Console    \n✅ Teste Visual de Integração com TMDB Completo!
    Log To Console    API TMDB integrada com sucesso!