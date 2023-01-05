import json
import os
import re
import subprocess
from subprocess import PIPE
import random
import string
import time
from typing import Dict
from robot.api import FatalError, Error, logger
import tempfile


class NcpRobotLib:
    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self, http_port=80, https_port=443, webui_port=4443):
        self._http_port = http_port
        self._https_port = https_port
        self._webui_port = webui_port
        self._docker: Dict[str, any] = {
            'container': None
        }

    def setup_ncp(self, instance_type, version):
        if instance_type == 'docker':
            container_name = 'nextcloudpi-' + ''.join(random.choice(string.digits) for i in range(6))
            image = version if ':' in version else f"ownyourbits/nextcloudpi:{version}"
            d_run = subprocess.run([
                'docker', 'run', '-d',
                '-p', f'127.0.0.1:{self._http_port}:80',
                '-p', f'127.0.0.1:{self._https_port}:443',
                '-p', f'127.0.0.1:{self._webui_port}:4443',
                '--name', container_name,
                image, 'localhost'
            ],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if d_run.returncode != 0:
                raise FatalError(f"Failed to start test instance: \n'{d_run.stderr}'")

            self._docker['container'] = container_name
            logger.info("Waiting for container startup")
            time.sleep(20)
            self.ncp_is_running()

        else:
            raise FatalError(f"Invalid instance type '{instance_type}'")

    def ncp_is_running(self):

        d_run = subprocess.run(['docker', 'container', 'ls', '--filter', f'name={self._docker["container"]}'],
                               stdout=PIPE, stderr=PIPE)
        re_string = r'.* Up.* ' + self._docker['container'] + r'.*'
        docker_success_re = re.compile(re_string, flags=re.DOTALL)

        if not docker_success_re.match(d_run.stdout.decode('utf-8')):
            raise AssertionError(f"Failed to start test instance: 'Container status is not 'Up'")

    def destroy_ncp(self):
        # time.sleep(60)
        if self._docker['container'] is None:
            raise Error("Container not running")

        _ = subprocess.run(['docker', 'stop', self._docker['container']])
        try:
            self.ncp_is_running()
            raise FatalError("Failed to stop instance - ncp is still running")
        except AssertionError:
            pass
        finally:
            d_run = subprocess.run(['docker', 'rm', self._docker['container']])
            err = None
            if d_run.returncode != 0:
                err = FatalError(f"Failed to delete container {self._docker['container']}")
            self._docker['container'] = None
            if err is not None:
                raise FatalError(err)

    def create_backup_in(self, target, *args):
        logger.info(f"Creating backup in {target}...")
        self.ncp_is_running()
        backup_cfg = {
            "id": "nc-backup",
            "name": "nc-backup",
            "title": "nc-backup",
            "description": "Backup this NC instance to a file",
            "info": "This will always include the current Nextcloud directory and the Database.\nYou can choose to include or exclude NC-data.",
            "infotitle": "",
            "params": [
                {
                    "id": "DESTDIR",
                    "name": "Destination directory",
                    "value": target,
                    "suggest": "/media/USBdrive/ncp-backups"
                },
                {
                    "id": "INCLUDEDATA",
                    "name": "Include data",
                    "value": "no" if 'dataless' in args else "yes",
                    "type": "bool"
                },
                {
                    "id": "COMPRESS",
                    "name": "Compress",
                    "value": "yes" if 'compressed' in args else "no",
                    "type": "bool"
                },
                {
                    "id": "BACKUPLIMIT",
                    "name": "Number of backups to keep",
                    "value": "99",
                    "suggest": "4"
                }
            ]
        }
        temp_dir = tempfile.TemporaryDirectory()
        tmp_file_path = os.path.join(temp_dir.name, 'nc-backup.cfg')
        with open(tmp_file_path, 'w') as f:
            json.dump(backup_cfg, f)

        backup_config_path = '/data/ncp/nc-backup.cfg'
        d_run = self.run_on_ncp('rm', backup_config_path)
        logger.info(d_run.stdout)
        if d_run.returncode != 0:
            raise AssertionError(f"Unexpected error: {d_run.stderr}")

        d_run = subprocess.run(['docker', 'cp', tmp_file_path, f'{self._docker["container"]}:{backup_config_path}'])
        logger.info(d_run.stdout)
        if d_run.returncode != 0:
            raise AssertionError(f"Unexpected error: {d_run.stderr}")

        temp_dir.cleanup()

        d_run = self.run_on_ncp('chown', 'root:www-data', backup_config_path)
        logger.info(d_run.stdout)
        if d_run.returncode != 0:
            raise AssertionError(f"Unexpected error: {d_run.stderr}")

        d_run = self.run_on_ncp('chmod', '660', backup_config_path)
        logger.info(d_run.stdout)
        if d_run.returncode != 0:
            raise AssertionError(f"Unexpected error: {d_run.stderr}")

        d_run = self.run_on_ncp('bash', '-c', "set -x "
                                              "&& source /usr/local/etc/library.sh "
                                              "&& echo \"ncp library loaded.\" "
                                              "&& run_app nc-backup")
        logger.info(d_run.stdout)
        if d_run.returncode != 0:
            raise AssertionError(f"An error occurred while creating backup: \n{d_run.stderr}")

    def run_on_ncp(self, *command):
        run_cmd = ['docker', 'exec', self._docker['container']]
        run_cmd.extend(command)
        logger.debug(f"Executing: '{run_cmd}'")
        return subprocess.run(run_cmd, stdout=PIPE, stderr=PIPE)

    def assert_file_exists_in_archive(self, backup_path, file, silent=False):
        if not silent:
            logger.info(f"Checking if '{file}' exists in any archive in '{backup_path}'")
        d_run = self.run_on_ncp('bash', '-c', f'compgen -G "{backup_path}"')
        if d_run.returncode != 0:
            raise AssertionError(f'No such backup: {backup_path}')
        archive = d_run.stdout.decode('utf-8').split('\n')[0]
        d_run = self.run_on_ncp('tar', '-tf', archive)
        if d_run.returncode != 0:
            raise AssertionError(f'Error reading archive: {archive}')
        match = re.search(file, d_run.stdout.decode('utf-8'))
        if match is None:
            raise AssertionError(f'File not found in backup: {file}')

    def assert_file_exists_not_in_archive(self, backup_path, file):
        logger.info(f"Checking that '{file}' does not exist in any archive in '{backup_path}'")
        try:
            self.assert_file_exists_in_archive(backup_path, file, True)
            raise AssertionError(f"File unexpectedly found in backup: {file}")
        except AssertionError:
            pass
