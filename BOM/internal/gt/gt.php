<html>
	<head>
		<title>G|T Segmentations Evaluation</title>
	</head>
<!-- global script -->
<script src="../../js/rectlib.js"></script>
<script>

var contentDocument;
var topDocument;
var contentWindow;
var topWindow;
var evalWindow;
var evalDocument;

var drawings = [];
var dataloaded = 0;

var batchmode = false;

function debug(data) {topWindow.add2log(data)}

function add2(struc,level,data,events) {
	topWindow.add2struc(struc,level,data,events)
}

window.onload = function() {
        topWindow 		= window.frames[0];
        topDocument 	= topWindow.document;
        
        evalWindow 		= window.frames[5];
        evalDocument 	= evalWindow.document;
        
        //~ topWindow.loadURLS();
        
        startFilter();
        //~ contentWindow 	= window.frames[1];
        //~ contentDocument = contentWindow.document;
        //startSegmentation();
};

function startFilter() {
	var url = topDocument.getElementById('gturl').value;
	var part1 = topDocument.getElementById('left_algorithm').value;
	var part2 = topDocument.getElementById('right_algorithm').value;
	
	var leftseg = part1.split("|")[0];
	var rightseg = part2.split("|")[0];
	var left_browser = part1.split("|")[1];;
	var right_browser = part2.split("|")[1];
	var collection_id = topDocument.getElementById('collection_id').value;
	var category = topDocument.getElementById('category').value;
	setSegmentation(collection_id,category,leftseg,rightseg,left_browser,right_browser,url);
}

function prepareEvaluation() {
	var url = topDocument.getElementById('gturl').value;
	
	var part1 = topDocument.getElementById('left_algorithm').value;
	var part2 = topDocument.getElementById('right_algorithm').value;
	
	var algo1 = part1.split("|")[0];
	var algo2 = part2.split("|")[0];
	var browser1 = part1.split("|")[1];
	var browser2 = part2.split("|")[1];
	
	evalWindow.clearDivsIn(parent.frames[2].document);
	evalWindow.clearDivsIn(parent.frames[4].document);
	if (evalWindow.prepareEvaluation(url,algo1,algo2,browser1,browser2)) {
		evalWindow.draw(evalWindow.e.gt,parent.frames[2]);
		evalWindow.draw(evalWindow.e.seg,parent.frames[4])
		return(true);
	}
	return(false);
}

function startEvaluation() {
	var tt = parseInt(topDocument.getElementById('tt').value);
	var tr = parseFloat(topDocument.getElementById('tr').value);
	var part1 = topDocument.getElementById('left_algorithm').value;
	var part2 = topDocument.getElementById('right_algorithm').value;
	var algo1 = part1.split("|")[0];
	var algo2 = part2.split("|")[0];
	var browser1 = part1.split("|")[1];
	var browser2 = part2.split("|")[1];
	var collection_id = topDocument.getElementById('collection_id').value;
	evalWindow.startEvaluation(tr,tt,algo1,algo2,browser1,browser2,collection_id);
}

function setSegmentation(collection_id,category,leftseg,rightseg,left_browser,right_browser,url) {
	document.getElementById("gtfilter").src = "http://www-poleia.lip6.fr/~sanojaa/BOM/data.php?source="+leftseg+"&filter="+encodeURIComponent(url)+"&browser="+left_browser+"&collection_id="+collection_id+"&category="+category;
	document.getElementById("segfilter").src = "http://www-poleia.lip6.fr/~sanojaa/BOM/data.php?source="+rightseg+"&filter="+encodeURIComponent(url)+"&browser="+right_browser+"&collection_id="+collection_id+"&category="+category;
}

function batch(urlind,algoind) {
	batchmode = true;
	topWindow.algoind = 1;
	topWindow.urlind = 1
	topWindow.document.getElementById("right_algorithm").style.display ="inherit";
	topWindow.document.getElementById("left_algorithm").selectedIndex = 0; //first algorithm
	topWindow.document.getElementById("right_algorithm").selectedIndex = 1; //second algorithm
	topWindow.processURL();
}

function dataLoaded() {
	dataloaded++;
	console.log("cargada data: "+dataloaded)
	if (dataloaded>1) {
		dataloaded=0;
		if (parent.batchmode) {
			if (topWindow) topWindow.step2();
		}
	}
}

function isURLPresent(url) {
	var filterdoc = window.frames[1].document;
	var elements = filterdoc.getElementsByTagName("td");
	for (var i=0;i<elements.length;i++) {
		if (elements[i].innerText.trim().toLowerCase() == url.trim().toLowerCase()) {
			return(true);
		}
	}
	return(false)
}
</script>

<frameset rows="25%,*,5%">
	<frame src='gttop.php?collection_id=<?=$_GET["collection_id"]?>&category=<?=$_GET["category"]?>' id='top' name='top'>
	<frameset cols="33%,33%,*">
		<frameset rows="33%,*">
<!--
			<frame id='gtfilter' name='gtdata' src='http://www-poleia.lip6.fr/~sanojaa/BOM/data.php?source=GTdata'/>
			
-->
			<frame id='gtfilter' name='gtdata' src='http://www-poleia.lip6.fr/~sanojaa/BOM/data.php?source=GTdata'/>
			<frame id='gtview' name='gtview' src='about:blank'/>
		</frameset>	
		<frameset rows="33%,*">
<!--
			<frame id='segfilter' name='segfilter' src='http://www-poleia.lip6.fr/~sanojaa/BOM/data.php?source=BOMdata'/>
-->
			<frame id='segfilter' name='segfilter' src='http://www-poleia.lip6.fr/~sanojaa/BOM/data.php?source=BOMdata'/>

			<frame id='segview' name='segview' src='about:blank'/>
		</frameset>	
		<frame id='evaluacion' name='evaluacion' src='evaluate.html'/>
	</frameset>
	<frame id='evalout' name='evalout' src='about:blank'/>
	
</frameset>
</html>
