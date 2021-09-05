<?php
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
namespace OCA\PreviewGenerator\Tests;

use OCA\PreviewGenerator\Watcher;
use OCP\Files\Node;
use OCP\IDBConnection;
use OCP\IUserManager;
use Test\TestCase;

/**
 * Class WatcherTest
 *
 * @package OCA\PreviewGenerator\Tests
 * @group DB
 */
class WatcherTest extends TestCase {

	/** @var IDBConnection */
	private $connection;

	/** @var IUserManager|\PHPUnit_Framework_MockObject_MockObject */
	private $userManager;

	/** @var Watcher */
	private $watcher;

	public function setUp() {
		parent::setUp();

		$this->connection = \OC::$server->getDatabaseConnection();
		$this->userManager = $this->createMock(IUserManager::class);
		$this->watcher = new Watcher($this->connection, $this->userManager);

		$qb = $this->connection->getQueryBuilder();
		$qb->delete('preview_generation');
	}

	public function testPostWriteCantFindUser() {
		$node = $this->createMock(Node::class);
		$node->method('getPath')
			->willReturn('/foo/bar/baz');

		$this->userManager->expects($this->once())
			->method('userExists')
			->with('foo')
			->willReturn(false);

		$this->watcher->postWrite($node);
	}

	public function testPostWrite() {
		$node = $this->createMock(Node::class);
		$node->method('getPath')
			->willReturn('/foo/bar/baz');
		$node->method('getId')
			->willReturn(42);

		$this->userManager->expects($this->once())
			->method('userExists')
			->with('foo')
			->willReturn(true);

		$this->watcher->postWrite($node);

		$qb = $this->connection->getQueryBuilder();
		$qb->select('*')
			->from('preview_generation');
		$cursor = $qb->execute();
		$rows = $cursor->fetchAll();
		$cursor->closeCursor();

		$this->assertCount(1, $rows);
		$row = $rows[0];
		$this->assertSame('foo', $row['uid']);
		$this->assertSame('42', $row['file_id']);
	}
}
