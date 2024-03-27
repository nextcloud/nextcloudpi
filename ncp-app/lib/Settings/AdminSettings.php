<?php
declare(strict_types=1);
namespace OCA\NextcloudPi\Settings;

use OCA\NextcloudPi\Service\SettingsService;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\Settings\ISettings;

class AdminSettings implements ISettings {

	private SettingsService $service;


	/**
	 * AdminSettings constructor
	 * @param SettingsService $service
	 */
	public function __construct(SettingsService $service) {
		$this->service = $service;
	}

	/**
	 * @return TemplateResponse
	 */
	public function getForm(): TemplateResponse
	{
		$ncp_config = $this->service->getConfig("ncp",
			["nextcloud_version" => "unknown", "php_version" => "unknown", "release" =>  "unknown"]);
		$community_config = $this->service->getConfig("ncp-community",
			[
				"CANARY" => 'no',
				"USAGE_SURVEYS" => 'no',
				"ADMIN_NOTIFICATIONS" => 'no',
				"NOTIFICATION_ACCOUNTS" => ''
			]);
		$ncp_version = trim($this->service->getFileContent("ncp-version", "unknown"));

		$default_phone_region = $this->service->getSystemConfigValueString("default_phone_region");
		$maintenance_window_start = $this->service->getSystemConfigValueString("maintenance_window_start");

		return new TemplateResponse('nextcloudpi', 'admin', [
			'community' => $community_config,
			'ncp' => $ncp_config,
			'ncp_version' => $ncp_version,
			'default_phone_region' => $default_phone_region,
			'maintenance_window_start' => $maintenance_window_start
		]);
	}

	/**
	 * @return string
	 */
	public function getSection() {
		return "server";
	}

	/**
	 * @return int
	 */
	public function getPriority() {
		return 1;
	}
}
?>
