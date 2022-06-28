# tapis-tests

This repo helps to run smoke tests in a docker container.
1. Edit the config.json file before building and running the container.
2. Build the image 
docker build -t tapis/smoketests .
3. Run tests
docker run --rm tapis/smoketests 

