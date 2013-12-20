//~ window.onload = function() {alert("cargo");carga()};

var marco = undefined;
var metaData;

function update_marco() {
    var s="<img src='"+chrome.extension.getURL("images/logo.png") +"' width='128'><br/>";
    s+="BOM Version:"+bomversion+"<br>";
	s+="Window:"+$(window).width()+"x"+$(window).height()+"<br>";
	s+="Document:"+$(document).width()+"x"+$(document).height()+"<br>";
	s+="<form>";
	blocks = [];
	updateBlockList(page);
	s+=blocks.length+" blocks";
	//~ for (var i=0;i<blocks.length;i++) {
			//~ if (blocks[i])
				//~ s+="<tr id='"+(i+1)+"'>";
				//~ s+="<td>"+(i+1)+"</td>";
				//~ s+="<td>" + blocks[i].id + "</td><td>" + dimension(blocks[i]) + "</td></tr>";
	//~ }
	s+="<input id='send' type='button' value='Send' onclick='send()'>";
	s+="<input id='getvc1' type='button' value='Get ViXML document'>";
	s+="<input id='getvx2' type='button' value='Get ViXML2 document'>";
	s+="</form><br>";
	marco.setContent(s);
	//~ hideLayout()
}
function dimension(block) {
	var rect = block.dim;
	return rect.x+","+rect.y+","+rect.w+","+rect.h;
}

function update_marco_submit() {
    var s="<img src='"+chrome.extension.getURL("images/logo.png") +"' width='128'><br/>";
    s+="Send Blocks<br>";
	//~ s+="<form action='http://www-poleia.lip6.fr/~sanojaa/SCAPE/submit.php' id='pmanual_form' method='POST'>";
    s+="<form action='http://www-poleia.lip6.fr/~sanojaa/BOM/submit.php' id='pmanual_form' method='POST'>";
	blocks = [];
	
	updateBlockList(page);
	
	showLayout();
	s+=blocks.length+" blocks<br>";
	
	s+="<input type='hidden' value='"+blocks.length+"' name='total'>";
	pn=getURLParameter('fn');
	s+="<input id='pmanual_webpage' type='hidden' size='80' value='"+pn+"' name='page'><br>";
	s+="<input id='pmanual_source' type='hidden' size='80' value='BOMdata' name='source'><br>";
	s+="<input id='pmanual_meta' type='hidden' size='30' value='"+metaData+"' name='meta'><br>";
	s+="<input id='pmanual_meta_window' type='hidden' size='30' value='"+$(window).width()+"x"+$(window).height()+ "' name='meta2' style='display:none'><br>";
	s+="<input id='random' type='hidden' size='30' value='"+(Math.ceil(Math.random()*2000))+ "' name='random' style='display:none'><br>";
	
	s+="<input id='pmanual_username' type='text' value='andres' name='name' style='display:none'><br>";
	s+="<select id='pmanual_category' name='category' style='display:none'>";
    s+="<option value='arts'>Arts</option>";
    s+="<option value='business'>Business</option>";
    s+="<option value='computers'>Computers</option>";
    s+="<option value='games'>Games</option>";
    s+="<option value='health'>Health</option>";
    s+="<option value='home'>Home</option>";
    s+="<option value='kids_and_teens'>Kids and Teens</option>";
    s+="<option value='news'>News</option>";
    s+="<option value='recreation'>Recreation</option>";
    s+="<option value='reference'>Reference</option>";
    s+="<option value='regional'>Regional</option>";
    s+="<option value='science'>Science</option>";
    s+="<option value='society'>Society</option>";
    s+="<option value='shopping'>Shopping</option>";
    s+="<option value='sports'>Sports</option>";
    s+="<option value='world'>World</option>";
	s+="</select><br>";
	//~ console.log(s);
	//~ var bs="";
	var k=1;
	for (var i=0;i<blocks.length;i++) {
		if (blocks[i]) {
			var c = countChildren(blocks[i]);
			console.log(blocks[i],c);
			if (c==0) {
				s+="<input type='hidden' value='G" + k + "," + dimension(blocks[i]) + "," + blocks[i].id +"' name='block"+(k)+"'>";
				k++;
			}
			console.log("out");
		}
	}
	//~ s+=bs;
	s+="<input id='finalsend' type='submit' value='Contribute to project' onclick='return confirm(\"Do you want to send data to our server?\")'>";
	s+="<textarea id='wprimaobj' name='wprimaobj'cols='20' rows='10'>"+wprima+"</textarea>";
	s+="</form>";	
	marco.setContent(s);
	//~ wprimaobj = document.getElementById("wprimaobj");
	//~ console.log(wprima);
	//~ wprima.value = wprima;
}


function getURLParameter(name) {
  return document.URL;
}


function showLayout() {
	for (var i=0;i<blocks.length;i++) {
		if (blocks[i]) {
			var c = countChildren(blocks[i]);
			console.log(blocks[i],c);
			if (c==0) {
				blocks[i].setOn();
			} else {
				blocks[i].hide(); 
			}
			console.log("out");
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
			var ac = 0.5;
			ac = parseFloat(prompt("Segment with which granularity: 0.0 - 1.0 \nGive a number\n small blocks 0.0 <--> 1.0 bigger blocks",ac));
			startSegmentation(window,ac,50);
			blocks = []
			updateBlockList(page);
			showLayout();
			if (!marco) {
				marco = new rectObj();
				marco.init(window,document)
				marco.build(0,0,200,400,"4px dotted black","#F0F0F0","Loading...","dialog-window-plmanual");
				marco.setOpacity("1")
				marco.setPosition("fixed");
				marco.setClass("bommarco");
			}
			
			
			//set events
			//~ window.onmouseover = pon;
			//~ window.onmouseout = quita;
			//~ window.onmousedown = dale;
			//~ window.onload = carga;
			//~ window.onkeydown = fufu;
			//~ window.onbeforeunload = bye;
			
			var dim = documentDim(window,document)
			console.log(dim);
			metaData = "chrome " + dim.w +"x" + dim.h;

			var sty = document.createElement("style");
			sty.appendChild(document.createTextNode(".bommarco {font-family:arial;color:black;font-size:12px}"))
			document.head.appendChild(sty);
			var sty2 = document.createElement("style");
			sty2.appendChild(document.createTextNode(".bomdialog {font-family:arial;color:black;font-size:12px}"))
			document.head.appendChild(sty2);
			var cont;
			marco.draw();
			getWPrima(page,true);
			//~ update_marco();
			update_marco_submit();
		
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


