<?php
/**
 * Create your routes in here. The name is the lowercase name of the controller
 * without the controller part, the stuff after the hash is the method.
 * e.g. page#index -> OCA\NextcloudPi\Controller\PageController->index()
 *
 * The controller class has to be registered in the application.php file since
 * it's instantiated in there
 */
return [
	'routes' => [
		['name' => 'page#index', 'url' => '/', 'verb' => 'GET'],
		['name' => 'settings#saveNcpSettings', 'url' => '/api/settings/ncp', 'verb' => 'POST'],
		['name' => 'settings#saveNcSettings', 'url' => '/api/settings/nextcloud', 'verb' => 'POST']
	]
];
