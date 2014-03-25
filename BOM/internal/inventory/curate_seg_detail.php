<style>
.conflict {background-color:red}
</style>
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

$sql = "select max(h) as mh from ".$table." where segmentation_id='".$segid."' limit 1;";
$maxh = mysql_query($sql,$link);
if ($rh = mysql_fetch_assoc($maxh)) {
} else die("Ooops rh");

$sql = "select max(w) as mw from ".$table." where segmentation_id='".$segid."' limit 1;";
$maxw = mysql_query($sql,$link);
if ($rw = mysql_fetch_assoc($maxw)) {
} else die("Ooops rw");
?>
<?php
$hdiff = $rw['mw']-$meta['doc_w']>0;
$vdiff = $rh['mh']-$meta['doc_h']>0;
?>
<h1>Curation for SEG-<?php echo $segid;?>::<?php echo strtoupper($algo)?>/<?php echo $browser?> </h1>
<h2>URL: <a target="_blank" href="<?php echo $seg['url']?>"><?php echo $seg['url']?></a></h2>

<input type="button" value="Segmentation list" onclick="window.open('curate_doc.php','_self')">
<input type="button" value="Algorithm errors" onclick="window.open('curate_algo.php?algoid=<?=strtoupper($algo)?>','_self')">
<input type="button" value="See all segmentations" onclick="window.open('curate_doc_detail.php?url=<?=$seg['url']?>','_self')"><br>


<table border="1" width="100%">
	<tr valign="top">
		<td>
			<b>Algorithm:</b> <?php echo $seg['kind']?><br>
			<b>Browser:</b> <?php echo $seg['browser']?><br>
			<b>Geometry:</b> <?php echo $meta['doc_w']?>x<?php echo $meta['doc_h']?><br>
			<b>Category:</b> <?php echo $seg['category']?><br>
			<b>Granularity:</b> <?php echo $seg['granularity']?><br>
			<b>Word Count:</b> <?php echo $seg['tdcount']?><br>
			<b>Taken:</b> <?php echo $seg['ts']?><br>
			<b>From:</b> <?php echo $seg['source1']?> <?php echo $seg['source2']?><br>
		</td>
		<td>
			<b>Max Blocks Width:</b> <?php echo $rw['mw'];?><br>
			<b>Max Blocks Height:</b> <?php echo $rh['mh'];?><br>
			<?if ($hdiff) {?><b style="background-color:red">Horizontal Diff:</b> <?php echo $rw['mw']-$meta['doc_w'];?><br><?}?>
			<?if ($vdiff) {?><b style="background-color:red">Vertical Diff:</b> <?php echo $rh['mh']-$meta['doc_h'];?><br><?}?>
		</td>
		<td>
			<b>Possible actions:</b><br><ul>
			
			<?php if ($hdiff) {?> <li><a href="curate_solve.php?segid=<?=$seg['id']?>&op=MAXW" onclick="return confirm('Do you want to set document height to <?=$rh['mh']?>?')">Set document WIDTH to <?=$rw['mw']?></a></li><?}?>
			<?php if ($vdiff) {?> <li><a href="curate_solve.php?segid=<?=$seg['id']?>&op=MAXH" onclick="return confirm('Do you want to set document height to <?=$rw['mw']?>?')">Set document HEIGHT to <?=$rh['mh']?></a></li><?}?>
			<li><a href="curate_solve.php?op=ADJUSTCONTENT&segid=<?=$seg['id']?>">Adjust document to content</a></li>
			<li><a href="curate_solve.php?op=ADJUSTCONTENTWIDTH&segid=<?=$seg['id']?>">Adjust document WIDTH to content</a></li>
			<li><a href="curate_solve.php?op=ADJUSTCONTENTHEIGHT&segid=<?=$seg['id']?>">Adjust document HEIGHT to content</a></li>
			<li><a href="#table">Explore and delete blocks in conflict</a></li>
			</ul>
		</td>
	</tr>
</table>
<hr>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr align="center" valign="top">
		<td>
			<iframe id="segpreview" src="drawseg.php?segid=<?=$segid?>&table=<?=$table?>&zoom=4" style='width:800;height:450'></iframe>
		</td>
		<td align="left">
			Zoom:
			<select name="zoom" onclick="document.getElementById('segpreview').src='drawseg.php?segid=<?=$segid?>&table=<?=$table?>&zoom='+this.value">
					<option value="1">100%</option>
					<option value="2">150%</option>
					<option value="3">200%</option>
					<option value="4">250%</option>
					<option value="5">300%</option>
					<option value="6">350%</option>
					<option value="7">400%</option>
					<option value="8">450%</option>
					<option value="9">500%</option>
			</select>
		</td>
		<td>
		<?php
			$imagepath = "http://132.227.204.64:8000/";
			require_once("./lib/effectiveTLDs.inc.php");
			require_once("./lib/regDomain.inc.php");
			$url = parse_url($seg['url'],PHP_URL_HOST);
			$host = trim(getRegisteredDomain($url));
			$pos = strpos($host,".");
			$murl = str_replace("http://","",$seg['url']);
			$murl = str_replace("/","_",$murl);
			$murl = str_replace(":","_",$murl);
			$murl = str_replace("__","_",$murl);
			$isrc = "firefox_snapshot.png";
			$imagepath = $imagepath . substr($host,$pos+1) . "/" . substr($host,0,$pos) . "/" . $murl . "/" . $isrc;
		?>
		<a href="<?=$imagepath?>" target="_blank"><img src="<?=$imagepath?>" height="400"></a>
		</td>
	</tr>
</table>
<hr>
<a name="table"></a>
<form action="curate_solve.php">
<input type="hidden" name="segid" value="<?=$segid?>"> 
<input type="submit" name="op" value="MERGE"> | 
<input type="submit" name="op" value="MOVELEFT">
<input type="submit" name="op" value="MOVERIGHT">
<input type="submit" name="op" value="MOVETOP">
<input type="submit" name="op" value="MOVEBOTTOM">
Desp:<input type="text" size="1" name="q" id="q" value="1"> | 
<input type="submit" name="op" value="SHIFTLEFTSEG">
<input type="submit" name="op" value="SHIFTTOPSEG">

<table border="1" width="100%">
<tr align="center">
	<td rowspan="2"><b>&nbsp;</b></td>
	<td rowspan="2"><b>BId</b></td>
	<td rowspan="2"><b>Document</b></td>
	<td colspan="4"><b>Block geometry</b></td>
	<td colspan="1" rowspan="2"><b>Norm. Gran.</b></td>
	<td rowspan="2"><b>Cover</b></td>
	<td rowspan="2" colspan="2"><b>Word Count</b></td>
	<td colspan="1" rowspan="2"><b>Ops</b></td>
</tr>
<tr>
<td align="center"><b>x</b></td>
<td align="center"><b>y</b></td>
<td align="center"><b>right</b></td>
<td align="center"><b>bottom</b></td>
</tr>
<?php
$sql = "select * from ".$table." where segmentation_id='".$segid."' order by y asc;";
$detail = mysql_query($sql,$link);
$acum=0;
$acump=0;
while ($d = mysql_fetch_assoc($detail)) {
	$cont = 0;
	for ($i=0;$i<100;$i+=10) {
		if ($d['nw']>$i) $cont++;
	}
	$dw = $cont;
	$cont = 0;
	for ($i=0;$i<100;$i+=10) {
		if ($d['nh']>$i) $cont++;
	}
	$dh = $cont;
	
	$hypo1 = ($dw*$dh)*10/100;
?>
<tr align="center">
	<td><input type="checkbox" name="block[]" value="<?=$d['id']?>"></td>
	<td><?php echo $d['bid']?></td>
	<td><?php echo $d['doc_w']?>x<?php echo $d['doc_h']?></td>
	<td <?php if ($d['x']>$meta['doc_w'] || $d['x']<0) {echo " class='conflict' ";}?>><a href='#' onclick="location.href='curate_solve.php?op=EDIT&segid=<?=$seg['id']?>&bid=<?=$d['id']?>&field=x&value='+prompt('new X value','<?=$d['x']?>')"><?php echo number_format($d['x'], 2, '.', ',')?></a></td>
	<td <?php if ($d['y']>$meta['doc_h'] || $d['y']<0) {echo " class='conflict' ";}?>><a href='#' onclick="location.href='curate_solve.php?op=EDIT&segid=<?=$seg['id']?>&bid=<?=$d['id']?>&field=y&value='+prompt('new Y value','<?=$d['y']?>')"><?php echo number_format($d['y'], 2, '.', ',')?></a></td>
	<td <?php if ($d['w']>$meta['doc_w'] || $d['x']<0) {echo " class='conflict' ";}?>><a href='#' onclick="location.href='curate_solve.php?op=EDIT&segid=<?=$seg['id']?>&bid=<?=$d['id']?>&field=w&value='+prompt('new W value','<?=$d['w']?>')"><?php echo number_format($d['w'], 2, '.', ',')?></a></td>
	<td <?php if ($d['h']>$meta['doc_h'] || $d['y']<0) {echo " class='conflict' ";}?>><a href='#' onclick="location.href='curate_solve.php?op=EDIT&segid=<?=$seg['id']?>&bid=<?=$d['id']?>&field=h&value='+prompt('new H value','<?=$d['h']?>')"><?php echo number_format($d['h'], 2, '.', ',')?></a></td>
	<td><?=number_format(($hypo1), 2, '.', ',')?></td>
	<td><?php echo $d['ecount']?></td>
	<td><a href='#' onclick="location.href='curate_solve.php?op=EDIT&segid=<?=$seg['id']?>&bid=<?=$d['id']?>&field=tcount&value='+prompt('new tcount value','<?=$d['tcount']?>')"><?php echo $d['tcount']?></a></td>
	<td><?=number_format(($d['tcount']/$seg['tdcount']*100), 2, '.', ',')?>%</td>
	<?
		$acump+=$d['tcount']/$seg['tdcount']*100;
		$acum+=$d['tcount']
	?>
	<td>
		<a href="curate_solve.php?segid=<?=$seg['id']?>&op=DEL&bid=<?=$d['id']?>" onclick="return confirm('Delete the block <?=$d['bid']?>?')">delete</a>
	</td>
</tr>
<?php
}
?>
<tr align="center">
	<td colspan="9">&nbsp;</td>
	<td<?if ($acum>$seg['tdcount']){?> class='conflict'<?}?>><?=$acum?><?if ($acum>$seg['tdcount']) {?><br>+<?=$acum-$seg['tdcount']?><?}?></td>
	<td<?if ($acump>100){?> class='conflict'<?}?>><?=number_format($acump, 2, '.', ',')?>%<?if ($acump>100) {?><br>+<?=number_format($acump-100, 2, '.', ',')?>%<?}?></td>
	<td>&nbsp;</td>
</tr>
</table>
<input type="submit" name="op" value="DELETESEGDET" onclick="return confirm('Really want to delete this segmentation?')">
</form>
<a href="#">Top</a>
