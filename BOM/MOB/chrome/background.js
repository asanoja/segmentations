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

//~ chrome.extension.onMessage.addListener(
    //~ function(request, sender, sendResponse) {
		//~ 
        //~ switch (request.directive) {
        //~ case "popup-click":
            //~ // execute the content script
            //~ chrome.tabs.executeScript(null, { // defaults to the current tab
                //~ file: "pmanual2.js", // script to inject into page and run in sandbox
                //~ allFrames: true // This injects script into iframes in the page and doesn't work before 4.0.266.0.
            //~ });
            //~ sendResponse({}); // sending back empty response to sender
            //~ break;
        //~ default:
            //~ // helps debug when request directive doesn't match
            //~ alert("Unmatched request of '" + request + "' from script to background.js from " + sender);
        //~ }
    //~ }
//~ );

chrome.browserAction.onClicked.addListener(function() {
		//if (BOMloaded) return;
		//BOMactive = !BOMactive;
        //~ var img;
        //~ if (BOMactive) {
			img = "logo_small.png";
		//~ } else {
			//~ img = "logo_small.png";
		//~ }
		//~ 
		//~ chrome.devtools.panels.elements.createSidebarPane("Font Properties",
			//~ function(sidebar) {
			  //~ sidebar.setPage("bompanel.html");
			  //~ sidebar.setHeight("8ex");
			//~ });
		
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

//~ popup-click
