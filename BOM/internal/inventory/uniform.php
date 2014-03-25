<?php include "../../conn.php";?>
<?php
$tablas = array();
array_push($tablas,"bf_blocks");
array_push($tablas,"bom_blocks");
array_push($tablas,"gt_blocks");
array_push($tablas,"jvips_blocks");
array_push($tablas,"vips_blocks");

foreach ($tablas as $table) {
	$sql = "update ".$table." set nx = 100*x/doc_w, ny = 100*y/doc_h, nw = 100*w/doc_w, nh = 100*h/doc_h";
	$res=mysql_query($sql,$link);
	echo $table. " -> OK<br>";
}

$sql = "update metrics set score = (tc/(1+cu+cf) )";
$res=mysql_query($sql,$link);
echo "Score -> OK<br>";
?>
<div id="evaloutput"></div>
