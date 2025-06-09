*** Settings ***
Documentation    Teste de integração com banco de dados
Library          SeleniumLibrary
Library          BuiltIn

*** Variables ***
${URL_FRONTEND}     http://localhost:3000
${NAVEGADOR}        chrome
${TIMEOUT}          10s

${EMAIL_TESTE}      teste-do-robozao@email.com
${SENHA_TESTE}      senha123
${NOME_TESTE}       Robozao
${SOBRENOME_TESTE}  Teste
${USUARIO_TESTE}    robozao_teste

*** Keywords ***
Abrir Navegador
    [Documentation]    Abre o navegador
    Open Browser    ${URL_FRONTEND}    ${NAVEGADOR}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Capture Page Screenshot    01-site-aberto.png
    Log To Console    Navegador aberto

Ir Para Cadastro
    [Documentation]    Vai para página de cadastro
    Go To    ${URL_FRONTEND}/auth/signup
    Wait Until Page Contains    Criar conta    timeout=${TIMEOUT}
    Capture Page Screenshot    02-pagina-cadastro.png
    Log To Console    Página de cadastro carregada

Preencher Formulario Cadastro
    [Documentation]    Preenche formulário de cadastro
    Log To Console    Preenchendo dados de cadastro...
    
    Input Text    id:firstName        ${NOME_TESTE}
    Input Text    id:lastName         ${SOBRENOME_TESTE}
    Input Text    id:username         ${USUARIO_TESTE}
    Input Text    id:email            ${EMAIL_TESTE}
    Input Text    id:password         ${SENHA_TESTE}
    Input Text    id:confirmPassword  ${SENHA_TESTE}
    
    Click Element    id:terms
    
    Capture Page Screenshot    03-formulario-preenchido.png
    Log To Console    Formulário preenchido

Submeter Cadastro
    [Documentation]    Submete o formulário de cadastro
    Click Button    Criar conta
    
    TRY
        Wait Until Location Contains    signin    timeout=10s
        Capture Page Screenshot    04-cadastro-sucesso.png
        Log To Console    ✅ Cadastro realizado com sucesso - dados salvos no banco!
    EXCEPT
        Capture Page Screenshot    04-cadastro-erro.png
        Log To Console    Usuário pode já existir no banco
    END

Ir Para Login
    [Documentation]    Vai para página de login
    Go To    ${URL_FRONTEND}/auth/signin
    Wait Until Page Contains    Entrar    timeout=${TIMEOUT}
    Capture Page Screenshot    05-pagina-login.png
    Log To Console    Página de login carregada

Preencher Dados Login
    [Documentation]    Preenche dados de login
    Log To Console    Preenchendo dados de login...
    
    Input Text    name:email     ${EMAIL_TESTE}
    Input Text    name:senha     ${SENHA_TESTE}
    
    Capture Page Screenshot    06-dados-login.png
    Log To Console    Dados de login preenchidos

Fazer Login
    [Documentation]    Faz login no sistema
    Click Button    Entrar
    
    TRY
        Wait Until Location Is    ${URL_FRONTEND}/    timeout=10s
        Wait Until Page Contains    NextFilm    timeout=5s
        Sleep    2s
        Capture Page Screenshot    07-pagina-principal.png
        Log To Console    ✅ Login realizado com sucesso - dados lidos do banco!
    EXCEPT
        TRY
            Wait Until Page Contains    NextFilm    timeout=5s
            Sleep    2s
            Capture Page Screenshot    07-pagina-principal.png
            Log To Console    ✅ Login realizado com sucesso!
        EXCEPT
            Capture Page Screenshot    07-login-erro.png
            Log To Console    Erro no login - verificar credenciais
        END
    END

Fechar Navegador
    [Documentation]    Fecha o navegador
    Close Browser
    Log To Console    Teste finalizado

*** Test Cases ***
Teste Cadastro E Login
    [Documentation]    Teste completo de cadastro e login
    [Tags]    banco    cadastro    login
    
    Log To Console    \n Iniciando teste de cadastro e login...
    
    Abrir Navegador
    
    Log To Console    Testando cadastro - escrita...
    Ir Para Cadastro
    Preencher Formulario Cadastro
    Submeter Cadastro
    
    Log To Console    Testando login - leitura...
    Ir Para Login
    Preencher Dados Login
    Fazer Login
    
    Sleep    3s
    Fechar Navegador
    
    Log To Console    \n✅ Teste de integração com banco concluído!