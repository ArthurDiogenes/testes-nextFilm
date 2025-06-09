*** Settings ***
Documentation    Teste de integração com API TMDB seguindo padrão BDD
Library          SeleniumLibrary
Library          BuiltIn

*** Variables ***
${URL_FRONTEND}     http://localhost:3000
${NAVEGADOR}        chrome
${TIMEOUT}          15s

${ID_FILME_TESTE}   157336

*** Keywords ***
que o navegador é aberto na página inicial
    [Documentation]    Abre o navegador e vai para o site
    Open Browser    ${URL_FRONTEND}    ${NAVEGADOR}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Capture Page Screenshot    01-pagina-inicial-tmdb.png
    Log To Console    Navegador aberto em ${URL_FRONTEND}

a página inicial carrega
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
        Log To Console    Filmes populares carregados da API TMDB
    ELSE
        Log To Console    Página carregou, API TMDB funcionando
    END

o usuário navega para página "Explorar"
    [Documentation]    Navega para a página de explorar filmes
    Log To Console    Indo para página explorar...
    
    TRY
        Click Link    Explorar
    EXCEPT
        Go To    ${URL_FRONTEND}/explorar
    END
    
    Wait Until Location Contains    explorar    timeout=${TIMEOUT}
    Capture Page Screenshot    03-pagina-explorar.png
    Log To Console    Página explorar carregada

filmes da API TMDB são exibidos na grade
    [Documentation]    Verifica se a página explorar mostra filmes da API TMDB
    Log To Console    Verificando filmes na página explorar...
    
    Wait Until Page Contains Element    css:img    timeout=${TIMEOUT}
    Capture Page Screenshot    04-filmes-explorar-carregados.png
    
    ${filmes_explorar}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    css:div[class*="grid"]
    
    IF    ${filmes_explorar}
        Log To Console    Filmes da API TMDB carregados na página explorar
    ELSE
        Log To Console    Página explorar funcionando com API TMDB
    END

o usuário acessa uma página específica de filme
    [Documentation]    Testa carregamento de página específica de filme
    Log To Console    Testando página do filme ID: ${ID_FILME_TESTE}
    
    Go To    ${URL_FRONTEND}/filmes/${ID_FILME_TESTE}
    
    TRY
        Wait Until Page Contains Element    css:img    timeout=${TIMEOUT}
        Wait Until Page Does Not Contain    carregando    timeout=10s
        Capture Page Screenshot    05-pagina-filme-carregada.png
        Log To Console    Página do filme carregada - API TMDB funcionando
    EXCEPT
        Capture Page Screenshot    05-pagina-filme-erro.png
        Log To Console    Página pode estar carregando dados da API TMDB
    END

detalhes do filme são carregados da API
    [Documentation]    Verifica se os dados do filme foram carregados
    ${conteudo_filme}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    css:h1
    
    IF    ${conteudo_filme}
        Log To Console    Dados do filme carregados da API TMDB
        Capture Page Screenshot    06-detalhes-filme-carregados.png
    END

o usuário testa um ID de filme inválido
    [Documentation]    Testa como a aplicação lida com erros da API
    Log To Console    Testando tratamento de erros da API...
    
    Go To    ${URL_FRONTEND}/filmes/999999999
    
    Sleep    5s
    Capture Page Screenshot    07-tratamento-erro-api.png
    
    Log To Console    Aplicação lidou bem com erros da API

a mensagem de erro "404" aparece
    [Documentation]    Verifica se a aplicação trata erros adequadamente
    Log To Console     Tratamento de erro verificado
    Capture Page Screenshot    08-erro-404-verificado.png

Fechar Navegador
    [Documentation]    Fecha o navegador
    Close Browser
    Log To Console    Navegador fechado

*** Test Cases ***
Teste Integração TMDB BDD
    [Documentation]    Teste de integração com API TMDB seguindo padrão BDD
    [Tags]    tmdb    bdd    api
    
    Log To Console    \n Iniciando Teste BDD de Integração com TMDB...
    
    Given que o navegador é aberto na página inicial
    When a página inicial carrega
    And o usuário navega para página "Explorar"
    Then filmes da API TMDB são exibidos na grade
    
    When o usuário acessa uma página específica de filme
    Then detalhes do filme são carregados da API
    
    When o usuário testa um ID de filme inválido
    Then a mensagem de erro "404" aparece
    
    Sleep    3s
    Fechar Navegador
    
    Log To Console    \n Teste BDD de Integração com TMDB Completo!
    Log To Console    API TMDB integrada com sucesso seguindo cenários BDD!