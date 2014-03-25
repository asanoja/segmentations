<?php 
$file = "archive/".$_GET['src'];
if (file_exists($file))
{
	
    $size = getimagesize($file);
    $fp = fopen($file, 'rb');
    echo "$size";
    if ($size and $fp)
    {
        // Optional never cache
    //  header('Cache-Control: no-cache, no-store, max-age=0, must-revalidate');
    //  header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
    //  header('Pragma: no-cache');

        // Optional cache if not changed
    //  header('Last-Modified: '.gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

        // Optional send not modified
    //  if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) and 
    //      filemtime($file) == strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']))
    //  {
    //      header('HTTP/1.1 304 Not Modified');
    //  }

        header('Content-Type: '.$size['mime']);
        header('Content-Length: '.filesize($file));
        fpassthru($fp);
        exit;
    }
} else die("nop");
?>

