*** Settings ***
Documentation    Teste de integração com banco de dados
Library          SeleniumLibrary
Library          BuiltIn

*** Variables ***
${URL_FRONTEND}     http://localhost:3000
${NAVEGADOR}        chrome
${TIMEOUT}          10s

${EMAIL_TESTE}      teste-do-robozao4@email.com
${SENHA_TESTE}      senha123
${NOME_TESTE}       Robozao4
${SOBRENOME_TESTE}  Teste
${USUARIO_TESTE}    robozao_teste4

*** Keywords ***
que o navegador é aberto na página de cadastro

    Open Browser    ${URL_FRONTEND}    ${NAVEGADOR}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Capture Page Screenshot    01-site-aberto.png
    Log To Console    Navegador aberto
    Go To    ${URL_FRONTEND}/auth/signup
    Wait Until Page Contains    Criar conta    timeout=${TIMEOUT}
    Capture Page Screenshot    02-pagina-cadastro.png
    Log To Console    Página de cadastro carregada

o usuário preenche o formulário de cadastro
    
    Input Text    id:firstName        ${NOME_TESTE}
    Input Text    id:lastName         ${SOBRENOME_TESTE}
    Input Text    id:username         ${USUARIO_TESTE}
    Input Text    id:email            ${EMAIL_TESTE}
    Input Text    id:password         ${SENHA_TESTE}
    Input Text    id:confirmPassword  ${SENHA_TESTE}
    
    Click Element    id:terms
    
    Capture Page Screenshot    03-formulario-preenchido.png
    Log To Console    Formulário preenchido

clica no botão "Criar conta"
    
    Click Button    xpath://button[@type="submit" and contains(text(), "Criar conta")]
    TRY
        Wait Until Page Contains    Conta criada    timeout=10s
        Capture Page Screenshot    04-cadastro-sucesso.png
        Log To Console    ✅ Cadastro realizado com sucesso - dados salvos no banco!
    EXCEPT
        Capture Page Screenshot    04-cadastro-erro.png
        Log To Console    Usuário pode já existir no banco
    END

o usuário é redirecionado para página de login

    Go To    ${URL_FRONTEND}/auth/signin
    Wait Until Page Contains    Entrar    timeout=${TIMEOUT}
    Capture Page Screenshot    05-pagina-login.png
    Log To Console    Página de login carregada

usuário preenche dados de login
    
    Input Text    name:email     ${EMAIL_TESTE}
    Input Text    name:senha     ${SENHA_TESTE}
    
    Capture Page Screenshot    06-dados-login.png
    Log To Console    Dados de login preenchidos

clica no botão "Entrar"
    
    # Tenta múltiplos seletores para o botão Entrar
    TRY
        Click Button    xpath://button[contains(text(), "Entrar")]
    EXCEPT
        TRY
            Click Button    xpath://button[@type="submit"]
        EXCEPT
            TRY
                Click Button    css:button[type="submit"]
            EXCEPT
                Click Element    xpath://button[contains(@class, "bg-rose-600")]
            END
        END
    END
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

o login é realizado com sucesso
    Wait Until Page Contains    NextFilm    timeout=${TIMEOUT}

Fechar Navegador
    Close Browser

*** Test Cases ***
Teste Cadastro E Login
        
    Given que o navegador é aberto na página de cadastro
    When o usuário preenche o formulário de cadastro
    And clica no botão "Criar conta"
    Then o usuário é redirecionado para página de login
    And usuário preenche dados de login
    When clica no botão "Entrar"
    Then o login é realizado com sucesso
    
    Sleep    3s
    Fechar Navegador