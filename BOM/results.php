<?php include "conn.php" ?>
<?php
function get($key) {
	return($_GET[$key]);
}

$url = get('url');
$cat = get('category');
$tc = get('tc');
$to = get('to');
$tu = get('tu');
$co = get('co');
$cu = get('cu');
$cf = get('cf');
$cm = get('cm');
$tt = get('tt');
$tr = get('tr');
$algo1 = get('algorithm1');
$algo2 = get('algorithm2');
$browser1 = get('browser1');
$browser2 = get('browser2');
$gtb = get('gtb');
$stb = get('stb');
$collection_id = get('collection_id');
$score1 = get('score1');
$score2 = get('score2');
//~ $graph = get('graph');

$a1='GT';
$a2='GT';

if ($algo1=="BOMdata") $a1="BOM";
if ($algo1=="VIPSdata") $a1="VIPS";
if ($algo1=="BFdata") $a1="BF";
if ($algo1=="JVIPSdata") $a1="JVIPS";

if ($algo2=="BOMdata") $a2="BOM";
if ($algo2=="VIPSdata") $a2="VIPS";
if ($algo2=="BFdata") $a2="BF";
if ($algo2	=="JVIPSdata") $a2="JVIPS";


	$sql="select category from segmentation where collection_id='".$collection_id."' and url='".$url."'";
	$results = mysql_query($sql); 
    if ($row = mysql_fetch_array($results)) {
		$cat = $row[0];
	}

$sql = "insert into metrics(`url`,`category`,`tc`,`to`,`tu`,`co`,`cu`,`cm`,`cf`,`tt`,`gtb`,`stb`,`algo1`,`algo2`,`browser1`,`browser2`,collection_id,score1,score2,tr) values('".$url."','".$cat."','".$tc."','".$to."','".$tu."','".$co."','".$cu."','".$cm."','".$cf."','".$tt."','".$gtb."','".$stb."','".$a1."','".$a2."','".$browser1."','".$browser2."','".$collection_id."',".$score1.",'".$score2."','".$tr."');";
mysql_query($sql,$link);
if (mysql_errno()>0) {echo "The data was NOT saved!";echo mysql_error();} else {
echo "The data has been saved!";
mysql_close($link);
?>
<h1>Results record</h1>
<table border="1" width="100%">
	<tr align="center"><td><b>Collection</b></td><td><?=$collection_id?></td></tr>
	<tr align="center"><td><b>Category</b></td><td><?=$cat?></td></tr>
	<tr align="center"><td><b>Page</b></td><td><?=$url?></td></tr>
	<tr align="center"><td><b>Algorithm 1</b></td><td><?=$algo1?>@<?=$browser1?></td></tr>
	<tr align="center"><td><b>Algorithm 2</b></td><td><?=$algo2?>@<?=$browser2?></td></tr>
	<tr align="center"><td><b>GT blocks</b></td><td><?=$gtb?></td></tr>
	<tr align="center"><td><b>Seg Blocks</b></td><td><?=$stb?></td></tr>
	<tr align="center"><td><b>TT</b></td><td><?=$tt?>px</td></tr>
	<tr align="center"><td><b>TR</b></td><td><?=$tr?></td></tr>
	<tr align="center"><td><b>Tc</b></td><td><b><?=$tc?></b></td></tr>
	<tr align="center"><td><b>To</b></td><td><?=$to?></td></tr>
	<tr align="center"><td><b>Tu</b></td><td><?=$tu?></td></tr>
	<tr align="center"><td><b>Co</b></td><td><?=$co?></td></tr>
	<tr align="center"><td><b>Cu</b></td><td><?=$cu?></td></tr>
	<tr align="center"><td><b>Cm</b></td><td><?=$cm?></td></tr>
	<tr align="center"><td><b>Cf</b></td><td><?=$cf?></td></tr>
	<tr align="center"><td><b>Prec</b></td><td><?=$tc/$gtb?></td></tr>
	<tr align="center"><td><b>Score1</b></td><td><?=$score1?></td></tr>
	<tr align="center"><td><b>Score2</b></td><td><?=$score2?></td></tr>
</table>
<?}?>
