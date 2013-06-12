require 'csv'
require 'rubygems'
require 'gnuplot'

x = []
y = []
z = []
CSV.foreach("output/wp.csv") do |row|
	x.push row[1].to_f
	y.push row[0].to_f
	z.push row[3].to_f
end

y = y.collect {|r| y.max - r}

Gnuplot.open do |gp|
	Gnuplot::SPlot.new( gp ) do |plot|
		plot.title  "Entropy"
		plot.ylabel "section"
		plot.xlabel "level"
		plot.zlabel "entropy"
		plot.key "outside"
		plot.data = []
		
		plot.data << Gnuplot::DataSet.new( [x, y, z] ) { |ds|
			ds.with = "linespoints"
			ds.title = "entropy"
		}
  end
end
