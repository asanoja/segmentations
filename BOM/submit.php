<?php
//~ print_r($_REQUEST);

$db = new mysqli('localhost', 'bom', 'dtwjshLHJwUERR7Q', 'bom');

$blocks = Array();
$name = trim($_REQUEST['name']);
$page = urldecode(trim($_REQUEST['page']));
$category = trim($_REQUEST['category']);
$total = intval(trim($_REQUEST['total']));
$meta = trim($_REQUEST['meta']);
$granularity = trim($_REQUEST['granularity']);
$source = trim($_REQUEST['source']);
$title = $page;
$pp = explode(" ",$meta);
$browser = $pp[0];
$dim = $pp[1];
$xdim = explode("x",$pp[1]);
$dw = $xdim[0];
$dh = $xdim[1];

$stmt = $db->stmt_init();

if($stmt->prepare("insert into segmentation(url,source1,source2,kind,granularity,wprima) values('".$page."','".$_SERVER['REMOTE_ADDR']."','".$_SERVER['HTTP_X_FORWARDED_FOR']."','".$source."','".$granularity."',?)")) {
	 $stmt->bind_param('s', $wprima);
	 $wprima = $_REQUEST['wprimaobj'];
	 $stmt->execute();
	 //~ print_r($stmt);
	 $stmt->close();
}
echo $mysqli->connect_errno;

//~ mysql_query("insert into segmentation(url,source1,source2,kind) values('".$page."','".$_SERVER['REMOTE_ADDR']."','".$_SERVER['HTTP_X_FORWARDED_FOR']."','".$source."')",$link);
$segmentation_id=$db->insert_id;

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
		<script src="rectlib.js"></script>
		<script>
		
		var blocks = [	
		
		<?php
		for ($i=1;$i<=$total;$i++) {
			$b = $_REQUEST["block".$i];
			$dim = explode(",",$b);
			if (trim($b[0])!="") {
				array_push($blocks,trim($b));
				echo "[".$dim[1].",".$dim[2].",".$dim[3].",".$dim[4].",'".$dim[0]."',".$dw.",".$dh.",".$dim[6]."]";
				if ($i<$total) echo ",";
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
<h1>Thanks for your submission</h1>

Here the submission data:<br>
<ul>
<li><b>Page</b>: <a href='<?=$page?>' target='new'><?=$page?></a></li>
<li><b>Source</b>:  <?=$source?></li>
<li><b>Blocks submited</b>: <?php echo count($blocks)?></li>
<li><b>Browser</b>: <?php echo $browser?></li>
<li><b>Document geometry</b>: <?php echo $dw?>x<?php echo $dh?></li>
<li><b>Granularity</b>: <?php echo $granularity?></li>
<table width="100%"><tr valign="top"><td>
<table border=1>
	<tr align="center"><td></td><td><b>Block ID</b></td><td><b>Block geometry</b></td><td><b>Inner Elem.</b></td></tr>
<?php
	

//$filename = "/web/sanojaa/public_html/BOM/data/".$source.".db";

//$data = new SQLite3($filename);

for ($i=0;$i<count($blocks);$i++) {
	//~ echo $i."-".$blocks[$i]."<br>";
	$dim = explode(",",$blocks[$i]);
	//~ print_r($dim);
	$id = $dim[0];
	if (trim($id)!="")  {
		$left = $dim[1];
		$top = $dim[2];
		$width = $left+$dim[3];
		$height = $top+$dim[4];
		$cover = $dim[6];
		$sql = "insert into ".$table."(browser,category,url,doc_w,doc_h,bid,block_x,block_y,block_w,block_h,segmentation_id,ecount) values('".$browser."','".$category."','".$page."','".$dw."','".$dh."','".$id."','".$left."','".$top."','".$width."','".$height."',".$segmentation_id.",".$cover.")";
		echo  "<tr align='center'><td>".($i+1)."</td><td>" . $id . "</td><td>" . number_format((float)$left, 2, '.', '') . ", " . number_format((float)$top, 2, '.', '') . ", " . number_format((float)$width, 2, '.', '') . ", " . number_format((float)$height, 2, '.', '') . "</td><td>".$cover."</td></tr>";
		//~ $result = mysql_query($sql);
		$db->query($sql);
	}
}

//~ $data->close();





?>

</table>
</td><td>
</ul>
<b>Preview:<br></b>
<iframe id="preview" name="preview" src="" style="width:510px;height:510px;border:0"/>
</td></tr></table>
</body>
</html>
<?php 
//~ mysql_close($link);
$db->close();
