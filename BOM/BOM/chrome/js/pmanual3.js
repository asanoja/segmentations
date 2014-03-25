//~ window.onload = function() {alert("cargo");carga()};

var metaData;


function dimension(block) {
	var rect = block.dim;
	return rect.x+","+rect.y+","+rect.w+","+rect.h;
}

function getURLParameter(name) {
  return document.URL;
}


function showLayout() {
	for (var i=0;i<blocks.length;i++) {
		if (blocks[i]) {
			var c = blocks[i].countChildren();
			//~ console.log(blocks[i],c);
			if (c==0) {
				blocks[i].setOn();
			} else {
				blocks[i].hide(); 
			}
			//~ console.log("out");
		}
	}
}

function hideLayout() {
	for (var i=0;i<blocks.length;i++) {
		if (blocks[i]) {
			blocks[i].setOff();
		}
	}
}



function carga(e) {
		
			
			if (navigator.appVersion.indexOf("Chrome")==-1){
				document.write('Sorry this ONLY works with Google Chrome or Chromium');
				return false;
			}
			var ac = 0.3;
			ac = parseFloat(prompt("Segment with which granularity: 0.0 - 1.0 \nGive a number\n small blocks 0.0 <--> 1.0 bigger blocks",ac));
			startSegmentation(window,ac,50,true);
			blocks = []
			updateBlockList(page);
					
			var dim = documentDim(window,document)
			//~ console.log(dim);
			metaData = "chrome " + dim.w +"x" + dim.h;
}

function getChildren(n, skipMe){
    var r = [];
    var elem = null;
    for ( ; n; n = n.nextSibling ) 
       if ( n.nodeType == 1 && n != skipMe)
          r.push( n );        
    return r;
}

function findInTree(elem,id) {
	if (!elem) return(false);
	if (elem.id == id) {
		return true;
	} else {
		if (elem.parentNode)
			return findInTree(elem.parentNode,id);
		else
			return false;
	}
}

function isContainerTag(tag) {
	
}

function getContainer(elem) {
	if (!elem) return;
    //~ console.log("GC: ("+elem.tagName+")");
	if (isContainerTag(elem.tagName)) {
		return elem;
	} else {
		if (elem.parentNode)
			return getContainer(elem.parentNode);
		else
			return undefined;
	} 
}

function updateBlockList(log) {
	// block array must be erase before by client method
	if (!log) return;
	for (var i=0;i<log.children.length;i++) {
		if (log.children[i] && log.children[i].block) {
			blocks.push(log.children[i]);
			updateBlockList(log.children[i]);
		}
	}
}

function searchLog(log,block) {
	
	var ret=undefined;
	
	if (log.block == block) return(log);
	
	for (var i=0;i<log.children.length;i++) {
		if (log.children[i] && log.children[i].block && block) {
			if (ret = searchLog(log.children[i],block)) break;
		}
	}
	return(ret);
}


