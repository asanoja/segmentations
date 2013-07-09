require 'csv'
require 'rubygems'
require 'nokogiri'
require_relative './matrix.rb'
require_relative './svglib.rb'
require 'graphviz'
#require 'RMagick'
#include Magick

class Evaluation
	attr_accessor :g,:p, :url, :filename
	def initialize
		@dim = {:width=>0,:height=>0}
		@blocks=[]
		@g = nil
		@p = nil
		@category
		@filename = ""
		@url = ""
		@bcg = nil
		@of = nil
		@fromGtoP = nil
		@fromPtoG = nil
	end
	def set_category(cat)
		@category = cat
	end
	def init(filename,algo)
		#~ begin
			puts "using #{algo} algorithm"
			@filename = filename
			@g = Manual.new(@category,filename)
			@p = Automatic.new(algo,@category,filename)
			@g.parse
			@p.parse
			if @g.url != @p.url
				puts "WARNING: Not the same page #{@g.url} != #{@p.url}"
			end
			@url = @g.url
			
		#~ rescue => e
			#~ raise "Evaluation can not be initialized because:\n#{e.backtrace.join("\n")}"
		#~ end
	end
	def fix_dimension_with_aspect_ratio
		@p.fix_dimension_with_aspect_ratio(@g.width,@g.height)
	end
	def fix_dimension_with_resize
		@p.fix_dimension_with_resize(@g.width,@g.height)
	end
	def significative(i,j)
	return (@of[i,j].to_f > @tr) || (@bcg[i,j].to_f > @ta)
	end
	def evaluate
		result = {:tc => 0,:to => 0,:tu => 0, :co => 0, :cu => 0, :cm => 0, :cf => 0}
		
		puts "#{@mt} #{@at}"
		
		subV = Array.new(@mt) {0}
		subH = Array.new(@at) {0}
		
		for i in (0..(@mt-1))
			for j in (0..(@at-1))
				if @bcg[i,j+@mt].to_f>0 
					#count only if significative
					if significative(i,j+@mt)
						subV[i]+=1
						subH[j]+=1
					end
				end
			end
		end
		
		puts subV.inspect
		puts subH.inspect
		
		for i in (0..(@mt-1))
			for j in (0..(@at-1))
				if @bcg[i,j+@mt].to_f>0 
					if subH[j] == 1 && subV[i]==1
						#~ puts "(#{i}-#{j}) V:#{subV[i]} H:#{subH[j]}" 
						result[:tc]+=1
					elsif false 
						
					end
				end
			end
		end
		vvs = 0
		vvc = 0
		vvm = 0

		hhs = 0
		hhc = 0
		hhm = 0
		
		subH.each {|x| 
			hhs+=x
			hhc+=1 			 if x>0
			result[:cu] += 1 if x>1
			result[:cf] += 1 if x==0
			}
		subV.each {|x| 
			vvs += x
			vvc +=1 		 if x>0
			result[:co] += 1 if x>1
			result[:cm] += 1 if x==0
		}
		
		result[:to] = vvs - vvc
		result[:tu] = hhs - hhc
		

		result
	end
	def prepare(tr,ta)
		@tr = tr
		@ta = ta
		@mt = @g.blocks.size
		@at = @p.blocks.size
		
		#~ puts "Manual: #{@mt} Auto: #{@at}"
		
		@bcg = Matrix.new(@at+@mt,@at+@mt,0)
		@of = Matrix.new(@at+@mt,@at+@mt,0)
		@fromGtoP = Matrix.new(@mt,@at,0)
		@fromPtoG = Matrix.new(@at,@mt,0)
		
		bg = "strict graph BCG {\n"
		bg+= "rankdir=LR;\n"
		bg+= "splines=true;\n"
		bg+= "ranksep=\"8 equally\";\n"
		bg+= "concentrate = true;\n"
		bg+= "node [shape=rectangle];\n"
		
		#~ puts "T:#{@mt+@at}"
		#~ ng = mt
		#~ np = mt+at
		
		bg+="subgraph cluster_G {\nlabel = \"G\";\ncolor=black;\n"
		bg+= "rank=\"same\"\n"
		(0..@mt-1).each {|i| bg+="G#{i+1} [label=\"G#{i+1}(#{h(@g.blocks[i])})\"];\n"}
		bg+="}\n"
		bg+="subgraph cluster_P {\nlabel = \"P\";\ncolor=\"black\";\n"
		bg+= "rank=\"same\"\n"
		(0..@at-1).each {|i| bg+="P#{i+1} [label=\"P#{i+1}(#{h(@p.blocks[i])})\"];\n"}
		bg+="}\n"
		
		for i in (0..@mt-1)
			for j in (@mt..(@mt+@at-1))
				blockG = @g.blocks[i]
				blockP = @p.blocks[j-@mt]
				#puts "#{i},#{j} G:#{ev.g.blocks[i].points} || P:#{ev.p.blocks[j-ng-1].points}"
				#~ puts "G#{i+1} vs P#{j-@mt+1}"
				
				divd = [h(blockG),h(blockP)].max.to_f
				
				if blockG.equals? blockP
					@bcg[i,j] = [h(blockG),h(blockP)].min
					@bcg[j,i] = [h(blockG),h(blockP)].min
					
					@of[i,j] = @bcg[i,j].to_f / divd unless divd==0
					@of[j,i] = @bcg[j,i].to_f / divd unless divd==0
					
					ww = 0
					
					ww = [h(blockG),h(blockP)].min.to_f / divd unless divd==0
					
					ncolor = ww>@tr ? "blue" : "red"
					
					bg+="P#{j-@mt+1} -- G#{i+1}  [dir=\"none\",label=\"#{"%.3f" % ww}\",color=\"#{ncolor}\",fontcolor=\"#{ncolor}\"];\n"
					#~ bg+="G#{i+1} -> P#{j-mt+1} [label=\"#{"%.2f" % of[j,i]}\",color=\"blue\",fontcolor=\"blue\"];\n"
					
					#~ puts "G#{i+1} equals P#{j-@mt+1}"
				elsif blockG.contains? blockP
					@bcg[i,j] = [h(blockG),h(blockP)].min
					@bcg[j,i] = [h(blockG),h(blockP)].min
					
					@of[i,j] = @bcg[i,j].to_f / divd unless divd==0
					@of[j,i] = @bcg[j,i].to_f / divd unless divd==0
					
					ncolor = @of[j,i]>@tr ? "blue" : "red"
					
					#~ bg+="P#{j-mt+1} -- G#{i+1}  [label=\"#{"%.2f" % of[i,j]}\",color=\"red\",fontcolor=\"red\"];\n"
					bg+="G#{i+1} -- P#{j-@mt+1}[label=\"#{"%.3f" % @of[j,i]}\",color=\"#{ncolor}\",fontcolor=\"#{ncolor}\"];\n"
					
					#~ puts "P#{j-@mt+1} in G#{i+1}"
				elsif blockP.contains? blockG
					@bcg[i,j] = [h(blockG),h(blockP)].min
					@bcg[j,i] = [h(blockG),h(blockP)].min
					
					@of[i,j] = @bcg[i,j].to_f / divd unless divd==0
					@of[j,i] = @bcg[j,i].to_f / divd unless divd==0
					
					ncolor = @of[i,j]>@tr ? "blue" : "red"
					
					#~ bg+="P#{j-mt+1} -> G#{i+1}  [label=\"#{"%.2f" % of[i,j]}\",color=\"red\",fontcolor=\"red\"];\n"
					bg+="G#{i+1} -- P#{j-@mt+1}[label=\"#{"%.3f" % @of[i,j]}\",color=\"#{ncolor}\",fontcolor=\"#{ncolor}\"];\n"
					#~ puts "G#{i+1} in P#{j-@mt+1}"
				else
					#~ puts "no match"
				end
				
				if @bcg[i,j].to_f>0
					@fromGtoP[i,j-@mt]+=@of[i,j].to_f
					#puts ["G#{i+1}","P#{j+1}",of[i,mt+j]].inspect
				end
				if @bcg[j,i].to_f>0
					@fromPtoG[j-@mt,i]+=@of[j,i].to_f
					#puts ["P#{(j+1)}","G#{(i+1)}",of[mt+j,i]].inspect
				end
			end
			#~ puts "="*80
			#~ gets
		end
		bg+="}"
		File.open("table/BCG_#{@p.algorithm}_#{@filename}.html",'w') {|f| f.puts @bcg.to_html}
		File.open("table/OF_#{@p.algorithm}_#{@filename}.html",'w') {|f| f.puts @of.to_html}
		File.open("table/FG2P_#{@p.algorithm}_#{@filename}.html",'w') {|f| f.puts @fromGtoP.to_html}
		File.open("table/FP2G_#{@p.algorithm}_#{@filename}.html",'w') {|f| f.puts @fromPtoG.to_html}
		File.open("dot/BG_#{@p.algorithm}_#{@filename}.dot",'w') {|f| f.puts bg}
		system "dot -Tsvg dot/BG_#{@p.algorithm}_#{@filename}.dot > images/BG_#{@p.algorithm}_#{@filename}.svg"
		#~ system "dot -Tpng dot/BG_#{@filename}.dot > images/BG_#{@filename}.png"
		#~ puts "</pre>"
		#~ puts @bcg.to_html
		#~ puts @of.to_html
		#~ puts @fromGtoP.to_html
		#~ puts @fromPtoG.to_html
	end
end

class Segmentation
	attr_accessor :url,:filename, :blocks, :width,:height
	def initialize(filename)
		@dim = {:width=>0,:height=>0}
		@filename = filename
		@imagefilename = ""
		@blocks = []
		@url = "" 
		@width = 0
		@height = 0
	end
	def set_imagefile(imgfile)
		@imagefilename = imgfile
	end
	def parse
		#~ puts self.class
		@url = @xml.at("Document")["url"]
		pos = @xml.at("Document")["Pos"].split(" ").collect{|x| x.split(":")}.flatten
		@width = pos[5].to_f
		@height = pos[7].to_f
		@xml.search("//Block").each do |block|
			childnodes = 0
			block.search("./Paths/path").each do |path|
				p path
				p path.inner_text.split(",")[5]
				p path.inner_text.split(",")[7]
				p childnodes+=path.inner_text.split(",")[7].to_i
			end
			#~ pb = epath.inner_text.split(",")
			bpos = block["Pos"].split(" ").collect{|x| x.split(":")}.flatten
			pb = ["path",bpos[1].to_f,bpos[3].to_f,bpos[5].to_f,bpos[7].to_f,"","",childnodes]
			#~ unless pb[0].nil?
				#~ if pb[0]=="/html/body"
					#~ pb[1] = 0
					#~ pb[2] = 0
					#~ pb[3] = @width
					#~ pb[4] = @height
				#~ end
				nb = Block.new(pb)
				nb.set_sid (@blocks.size+1)
				@blocks.push nb
			#~ else
				#~ puts "block skipped!!!! in #{self.class} #{epath}"
			#~ end
		end
	end
	def fix_dimension_with_resize(target_width,target_height)
		#~ p [@width,target_width]
		wratio =  target_width / @width
		hratio = target_height / @height 
		@width = target_width
		@height = target_height
		@blocks.each do |b|
			if wratio>=1
				b.left,b.width = b.left * wratio, b.width * wratio
				b.top,b.height = b.top * hratio, b.height * hratio
			else
				b.left,b.width = b.left / wratio, b.width / wratio
				b.top,b.height = b.top / hratio, b.height / hratio
			end
		end
	end
	def fix_dimension_with_aspect_ratio(other_width,other_height)
		#~ puts "GDIM: #{@width} #{height}"
		#~ puts "PDIM: #{other_width} #{other_height}"
		
		original = @width / @height
		scaled = other_width / other_height
		
		if scaled < original
			#~ puts "width ratio"
			ratio = other_width / @width #resizing by width
		else
			#~ puts "height ratio"
			ratio = other_height / @height #resizing by height
		end
		
		#~ puts "RATIO: #{ratio}"
		
		@width = @width * ratio
		@height = @height * ratio
		
		#~ puts "GDIM': #{@width} #{height}"
		#~ puts "PDIM': #{other_width} #{other_height}"
		
		@blocks.each do |b|
			b.left,
			b.top,
			b.width,
			b.height = b.left	*	ratio,
					   b.top	*	ratio,
					   b.width	*	ratio,
					   b.height	*	ratio
		end
		
	end
	def points(sep=" ")
		"0,0 0,#{@height} #{@width},#{@height} #{@width},0"
	end
end

class Automatic < Segmentation
	attr_accessor :algorithm
	def initialize(algorithm,category,filename)
		super(filename)
		@category = category
		@algorithm = algorithm
		#~ begin
			@xml = load_doc
		#~ rescue
			#~ raise "Automatic segmentation can not be loaded #{$!}"
		#~ end
	end
	private
	def load_doc
		#~ puts  "#{self.class} loading xml/#{@filename}.xml"
		
		unless File.exists?("#{@algorithm}/"+@filename+".xml")
			if @algorithm=="bom1"
				cmd="../pagelyzer/pagelyzer analyzer --decorated-file=source/#{@filename}.dhtml --output-file=bom1/#{@filename}.xml --granularity=6 --force --algorithm=bom1"
			elsif @algorithm=="bom2"
				cmd="../pagelyzer/pagelyzer analyzer --decorated-file=source/#{@filename}.dhtml --output-file=bom2/#{@filename}.xml --granularity=6 --force --algorithm=bom2"
			elsif @algorithm=="bom3"
				cmd="../pagelyzer/pagelyzer analyzer --decorated-file=source/#{@filename}.dhtml --output-file=bom3/#{@filename}.xml --granularity=6 --force --algorithm=bom3"
			elsif @algorithm=="blockfusion"
				cmd="../blockfusion/blockfusion.rb source/#{@filename}.dhtml blockfusion/#{@filename}.xml 6"
			elsif @algorithm=="dummy"
				cmd="../dummy/dummy.rb source/#{@filename}.dhtml dummy/#{@filename}.xml"
			else
				raise "algorithm #{@algorithm} not found"
			end
			p cmd
			unless system(cmd)
				raise "No XML found for #{@filename}.xml"
			end
		end
		return Nokogiri::XML(File.open("#{@algorithm}/#{@filename}.xml"))
	end
end

class Manual < Segmentation
	def initialize(category,filename)
		super(filename)
		@category = category
		begin
			@xml = load_doc
		rescue
			raise "Manual segmentation can be loaded"
		end
	end
	private
	def load_doc
		#~ puts  "#{self.class} loading manual/#{@category}/#{@filename}.xml"
		if File.exist?("manual/#{@category}/#{@filename}.xml")
			return Nokogiri::XML(File.open("manual/#{@category}/#{@filename}.xml"))
			#~ @filename = "manual/#{@category}/#{@filename}.xml"
		else
			raise "No XML found for manual/#{@category}/#{@filename}.xml"
		end
	end
end

class Point
	attr_accessor :x,:y
	def initialize(x,y)
		@x=x
		@y=y
	end
	def distance_to(point)
		Math.hypot(@x-point.x,@y-point.y)
	end
	def to_s
	"(#{@x},#{@y})"
	end
end

class Block
	attr_accessor :path,:left,:top,:width,:height,:children
	
	def initialize(arr)
		@path,@left,@top,@width,@height,@id,@uid,@children = arr
		p @left=@left.to_f
		@top=@top.to_f
		@width=@width.to_f
		@height=@height.to_f
		@path = @path.gsub("/tbody","")
		p @children = @children.to_i
		@image = nil
		@sid = ""
		@deltaGeo = 20
		@deltaCnt = 4
	end
	def set_image(filename)
		#~ img = Magick::ImageList.new(filename)
		#~ filename = "#{self.object_id}"+filename.gsub("/","_")
		#~ @image = img.crop(@left,@top,right,bottom)
		#~ @image.write("fragments/#{filename}_block_#{"%03d" % @sid.to_i}.png")
		#~ puts @image = "fragments/#{filename}_block_#{"%03d" % @sid.to_i}.png"
	end
	def area(node)
		cx = @width.to_f / 2
		cy = @height.to_f / 2
		r = Math.sqrt(cx**2 + cy**2)
		angle = Math.asin(cy/r)
		return (4*(r**2)*Math.sin(2*Math::PI/4))/2
	end
	def right
		@left + @width
	end
	def bottom
		@top + @height
	end
	def area
		@width * @height
	end
	def geo_contains?(element)
		#~ d1 = Point.new(@left,@top).distance_to(Point.new(element.left,element.top))
		#~ d2 = Point.new(@left,bottom).distance_to(Point.new(element.left,element.bottom))
		#~ d3 = Point.new(right,bottom).distance_to(Point.new(element.right,element.bottom))
		#~ d4 = Point.new(right,@top).distance_to(Point.new(element.right,element.top))
		#~ vd = [d1,d2,d3,d4]
		
		r1 = @left-@deltaGeo < element.left
		r2 = @top-@deltaGeo < element.top
		r3 = bottom+@deltaGeo > element.bottom
		r4 = right+@deltaGeo > element.right
		
		vp = [r1,r2,r3,r4]
		
		#~ p [@left-@deltaGeo,element.left,r1]
		#~ p [@top-@deltaGeo,element.top,r2]
		#~ p [bottom+@deltaGeo,element.bottom,r3]
		#~ p [right+@deltaGeo,element.right,r4]
		
		#~ p ["vd"]+vd
		#~ p ["vd","cond"]+vd.collect{|d| d>@deltaGeo}
		#~ p ["vp"]+vp
		
		#~ vdc = 0
		#~ vd.each {|k| vdc+=1 if k>@deltaGeo}
		
		vpc = 0
		vp.each {|k| vpc+=1 if k}
		
		#~ p [vdc,vpc]
		rgeo=vpc>3
		#~ rgeo = vd.collect{|d| d>@deltaGeo}.uniq.include?(true) && !(vp.uniq.include?(true))
		
		#~ rgeo = rgeo && 
		#~ p rgeo = rgeo && (element.top - @top > @deltaGeo) && (element.top - @left < bottom)
		#~ p rgeo = rgeo && (element.bottom - bottom > @deltaGeo) && (element.bottom - bottom > @top)
		#~ p rgeo = rgeo && (element.right - right > @deltaGeo) && (element.right - right > @width)
		ageo = (element.area / area)
		#~ p ["geo_in?",rgeo,ageo]
		return rgeo
	end
	def cnt_contains?(element)
		rcnt = (@children >= element.children + @deltaCnt)
		#~ p ["cnt_in?",rcnt]
		return rcnt
	end
	def geo_equals?(element)
	
	d1 = Point.new(@left,@top).distance_to(Point.new(element.left,element.top))
		d2 = Point.new(@left,bottom).distance_to(Point.new(element.left,element.bottom))
		d3 = Point.new(right,bottom).distance_to(Point.new(element.right,element.bottom))
		d4 = Point.new(right,@top).distance_to(Point.new(element.right,element.top))
		
		vd = [d1,d2,d3,d4]
		
		#~ p [@left,element.left,@top,element.top,bottom,element.bottom,right,element.right]
		
		rgeo = !vd.collect{|d| d<@deltaGeo}.include?(false)
		
		#~ dleft = ([element.left, @left].max - [element.left, @left].min).abs
		#~ dtop = ([element.top, @top].max - [element.top, @top].min).abs
		#~ dright = ([element.right, right].max - [element.right,right].min).abs
		#~ dbottom = ([element.bottom, bottom].max - [element.bottom,bottom].min).abs
		#~ 
		#~ rgeo = dleft < @deltaGeo
		#~ rgeo = rgeo && (dtop < @deltaGeo)
		#~ rgeo = rgeo && (dright < @deltaGeo) 
		#~ rgeo = rgeo && (dbottom < @deltaGeo)
		#~ p ["eql?",rgeo]
		return rgeo
	end
	def cnt_equals?(element)
		rcnt = ([@children,element.children].max-[@children,element.children].min).abs < @deltaCnt
		#~ p ["chl",@children,element.children,rcnt]
		return rcnt
	end
	def contains?(element)
		return (geo_equals?(element) || (geo_contains?(element)) ) && cnt_contains?(element)
	end
	def equals?(element)
		return (geo_equals?(element) &&  cnt_equals?(element))
	end
	def points(sep=" ")
		"#{@left},#{@top} #{@left},#{bottom} #{right},#{bottom} #{right},#{@top}"
	end
	def to_s
		"#{@path} @ (#{@left},#{@top},#{@width},#{@height}) : W:#{@weight} C:#{@children}"
	end
	def set_sid(sid)
		@sid = sid
	end
end

def h(b)
	b.children
end



#main
system "rm images/*"
system "rm dot/*"
system "rm data/*"
system "rm table/*"
system "rm plot/*"

total={}

#~ ["bom1","bom2","blockfusion","dummy"].each do |algo|
["bom3"].each do |algo|

files = {}

Dir.glob("manual/*").each do |cat|
	catfile = cat.gsub("manual/","")
	files[catfile] = File.open("data/raw_#{algo}_#{catfile}.csv","w")
	files[catfile].puts "tr,ta,tc,to,tu,co,cu,cm,cf"
	
end



ta = 1	
tr = 1 #ojo
while tr <= 1
	Dir.glob("manual/*").each do |cat|
		catfile = cat.gsub("manual/","")
		
		next if catfile=="regional"
		
		Dir.glob("#{cat}/*.xml").each do |page|
			ev = Evaluation.new
			
			ev.set_category cat.split("/")[1]
			
			filename = page.split("/")[2]
			filename = filename.gsub(".xml","")
			filename = filename.gsub(".","_").strip
		
			#~ ev.set_filename()
			#~ ev.g.set_imagefile "xml/#{filename}.png"
			#~ ev.p.set_imagefile "xml/#{filename}.png"
			
			ev.init(filename,algo)

			puts "PAGE: #{ev.url}"
			puts "GFILE: #{ev.g.filename}"
			puts "PFILE: #{ev.p.filename}"

			#~ ev.fix_dimension_with_resize
			#~ ev.fix_dimension_with_aspect_ratio
			
			#making visual svg outputs

			if total[catfile].nil?
				total[catfile] = ev.g.blocks.size
			else
				if total[catfile] < ev.g.blocks.size
					total[catfile] = ev.g.blocks.size
				end
			end
			
			svg = SVGPage.new [ev.p.width,ev.g.width].max,[ev.p.height,ev.g.height].max
			svgg = SVGPage.new ev.g.width,ev.g.height
			svgp = SVGPage.new ev.p.width,ev.p.height
			
			
			d={"points" => ev.p.points, "color" => "#A020F0", "text" => "pdoc "}
			svg.data.push d
			svgp.data.push d
			
			d={"points" => ev.g.points, "color" => "green", "text" => "gdoc "}
			svg.data.push d
			svgg.data.push d
			
			
			k=0
			(0..(ev.g.blocks.size-1)).each {|i|
				d = {"points" => ev.g.blocks[i].points, "color" => "red", "text" => "G#{i+1}"}
				svg.data.push d
				svgg.data.push d
				k+=1
				break if k==100
			}
			k=0
			(0..ev.p.blocks.size-1).each {|i|
				d = {"points" => ev.p.blocks[i].points, "color" => "blue", "text" => "_____________P#{i+1}"}
				svg.data.push d
				svgp.data.push d
				k+=1
				break if k==1000
			}
			File.open("images/debug_#{algo}_#{ev.filename}.svg","w") {|f| f.puts svg.parse("../source/#{ev.p.filename}.png")}
			File.open("images/debugP_#{algo}_#{ev.p.filename}.svg","w") {|f| f.puts svgp.parse("../source/#{ev.p.filename}.png")}
			File.open("images/debugG_#{algo}_#{ev.p.filename}.svg","w") {|f| f.puts svgg.parse("../source/#{ev.p.filename}.png")}
			
			#starting evaluation
			
			
			ev.prepare(tr,ta)
			result = ev.evaluate
			
			puts "Tr: #{"%.2f" % tr} Ta #{ta} Tc: #{result[:tc]} To: #{result[:to]} Tu: #{result[:tu]} Co: #{result[:co]} Cu: #{result[:cu]} Cm: #{result[:cm]} Cf: #{result[:cf]}"		
			
			files[catfile].puts "#{tr},#{ta},#{result[:tc]},#{result[:to]},#{result[:tu]},#{result[:co]},#{result[:cu]},#{result[:cm]},#{result[:cf]}"
			ev.p = nil
			ev.g = nil
			ev = nil
		end
	end
	tr+=0.1
	#~ break
end

files.each do |k,v|
	files[k].close
end

avg = {}

Dir.glob("data/raw_#{algo}_*").each do |raw|
#~ puts raw
	datafilename = raw.gsub("data/","").gsub("raw_","data_")
	o = File.open("data/#{datafilename}","w")
	
	CSV.foreach(raw, :headers=>true) do |row|

		if avg[row["tr"].to_f.to_s].nil?
			avg[row["tr"].to_f.to_s] = {:tc => 0,:to => 0,:tu => 0, :co => 0, :cu => 0, :cm => 0, :cf => 0, :n=>0}
		end
		 avg[row["tr"].to_f.to_s][:tc] += row["tc"].to_f
		 avg[row["tr"].to_f.to_s][:to] += row["to"].to_f
		 avg[row["tr"].to_f.to_s][:tu] += row["tu"].to_f
		 avg[row["tr"].to_f.to_s][:co] += row["co"].to_f
		 avg[row["tr"].to_f.to_s][:cu] += row["cu"].to_f
		 avg[row["tr"].to_f.to_s][:cm] += row["cm"].to_f
		 avg[row["tr"].to_f.to_s][:cf] += row["cf"].to_f
		 avg[row["tr"].to_f.to_s][:n] += 1
		 
	end
	
	o.puts "tr,ta,tc,to,tu,co,cu,cm,cf"
	
	avg.each_pair do |k,v|
		#~ avg[k][:tc] /= v[:n]
		#~ avg[k][:to] /= v[:n]
		#~ avg[k][:tu] /= v[:n]
		#~ avg[k][:co] /= v[:n]
		#~ avg[k][:cu] /= v[:n]
		#~ avg[k][:cm] /= v[:n]
		#~ avg[k][:cf] /= v[:n]
		
		o.puts "#{k},1,#{avg[k][:tc]},#{avg[k][:to]},#{avg[k][:tu]},#{avg[k][:co]},#{avg[k][:cu]},#{avg[k][:cm]},#{avg[k][:cf]}"
	end

	#~ File.open("data/total_#{cat.split("/")[1]}.txt","w") {|f| f.puts ev.g.blocks.size}	
	
end
end #algo

total.each_pair do |k,v|
	File.open("data/total_#{k}.txt",'w') {|f| f.puts v}
end
