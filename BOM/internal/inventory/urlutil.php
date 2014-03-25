<?php
function getCacheUrl($url) {
	$cache = "http://132.227.204.64:8000/";
	require_once("./lib/effectiveTLDs.inc.php");
	require_once("./lib/regDomain.inc.php");
	$purl = parse_url($url);
	$host = trim(getRegisteredDomain($purl));
	//~ echo $purl['host'];
	$arr = explode(".",$purl['host']);
	$arr = array_reverse($arr);
	
	if ($arr[1]=="co" || $arr[1]=="ac") {
		$suffix = $arr[1].".".$arr[0];
		$phost = $arr[2];
	} else {
		$suffix = $arr[0];
		$phost = $arr[1];
	}

	$murl = str_replace("http://","",$url);
	$murl = str_replace("https://","",$murl);
	$murl = str_replace("/","_",$murl);
	$murl = str_replace(":","_",$murl);
	$murl = str_replace("__","_",$murl);

	$url2path = str_replace("http://","",$url);
	$url2path = str_replace("https://","",$url2path);

	$cache = $cache . $suffix . "/" . $phost . "/" . $murl . "/source/" .  $url2path ;
	return $cache;
}

function getCacheFolderUrl($url) {
	$cache = "http://132.227.204.64:8000/";
	require_once("./lib/effectiveTLDs.inc.php");
	require_once("./lib/regDomain.inc.php");
	$purl = parse_url($url);
	$host = trim(getRegisteredDomain($purl));
	//~ echo $purl['host'];
	$arr = explode(".",$purl['host']);
	$arr = array_reverse($arr);
	
	if ($arr[1]=="co" || $arr[1]=="ac") {
		$suffix = $arr[1].".".$arr[0];
		$phost = $arr[2];
	} else {
		$suffix = $arr[0];
		$phost = $arr[1];
	}

	$murl = str_replace("http://","",$url);
	$murl = str_replace("https://","",$murl);
	$murl = str_replace("/","_",$murl);
	$murl = str_replace(":","_",$murl);
	$murl = str_replace("__","_",$murl);

	$url2path = str_replace("http://","",$url);
	$url2path = str_replace("https://","",$url2path);

	$cache = $cache . $suffix . "/" . $phost . "/" . $murl ;
	return $cache;
}

?>

