<?php
echo "<pre>";
// (0)ALGORITHM,(1)BROWSER,(2)CATEGORY,(3)URL,(4)DOCW,(5)DOCH,(6)GRAN,(7)BID,(8)BX,(9)BY,(10)BW,(11)BH,(12)COUNTELEM
//~ print_r($_POST);
//~ if ($_POST["record"]) {
	//~ $rec=$_POST["record"];
	//~ $lines = explode("\n",$rec);
	//~ 
	//~ $page="";
	//~ $category="";
	//~ $total=0;
	//~ $source="";
	//~ $meta="";
	//~ $category ="";
	//~ $blocks = Array();
	//~ $cover = 0;
	//~ $granularity = 0;
	//~ $line ="";
	//~ 
	//~ for ($i=0;$i<count($lines);$i++) {
		//~ 
		//~ $line = trim(preg_replace('/\s+/', '', $lines[$i]));
//~ 
		//~ $arr = explode(",",$line);
//~ 
		//~ if (count($arr) > 1) {
			//~ 
			//~ print_r($arr);
			//~ 
			//~ if ($i==0) {
				//~ $page = urldecode(trim($arr[3]));
				//~ $total = count($lines);
				//~ $source = $arr[0]."data";
				//~ $meta = $arr[1]." ".$arr[4]."x".$arr[5];
				//~ $category = $arr[2];
				//~ $granularity = $arr[6];
				//~ $count = $arr[12];
			//~ }
			//~ // (0)SEQ_ID,(1)X,(2)Y,(3)W,(4)H,(5)LOCAL_ALGO_ID,(6)COVER
			//~ 
			//~ array_push($blocks,$arr[7].",".$arr[8].",".$arr[9].",".$arr[10].",".$arr[11].",".$arr[7].",".$arr[12]);
//~ 
		//~ }
	//~ }
	//~ $par = "page=".$page."&category=".$category."&total=".$total."&source=".$source."&meta=".urlencode($meta)."&granularity=".$granularity;
	//~ for ($i=0;$i<count($blocks);$i++) {
		//~ $par = $par . "&block".($i+1)."=".$blocks[$i];
	//~ }
	//~ 
	//~ Header("Location:submit.php?".$par);
//~ 
	//~ exit;
//~ }
//~ echo "</pre>";
?>

<form action="submit.php" method="POST" id="forma">
	<textarea name="record" cols="120" rows="20" id="record"></textarea>
	<input type="submit" value="send" name="sub">
</form>
