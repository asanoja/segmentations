<head>
<title>Web page segmentations inventory</title>
</head>
<?php include "../../conn.php";?>

<h1>Web page segmentation Datasets</h1>

<table border="1" width="100%">
<tr align="center">
	<td align='center'><b>Collection ID</b></td>
	<td align='center'><b>Collection Name</b></td>
	<td colspan="1"><b>Num. Categories</b></td>
</tr>
<?php
$sql= "SELECT * from `collection` order by name;";
$master = mysql_query($sql,$link);
while ($r = mysql_fetch_assoc($master)) {
?>
<tr align="left">
	<td align='center'><a href='inventory_cat.php?collection_id=<?php echo $r['id']?>'><?php echo $r['id']?></a></td>
	<td align='center'><a href='inventory_cat.php?collection_id=<?php echo $r['id']?>'><?php echo $r['name']?></a></td>
	<?php
	$sql="select distinct category from segmentation where collection_id='".$r["id"]."'";
	$detail = mysql_query($sql);
	$count = mysql_num_rows($detail);
	if ($det = mysql_fetch_assoc($detail)) {} else die("no segmentation found");
	?>
	<td align="center"><a href='inventory_cat.php?collection_id=<?php echo $r['id']?>'><?php echo $count?></a></td>
</tr>
<?php
}
?>
</table>
