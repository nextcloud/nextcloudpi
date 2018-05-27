#!/usr/bin/env python3

"""
Automatic testing for NextCloudPi

Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
GPL licensed (see LICENSE file in repository root).
Use at your own risk!

   ./tests.py <IP>

More at https://ownyourbits.com
"""

import unittest
import sys
import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


IP = sys.argv[1]


class AdminWebTest(unittest.TestCase):
    """
    Log as admin and assert that all internal checks pass ("All checks passed!")
    Also checks for correct trusted domain setting
    """

    def setUp(self):
        self.driver = webdriver.Firefox()

    # @unittest.skip("Skipping...")
    def test_admin_checks(self):
        """ Login and assert admin page checks"""
        driver = self.driver
        driver.implicitly_wait(150)  # first run can be really slow on QEMU
        driver.get("https://" + IP + "/index.php/settings/admin")
        self.assertIn("NextCloudPi", driver.title)
        trusted_domain_str = "You are accessing the server from an untrusted domain"
        self.assertNotIn(trusted_domain_str, driver.page_source)
        driver.find_element_by_id("user").send_keys("ncp")
        driver.find_element_by_id("password").send_keys("ownyourbits")
        driver.find_element_by_id("submit").click()
        self.assertNotIn("Wrong password", driver.page_source)

        wait = WebDriverWait(driver, 800) # first processing of this page is even slower in NC13
        wait.until(EC.visibility_of(driver.find_element_by_class_name("icon-checkmark")))

    def tearDown(self):
        self.driver.close()


class CreateUserTest(unittest.TestCase):
    """
    Create a user, then navigate a little bit
    """

    def setUp(self):
        self.driver = webdriver.Firefox()

    @unittest.skip("Skipping...")
    def test_user_creation(self):
        """ Create user test_user1 """
        driver = self.driver
        driver.get("https://" + IP + "/index.php/settings/users")

        driver.find_element_by_id("user").send_keys("ncp")
        driver.find_element_by_id("password").send_keys("ownyourbits")
        driver.find_element_by_id("submit").click()
        self.assertNotIn("Wrong password", driver.page_source)

        wait = WebDriverWait(driver, 150)
        wait.until(lambda driver: driver.find_element_by_id("newusername"))

        driver.find_element_by_id("newusername").send_keys("test_user1")
        driver.find_element_by_id("newuserpassword").send_keys("ownyourbits")
        driver.find_element_by_id("newuserpassword").send_keys(Keys.RETURN)

        time.sleep(5)

        # navigate a little bit
        driver.get("https://" + IP + "/index.php/settings/admin")
        self.assertIn("NextCloudPi", driver.title)
        driver.get("https://" + IP + "/index.php/settings/apps")
        self.assertIn("NextCloudPi", driver.title)

    def tearDown(self):
        self.driver.close()


class LoginNewUserTest(unittest.TestCase):
    """
    Login as the newly created user and check that we are in the Files App
    """

    def setUp(self):
        self.driver = webdriver.Firefox()

    @unittest.skip("Skipping...")
    def test_user_login(self):
        """ Login as test_user1 """
        driver = self.driver
        driver.implicitly_wait(210)  # first run can be really slow on QEMU
        driver.get("https://" + IP)

        self.assertIn("NextCloudPi", driver.title)
        driver.find_element_by_id("user").send_keys("test_user1")
        driver.find_element_by_id("password").send_keys("ownyourbits")
        driver.find_element_by_id("submit").click()
        self.assertNotIn("Wrong password", driver.page_source)

        time.sleep(60)  # first run can be really slow on QEMU
        wait = WebDriverWait(driver, 210)
        wait.until(lambda driver: driver.find_element_by_id("fileList"))

        # navigate a little bit
        driver.get("https://" + IP + "/index.php/settings/personal")
        self.assertIn("NextCloudPi", driver.title)

    def tearDown(self):
        self.driver.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("IP argument required")
        sys.exit()

    unittest.main(argv=['first-arg-is-ignored'], verbosity=2)

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
