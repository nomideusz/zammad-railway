# Zammad's search index. Settings upstream's compose passes as env vars are
# baked in here: Railway variable names can't contain dots.
FROM elasticsearch:9.5.3

# network.bind_host "::" makes it reachable on Railway's IPv6 private network
# (a list with 0.0.0.0 as well is a fatal "wildcard + multiple addresses").
# Security stays on: only Zammad, with ELASTIC_PASSWORD, can query it.
RUN { \
  echo 'discovery.type: single-node'; \
  echo 'network.bind_host: "::"'; \
  echo 'xpack.security.enabled: true'; \
  echo 'xpack.security.http.ssl.enabled: false'; \
  echo 'xpack.security.transport.ssl.enabled: false'; \
  echo 'xpack.ml.enabled: false'; \
} >> /usr/share/elasticsearch/config/elasticsearch.yml

ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

# Railway volumes mount root-owned; Elasticsearch runs as uid 1000 and
# refuses root.
USER root
COPY railway-es-entrypoint.sh /railway-es-entrypoint.sh
RUN chmod +x /railway-es-entrypoint.sh
ENTRYPOINT ["/railway-es-entrypoint.sh"]
