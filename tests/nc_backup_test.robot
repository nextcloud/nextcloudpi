#!/usr/bin/env python

*** Settings ***
Library         NcpRobotLib.py    8080      8443    4443
Suite Setup      Setup Ncp        docker    latest
Suite Teardown   Destroy Ncp
Test Teardown    Run on Ncp       rm        -rf     /opt/ncp-backups/*.tar

*** Test Cases ***

Create dataless Backup
    #[Documentation] Creates and validates a backup using nc-backup
    Create Backup in                     /opt/ncp-backups          dataless
    Assert file exists in archive        /opt/ncp-backups/*.tar    nextcloud/config/config.php
    Assert file exists in archive        /opt/ncp-backups/*.tar    nextcloud-sqlbkp_.*.bak
    Assert file exists not in archive    /opt/ncp-backups/*.tar    ncdata/files/ncp

Create Backup with data
    #[Documentation] Creates and validates a backup using nc-backup
    Create Backup in                 /opt/ncp-backups
    Assert file exists in archive    /opt/ncp-backups/*.tar    nextcloud/config/config.php
    Assert file exists in archive    /opt/ncp-backups/*.tar    nextcloud-sqlbkp_.*.bak
    Assert file exists in archive    /opt/ncp-backups/*.tar    data/ncp/files/Nextcloud.png
