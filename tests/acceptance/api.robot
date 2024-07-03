*** Settings ***
Documentation       A test suite to validate the API functionality.

Library             RequestsLibrary
Library             DatabaseLibrary
Library             Process
Library             OperatingSystem
Library             Collections

Task Setup          Test Setup
Task Teardown       Test Teardown


*** Variables ***
${SESSION}      api
${ALIAS}        webserver
${DB_FILE}      ${TEMPDIR}${/}test.db
${DB_DRIVER}    sqlite3
${ROBOTS}       [{"id": 1, "name": "robot", "status": "IDLE"}, {"id": 2, "name": "bender", "status": "LOST"}]


*** Test Cases ***
Robot List
    [Documentation]    Retrieve the list of robots.
    [Tags]    api

    ${response}    GET On Session    ${SESSION}                 /robots
    Should Be Equal As Integers      ${response.status_code}    200
    ${expected}    Evaluate          ${ROBOTS}                  modules=json
    Lists Should Be Equal            ${response.json()}         ${expected}

Root Robot
    [Documentation]    Retrieve the root robot.

    ${response}    GET On Session    ${SESSION}                /
    Should Be Equal As Integers      ${response.status_code}   200
    Should Be Equal As Strings       ${response.text}          "Bender"

Echo Status
    [Documentation]    Echo the status of a robot.

    ${response}    GET On Session    ${SESSION}                 /echo/idle
    Should Be Equal As Integers      ${response.status_code}    200
    Should Be Equal As Strings       ${response.text}           "Bender is idle"

Verify Robot ID Matches
    [Documentation]    Verifies the robot ID matches the expected value.
    [Tags]    api

    ${response}    GET On Session    ${SESSION}                 /robot/1
    Should Be Equal As Integers      ${response.status_code}    200
    VAR  ${data}    ${response.json()}

    ${robot}    Get From Dictionary    ${data}    id
    Should Be Equal As Integers        ${robot}   1
    ${robot}    Get From Dictionary    ${data}    name
    Should Be Equal As Strings         ${robot}   robot
    ${robot}    Get From Dictionary    ${data}    status
    Should Be Equal As Strings         ${robot}   IDLE


*** Keywords ***
Test Setup
    # Create the integration tests database
    Connect To Database Using Custom Params    ${DB_DRIVER}    database="${DB_FILE}"
    Set Auto Commit
    # Add the initial data
    Query    CREATE TABLE robots (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, status TEXT NOT NULL)
    Query    INSERT INTO robots (name, status) VALUES ('robot', 'IDLE')
    Query    INSERT INTO robots (name, status) VALUES ('bender', 'LOST')

    # Launch the web server
    Start Process    python    -m    robot_api    alias=${ALIAS}    env:ROBOT_API_DATABASE_PATH=${DB_FILE}
    Create Session    ${SESSION}    http://localhost:8000

    Process Should Be Running    ${ALIAS}

Test Teardown
    # Stop the web server
    Terminate Process    ${ALIAS}
    Delete All Sessions

    # Drop the integration tests database
    Disconnect From Database
    Remove File    ${DB_FILE}
