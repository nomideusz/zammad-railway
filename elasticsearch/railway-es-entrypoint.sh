#!/bin/bash
set -e
chown -R 1000:0 /usr/share/elasticsearch/data
# Drop to the elasticsearch user (ES refuses to run as root). chroot resets
# cwd to / but the ES entrypoint uses relative paths — cd back before exec.
exec chroot --userspec=1000:0 / /bin/bash -c 'cd /usr/share/elasticsearch && exec /bin/tini -- /usr/local/bin/docker-entrypoint.sh eswrapper'
