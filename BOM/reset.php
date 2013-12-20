<?php
$link = mysql_connect('localhost', 'bom', 'dtwjshLHJwUERR7Q');
if (!$link) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("bom", $link);
?>
<?php
mysql_query("delete from metrics");
?>
Deleted all metrics
<?php
mysql_close($link);
?>
