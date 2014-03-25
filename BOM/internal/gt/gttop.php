<?php
include "../../conn.php";
?>
<html>
	<head>
<script src="jquery-min.js"></script>
<script src="urllist.php<?if ($_GET["collection_id"]!="") {echo "?collection_id=".$_GET["collection_id"];}?><?if ($_GET["category"]!="") {echo "&category=".$_GET["category"];}?>"></script>
<script>
var urlind;
var algoind;
var browserind;
var ttind;
//var urls = [];
var algo = [<?php
	$sql="select * from algorithms where id<>'GT' and active=1 order by ord asc";
	$results = mysql_query($sql);
	$acum = ""; 
    while ($row = mysql_fetch_array($results)) {
		$acum = $acum . "\"".$row[0]."\",";
	}
	echo rtrim($acum,",");
	?>];

function advance() {
	algoind++;
	if (algoind > algo.length) {
		algoind=1;
		urlind++;
	}
	setTimeout("processURL()",1000);
}

function step2() {
	if (!parent.batchmode) return;
	console.log("Step 2");
	if (parent.prepareEvaluation()) {
		var trobj = document.getElementById("tr");
		var tr = trobj.value;
		//~ for (var trind=0;trind<trobj.options.length;trind++) {
			//~ trobj.selectedIndex = trind;
			console.log("evaluating URL:"+document.getElementById("gturl").value+", A:"+algo[algoind]+", TR:"+tr)
			parent.startEvaluation();
		//~ }
		advance();
	} else {
		advance();
	}
}

function processURL() {
	if (!parent.batchmode) return;
	console.log("Step 1. "+urlind+" "+algoind,document.getElementById("gturl").options.length);
	var eurl = document.getElementById("gturl");
	if (urlind >= eurl.options.length) {
		console.log("Process finished");
		parent.evalDocument.getElementById("evaloutput").innerHTML = "Batch process finished<br><a href='report.php' target='_blank'>Open report</a>"
		parent.batchmode = false;
		return;
	} else {
		if (algoind > algo.length) return;
		eurl.selectedIndex = urlind;
		document.getElementById("right_algorithm").selectedIndex = algoind;
		parent.startFilter(algo[algoind]+"data");
	}
}

function loadURLS() {
	var opt;
	for (var i=document.getElementById("gturl").options.length-1;i>0;i--) {
		document.getElementById("gturl").removeChild(document.getElementById("gturl").options[i]);
	}
	var k=1;
	for (var i=0; i<urls.length; i++) {
		opt = document.createElement("option")
		opt.value = urls[i];
		if (urls[i] == "<?=$_GET["url"]?>") opt.setAttribute("selected", "true");
		
			if (urls[i].indexOf("-")==0) {
				opt.text = urls[i];
				opt.style.backgroundColor="#A52A2A";
				opt.style.color = "white";
			} else {
				opt.text = k +". " +urls[i];
				opt.setAttribute("parsed","true");
			}
		
		if (urls[i].indexOf("-")!=0) k++;
		document.getElementById("gturl").appendChild(opt);
	}
}

function checkAlgoBrDefault(obj,objbrid) {
	var br = document.getElementById(objbrid);
	var match = "";
	if (obj.value == "GTdata") {
		br.style.display = "none";
		br.selectedIndex = 0;
	} else {
		br.style.display = "inherit";
	}
}
</script>
</head>
<body onload="loadURLS()">

<table>
	<tr>
	<td valign="top">
<img src="../../images/gtlogo.png" height="64">
</td>
<td>
<!--
<input type="text" name="url" id="url" value="http://www.upmc.fr/" size="40">
-->
<form id="formafil" name="formafil"  action="gt.php" method="get" target="_top">
	<input type="hidden" name="rnd" value="<?=rand()?>">
Collection: <select name="collection_id" id="collection_id">
<?php
	$sql="select * from collection order by name asc";
	$results = mysql_query($sql); 
    while ($row = mysql_fetch_array($results)) {
		//~ echo $_GET["collection_id"]. " ". $row[0]. ", " . ($_GET["collection_id"]==$row[0]);
		if ($row[0] == $_GET["collection_id"]) {$sel=" selected ";}
		echo "<option ".$sel." value='".$row[0]."'>".$row[1]."</option>";
		$sel="";
	}
	?>
</select>

Category: <select name="category" id="category">
<?php
	$sql="select distinct category from segmentation order by category asc";
	$results = mysql_query($sql); 
    while ($row = mysql_fetch_array($results)) {
		//~ echo $_GET["collection_id"]. " ". $row[0]. ", " . ($_GET["collection_id"]==$row[0]);
		if ($row[0] == $_GET["category"]) {$sel=" selected ";}
		echo "<option ".$sel." value='".$row[0]."'>".$row[0]."</option>";
		$sel="";
	}
	?>
</select>
<input type="submit" value="Go">
</form>
<br>
<form>
<select name="gturl" id="gturl" onchange="parent.startFilter()">
<option value="">[URL]</option>	
</select>
<br>

<span style="border: 1px dotted red ">
	Left: <select name="left_algorithm" id="left_algorithm" onclick="parent.startFilter()">
	<?php
	$sql="select algorithms.name,browsers.long_name,algorithms.id,browsers.id from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id inner join browsers on browsers.id=algo_browser.browser_id where browsers.active=1 and algorithms.active=1 order by algorithms.ord asc";
	$results = mysql_query($sql); 
    while ($row = mysql_fetch_array($results)) {
		echo "<option value='".$row[2]."data|".$row[3]."'>".$row[0]."@".$row[1]."</option>";
	}
	?>
</select>
</span>
<br>
<span style="border: 1px dotted green ">
Right: <select name="right_algorithm" id="right_algorithm" onclick="parent.startFilter()">
	<?php
	$sql="select algorithms.name,browsers.long_name,algorithms.id,browsers.id from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id inner join browsers on browsers.id=algo_browser.browser_id where browsers.active=1 and algorithms.active=1 order by algorithms.ord asc";
	$results = mysql_query($sql); 
    while ($row = mysql_fetch_array($results)) {
		echo "<option value='".$row[2]."data|".$row[3]."'>".$row[0]."@".$row[1]."</option>";
	}
	?>
</select>
</span>
</td>
<td>
<!--
 either <input type='button' value="refresh" onclick="parent.setSegmentation(document.getElementById('algorithm').value)"> or <input type="button" value="Filter"  onclick="parent.startFilter(document.getElementById('algorithm').value)"> data, 
-->
<input type="button" value="load segmentations"  onclick="parent.prepareEvaluation()"> <br>
tt=
<select name="tt" id="tt">
	<?php
		for ($i=0;$i<=20;$i+=2) {
			if ($i==2) {$sel = " selected ";} else {$sel="";}
			?>
			<option value="<?=$i?>" <?=$sel?>><?=$i?></option>
		<?}
	?>
</select>px
tr=
<select name="tr" id="tr">
	<?php
		for ($i=0;$i<1;$i+=0.1) {
			if ($i==0) {$sel = " selected ";} else {$sel="";}
			?>
			
			<option value="<?=$i?>" <?=$sel?>><?=$i?></option>
		<?}
	?>
</select>
 
<input type="button" value="evaluate"  onclick="parent.startEvaluation()"> 
<input type="button" value="batch"  onclick="parent.batch()"> 
<input type="button" value="report"  onclick="window.open('report3.php?collection_id='+document.getElementById('collection_id').value)"> 
</form>

	<input type="button" value="Reset evaluation data"  onclick="if (confirm('Are you sure you want to delete the data?')) {window.open('reset.php','evaluacion')}"> 
	<input type="button" value="Recompute"  onclick="window.open('../inventory/uniform.php','evaluacion')"> 

</td>
</tr>
</table>
</body>
</html>
