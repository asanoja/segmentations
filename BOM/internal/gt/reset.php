<?php include "../../conn.php";?>
<?php
mysql_query("delete from metrics");
?>
<?php
mysql_close($link);
?>
<div id="evaloutput">Deleted all metrics</div>
