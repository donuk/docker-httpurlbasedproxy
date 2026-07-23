FROM nginx:1.27.2

ENV DOMAIN=self-signed-ssl
ENV BACKEND=BACKEND-NOT-CONFIGURED
ENV TIMEOUT=60s
ENV RESOLVER_TIMEOUT=10s
RUN apt-get update && apt-get install -y apache2-utils && apt-get clean
ADD ./setup-proxy-config.sh /docker-entrypoint.d/99-setup-proxy-config.sh
