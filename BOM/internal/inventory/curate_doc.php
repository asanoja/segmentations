<?php include "../../conn.php";?>
<?php
$algoid = $_GET["algoid"];
$kind = $algoid."data";
$category = $_GET["category"];
$table = strtolower($algoid."_blocks");
$where="";
if (isset($category) && $category!="") {$where=" where category='".$category."' ";}
?>
<h1>Inventory Documents Curation</h1>

<form action="curate_doc.php" method="GET">
	Category: <select name="category">
		<option value="">--all--</option>
		<?php
			$sql = "select distinct category from segmentation order by category";
			$rq = mysql_query($sql,$link);
			while ($r = mysql_fetch_assoc($rq)) {
				if ($r['category'] == $_GET['category']) {$sel=" selected";} else {$sel="";}
				?>
				<option name="<?=$r['category']?>" <?=$sel?>><?=$r['category']?></option>
			<?}
		?>
	</select>
<input type="submit" name="dale" value="Filter">
</form>
<a href="curate.php">Back</a>

<table border="1" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td>&nbsp;</td>
		<td><b>URL/Category</b></td>
		<?php
		$sql = "select algorithms.id algo,browsers.short_name as browser from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id  inner join browsers on browsers.id=algo_browser.browser_id where browsers.active=1 order by algorithms.ord asc";
		$ralgo = mysql_query($sql,$link);
		while ($r = mysql_fetch_object($ralgo)) {?>
			<td><b><?=$r->algo?>@<?=$r->browser?></b></td>
		<?}?>
	</tr>
	<?php
		$sql = "select url,category,count(kind) as c from segmentation ".$where." group by url,category order by c desc,category,url "; //esto debe ser normalizado en una table pages
		$rmain = mysql_query($sql,$link);
		$k=1;
		while ($main = mysql_fetch_assoc($rmain)) {?>
			<tr>
				<td><?=$k?></td>
				<?$k++;?>
				<td style='font-size:12px' width="20%">
					<a href="curate_doc_detail.php?url=<?=$main['url']?>">
						<?=$main['url']?>
					</a>
					<br>
					<?=$main['category']?>
				</td>
			<?php
				$sql = "select algorithms.id algo,browsers.short_name as browser from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id  inner join browsers on browsers.id=algo_browser.browser_id  where browsers.active=1  order by algorithms.ord asc";
				$ralgo = mysql_query($sql,$link);
				while ($r = mysql_fetch_assoc($ralgo)) {
					if (isset($category)) {$catwhere=" and category='".$category."'";} else {$catwhere="";}
					$sql = "select * from segmentation where url='".$main['url']."' and kind='".$r['algo']."data' and browser='".$r['browser']."' ".$catwhere;
					$rdet = mysql_query($sql,$link);
					$sty="";
					$s="";
					if ($det = mysql_fetch_object($rdet)) {
						$sql="select count(id) as c from ".strtolower($r['algo'])."_blocks where segmentation_id=".$det->id;
						$cbr = mysql_query($sql,$link);
						if ($cb = mysql_fetch_assoc($cbr)) {
							$s=$s . number_format($det->doc_w, 2, ',', '.');
							$s = $s ." x ";
							$s = $s . number_format($det->doc_h, 2, ',', '.') . "<br>";
							//$s = $s . $det->browser.$det->kind;
							$s = $s . "<a href='curate_seg_detail.php?segid=".$det->id."'>".$cb["c"]." blocks</a>";
							$sty=$sty."background-color : #9EE488;";
						} else {
							$sty=$sty."background-color : #BFBFBF;";
						}
					} else {
						$sty=$sty."background-color : #BFBFBF;";
					}
			?>
					<td align="center" style="<?=$sty?>">
						<?if ($s!="") {?>
							<?=$s?>
						<?} else {?>
							&nbsp;
						<?}?>
					</td>
				<?}?>
			</tr>
		<?}?>
	
</table>
