function clickHandler(e) {
    chrome.extension.sendMessage({directive: "popup-click"}, function(response) {
        this.close(); // close the popup when the background finishes processing request
    });
}

//~ function proceed() {
	//~ var tabId;
	//~ 
	//~ chrome.tabs.getSelected(null, function(tab) {
        //~ tabId = tab.id;
    //~ });
	//~ 
	//~ chrome.tabs.sendRequest(tabId, {greeting: "reintrodu"}, function(response)
    //~ {
        //~ alert(response.farewell);
//~ 
        //~ //closing only after receiving response
        //~ window.close();
    //~ }); 
	//~ 
//~ }
//~ 
