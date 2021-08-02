#!/bin/bash

set -e

# Required for the reverse proxy of the metrics app
a2enmod proxy_http
bash -c "sleep 2 && service apache2 reload" &>/dev/null &
