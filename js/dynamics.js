function featuresMenu() {
	const featuresDropdown = document.getElementById('features-dropdown');
	featuresDropdown.classList.toggle('is-active');
	const featuresIcon = document.getElementById('features-icon');
	if(featuresIcon.dataset.image == "arrow-down") {
		featuresIcon.src = "images/arrow-up-icon.png";
		featuresIcon.dataset.image = "arrow-up";
		return
	};
	if(featuresIcon.dataset.image == "arrow-up") {
		featuresIcon.src = "images/arrow-down-icon.png";
		featuresIcon.dataset.image = "arrow-down";
		return
	};
};

function extrasMenu() {
	const extrasDropdown = document.getElementById('extras-dropdown');
	extrasDropdown.classList.toggle('is-active');
	const extrasIcon = document.getElementById('extras-icon');
	if(extrasIcon.dataset.image == "arrow-down") {
		extrasIcon.src = "images/arrow-up-icon.png";
		extrasIcon.dataset.image = "arrow-up";
		return
	};
	if(extrasIcon.dataset.image == "arrow-up") {
		extrasIcon.src = "images/arrow-down-icon.png";
		extrasIcon.dataset.image = "arrow-down";
		return
	};
}

function nextImg() {

}
