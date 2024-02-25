#!/usr/bin/env python3

"""
Automatic testing for NextCloudPi

Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
GPL licensed (see LICENSE file in repository root).
Use at your own risk!

   ./nextcloud_tests.py [IP]

More at https://ownyourbits.com
"""
import json
import sys
import os
import getopt
import configparser
import signal
import re
import time
from pathlib import Path

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement
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
    title = "test"

    def new(self, title):
        self.title = title
        print("[check] " + "{:16}".format(title), end=' ', flush = True)

    def check(self, expression, msg=None):
        if expression and not isinstance(expression, Exception):
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

def is_admin_notifications_checkbox(item: WebElement):
    try:
        input_item = item.find_element(By.TAG_NAME, "input")
        return input_item.get_attribute("name") == "adminNotifications"
    except:
        return False


def close_first_run_wizard(driver: WebDriver):
    wait = WebDriverWait(driver, 60)
    first_run_wizard = None
    try:
        first_run_wizard = driver.find_element(By.CSS_SELECTOR, "#firstrunwizard")
    except NoSuchElementException:
        pass
    if first_run_wizard is not None and first_run_wizard.is_displayed():
        wait.until(VisibilityOfElementLocatedByAnyLocator([(By.CLASS_NAME, "modal-container__close"),
                                                           (By.CLASS_NAME, "first-run-wizard__close-button")]))
        try:
            overlay_close_btn = driver.find_element(By.CLASS_NAME, "first-run-wizard__close-button")
            overlay_close_btn.click()
        except NoSuchElementException:
            overlay_close_btn = driver.find_element(By.CLASS_NAME, "modal-container__close")
            overlay_close_btn.click()
        time.sleep(3)


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
            try:
                driver.find_element(By.CSS_SELECTOR, ".login-form button[type=submit]").click()
            except NoSuchElementException:
                pass

    test.report("password", "Wrong password" not in driver.page_source, msg="Failed to login with provided password")

    test.new("settings config")
    wait = WebDriverWait(driver, 60)
    try:
        wait.until(VisibilityOfElementLocatedByAnyLocator([(By.CSS_SELECTOR, "#security-warning-state-ok"),
                                                           (By.CSS_SELECTOR, "#security-warning-state-warning"),
                                                           (By.CSS_SELECTOR, "#security-warning-state-error")]))

        element_ok = driver.find_element(By.ID, "security-warning-state-ok")
        element_warn = driver.find_element(By.ID, "security-warning-state-warning")

        if element_warn.is_displayed():

            warnings = driver.find_elements(By.CSS_SELECTOR, "#postsetupchecks > .warnings > li")
            for warning in warnings:
                if re.match(r'.*Server has no maintenance window start time configured.*', warning.text):
                    continue
                elif re.match(r'.*Could not check for JavaScript support.*', warning.text):
                    continue
                else:
                    raise ConfigTestFailure(f"WARN: {warning.text}")

            if driver.find_element(By.CSS_SELECTOR, "#postsetupchecks > .errors").is_displayed():
                try:
                    first_error = driver.find_element(By.CSS_SELECTOR, "#postsetupchecks > .errors > li")
                except NoSuchElementException:
                    first_error = None
                raise ConfigTestFailure(f"ERROR: {first_error.text if first_error is not None else 'unexpected error'}")

            infos = driver.find_elements(By.CSS_SELECTOR, "#postsetupchecks > .info > li")
            for info in infos:
                if re.match(r'.*Your installation has no default phone region set.*', info.text) \
                        or re.match(r'The PHP module "imagick" is not enabled', info.text):
                    continue
                else:
                    print(f'INFO: {info.text}')
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

    close_first_run_wizard(driver)

    test.new("admin section (1)")
    try:
        driver.get(f"https://{IP}:{nc_port}/index.php/settings/admin")
    except Exception as e:
        test.check(e, msg=f"{tc.red}error:{tc.normal} unable to reach {tc.yellow + IP + tc.normal}")
    old_admin_notifications_value = None
    list_items = driver.find_elements(By.CSS_SELECTOR, "#nextcloudpi li")
    try:
        wait.until(lambda drv: drv.find_element(By.ID, "nextcloudpi").is_displayed())
        expected = {
            "ncp_version": False,
            "php_version": False,
            "debian_release": False,
            "canary": False,
            "admin_notifications": False,
            # "usage_surveys": False,
            "notification_accounts": False
        }
        version_re = re.compile(r'^(v\d+\.\d+\.\d+)$')
        with (Path(__file__).parent / '../etc/ncp.cfg').open('r') as cfg_file:
            ncp_cfg = json.load(cfg_file)
        for li in list_items:
            try:
                inp = li.find_element(By.TAG_NAME, "input")
                inp_name = inp.get_attribute("name")
                inp_value = inp.get_attribute("value") if inp.get_attribute("type") != "checkbox" else inp.is_selected()
                if inp_name == "canary":
                    expected["canary"] = True
                elif inp_name == "adminNotifications":
                    old_admin_notifications_value = inp_value
                    expected["admin_notifications"] = True
                elif inp_name == "usageSurveys":
                    expected["usage_surveys"] = True
                elif inp_name == "notificationAccounts":
                    expected["notification_accounts"] = True
            except:
                divs = li.find_elements(By.TAG_NAME, "div")
                if 'ncp version' in divs[0].text.lower() and version_re.match(divs[1].text):
                    expected['ncp_version'] = True
                elif 'php version' in divs[0].text.lower() and divs[1].text == ncp_cfg['php_version']:
                    expected['php_version'] = True
                elif 'debian release' in divs[0].text.lower() and divs[1].text == ncp_cfg['release']:
                    expected['debian_release'] = True
        failed = list(map(lambda item: item[0], filter(lambda item: not item[1], expected.items())))
        test.check(len(failed) == 0, f"checks failed for admin section: [{', '.join(failed)}]")
    except Exception as e:
        test.check(e)
    test.new("admin section (2)")
    wait = WebDriverWait(driver, 10)
    try:
        li = next(filter(is_admin_notifications_checkbox, list_items))
        li.find_element(By.TAG_NAME, "input").click()
        time.sleep(15)
        wait.until(lambda drv: drv.find_element(By.CSS_SELECTOR, "#nextcloudpi .error-message:not(.hidden)"))
        error_box = driver.find_element(By.CSS_SELECTOR, "#nextcloudpi .error-message")
        test.check(False, str(error_box.text))
    except Exception as e:
        if isinstance(e, TestFailed):
            raise e
        test.check(True)

    test.new("admin section (3)")
    try:
        driver.refresh()
    except Exception as e:
        test.check(e, msg=f"{tc.red}error:{tc.normal} unable to reach {tc.yellow + IP + tc.normal}")
    try:
        list_items = driver.find_elements(By.CSS_SELECTOR, "#nextcloudpi li")
        li = next(filter(is_admin_notifications_checkbox, list_items))
        test.check(li.find_element(By.TAG_NAME, "input").is_selected() != old_admin_notifications_value,
                   "Toggling admin notifications didn't work")
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

    options = webdriver.FirefoxOptions()
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt in ('-n', '--new'):
            if os.path.exists(test_cfg):
                os.unlink(test_cfg)
        elif opt == '--no-gui':
            options.add_argument("-headless")
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

    driver = webdriver.Firefox(options=options)
    failed=False
    try:
        test_nextcloud(IP, nc_port, driver)
    except Exception as e:
        print(e)
        print(traceback.format_exc())
        failed=True
    finally:
        driver.close()
    if failed:
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
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
