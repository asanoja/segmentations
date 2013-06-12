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

ndata = {}
set = ARGV[0]
tags = ARGV[1..ARGV.size-1]
ndata["page"] = {}
ndata["base"] = {}

["page","base"].each do |p|
	tags.each do |tag|
		if p=="page"
			file = "output/wp/#{tag}.csv"
		else
			file = "data/#{set}/#{tag}.csv"
		end	
		p file
		ndata[p][tag] = Elem.new
		CSV.foreach(file) do |row|
			ndata[p][tag].x.push row[1].to_f
			ndata[p][tag].y.push row[0].to_f
			ndata[p][tag].z.push 1
		end
		xyz =[]
		x = ndata[p][tag].x
		y = ndata[p][tag].y
		
		0.upto(x.size) do |k|
			next if x[k].nil? or y[k].nil?
			e = [x[k],y[k],1.0]
			if xyz.include? e
				pos = xyz.index(e)
				xyz[pos][2]+=1
			else
				xyz[k] = e 
			end
		end

		xyz.delete(nil)
		xyz.sort_by {|e| e[0]}

		ndata[p][tag].x = xyz.collect {|e| e[0]}
		ndata[p][tag].y = xyz.collect {|e| 6-e[1]}
		ndata[p][tag].z = xyz.collect {|e| e[2]}
	end
end
p ndata["page"]

Gnuplot.open do |gp|
	Gnuplot::Plot.new( gp ) do |plot|
		plot.title  "tags frequency - #{ARGV[0].upcase}"
		plot.ylabel "section"
		plot.xlabel "level"
		plot.zlabel "freq"
		plot.key "outside"
		plot.ytics "('L0' 0,'L1' 1,'L2' 2,'L3' 3,'L4' 4,'L5' 5,'L6' 6)"
		plot.ytics "('S6' 0,'S5' 1,'S4' 2,'S3' 3,'S2' 4,'S1' 5,'S0' 6)"
		plot.data = []
		["page","base"].each do |p|
			tags.each do |tag|
				plot.data << Gnuplot::DataSet.new( [ndata[p][tag].x, ndata[p][tag].y, ndata[p][tag].z] ) { |ds|
					ds.with = "linespoints"
					ds.title = p+"-"+tag
				}
			end
		end
	  end
end
