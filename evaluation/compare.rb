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
	end
	def set_category(cat)
		@category = cat
	end
	def init(filename)
		#~ begin
			@g = Manual.new(@category,filename)
			@p = Automatic.new(@category,filename)
			@g.parse
			@p.parse
			if @g.url != @p.url
				raise "Not the same page #{@g.url} != #{@p.url}"
			else
				@url = @g.url
			end
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
		puts self.class
		@url = @xml.at("Document")["url"]
		pos = @xml.at("Document")["Pos"].split(" ").collect{|x| x.split(":")}.flatten
		@width = pos[5].to_f
		@height = pos[7].to_f
		@xml.search("//Block").each do |block|
			epath = block.at("path")
			pb = epath.inner_text.split(",")
			unless pb[0].nil?
				if pb[0]!="/html/body"
					nb = Block.new(pb)
					#~ nb.set_image @imagefilename
					nb.set_sid (@blocks.size+1)
					@blocks.push nb
				end
			else
				puts "block skipped!!!! in #{self.class} #{epath}"
			end
		end
	end
	def fix_dimension_with_resize(target_width,target_height)
		p [@width,target_width]
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
		puts "GDIM: #{@width} #{height}"
		puts "PDIM: #{other_width} #{other_height}"
		
		original = @width / @height
		scaled = other_width / other_height
		
		if scaled < original
			puts "width ratio"
			ratio = other_width / @width #resizing by width
		else
			puts "height ratio"
			ratio = other_height / @height #resizing by height
		end
		
		puts "RATIO: #{ratio}"
		
		@width = @width * ratio
		@height = @height * ratio
		
		puts "GDIM': #{@width} #{height}"
		puts "PDIM': #{other_width} #{other_height}"
		
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
	def initialize(category,filename)
		super(filename)
		@category = category
		begin
			@xml = load_doc
		rescue
			raise "Automatic segmentation can be loaded #{$!}"
		end
	end
	private
	def load_doc
		puts  "#{self.class} loading xml/#{@filename}.xml"
		unless File.exists?("xml/"+@filename+".xml")
			unless system("../pagelyzer/pagelyzer analyzer --decorated-file=xml/#{@filename}.dhtml --output-file=xml/#{@filename}.xml --granularity=6 --force")
				raise "No XML found for #{@filename}.xml"
			end
		end
		return Nokogiri::XML(File.open("xml/#{@filename}.xml"))
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
		puts  "#{self.class} loading manual/#{@category}/#{@filename}.xml"
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
		@left=@left.to_f
		@top=@top.to_f
		@width=@width.to_f
		@height=@height.to_f
		@path = @path.gsub("/tbody","")
		@children = @children.to_i
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
		p ["geo_in?",rgeo,ageo]
		return rgeo
	end
	def cnt_contains?(element)
		rcnt = (@children >= element.children + @deltaCnt)
		p ["cnt_in?",rcnt]
		return rcnt
	end
	def geo_equals?(element)
	
	d1 = Point.new(@left,@top).distance_to(Point.new(element.left,element.top))
		d2 = Point.new(@left,bottom).distance_to(Point.new(element.left,element.bottom))
		d3 = Point.new(right,bottom).distance_to(Point.new(element.right,element.bottom))
		d4 = Point.new(right,@top).distance_to(Point.new(element.right,element.top))
		
		p vd = [d1,d2,d3,d4]
		
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
		p ["eql?",rgeo]
		return rgeo
	end
	def cnt_equals?(element)
		rcnt = ([@children,element.children].max-[@children,element.children].min).abs < @deltaCnt
		p ["chl",@children,element.children,rcnt]
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

marr=[]
xarr=[]

Dir.glob("manual/*").each do |cat|
	Dir.glob("#{cat}/*.xml").each do |page|
		ev = Evaluation.new
		
		ev.set_category cat.split("/")[1]
		
		filename = page.split("/")[2]
		filename = filename.gsub(".xml","")
		filename = filename.gsub(".","_").strip
	
		#~ ev.set_filename()
		#~ ev.g.set_imagefile "xml/#{filename}.png"
		#~ ev.p.set_imagefile "xml/#{filename}.png"
		
		ev.init(filename)

		puts "PAGE: #{ev.url}"
		puts "GFILE: #{ev.g.filename}"
		puts "PFILE: #{ev.p.filename}"

		#~ ev.fix_dimension_with_resize
		#~ ev.fix_dimension_with_aspect_ratio
		
		
		svg = SVGPage.new [ev.p.width,ev.g.width].max,[ev.p.height,ev.g.height].max
		svgg = SVGPage.new ev.g.width,ev.g.height
		svgp = SVGPage.new ev.p.width,ev.p.height
		
		d={"points" => ev.p.points, "color" => "#A020F0", "text" => "pdoc "}
		svg.data.push d
		svgp.data.push d
		
		d={"points" => ev.g.points, "color" => "green", "text" => "gdoc "}
		svg.data.push d
		svgg.data.push d
		
		mt = ev.g.blocks.size
		at = ev.p.blocks.size

		puts "Manual: #{mt}"
		puts "Auto: #{at}"
		
		k=0
		(0..mt-1).each {|i|
			d = {"points" => ev.g.blocks[i].points, "color" => "red", "text" => "G#{i+1}"}
			svg.data.push d
			svgg.data.push d
			k+=1
			break if k==100
		}
		k=0
		(0..at-1).each {|i|
			d = {"points" => ev.p.blocks[i].points, "color" => "blue", "text" => "_____________P#{i+1}"}
			svg.data.push d
			svgp.data.push d
			k+=1
			break if k==1000
		}
		File.open("debug.svg","w") {|f| f.puts svg.parse}
		File.open("debugP.svg","w") {|f| f.puts svgp.parse}
		File.open("debugG.svg","w") {|f| f.puts svgg.parse}
		
		#~ gets
		
		bcg = Matrix.new(at+mt,at+mt,0)
		of = Matrix.new(at+mt,at+mt,0)
		bg = "strict digraph BCG {\n"
		bg+= "rankdir=LR;\n"
		bg+= "splines=true;\n"
		bg+= "concentrate = true;\n"
		bg+= "node [shape=rectangle];\n"
		
		puts "T:#{mt+at}"
		ng = mt
		np = mt+at
		
		bg+="subgraph cluster_G {\nlabel = \"G\";\ncolor=red;\n"
		bg+= "rank=\"same\"\n"
		(0..mt-1).each {|i| bg+="G#{i+1} [label=\"G#{i+1}(#{ev.g.blocks[i].children})\"];\n"}
		bg+="}\n"
		bg+="subgraph cluster_P {\nlabel = \"P\";\ncolor=blue;\n"
		bg+= "rank=\"same\"\n"
		(0..at-1).each {|i| bg+="P#{i+1} [label=\"P#{i+1}(#{ev.p.blocks[i].children})\"];\n"}
		bg+="}\n"
		
		for i in (0..mt-1)
			for j in (mt..(mt+at-1))
				g = ev.g.blocks[i]
				p = ev.p.blocks[j-mt]
				#puts "#{i},#{j} G:#{ev.g.blocks[i].points} || P:#{ev.p.blocks[j-ng-1].points}"
				puts "G#{i+1} vs P#{j-mt+1}"
				
				if g.equals? p
					bcg[i,j] = [h(g),h(p)].max
					bcg[j,i] = [h(g),h(p)].max
					
					of[i,j] = bcg[i,j].to_f / [h(g),h(p)].max
					of[j,i] = bcg[j,i].to_f / [h(g),h(p)].max

					bg+="P#{j-mt+1} -> G#{i+1}  [label=\"#{"%.2f" % of[i,j]}\",color=\"red\",fontcolor=\"red\"];\n"
					bg+="G#{i+1} -> P#{j-mt+1} [label=\"#{"%.2f" % of[j,i]}\",color=\"blue\",fontcolor=\"blue\"];\n"
					
					puts "G#{i+1} equals P#{j-mt+1}"
				elsif g.contains? p
					bcg[i,j] = h(p)
					bcg[j,i] = h(p)
					
					of[i,j] = bcg[i,j].to_f / h(g)
					of[j,i] = bcg[j,i].to_f / h(p)
					
					bg+="P#{j-mt+1} -> G#{i+1}  [label=\"#{"%.2f" % of[i,j]}\",color=\"red\",fontcolor=\"red\"];\n"
					bg+="G#{i+1} -> P#{j-mt+1}[label=\"#{"%.2f" % of[j,i]}\",color=\"blue\",fontcolor=\"blue\"];\n"
					
					puts "P#{j-mt+1} in G#{i+1}"
				elsif p.contains? g
					bcg[j,i] = h(g)
					bcg[i,j] = h(g)
					
					of[i,j] = bcg[i,j].to_f / h(g)
					of[j,i] = bcg[j,i].to_f / h(p)
					
					bg+="P#{j-mt+1} -> G#{i+1}  [label=\"#{"%.2f" % of[i,j]}\",color=\"red\",fontcolor=\"red\"];\n"
					bg+="G#{i+1} -> P#{j-mt+1}[label=\"#{"%.2f" % of[j,i]}\",color=\"blue\",fontcolor=\"blue\"];\n"
					puts "G#{i+1} in P#{j-mt+1}"
				else
					puts "no match"
				end
				
				
			end
			puts "="*80
			#~ gets
		end
		bg+="}"
		File.open("BCG.txt",'w') {|f| f.puts bcg}
		File.open("OF.txt",'w') {|f| f.puts of}
		File.open("BG.dot",'w') {|f| f.puts bg}
		puts bcg.to_html
		system "dot -Tsvg BG.dot > BG.svg"
		system "dot -Tpng BG.dot > BG.png"
		
		fromGtoP = Matrix.new(mt,at,0)
		fromPtoG = Matrix.new(at,mt,0)
		
		for i in (0..(mt-1))
			for j in (0..(at-1))
				if bcg[i,mt+j].to_f>0
					fromGtoP[i,j]+=1
					puts ["G#{i+1}","P#{j+1}",of[i,mt+j]].inspect
				end
				if bcg[mt+j,i].to_f>0
					fromPtoG[j,i]+=1
					puts ["P#{(j+1)}","G#{(i+1)}",of[mt+j,i]].inspect
				end
				
			end
		end
		puts fromGtoP.to_html
		puts fromPtoG.to_html
		
		#~ tc = 0 
		#~ 
		#~ ccG = ccP =0
		#~ 
		#~ for i in (0..(mt-1))
			#~ for j in (0..(at-1))
				#~ esalidaG = fromGtoP.rows[i].inject{|sum,x| sum+x}
				#~ esalidaP = fromPtoG.rows[j].inject{|sum,x| sum+x}
				#~ if esalidaG==esalidaP && esalidaG==1
					#~ puts "G#{i+1} -> P#{j+1}"
				#~ end
			#~ end
		#~ end
		
		
		#QUEDE AQUI HAY QUE HACE EL CALCULO DE CUALES SON LOS NODOS CONECTADOS
		#QUE TIENEN UN SOLO VERTICE
		#Y CUALES SON AQUELLOS QUE TIENEN VARIOS
		#ESTOY YA MAMAO
		#SIGUO MANANA
		
	end
end
