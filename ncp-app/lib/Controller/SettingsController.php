<?php
declare(strict_types=1);
namespace OCA\NextcloudPi\Controller;

use OCA\NextcloudPi\Exceptions\InvalidSettingsException;
use OCA\NextcloudPi\Exceptions\SaveSettingsException;
use OCA\NextcloudPi\Service\SettingsService;
use OCP\IRequest;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\JSONResponse;
use OCP\AppFramework\Controller;

class SettingsController extends Controller {

	/** @var SettingsService */
	private $service;


	/**
	 * SettingsController constructor
	 * @param SettingsService $service
	 */
	public function __construct(SettingsService $service) {
		$this->service = $service;
	}


	/**
	 * @NoCSRFRequired
	 * @CORS
	 *
	 * @param array $settings
	 */
	public function save(array $settings): JSONResponse {
		try {
			$this->service->saveSettings($settings);
			return new JSONResponse([]);
		} catch(InvalidSettingsException $e)  {
			return new JSONResponse(["error" => $e->getMessage()], Http::STATUS_BAD_REQUEST);
		} catch(SaveSettingsException $e) {
			return new JSONResponse(["error" => $e->getMessage()], Http::STATUS_INTERNAL_SERVER_ERROR);
		}
	}
}

?>
