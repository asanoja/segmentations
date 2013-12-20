<?php
$link = mysql_connect('localhost', 'bom', 'dtwjshLHJwUERR7Q');
if (!$link) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("bom", $link);
?>
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
$algo1 = get('algorithm1');
$algo2 = get('algorithm2');
$browser1 = get('browser1');
$browser2 = get('browser2');
$gtb = get('gtb');
$stb = get('stb');
//~ $graph = get('graph');

$a1='GT';
$a2='GT';

if ($algo1=="BOMdata") $a1="BOM";
if ($algo1=="VIPSdata") $a1="VIPS";

if ($algo2=="BOMdata") $a2="BOM";
if ($algo2=="VIPSdata") $a2="VIPS";

$sql = "insert into metrics(`url`,`category`,`tc`,`to`,`tu`,`co`,`cu`,`cm`,`cf`,`tt`,`gtb`,`stb`,`algo1`,`algo2`,`browser1`,`browser2`) values('".$url."','".$cat."','".$tc."','".$to."','".$tu."','".$co."','".$cu."','".$cm."','".$cf."','".$tt."','".$gtb."','".$stb."','".$a1."','".$a2."','".$browser1."','".$browser2."');";
mysql_query($sql,$link);
echo "The data has been saved!";
mysql_close($link);
?>
<h1>Results record</h1>
<table border="1" width="100%">
	<tr align="center">
		<td><b>Page</b></td>
		<td><b>Algorithm 1</b></td>
		<td><b>Algorithm 2</b></td>
		<td><b>GT blocks</b></td>
		<td><b>Seg Blocks</b></td>
		<td><b>TT</b></td>
		<td><b>Tc</b></td>
		<td><b>To</b></td>
		<td><b>Tu</b></td>
		<td><b>Co</b></td>
		<td><b>Cu</b></td>
		<td><b>Cm</b></td>
		<td><b>Cf</b></td>
	</tr>
	<tr align="center">
		<td><?=$url?></td>
		<td><?=$algo1?>@<?=$browser1?></td>
		<td><?=$algo2?>@<?=$browser2?></td>
		<td><?=$gtb?></td>
		<td><?=$stb?></td>
		<td><?=$tt?></td>
		<td><?=$tc?></td>
		<td><?=$to?></td>
		<td><?=$tu?></td>
		<td><?=$co?></td>
		<td><?=$cu?></td>
		<td><?=$cm?></td>
		<td><?=$cf?></td>
	</tr>
</table>

