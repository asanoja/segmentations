<?php include "../../conn.php";?>
<?php 
	$segid=$_GET["segid"];
	$sql = "select * from segmentation where id='".$segid."';";
	$master = mysql_query($sql,$link);
	$seg="";
	if ($seg = mysql_fetch_assoc($master)) {
	} else die("No results");
?>
<?php
	$zoom = 1;
	if (isset($_GET["zoom"])) $zoom = $_GET["zoom"];
	if (isset($_GET["docw"])) $docw = $_GET["docw"];
	if (isset($_GET["doch"])) $doch = $_GET["doch"];
	$docw = 100;
	$doch = 100;
?>
<html>
<head>
	<script src="../../js/rectlib.js"></script>
<script>
		
		var blocks = [	
		
		<?php
		$sql = "select * from ".$_GET["table"]." where segmentation_id='".$segid."';";
		$master = mysql_query($sql,$link);

		while ($b = mysql_fetch_assoc($master)) {
				//array_push($blocks,trim($b));
				//~ echo "[".$b["x"].",".$b["y"].",".($b["w"]).",".($b["h"]).",'".$b["bid"]."',".$b["doc_w"].",".$b["doc_h"].",".$b["ecount"]."],\n";
				echo "[".$b["nx"].",".$b["ny"].",".($b["nw"]).",".($b["nh"]).",'".$b["bid"]."',".$docw.",".$doch.",".$b["ecount"]."],\n";
		}
		?>
		];
		 
		function draw(blocks,win,border,fill) {
			var canvas = new rectObj();
			canvas.init(win,win.document);
			var pw = <?php echo $docw?>;
			var ph = <?php echo $doch?>;
			var nh,nw;
			var debug=parent.document.getElementById("debug");
			
			<?php
			//~ $curw = $seg['doc_w'];
			//~ $curh = $seg['doc_h'];
			$curw = $docw;
			$curh = $doch;
			?>
			
			
			if (<?=$curw?> < <?=$curh?>) {
				pw = solve(undefined, ph, <?=$curw?>, <?=$curh?>);
			} else {
				ph = solve(pw, undefined, <?=$curw?>, <?=$curh?>);
			}
			
			canvas.build(0,0,pw*<?=$zoom?>,ph*<?=$zoom?>,"2px dotted blue","transparent","","");
			
			var rect;
			for (var i=0;i<blocks.length;i++) {
				cont="";
				if (!border) border = "2px solid red";
				if (!fill) fill = "transparent";
				var seg = blocks[i];
				rect = canvas.build(seg[0]*<?=$zoom?>,seg[1]*<?=$zoom?>,(seg[2]-seg[0])*<?=$zoom?>,(seg[3]-seg[1])*<?=$zoom?>,border,fill,"<font size='-2'>"+seg[4]+"</font>",seg[4]);
				
				if (seg[5] < seg[6]) {
					nh = ph; //solve(undefined, nh, this.originalWidth, this.originalHeight);
					nw = solve(undefined, nh, seg[5], seg[6]);
				} else {
					nw = pw; //solve(undefined, nh, this.originalWidth, this.originalHeight);
					nh = solve(nw, undefined, seg[5], seg[6]);
				}
				
				rect.scale(nw,nh,seg[5],seg[6]);
				
				//~ if (debug)
					//~ debug.appendChild(document.createTextNode(seg[4]+": "+(seg[1]+"-"+seg[3])+", "+(rect.getRect().left+"-"+rect.getRect().height)+"\n"))
				//~ parent.drawings.push(rect);
				//console.log(blocks[i][4],nw,nh)
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
			draw(blocks,window,"","");
		}
		</script>
</head>
<body onload="drawpreview()">

</body>
</html>
