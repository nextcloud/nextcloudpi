// SPDX-FileCopyrightText: Tobias Knöppler <tobias@knoeppler.net>
// SPDX-License-Identifier: AGPL-3.0-or-later
const path = require('path')
const webpackConfig = require('@nextcloud/webpack-vue-config')

module.exports = {...webpackConfig,
	...{
		entry: {
			admin: path.join(__dirname, 'src/main-admin')
		}
	}
}
