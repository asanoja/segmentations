<?php include "../../conn.php";?>
<?php
$url = $_GET["url"];
?>
<h1>Curation of Documents</h1>
<h2>URL: <a target="_blank" href="<?=$url?>"><?=$url?></a></h2>
<a href="curate_doc.php?>">Back</a>

<form action="histogram.php" method="get" target="_blank" id="forma">
	<input type="hidden" name="collection_id" value="GOSH">
<table border="1" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<?php
		$sql = "select algorithms.id algo,browsers.short_name as browser from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id  inner join browsers on browsers.id=algo_browser.browser_id where browsers.active=1 order by algorithms.ord asc";
		$ralgo = mysql_query($sql,$link);
		while ($r = mysql_fetch_object($ralgo)) {?>
			<td><b><?=$r->algo?>@<?=$r->browser?></b></td>
		<?}?>
	</tr>
	<tr>
		<?
		$sql = "select algorithms.id algo,browsers.short_name as browser from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id  inner join browsers on browsers.id=algo_browser.browser_id where browsers.active=1 order by algorithms.ord asc";
		$ralgo = mysql_query($sql,$link);
		while ($r = mysql_fetch_assoc($ralgo)) {
			$s="";
			$sty="";
			$sql = "select * from segmentation where url='".$url."' and kind='".$r['algo']."data' and browser='".$r['browser']."'";
			$rdet = mysql_query($sql,$link);
			if ($det = mysql_fetch_object($rdet)) {
				$s="<iframe src=\"drawseg.php?segid=".$det->id."&table=blocks&zoom=2\" height='400'></iframe>";
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
		<td valign="top">
<?php
			$imagepath = "http://132.227.204.64:8000/";
			require_once("./lib/effectiveTLDs.inc.php");
			require_once("./lib/regDomain.inc.php");
			$purl = parse_url($url,PHP_URL_HOST);
			$host = trim(getRegisteredDomain($purl));
			$pos = strpos($host,".");
			$murl = str_replace("http://","",$url);
			$murl = str_replace("/","_",$murl);
			$murl = str_replace(":","_",$murl);
			$murl = str_replace("__","_",$murl);
			$isrc = "firefox_snapshot.png";
			$imagepath = $imagepath . substr($host,$pos+1) . "/" . substr($host,0,$pos) . "/" . $murl . "/" . $isrc;
		?>
		<a href="<?=$imagepath?>"><img src="<?=$imagepath?>" height="400"></a>
</td>
	</tr>
	<tr>
		<?
			$sql = "select algorithms.id algo,browsers.short_name as browser from algo_browser inner join algorithms on algorithms.id=algo_browser.algo_id  inner join browsers on browsers.id=algo_browser.browser_id where browsers.active=1 order by algorithms.ord asc";
			$ralgo = mysql_query($sql,$link);
			while ($r = mysql_fetch_assoc($ralgo)) {
				$s="";
				$sty="";
				$sql = "select * from segmentation where url='".$url."' and kind='".$r['algo']."data' and browser='".$r['browser']."'";
				$rdet = mysql_query($sql,$link);
				if ($det = mysql_fetch_object($rdet)) {?>
					<td align="center" style="<?=$sty?>">
					<input type="button" onclick="window.open('curate_seg_detail.php?segid=<?=$det->id?>','_self')" value="Open"><br>
					<input type="checkbox" name="segsel[]" value="<?=$det->id?>">
					<?
					$algo = strtolower(str_replace("data","",$det->kind));
					$table = $algo."_blocks";
					$browser = $det->browser;
					?>
						seg.<?=$algo?>.<?=$browser?>.<?=$det->id?><br>
						<?=$det->doc_w."x".$det->doc_h?><br>
						<a href="curate_solve.php?op=DOCRESIZE&url=<?=$det->url?>&docw=<?=$det->doc_w?>&doch=<?=$det->doc_h?>">Take this geometry as standard </a><br>
						<a href="curate_solve.php?op=SHIFTLEFT&url=<?=$det->url?>">Push blocks left</a><br>
						<a href="#" onclick="location.href='curate_solve.php?op=COPYSEG&segid=<?=$det->id?>&target='+prompt('Copy to:','BOMdata')+'&url=<?=$det->url?>';">Copy</a><br>
						<a href="curate_solve.php?op=DELETESEG&segid=<?=$det->id?>&url=<?=$det->url?>" onclick="return confirm('Delete segmentation <?=$det->id?>')">Delete</a><br>
					</td>
				<?} else {
					echo "<td style='background-color : #BFBFBF;'></td>";
				} 	
		}?>
	</tr>
</table>
<center>
	<input type="submit" name="mode" value="HistogramX">
	<input type="submit" name="mode" value="HistogramY">
	<input type="reset" value="Reset"></center>
</form>
