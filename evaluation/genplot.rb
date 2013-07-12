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
ntitle = {}
limits = {}

ntitle["to"] = "Oversegmented blocks"
ntitle["tu"] = "Undersegmented blocks"
ntitle["tc"] = "Correct blocks"

fields = ["tc"]
#~ fields = ["to","tu"]
#~ fields = ["to"]
#~ fields = ["tu"]
#~ fields = ["cm","cf"]
#~ fields = ["tc","to","tu","cm","cf"]

catname = ""

	Dir.glob("manual/*").each do |catfile|
	category = catfile.gsub("manual/","")

	
	#~ filename = file.gsub("data/","")
	#~ catname = filename.gsub("data_","")
	#~ catname = catname.gsub("_"," ")
	#~ catname = catname.gsub(".csv","")
	
	#~ algorithms = ["bom3"]
	algorithms = ["bom1","bom2","bom3","blockfusion","dummy"]
	
	algorithms.each {|algo| fields.each {|f| ndata["#{algo}_#{f}"] = Elem.new}}
	
	algorithms.each do |algo|
	
		filename = "data/data_#{algo}_#{category}.csv"
		
		if File.exist? filename
	
		CSV.foreach(filename, :headers=>true) do |row|
			fields.each do |field|
				ndata["#{algo}_#{field}"].x.push row["tr"].to_f
				ndata["#{algo}_#{field}"].y.push row["#{field}"].to_f
				ndata["#{algo}_#{field}"].z.push 1
			end
			
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
		end
	end

#~ p ndata["tc"].y

limits[category] = {:li=>0,:ls=>File.open("data/total_#{category}.txt").read.to_s.to_i}

Gnuplot.open do |gp|
	Gnuplot::Plot.new( gp ) do |plot|
		plot.title  "Total correct blocks - #{category}"
		plot.ylabel "blocks"
		plot.xlabel "tr"
		plot.zlabel "none"
		plot.yrange "[#{limits[category][:li]}:#{limits[category][:ls]}]"
		plot.key "outside"
		plot.terminal "png"
		plot.output  "plot/#{category}.png"
		plot.data = []
		algorithms.each do |algo|
			fields.each do |tag|
				if ndata["#{algo}_#{tag}"].x!=[] && ndata["#{algo}_#{tag}"].y!=[]
					puts "add data for #{algo} #{tag}"
					plot.data << Gnuplot::DataSet.new( [ndata["#{algo}_#{tag}"].x, ndata["#{algo}_#{tag}"].y, ndata["#{algo}_#{tag}"].z] ) { |ds|
						ds.with = "linespoints"
						ds.title = "#{algo}_#{tag}"
					}
				else
					puts "no data #{algo} #{tag}"
				end
			end
		end
  end
end
end
