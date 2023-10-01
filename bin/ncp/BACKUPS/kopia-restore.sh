#!/bin/bash
# Nextcloud backups
#
# Copyleft 2023 by Tobias Knöppler
# GPL licensed (see end of file) * Use at your own risk!
#

install() { :; }

configure() {
  kopia-restore "${REPOSITORY}" "${REPOSITORY_PASSWORD}" "${SNAPSHOT_ID}"
}
