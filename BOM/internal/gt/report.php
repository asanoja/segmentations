<?php include '../conn.php' ?>

<?php
$collection_id = $_GET["collection_id"];
$cat = $_GET["cat"];

if (!isset($collection_id)) die("No collection");
?>

<?php	
$variable = $_GET["val"];
$browser1 = $_GET["browser1"];
$browser2 = $_GET["browser2"];

$algorithm1 = $_GET["algorithm1"];
$algorithm2 = $_GET["algorithm2"];

if (!isset($variable)) $variable="tc";
if (!isset($browser1)) $browser1="chrome";
if (!isset($browser2)) $browser2="iexplorer";
if (!isset($algorithm1)) $algorithm1="BOM";
if (!isset($algorithm2)) $algorithm2="BF";

	//~ echo $algorithm1;
	//~ echo $algorithm2;

$title = array(
	'tc'=>'Total correct blocks',
	'cm'=>'Missed blocks',
	'cf'=>'False Alarms blocks',
	'to'=>'Total oversegmented blocks',
	'tu'=>'Total undersegmented blocks'
);
	function tabular($sql,$link,$fields,$link) {
		echo "<table border=1>";
		echo "	<tr>";
		for ($f=0;$f<count($fields);$f++) {
			echo "<td><b>".$fields[$f]."</b></td>";
		}
		echo "	</tr>";
		//~ echo $sql;
		$results = mysql_query($sql,$link);
		while ($row = mysql_fetch_array($results)) {
			echo "<tr>";
			for ($i=0;$i<count($fields);$i++) {
				echo "<td>".$row[$i]."</td>";
			}
			echo "</tr>";
		}
		echo "</table>";
	}
?>

<html>
	<head>
		<script src="graphs/amcharts/amcharts.js" type="text/javascript"></script>
        <script src="graphs/amcharts/xy.js" type="text/javascript"></script>
        <title>Evaluation Report</title>
        <script>
        function go(k) {
			location.href = "report.php?val="+k;
		}
        </script>
        
        <script>
        var chart;
        
         var chartData = [
			<?php 
				$cq ="";
				if (isset($cat)) {
					if ($cat!="") {
						$cq = " and category='".$cat."' ";
					}
				}
				
				$sql_master="select category,tt from metrics group by category,tt order by category,tt;";
				$master = mysql_query($sql_master,$link);
					for ($tt=0;$tt<=25;$tt+=5) {
						echo "{";
						$add=false;
						
						$sql_r="select 'GT',avg(metrics.gtb) from metrics where algo2='".$algorithm1."' and browser2='".$browser1."' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							echo "'gtbx':".$tt.",";
							echo "'gtby':".$r[1].",";
							echo "'algo0' : 'GT',";
						}
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='".$algorithm1."' and browser2='".$browser1."' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							echo "'bomx':".$tt.",";
							echo "'bomy':".$r[1].",";
							echo "'algo1':'".$algorithm1."'";
							$add=true;
						}
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='".$algorithm2."' and browser2='".$browser2."' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($add) {echo ",";}
						if ($r = mysql_fetch_array($detail)) {
							echo "'vipsx':".$tt.",";
							echo "'vipsy':".$r[1].",";
							echo "'algo2':'".$algorithm2."'";
							
						}
						echo "}";
						if ($tt<25) echo ",\n";
					}
            ?>
               
            ];

        AmCharts.ready(function () {
                // XY CHART
                chart = new AmCharts.AmXYChart();
                chart.pathToImages = "graphs/amcharts/images/";
                chart.dataProvider = chartData;
                chart.startDuration = 1;

                // AXES
                // X
                var xAxis = new AmCharts.ValueAxis();
                xAxis.title = "Tolerance (px)";
                xAxis.position = "bottom";
                xAxis.dashLength = 1;
                xAxis.axisAlpha = 0;
                xAxis.autoGridCount = true;
                chart.addValueAxis(xAxis);

                // Y
                var yAxis = new AmCharts.ValueAxis();
                yAxis.position = "left";
                yAxis.title = "Blocks (avg)";
                yAxis.dashLength = 1;
                yAxis.axisAlpha = 0;
                yAxis.autoGridCount = true;
                chart.addValueAxis(yAxis);

                // GRAPHS
                // triangles up			
                var graph1 = new AmCharts.AmGraph();
                graph1.lineColor = "#FF6600";
                graph1.title = "1. <?php echo $algorithm1."@".$browser1?>";
                graph1.balloonText = "x:[[x]] y:[[y]]";
                graph1.xField = "bomx";
                graph1.yField = "bomy";
                graph1.lineAlpha = 100;
                graph1.bullet = "circle";
                //~ graph1.valueField = "[[algo1]]";
                //~ graph1.legendValueText="[[algo1]]";
                chart.addGraph(graph1);

                // triangles down 
                var graph2 = new AmCharts.AmGraph();
                graph2.lineColor = "#FCD202";
                graph2.title = "2. <?php echo $algorithm2."@".$browser2?>";
                graph2.balloonText = "x:[[x]] y:[[y]]";
                graph2.xField = "vipsx";
                graph2.yField = "vipsy";
                graph2.lineAlpha = 100;
                graph2.bullet = "circle";
                //~ graph2.valueField = "[[algo1]]";
                //~ graph2.legendValueText="[[algo2]]";
                chart.addGraph(graph2);
                
                 // triangles down 
                var graph3 = new AmCharts.AmGraph();
                graph3.lineColor = "#800080";
                graph3.title = "3. Ground Truth";
                graph3.balloonText = "x:[[x]] y:[[y]]";
                graph3.xField = "gtbx";
                graph3.yField = "gtby";
                graph3.lineAlpha = 100;
                graph3.bullet = "circle";
                //~ graph2.valueField = "[[algo1]]";
                //~ graph2.legendValueText="[[algo2]]";
                chart.addGraph(graph3);

                // first trend line
                //~ var trendLine = new AmCharts.TrendLine();
                //~ trendLine.lineColor = "#FF6600";
                //~ trendLine.initialXValue = 1;
                //~ trendLine.initialValue = 2;
                //~ trendLine.finalXValue = 12;
                //~ trendLine.finalValue = 11;
                //~ chart.addTrendLine(trendLine);
//~ 
                //~ // second trend line
                //~ trendLine = new AmCharts.TrendLine();
                //~ trendLine.lineColor = "#FCD202";
                //~ trendLine.initialXValue = 1;
                //~ trendLine.initialValue = 1;
                //~ trendLine.finalXValue = 12;
                //~ trendLine.finalValue = 19;
                //~ chart.addTrendLine(trendLine);


				var legend = new AmCharts.AmLegend();
                legend.markerType = "circle";
                legend.markerSize = 20;
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
	<img src="../images/gtlogo.png" height="64">
<h1>Segmentation Evaluation Report</h1>
<form action="report.php" method="get">
	<input type="hidden" name="collection_id" value="<?=$collection_id?>">
	Collection: <b><?=$collection_id?></b><br>
Category: <select name="cat">
<?
	$sql_r="select distinct category from metrics where collection_id='".$collection_id."' order by category;";
	$detail = mysql_query($sql_r,$link); 
	while ($r = mysql_fetch_array($detail)) {
		if ($r[0] == $cat) {$sel=" selected ";} else {$sel="";}
		echo "<option ".$sel." value='".$r[0]."'>".$r[0]."</option>";
	} 
?>
</select><br>
Metric: <select name="val">
	<?php foreach ($title as $key => $value) {?>
		<?php if ($key == $variable) {$sel=" selected ";} else {$sel="";}?>
		<option <?=$sel?> value='<?=$key?>'><?=$value?> (<?=$key?>)</option>
	<?php }?>
</select><br>
Algorithm1: 
<select name="algorithm1">
	<option value="BOM" <?if ($algorithm1=="BOM") {echo "selected";}?> >BoM</option>
	<option value="VIPS" <?if ($algorithm1=="VIPS") {echo "selected";}?> >VIPS</option>
	<option value="BF" <?if ($algorithm1=="BF") {echo "selected";}?> >Blockfusion</option>
	<option value="JVIPS" <?if ($algorithm1=="JVIPS") {echo "selected";}?> >jVIPS</option>
</select>
@ browser: <select name="browser1">
	<option value="chrome" <?php if ($browser1=="chrome") {echo "selected";}?>>Chrome</option>
	<option value="firefox" <?php if ($browser1=="firefox") {echo "selected";}?>>Firefox</option>
	<option value="iexplorer" <?php if ($browser1=="iexplorer") {echo "selected";}?>>Internet Explorer</option>
	<option value="cssbox" <?php if ($browser1=="cssbox") {echo "selected";}?>>Java CSSBox</option>
</select><br>

Algorithm2:
<select name="algorithm2">
	<option value="BOM" <?if ($algorithm2=="BOM") {echo "selected";}?> >BoM</option>
	<option value="VIPS" <?if ($algorithm2=="VIPS") {echo "selected";}?> >VIPS</option>
	<option value="BF" <?if ($algorithm2=="BF") {echo "selected";}?> >Blockfusion</option>
	<option value="JVIPS" <?if ($algorithm2=="JVIPS") {echo "selected";}?> >jVIPS</option>
</select>
@ browser: <select name="browser2">
	<option value="chrome" <?php if ($browser2=="chrome") {echo "selected";}?>>Chrome</option>
	<option value="firefox" <?php if ($browser2=="firefox") {echo "selected";}?>>Firefox</option>
	<option value="iexplorer" <?php if ($browser2=="iexplorer") {echo "selected";}?>>Internet Explorer</option>
	<option value="cssbox" <?php if ($browser2=="cssbox") {echo "selected";}?>>Java CSSBox</option>
</select>

<input type="submit" value="Query"></form>
<h2><?php echo $title[$variable]?></h2>
 <div id="chartdiv" style="width: 600px; height: 400px;"></div>
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
