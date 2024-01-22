*** Settings ***
Documentation     A script to classify text files using a Flask app.
Library           OperatingSystem
Library           RequestsLibrary
Library           Collections

*** Variables ***
${SERVER_URL}     http://127.0.0.1:5000
${DIRECTORY}      ./emails/ 

*** Test Cases ***
Classify Text Files
    Create Session    MySession    ${SERVER_URL}
    ${files}=    List Files In Directory    ${DIRECTORY}    *.txt
    ${results}=    Create List
    FOR    ${file}    IN    @{files}
        ${file_path}=    Join Path    ${DIRECTORY}    ${file}
        ${text}=    Get File    ${file_path}
        ${status}    ${response}=    Run Keyword And Ignore Error    Classify Text    MySession    ${text}
        IF    '${status}' != 'PASS'
            Log    Failed to classify ${file}. Error: ${response}
            Continue For Loop
        END
        Append To List    ${results}    ${file} - ${response['classification']}
    END
    Log List    ${results}

*** Keywords ***
Classify Text
    [Arguments]    ${session}    ${text}
    &{data}=    Create Dictionary    text=${text}
    ${response}=    POST On Session    ${session}    /classify    data=&{data}
    [Return]    ${response.json()}
