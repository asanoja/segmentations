<?php
$fn=$_GET['url'];
$browser=$_GET['browser'];
$granularity=$_GET['granularity'];
$cmd = $_GET['cmd'];
if ($cmd == 'capture') {
	$r="http://132.227.204.64:8083/".$cmd."?browser=".$browser."&granularity=".$granularity."&url=".$fn;
	Header("Content-Type: image/png");
	$res = file_get_contents($r);
}
if ($cmd == 'xml') {
	$r="http://132.227.204.64:8082/".$cmd."?browser=".$browser."&granularity=".$granularity."&url=".$fn;
	Header("Content-Type: text/plain");
	$res = file_get_contents($r);
}
if ($cmd == 'png') {
	$r="http://132.227.204.64:8082/".$cmd."?browser=".$browser."&granularity=".$granularity."&url=".$fn;
	Header("Content-Type: image/png");
	$res = file_get_contents($r);
}
if ($cmd == 'base64') {
	$r="http://132.227.204.64:8082/".$cmd."?browser=".$browser."&granularity=".$granularity."&url=".$fn;
	Header("Content-Type: text/plain");
	$res = file_get_contents($r);
}
echo $res;
?>
