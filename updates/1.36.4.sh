#!/bin/bash

set -e

a2enmod proxy_http
service apache2 restart
