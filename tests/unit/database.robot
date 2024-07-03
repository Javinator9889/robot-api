*** Settings ***
Documentation       A test suite to validate the database functionality.

Library             DatabaseLibrary
Library             OperatingSystem
Library             ${CURDIR}/RobotDatabase.py    ${DB_FILE}

Test Setup          Test Setup
Test Teardown       Test Teardown


*** Variables ***
${DB_FILE}              ${TEMPDIR}${/}test.db
${DB_NAME}              robots
${DB_DRIVER}            sqlite3
${ROBOT_NAME}           robot
${ROBOT_STATUS}         IDLE
${ROBOT_NEW_NAME}       Bender
${ROBOT_NEW_STATUS}     BUSY


*** Test Cases ***
Robot Insertion
    [Documentation]    Insert a row in the database.
    Insert Robot    ${ROBOT_NAME}    ${ROBOT_STATUS}
    Commit

    ${result}    Query    SELECT * FROM ${DB_NAME} WHERE name = '${ROBOT_NAME}'
    Should Be Equal As Strings    ${result[0][1]}    ${ROBOT_NAME}

Robot Exists
    [Documentation]    Check if a row exists in the database after inserting it.

    ${id}    Insert Default Robot
    ${res}    Robot Exists    ${id}
    Should Be True    ${res}

Robot Deletion
    [Documentation]    Delete a row from the database.

    ${id}    Insert Default Robot
    Delete Robot    ${id}
    Commit

    ${result}    Query    SELECT * FROM ${DB_NAME} WHERE name = '${ROBOT_NAME}'
    Should Be Empty    ${result}

Robot Update Name
    [Documentation]    Update a row in the database.

    ${id}    Insert Default Robot
    Update Robot    ${id}    name=${ROBOT_NEW_NAME}    status=${None}
    Commit

    ${result}    Query    SELECT * FROM ${DB_NAME} WHERE id = ${id}
    Should Be Equal As Strings    ${result[0][1]}    ${ROBOT_NEW_NAME}

Robot Update Status
    [Documentation]    Update a row in the database.

    ${id}    Insert Default Robot
    Update Robot    ${id}    name=${None}    status=${ROBOT_NEW_STATUS}
    Commit

    ${result}    Query    SELECT * FROM ${DB_NAME} WHERE id = ${id}
    Should Be Equal As Strings    ${result[0][2]}    ${ROBOT_NEW_STATUS}

Robot Update Invalid Parameters
    [Documentation]    Update a row in the database with invalid parameters.

    ${id}    Insert Default Robot
    Run Keyword And Expect Error    ValueError: At least one of name or status must be provided.
    ...    Update Robot    ${id}    ${None}    ${None}


*** Keywords ***
Test Setup
    [Documentation]    Create a table in the database.
    Create Table
    Connect To Database Using Custom Params    ${DB_DRIVER}    database="${DB_FILE}"
    Set Auto Commit

Test Teardown
    [Documentation]    Deletes the database.
    Disconnect From Database
    Remove File    ${DB_FILE}

Insert Default Robot
    [Documentation]    Insert a robot in the database. Returns the robot ID.
    Query    INSERT INTO ${DB_NAME} (name, status) VALUES ('${ROBOT_NAME}', '${ROBOT_STATUS}')

    ${result}    Query    SELECT last_insert_rowid()
    Should Not Be Empty    ${result}
    RETURN    ${result}[0][0]
