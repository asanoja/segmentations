<?php
if ($_POST["record"]) {
	$rec=$_POST["record"];
	$lines = explode("\n",$rec);
	echo "<pre>";
	
	$page="";
	$category="";
	$total=0;
	$source="";
	$meta="";
	$category ="";
	$blocks = Array();
	
	for ($i=0;$i<count($lines);$i++) {
		$arr = explode(",",$lines[$i]);
		if ($i==0) {
			$page = urldecode(trim($arr[3]));
			$total = count($lines);
			$source = $arr[0]."data";
			$meta = $arr[1]." ".$arr[4]."x".$arr[5];
			$category = $arr[2];
		}
		
		array_push($blocks,$arr[6].",".$arr[9].",".$arr[10].",".$arr[11].",".$arr[12]);
	}
	$par = "page=".$page."&category=".$category."&total=".$total."&source=".$source."&meta=".$meta;
	for ($i=0;$i<count($blocks);$i++) {
		$par = $par . "&block".($i+1)."=".$blocks[$i];
	}
	Header("Location:submit.php?".$par);
	exit;
}
?>

<form action="add.php" method="POST">
	<textarea name="record" cols="80" rows="20" id="record"></textarea>
	<input type="submit" value="send" name="sub">
</form>
