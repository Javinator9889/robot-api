*** Settings ***
Documentation       A test suite to validate the API functionality. Uses a custom Python
...                 library underneath.

Resource            ${EXECDIR}/tests/resources/api.resource
Library             ${EXECDIR}/tests/resources/API.py    ${URL}

Test Setup          API Test Setup
Test Teardown       API Test Teardown

*** Test Cases ***
Robot List
    [Documentation]    Retrieve the list of robots.
    [Tags]    api

    ${response}    Python API GET     /robots
    ${expected}    Evaluate           ${ROBOTS}      modules=json
    Lists Should Be Equal             ${response}    ${expected}

Create New Robot
    [Documentation]    Create a new robot.
    [Tags]    api

    ${response}    Python API POST    /robot/c3po/idle    expected_status=201
    ${robot}    Get From Dictionary   ${response}         id

    ${response}    Python API GET     /robot/${robot}
    API Robot "c3po" Should Match Status "idle" In ${response}
