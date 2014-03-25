<?php include "../../conn.php";?>
<h1>URL details</h1>
<?php
$url = $_GET["url"];
?>
<h2>URL: <a href="<?php echo $url?>" target="_blank"><?php echo $url?></a></h2>

<?php include "urlutil.php";?>
<?php $cache = getCacheUrl($url);?>
<h3>Cache: <a href="<?=$cache?>" target="_blank"><?=$cache?></a></h3>

<?php
$sql="select * from segmentation where url='".$url."' and kind='GTdata'";
	$detail = mysql_query($sql);
	$count = mysql_num_rows($detail);
	$gt = $count>0;
?>
<?php if ($gt) {?>
<b>Goto:</b> <input type="button" onclick="location.href='gt.php?url=<?=$url?>'" value="Evaluation enviroment">
<?php }?>
<input type="button" onclick="location.href='curate_doc_detail.php?url=<?=$url?>'" value="Curation enviroment"><br>
<b>Algorithm Legend</b>
<ul>
	<li>GTdata : Ground-truth </li>
	<li>BOMdata : Block-o-Matic </li>
	<li>BFdata : Blockfusion </li>
	<li>VIPSdata : MS-VIPS </li>
	<li>JVIPSdata : JavaVIPS</li>
</ul>
<table border="1" width="100%">
<tr align="center">
	<td><b>Segmentation</b></td>
	<td><b>Algorithm</b></td>
	<td><b>Browser</b></td>
	<td><b>Category</b></td>
	<td><b>Granularity</b></td>
	<td><b>Geometry</b></td>
	<td><b>Taken</b></td>
	<td colspan="1"><b>Ops</b></td>
	<td>
	</td>
</tr>
<?php

//esto deberia ser mas dinamico usando el campo kind
$sql = "select * from segmentation where url='".$url."';";
$detail = mysql_query($sql,$link);
while ($d = mysql_fetch_assoc($detail)) {
?>
<tr align="center">
	<td><a href='seg_detail.php?segid=<?php echo $d['id']?>'>SEG-<?php echo $d['id']?></a></td>
	<td><?php echo $d['kind']?></td>
	<td><?php echo $d['browser']?></td>
	<td><?php echo $d['category']?></td>
	<td><?php echo $d['granularity']?></td>
	<td><?php echo $d['doc_w']?> x <?php echo $d['doc_h']?></td>
	<td><?php echo $d['ts']?></td>
	<td>&nbsp;</td>
	<td>
		<center><iframe src="drawseg.php?segid=<?=$d['id']?>&table=blocks&docw=125&doch=125" style='width:150;height:150;overflow:none'></iframe></center>
	</td>
<!--
	<td><a href=''>delete</a></td>
-->
</tr>
<?php
}
?>
</table>
