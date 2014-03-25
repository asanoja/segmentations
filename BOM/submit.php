<?php
class block {
	function __construct($record,$fullrecord) {
		if ($fullrecord) {
			//~ print_r($record);
			$this->id=$record[8];
			$this->x=$record[9];
			$this->y=$record[10];
			$this->w=$record[11];
			$this->h=$record[12];
			$this->ecount=$record[13];
			$this->wcount=$record[14];
		} else {
			$this->id=$record[0];
			$this->x=$record[1];
			$this->y=$record[2];
			$this->w=$record[3];
			$this->h=$record[4];
			$this->ecount=$record[6];
			$this->wcount=$record[7];
		}
	}
}
?>

<?php
$simulate = false;
//~ print_r($_REQUEST);

//~ $db = new mysqli('localhost', 'root', 'c2306hytu', 'bom');
$db = new mysqli('localhost', 'bom', 'dtwjshLHJwUERR7Q', 'bom');
$blocks = Array();

$name = "";
$page = "";
$category = "";
$total = 0;
$meta = "";
$granularity = 0;
$source = "";
$title = "";
$browser = "";
$collection = "GOSH";
$dw = 0;
$dh = 0;
$tdcount = 0;

if ($_POST["record"]) {
	echo "From record";
	$rec=$_POST["record"];
	$lines = explode("\n",$rec);
	
	$line ="";
	
	for ($i=0;$i<count($lines);$i++) {
		
		$line = trim(preg_replace('/\s+/', '', $lines[$i]));

		$arr = explode(",",$line);

		if (count($arr) > 1) {
			
			//~ print_r($arr);
			
			if ($i==0) {
				$page = urldecode(trim($arr[3]));
				$total = count($lines);
				$source = $arr[0]."data";
				$meta = $arr[1]." ".$arr[4]."x".$arr[5];
				$category = $arr[2];
				$granularity = $arr[7];
				$tdcount = $arr[6];
			}
			// (0)SEQ_ID,(1)X,(2)Y,(3)W,(4)H,(5)LOCAL_ALGO_ID,(6)COVER
			//$ee=$arr[8].",".$arr[9].",".$arr[10].",".$arr[11].",".$arr[12].",".$arr[13].",".$arr[14];
			array_push($blocks,new block($arr,true));

		}
	}
	//$par = "page=".$page."&category=".$category."&total=".$total."&source=".$source."&meta=".urlencode($meta)."&granularity=".$granularity;
	//~ for ($i=0;$i<count($blocks);$i++) {
		//~ $par = $par . "&block".($i+1)."=".$blocks[$i];
	//~ }
} else {
	echo "From parameters";
	$name = trim($_REQUEST['name']);
	$page = urldecode(trim($_REQUEST['page']));
	$category = trim($_REQUEST['category']);
	$total = intval(trim($_REQUEST['total']));
	$meta = trim($_REQUEST['meta']);
	$granularity = trim($_REQUEST['granularity']);
	$source = trim($_REQUEST['source']);
	$collection = trim($_REQUEST['collection']);
	$tdcount = trim($_REQUEST['tdcount']);
	$title = $page;
	
	
	for ($i=1;$i<=$total;$i++) {
		$b = $_REQUEST["block".$i];
		$dim = explode(",",$b);
		if (trim($dim[0])!="") {
			array_push($blocks,new block($dim,false));
			//echo "[".$dim[1].",".$dim[2].",".$dim[3].",".$dim[4].",'".$dim[0]."',".$dw.",".$dh.",".$dim[6]."]";
			//if ($i<$total) echo ",";
		}
	}
}

$pp = explode(" ",$meta);
$browser = $pp[0];
$dim = $pp[1];
$xdim = explode("x",$pp[1]);
$dw = $xdim[0];
$dh = $xdim[1];

if (substr($page, -1) === "/") {
	$page = substr($page,0,-1);
}

$stmt = $db->stmt_init();
$sql = "insert into segmentation(url,source1,source2,kind,granularity,browser,category,collection_id,doc_w,doc_h,tdcount,wprima) values('".$page."','".$_SERVER['REMOTE_ADDR']."','".$_SERVER['HTTP_X_FORWARDED_FOR']."','".$source."','".$granularity."','".$browser."','".$category."','".$collection."','".$dw."','".$dh."','".$tdcount."',?)";
if (!$simulate) {
	if($stmt->prepare($sql)) {
		 $stmt->bind_param('s', $wprima);
		 $wprima = $_REQUEST['wprimaobj'];
		 $stmt->execute();
		 $stmt->close();
	}
}

echo $mysqli->connect_errno;

if (!$simulate) $segmentation_id=$db->insert_id;

if ($source=="GTdata") {
	$table = "gt_blocks";
	$logo="logo_mob.png";
	$color="green";
}
if ($source=="BOMdata") {
	$table = "bom_blocks";
	$logo="logo_bom.png";
	$color="blue";
}
if ($source=="VIPSdata") {
	$table = "vips_blocks";
	$logo="logo_vips.png";
	$color="purple";
}
if ($source=="BFdata") {
	$table = "bf_blocks";
	$logo="logo_bf.png";
	$color="#C0C0C0";
}
if ($source=="JVIPSdata") {
	$table = "jvips_blocks";
	$logo="logo_jvips.png";
	$color="yellow";
}

?>
<html>
	<head>
		<title>Thanks for your submission</title>
		<script src="js/rectlib.js"></script>
		<script>
		
		var blocks = [	
		
		<?php
		for ($i=0;$i<=count($blocks);$i++) {
			$b = $blocks[$i];
			//~ $dim = explode(",",$b);
			if (trim($b->id)!="") {
				echo "[".$b->x.",".$b->y.",".$b->w.",".$b->h.",'".$b->id."',".$dw.",".$dh.",".$b->ecount.",".$b->wcount."],";
				//~ echo "[".$dim[1].",".$dim[2].",".$dim[3].",".$dim[4].",'".$dim[0]."',".$dw.",".$dh.",".$dim[6]."]";
				//~ if ($i<$total) echo ",";
			}
		}
		?>
		];
		 
		function draw(blocks,win,border,fill) {
			var canvas = new rectObj();
			canvas.init(win,win.document);
			var pw = 500;
			var ph = 500;
			var nh,nw;
			canvas.build(0,0,pw,ph,"2px dotted red","transparent","","");
			var rect;
			for (var i=0;i<blocks.length;i++) {
				cont="";
				if (!border) border = "2px solid red";
				if (!fill) fill = "<?php echo $color?>";
				var seg = blocks[i];
				rect = canvas.build(seg[0],seg[1],seg[2],seg[3],border,fill,seg[4],seg[4]);
				
				if (seg[5] < seg[6]) {
					nh = ph; //solve(undefined, nh, this.originalWidth, this.originalHeight);
					nw = solve(undefined, nh, seg[5], seg[6]);
				} else {
					nw = pw; //solve(undefined, nh, this.originalWidth, this.originalHeight);
					nh = solve(nw, undefined, seg[5], seg[6]);
				}
				
				rect.scale(nw,nh,seg[5],seg[6]);
				//~ parent.drawings.push(rect);
				console.log(blocks[i])
			}
		}
		
		function solve(width, height, numerator, denominator) {
			var value;
			
			// solve for width
			if ('undefined' !== typeof width) {
				value =  width / (numerator / denominator);
			}
			// solve for height
			else if ('undefined' !== typeof height) {
				value =  height * (numerator / denominator);
			}
			
			return value;
		}
		
		function drawpreview() {
			draw(blocks,document.getElementById('preview').contentWindow,"","");
		}
		</script>
		
	</head>
	<body onload="drawpreview()">
		<table width='100%'>
	<tr>
		<td><img src="images/<?=$logo?>" height='150'></td>
		<td><img src="images/logo_lip6.png" height='100'></td>
		<td><img src="images/LogoUPMC3.png" height='100'></td>
		<td><img src="images/SCAPE_logo_thumb.jpg" height='100'></td>
	</tr>
</table>
<?if ($simulate) {?>
<h1 style="color:red">Simulating. No change made</h1>
<?}?>
<h1>Thanks for your submission</h1>

Here the submission data:<br>
<ul>
<li><b>Collection</b>: <?=$collection?></li>
<li><b>Page</b>: <a href='<?=$page?>' target='new'><?=$page?></a></li>
<li><b>Source</b>:  <?=$source?></li>
<li><b>Blocks submited</b>: <?php echo count($blocks)?></li>
<li><b>Browser</b>: <?php echo $browser?></li>
<li><b>Document geometry</b>: <?php echo $dw?>x<?php echo $dh?></li>
<li><b>Granularity</b>: <?php echo $granularity?></li>
<li><b>Total words</b>: <?php echo $tdcount?></li>
<table width="100%"><tr valign="top"><td>
<table border=1>
	<tr align="center"><td></td><td><b>Block ID</b></td><td><b>Block geometry</b></td><td><b>Inner Elem.</b></td><td><b>Word count</b></td></tr>
<?php
	
for ($i=0;$i<count($blocks);$i++) {
	//~ echo $i."-".$blocks[$i]."<br>";
	//~ $dim = explode(",",$blocks[$i]);
	$b = $blocks[$i];
	//print_r($b);
	$id = $b->id;
	//~ if (trim($id)!="")  {
		$left = $b->x;
		$top = $b->y;
		$width = $left+$b->w;
		$height = $top+$b->h;
		$cover = $b->ecount;
		$tcover = $b->wcount;
		if ($cover==0) $cover=1;
		$sql = "insert into ".$table."(doc_w,doc_h,bid,x,y,w,h,segmentation_id,ecount,tcount) values('".$dw."','".$dh."','".$id."','".$left."','".$top."','".$width."','".$height."',".$segmentation_id.",".$cover.",".$tcover.")";
		echo  "<tr align='center'><td>".($i+1)."</td><td>" . $id . "</td><td>" . number_format((float)$left, 2, '.', '') . ", " . number_format((float)$top, 2, '.', '') . ", " . number_format((float)$width, 2, '.', '') . ", " . number_format((float)$height, 2, '.', '') . "</td><td>".$cover."</td><td>".$tcover."</td></tr>";
		if (!$simulate) $db->query($sql);
	//~ }
}

?>

</table>
</td><td>
</ul>
<b>Preview:<br></b>
<?if ($source!="VIPSdata"){?>
<iframe id="preview" name="preview" src="" style="width:510px;height:510px;border:0"/>
<?}?>
</td></tr></table>
</body>
</html>
<?php 
$db->close();
include "internal/inventory/uniform.php";
?>
