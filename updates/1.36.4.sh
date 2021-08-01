#!/bin/bash

set -e

# Required for the reverse proxy of the metrics app
a2enmod proxy_http
service apache2 restart
