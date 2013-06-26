<html>
<?php
$name = $_POST['name'];
$page = urldecode($_POST['page']);
$total = intval($_POST['total']);
$title = $page;
$meta = $_POST['meta'];
$pp = explode(" ",$meta);
$browser = $pp[0];
$dim = $pp[1];
$xdim = explode("x",$pp[1]);
$dw = $xdim[0];
$dh = $xdim[1];

$blocks = Array();

for ($i=1;$i<=$total;$i++) {
	array_push($blocks,$_POST["block".$i]);
}

$category = $_POST['category'];
//$file = $name.",".str_replace("/",'_',str_replace("http://",'',$page)).".txt";
$file = $browser."_".str_replace("/",'_',str_replace("http://",'',(str_replace(".","_",$page).".xml")));


$xml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\" ?>\n";
$xml .= "<XML>\n";
$xml .= "<Document url=\"".$page."\" Title=\"".$title."\" Version=\"\" Pos=\"WindowWidth||PageRectLeft:0 WindowHeight||PageRectTop:0 ObjectRectWith:".$dw." ObjectRectHeight:".$dh."\">\n";
$i=1;
foreach($blocks as $block) {
	$data = explode(",",$block);
	$xml .= "<Block Ref=\"Block".($i++)."\" internal_id=\"\" ID=\"\" Pos=\"WindowWidth||PageRectLeft:".$data[1]." WindowHeight||PageRectTop:".$data[2]." ObjectRectWidth:".$data[3]." ObjectRectHeight:".$data[4]."\" Doc=\"0.6\">\n";
	$xml .= "<weight>0</weight>\n";
	$xml .= "<Paths><path>".$block."</path></Paths>\n";
	$xml .= "<Links ID=\"\" IDList=\"\"></Links>\n";
	$xml .= "<Imgs ID=\"\" IDList=\"\"></Imgs>\n";
	$xml .= "<Txts ID=\"\" Txt=\"\"/>\n";
	$xml .= "</Block>\n";
}
$xml .= "</Document>\n";
$xml .= "</XML>\n";

$postdata = http_build_query(
    array(
        'url' => $page,
        'browser' => $browser,
        'fn' => $file,
        'category' => $category,
        'cont' => urlencode($xml)
    )
);

$opts = array('http' =>
    array(
        'method'  => 'POST',
        'header'  => 'Content-type: application/x-www-form-urlencoded',
        'content' => $postdata
    )
);

$context  = stream_context_create($opts);

$res = file_get_contents('http://132.227.204.64:8081/plmanual/save.php', false, $context);


//$res = file_get_contents("http://132.227.204.64:8081/plmanual/save.php?url=".$page."&browser=".$browser."&fn=".$file."&category=".$category."&cont=".urlencode($xml));
echo "The server responded: [".$res."]<br>";
if ($res=="OK") {
?>
<head>
<script src="../bom/js/jquery-1.9.1.js"></script>
<script>
function carga() {
	console.log("iniciando");
	document.getElementById("dump").innerHTML = "But wait!!! don't close yet... I'm capturing the page version you evaluated"
	$.ajax({
					type: "GET",
					url : "../bom/call_bom.php",
					data: "cmd=capture&purl=<?=$page?>&browser=<?=$browser?>&granularity=<?=$granularity?>",
					dataType: "text",
					success : function(data) {
						console.log("return "+data);
						code = data.split(":")[0]
						time = data.split(":")[1]
						if (code=="OK") {
							document.getElementById("dump").innerHTML = "captured!!! merci"
						}
					}
			});
}
window.onload = carga;
</script>
</head>
<body>
<h1>Hi, <?=$name?> </h1>

<h2>Thanks for submiting!. It is very much preciated for our research</h2>
<h1 id="dump"></h1>
This is the information submitted:<br>

Page: <?=$page?><br>
Category: <?=$category?><br>
File: <?=$fn?>

<!--
<ul>
	<?php foreach($blocks as $block) {?>
	<li><?=$block?></li>
	<?}?>
</ul>
-->
<?php
echo "<textarea style='width:100%;height:50%'>";
echo htmlentities($xml);
echo "</textarea>";
?>

Here, get a free coffee<br>
<img src='http://www.longbeachstuff.com/wp-content/uploads/2012/11/coffee.jpg' width='200'>
<?
} else {
	echo "Connection to internal server not possible. I'm sorry could not save it";

}

?><br>

</body>
</html>
