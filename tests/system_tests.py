#!/usr/bin/env python3

"""
Automatic system testing for NextCloudPi

Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
GPL licensed (see LICENSE file in repository root).
Use at your own risk!

   ./system_tests.py [user@ip]

More at https://ownyourbits.com
"""
import json
import subprocess

pre_cmd = []

import sys
import getopt
import os
import signal
from subprocess import run, getstatusoutput, PIPE, CompletedProcess
from typing import Optional

processes_must_be_running = [
        'apache2',
        'cron',
        'mariadb',
        'php-fpm',
        'postfix',
        'redis-server',
        ]

binaries_must_be_installed = [
        'jq',
        'dialog',
        'dnsmasq',
        'git',
        'letsencrypt',
        'noip2',
        'rsync',
        'ssh',
        ]

binaries_no_docker = [
        'btrfs',
        'fail2ban-server',
        'udiskie',
        'ufw',
        'samba',
        ]

files_must_exist = [
        '/usr/local/etc/ncp-version',
        ]

files_must_not_exist = [
        '/.ncp-image',
        ]

lxc_command = 'lxc'
if 'USE_INCUS' in os.environ and os.environ['USE_INCUS'] == 'yes':
    lxc_command = 'incus'


class tc:
    "terminal colors"
    brown='\033[33m'
    yellow='\033[33;1m'
    green='\033[32m'
    red='\033[31m'
    normal='\033[0m'


def usage():
    "Print usage"
    print("usage: system_tests.py [user@ip]")


def is_running(process):
    "check that a process is running"
    print("[running] " + tc.brown + "{:16}".format(process) + tc.normal, end=' ')
    result = run(pre_cmd + ['pgrep', '-cf', process], stdout=PIPE, stderr=PIPE)
    if result.returncode == 0:
        print(tc.green + "ok" + tc.normal)
    else:
        print(tc.red + "error" + tc.normal)
    return result.returncode == 0


def file_exists(file):
    "check that a file exists"
    print("[exists ] " + tc.brown + "{:16}".format(file) + tc.normal, end=' ')
    result = run(pre_cmd + ['test', '-f', file], stdout=PIPE, stderr=PIPE)
    if result.returncode == 0:
        print(tc.green + "ok" + tc.normal)
    else:
        print(tc.red + "error" + tc.normal)
    return result.returncode == 0


def file_not_exists(file):
    "check that a file doesn't exist"
    print("[nexists] " + tc.brown + "{:16}".format(file) + tc.normal, end=' ')
    result = run(pre_cmd + ['test', '-f', file], stdout=PIPE, stderr=PIPE)
    if result.returncode != 0:
        print(tc.green + "ok" + tc.normal)
    else:
        print(tc.red + "error" + tc.normal)
    return result.returncode == 0


def check_processes_running(processes):
    "check that all processes are running"
    ret = True
    for process in processes:
        if not is_running(process):
            ret = False
    return ret


def is_installed(binary):
    "check that a binary is installed"
    print("[install] " + tc.brown + "{:16}".format(binary) + tc.normal, end=' ')
    result = run(pre_cmd + ['sudo', 'which', binary], stdout=PIPE, stderr=PIPE)
    if result.returncode == 0:
        print(tc.green + "ok" + tc.normal)
    else:
        print(tc.red + "error" + tc.normal)
    return result.returncode == 0


def check_binaries_installed(binaries):
    "check that all the binaries are installed"
    ret = True
    for binary in binaries:
        if not is_installed(binary):
            ret = False
    return ret


def check_files_exist(files):
    "check that all the files exist"
    ret = True
    for file in files:
        if not file_exists(file):
            ret = False
    return ret


def check_files_dont_exist(files):
    "check that all the files don't exist"
    ret = True
    for file in files:
        if file_not_exists(file):
            ret = False
    return ret


def check_notify_push():
    "check that notify_push is installed and set up"
    result = run(pre_cmd + ['ncc', 'notify_push:self-test'], stdout=PIPE, stderr=PIPE)

    print("[push   ] " + tc.brown + "notify_push self-test" + tc.normal, end=' ')
    if result.returncode == 0:
        print(tc.green + "ok" + tc.normal)
        return True
    else:
        print(tc.red + "error" + tc.normal)
        print(result.stderr)
        print(result.stdout)
        return False

def is_lxc():
    "check that we are running inside a LXC container"
    (exitcode, output) = getstatusoutput('grep -q container=lxc /proc/1/environ')
    return exitcode == 0

def signal_handler(sig, frame):
        sys.exit(0)


class ProcessExecutionException(Exception):
    pass


def test_autoupdates():
    def handle_error(r: CompletedProcess) -> CompletedProcess:
        if r.returncode != 0:
            print(f"{tc.red}error{tc.normal}\n{r.stdout.decode('utf-8') if r.stdout else ''}\n{r.stderr.decode('utf-8') if r.stderr else ''}"
                  f" -- command failed: '{' '.join(r.args)}'")
            raise ProcessExecutionException()
        return CompletedProcess(r.args,
                                r.returncode,
                                r.stdout.decode('utf-8') if r.stdout else '',
                                r.stderr.decode('utf-8') if r.stderr else '')

    def set_cohorte_id(cohorte_id: int) -> CompletedProcess:
        proc = subprocess.Popen(pre_cmd + ['cat', '/usr/local/etc/instance.cfg'], stdout=subprocess.PIPE, shell=False)
        #handle_error(run(pre_cmd + ['cat', '/usr/local/etc/instance.cfg'], stdout=subprocess.STDOUT, stderr=subprocess.STDOUT))
        #r = handle_error(run(pre_cmd + ['cat', '/usr/local/etc/instance.cfg'], stdout=PIPE, stderr=PIPE))
        (out, err) = proc.communicate()
        if proc.returncode != 0:
            raise ProcessExecutionException()
        try:
            instance_cfg = json.loads(out)
        except json.decoder.JSONDecodeError as e:
            print(f"{tc.red}error{tc.normal} /usr/local/etc/instance.cfg could not be parsed, was: {out}\n{err}")
            print(f"Command: '{' '.join(pre_cmd + ['cat', '/usr/local/etc/instance.cfg'])}'")
            raise e

        instance_cfg['cohorteId'] = cohorte_id
        return handle_error(run(pre_cmd + ['bash', '-c', f'echo \'{json.dumps(instance_cfg)}\' > /usr/local/etc/instance.cfg'], stdout=PIPE, stderr=PIPE))

    print(f"[updates] {tc.brown}staged rollouts{tc.normal}", end=' ')
    try:
        result = handle_error(run(pre_cmd + ['cat', '/usr/local/etc/ncp-version'], stdout=PIPE, stderr=PIPE))
        if 'v99.99.99' in result.stdout:
            print(f"{tc.yellow}skipped{tc.normal} (already updated to v99.99.99)")
            return True
        handle_error(run(pre_cmd + ['rm', '-f', '/var/run/.ncp-latest-version']))
        handle_error(run(pre_cmd + ['sed', '-i', 's|BRANCH="master"|BRANCH="testing/staged-rollouts-1"|', '/usr/local/bin/ncp-check-version'], stdout=PIPE, stderr=PIPE))
        set_cohorte_id(1)
        result = run(pre_cmd + ['test', '-f', '/var/run/.ncp-latest-version'], stdout=PIPE, stderr=PIPE)
        if result.returncode == 0:
            result = handle_error(run(pre_cmd + ['cat', '/var/run/.ncp-latest-version'], stdout=PIPE, stderr=PIPE))
            if 'v99.99.99' in result.stdout:
                print(f"{tc.red}error{tc.normal} Auto update to v99.99.99 was unexpectedly not prevented by disabled cohorte id")
                return False

        set_cohorte_id(99)
        handle_error(run(pre_cmd + ['/usr/local/bin/ncp-check-version'], stdout=PIPE, stderr=PIPE))
        result = handle_error(run(pre_cmd + ['cat', '/var/run/.ncp-latest-version'], stdout=PIPE, stderr=PIPE))
        if 'v99.99.99' not in result.stdout:
            print(f"{tc.red}error{tc.normal} Expected latest detected version to be v99.99.99, was {result.stdout}")
            return False

        handle_error(run(pre_cmd + ['/usr/local/bin/ncp-test-updates']))
        handle_error(run(pre_cmd + ['ncp-update', 'testing/staged-rollouts-1'], stdout=PIPE, stderr=PIPE))
        result = handle_error(run(pre_cmd + ['cat', '/usr/local/etc/v99.99.99.success'], stdout=PIPE, stderr=PIPE))
        if 'updated' not in result.stdout:
            print(f"{tc.red}error{tc.normal} update to v99.99.99 did not succeed")
            return False
        print(f"{tc.green}ok{tc.normal}")

    except ProcessExecutionException:
        return False

    return True

if __name__ == "__main__":

    signal.signal(signal.SIGINT, signal_handler)

    # parse options
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'h', ['help', 'no-ping', 'non-interactive', 'skip-update-test'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    skip_ping = False
    interactive = True
    skip_update_test = False
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt == '--skip-update-test':
            print("Skipping update test")
            skip_update_test = True
        elif opt == '--no-ping':
            skip_ping = True
        elif opt == '--non-interactive':
            interactive = False
        else:
            usage()
            sys.exit(2)

    # parse arguments
    ssh_cmd = "ssh root@nextcloudpi.local"
    if len(args) > 0:
        if '@' in args[0]:
            ssh_cmd = "ssh " + args[0]
        else:
            print(tc.brown + "* Ignoring invalid SSH argument " + tc.yellow + args[0] + tc.normal)
            args = []

    # detect if we are running this in a NCP instance
    try:
        dockers_running = run(['docker', 'ps', '--format', '{{.Names}}'], stdout=PIPE).stdout.decode('utf-8')
    except:
        dockers_running = ''

    # detect if we are running this in a LXC instance
    try:
        lxc_running = run([lxc_command, 'info', 'ncp'], stdout=PIPE, check = True)
    except:
        lxc_running = False

    try:
        systemd_container_running = run(['machinectl', 'show', 'ncp'], stdout=PIPE, check = True)
    except:
        systemd_container_running = False


    # local method
    if os.path.exists('/usr/local/etc/ncp-baseimage'):
        print(tc.brown + "* local NCP instance detected" + tc.normal)
        if not is_lxc():
            binaries_must_be_installed = binaries_must_be_installed + binaries_no_docker
        pre_cmd = []

    # docker method
    elif 'nextcloudpi' in dockers_running:
        print( tc.brown + "* local NCP docker instance detected" + tc.normal)
        pre_cmd = ['docker', 'exec']
        if interactive:
            pre_cmd.append('-ti')
        pre_cmd.append('nextcloudpi')

    # LXC method
    elif lxc_running:
        print( tc.brown + "* local LXC instance detected" + tc.normal)
        pre_cmd = [lxc_command, 'exec', 'ncp', '--']

    elif systemd_container_running:
        pre_cmd = ['systemd-run', '--wait', '-P', '--machine=ncp']

    # SSH method
    else:
        if len(args) == 0:
            print( tc.brown + "* No local NCP instance detected, trying SSH with " +
               tc.yellow + ssh_cmd + tc.normal + "...")
        binaries_must_be_installed = binaries_must_be_installed + binaries_no_docker
        pre_cmd = ['ssh', '-o UserKnownHostsFile=/dev/null' , '-o PasswordAuthentication=no',
                   '-o StrictHostKeyChecking=no', '-o ConnectTimeout=10', ssh_cmd[4:]]

        if not skip_ping:
            at_char = ssh_cmd.index('@')
            ip = ssh_cmd[at_char+1:]
            ping_cmd = run(['ping', '-c1', '-w10', ip], stdout=PIPE, stderr=PIPE)
            if ping_cmd.returncode != 0:
                print(tc.red + "No connectivity to " + tc.yellow + ip + tc.normal)
                #sys.exit(1)

        ssh_test = run(pre_cmd + [':'], stdout=PIPE, stderr=PIPE)
        if ssh_test.returncode != 0:
            ssh_copy = run(['ssh-copy-id', ssh_cmd[4:]], stderr=PIPE)
            if ssh_copy.returncode != 0:
                print(tc.red + "SSH connection failed" + tc.normal)
                sys.exit(1)

    print(pre_cmd)
    # checks
    print("\nNextCloudPi system checks")
    print("-------------------------")
    running_result = check_processes_running(processes_must_be_running)
    install_result = check_binaries_installed(binaries_must_be_installed)
    files1_result  = check_files_exist(files_must_exist)
    files2_result  = check_files_dont_exist(files_must_not_exist)
    notify_push_result = check_notify_push()
    update_test_result = True if skip_update_test else test_autoupdates()

    if running_result and install_result and files1_result and files2_result and notify_push_result and update_test_result:
        sys.exit(0)
    else:
        sys.exit(1)

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
