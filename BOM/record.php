<?php include "conn.php"?>
<?php
function fmt($s) {
	$d=explode(",",$s);
	for ($i=0;$i<count($d);$i++) {
		$f=$f.$d[$i].",";
		$col++;
	}
	$f=$f."\n";
	return $f;
}

$source = $_GET['source'];
$browser = $_GET['browser'];
$bfilter = "";

if ($source=="GTdata") {
	$table = "gt_blocks";
	$bfilter =  " and kind='".$source."'";
	$extra="";
}
if ($source=="BOMdata") {
	$table = "bom_blocks";
	$bfilter =  " and browser='".$browser."' and kind='".$source."'";
	$extra = " on " . $browser;
}
if ($source=="VIPSdata") {
	$table = "vips_blocks";
	$bfilter =  " and browser='".$browser."' and kind='".$source."'";
	$extra = " on " . $browser;
}
if ($source=="BFdata") {
	$table = "bf_blocks";
	$bfilter =  " and browser='".$browser."' and kind='".$source."'";
	$extra = " on " . $browser;
}
if ($source=="JVIPSdata") {
	$table = "jvips_blocks";
	$bfilter =  " and browser='".$browser."' and kind='".$source."'";
	$extra = " on " . $browser;
}

$filter=true;
if ($_GET['filter']=="") $filter=false;
$qfilter = trim($_GET['filter']);
$collection_id = trim($_GET['collection_id']);
$category = trim($_GET['category']);

$fields = array();
array_push($fields,'bid');
array_push($fields,'doc_w');
array_push($fields,'doc_h');
array_push($fields,'nx');
array_push($fields,'ny');
array_push($fields,'nw');
array_push($fields,'nh');
array_push($fields,'ecount');
array_push($fields,'tcount');

	//~ echo $table . $extra;
	$ms = "SELECT MAX(id) as sid FROM segmentation where url='".$qfilter."' and category='".$category."' and collection_id='".$collection_id."' ".$bfilter;
	$mms = mysql_query($ms); 
	$os="";
	if ($os = mysql_fetch_assoc($mms)) {} else die("no segmentation found");
	$sql="select 100 as doc_w,100 as doc_h,nx,ny,nw,nh,ecount,tcount,bid from ".$table." where segmentation_id=(".$os['sid'].")";
	//~ $sql="select * from ".$table." where segmentation_id=(".$os['sid'].")";
	$results = mysql_query($sql); 
	
    while ($row = mysql_fetch_assoc($results)) {
		$s="";
		for ($j=0;$j<count($fields);$j++) {
			$s=$s.$row[$fields[$j]].",";
		}
		$s = rtrim($s, ',');
		echo fmt($s);
    }
    mysql_close();
?>

