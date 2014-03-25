<?php include "../../conn.php";?>
<?php
$segid = $_GET["segid"];
$url = "";
$kind = "";
$sql = "select * from segmentation where id='".$segid."' order by url,granularity asc;";
$master = mysql_query($sql,$link);
if ($seg = mysql_fetch_assoc($master)) {
} else die("Ooops master");
$algo = strtolower(str_replace("data","",$seg['kind']));
$table = $algo."_blocks";
$browser = $seg['browser'];

$sql = "select doc_w,doc_h from segmentation where id='".$segid."' limit 1;";
$metal = mysql_query($sql,$link);
if ($meta = mysql_fetch_assoc($metal)) {
} else die("Ooops metal");

?>

<h1>Details for SEG-<?php echo $segid;?>::<?php echo strtoupper($algo)?>/<?php echo $browser?> </h1>
<h2>URL: <a href="<?php echo $seg['url']?>"><?php echo $seg['url']?></a></h2>
<b>Algorithm:</b> <?php echo $seg['kind']?><br>
<b>Browser:</b> <?php echo $seg['browser']?><br>
<b>Geometry:</b> <?php echo $meta['doc_w']?>x<?php echo $meta['doc_h']?><br>
<b>Category:</b> <?php echo $seg['category']?><br>
<b>Granularity:</b> <?php echo $seg['granularity']?><br>
<b>Taken:</b> <?php echo $seg['ts']?><br>
<b>From:</b> <?php echo $seg['source1']?> <?php echo $seg['source2']?><br>

<hr>

<center><iframe src="drawseg.php?segid=<?=$segid?>&table=<?=$table?>" style='width:450;height:450'></iframe></center>
<hr>
<table border="1" width="100%">
<tr align="center">
	<td rowspan="2"><b>BId</b></td>
	<td rowspan="2"><b>Document</b></td>
	<td colspan="4"><b>Block geometry</b></td>
	<td rowspan="2"><b>Cover</b></td>
	<td colspan="1" rowspan="2"><b>Ops</b></td>
</tr>
<tr>
<td align="center"><b>x</b></td>
<td align="center"><b>y</b></td>
<td align="center"><b>w</b></td>
<td align="center"><b>h</b></td>
</tr>
<?php
$sql = "select * from ".$table." where segmentation_id='".$segid."' order by id;";
$detail = mysql_query($sql,$link);
while ($d = mysql_fetch_assoc($detail)) {
?>
<tr align="center">
	<td><?php echo $d['bid']?></td>
	<td><?php echo $d['doc_w']?>x<?php echo $d['doc_h']?></td>
	<td><?php echo number_format($d['x'], 2, '.', ',')?></td>
	<td><?php echo number_format($d['y'], 2, '.', ',')?></td>
	<td><?php echo number_format($d['w'], 2, '.', ',')?></td>
	<td><?php echo number_format($d['h'], 2, '.', ',')?></td>
	<td><?php echo $d['ecount']?></td>
	<td><a href=''>delete</a></td>
</tr>
<?php
}
?>
</table>
