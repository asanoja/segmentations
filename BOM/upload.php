<?php include "conn.php" ?>
<?php
if ( !isset($_FILES['userFile']['type']) ) {
   die('<p>No image submitted</p></body></html>');
}

// Validate uploaded image file
if ( !preg_match( '/gif|png|x-png|jpeg/', $_FILES['userFile']['type']) ) {
   die('<p>Only browser compatible images allowed</p></body></html>');
} else if (false && $_FILES['userFile']['size'] > 16384 ) {
   die('<p>Sorry file too large</p></body></html>');
// Copy image file into a variable
} else if ( !($handle = fopen ($_FILES['userFile']['tmp_name'], "r")) ) {
   die('<p>Error opening temp file</p></body></html>');
} else if ( !($image = fread ($handle, filesize($_FILES['userFile']['tmp_name']))) ) {
   die('<p>Error reading temp file</p></body></html>');
} else {
   fclose ($handle);
   // Commit image to the database
   $image = mysql_real_escape_string($image);
   $alt = htmlentities($_POST['altText']);
   $graph_src = $_POST['graph_src'];
   $url = $_POST['url'];
   $algo = $_POST['algo'];
   $browser = $_POST['browser'];
   $query = "INSERT INTO segmentation_data (segmentation_id,graph_image,graph_src) VALUES (".$segid.",'". $image . "','".$graph_src."')";
   if ( !(mysql_query($query,$link)) ) {
      die('OK');
   } else {
      die('FAIL');
   }
}
?>
END.
