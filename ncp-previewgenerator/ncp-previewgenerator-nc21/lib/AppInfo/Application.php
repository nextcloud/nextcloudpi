<?php

declare(strict_types=1);
/**
 * @copyright Copyright (c) 2016, Roeland Jago Douma <roeland@famdouma.nl>
 *
 * @author Roeland Jago Douma <roeland@famdouma.nl>
 *
 * @license GNU AGPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
namespace OCA\PreviewGenerator\AppInfo;

use OCA\PreviewGenerator\Listeners\PostWriteListener;
use OCP\AppFramework\App;
use OCP\AppFramework\Bootstrap\IBootContext;
use OCP\AppFramework\Bootstrap\IBootstrap;
use OCP\AppFramework\Bootstrap\IRegistrationContext;
use OCP\Files\Events\Node\NodeWrittenEvent;

class Application extends App implements IBootstrap {
	public const APPNAME='previewgenerator';

	public function __construct() {
		parent::__construct(self::APPNAME);
	}

	public function register(IRegistrationContext $context): void {
		$context->registerEventListener(NodeWrittenEvent::class, PostWriteListener::class);
	}

	public function boot(IBootContext $context): void {
	}
}
