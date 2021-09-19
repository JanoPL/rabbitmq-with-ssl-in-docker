FROM rabbitmq:3.9-management

ARG arg_domain=testdomain.local
ENV DOMAIN=${arg_domain}

RUN apt-get update \
	&& apt-get install openssl -y  \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /rbmq/testca/certs \
	&& mkdir -p /rbmq/testca/private \
	&& chmod 700 /rbmq/testca/private \
	&& echo 01 > /rbmq/testca/serial \
	&& touch /rbmq/testca/index.txt

RUN rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl

#COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config
COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY openssl.cnf /rbmq/testca
COPY prepare-server.sh generate-client-keys.sh /rbmq/

RUN mkdir -p /rbmq/server \
	&& mkdir -p /rbmq/client \
	&& chmod +x /rbmq/prepare-server.sh /rbmq/generate-client-keys.sh

RUN /bin/bash /rbmq/prepare-server.sh 

RUN /bin/bash /rbmq/generate-client-keys.sh
RUN chown root:rabbitmq /rbmq/server/key.pem && chmod 640 /rbmq/server/key.pem
#sleep infinity
