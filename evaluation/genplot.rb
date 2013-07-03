require 'csv'
require 'rubygems'
require 'gnuplot'

class Elem
attr_accessor :x,:y,:z
def initialize
@x=[]
@y=[]
@z=[]
end
end

#~ system "rm plot/*"

ndata = {}

fields = ["tc","to","tu"]#,"cm","cf"]

catname = ""

file = ARGV[0]
	filename = file.gsub("data/","")
	catname = filename.gsub("data_","")
	catname = catname.gsub("_"," ")
	catname = catname.gsub(".csv","")
	
	fields.each {|f| ndata[f] = Elem.new}
	
	CSV.foreach(file, :headers=>true) do |row|
		ndata["tc"].x.push row["tr"].to_f
		ndata["tc"].y.push row["tc"].to_f
		ndata["tc"].z.push 1
		
		#~ ndata["to"].x.push row["tr"].to_f
		#~ ndata["to"].y.push row["to"].to_f
		#~ ndata["to"].z.push 1
		#~ 
		#~ ndata["tu"].x.push row["tr"].to_f
		#~ ndata["tu"].y.push row["tu"].to_f
		#~ ndata["tu"].z.push 1
		
		#~ ndata["cm"].x.push row["tr"].to_f
		#~ ndata["cm"].y.push row["cm"].to_f
		#~ ndata["cm"].z.push 1
		#~ 
		#~ ndata["cf"].x.push row["tr"].to_f
		#~ ndata["cf"].y.push row["cf"].to_f
		#~ ndata["cf"].z.push 1
	end
#~ end

#~ p ndata["tc"].y

Gnuplot.open do |gp|
	Gnuplot::Plot.new( gp ) do |plot|
		plot.title  "Segmentation Results - #{catname}"
		plot.ylabel "blocks"
		plot.xlabel "tr"
		plot.zlabel "none"
		plot.key "outside"
		plot.terminal "png"
		plot.output  "plot/#{catname}.png"
		plot.data = []
		fields.each do |tag|
			plot.data << Gnuplot::DataSet.new( [ndata[tag].x, ndata[tag].y, ndata[tag].z] ) { |ds|
				ds.with = "linespoints"
				ds.title = tag
			}
		end
  end
end
