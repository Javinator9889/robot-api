*** Settings ***
Documentation    Sample resource file modifying slightly a bit the "requests" library.
Library          Collections
Library          RequestsLibrary
Library          DatabaseLibrary
Library          Process
Library          OperatingSystem

*** Variables ***
${ADDRESS}       localhost
${PORT}          8000
${URL}           http://${ADDRESS}:${PORT}
${SESSION}       api
${ALIAS}         webserver
${DB_FILE}       ${TEMPDIR}${/}test.db
${DB_DRIVER}     sqlite3
${ROBOTS}        [{"id": 1, "name": "robot", "status": "idle"}, {"id": 2, "name": "bender", "status": "lost"}]

*** Keywords ***
API GET "${Path}" As ${Format}
    [Documentation]    Perform a GET request on the given path for the session. "Format"
    ...            is the format of the response, e.g. "JSON" or "Text".
    ${response}    GET On Session    ${SESSION}    ${Path}      expected_status=200

    # Ignore the case of the format
    IF  "${Format.upper()}" == "JSON"
        RETURN    ${response.json()}
    END
    RETURN        ${response.text}

API Robot "${Name}" Should Match Status "${Status}" In ${Response}
    [Documentation]    Verifies the robot name matches the expected value.

    ${robot}    Get From Dictionary    ${Response}    name
    Should Be Equal As Strings         ${robot}       ${Name}
    ${robot}    Get From Dictionary    ${Response}    status
    Should Be Equal As Strings         ${robot}       ${Status}

API Test Setup
    # Create the integration tests database
    Connect To Database Using Custom Params    ${DB_DRIVER}    database="${DB_FILE}"
    Set Auto Commit
    # Add the initial data
    Query    CREATE TABLE robots (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, status TEXT NOT NULL)
    Query    INSERT INTO robots (name, status) VALUES ('robot', 'idle')
    Query    INSERT INTO robots (name, status) VALUES ('bender', 'lost')

    # Launch the web server
    Start Process    python    -m    robot_api    alias=${ALIAS}    env:ROBOT_API_DATABASE_PATH=${DB_FILE}
    Create Session    ${SESSION}     ${URL}

    # To verify the web server is running and nothing is broken
    Process Should Be Running    ${ALIAS}

    # Wait for the web server to start
    VAR               ${started}     ${False}
    WHILE    not ${started}
        ${res}    Run Process    nc    -z    ${ADDRESS}    ${PORT}
        VAR           ${started}    ${res.rc} == 0
    END

API Test Teardown
    # Stop the web server
    ${res}    Terminate Process    ${ALIAS}
    Run Keyword If Test Failed    Log    ${res.stdout}    level=ERROR
    Run Keyword If Test Failed    Log    ${res.stderr}    level=TRACE
    Delete All Sessions

    # Drop the integration tests database
    Disconnect From Database
    Remove File    ${DB_FILE}
