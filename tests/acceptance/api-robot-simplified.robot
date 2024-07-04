*** Settings ***
Documentation       A test suite to validate the API functionality.

Resource            ${EXECDIR}/tests/resources/api.resource

Task Setup          API Test Setup
Task Teardown       API Test Teardown


*** Test Cases ***
Robot List
    [Documentation]    Retrieve the list of robots.
    [Tags]    api

    ${json}        API GET /robots On ${SESSION} As JSON
    ${expected}    Evaluate          ${ROBOTS}                  modules=json
    Lists Should Be Equal            ${json}         ${expected}

Root Robot
    [Documentation]    Retrieve the root robot.

    ${name}        API GET / On ${SESSION} As text
    Should Be Equal As Strings       ${name}         "Bender"

Echo Status
    [Documentation]    Echo the status of a robot.

    ${response}    API GET /echo/idle On ${SESSION} As text
    Should Be Equal As Strings       ${response}     "Bender is idle"

Verify Robot ID Matches
    [Documentation]    Verifies the robot ID matches the expected value.
    [Tags]    api

    ${data}        API GET /robot/1 On ${SESSION} As JSON
    API Robot "robot" Should Match Status "idle" In ${data}

Create New Robot
    [Documentation]    Create a new robot.
    [Tags]    api

    ${response}    POST On Session    ${SESSION}                 /robot/c3po/idle    expected_status=201
    ${robot}    Get From Dictionary   ${response.json()}         id

    ${response}    API GET /robot/${robot} On ${SESSION} As JSON
    API Robot "c3po" Should Match Status "idle" In ${response}

Delete Robot
    [Documentation]    Delete a robot.
    [Tags]    api

    ${response}    DELETE On Session  ${SESSION}                 /robot/1
    Should Be Equal As Integers       ${response.status_code}    200

    ${response}    GET On Session     ${SESSION}                 /robot/1    expected_status=404
