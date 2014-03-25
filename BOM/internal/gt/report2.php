<?php include '../conn.php' ?>

<?php	
$variable = $_GET["val"];

$browser1 = "chrome";
$browser2 = "chrome";
$browser3 = "iexplorer";
$browser4 = "cssbox";

$algorithm1 = "BOM";
$algorithm2 = "BF";
$algorithm3 = "VIPS";
$algorithm4 = "JVIPS";

if (!isset($variable)) $variable="tc";

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
				//~ $sql="select count(distinct url),algorithms.name,category,tt,avg(`tc`),avg('to'),avg(tu),avg(co),avg(cu),avg(cm),avg(cf), avg(gtb), avg(stb), avg(`tc`)/avg(gtb) as prec, ((avg(tc)/avg(gtb)) / (avg(cm)+avg(cf))) as score  from metrics inner join algorithms on algorithms.id=algorithm group by category,algorithm,tt order by category,algorithm,tt;";
				$sql_master="select category,tt from metrics group by category,tt order by category,tt;";
				$master = mysql_query($sql_master,$link);
					for ($tt=0;$tt<=25;$tt+=5) {
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='".$algorithm1."' and browser2='".$browser1."' and tt=".$tt." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						echo "{";

						if ($r = mysql_fetch_array($detail)) {
							echo "'bomx':".$tt.",";
							echo "'bomy':".$r[1].",";
							echo "'algo1':'".$algorithm1."',";
						} else {
							echo "'bomx':".$tt.",";
							echo "'bomy':0,";
							echo "'algo1':'".$algorithm1."',";
						}

						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='".$algorithm2."' and browser2='".$browser2."' and tt=".$tt." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($add) {echo ",";}
						if ($r = mysql_fetch_array($detail)) {
							echo "'bfx':".$tt.",";
							echo "'bfy':".$r[1].",";
							echo "'algo2':'".$algorithm2."',";
						} else {
							echo "'bfx':".$tt.",";
							echo "'bfy':0,";
							echo "'algo2':'".$algorithm2."',";
						}
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='".$algorithm3."' and browser2='".$browser3."' and tt=".$tt." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($add) {echo ",";}
						if ($r = mysql_fetch_array($detail)) {
							echo "'vipsx':".$tt.",";
							echo "'vipsy':".$r[1].",";
							echo "'algo3':'".$algorithm3."',";
						} else {
							echo "'vipsx':".$tt.",";
							echo "'vipsy':0,";
							echo "'algo3':'".$algorithm3."',";
						}
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='".$algorithm4."' and browser2='".$browser4."' and tt=".$tt." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($add) {echo ",";}
						if ($r = mysql_fetch_array($detail)) {
							echo "'jvipsx':".$tt.",";
							echo "'jvipsy':".$r[1].",";
							echo "'algo4':'".$algorithm4."'";
						} else {
							echo "'jvipsx':".$tt.",";
							echo "'jvipsy':0,";
							echo "'algo4':'".$algorithm4."'";
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
                graph1.lineColor = "#008000";
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
                graph2.xField = "bfx";
                graph2.yField = "bfy";
                graph2.lineAlpha = 100;
                graph2.bullet = "circle";
                //~ graph2.valueField = "[[algo1]]";
                //~ graph2.legendValueText="[[algo2]]";
                chart.addGraph(graph2);
                
                // triangles down 
                var graph3 = new AmCharts.AmGraph();
                graph3.lineColor = "#EC2020";
                graph3.title = "3. <?php echo $algorithm3."@".$browser3?>";
                graph3.balloonText = "x:[[x]] y:[[y]]";
                graph3.xField = "vipsx";
                graph3.yField = "vipsy";
                graph3.lineAlpha = 100;
                graph3.bullet = "circle";
                //~ graph2.valueField = "[[algo1]]";
                //~ graph2.legendValueText="[[algo2]]";
                chart.addGraph(graph3);
                
                // triangles down 
                var graph4 = new AmCharts.AmGraph();
                graph4.lineColor = "#1E90FF";
                graph4.title = "4. <?php echo $algorithm4."@".$browser4?>";
                graph4.balloonText = "x:[[x]] y:[[y]]";
                graph4.xField = "jvipsx";
                graph4.yField = "jvipsy";
                graph4.lineAlpha = 100;
                graph4.bullet = "circle";
                //~ graph2.valueField = "[[algo1]]";
                //~ graph2.legendValueText="[[algo2]]";
                chart.addGraph(graph4);

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
		$sql = "(select algo2,tt,metrics.`".$variable."` from metrics where algo2='".$algorithm1."' and browser2='".$browser1."'  order by tt )";
		$sql = $sql . " union (select algo2,tt,metrics.`".$variable."` from metrics where algo2='".$algorithm2."' and browser2='".$browser2."' order by tt );";
		tabular($sql,$link,array('algo2','tt',$variable));
	 ?>
 </div>
</body>
</html>
<?php
mysql_close($link);
?>
