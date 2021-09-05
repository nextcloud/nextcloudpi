<?php
declare(strict_types=1);
/**
 * @copyright Copyright (c) 2017, Roeland Jago Douma <roeland@famdouma.nl>
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

namespace OCA\PreviewGenerator;

use OCP\IConfig;

class SizeHelper {

	public static function calculateSizes(IConfig $config): array {
		/*
		 * First calculate the systems max sizes
		 */

		$sizes = [
			'square' => [],
			'height' => [],
			'width' => [],
		];

		$maxW = (int)$config->getSystemValue('preview_max_x', 4096);
		$maxH = (int)$config->getSystemValue('preview_max_y', 4096);

		$s = 32;
		while($s <= $maxW || $s <= $maxH) {
			$sizes['square'][] = $s;
			$s *= 2;
		}

		$w = 32;
		while($w <= $maxW) {
			$sizes['width'][] = $w;
			$w *= 2;
		}

		$h = 32;
		while($h <= $maxH) {
			$sizes['height'][] = $h;
			$h *= 2;
		}


		/*
		 * Now calculate the user provided max sizes
		 * Note that only powers of 2 matter but if users supply different
		 * stuff it is their own fault and we just ignore it
		 */
		$getCustomSizes = function(IConfig $config, $key) {
			$TXT = $config->getAppValue('previewgenerator', $key, '');
			$values = [];
			if ($TXT !== '') {
				foreach (explode(' ', $TXT) as $value) {
					if (ctype_digit($value)) {
						$values[] = (int)$value;
					}
				}
			}

			return $values;
		};

		$squares = $getCustomSizes($config, 'squareSizes');
		$widths = $getCustomSizes($config, 'widthSizes');
		$heights = $getCustomSizes($config, 'heightSizes');

		if ($squares !== []) {
			$sizes['square'] = array_intersect($sizes['square'], $squares);
		}

		if ($widths !== []) {
			$sizes['width'] = array_intersect($sizes['width'], $widths);
		}

		if ($heights !== []) {
			$sizes['height'] = array_intersect($sizes['height'], $heights);
		}

		return $sizes;
	}
}
