<?php
declare(strict_types=1);
namespace OCA\NextcloudPi\Controller;

use OCA\NextcloudPi\Exceptions\InvalidSettingsException;
use OCA\NextcloudPi\Exceptions\SaveSettingsException;
use OCA\NextcloudPi\Service\SettingsService;
use OCP\HintException;
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
	 * @CORS
	 *
	 * @param array $settings
	 */
	public function saveNcpSettings(array $settings): JSONResponse {
		try {
			$this->service->saveNcpSettings($settings);
			return new JSONResponse([]);
		} catch(InvalidSettingsException $e)  {
			return new JSONResponse(["error" => $e->getMessage()], Http::STATUS_BAD_REQUEST);
		} catch(SaveSettingsException $e) {
			return new JSONResponse(["error" => $e->getMessage()], Http::STATUS_INTERNAL_SERVER_ERROR);
		}
	}

	/**
	 * @CORS
	 *
	 * @param array $settings
	 */
	public function saveNcSettings(array $settings): JSONResponse {
		try {
			$this->service->saveNcSettings($settings);
			return new JSONResponse([]);
		} catch(InvalidSettingsException $e)  {
			return new JSONResponse(["error" => $e->getMessage()], Http::STATUS_BAD_REQUEST);
		} catch(SaveSettingsException|HintException $e) {
			return new JSONResponse(["error" => $e->getMessage()], Http::STATUS_INTERNAL_SERVER_ERROR);
		}
	}
}

?>
