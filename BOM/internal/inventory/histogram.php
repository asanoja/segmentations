<?php include "../../conn.php"; ?>

<?php
if ($_GET['mode']=="HistogramX") {
	$mode = "X";
} else {
	$mode = "Y";
}
$collection_id = $_GET["collection_id"];
$seg1 = $_GET["segsel"][0];
$seg2 = $_GET["segsel"][1];

$msql = "select * from segmentation where id=".$seg1;
$a = mysql_query($msql,$link);
if ($det = mysql_fetch_object($a)) {
	$algo = strtolower(str_replace("data","",$det->kind));
	$table = $algo."_blocks";
	$browser = $det->browser;
	$sseg1 = $algo."@".$browser;
}
$msql = "select * from segmentation where id=".$seg2;
$a = mysql_query($msql,$link);
if ($det = mysql_fetch_object($a)) {
	$algo = strtolower(str_replace("data","",$det->kind));
	$table = $algo."_blocks";
	$browser = $det->browser;
	$sseg2 = $algo."@".$browser;
}

if (!isset($collection_id)) die("No collection");
?>

<html>
	<head>
		<script src="../../js/graphs/amcharts/amcharts.js" type="text/javascript"></script>
        <script src="../../js/graphs/amcharts/xy.js" type="text/javascript"></script>
        <title>Segmentation Histogram Comparison</title>
        
        <script>
        var chart;
        
         var chartData = [
			<?php 
				$arr = array();
				$arrm = array();
				$ttmax= 100;
				$dif = 10;
				$ymax = 20;
				$val1=0;
				$val2=0;
				$acum=0;
				$in1 = array(0);
				$in2 = array(0);
					for ($tt=0;$tt<=$ttmax;$tt+=$dif) {
						if ($mode=="Y") {
							$sql_r="select id from blocks where ((ny<".$tt." and nh>".($tt+$dif).") or (ny>=".$tt." and ny<=".($tt+$dif).") or (nh>=".$tt." and nh<=".($tt+$dif).")) and segmentation_id=".$seg1." and id not in (".implode(",",$in1).");";
						} else {
							$sql_r="select id from blocks where ((nx<".$tt." and nw>".($tt+$dif).") or (nw>=".$tt." and nw<=".($tt+$dif).") or (nw>=".$tt." and nw<=".($tt+$dif).")) and segmentation_id=".$seg1." and id not in (".implode(",",$in1).");";
						}
						$detail = mysql_query($sql_r,$link); 
						$valp=0;
						while ($r = mysql_fetch_assoc($detail)) {
							$valp=$valp+1;
							array_push($in1,$r["id"]);
						}
						$val1 = $val1 + $valp;
						array_push($arr,"{'s1x':".$tt.",'s1y':".$val1."}");

						if ($mode=="Y") {
							$sql_r="select id from blocks where ((ny<".$tt." and nh>".($tt+$dif).") or (ny>=".$tt." and ny<=".($tt+$dif).") or (nh>=".$tt." and nh<=".($tt+$dif).")) and segmentation_id=".$seg2." and id not in (".implode(",",$in2).");";
						} else {
							$sql_r="select id from blocks where ((nx<".$tt." and nw>".($tt+$dif).") or (nx>=".$tt." and nx<=".($tt+$dif).") or (nw>=".$tt." and nw<=".($tt+$dif).")) and segmentation_id=".$seg2." and id not in (".implode(",",$in2).");";
						}
						$detail = mysql_query($sql_r,$link); 
						$valq=0;
						while ($r = mysql_fetch_assoc($detail)) {
							$valq=$valq+1;
							array_push($in2,$r["id"]);
						}
						$val2 = $val2 + $valq;
						array_push($arr,"{'s2x':".$tt.",'s2y':".$val2."}");
						
						$acum = $acum + abs($valp-$valq);
						array_push($arr,"{'dx':".$tt.",'dy':".$acum."}");
					
					array_push($arrm,implode(",",$arr));
				}
				//~ print_r($arr);
				echo implode(",\n",$arr);
            ?>
               
            ];

        AmCharts.ready(function () {
                // XY CHART
                chart = new AmCharts.AmXYChart();
                chart.pathToImages = "../../js/graphs/amcharts/images/";
                chart.dataProvider = chartData;
                chart.startDuration = 1;

                // AXES
                // X
                var xAxis = new AmCharts.ValueAxis();
                xAxis.title = "Document Height";
                xAxis.position = "bottom";
                xAxis.dashLength = 1;
                xAxis.axisAlpha = 0;
                xAxis.autoGridCount = true;
                xAxis.minimum = 0;
                xAxis.maximum = 100;
                chart.addValueAxis(xAxis);

                // Y
                var yAxis = new AmCharts.ValueAxis();
                yAxis.position = "left";
                yAxis.title = "Blocks";
                yAxis.dashLength = 1;
                yAxis.axisAlpha = 0;
                yAxis.autoGridCount = true;
                //~ yAxis.minimum = 0;
                //~ yAxis.maximum = <?=$ymax?>;
                chart.addValueAxis(yAxis);

                // GRAPHS
                
                // seg1
                var graph0 = new AmCharts.AmGraph();
                graph0.lineColor = "#800080";
                graph0.title = "1. <?=$sseg1?>";
                graph0.balloonText = "x:[[x]] y:[[y]]";
                graph0.xField = "s1x";
                graph0.yField = "s1y";
                graph0.lineAlpha = 100;
                graph0.bullet = "circle";
                chart.addGraph(graph0);
                
                
                
                // seg2
                var graph2 = new AmCharts.AmGraph();
                graph2.lineColor = "#FF0000";
                graph2.title = "2. <?=$sseg2?>";
                graph2.balloonText = "x:[[x]] y:[[y]]";
                graph2.xField = "s2x";
                graph2.yField = "s2y";
                graph2.lineAlpha = 100;
                graph2.bullet = "circle";
                chart.addGraph(graph2);
                
                // seg2 accumulative
                var graph3 = new AmCharts.AmGraph();
                graph3.lineColor = "#FFA500";
                graph3.title = "3. Error";
                graph3.balloonText = "x:[[x]] y:[[y]]";
                graph3.xField = "dx";
                graph3.yField = "dy";
                graph3.lineAlpha = 100;
                graph3.bullet = "circle";
                chart.addGraph(graph3);

				var legend = new AmCharts.AmLegend();
                legend.markerType = "circle";
                legend.markerSize = 20;
                legend.position = "right";
                //~ legend.valueText = "[[value]]";
                chart.addLegend(legend);
                
                // CURSOR
                var chartCursor = new AmCharts.ChartCursor();
                chart.addChartCursor(chartCursor);

                // SCROLLBAR

                var chartScrollbar = new AmCharts.ChartScrollbar();
                chart.addChartScrollbar(chartScrollbar);

                // WRITE                                                
                chart.write("chartdiv");
            });
        </script>
	</head>
<body>
<h1>Segmentation Histogram</h1>
Collection: <b><?=$collection_id?></b> | 
Segmentation #1: <?=$seg1?> 
<?if (isset($seg2)) {?> | Segmentation #2: <?=$seg2?>  <?}?>

<h2><?php echo $title[$variable]?></h2>
 <div id="chartdiv" style="border:2px solid black;width: 100%; height: 520px;"></div>
 <div>
	 
	 <?php 
		//~ $sql = "(select algo2,tt,metrics.`".$variable."` from metrics where algo2='".$algorithm1."' and browser2='".$browser1."'  order by tt )";
		//~ $sql = $sql . " union (select algo2,tt,metrics.`".$variable."` from metrics where algo2='".$algorithm2."' and browser2='".$browser2."' order by tt );";
		//~ tabular($sql,$link,array('algo2','tt',$variable));
	 ?>
 </div>
</body>
</html>
<?php
mysql_close($link);
?>
