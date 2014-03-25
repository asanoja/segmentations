<?php
$link = mysql_connect('localhost', 'bom', 'dtwjshLHJwUERR7Q');
//~ $link = mysql_connect('localhost', 'root', 'c2306hytu');
if (!$link) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("bom", $link);
?>
