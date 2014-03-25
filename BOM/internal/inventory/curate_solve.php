<?php include "../../conn.php";?>
<?php include "lib/curate_util.php";?>
<?php
$segid = $_GET["segid"];
$op = $_GET["op"];

if (isset($_GET["segid"])) {
	$main = mysql_query("select kind from segmentation where id=".$segid);
	if ($mdata = mysql_fetch_assoc($main)) {} else die("No segmentation");
	$algo = strtolower(str_replace("data","",$mdata['kind']));
	$table = $algo."_blocks";
}

if ($op == "MAXH") {
	$sql = "select max(h) as mh from ".$table." where segmentation_id='".$segid."';";
	$maxh = mysql_query($sql,$link);
	if ($rh = mysql_fetch_assoc($maxh)) {} else die("Ooops mh");
	$mh = $rh['mh'];
	$sql = "update ".$table." set doc_h='".$mh."' where segmentation_id=".$segid;
	mysql_query($sql,$link);
	$sql = "update segmentation set doc_h='".$mh."' where id=".$segid;
	mysql_query($sql,$link);
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "MAXW") {
	$sql = "select max(w) as mw from ".$table." where segmentation_id='".$segid."';";
	$maxw = mysql_query($sql,$link);
	if ($rw = mysql_fetch_assoc($maxw)) {} else die("Ooops mw");
	$mw = $rw['mw'];
	$sql = "update ".$table." set doc_w='".$mw."' where segmentation_id=".$segid;
	mysql_query($sql,$link);
	$sql = "update segmentation set doc_w='".$mw."' where id=".$segid;
	mysql_query($sql,$link);
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "DEL") {
	$bid = $_GET["bid"];
	mysql_query("delete from ".$table." where id=".$bid);
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "EDIT") {
	$bid = $_GET["bid"];
	$value = $_GET["value"];
	$field = $_GET["field"];
	$sql="update ".$table." set ".$field."=".$value." where id=".$bid." and segmentation_id=".$segid;
	mysql_query($sql,$link);
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "DOCRESIZE") {
	$url = $_GET['url'];
	$docw = $_GET['docw'];
	$doch = $_GET['doch'];
	$sql = "select * from segmentation where url='".$url."'";
	$ra = mysql_query($sql,$link);
	while ($r = mysql_fetch_assoc($ra)) {
		$segid = $r["id"];
		$algo = strtolower(str_replace("data","",$r['kind']));
		$table = $algo."_blocks";
		$oldw = $r["doc_w"];
		$oldh = $r["doc_h"];
		
		$sql = "update segmentation set doc_w='".$docw."', doc_h='".$doch."' where id=".$segid;
		mysql_query($sql,$link);
		
		$sql = "select * from ".$table." where segmentation_id=".$segid;
		$rb = mysql_query($sql,$link);
		while ($b = mysql_fetch_assoc($rb)) {
			//~ echo "<pre>".$docw." ".$doch." ".$b['x']." ".$b['y']."</pre>";
			$x = $docw*$b['x'] / $oldw;
			$y = $doch*$b['y'] / $oldh;
			$w = $docw*$b['w'] / $oldw;
			$h = $doch*$b['h'] / $oldh;
			$sql = "update ".$table." set x=".$x.",y=".$y.",w=".$w.",h=".$h.",doc_w=".$docw.",doc_h=".$doch." where id=".$b['id'];
			mysql_query($sql);
		}
	}
	include "uniform.php";
	$goto = "curate_doc_detail.php?url=".$url;
}

if ($op=="ADJUSTCONTENT") {
	$sql = "select max(h) as mh from ".$table." where segmentation_id='".$segid."' limit 1;";
	$maxh = mysql_query($sql,$link);
	if ($rh = mysql_fetch_assoc($maxh)) {
	} else die("Ooops rh");

	$sql = "select max(w) as mw from ".$table." where segmentation_id='".$segid."' limit 1;";
	$maxw = mysql_query($sql,$link);
	if ($rw = mysql_fetch_assoc($maxw)) {
	} else die("Ooops rw");
	$sql = "update ".$table." set doc_w=".$rw['mw'].", doc_h=".$rh['mh']." where segmentation_id=".$segid;
	mysql_query($sql,$link);
	$sql = "update segmentation set doc_w=".$rw['mw'].", doc_h=".$rh['mh']." where id=".$segid;
	mysql_query($sql,$link);
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op=="ADJUSTCONTENTWIDTH") {
	$sql = "select max(w) as mw from ".$table." where segmentation_id='".$segid."' limit 1;";
	$maxw = mysql_query($sql,$link);
	if ($rw = mysql_fetch_assoc($maxw)) {
	} else die("Ooops rw");
	$sql = "update ".$table." set doc_w=".$rw['mw']." where segmentation_id=".$segid;
	mysql_query($sql,$link);
	$sql = "update segmentation set doc_w=".$rw['mw']." where id=".$segid;
	mysql_query($sql,$link);
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}
if ($op=="ADJUSTCONTENTHEIGHT") {
	$sql = "select max(h) as mh from ".$table." where segmentation_id='".$segid."' limit 1;";
	$maxh = mysql_query($sql,$link);
	if ($rh = mysql_fetch_assoc($maxh)) {
	} else die("Ooops rh");

	$sql = "update ".$table." set doc_h=".$rh['mh']." where segmentation_id=".$segid;
	mysql_query($sql,$link);
	$sql = "update segmentation set doc_h=".$rh['mh']." where id=".$segid;
	mysql_query($sql,$link);
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "SHIFTLEFT") {
	$url = $_GET['url'];
	$sql = "select * from segmentation where url='".$url."'";
	$ra = mysql_query($sql,$link);
	while ($seg = mysql_fetch_assoc($ra)) {
		$segid = $seg["id"];
		$algo = strtolower(str_replace("data","",$seg['kind']));
		$table = $algo."_blocks";
		$sql = "select min(x) as mx from ".$table." where segmentation_id=".$segid . " having mx>=0";		
		$rxdif = mysql_query($sql,$link);
		if ($xdif = mysql_fetch_assoc($rxdif)) {
			//~ $table . " ". $seg['browser'] ." ". $xdif['mx'];
			if ($xdif['mx']>0) {
				$sql = "update ".$table." set x=x-".$xdif['mx'].", w=w-".$xdif['mx']." where segmentation_id=".$segid;
				mysql_query($sql);
			}
		} else die("no min x");
	}
	include "uniform.php";
	$goto = "curate_doc_detail.php?url=".$url;
}

if ($op == "SHIFTTOP") {
	$url = $_GET['url'];
	$sql = "select * from segmentation where url='".$url."'";
	$ra = mysql_query($sql,$link);
	while ($seg = mysql_fetch_assoc($ra)) {
		$segid = $seg["id"];
		$algo = strtolower(str_replace("data","",$seg['kind']));
		$table = $algo."_blocks";
		$sql = "select min(y) as my from ".$table." where segmentation_id=".$segid . " having my>=0";		
		$rydif = mysql_query($sql,$link);
		if ($ydif = mysql_fetch_assoc($rydif)) {
			$table . " ". $seg['browser'] ." ". $ydif['my'];
			if ($xdif['my']>0) {
				$sql = "update ".$table." set y=y-".$ydif['my'].", h=h-".$ydif['my']." where segmentation_id=".$segid;
				mysql_query($sql);
			}
		} else die("no min y");
	}
	include "uniform.php";
	$goto = "curate_doc_detail.php?url=".$url;
}

if ($op=="MERGE") {
	$k=0;
	$segid = "";
	$pivot = array();
	$delist = array();
	foreach ($_GET['block'] as $block) {
		if ($k==0) {
			$pivot[0] = $block;
			$res = mysql_query("select * from blocks where id=".$block,$link);
			if ($r = mysql_fetch_assoc($res)) {
				$pivot[1] = $r['x'];
				$pivot[2] = $r['y'];
				$pivot[3] = $r['w'];
				$pivot[4] = $r['h'];
				$pivot[5] = $r['ecount'];
				$pivot[6] = $r['tcount'];
				$segid = $r['segmentation_id'];
			} else die("no pivot block ".$block);
		} else {
			array_push($delist,$block);
			$res = mysql_query("select * from blocks where id=".$block,$link);
			if ($r = mysql_fetch_assoc($res)) {
				$pivot[1] = min($pivot[1],$r["x"]);
				$pivot[2] = min($pivot[2],$r["y"]);
				$pivot[3] = max($pivot[3],$r["w"]);
				$pivot[4] = max($pivot[4],$r["h"]);
				$pivot[5] = $pivot[5] + $r["ecount"];
				$pivot[6] = $pivot[6] + $r["tcount"];
			} else die("no block ".$block);
		}
		//~ print_r($r);
		//~ echo "<br>";
		//~ print_r($pivot);
		//~ echo "<br>";
		$k=$k+1;
	}
	$main = mysql_query("select kind from segmentation where id=".$segid);
	if ($mdata = mysql_fetch_assoc($main)) {} else die("No segmentation");
	$algo = strtolower(str_replace("data","",$mdata['kind']));
	$table = $algo."_blocks";
	//~ print_r($pivot);
	$sql = "update ".$table." set x=".$pivot[1].",y=".$pivot[2].",w=".$pivot[3].",h=".$pivot[4].",ecount=".$pivot[5].",tcount=".$pivot[6]." where id=".$pivot[0];
	mysql_query($sql,$link);
	foreach ($delist as $id) {
		$sql="delete from ".$table." where id=".$id;
		mysql_query($sql,$link);
	}
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op=="MOVERIGHT") {
	$desp = $_GET['q'];
	foreach ($_GET['block'] as $block) {
		$sql = "update ".$table." set x=x+".$desp.",w=w+".$desp." where id=".$block;
		mysql_query($sql,$link);
	}
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}
if ($op=="MOVELEFT") {
	$desp = $_GET['q'];
	foreach ($_GET['block'] as $block) {
		$sql = "update ".$table." set x=x-".$desp.",w=w-".$desp." where id=".$block;
		mysql_query($sql,$link);
	}
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}
if ($op=="MOVETOP") {
	$desp = $_GET['q'];
	foreach ($_GET['block'] as $block) {
		$sql = "update ".$table." set y=y-".$desp.",h=h-".$desp." where id=".$block;
		mysql_query($sql,$link);
	}
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}
if ($op=="MOVEBOTTOM") {
	$desp = $_GET['q'];
	foreach ($_GET['block'] as $block) {
		$sql = "update ".$table." set y=y+".$desp.",h=h+".$desp." where id=".$block;
		mysql_query($sql,$link);
	}
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "SHIFTLEFTSEG") {
	$sql = "select min(x) as mx from ".$table." where segmentation_id=".$segid . " having mx>=0";		
	$rxdif = mysql_query($sql,$link);
	if ($xdif = mysql_fetch_assoc($rxdif)) {
		if ($xdif['mx']>0) {
			$sql = "update ".$table." set x=x-".$xdif['mx'].", w=w-".$xdif['mx']." where segmentation_id=".$segid;
			mysql_query($sql);
		}
	} else die("no min x");
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op == "SHIFTTOPSEG") {
	$sql = "select min(y) as my from ".$table." where segmentation_id=".$segid . " having my>=0";		
	$rxdif = mysql_query($sql,$link);
	if ($xdif = mysql_fetch_assoc($rxdif)) {
		if ($xdif['my']>0) {
			$sql = "update ".$table." set y=y-".$xdif['my'].", h=h-".$xdif['my']." where segmentation_id=".$segid;
			mysql_query($sql);
		}
	} else die("no min y");
	include "uniform.php";
	$goto = "curate_seg_detail.php?segid=".$segid;
}

if ($op=="COPYSEG") {
	if ($_GET['target']!='null' && isset($_GET['target'])) {
		$algo = strtolower(str_replace("data","",$_GET['target']));
		$ntable = $algo."_blocks";
		$sql="select * from segmentation where id=".$segid;
		$rs = mysql_query($sql,$link);
		if ($s =mysql_fetch_assoc($rs)) {
			$sql="insert into segmentation(url,source1,kind,granularity,category,browser,collection_id,doc_w,doc_h,tdcount) values('".$s['url']."','".$s['source1']."','".$_GET['target']."','".$s['granularity']."','".$s['category']."','".$s['browser']."','".$s['collection_id']."','".$s['doc_w']."','".$s['doc_h']."','".$s['tdcount']."')";
			mysql_query($sql,$link);
			$newsegid = mysql_insert_id();
			$sql="select * from ".$table." where segmentation_id=".$segid;
			$rb = mysql_query($sql,$link);
			while ($b = mysql_fetch_assoc($rb)) {
				$sql = "insert into ".$ntable."(doc_w,doc_h,bid,x,y,w,h,segmentation_id,ecount,tcount) values('".$b['doc_w']."','".$b['doc_h']."','".$b['bid']."','".$b['x']."','".$b['y']."','".$b['w']."','".$b['h']."','".$newsegid."','".$b['ecount']."','".$b['tcount']."')";
				mysql_query($sql,$link);
			}
		}
	} else die("No target");
	include "uniform.php";
	$goto = "curate_doc_detail.php?url=".$_GET["url"];
}
if ($op == "DELETESEG") {
	mysql_query("delete from segmentation where id=".$segid,$link);
	$goto = "curate_doc_detail.php?url=".$_GET["url"];
}
if ($op == "DELETESEGDET") {
	mysql_query("delete from segmentation where id=".$segid,$link);
	$goto = "curate_doc.php";
}
//~ if ($op == "NEWBLOCK") {
	//~ mysql_query("insert from segmentation where id=".$segid,$link);
	//~ $goto = "curate_doc_detail.php?url=".$_GET["url"];;
//~ }
Header("Location: ".$goto);
?>
