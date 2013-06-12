<?php
$fn=$_GET['url'];
$browser=$_GET['browser'];
$granularity=$_GET['granularity'];
$cmd = $_GET['cmd'];
$r="http://132.227.204.64:8082/".$cmd."?browser=".$browser."&granularity=".$granularity."&url=".$fn;
if ($cmd == 'capture') {
	Header("Content-Type: image/png");
	$res = file_get_contents($r);
}
if ($cmd == 'xml') {
	Header("Content-Type: text/plain");
	$res = file_get_contents($r);
}
echo $res;
?>
