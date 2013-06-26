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
var vblocks = new Array();
var marco = undefined;
var dialog = undefined;
var cargado = false;
var metaData = "";
var lastBlock = undefined;
var alldisabled = false;
var over = undefined;

function bye() {
    self.port.emit("unload");
}

function fufu(e) {
	if (!e) e=event;
	//~ console.log(e.keyCode);
	if (e.keyCode == 113) {
		console.log("F2");
		if (editing) addNewBlock();
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

function getOffset(obj) {
	pos = {x: 0, y: 0};
	el = obj;
	while (el) {
		pos.x += (el.offsetLeft - el.scrollLeft + el.clientLeft);
		pos.y += (el.offsetTop - el.scrollTop + el.clientTop);
		console.log("E: "+getXPath(obj)+" CUR:"+el.tagName+" ("+pos.x+","+pos.y+")");
		el = el.offsetParent;
	}
	return(pos);
}

function getDim(block) {
	var dim = {w: 0, h: 0};
	dim.w = block.offsetWidth;
	dim.h = block.offsetHeight;
	return dim;
}

function getRect2(obj) {
	var of = getOffset(obj);
	var di = getDim(obj);
	return {left:of.x, top:of.y, width:di.w, height:di.h}
}

function getRect3(obj) {
	return {left:$(obj).offset().left, top:$(obj).offset().top, width:$(obj).width(), height:$(obj).height()}
}

function getRect(obj) {
	dim = {x:0, y:0, w:0, h:0};
	//~ r = obj.getBoundingClientRect();
	//~ r = getRect2(obj);
	r = getRect3(obj);
	dim.x = r.left;
	dim.y = r.top;
	dim.w = r.width;
	dim.h = r.height;
	return dim;
}

function dimension(block) {
	var rect = getRect(block);
	return rect.x+","+rect.y+","+rect.w+","+rect.h;
}

function getDocHeight() {
//~ var d = document;
//~ return Math.max(
//~ Math.max(d.body.scrollHeight, d.documentElement.scrollHeight),
//~ Math.max(d.body.offsetHeight, d.documentElement.offsetHeight),
//~ Math.max(d.body.clientHeight, d.documentElement.clientHeight)
//~ );
return Math.max(document.documentElement["clientHeight"], document.body["scrollHeight"], document.documentElement["scrollHeight"], document.body["offsetHeight"], document.documentElement["offsetHeight"]);
}

function getDocWidth() {
//~ var d = document;
//~ return Math.max(
//~ Math.max(d.body.scrollWidth, d.documentElement.scrollWidth),
//~ Math.max(d.body.offsetWidth, d.documentElement.offsetWidth),
//~ Math.max(d.body.clientWidth, d.documentElement.clientWidth)
//~ );
return Math.max(document.documentElement["clientWidth"], document.body["scrollWidth"], document.documentElement["scrollWidth"], document.body["offsetWidth"], document.documentElement["offsetWidth"]);
}
function update_over() {
	if (lastElement) {
		over.style.left = getRect(lastElement).x+"px";
		over.style.top = getRect(lastElement).y+"px";
		over.style.width = getRect(lastElement).w+"px";
		over.style.height = getRect(lastElement).h+"px";
		over.innerHTML = "Element: "+getXPath(lastElement); 
	} 
}

function newRect(element,size,style,color,bgcolor,type) {
	if (element)
		console.log("OVER IN "+element+ " "  + getRect(element).h);
	var nover = document.createElement("div");
	nover.id = "plmanualover_" + Math.floor(Math.random()*1001);
	nover.style.background = bgcolor;
	nover.style.border = size + "px "+ style +" black";
	nover.style.opacity = '0.8';
	nover.wordWrap = 'break-word';
	if (element) {
		rect = getRect(element);
		nover.style.left = rect.x+"px";
		nover.style.top = rect.y+"px";
		nover.style.width = rect.w+"px";
		nover.style.height = rect.h+"px";
	} 
	nover.style.position = "absolute";
	nover.style.zIndex = "10000";
	console.log("Element: "+getXPath(element));
	nover.innerHTML = "<span style='font-size:12px;line-height:100%;opacity:100%;color:"+color+"'>Element: "+getXPath(element)+" "+nover.style.left+","+nover.style.top+","+nover.style.width+","+nover.style.height+"</span>";
	if (type=='main') {
		nover.id = "plmanual_over";
		nover.style.border = '4px dotted #000000';
	}
	if (type=="geometry_error") {
		nover.style.opacity = '1';
		nover.innerHTML = "<span style='font-size:104px;line-height:100%;color:white'><center style='color:black'>Window geometry not corret the window width should be at most 1024 to work and zoom set to 100%. We suggest to install <a style='color:white' href='https://chrome.google.com/webstore/detail/window-resizer/kkelicaakdanhinjdeammmilcgefonfh'>Window Resize extension</a></center></span>";
	}
	document.body.appendChild(nover);
	return(nover);
}

function update_marco() {
    marco.innerHTML="<h2>Block-o-Matic</h2><br/>";
	marco.innerHTML+="Selected Blocks<br>";
	//~ marco.innerHTML+="<hr>";
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
	marco.style.zIndex = "4000000";
}

function getURLParameter(name) {
  return document.URL;
}

function countNodes(node) {
  var k = 0, c = node.childNodes.length, result = c;
  for (; k<c; k++) result += countNodes(node.childNodes[k]);
  return result;
} 

function update_marco_submit() {
    s="<h2>Block-o-Matic</h2><br>";
    s+="Send Blocks<br>";
	s+="<form action='http://www-poleia.lip6.fr/~sanojaa/SCAPE/submit.php' id='pmanual_form' method='POST'>";
    //s+="<form action='http://localhost/submit.php' id='pmanual_form' method='POST'>";
	
	var tk=0;
	for (var i=0;i<blocks.length;i++) {
			if (blocks[i]) {
				tk+=1;
			}
	}
	
	s+="Selected "+tk+" blocks<br>"
	s+="<input type='hidden' value='"+tk+"' name='total'>";
	pn=getURLParameter('fn');
	s+="<input id='pmanual_webpage' type='text' size='80' value='"+pn+"' name='page'><br>";
	s+="<input id='pmanual_meta' type='text' size='30' value='"+metaData+"' name='meta'><br>";
	s+="<input id='pmanual_meta_window' type='text' size='30' value='"+$(window).width()+"x"+$(window).height()+ "' name='meta2'><br>";
	s+="<input id='random' type='text' size='30' value='"+(Math.ceil(Math.random()*2000))+ "' name='random'><br>";
	
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
	//~ console.log(s);
	//~ var bs="";
	for (var i=0;i<blocks.length;i++) {
			if (blocks[i]) {
				console.log(getXPath(blocks[i])+","+dimension(blocks[i])+","+blocks[i].id+","+blocks[i].id+","+countNodes(blocks[i]));
				s+="<span>"+getXPath(blocks[i])+","+dimension(blocks[i])+","+blocks[i].id+","+blocks[i].id+","+countNodes(blocks[i])+"</span><br/>";
				s+="<input type='hidden' value='"+getXPath(blocks[i])+","+dimension(blocks[i])+","+blocks[i].id+","+blocks[i].id+","+countNodes(blocks[i])+"' name='block"+(i+1)+"'>";
			}
	}
	//~ s+=bs;
	s+="<input id='finalsend' type='submit' value='Confirm send'>";
	s+="</form>";	
	marco.innerHTML = s;
	marco.style.display="block";
	marco.style.zIndex = "4000000";
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
				document.write('Sorry this ONLY works with Google Chrome or Chromium');
				return false;
			}
			//metaData = navigator.appName.toLowerCase() +" "+ getDocWidth() +"x" + getDocHeight();
			metaData = "chrome " + getDocWidth() +"x" + getDocHeight();

			//~ chrome.runtime.sendMessage({code:"checkgeom", data: ""}, function(response) {
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
			marco.style.zIndex = "4000000";
			marco.style.display = "block"
			
			update_marco();
			
			if (!document.getElementById('marco-plmanual')) {
				document.body.appendChild(marco);
				//~ console.log("marco creado");
			}
			
			//adjusting window geometry
			
			console.log(window.innerWidth,window.innerHeight);
			
			//~ if ( (window.innerWidth>1024)) {
				//~ newRect(document.body,"2px","dotted","blue","white","geometry_error");
				//~ window.onmouseover = undefined;
				//~ window.onmouseout = undefined;
				//~ window.onmousedown = undefined;
			//~ }
			
			editing = false;
			cargado = true;
			//~ if (splash)
			//~ document.body.removeChild(document.getElementById('plmanual_splash'));
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

function newmouseout(e) {
	omask = true;
	pon(e)
}

function pon(e) {
	//~ console.log("PON: " + e +", " + omask);
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
			//lastElement.style.border = '4px dotted blue';
			//~ if (elemChanged)
			//defaultOver.push(newRect(lastElement,4,'dotted','blue','main'));
			if (lastContainer) {
				//~ if (elemChanged) 
					//defaultOver.push(newRect(lastContainer,2,'dotted','red'));
					//lastContainer.style.border = '2px dotted red';
			}
			b=getChildren(lastElement.parentNode.firstChild, lastElement);
			for (var i=0;i<b.length;i++) {
				//console.log("CH:"+getXPath(b[i]));
				if (blocks.indexOf(b[i])>=0) {} else {
					//~ if (elemChanged)
						//defaultOver.push(newRect(b[i],2,"dotted","green"));
					//b[i].style.border = '2px dotted green'
				}
			}
			lastElement.title = lastElement.tagName;
			//~ omask = true;
			//~ console.log("MARCO OVER:"+elem);
			//~ console.log("DOVER:");
			//~ console.log(defaultOver);
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
	//~ omask = true;	
	//~ if (defaultOver) {
		//~ for (var i=0;i<defaultOver.length;i++) {
			//~ console.log(defaultOver[i].id);
			//~ console.log(document.getElementById(defaultOver[i].id));
			//~ document.body.removeChild(document.getElementById(defaultOver[i].id));
		//~ }
	//~ } 
	//~ defaultOver = undefined;
	lastElement.title="";

	//~ if (defaultOver) {
			//~ for (var i=0;i<defaultOver.length;i++) {
				//~ document.body.removeChild(document.getElementById(defaultOver[i].id));
			//~ }
		//~ } 
	//defaultOver = new Array();
	//lastElement.style.border = "0px solid transparent";
    //if (lastContainer) lastContainer.style.border = "0px solid transparent";
    b=getChildren(lastElement.parentNode.firstChild, lastElement);
    //console.log(b);
    //~ for (var i=0;i<b.length;i++) {
        //~ if (blocks.indexOf(b[i])>=0) {} else {
            //~ b[i].style.border = '0px solid transparent'
        //~ }
    //~ }
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
    //~ console.log("GC: ("+elem.tagName+")");
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
	lastBlock = lastElement;
	rect = getRect(lastBlock);
	console.log("CLICK1 "+editing + " " +lastElement.tagName.toLowerCase()+" "+lastElement.id+" xpath:"+getXPath(lastElement)+" DIM:"+rect.x+","+rect.y+","+rect.w+","+rect.h);
	if ( !editing && 
		 !findInTree(lastElement,'marco-plmanual') &&
		 (lastElement.id != 'dialog-window-plmanual') &&
		 (lastElement.id != 'marco-plmanual') &&
		 (lastElement.id != 'plno') &&
		 (lastElement.id != 'plyes') ) {
		editing = true;

		
		if (!over) 
			over = newRect(lastBlock,2,"dotted","blue","white","main")
		else
			update_over();
        
		xpath = getXPath(lastElement);
		lastContainer = getContainer(lastElement);
        
		if (!document.getElementById('dialog-window-plmanual'))
			dialog = document.createElement('div');
		else
			dialog = document.getElementById('dialog-window-plmanual');
			
		dialog.id = "dialog-window-plmanual";
		dialog.style.zIndex="2000001";
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
			//~ console.log("dialogo creado");
		}
	} else {
			if (findInTree(lastElement,"marco-plmanual")) {
				if (lastElement.tagName=="A") {
					blocks[parseInt(lastElement.id)].style.background='';
					blocks[parseInt(lastElement.id)].style.border='';
					blocks[parseInt(lastElement.id)]=undefined;
					//~ vblocks[parseInt(lastElement.id)].style.background='';
					//~ vblocks[parseInt(lastElement.id)].style.border='';
					//~ vblocks[parseInt(lastElement.id)]=undefined;
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
    //~ console.log("GDADDY "+lastElement.parentNode)
	if (lastElement.parentNode) {
        lastElement.style.border = "0px solid transparent";
        lastElement = lastElement.parentNode;
	    editing=false
	    dale(lastEvent);
	} else {console.log("NO MORE PARENTS!!!");lastElement = document.body}
	return(false);
}

function addNewBlock() {
	if (!lastBlock)
		return false;
	block = lastBlock;
	console.log("dep: NB: "+block);
	var nover = newRect(block,2,"dotted","red","black","");
	vblocks.push(nover);
	blocks.push(block);
    dblock = [];
    dblock.push(block.id);
    dblock.push(block.className);
    dblock.push(getXPath(block));
    dblock.push(dimension(block));
    //~ self.port.emit("addNewBlock",dblock);
    if (document.getElementById('dialog-window-plmanual'))
		document.body.removeChild(document.getElementById('dialog-window-plmanual'));
	if (document.getElementById(over.id))
		document.body.removeChild(document.getElementById(over.id));
	update_marco();
	editing=false;
	dialog=undefined;
	return(false);
}

function discardBlock() {
	//~ console.log("DISC: "+lastElement);
	//lastElement.style.border = "0px solid transparent";
    b = getChildren(lastElement.parentNode.firstChild);
    for (var i=0;i<b.length;i++) {
        b[i].style.border = "0px solid transparent";
    }
    if (document.getElementById('dialog-window-plmanual'))
		document.body.removeChild(document.getElementById('dialog-window-plmanual'));
	 if (document.getElementById('plmanual_over')) {
		document.body.removeChild(document.getElementById('plmanual_over'));
	}
	over = undefined;
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
