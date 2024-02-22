<?php
script('nextcloudpi', 'nextcloudpi-admin');
style('nextcloudpi', 'admin');
?>
<div id="nextcloudpi" class="section">
    <h2>NextcloudPi</h2>

    <h3>System Info</h3>
    <ul>
        <li>
            <div>NCP Version:</div>
            <div><?php echo $_["ncp_version"] ?></div>
        </li>
        <li>
            <div>PHP Version:</div>
            <div><?php echo $_["ncp"]["php_version"] ?></div>
        </li>
        <li>
            <div>Debian Release:</div>
            <div><?php echo $_["ncp"]["release"] ?></div>
        </li>
    </ul>
    <h3>Nextcloud Settings</h3>
    <ul id="ncp-settings-nc">
        <li>
            <input name="maintenance_window_start" type="number" value="<?php echo $_['maintenance_window_start']; ?>"/>
            <label for="maintenance_window_start">Maintenance Window Start Hour</label>
        </li>
        <li>
            <input name="default_phone_region" type="text" value="<?php echo $_['default_phone_region']; ?>"/>
            <label for="default_phone_region">Default Phone Region</label>
        </li>
    </ul>
    <h3>NCP Settings</h3>
    <ul id="ncp-settings">
        <li>
            <input name="canary" type="checkbox" <?php echo $_['community']['CANARY'] === 'yes' ? ' checked="checked"' : ''; ?>"/>
            <label for="canary">Enable updates from canary (testing) channel</label>
        </li>
        <li>
            <input name="adminNotifications"
                   type="checkbox" <?php echo $_['community']['ADMIN_NOTIFICATIONS'] === 'yes' ? ' checked="checked"' : ''; ?>"/>
            <label for="adminNotifications">Enable notifications about relevant changes in NCP</label>
        </li>
        <li>
            <input name="usageSurveys"
                   type="checkbox" <?php echo $_['community']['USAGE_SURVEYS'] === 'yes' ? ' checked="checked"' : ''; ?>"/>
            <label for="adminNotifications">Enable notifications for surveys that help to improve NCP</label>
        </li>
        <li>
            <div>Accounts to notify:</div>
            <input type="text" name="notificationAccounts"
                   placeholder="comma separated list of accounts. Default is: all admins"
                   value="<?php echo $_['community']['NOTIFICATION_ACCOUNTS']; ?>"/>
        </li>
    </ul>
    <p class="error-message hidden"></p>
</div>
