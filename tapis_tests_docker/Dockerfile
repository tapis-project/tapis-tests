FROM debian
RUN apt-get -y -qq update && \
	apt-get install -y -qq curl && \
	apt-get clean
# install jq to parse json within bash scripts
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
  chmod +x /usr/local/bin/jq
ADD config.json /config.json
ADD tapisv3smoketests.sh /tapisv3smoketests.sh  
RUN chmod +x /tapisv3smoketests.sh
ENTRYPOINT  /tapisv3smoketests.sh
