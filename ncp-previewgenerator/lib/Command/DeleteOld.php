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
namespace OCA\PreviewGenerator\Command;

use OCP\Files\Folder;
use OCP\Files\IRootFolder;
use OCP\Files\NotFoundException;
use OCP\IUser;
use OCP\IUserManager;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class DeleteOld extends Command {

	/** @var IUserManager */
	protected $userManager;

	/** @var IRootFolder */
	protected $rootFolder;

	public function __construct(IRootFolder $rootFolder,
								IUserManager $userManager) {
		parent::__construct();

		$this->userManager = $userManager;
		$this->rootFolder = $rootFolder;
	}

	protected function configure() {
		$this
			->setName('preview:delete_old')
			->setDescription('Delete old preview folder (pre NC11)')
			->addArgument(
				'user_id',
				InputArgument::OPTIONAL,
				'Delete old preview folder for the given user'
			);
	}

	protected function execute(InputInterface $input, OutputInterface $output): int {
		$userId = $input->getArgument('user_id');

		if ($userId === null) {
			$this->userManager->callForSeenUsers(function (IUser $user) {
				$this->deletePreviews($user);
			});
		} else {
			$user = $this->userManager->get($userId);
			if ($user !== null) {
				$this->deletePreviews($user);
			}
		}

		return 0;
	}

	private function deletePreviews(IUser $user) {
		\OC_Util::tearDownFS();
		\OC_Util::setupFS($user->getUID());

		$userFolder = $this->rootFolder->getUserFolder($user->getUID());
		$userRoot = $userFolder->getParent();

		try {
			/** @var Folder $thumbnails */
			$thumbnails = $userRoot->get('thumbnails');
			$thumbnails->delete();
		} catch (NotFoundException $e) {
			//Ignore
		}
	}


}
