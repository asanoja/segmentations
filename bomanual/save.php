<?php 

$fn = $_POST['fn'];
$cat = $_POST['category'];
$url = $_POST['url'];
$browser = $_POST['browser'];

if (!file_exists("inbox/".$cat))
	mkdir("inbox/".$cat);

file_put_contents("inbox/".$cat."/".$fn,urldecode($_POST['cont']));

exec("/home/scape/src/segmentations/pagelyzer/pagelyzer capture --url=".$url." --output-folder=/media/DATA/online --headless  --browser=".$browser." &");

echo "OK";
?>
