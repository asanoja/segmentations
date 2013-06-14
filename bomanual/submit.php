<?php
$name = $_POST['name'];
$page = urldecode($_POST['page']);
$total = intval($_POST['total']);
$meta = $_POST['meta'];
$pp = explode(" ",$meta);
$browser = $pp[0];
$dim = $pp[1];

$blocks = Array();

for ($i=1;$i<=$total;$i++) {
	array_push($blocks,$_POST["block".$i]);
}

$category = $_POST['category'];
//$file = $name.",".str_replace("/",'_',str_replace("http://",'',$page)).".txt";
$file = $browser."_".str_replace("/",'_',str_replace("http://",'',str_replace(".html",'.txt',$page)));


$cont = $name."\n";
$cont .= $category."\n";
$cont .= $page."\n";
$cont .= $meta."\n";
$cont .= $total."\n";
foreach($blocks as $block) {
	$cont .= $block."\n";
}
$res = file_get_contents("http://132.227.204.64:8081/plmanual/save.php?url=".$page."&browser=".$browser."&fn=".$file."&category=".$category."&cont=".urlencode($cont));
echo "--".$res."--";
if ($res=="OK") {
?>

<h1>Hi, <?=$name?> </h1>

<h2>Thanks for submiting!. It is very much preciated for our research</h2>

This is the information submitted:<br>

Page: <?=$page?><br>
Category: <?=$category?><br>
File: <?=$fn?>

<ul>
	<?php foreach($blocks as $block) {?>
	<li><?=$block?></li>
	<?}?>
</ul>

Here, get a free coffee<br>
<img src='http://www.longbeachstuff.com/wp-content/uploads/2012/11/coffee.jpg' width='200'>
<?
} else {
	echo "Connection to internal server not possible. I'm sorry could not save it";

}

?><br>
<center>
<a href='javascript:self.close()'>Close</a>
</center>
