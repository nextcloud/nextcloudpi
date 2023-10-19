/**
 * SPDX-FileCopyrightText: 2018 John Molakvoæ <skjnldsv@protonmail.com>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import {generateFilePath, generateUrl} from '@nextcloud/router'
import axios from '@nextcloud/axios'
//
// import Vue from 'vue'
// import App from './App.vue'

// eslint-disable-next-line
__webpack_public_path__ = generateFilePath(appName, '', 'js/')
//
// Vue.mixin({ methods: { t, n } })
//
// export default new Vue({
// 	el: '#nextcloudpi',
// 	render: h => h(App),
// })


async function saveSettings() {
	let settings = collectSettings();
	console.log("Saving nextcloudpi settings: ", settings);
	try {
		let response = await axios.post(generateUrl('/apps/nextcloudpi/api/settings'), {settings: settings})
		console.log("Saving ncp settings succeeded")
		return {success: true, error: null}
	} catch (e) {
		// console.log("axios failure: ", arguments)
		console.error(e)
		let errMsg = e.response.data.error;
		throw Error(`${errMsg ? errMsg : e.message} (HTTP ${e.response.status})`)
	}
}

function collectSettings() {
	let settings = {};
	document.querySelectorAll("#nextcloudpi input").forEach(element => {
		if (element.type === "checkbox") {
			settings[element.name] = element.checked;
		} else {
			settings[element.name] = element.value;
		}
	});
	return settings;
}

window.addEventListener('load', () => {
	console.log("Listening to ncp settings changes");
	let errorBox = document.querySelector("#nextcloudpi .error-message");
	document.querySelectorAll("#nextcloudpi input").forEach(element => {
		element.addEventListener("change", async () => {
			saveSettings()
				.then(() => {
					errorBox.classList.add("hidden");
				})
				.catch(e => {
					console.error(e);
					errorBox.innerText = "Failed to save NextcloudPi settings: " + e.message;
					errorBox.classList.remove("hidden");
				})
		})
	})
})
