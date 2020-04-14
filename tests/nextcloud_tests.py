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
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.common.exceptions import NoSuchElementException

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
    blue = '\033[1;34m'

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

def usage():
    "Print usage"
    print("usage: nextcloud_tests.py [--new] [ip]")
    print("--new removes saved configuration")

def signal_handler(sig, frame):
        sys.exit(0)

def test_nextcloud(IP, selenium_host):
    """ Login and assert admin page checks"""
    test = Test()
    if selenium_host is None:
        driver = webdriver.Firefox(service_log_path='/dev/null')
    else:
        driver = webdriver.Remote(command_executor=selenium_host, desired_capabilities=DesiredCapabilities.FIREFOX)
    with driver:
        driver.implicitly_wait(60)
        test.new("nextcloud page")
        try:
            driver.get("https://" + IP + "/index.php/settings/admin/overview")
        except:
            test.check(False)
            print(tc.red + "error:" + tc.normal + " unable to reach " + tc.yellow + IP + tc.normal)
            sys.exit(1)
        test.check("NextCloudPi" in driver.title)
        trusted_domain_str = "You are accessing the server from an untrusted domain"
        test.report("trusted domain", trusted_domain_str not in driver.page_source)
        try:
            driver.find_element_by_id("user").send_keys(nc_user)
            driver.find_element_by_id("password").send_keys(nc_pass)
            driver.find_element_by_id("submit").click()
        except: pass
        test.report("password", "Wrong password" not in driver.page_source)

        test.new("settings config")
        try:
            wait = WebDriverWait(driver, 60)
            wait.until(EC.visibility_of(driver.find_element_by_class_name("icon-checkmark-white")))
            test.check(True)
        except:
            driver.implicitly_wait(0)
            is_warning = False
            err_div = driver.find_element_by_id("security-warning-state-failure")
            warn_div = driver.find_element_by_id("security-warning-state-warning")
            if "hidden" not in err_div.get_attribute("class"):
                print(tc.red + "error: " + tc.normal + err_div.text)
            elif "hidden" not in warn_div.get_attribute("class"):
                is_warning = True
                print(tc.yellow + "warn: " + tc.normal + warn_div.text)
            else:
                print(tc.red + "error: " + tc.normal + "Unknown error")

            errors = driver.find_elements_by_css_selector("#postsetupchecks>.errors:not(.hidden)>li")
            warnings = driver.find_elements_by_css_selector("#postsetupchecks>.warnings:not(.hidden)>li")
            notes = driver.find_elements_by_css_selector("#postsetupchecks>.info:not(.hidden)>li")
            if len(errors) > 0:
                line_start = "- " + tc.red + "err:  " + tc.normal
                print(line_start + ("\n" + line_start).join([err.text for err in errors]))
            if len(warnings) > 0:
                line_start = "- " + tc.yellow + "warn: " + tc.normal
                print(line_start + ("\n" + line_start).join([warning.text for warning in warnings]))
            if len(notes) > 0:
                line_start = "- " + tc.blue + "info: " + tc.normal
                print(line_start + ("\n" + line_start).join([note.text for note in notes]))

            def shoud_ignore(line):
                if "This instance is missing some recommended PHP modules." in line.text:
                    child_list = line.find_elements_by_tag_name("li")
                    return len(child_list) == 1 and "imagick" in child_list[0].text
                return False

            remaining_errors = [e for e in errors if not shoud_ignore(e)]
            remaining_warnings = [w for w in warnings if not shoud_ignore(w)]
            remaining_notes = [n for n in notes if not shoud_ignore(n)]

            test.check(is_warning and len(remaining_errors) == len(remaining_warnings) == len(remaining_notes) == 0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)

    # parse options
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'hn', ['help'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt in ('-n', '--new'):
            if os.path.exists(test_cfg):
                os.unlink(test_cfg)
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
    selenium_host = args[1] if len(args) > 1 else None
    print("Nextcloud tests " + tc.yellow + IP + tc.normal )
    print("---------------------------")
    test_nextcloud(IP, selenium_host)

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
