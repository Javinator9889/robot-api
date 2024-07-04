# Robot Framework - demo

[![Robot Framework API Demonstration](https://github.com/Javinator9889/robot-api/actions/workflows/python-app.yml/badge.svg)](https://github.com/Javinator9889/robot-api/actions/workflows/python-app.yml)

This project sets up a simple API made with FastAPI and a database backed by
SQLite3.

[Poetry](https://python-poetry.org/) is used as the dependency manager. You should
install it first to gather all the dependencies.

## Installing prerequisites

```bash
poetry install
```

> NOTE: [Poetry](https://python-poetry.org/) should be installed for the command above to work.
> It will take care of everything.


## Running the tests

The tests are simply run by calling `robot`, and then inspecting the `log.html`
file for further details:

```bash
poetry run robot tests/
```

It will automatically gather all the resources for the tests to work.
