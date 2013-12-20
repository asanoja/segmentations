<script>
window.onload = function() {parent.dataLoaded();}
</script>
<?php
$link = mysql_connect('localhost', 'bom', 'dtwjshLHJwUERR7Q');
if (!$link) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("bom", $link);
?>
<?php
$GLOBALS['trow']=-1;

function fmt($s) {
	$col=1;
	$GLOBALS['trow']++;
	$d=explode(",",$s);
	$f="<tr align='center'>";
	
	for ($i=0;$i<count($d);$i++) {
		$f=$f."<td id='r".$GLOBALS['trow']."c".$col."' row='".$GLOBALS['trow']."' col='".$col."'>".$d[$i]."</td>";
		$col++;
	}
	$f=$f."</tr>";
	return $f;
}

$source = $_GET['source'];
$browser = $_GET['browser'];
$bfilter = "";

if ($source=="GTdata") {
	$table = "gt_blocks";
	$logo="logo_mob.png";
	$color="green";
	$extra="";
}
if ($source=="BOMdata") {
	$table = "bom_blocks";
	$logo="logo_bom.png";
	$color="blue";
	$bfilter =  " and browser='".$browser."'";
	$extra = " on " . $browser;
}
if ($source=="VIPSdata") {
	$table = "vips_blocks";
	$logo="logo_vips.png";
	$color="purple";
	$bfilter =  " and browser='".$browser."'";
	$extra = " on " . $browser;
}


$filter=true;
if ($_GET['filter']=="") $filter=false;
$qfilter = trim($_GET['filter']);

//~ $handle = @fopen("/web/sanojaa/public_html/SCAPE/".$filename . ".txt", "r");
//~ $handle = @fopen("/var/www/BOM/data/".$filename . ".txt", "r");
//~ if ($data) {
	echo $table . $extra;
	echo "<table border='1'>";
	$ms = "SELECT MAX(segmentation_id) FROM ".$table." where url='".$qfilter."'".$bfilter;
	$sql="select * from ".$table." where url='".$qfilter."'".$bfilter." and segmentation_id=(".$ms.")";
	$results = mysql_query($sql); 
    while ($row = mysql_fetch_array($results)) {
		$s = $row[1].",".$row[2].",".$row[3].",".$row[4].",".$row[5].",".$row[6].",".$row[7].",".$row[8].",".$row[9].",".$row[10];
		echo fmt($s);
    }
    echo "</table>";
    mysql_close();
//~ }
?>

