<?php

declare(strict_types=1);

namespace OCA\NextcloudPi\Service;

use OCA\NextcloudPi\Exceptions\InvalidSettingsException;
use OCA\NextcloudPi\Exceptions\SaveSettingsException;
use Psr\Log\LoggerInterface;

class SettingsService {
	private LoggerInterface $logger;

	public function __construct(LoggerInterface $logger) {
		$this->logger = $logger;
	}

	/**
	 * @param $name string of the config
	 * @param array $defaults Default value to use if the config can't be loaded
	 * @return array
	 */
	public function getConfig(string $name, array $defaults): array
	{
		[$ret, $config_str, $stderr] = $this->runCommand( "bash -c \"sudo /home/www/ncp-app-bridge.sh config $name\"");
		$config = null;
		if ($ret == 0) {
			try {
				$config = json_decode($config_str, true, 512, JSON_THROW_ON_ERROR);
			} catch (\Exception $e) {
				$this->logger->error($e);
			}
		}
		if ($config == null) {
			$this->logger->error("Failed to retrieve ncp config (exit code: $ret)");
			return $defaults;
		}
		return $config;
	}
	/**
	 * @param $name string of the config
	 * @param string $defaults Default value to use if the file can't be loaded
	 * @return string
	 */
	public function getFileContent(string $name, string $defaults): string
	{
		[$ret, $file_contents, $stderr] = $this->runCommand( "bash -c \"sudo /home/www/ncp-app-bridge.sh file $name\"");
		if ($ret != 0) {
			return $defaults;
		}
		return $file_contents;
	}

	/**
	 * @throws InvalidSettingsException
	 * @throws SaveSettingsException
	 */
	public function saveSettings(array $settings) {
		$parseBool = function ($val): string {
			return $val ? "yes" : "no";
		};
		$identityFn = function ($val) {
			return $val;
		};

		$settings_map = [
			"canary" => ["ncp-community", "CANARY", $parseBool],
			"adminNotifications" => ["ncp-community", "ADMIN_NOTIFICATIONS", $parseBool],
			"usageSurveys" => ["ncp-community", "USAGE_SURVEYS", $parseBool],
			"notificationAccounts" => ["ncp-community", "NOTIFICATION_ACCOUNTS", $identityFn]
		];

		foreach ($settings as $k => $value) {
			[$cfgName, $fieldName, $fn] = $settings_map[$k];
			if ($cfgName == null || $fieldName == null) {
				throw new InvalidSettingsException("key error for '$k'");
			}
			$parsed = $fn($value);
			$cmd = "bash -c \"sudo /home/www/ncp-app-bridge.sh config '$cfgName' '$fieldName=$parsed'\"";
			[$ret, $stdout, $stderr] = $this->runCommand($cmd);
			if ($ret !== 0) {
				throw new SaveSettingsException(
					"Failed to save NCP settings '$cfgName/$fieldName': \n error output from command:\n\n$cmd"
					. str_replace("\n", "\n>  ", $stderr));
			}
		}
	}

	private function runCommand(string $cmd): array {
		$descriptorSpec = [
			0 => ["pipe", "r"],
			1 => ["pipe", "w"],
			2 => ["pipe", "w"]
		];

		$proc = proc_open($cmd, $descriptorSpec, $pipes, "/home/www-data", null);
		$stdout = stream_get_contents($pipes[1]);
		fclose($pipes[1]);
		$stderr = stream_get_contents($pipes[2]);
		fclose($pipes[2]);
		return [proc_close($proc), $stdout, $stderr];
	}
}

?>
