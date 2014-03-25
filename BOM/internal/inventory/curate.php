<?php include "../../conn.php";?>
<h1>Inventory Curation</h1>

<h2>Blocks curation</h2>
<?php
$sql="select * from algorithms order by ord";
$detail = mysql_query($sql);
if (mysql_num_rows($detail)>0) {
?>
<i><?=mysql_num_rows($detail)?> algorithms</i>
<table border="1" width="100%">
	<tr align="center">
		<td><b>ID</b></td>
		<td><b>Name</b></td>
		<td colspan="2"><b>Curate</b></td>
	</tr>
	<?php while ($obj = mysql_fetch_object($detail)) {?>
	<tr align="center">
		<td><?=$obj->id?></td>
		<td><?=$obj->name?></td>
		<td><input type="button" onclick="location.href='curate_algo.php?algoid=<?=$obj->id?>'" value='Go'></td>
	</tr>
	<?}?>
</table>
<?}?>
<h2>Documents curation</h2>
<input type="button" onclick="location.href='curate_doc.php'" value='Go'>
