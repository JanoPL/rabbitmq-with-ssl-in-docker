# RabbitMQ with SSL Configuration in Docker

> RabbitMQ and SSL made easy for tests.

This repository aims at building a RabbitMQ container with SSL enabled using TLV v1.3.
Generation of the server certificates, as well as server configuration, are performed during
the image's build. A client certificate is generated when a container is created from this image.

It is recommended to mount a volume so that the client certificate can be reached from the
host system. Client certificates are generated under the **/rbmq/client** directory.

The certificates have been moved to the path /tmp/{certs, server, client}

## To build this image

```shell
cd tests && ./build.sh
```

The generated image contains SSL certificates for the server side.

## To build this image with custom domain

```shell
docker build --build-arg arg_domain=<domain> -t [<user>/]<image name>[:<tag>] .
```

By default, the certificate is generated with the host name

## To build this image with docker compose 

```shell
docker compose build 
```

## To run this image

```
mkdir -p /tmp/docker-test \
	&& rm -rf /tmp/docker-test/* \
	&& docker run -d --rm -p 12000:5671 -v /tmp/docker-test:/rbmq/client rabbitmq-with-ssl:latest
```

Here, we bind the port 5671 from the container on the 12000 port on the local host.  
We also share a local directory with the container, to retrieve the client certificate.
You can verify client certificates were generated with `ls /tmp/docker-test`. This directory contains
a key store and a trust store, both in the PKCS12 format.

## To run this image with docker compose 

```shell
docker compose up -d 
```

default exposed ports: 
- amqp: 5672
- amqps: 5671
- http: 15672

## To stop the container

`docker stop <container-id>` will stop the container.  
If you kept the `--rm` option, it will be deleted directly.

```docker compose down ``` will stop containers using docker compose

## To run quick tests

```
cd tests && ./test.sh
```

## To diagnose troubles

- Verify the client certificates were correctly generated: `ls -l /tmp/docker-test`
- Inspect the container: `docker exec -ti <container-id> /bin/bash`
- Check the logs: `docker logs <container-id>`
- Verify the SSL connection works: `openssl s_client -connect 127.0.0.1:12000 -key /tmp/docker-test/key.pem`  
  This last command will result in `Verify return code: 19 (self signed certificate in certificate chain)`, which is normal.
  We should specify the **-CApath**, which is inside the Docker container. This test is enough to verify SSL is enabled and
  the server is reachable from the host system.

## Quick overview of the content

- **Dockerfile**: the file with instructions to create a Docker image.
- **config/rabbitmq.config**: the configuration file for RabbitMQ.
- **config/openssl.cnf**: a configuration file used during certificates creation.
- **scripts/prepare-server.sh**: a script during the generation of the image and that deals with server certificates.
- **scripts/generate-client-keys.sh**: a script that is run by default when a container is created from this image.
  It deals with the generation of client certificates.
