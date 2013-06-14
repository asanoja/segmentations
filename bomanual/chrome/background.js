var metadata;

chrome.runtime.onMessage.addListener(
	function(request, sender, sendResponse) {
		var newdata;
		if (request.code=="sendMetadata") {
			metadata = request.data;
			newdata = "metadata "+metadata+" accepted";
		}
		sendResponse(newdata);
});

chrome.browserAction.onClicked.addListener(function() {
        alert("clicked");
        alert(chrome.extension.getViews().length);
});
