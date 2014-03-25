<?php include "../../conn.php";?>
<?php
$algoid = $_GET["algoid"];
$kind = $algoid."data";
$table = strtolower($algoid."_blocks");
?>
<h1>Inventory Blocks Curation</h1>

<input type="button" onclick="location.href='curate.php'" value="Main">

<h2><?=$algoid?> blocks</h2>
<h3>Vertical overflow blocks</h3>
<?php
$sql="select * from ".$table." where (h > doc_h)";
$detail = mysql_query($sql);
if (mysql_num_rows($detail)>0) {
?>
<i><?=mysql_num_rows($detail)?> blocks are in conflict</i>
<table border="1" width="100%">
	<tr align="center">
		<td><b>Segmentation ID</b></td>
		<td><b>BID</b></td>
		<td><b>Document</b></td>
		<td><b>h</b></td>
	</tr>
	<?php while ($obj = mysql_fetch_object($detail)) {?>
	<tr align="center">
		<td><a href="curate_seg_detail.php?segid=<?=$obj->segmentation_id?>"><?=$obj->segmentation_id?></a></td>
		<td><?=$obj->bid?></td>
		<td><?=$obj->doc_w?> x <b><?=$obj->doc_h?></b></td>
		<td><?=$obj->h?></td>
	</tr>
	<?}?>
</table>
<?}?>

<h3>Horizontal overflow blocks</h3>
<?php
$sql="select * from ".$table." where (w > doc_w)";
$detail = mysql_query($sql);
if (mysql_num_rows($detail)>0) {
?>
<i><?=mysql_num_rows($detail)?> blocks are in conflict</i>
<table border="1" width="100%">
	<tr align="center">
		<td><b>Segmentation ID</b></td>
		<td><b>BID</b></td>
		<td><b>Document</b></td>
		<td><b>w</b></td>
	</tr>
	<?php while ($obj = mysql_fetch_object($detail)) {?>
	<tr align="center">
		<td><a href="curate_seg_detail.php?segid=<?=$obj->segmentation_id?>"><?=$obj->segmentation_id?></a></td>
		<td><?=$obj->bid?></td>
		<td><?=$obj->doc_w?> x <b><?=$obj->doc_h?></b></td>
		<td><?=$obj->w?></td>
	</tr>
	<?}?>
</table>
<?}?>

<h3>Horizontal out-of-context blocks</h3>
<?php
$sql="select * from ".$table." where (x > doc_w) or (x<0)";
$detail = mysql_query($sql);
if (mysql_num_rows($detail)>0) {
?>
<i><?=mysql_num_rows($detail)?> blocks are in conflict</i>
<table border="1" width="100%">
	<tr align="center">
		<td><b>Segmentation ID</b></td>
		<td><b>BID</b></td>
		<td><b>Document</b></td>
		<td><b>x</b></td>
		<td><b>w</b></td>
	</tr>
	<?php while ($obj = mysql_fetch_object($detail)) {?>
	<tr align="center">
		<td><a href="curate_seg_detail.php?segid=<?=$obj->segmentation_id?>"><?=$obj->segmentation_id?></a></td>
		<td><?=$obj->bid?></td>
		<td><?=$obj->doc_w?> x <b><?=$obj->doc_h?></b></td>
		<td><?=$obj->x?></td>
		<td><?=$obj->w?></td>
	</tr>
	<?}?>
</table>
<?}?>

<h3>Vertical out-of-context blocks</h3>
<?php
$sql="select * from ".$table." where (y > doc_h) or (y<0)";
$detail = mysql_query($sql);
if (mysql_num_rows($detail)>0) {
?>
<i><?=mysql_num_rows($detail)?> blocks are in conflict</i>
<table border="1" width="100%">
	<tr align="center">
		<td><b>Segmentation ID</b></td>
		<td><b>BID</b></td>
		<td><b>Document</b></td>
		<td><b>y</b></td>
		<td><b>h</b></td>
	</tr>
	<?php while ($obj = mysql_fetch_object($detail)) {?>
	<tr align="center">
		<td><a href="curate_seg_detail.php?segid=<?=$obj->segmentation_id?>"><?=$obj->segmentation_id?></a></td>
		<td><?=$obj->bid?></td>
		<td><?=$obj->doc_w?> x <b><?=$obj->doc_h?></b></td>
		<td><?=$obj->y?></td>
		<td><?=$obj->h?></td>
	</tr>
	<?}?>
</table>
<?}?>

<h3>Word count mismatch</h3>
<?php
$sql="SELECT segmentation.id as segid, segmentation.tdcount as tdcount, SUM( ".$table.".tcount ) AS scount FROM segmentation INNER JOIN ".$table." ON ".$table.".segmentation_id = segmentation.id GROUP BY segmentation.id having scount>tdcount";
$detail = mysql_query($sql,$link);
?>
<?
if (mysql_num_rows($detail)>0) {
?>
<i><?=mysql_num_rows($detail)?> blocks are in conflict</i>
<table border="1" width="100%">
	<tr align="center">
		<td><b>Segmentation ID</b></td>
		<td><b>tdcount</b></td>
		<td><b>scount</b></td>
	</tr>
	<?php while ($obj = mysql_fetch_object($detail)) {?>
	<tr align="center">
		<td><a href="curate_seg_detail.php?segid=<?=$obj->segid?>"><?=$obj->segid?></a></td>
		<td><?=$obj->tdcount?></td>
		<td><?=$obj->scount?></td>
	</tr>
	<?}?>
</table>
<?}?>


