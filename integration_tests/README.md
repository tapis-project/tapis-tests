To run Tapis v3 integration tests
docker build -t tapis/tapistests -f Dockerfile-tests . 
docker run -it  tapis/tapistests


Open tapistest.py and make sure all the usernames, passwords, system ids and paths are set correct for the test