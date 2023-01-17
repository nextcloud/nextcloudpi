# syntax=docker/dockerfile:1
FROM caddy:2.6.1-alpine AS Builder
RUN xcaddy build \
--with github.com/greenpau/caddy-security \
--with github.com/caddyserver/transform-encoder \
--with github.com/mholt/caddy-webdav \
--with github.com/greenpau/caddy-trace \
--with github.com/hairyhenderson/caddy-teapot-module \
--with github.com/aksdb/caddy-cgi/v2 \
--with github.com/abiosoft/caddy-json-parse \
--with github.com/greenpau/caddy-trace \
--with github.com/mastercactapus/caddy2-proxyprotocol \
--with github.com/porech/caddy-maxmind-geolocation \
--with github.com/gamalan/caddy-tlsredis \
--with github.com/abiosoft/caddy-exec \
--with github.com/sjtug/caddy2-filter \
--with github.com/mholt/caddy-dynamicdns \
--with github.com/ggicci/caddy-jwt \
--with github.com/muety/caddy-remote-host \
--with github.com/greenpau/caddy-git \
--with github.com/ueffel/caddy-basic-auth-filter \
--with github.com/firecow/caddy-forward-auth

FROM caddy:2.6.1-alpine AS cad
COPY --from=Builder ["/usr/bin/caddy","/usr/local/bin/caddy"]
COPY --from=Builder ["/etc/caddy/Caddyfile","/etc/caddy/Caddyfile"]
USER caddy
# VOLUME /usr/share/caddy
VOLUME /etc/caddy/Caddyfile
VOLUME /data
EXPOSE 80
EXPOSE 443
EXPOSE 2019
EXPOSE 8080
EXPOSE 8443
ENTRYPOINT ["/usr/local/bin/caddy"]
