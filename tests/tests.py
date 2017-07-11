#!/usr/bin/env python3

# Automatic testing for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
#   ./tests.py <IP>
#
# More at https://ownyourbits.com
#

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import unittest
import pexpect
import sys
import time


IP = sys.argv[1]

#
# Login as Admin user and assert that all internal checks pass ( All checks passed! tick  )
# Also checks for correct trusted domain setting
#

class AdminWebTest(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Firefox()

    #@unittest.skip("Skipping...")
    def test_login(self):
        driver = self.driver
        driver.implicitly_wait(150) # first run can be really slow on QEMU
        driver.get("https://" + IP + "/index.php/settings/admin")
        self.assertIn("Nextcloud", driver.title)
        self.assertNotIn ( "You are accessing the server from an untrusted domain" , driver.page_source )
        driver.find_element_by_id("user").send_keys("admin")
        driver.find_element_by_id("password").send_keys("ownyourbits")
        driver.find_element_by_id("submit").click()
        self.assertNotIn ( "Wrong password" , driver.page_source )

        wait = WebDriverWait(driver, 150)
        element = wait.until(EC.visibility_of(driver.find_element_by_class_name("icon-checkmark")))

    def tearDown(self):
        self.driver.close()


#
# Create a user, then navigate a little bit
#

class CreateUserTest(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Firefox()

    #@unittest.skip("Skipping...")
    def test_login(self):
        driver = self.driver
        driver.get("https://" + IP + "/index.php/settings/users")

        driver.find_element_by_id("user").send_keys("admin")
        driver.find_element_by_id("password").send_keys("ownyourbits")
        driver.find_element_by_id("submit").click()
        self.assertNotIn ( "Wrong password" , driver.page_source )

        wait = WebDriverWait(driver, 150)
        wait.until(lambda driver: driver.find_element_by_id("newusername"))

        driver.find_element_by_id("newusername").send_keys("test_user1")
        driver.find_element_by_id("newuserpassword").send_keys("ownyourbits")
        driver.find_element_by_id("newuserpassword").send_keys(Keys.RETURN)

        time.sleep( 5 )

        # navigate a little bit
        driver.get("https://" + IP + "/index.php/settings/admin")
        self.assertIn("Nextcloud", driver.title)
        driver.get("https://" + IP + "/index.php/settings/apps")
        self.assertIn("Nextcloud", driver.title)

    def tearDown(self):
        self.driver.close()

#
# Login as the newly created user and check that we are in the Files App
#

class LoginNewUserTest(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Firefox()

    #@unittest.skip("Skipping...")
    def test_login(self):
        driver = self.driver
        driver.get("https://" + IP)

        self.assertIn("Nextcloud", driver.title)
        driver.find_element_by_id("user").send_keys("test_user1")
        driver.find_element_by_id("password").send_keys("ownyourbits")
        driver.find_element_by_id("submit").click()

        wait = WebDriverWait(driver, 60)
        wait.until(lambda driver: driver.find_element_by_id("fileList"))

        # navigate a little bit
        driver.get("https://" + IP + "/index.php/settings/personal")
        self.assertIn("Nextcloud", driver.title)

    def tearDown(self):
        self.driver.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print( "IP argument required" )
        sys.exit()

    unittest.main(argv=['first-arg-is-ignored'],verbosity=2)

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

