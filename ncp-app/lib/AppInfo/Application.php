<?php
declare(strict_types=1);
// SPDX-FileCopyrightText: Tobias Knöppler <tobias@knoeppler.net>
// SPDX-License-Identifier: AGPL-3.0-or-later

namespace OCA\NextcloudPi\AppInfo;

use OCP\AppFramework\App;

class Application extends App {
	public const APP_ID = 'nextcloudpi';

	public function __construct() {
		parent::__construct(self::APP_ID);
	}
}
