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

use OCA\PreviewGenerator\SizeHelper;
use OCP\Encryption\IManager;
use OCP\Files\File;
use OCP\Files\Folder;
use OCP\Files\IRootFolder;
use OCP\Files\NotFoundException;
use OCP\IConfig;
use OCP\IDBConnection;
use OCP\IPreview;
use OCP\IUser;
use OCP\IUserManager;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class Generate extends Command {

	/** @var IUserManager */
	protected $userManager;

	/** @var IRootFolder */
	protected $rootFolder;

	/** @var IPreview */
	protected $previewGenerator;

	/** @var IConfig */
	protected $config;

	/** @var IDBConnection */
	protected $connection;

	/** @var OutputInterface */
	protected $output;

	/** @var int[][] */
	protected $sizes;

	/** @var IManager */
	protected $encryptionManager;

	public function __construct(IRootFolder $rootFolder,
								IUserManager $userManager,
								IPreview $previewGenerator,
								IConfig $config,
								IDBConnection $connection,
								IManager $encryptionManager) {
		parent::__construct();

		$this->userManager = $userManager;
		$this->rootFolder = $rootFolder;
		$this->previewGenerator = $previewGenerator;
		$this->config = $config;
		$this->connection = $connection;
		$this->encryptionManager = $encryptionManager;
	}

	protected function configure() {
		$this
			->setName('preview:generate-all')
			->setDescription('Generate previews')
			->addArgument(
				'user_id',
				InputArgument::OPTIONAL,
				'Generate previews for the given user'
			)->addOption(
				'path',
				'p',
				InputOption::VALUE_OPTIONAL,
				'limit scan to this path, eg. --path="/alice/files/Photos", the user_id is determined by the path and the user_id parameter is ignored'
			);
	}

	protected function execute(InputInterface $input, OutputInterface $output): int {
		if ($this->encryptionManager->isEnabled()) {
			$output->writeln('Encryption is enabled. Aborted.');
			return 1;
		}

		// Set timestamp output
		$formatter = new TimestampFormatter($this->config, $output->getFormatter());
		$output->setFormatter($formatter);
		$this->output = $output;

		$this->sizes = SizeHelper::calculateSizes($this->config);

		$inputPath = $input->getOption('path');
		if ($inputPath) {
			$inputPath = '/' . trim($inputPath, '/');
			list (, $userId,) = explode('/', $inputPath, 3);
			$user = $this->userManager->get($userId);
			if ($user !== null) {
				$this->generatePathPreviews($user, $inputPath);
			}
		} else {
			$userId = $input->getArgument('user_id');
			if ($userId === null) {
				$this->userManager->callForSeenUsers(function (IUser $user) {
					$this->generateUserPreviews($user);
				});
			} else {
				$user = $this->userManager->get($userId);
				if ($user !== null) {
					$this->generateUserPreviews($user);
				}
			}
		}

		return 0;
	}

	private function generatePathPreviews(IUser $user, string $path) {
		\OC_Util::tearDownFS();
		\OC_Util::setupFS($user->getUID());
		$userFolder = $this->rootFolder->getUserFolder($user->getUID());
		try {
			$relativePath = $userFolder->getRelativePath($path);
		} catch (NotFoundException $e) {
			$this->output->writeln('Path not found');
			return;
		}
		$pathFolder = $userFolder->get($relativePath);
		$this->processFolder($pathFolder, $user);
	}

	private function generateUserPreviews(IUser $user) {
		\OC_Util::tearDownFS();
		\OC_Util::setupFS($user->getUID());

		$userFolder = $this->rootFolder->getUserFolder($user->getUID());
		$this->processFolder($userFolder, $user);
	}

	private function processFolder(Folder $folder, IUser $user) {
		// Respect the '.nomedia' file. If present don't traverse the folder
		if ($folder->nodeExists('.nomedia')) {
			$this->output->writeln('Skipping folder ' . $folder->getPath());
			return;
		}

		// random sleep between 0 and 50ms to avoid collision between 2 processes
		usleep(rand(0,50000));

		$this->output->writeln('Scanning folder ' . $folder->getPath());

		$nodes = $folder->getDirectoryListing();

		foreach ($nodes as $node) {
			if ($node instanceof Folder) {
				$this->processFolder($node, $user);
			} else if ($node instanceof File) {
				$is_locked = false;
				$qb = $this->connection->getQueryBuilder();
				$row = $qb->select('*')
                                  ->from('preview_generation')
                                  ->where($qb->expr()->eq('file_id', $qb->createNamedParameter($node->getId())))
                                  ->setMaxResults(1)
                                  ->execute()
                                  ->fetch();
				if ($row !== false) {
					if ($row['locked'] == 1) {
						// already being processed
						$is_locked = true;
					} else {
						$qb->update('preview_generation')
						   ->where($qb->expr()->eq('file_id', $qb->createNamedParameter($node->getId())))
						   ->set('locked', $qb->createNamedParameter(true))
						   ->execute();
					}
				} else {
					$qb->insert('preview_generation')
				           ->values([
					       'uid'     => $qb->createNamedParameter($user->getUID()),
					       'file_id' => $qb->createNamedParameter($node->getId()),
					       'locked'  => $qb->createNamedParameter(true),
				           ])
					   ->execute();
				}

				if ($is_locked === false) {
					try {
						$this->processFile($node);
					} finally {
						$qb->delete('preview_generation')
	 					    ->where($qb->expr()->eq('file_id', $qb->createNamedParameter($node->getId())))
						    ->execute();
					}
				}
			}
		}
	}

	private function processFile(File $file) {
		if ($this->previewGenerator->isMimeSupported($file->getMimeType())) {
			if ($this->output->getVerbosity() > OutputInterface::VERBOSITY_VERBOSE) {
				$this->output->writeln('Generating previews for ' . $file->getPath());
			}

			try {
				foreach ($this->sizes['square'] as $size) {
					$this->previewGenerator->getPreview($file, $size, $size, true);
				}

				// Height previews
				foreach ($this->sizes['height'] as $height) {
					$this->previewGenerator->getPreview($file, -1, $height, false);
				}

				// Width previews
				foreach ($this->sizes['width'] as $width) {
					$this->previewGenerator->getPreview($file, $width, -1, false);
				}
			} catch (NotFoundException $e) {
				// Maybe log that previews could not be generated?
			} catch (\InvalidArgumentException $e) {
				$error = $e->getMessage();
				$this->output->writeln("<error>${error}</error>");
			}
		}
	}

}
