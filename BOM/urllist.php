<?php
header('Content-Type: application/javascript; charset=utf-8');
?>

<?php
$link = mysql_connect('localhost', 'bom', 'dtwjshLHJwUERR7Q');
if (!$link) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("bom", $link);
?>

urls = [<?php
$results = mysql_query("select distinct url from segmentation order by ts desc",$link);
  while ($row = mysql_fetch_object($results)) {
	 echo "'".$row->url."',";
  }
?>
];
