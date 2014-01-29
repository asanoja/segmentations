var bfversion = 1;

function getElementByXpath(path) {
    return document.evaluate(path, document, null, 9, null).singleNodeValue;
}

function bfprocess(pac) {
	var pagedef = [documentDim()];
	var gblocks = [];
	var fblocks = [];
	for (var i = 0;i<blocks.length;i++) {
		var xpdef = blocks[i];
		if (xpdef) {
			var bid = xpdef[0];
			for (var j=0;j<xpdef[1].length;j++) {
				var xpath = xpdef[1][j];
				var elem = getElementByXpath(xpath);
				if (elem) {
					if (relativeArea(elem) > pac) {
						var rect = getRect(elem);
						var count = countNodes(elem);
						gblocks.push([bid,xpath,elem,rect,count,relativeArea(elem)]);
						fblocks.push(new rectObj().init(window,document).build(rect.x,rect.y,rect.w,rect.h,"2px solid red","rgba(255, 0, 0, 0.5)",xpath+"<br>"+count+" nodes<br>ra:"+relativeArea(elem),undefined));
					} else {
						gblocks.push([bid,xpath,"DISCARDED",relativeArea(elem)]);
					}
				} else {
					gblocks.push([bid,xpath,null,null,null,relativeArea(elem)]);
				}
			}
		}
	}
	pagedef.push(gblocks);
	return(pagedef);
}

function getRect(obj) {
	if (!obj) return;
	if (obj.tagName.toUpperCase() == "BODY") {
		return {x:0, y:0, w:documentDim().w, h:documentDim().h}
	} else {
		return {x:$(obj).offset().left, y:$(obj).offset().top, w:$(obj).width(), h:$(obj).height()};
	}
	
}

function documentDim(win,doc) {
	var w,h;
	if (win) w=win; else win=window;
	if (doc) d=doc; else doc=document;
	return {w:$(doc).width(),h:$(doc).height()};
}

function countNodes(node) {
  var k = 0, c = node.childNodes.length, result = c;
  for (; k<c; k++) result += countNodes(node.childNodes[k]);
  if (result==0)
	result=1;
  return result;
} 

function hypo(elem) {
	return(Math.sqrt(Math.pow(getRect(elem).w,2)+Math.pow(getRect(elem).h,2)));
}

function perimeter(elem) {
	return( 2*(getRect(elem).w+getRect(elem).h));
}

function area(elem) {
	return(getRect(elem).w * getRect(elem).h);
}
	
function proportion(elem) {
	//return((area(elem) + perimeter(elem) + hypo(elem))/3);
	return(hypo(elem));
}
	
	
function relativeArea(e) {
	if (!e) return(0);
	if (e.parentNode) {
		return( proportion(e) / proportion(e.parentNode) );
	} else {
		return(1);
	}
}
	
