FROM haproxy

RUN  apt-get update && apt-get install -y unzip curl --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV CONSUL_TEMPLATE_VERSION=0.11.1 

RUN  mkdir /tmp/consul-template \
  && curl -s -k -o /tmp/consul-template/consul_template.zip https://releases.hashicorp.com/consul-template/0.11.1/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && cd /tmp/consul-template \
  && unzip consul_template.zip \
  && mv consul-template /usr/bin \
  && rm -rf /tmp/* \
  && apt-get purge -y

COPY certs/ /etc/ssl/
COPY config/haproxy.json /tmp/haproxy.json
COPY config/haproxy.ctmpl /tmp/haproxy.ctmpl

ENTRYPOINT ["consul-template","-config=/tmp/haproxy.json"]
CMD ["-consul=consul.service.consul:8500"]
