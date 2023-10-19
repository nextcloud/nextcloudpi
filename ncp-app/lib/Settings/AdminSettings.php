<?php
declare(strict_types=1);
namespace OCA\NextcloudPi\Settings;

use OCA\NextcloudPi\Service\SettingsService;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\Settings\ISettings;

class AdminSettings implements ISettings {

	/** @var SettingsService */
	private $service;


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
	public function getForm() {
		$ncp_config = $this->service->getConfig("ncp",
			["nextcloud_version" => "unknown", "php_version" => "unknown", "release" =>  "unknown"]);
		$community_config = $this->service->getConfig("ncp-community",
			[
				"CANARY" => 'no',
				"USAGE_SURVEYS" => 'no',
				"ADMIN_NOTIFICATIONS" => 'no',
				"NOtIFICATION_ACCOUNTS" => ""
			]);
		$ncp_version = trim($this->service->getFileContent("ncp-version", "unknown"));

		return new TemplateResponse('nextcloudpi', 'admin', [
			'community' => $community_config,
			'ncp' => $ncp_config,
			'ncp_version' => $ncp_version
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
