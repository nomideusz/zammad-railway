# Zammad in one service: nginx, the Rails server, the websocket server and
# the background workers, supervised by railway-entrypoint.sh. Upstream's
# compose runs each as its own container from this same image; on Railway
# that is five services to deploy in the right order, and every one of them
# boots Rails just to wait for the init container.
FROM ghcr.io/zammad/zammad:7.2.0-0006

USER root
# nginx sizes `auto` from the host's CPUs, 48 on Railway: 48 workers is
# ~1.5 GB of idle memory.
RUN sed -i 's/^worker_processes auto;/worker_processes 2;/; /^worker_cpu_affinity/d' /etc/nginx/nginx.conf
COPY --chown=zammad:zammad nginx.conf /etc/nginx/sites-enabled/default
COPY railway-entrypoint.sh railway-setup.rb /opt/railway/
RUN chmod 755 /opt/railway/railway-entrypoint.sh
USER zammad

ENTRYPOINT ["/opt/railway/railway-entrypoint.sh"]
