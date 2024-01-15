#!/bin/bash

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

install() {
  apt-get update
  $APTINSTALL podman
#  mkdir -p raspbian_root/etc/containers
#  cat <<EOF > raspbian_root/etc/containers/policy.json
#{
#  "default": [
#    {
#      "type": "insecureAcceptAnything"
#    }
#  ],
#  "transports":
#  {
#    "docker-daemon":
#      {
#        "": [{"type":"insecureAcceptAnything"}]
#      }
#  }
#}
#EOF

  success=false
  for i in {1..10}
  do
    sleep 5
    if podman run --rm docker.io/hello-world
    then
      success=true
      break
    else
      echo "Docker failed to start (attempt ${i}/10)"
    fi
  done

  podman rmi docker.io/hello-world:latest || true

  [[ "$success" == "true" ]] || exit 1
}

configure() { :; }
