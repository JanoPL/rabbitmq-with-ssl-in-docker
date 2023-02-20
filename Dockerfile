FROM rabbitmq:3.11-management

ARG ORG_DOMAIN=testdomain.local
ENV DOMAIN=${ORG_DOMAIN}

LABEL version = "1.0"
LABEL description = "Rabbitmq with ssl connection"

RUN apt-get update
RUN apt-get install openssl -y

RUN mkdir -p /tmp\
    && mkdir -p /tmp/certs \
    && mkdir -p /tmp/certs/private \
    && mkdir -p /tmp/server \
    && mkdir -p /tmp/client \

RUN chmod 700 /tmp/certs/private
RUN echo 01 > /tmp/certs/serial
RUN touch /tmp/certs/index.txt

RUN rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl

COPY config/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY config/openssl.cnf /tmp/openssl.cnf
COPY scripts/prepare-server.sh /tmp/prepare-server.sh
COPY scripts/generate-client-keys.sh /tmp/generate-client-keys.sh

RUN chmod +x /tmp/prepare-server.sh
RUN chmod +x /tmp/generate-client-keys.sh

RUN /tmp/prepare-server.sh

RUN /tmp/generate-client-keys.sh

RUN chown root:rabbitmq /tmp/server/key.pem && chmod 640 /tmp/server/key.pem
#sleep infinity
