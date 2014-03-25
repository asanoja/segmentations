var metadata;
var BOMactive=false;
var BOMloaded=false;
var currentTab ;

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
		img = "logo_small.png";
		chrome.browserAction.setIcon({path:"images/"+img}, callbackClick);
});


function callbackClick() {
chrome.tabs.executeScript({file: "js/rectlib.js"}, function() {
	chrome.tabs.executeScript({file: "js/bomlib.js"}, function() {
	   chrome.tabs.executeScript({file: "js/pmanual2.js"}, function() {
		   chrome.tabs.executeScript({code: "carga()"}, function() {
			  console.log("BOM DEMO extension active");
			  BOMloaded = true;
			});
		});
	});
});
}
