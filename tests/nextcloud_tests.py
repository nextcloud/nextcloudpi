#!/usr/bin/env python3

"""
Automatic testing for NextCloudPi

Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
GPL licensed (see LICENSE file in repository root).
Use at your own risk!

   ./nextcloud_tests.py [IP]

More at https://ownyourbits.com
"""

import sys
import time
import urllib
import os
import getopt
import configparser
import signal
import re
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.service import Service
from selenium.webdriver.firefox.webdriver import WebDriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.firefox.options import Options
from selenium.common.exceptions import NoSuchElementException, WebDriverException, TimeoutException
from typing import List, Tuple
import traceback

suite_name = "nextcloud tests"
test_cfg = 'test_cfg.txt'
test_log = 'test_log.txt'


class tc:
    "terminal colors"
    brown='\033[33m'
    yellow='\033[33;1m'
    green='\033[32m'
    red='\033[31m'
    normal='\033[0m'


class TestFailed(Exception):
    pass


class Test:
    title  = "test"

    def new(self, title):
        self.title = title
        print("[check] " + "{:16}".format(title), end=' ', flush = True)

    def check(self, expression, msg=None):
        if expression:
            print(tc.green + "ok" + tc.normal)
            self.log("ok")
        else:
            print(tc.red + "error" + tc.normal)
            self.log("error")
            exc_args = [f"'{self.title}' failed"]
            if isinstance(expression, Exception):
                exc_args.append(expression)
            if msg is not None:
                exc_args.append(msg)

            raise TestFailed(*exc_args)

    def report(self, title, expression, msg=None):
        self.new(title)
        self.check(expression, msg=msg)

    def log(self, result):
        config = configparser.ConfigParser()
        if os.path.exists(test_log):
            config.read(test_log)
        if not config.has_section(suite_name):
            config[suite_name] = {}
        config[suite_name][self.title] = result
        with open(test_log, 'w') as logfile:
            config.write(logfile)


def usage():
    "Print usage"
    print("usage: nextcloud_tests.py [--new] [ip]")
    print("--new removes saved configuration")


def signal_handler(sig, frame):
        sys.exit(0)


class VisibilityOfElementLocatedByAnyLocator:
    def __init__(self, locators: List[Tuple[By, str]]):
        self.locators = locators

    def __call__(self, driver):
        for locator in self.locators:
            try:
                element = driver.find_element(*locator)
                if element.is_displayed():
                    return True
            except (NoSuchElementException, WebDriverException, TimeoutException):
                pass
        return False


class ConfigTestFailure(Exception):
    pass


def test_nextcloud(IP: str, nc_port: str, driver: WebDriver):
    """ Login and assert admin page checks"""
    test = Test()
    test.new("nextcloud page")
    try:
        driver.get(f"https://{IP}:{nc_port}/index.php/settings/admin/overview")
    except Exception as e:
        test.check(e, msg=f"{tc.red}error:{tc.normal} unable to reach {tc.yellow + IP + tc.normal}")
    test.check("NextCloudPi" in driver.title, msg="NextCloudPi not found in page title!")
    trusted_domain_str = "You are accessing the server from an untrusted domain"
    test.report("trusted domain", trusted_domain_str not in driver.page_source, f"Domain '{IP}' is not trusted")
    try:
        driver.find_element(By.ID, "user").send_keys(nc_user)
        driver.find_element(By.ID, "password").send_keys(nc_pass)
        driver.find_element(By.ID, "submit-form").click()
    except NoSuchElementException:
        try:
            driver.find_element(By.ID, "submit").click()
        except NoSuchElementException:
            pass

    test.report("password", "Wrong password" not in driver.page_source, msg="Failed to login with provided password")

    test.new("settings config")
    wait = WebDriverWait(driver, 30)
    try:
        wait.until(VisibilityOfElementLocatedByAnyLocator([(By.CSS_SELECTOR, "#security-warning-state-ok"),
                                                           (By.CSS_SELECTOR, "#security-warning-state-warning"),
                                                           (By.CSS_SELECTOR, "#security-warning-state-error")]))

        element_ok = driver.find_element(By.ID, "security-warning-state-ok")
        element_warn = driver.find_element(By.ID, "security-warning-state-warning")

        if element_warn.is_displayed():

            if driver.find_element(By.CSS_SELECTOR, "#postsetupchecks > .errors").is_displayed() \
                    or driver.find_element(By.CSS_SELECTOR, "#postsetupchecks > .warnings").is_displayed():
                raise ConfigTestFailure("There have been errors or warnings")

            infos = driver.find_elements(By.CSS_SELECTOR, "#postsetupchecks > .info > li")
            for info in infos:
                if re.match(r'.*Your installation has no default phone region set.*', info.text):
                    continue
                else:

                    php_modules = info.find_elements(By.CSS_SELECTOR, "li")
                    if len(php_modules) != 1:
                        raise ConfigTestFailure(f"Could not find the list of php modules within the info message "
                                                f"'{infos[0].text}'")
                    if php_modules[0].text != "imagick":
                        raise ConfigTestFailure("The list of php_modules does not equal [imagick]")

        elif not element_ok.is_displayed():
            raise ConfigTestFailure("Neither the warnings nor the ok status is displayed "
                                    "(so there are probably errors or the page is broken)")

        test.check(True)

    except Exception as e:
        test.check(e)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)

    # parse options
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'hn', ['help', 'new', 'no-gui'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    options = Options()
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt in ('-n', '--new'):
            if os.path.exists(test_cfg):
                os.unlink(test_cfg)
        elif opt == '--no-gui':
            options.headless = True
        else:
            usage()
            sys.exit(2)

    nc_user = False
    nc_pass = False
    config = configparser.ConfigParser()

    if os.path.exists(test_cfg):
        config.read(test_cfg)
        try:
            nc_user = config['credentials']['nc_user']
            nc_pass = config['credentials']['nc_pass']
        except: pass

    if not nc_user or not nc_pass:
        nc_user = input("Nextcloud username (empty=ncp): ")
        nc_user = "ncp" if nc_user == "" else nc_user
        nc_pass = input("Nextcloud " + nc_user + " password (empty=ownyourbits): ")
        nc_pass = "ownyourbits" if nc_pass == "" else nc_pass
        print("")

        if not config.has_section('credentials'):
            config['credentials'] = {}
        config['credentials']['nc_user' ] = nc_user
        config['credentials']['nc_pass' ] = nc_pass
        with open(test_cfg, 'w') as configfile:
            config.write(configfile)

    # test
    IP = args[0] if len(args) > 0 else 'localhost'
    nc_port = args[1] if len(args) > 1 else "443"
    print("Nextcloud tests " + tc.yellow + IP + tc.normal)
    print("---------------------------")

    driver = webdriver.Firefox(service_log_path='/dev/null', options=options)
    try:
        test_nextcloud(IP, nc_port, driver)
    except Exception as e:
        print(e)
        print(traceback.format_exc())
    finally:
        driver.close()

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
