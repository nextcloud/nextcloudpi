#!/bin/bash
# Nextcloud backups
#
# Copyleft 2023 by Tobias Knöppler
# GPL licensed (see end of file) * Use at your own risk!
#

install() { :; }

configure() {
  kopia-restore "${SNAPSHOT_ID}" "${REPOSITORY}" "${REPOSITORY_PASSWORD}"
}
