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
namespace OCA\PreviewGenerator\Command;

use OCA\PreviewGenerator\SizeHelper;
use OCP\AppFramework\Utility\ITimeFactory;
use OCP\Encryption\IManager;
use OCP\Files\File;
use OCP\Files\IRootFolder;
use OCP\Files\NotFoundException;
use OCP\IConfig;
use OCP\IDBConnection;
use OCP\IPreview;
use OCP\IUserManager;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class PreGenerate extends Command {

	/** @var string */
	protected $appName;

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

	/** @var ITimeFactory */
	protected $time;

	/**
	 * @param string $appName
	 * @param IRootFolder $rootFolder
	 * @param IUserManager $userManager
	 * @param IPreview $previewGenerator
	 * @param IConfig $config
	 * @param IDBConnection $connection
	 * @param IManager $encryptionManager
	 * @param ITimeFactory $time
	 */
	public function __construct($appName,
						 IRootFolder $rootFolder,
						 IUserManager $userManager,
						 IPreview $previewGenerator,
						 IConfig $config,
						 IDBConnection $connection,
						 IManager $encryptionManager,
						 ITimeFactory $time) {
		parent::__construct();

		$this->appName = $appName;
		$this->userManager = $userManager;
		$this->rootFolder = $rootFolder;
		$this->previewGenerator = $previewGenerator;
		$this->config = $config;
		$this->connection = $connection;
		$this->encryptionManager = $encryptionManager;
		$this->time = $time;
	}

	protected function configure() {
		$this
			->setName('preview:pre-generate')
			->setDescription('Pre generate previews');
	}

	/**
	 * @param InputInterface $input
	 * @param OutputInterface $output
	 * @return int
	 */
	protected function execute(InputInterface $input, OutputInterface $output) {
		if ($this->encryptionManager->isEnabled()) {
			$output->writeln('Encryption is enabled. Aborted.');
			return 1;
		}

		// Set timestamp output
		$formatter = new TimestampFormatter($this->config, $output->getFormatter());
		$output->setFormatter($formatter);
		$this->output = $output;

		$this->sizes = SizeHelper::calculateSizes($this->config);
		$this->startProcessing();

		return 0;
	}

	private function startProcessing() {
		// random sleep between 0 and 50ms to avoid collision between 2 processes
		usleep(rand(0,50000));

		while(true) {
			$qb = $this->connection->getQueryBuilder();
			$row = $qb->select('*')
				->from('preview_generation')
				->where($qb->expr()->eq('locked', $qb->createNamedParameter(false)))
				->setMaxResults(1)
				->execute()
				->fetch();

			if ($row === false) {
				break;
			}

			$qb->update('preview_generation')
			   ->where($qb->expr()->eq('id', $qb->createNamedParameter($row['id'])))
			   ->set('locked', $qb->createNamedParameter(true))
			   ->execute();
                        try {
				$this->processRow($row);
			} finally {
				$qb->delete('preview_generation')
			            ->where($qb->expr()->eq('id', $qb->createNamedParameter($row['id'])))
				    ->execute();
			}
		}
	}

	private function processRow($row) {
		//Get user
		$user = $this->userManager->get($row['uid']);

		if ($user === null) {
			return;
		}

		try {
			$userFolder = $this->rootFolder->getUserFolder($user->getUID());
			$userRoot = $userFolder->getParent();
		} catch (NotFoundException $e) {
			return;
		}

		//Get node
		$nodes = $userRoot->getById($row['file_id']);

		if ($nodes === []) {
			return;
		}

		$node = $nodes[0];
		if ($node instanceof File) {
			$this->processFile($node);
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
                            if ($this->output->getVerbosity() > OutputInterface::VERBOSITY_VERBOSE) {
				$error = $e->getMessage();
				$this->output->writeln("<error>${error} " . $file->getPath() . " not found.</error>");
                            }
			} catch (\InvalidArgumentException $e) {
				$error = $e->getMessage();
				$this->output->writeln("<error>${error}</error>");
			}
		}
	}

}
