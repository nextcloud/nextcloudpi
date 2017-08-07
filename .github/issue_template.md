<!--
Thanks for reporting issues back to NextCloudPi! 

Here you can file questions, bugs and feature requests

If there is an important security issue that has gone unnoticed, please send a private email to nacho _at_ ownyourbits.com

### QUESTIONS

Please, look at the issues tagged as 'question' to make sure that your question has not been already covered. https://github.com/nextcloud/nextcloudpi/issues?utf8=✓&q=label:question%20

Also, make sure to read the articles in ownyourbits explaining NextCloudPi extras before asking. https://ownyourbits.com/category/nextcloud/

### PROBLEMS

If you are running into problems, please fill out the following information. For questions or feature requests you don't have to

Keep in mind that many problems come from faulty power sources and corrupted SD cards, so make sure this is not the case for you before reporting.
-->

### What version of NextCloudPi are you using? ( eg: v0.17.2 )

### What is the base image that you installed on the SD card? ( eg: NextCloudPi_07-21-17 )

### Expected behavior

### Actual behaviour

### Steps to reproduce, from a freshly installed image

### Include logs
<details>
<summary>Nextcloud logs</summary>

```
Login as admin user into your Nextcloud and copy here the logs from
https://example.com/index.php/settings/admin/logging

If you don't have access to the web interface, open a terminal session and paste the last 100 lines of /var/www/nextcloud/data/nextcloud.log
```
</details>
<details>
<summary>Apache logs</summary>

```
Paste the output of `systemctl status apache2`
Paste the output of `tail -n 100 /var/log/apache2/*.log`
```
</details>
<details>
<summary>mariaDB logs</summary>

```
Paste the output of `systemctl status mysqld`
Paste the output of `tail -n 100 /var/log/mysql/*.log`
```
</details>
