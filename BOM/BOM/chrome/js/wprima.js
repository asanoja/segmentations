var wprima="";
var record="";
function parseAttr(attr) {
	if (typeof stringValue === 'string') 
		return(attr);
	else {
		var al="";
		for (var k=0;k<attr.length;k++) {
			al+=attr[k].name+"="+attr[k].value+" ";
		}
		return(al);
	}
}

function getCSSdec(block) {
	return("border: 2px dotted black; z-index: 10000; position: absolute; background-color: transparent; color: red; font-weight: bold; opacity: 0.5; left: "+block.dim.x+"px; top: "+block.dim.y+"px; width: "+block.dim.w+"px; height: "+block.dim.h+"px;");
}

function openTag(nom,attr) {
	
	return("\n<"+nom+" "+attr+">");
}
function closeTag(nom) {
	return("\n</"+nom+">");
}
function uTag(nom,attr) {
	return("<"+nom+" "+attr+"/>\n");
}

function getWPrima(block,first) {
	if (!block) return;
	console.log("Computing Wprima for", block);
	if ( (block.type =="PAGE") || (first && block.type != "PAGE")) {
		wprima += openTag("PAGE",'page="'+document.URL+'" width="'+documentDim().w+'" height="'+documentDim().h+'"');
		//record += "BOM,"+browserSniff()+",none,"+document.URL +","+documentDim().w+","+documentDim().h + "," + block.id + ",none,0,"+ block.dim.x + "," + block.dim.y + "," + block.dim.w + "," + block.dim.h +"\n";
		for (var j=0;j<block.geometricObjects.length;j++) {
			var geo = block.geometricObjects[j];
			//openTag(geo.tagName,"id='"+geo.getAttribute('id')+"' class='"+geo.className+"' x='" + getRect(geo).x + "' y='"+getRect(geo).y+"' width='"+getRect(geo).w+"' height='"+getRect(geo).h);
		}
		for (var i=0;i<block.children.length;i++) {
			var child = block.children[i];
			getWPrima(child);
		}
		wprima += closeTag("PAGE");
	} else {
		if (block.countChildren()==0) {
			wprima += openTag("BLOCK",'type="'+block.type+'" geometry="'+getPolygonPoints(block.dim)+'" style="'+getCSSdec(block)+'"');
			record += "BOM,"+browserSniff()+",none,"+document.URL +","+documentDim().w+","+documentDim().h + "," + block.id + ",none,0,"+ block.dim.x + "," + block.dim.y + "," + block.dim.w + "," + block.dim.h +"\n";
		
			for (var g=0;g<block.geometricObjects.length;g++) {
				var geo = block.geometricObjects[g];
				//wprima += openTag(geo.tagName,"id='"+geo.getAttribute('id')+"' class='"+geo.className+"' x='" + getRect(geo).x + "' y='"+getRect(geo).y+"' width='"+getRect(geo).w+"' height='"+getRect(geo).h);
				wprima += geo.outerHTML;
			}
			wprima += closeTag("BLOCK");
		}
		for (var i=0;i<block.children.length;i++) {
			var child = block.children[i];
			getWPrima(child);
		}
	}

}


function browserSniff() {
var nVer = navigator.appVersion;
var nAgt = navigator.userAgent;
var browserName  = navigator.appName;
var fullVersion  = ''+parseFloat(navigator.appVersion); 
var majorVersion = parseInt(navigator.appVersion,10);
var nameOffset,verOffset,ix;

// In Opera, the true version is after "Opera" or after "Version"
if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
 browserName = "Opera";
 fullVersion = nAgt.substring(verOffset+6);
 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
   fullVersion = nAgt.substring(verOffset+8);
}
// In MSIE, the true version is after "MSIE" in userAgent
else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
 browserName = "Microsoft Internet Explorer";
 fullVersion = nAgt.substring(verOffset+5);
}
// In Chrome, the true version is after "Chrome" 
else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
 browserName = "Chrome";
 fullVersion = nAgt.substring(verOffset+7);
}
// In Safari, the true version is after "Safari" or after "Version" 
else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
 browserName = "Safari";
 fullVersion = nAgt.substring(verOffset+7);
 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
   fullVersion = nAgt.substring(verOffset+8);
}
// In Firefox, the true version is after "Firefox" 
else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
 browserName = "Firefox";
 fullVersion = nAgt.substring(verOffset+8);
}
// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < 
          (verOffset=nAgt.lastIndexOf('/')) ) 
{
 browserName = nAgt.substring(nameOffset,verOffset);
 fullVersion = nAgt.substring(verOffset+1);
 if (browserName.toLowerCase()==browserName.toUpperCase()) {
  browserName = navigator.appName;
 }
}
// trim the fullVersion string at semicolon/space if present
if ((ix=fullVersion.indexOf(";"))!=-1)
   fullVersion=fullVersion.substring(0,ix);
if ((ix=fullVersion.indexOf(" "))!=-1)
   fullVersion=fullVersion.substring(0,ix);

majorVersion = parseInt(''+fullVersion,10);
if (isNaN(majorVersion)) {
 fullVersion  = ''+parseFloat(navigator.appVersion); 
 majorVersion = parseInt(navigator.appVersion,10);
}
return(browserName.toLowerCase());
//~ document.write(''
 //~ +'Browser name  = '+browserName+'<br>'
 //~ +'Full version  = '+fullVersion+'<br>'
 //~ +'Major version = '+majorVersion+'<br>'
 //~ +'navigator.appName = '+navigator.appName+'<br>'
 //~ +'navigator.userAgent = '+navigator.userAgent+'<br>'
//~ )
}
