window.onmouseover = pon;
window.onmouseout = quita;
window.onmousedown = dale;
window.onload = carga;
window.onkeydown = fufu;
window.onbeforeunload = bye;

var lastElement = undefined;
var lastContainer = undefined;
var lastEvent = undefined;
var editing = false;
var blocks = new Array();
var marco = undefined;
var dialog = undefined;
var cargado = false;
var metaData = "";

function bye() {
    self.port.emit("unload");
}

function fufu(e) {
	if (!e) e=event;
	console.log(e.keyCode);
	if (e.keyCode == 113) {
		console.log("F2");
		if (editing) addNewBlock(lastElement);
		return false;
	}
	if (e.keyCode == 114) {
		console.log("F3");
        if (editing) {
        b = getChildren(lastElement.parentNode.firstChild);
        for (var i=0;i<b.length;i++) {
            addNewBlock(b[i]);
        }
        }
		return false;
	}
	if (e.keyCode == 115) {
		console.log("F4");
        if (editing) addNewBlock(lastContainer);
		return false;
	}
	if (e.keyCode == 116) {
		console.log("F5");
		update_marco_submit();
		return false;
	}
	if (e.keyCode == 117) {
		console.log("F6");
		toggle_marco();
		return false;
	}
    if (e.keyCode == 119) {
    	console.log("F8");
		goparent();
		return false;
	}
	if (e.keyCode == 13) {
		console.log("ENTER");
		dale(lastEvent);
		return false;
	}
	if (e.keyCode == 27 || e.keyCode == 118)
		console.log("ESCAPE OR F7");
		discardBlock();
		update_marco();
		return false;
	
//	lastElement.value += e.keyCode;
	
	return true;
}

function toggle_marco() {
	if (marco.style.display=="block")
		marco.style.display = "none";
	else
		marco.style.display = "block";
}

function dimension(block) {
	s=block.offsetLeft+","+block.offsetTop+","+block.offsetWidth+","+block.offsetHeight;
	return s;
}

function getDocHeight() {
var d = document;
return Math.max(
Math.max(d.body.scrollHeight, d.documentElement.scrollHeight),
Math.max(d.body.offsetHeight, d.documentElement.offsetHeight),
Math.max(d.body.clientHeight, d.documentElement.clientHeight)
);
}

function getDocWidth() {
var d = document;
return Math.max(
Math.max(d.body.scrollWidth, d.documentElement.scrollWidth),
Math.max(d.body.offsetWidth, d.documentElement.offsetWidth),
Math.max(d.body.clientWidth, d.documentElement.clientWidth)
);
}

function update_marco() {
    marco.innerHTML="<h2>Block-o-Matic</h2><br/>";
	marco.innerHTML+="Selected Blocks<br>";
	marco.innerHTML+="<hr>";
	marco.innerHTML+="<form>";
	marco.innerHTML+="<ol>";
	for (var i=0;i<blocks.length;i++) {
			if (blocks[i])
				marco.innerHTML+=" <li id='"+i+"'>"+i+". <input id='"+i+"' type='text' value='"+getXPath(blocks[i])+"'> <a href='#' id='"+i+"'>delete</a></li>";
	}
	marco.innerHTML+="</ol>";
	marco.innerHTML+="<input id='send' type='button' value='Send'>";
	marco.innerHTML+="</form><br>";
	marco.innerHTML+="<span href id='plyes'>[F2 add element]</span>&nbsp;";
	marco.innerHTML+="<span href id='plno'>[F3 add siblings]</span>&nbsp;";
	marco.innerHTML+="<span href id='plno'>[F4 accept container]</span>&nbsp;";
	marco.innerHTML+="<span href id='plparent'>[F5 send]</span>&nbsp;";
	marco.innerHTML+="<span href id='plparent'>[F6 hide/show panel]</span>&nbsp;";
	marco.innerHTML+="<span href id='plparent'>[F7/ESC cancel]</span>&nbsp;";
	marco.innerHTML+="<span href id='plparent'>[F8 go parent]</span>&nbsp;";
}

function getURLParameter(name) {
  return document.URL;
}

function update_marco_submit() {
    s="<h2>Block-o-Matic</h2><br>";
    s+="Send Blocks<br>";
	s+="<hr>";
	s+="<form action='http://www-poleia.lip6.fr/~sanojaa/SCAPE/submit.php' id='pmanual_form' method='POST'>";
    //s+="<form action='http://localhost/submit.php' id='pmanual_form' method='POST'>";
	
	k=0;
	for (var i=0;i<blocks.length;i++) {
			if (blocks[i]) {
				k++;
			}
	}
	
	s+="Selected "+k+" blocks<br>"
	s+="<input type='hidden' value='"+k+"' name='total'>";
	pn=getURLParameter('fn');
	s+="<input id='pmanual_webpage' type='text' value='"+pn+"' name='page'><br>";
	s+="<input id='pmanual_meta' type='text' value='"+metaData+"' name='meta'><br>";
	
	s+="Your name:<input id='pmanual_username' type='text' value='andres' name='name'><br>";
	s+="Category:<select id='pmanual_category' name='category'>";
    s+="<option value='unfiled_tagged'>Unfiled Tagged</option>";
    s+="<option value='music_movies'>Music_Movies</option>";
    s+="<option value='home_living'>Home Living</option>";
    s+="<option value='outdoors'>Outdoors</option>";
    s+="<option value='sci_tech'>Sci Tech</option>";
    s+="<option value='regional'>Regional</option>";
    s+="<option value='society'>Society</option>";
    s+="<option value='computers'>Computers</option>";
    s+="<option value='media'>Media</option>";
    s+="<option value='hobbies'>Hobbies</option>";
    s+="<option value='commerce'>Commerce</option>";
    s+="<option value='religion'>Religion</option>";
    s+="<option value='sports'>Sports</option>";
    s+="<option value='health'>Health</option>";
    s+="<option value='arts_history'>Arts History</option>";
	s+="</select><br>";

	for (var i=0;i<blocks.length;i++) {
			if (blocks[i]) {
				s+="<input type='hidden' value='"+getXPath(blocks[i])+","+dimension(blocks[i])+","+blocks[i].id+","+blocks[i].id+"' name='block"+(i+1)+"'>";
			}
	}
	
	s+="<input id='finalsend' type='submit' value='Confirm send'>";
	s+="</form>";	
	marco.innerHTML = s;
	marco.style.display="block";
}

function DisableFrameLinks(iFrame){
   var links;
   //console.log(iFrame.contentWindow);
  if ( iFrame.contentWindow && iFrame.contentWindow.document)
   {
     links = iFrame.contentWindow.document.links;
     for(var i in links)
     {
        links[i].href="#";
     }
   }
 }

function carga(e) {
		if (!cargado) {
			if (navigator.appVersion.indexOf("Chrome")==-1){
				//document.write('Sorry this ONLY works with Google Chrome or Chromium');
				//return false;
			}
			//metaData = navigator.appName.toLowerCase() +" "+ getDocWidth() +"x" + getDocHeight();
			metaData = "chrome " + getDocWidth() +"x" + getDocHeight();

			//~ chrome.runtime.sendMessage({code:"sendMetadata", data: metaData}, function(response) {
				//~ console.log(response);
			//~ });
			
			var anchors = document.getElementsByTagName('a');
			for (var i=0;i<anchors.length;i++) {
				anchors[i].onclick = function() {return(false);};
			}
			
			var iframes = document.getElementsByTagName('iframe');
			for (var i=0;i<iframes.length;i++) {
				DisableFrameLinks(iframes[i]);
			}
			
			
			if (!document.getElementById('marco-plmanual'))
				marco = document.createElement('div');
			else
				marco = document.getElementById('marco-plmanual');
			
			marco.id = "marco-plmanual";
			marco.style.position="fixed";
			marco.style.top = "0px";
			marco.style.width = "600px";
			marco.style.left = "0px";
			marco.style.height = "300px"
			marco.style.border = '4px solid black'
			marco.style.background = '#F0F0F0'
			marco.style.overflow = "scroll";
			marco.style.opacity = "1"
			marco.style.zIndex = "100000";
			marco.style.display = "block"
			
			update_marco();
			
			if (!document.getElementById('marco-plmanual')) {
				document.body.appendChild(marco);
				console.log("marco creado");
			}
			editing = false;
			cargado = true;
		}
}

function getChildren(n, skipMe){
    var r = [];
    var elem = null;
    for ( ; n; n = n.nextSibling ) 
       if ( n.nodeType == 1 && n != skipMe)
          r.push( n );        
    return r;
}

function pon(e) {
	if (!e) e=event;
    if (!marco) carga();
	if (editing) {
		if (dialog) {
			dialog.style.left=e.pageX+"px";
			dialog.style.top=e.pageY+"px";
		//return false;
		}
	} else {
		elem = document.elementFromPoint(e.clientX,e.clientY);
		if (blocks.indexOf(elem)>=0) 
			return false;
		if (elem.id=='marco-plmanual') 
			return false;
			
		elem.webkitBoxSizing = 'border-box';	
		lastElement = elem;
		if (!findInTree(lastElement,'marco-plmanual')) {
			lastContainer = getContainer(lastElement);
			lastEvent = e;
			lastElement.style.border = '4px dotted blue';
			if (lastContainer) lastContainer.style.border = '2px dotted red';
			b=getChildren(lastElement.parentNode.firstChild, lastElement);
			for (var i=0;i<b.length;i++) {
				//console.log("CH:"+getXPath(b[i]));
				if (blocks.indexOf(b[i])>=0) {} else {
					b[i].style.border = '2px dotted green'
				}
			}
			lastElement.title =lastElement.tagName;
			console.log("MARCO OVER:"+elem);
		}
	}
}

function quita(e) {
	if (!e) e=event;
	if (editing) return false;
	if (blocks.indexOf(lastElement)>=0) 
		return;
    if (!lastElement) return false;
	if (lastElement.id=='marco-plmanual') 
		return;
		lastElement.title="";
	lastElement.style.border = "0px solid transparent";
    if (lastContainer) lastContainer.style.border = "0px solid transparent";
    b=getChildren(lastElement.parentNode.firstChild, lastElement);
    //console.log(b);
    for (var i=0;i<b.length;i++) {
        if (blocks.indexOf(b[i])>=0) {} else {
            b[i].style.border = '0px solid transparent'
        }
    }
	//console.log("SALE "+lastElement);
}

function findInTree(elem,id) {
	//console.log("("+elem.id+") ("+id+")");
	if (elem.id == id) {
		return true;
	} else {
		if (elem.parentNode)
			return findInTree(elem.parentNode,id);
		else
			return false;
	}
}

function isContainer(tag) {
	
}

function getContainer(elem) {
    console.log("GC: ("+elem.tagName+")");
	if (isContainer(elem.tagName)) {
		return elem;
	} else {
		if (elem.parentNode)
			return getContainer(elem.parentNode);
		else
			return undefined;
	} 
}

function dale(e) {
	if (!e) e=event;
	console.log("CLICK1 "+editing + " " +lastElement.tagName.toLowerCase()+" "+lastElement.id+" xpath:"+getXPath(lastElement));
	if ( !editing && 
		 !findInTree(lastElement,'marco-plmanual') &&
		 (lastElement.id != 'dialog-window-plmanual') &&
		 (lastElement.id != 'marco-plmanual') &&
		 (lastElement.id != 'plno') &&
		 (lastElement.id != 'plyes') ) {
		editing = true;

		lastElement.style.border = "5px solid red";
        
		xpath = getXPath(lastElement);
		lastContainer = getContainer(lastElement);
        
		if (!document.getElementById('dialog-window-plmanual'))
			dialog = document.createElement('div');
		else
			dialog = document.getElementById('dialog-window-plmanual');
			
		dialog.id = "dialog-window-plmanual";
		dialog.style.zIndex="1000";
		dialog.style.overflow = "scroll";
		dialog.style.top = e.pageY+"px";
		dialog.style.position="absolute";
		dialog.style.width = (document.body.clientWidth/3)+"px";
		dialog.style.left = ((document.body.clientWidth/3)-(parseInt(dialog.style.width)/3))+"px";
		dialog.style.height = '200px'
		dialog.style.border = '4px dotted #000000'
		dialog.style.opacity = "0.8";
		dialog.style.background = '#F0F0F0'
		dialog.style.color = 'black	'
		
		dialog.innerHTML="<h1>New page block?</h1>";
		dialog.innerHTML+="Location: "+xpath+"<br/>";
        dialog.innerHTML+="Container: "+getXPath(lastContainer);
		dialog.innerHTML+="<center>";
		dialog.innerHTML+="<span href id='plyes'>[F2 add element]</span>&nbsp;";
        dialog.innerHTML+="<span href id='plno'>[F3 add siblings]</span>&nbsp;";
		dialog.innerHTML+="<span href id='plno'>[F4 accept container]</span>&nbsp;";
		dialog.innerHTML+="<span href id='plparent'>[F5 send]</span>&nbsp;";
		dialog.innerHTML+="<span href id='plparent'>[F6 hide/show panel]</span>&nbsp;";
		dialog.innerHTML+="<span href id='plparent'>[F7/ESC cancel]</span>&nbsp;";
		dialog.innerHTML+="</center><br>";
		dialog.style.display='inherit';
		
		if (!document.getElementById('dialog-window-plmanual')) {
			document.body.appendChild(dialog);
			console.log("dialogo creado");
		}
	} else {
			if (findInTree(lastElement,"marco-plmanual")) {
				if (lastElement.tagName=="A") {
					blocks[parseInt(lastElement.id)].style.background='';
					blocks[parseInt(lastElement.id)].style.border='';
					blocks[parseInt(lastElement.id)]=undefined;
					update_marco();
				} else if (lastElement.id=="send") {
					update_marco_submit();
				} else if (lastElement.id=="pmanual_username") {
					document.getElementById('pmanual_username').value = prompt("name:");
				} else if (lastElement.id=="pmanual_useremail") {
					document.getElementById('pmanual_useremail').value = prompt("email:");
				} else if (lastElement.id=="finalsend") {
					document.getElementById('pmanual_form').submit();
				}
			}
	}
}

function goparent() {
    console.log("GDADDY "+lastElement.parentNode)
	if (lastElement.parentNode) {
        lastElement.style.border = "0px solid transparent";
        lastElement = lastElement.parentNode;
	    editing=false
	    dale(lastEvent);
	} else {console.log("NO MORE PARENTS!!!")}
	return(false);
}

function addNewBlock(block) {
	console.log("dep: NB: "+block);
	block.style.background = 'blue';
	block.style.border = '4px dotted red';
	block.style.opacity = '0.8';
	blocks.push(block);
    dblock = [];
    dblock.push(block.id);
    dblock.push(block.className);
    dblock.push(getXPath(block));
    dblock.push(dimension(block));
    //~ self.port.emit("addNewBlock",dblock);
	document.body.removeChild(document.getElementById('dialog-window-plmanual'));
	update_marco();
	editing=false;
	dialog=undefined;
	return(false);
}

function discardBlock() {
	console.log("DISC: "+lastElement);
	lastElement.style.border = "0px solid transparent";
    b = getChildren(lastElement.parentNode.firstChild);
    for (var i=0;i<b.length;i++) {
        b[i].style.border = "0px solid transparent";
    }
	document.body.removeChild(document.getElementById('dialog-window-plmanual'));
	editing=false;
	dialog=undefined;
	return(false);
}

function getXPath(elt) {
     var path = "";
     for (; elt && elt.nodeType == 1; elt = elt.parentNode)
     {
   	idx = getElementIdx(elt);
	xname = elt.tagName;
	if (idx > 1) xname += "[" + idx + "]";
	path = "/" + xname + path;
     }
 
     return path.toLowerCase();	
}

function getElementIdx(elt)
{
    var count = 1;
    for (var sib = elt.previousSibling; sib ; sib = sib.previousSibling)
    {
        if(sib.nodeType == 1 && sib.tagName == elt.tagName)	count++
    }
    
    return count;
}
