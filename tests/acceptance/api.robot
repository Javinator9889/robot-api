*** Settings ***
Documentation       A test suite to validate the API functionality.

Resource            ${EXECDIR}/tests/resources/api.resource

Test Setup          API Test Setup
Test Teardown       API Test Teardown


*** Test Cases ***
Robot List
    [Documentation]    Retrieve the list of robots.
    [Tags]    api

    ${response}    GET On Session    ${SESSION}                 /robots        expected_status=200
    ${expected}    Evaluate          ${ROBOTS}                  modules=json
    Lists Should Be Equal            ${response.json()}         ${expected}

Root Robot
    [Documentation]    Retrieve the root robot.

    ${response}    GET On Session    ${SESSION}                 /              expected_status=200
    Should Be Equal As Strings       ${response.text}           "Bender"

Echo Status
    [Documentation]    Echo the status of a robot.

    ${response}    GET On Session    ${SESSION}                 /echo/idle     expected_status=200
    Should Be Equal As Strings       ${response.text}           "Bender is idle"

Verify Robot ID Matches
    [Documentation]    Verifies the robot ID matches the expected value.
    [Tags]    api

    ${response}    GET On Session    ${SESSION}                 /robot/1        expected_status=200
    VAR  ${data}    ${response.json()}

    ${robot}    Get From Dictionary    ${data}    id
    Should Be Equal As Integers        ${robot}   1
    ${robot}    Get From Dictionary    ${data}    name
    Should Be Equal As Strings         ${robot}   robot
    ${robot}    Get From Dictionary    ${data}    status
    Should Be Equal As Strings         ${robot}   idle

Create New Robot
    [Documentation]    Create a new robot.
    [Tags]    api

    ${response}    POST On Session    ${SESSION}                 /robot/c3po/idle    expected_status=201
    ${robot}    Get From Dictionary   ${response.json()}         id

    ${response}    GET On Session     ${SESSION}                 /robot/${robot}     expected_status=200
    ${robot}    Get From Dictionary   ${response.json()}         name
    Should Be Equal As Strings        ${robot}                   c3po
    ${robot}    Get From Dictionary   ${response.json()}         status
    Should Be Equal As Strings        ${robot}                   idle

Delete Robot
    [Documentation]    Delete a robot.
    [Tags]    api

    ${response}    DELETE On Session  ${SESSION}                 /robot/1
    Should Be Equal As Integers       ${response.status_code}    200

    ${response}    GET On Session     ${SESSION}                 /robot/1    expected_status=404
