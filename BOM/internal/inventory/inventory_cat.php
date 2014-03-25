<head>
<title>Web page segmentations inventory</title>
</head>
<?php include "../../conn.php";?>

<h1>Web page segmentation repository</h1>

<table border="1" width="100%">
<tr align="center">
	<td align='center'><b>Category</b></td>
	<td colspan="1"><b>Num. Urls</b></td>
</tr>
<?php
$colid = $_GET["collection_id"];
$sql= "SELECT category FROM `segmentation` where collection_id='".$colid."' group by category order by category;";
$master = mysql_query($sql,$link);
while ($r = mysql_fetch_assoc($master)) {
?>
<tr align="left">
	<td align='center'><a href='inv_cat_detail.php?category=<?php echo $r['category']?>'><?php echo strtoupper($r['category']);?></a></td>
	<?php
		$sql="select distinct url from segmentation where collection_id='".$colid."' and category='".$r['category']."'";
		$detail = mysql_query($sql);
		$count = mysql_num_rows($detail);
		if ($det = mysql_fetch_assoc($detail)) {} else die("no urls found");
	?>
	<td align="center"><a href='inv_cat_detail.php?category=<?php echo $r['category']?>'><?php echo $count?></a></td>
</tr>
<?php
}
?>
</table>
