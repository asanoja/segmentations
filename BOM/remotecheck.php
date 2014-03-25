<?php include "conn.php";
$url = $_GET['url'];
$kind = $_GET['kind'];
$browser = $_GET['browser'];

$algo = strtolower(str_replace("data","",$kind));
$table = $algo."_blocks";

$sql = "select count(id) from segmentation where url='".$url."' and browser='".$browser."' and kind='".$kind."'";
$rr = mysql_query($sql,$link);
if ($r = mysql_fetch_row($rr)) {
	if ($r[0]==0) {
		echo "NO";
	} else {
		echo "YES";
	}
} else die("NO");
?>
