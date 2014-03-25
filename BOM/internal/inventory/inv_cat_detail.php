
<head>
<title>Web page segmentations inventory</title>
</head>
<?php include "../../conn.php";?>
<?
$category = $_GET["category"];
?>
<h1>Category: <?=$category;?></h1>

<table border="1" width="100%">
<tr align="center">
	<td><b>No.</b></td>
	<td><b>URL</b></td>
	<td colspan="1"><b>Num. Segmentations</b></td>
	<td colspan="1"><b>GT</b></td>
</tr>
<?php
$sql = "select url,count(url) as c from segmentation where category='".$category."' group by url order by c desc,url;";
$master = mysql_query($sql,$link);
$k=1;
while ($r = mysql_fetch_assoc($master)) {
?>
<?php
	$sql="select * from segmentation where url='".$r['url']."' and kind='GTdata'";
		$detail = mysql_query($sql);
		$count = mysql_num_rows($detail);
		$gt = $count>0;
		if ($gt) $color="#90EE90"; else $color="#FFC0CB";
	?>
<tr align="left" style="background-color:<?=$color?>">
	<td align="center"><?=$k?></td>
	<td><a href='inv_detail.php?url=<?php echo $r['url']?>'><?php echo $r['url']?></a></td>
	<td align="center"><a href='inv_detail.php?url=<?php echo $r['url']?>'><?php echo $r['c']?></a></td>
	
	<td align="center"><?php if ($gt) {echo "yes";} else {echo "no";}?></a></td>
	<?$k++;?>
</tr>
<?php
}
?>
</table>
