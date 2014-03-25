<?php include "../../conn.php"; ?>

<?php
$collection_id = $_GET["collection_id"];
$cat = $_GET["cat"];

if (!isset($collection_id)) die("No collection");
?>

<?php	
$variable = $_GET["val"];

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
		<script src="../../js/graphs/amcharts/amcharts.js" type="text/javascript"></script>
        <script src="../../js/graphs/amcharts/xy.js" type="text/javascript"></script>
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
					if ($cat=="all") $cat="";
					if ($cat!="") {
						$cq = " and category='".$cat."' ";
					}
				}
				
				//~ $sql_master="select category,tt from metrics group by category,tt order by category,tt;";
				//~ $master = mysql_query($sql_master,$link);
				$arr = array();
				$arrm = array();
				$ttmax= 20;
					for ($tt=0;$tt<=$ttmax;$tt+=2) {
						$add=false;
						
						$sql_r="select 'GT',avg(metrics.gtb) from metrics where tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							array_push($arr,"'gtbx':".$tt);
							array_push($arr,"'gtby':".$r[1]);
							array_push($arr,"'algo0':'GT'");
						} 
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='BOM' and browser2='chrome' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							array_push($arr,"'bomcx':".$tt);
							array_push($arr,"'bomcy':".$r[1]);
							array_push($arr,"'algo1':'BOMchrome'");
						}
						
						//~ $sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='BOM' and browser2='firefox' and tt=".$tt." ".$cq." group by tt;";
						//~ $detail = mysql_query($sql_r,$link); 
						//~ if ($r = mysql_fetch_array($detail)) {
							//~ array_push($arr,"'bomfx':".$tt);
							//~ array_push($arr,"'bomfy':".$r[1]);
							//~ array_push($arr,"'algo2':'BOMfirefox'");
						//~ }
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='JVIPS' and browser2='cssbox' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							array_push($arr,"'jvipsx':".$tt);
							array_push($arr,"'jvipsy':".$r[1]);
							array_push($arr,"'algo3':'JVIPScssbox'");
						}
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='BF' and browser2='chrome' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							array_push($arr,"'bfcx':".$tt);
							array_push($arr,"'bfcy':".$r[1]);
							array_push($arr,"'algo4':'BFchrome'");
						}
						
						//~ $sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='BF' and browser2='firefox' and tt=".$tt." ".$cq." group by tt;";
						//~ $detail = mysql_query($sql_r,$link); 
						//~ if ($r = mysql_fetch_array($detail)) {
							//~ array_push($arr,"'bffx':".$tt);
							//~ array_push($arr,"'bffy':".$r[1]);
							//~ array_push($arr,"'algo5':'BFfirefox'");
						//~ }
						
						$sql_r="select algo2,avg(metrics.`".$variable."`) from metrics where algo2='VIPS' and browser2='iexplorer' and tt=".$tt." ".$cq." group by tt;";
						$detail = mysql_query($sql_r,$link); 
						if ($r = mysql_fetch_array($detail)) {
							array_push($arr,"'vipsx':".$tt);
							array_push($arr,"'vipsy':".$r[1]);
							array_push($arr,"'algo6':'VIPSixplorer'");
						}
					
					array_push($arrm,"{".implode(",",$arr)."}");
				}
				echo implode(",",$arrm);
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
                
                // triangles down 
                var graph0 = new AmCharts.AmGraph();
                graph0.lineColor = "#800080";
                graph0.title = "3. Ground Truth";
                graph0.balloonText = "x:[[x]] y:[[y]]";
                graph0.xField = "gtbx";
                graph0.yField = "gtby";
                graph0.lineAlpha = 100;
                graph0.bullet = "circle";
                //~ graph2.valueField = "[[algo1]]";
                //~ graph2.legendValueText="[[algo2]]";
                chart.addGraph(graph0);
                
                // chrome bom		
                var graph1 = new AmCharts.AmGraph();
                graph1.lineColor = "red";
                graph1.title = "1. BOM@chrome";
                graph1.balloonText = "x:[[x]] y:[[y]]";
                graph1.xField = "bomcx";
                graph1.yField = "bomcy";
                graph1.lineAlpha = 100;
                graph1.bullet = "triangleUp";
                chart.addGraph(graph1);

				// firefox bom		
                //~ var graph2 = new AmCharts.AmGraph();
                //~ graph2.lineColor = "#FF0000";
                //~ graph2.title = "2. BOM@firefox";
                //~ graph2.balloonText = "x:[[x]] y:[[y]]";
                //~ graph2.xField = "bomfx";
                //~ graph2.yField = "bomfy";
                //~ graph2.lineAlpha = 100;
                //~ graph2.bullet = "triangleUp";
                //~ chart.addGraph(graph2)

                // cssbox jvips
                var graph3 = new AmCharts.AmGraph();
                graph3.lineColor = "#FCD202";
                graph3.title = "3. JVIPS@cssbox";
                graph3.balloonText = "x:[[x]] y:[[y]]";
                graph3.xField = "jvipsx";
                graph3.yField = "jvipsy";
                graph3.lineAlpha = 100;
                graph3.bullet = "circle";
                chart.addGraph(graph3);
                
                 // chrome bf
                var graph4 = new AmCharts.AmGraph();
                graph4.lineColor = "#8B6914";
                graph4.title = "4. BF@chrome";
                graph4.balloonText = "x:[[x]] y:[[y]]";
                graph4.xField = "bfcx";
                graph4.yField = "bfcy";
                graph4.lineAlpha = 100;
                graph4.bullet = "square";
                chart.addGraph(graph4);
                
                 // firefox bf
                //~ var graph5 = new AmCharts.AmGraph();
                //~ graph5.lineColor = "#AF9A65";
                //~ graph5.title = "4. BF@firefox";
                //~ graph5.balloonText = "x:[[x]] y:[[y]]";
                //~ graph5.xField = "bffx";
                //~ graph5.yField = "bffy";
                //~ graph5.lineAlpha = 100;
                //~ graph5.bullet = "square";
                //~ chart.addGraph(graph5);
                
                 // chrome vips
                var graph6 = new AmCharts.AmGraph();
                graph6.lineColor = "#ADD8E6";
                graph6.title = "6. VIPS@iexplorer";
                graph6.balloonText = "x:[[x]] y:[[y]]";
                graph6.xField = "vipsx";
                graph6.yField = "vipsy";
                graph6.lineAlpha = 100;
                graph6.bullet = "bubble";
                chart.addGraph(graph6);

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
	<img src="../../images/gtlogo.png" height="64">
<h1>Segmentation Evaluation Report</h1>
<form action="report3.php" method="get">
	<input type="hidden" name="collection_id" value="<?=$collection_id?>">
	Collection: <b><?=$collection_id?></b> | 
Category: <select name="cat">
	<option value="all">--all--</option>
<?
	$sql_r="select distinct category from metrics where collection_id='".$collection_id."' order by category;";
	$detail = mysql_query($sql_r,$link); 
	while ($r = mysql_fetch_array($detail)) {
		if ($r[0] == $cat) {$sel=" selected ";} else {$sel="";}
		echo "<option ".$sel." value='".$r[0]."'>".$r[0]."</option>";
	} 
?>
</select> | 
Metric: <select name="val">
	<?php foreach ($title as $key => $value) {?>
		<?php if ($key == $variable) {$sel=" selected ";} else {$sel="";}?>
		<option <?=$sel?> value='<?=$key?>'><?=$value?> (<?=$key?>)</option>
	<?php }?>
</select> | 

<input type="submit" value="Query"></form>
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
