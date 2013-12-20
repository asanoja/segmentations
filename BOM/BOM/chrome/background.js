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
		//~ if (BOMloaded) return;
		//~ BOMactive = !BOMactive;
        //~ var img;
        //~ if (BOMactive) {
			//~ img = "logo_small.png";
		//~ } else {
			img = "logo_small.png";
		//~ }
		chrome.browserAction.setIcon({path:"images/"+img}, callbackClick);
});


//~ function callbackClick() {
	//~ currentTab = chrome.tabs.getCurrent(tabSelected);
//~ }

function callbackClick() {
//~ if (BOMactive) {
chrome.tabs.executeScript({file: "js/rectlib.js"}, function() {
	chrome.tabs.executeScript({file: "js/bomlib.js"}, function() {
	   chrome.tabs.executeScript({file: "js/pmanual2.js"}, function() {
		   chrome.tabs.executeScript({code: "carga()"}, function() {
			  console.log("BOM extension active");
			  BOMloaded = true;
			});
		});
	});
});
//~ }
}
