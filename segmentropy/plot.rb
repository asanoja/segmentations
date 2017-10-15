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
1.upto(ARGV.size-1).each do |i|
	tag=ARGV[i]
	p tag,i
	ndata[tag] = Elem.new
	CSV.foreach("data/#{set}/#{tag}.csv") do |row|
		ndata[tag].x.push row[1].to_f
		ndata[tag].y.push row[0].to_f
		ndata[tag].z.push 1
	end
	xyz =[]
	x = ndata[tag].x
	y = ndata[tag].y
	
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

	ndata[tag].x = xyz.collect {|e| e[0]}
	ndata[tag].y = xyz.collect {|e| 6-e[1]}
	ndata[tag].z = xyz.collect {|e| e[2]}
end

Gnuplot.open do |gp|
	Gnuplot::Plot.new( gp ) do |plot|
		plot.title  "tags frequency - #{ARGV[0].upcase}"
		plot.ylabel "section"
		plot.xlabel "level"
		plot.zlabel "freq"
		plot.key "outside"
		plot.data = []
		1.upto(ARGV.size-1).each do |i|
			tag=ARGV[i]
			plot.data << Gnuplot::DataSet.new( [ndata[tag].x, ndata[tag].y, ndata[tag].z] ) { |ds|
				ds.with = "points"
				ds.title = tag
			}
		end
  end
end
