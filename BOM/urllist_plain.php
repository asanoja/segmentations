<?php
header('Content-Type: application/javascript; charset=utf-8');

$collection_id = "GOSH";
$category = "";
$maxseg = 4;

if (isset($_GET["collection_id"])) {
	if (trim($_GET["collection_id"])!="") {
		$collection_id=trim($_GET["collection_id"]);
	}
}
if (isset($_GET["category"])) {
	if (trim($_GET["category"])!="") {
		$category=trim($_GET["category"]);
	}
}
?>
<?php include "conn.php";?>
<?php
if ($collection_id=="") {
	$sql = "select url,count(kind) as c from segmentation group by url having c>=".$maxseg." order by url desc";
} else {
	if ($category=="") {
		$sql = "select url,count(kind) as c from segmentation where collection_id='".$collection_id."' group by url having c>=".$maxseg." order by url desc";
	} else {
		$sql = "select url,count(kind) as c from segmentation where collection_id='".$collection_id."' and category='".$category."' group by url having c>=".$maxseg." order by url desc";
	}
}
$results = mysql_query($sql,$link);
  while ($row = mysql_fetch_object($results)) {
	 echo $row->url."\n";
  }
?>
