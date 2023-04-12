#!/usr/bin/env python3

"""
Automatic testing for NextcloudPi

Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
GPL licensed (see LICENSE file in repository root).
Use at your own risk!

   ./activation_tests.py [IP]

More at https://ownyourbits.com
"""

import sys
import time
import traceback
import urllib
import os
import getopt
import configparser
import signal
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.firefox.options import Options
from selenium.common.exceptions import UnexpectedAlertPresentException
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import TimeoutException

suite_name = "activation tests"
test_cfg = 'test_cfg.txt'
test_log = 'test_log.txt'


class tc:
    "terminal colors"
    brown='\033[33m'
    yellow='\033[33;1m'
    green='\033[32m'
    red='\033[31m'
    normal='\033[0m'


def usage():
    "Print usage"
    print("usage: activation_tests.py [-t|--timeout <timeout>] [-h|--no-gui] [ip [nc-port [admin-port]]]")


class Test:
    title  = "test"

    def new(self, title):
        self.title = title
        print("[check] " + "{:16}".format(title), end=' ', flush = True)

    def check(self, expression):
        if expression:
            print(tc.green + "ok" + tc.normal)
            self.log("ok")
        else:
            print(tc.red + "error" + tc.normal)
            self.log("error")
            sys.exit(1)

    def report(self, title, expression):
        self.new(title)
        self.check(expression)

    def log(self, result):
        config = configparser.ConfigParser()
        if os.path.exists(test_log):
            config.read(test_log)
        if not config.has_section(suite_name):
            config[suite_name] = {}
        config[suite_name][self.title] = result
        with open(test_log, 'w') as logfile:
            config.write(logfile)


def is_element_present(driver, how, what):
    try: driver.find_element(by=how, value=what)
    except NoSuchElementException: return False
    return True


def signal_handler(sig, frame):
        sys.exit(0)


def test_activation(IP, nc_port, admin_port, options, wait_timeout=120):
    """ Activation process checks"""

    # activation page
    test = Test()
    driver = webdriver.Firefox(options=options)
    driver.implicitly_wait(5)
    test.new("activation opens")
    driver.get(f"https://{IP}:{nc_port}")
    test.check("NextcloudPi Activation" in driver.title)
    try:
        ncp_pass = driver.find_element(By.ID, "ncp-pwd").get_attribute("value")
        nc_pass = driver.find_element(By.ID, "nc-pwd").get_attribute("value")

        config = configparser.ConfigParser()
        if not config.has_section('credentials'):
            config['credentials'] = {}
        config['credentials']['ncp_user' ] = 'ncp'
        config['credentials']['ncp_pass' ] = ncp_pass
        config['credentials']['nc_user'  ] = 'ncp'
        config['credentials']['nc_pass'  ] = nc_pass
        with open(test_cfg, 'w') as configfile:
            config.write(configfile)

        driver.find_element(By.ID, "activate-ncp").click()
        test.report("activation click", True)
    except:
        ncp_pass = ""
        test.report("activation click", False)

    test.new("activation ends")
    try:
        wait = WebDriverWait(driver, wait_timeout)
        wait.until(EC.text_to_be_present_in_element((By.ID, 'error-box'), "ACTIVATION SUCCESSFUL"))
        test.check(True)
    except TimeoutException:
        test.check(False)
    except:
        test.check(True)
    try:
        driver.close()
    except Exception as e:
        traceback.print_exception(e)
        print(f"Could not close driver: {e}")

    # ncp-web
    test.new("ncp-web")
    driver = webdriver.Firefox(options=options)
    driver.implicitly_wait(30)
    try:
        driver.get(f"https://ncp:{urllib.parse.quote_plus(ncp_pass)}@{IP}:{admin_port}")
    except UnexpectedAlertPresentException:
        pass
    except Exception as e:
        print(f"WARN: Exception while attempting to get ncp-web: '{e}'")
        raise e
    test.check("NextcloudPi Panel" in driver.title)
    test.report("first run wizard", is_element_present(driver, By.ID, "first-run-wizard"))

    driver.close()


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)

    # parse options
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'ht:', ['help', 'timeout=', 'no-gui'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    arg_timeout = 120
    options = Options()
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt == '--no-gui':
            options.headless = True
        elif opt in ('-t', '--timeout'):
            arg_timeout = int(arg)
        else:
            usage()
            sys.exit(2)

    # test

    IP = args[0] if len(args) > 0 else 'localhost'
    nc_port = args[1] if len(args) > 1 else "443"
    admin_port = args[2] if len(args) > 2 else "4443"
    print("Activation tests " + tc.yellow + IP + tc.normal)
    print("---------------------------")

    test_activation(IP, nc_port, admin_port, options, arg_timeout)

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
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
