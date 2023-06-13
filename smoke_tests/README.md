# tapis-tests


Important Note: Prior to running Smoke tests 
- create a storage or execution system 
- create app
- populate all the details in config.json

1.To run Smoke Tests for all services run:

./tapisv3smoketests.sh -s all -tenant dev


2. To run Smoketests for any particular service, for example: systems run:

./tapisv3smoketests.sh -s systems -tenant dev


3. To run tests in debug mode run:

bash -x tapisv3smoketests.sh -s all -tenant dev


Service names: actors, apps, authenticator, meta, postits, pods, sk, streams, systems, tenants, workflows