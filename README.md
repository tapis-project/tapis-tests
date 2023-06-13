# tapis-tests
This repository contains test suites that can be used to validate a Tapis installation.
There are three types of tests included in each of the subdirectories.

1. ``smoke_tests`` -- This folder contains "smoke tests", i.e., basic checks of the functionality of each service. The tests are written in BASH and utilize the ``curl``  HTTP client. This approach minimizes dependencies of the tests themselves (e.g., these tests do not depend on a Python installation, the Tapis Python SDK, tapipy, or other libraries). To use these tests, simply update the config file and execute the bash script. There is also a Dockerfile included to allow for executing the tests in a container.

2. ``integration_tests`` -- This folder contains a more "integration tests", i.e., more elaborate checks of the Tapis functionality than that checked by the smoke tests. Unlike the smoke tests, the integration tests use Python and the Tapis Python SDK (tapipy). To use run the integration tests, consider using the including Dockerfile to build a docker image. This approach requires changes to the storage.json and the app.json files included in the ``src`` directory there as well as updates to the variables in tapistest.py. See the README contained in the folder for more details. 
