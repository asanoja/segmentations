require 'nokogiri'
require_relative './matrix.rb'
require_relative './svglib.rb'
require 'graphviz'
require 'RMagick'
include Magick

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
	def set_filename(filename)
		@filename = filename
		@g = Manual.new(@category,filename)
		@p = Automatic.new(@category,filename)
	end
	def init
		if @g.load and @p.load
			@g.parse
			@p.parse
			if @g.url != @p.url
				puts "Not the same page #{@g.url} != #{@p.url}"
				return false
			else
				@url = @g.url
				return true
			end
		else
			return false
		end
	end
	def fix_dimension_with_aspect_ratio
		@g.fix_dimension_with_aspect_ratio(@p.width,@p.height)
	end
	def fix_dimension_with_resize
		@g.fix_dimension_with_resize(@p.width,@p.height)
	end
end

class Segmentation
	attr_accessor :url,:filename, :blocks, :width,:height
	def initialize(category,filename)
		@xml = nil
		@dim = {:width=>0,:height=>0}
		@filename = filename
		@imagefilename = ""
		@blocks = []
		@category = category
		@url = "" 
		@width = 0
		@height = 0
	end
	def set_imagefile(imgfile)
		@imagefilename = imgfile
	end
	def load(file)
	end
	def parse
		p self.class
		@url = @xml.at("Document")["url"]
		pos = @xml.at("Document")["Pos"].split(" ").collect{|x| x.split(":")}.flatten
		@width = pos[1].to_f
		@height = pos[3].to_f
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
				puts "block skipeed!!!! in #{self.class} #{epath}"
			end
		end
	end
	def fix_dimension_with_resize(other_width,other_height)
		puts @width,other_width
		puts @width / other_width
		puts @height,other_height
		puts @height / other_height
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
	def load
		unless File.exists?("xml/"+@filename+".xml")
			if system("../pagelyzer/pagelyzer analyzer --decorated-file=xml/#{@filename}.dhtml --output-file=xml/#{@filename}.xml --granularity=6 --force")
				return true
			else
				#raise "No XML found for #{@filename}.xml"
				return false
			end
		end
		@xml = Nokogiri::XML(File.open("xml/#{@filename}.xml"))
		@filename = "xml/#{@filename}.xml"
		return true
	end
end

class Manual < Segmentation
	def load
		if File.exist?("manual/#{@category}/#{@filename}.xml")
			@xml = Nokogiri::XML(File.open("manual/#{@category}/#{@filename}.xml"))
			@filename = "manual/#{@category}/#{@filename}.xml"
			return true
		else
			return false
		end
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
	def contains?(element)
		r = (@left < element.left)
		r = r and (@top < element.top) 
		r = r and (right > element.right) 
		r = r and (bottom > element.bottom)
		return r
	end
	def equals?(element)
		delta = 10
		dleft = element.left - @left
		dtop = element.top - @top
		dright = right - element.right
		dbottom = bottom - element.bottom
		
		r = dleft < delta
		r = r and (dtop < delta)
		r = r and (dright > delta) 
		r = r and (dbottom > delta)
		return r
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

def dameraulevenshtein(seq1, seq2)
    oneago = nil
    thisrow = (1..seq2.size).to_a + [0]
    seq1.size.times do |x|
        twoago, oneago, thisrow = oneago, thisrow, [0] * seq2.size + [x + 1]
        seq2.size.times do |y|
            delcost = oneago[y] + 1
            addcost = thisrow[y - 1] + 1
            subcost = oneago[y - 1] + ((seq1[x] != seq2[y]) ? 1 : 0)
            thisrow[y] = [delcost, addcost, subcost].min
            if (x > 0 and y > 0 and seq1[x] == seq2[y-1] and seq1[x-1] == seq2[y] and seq1[x] != seq2[y])
                thisrow[y] = [thisrow[y], twoago[y-2] + 1].min
            end
        end
    end
    return thisrow[seq2.size - 1]
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

		ev.set_filename(filename)
		#~ ev.g.set_imagefile "xml/#{filename}.png"
		#~ ev.p.set_imagefile "xml/#{filename}.png"
		
		next unless ev.init

		puts "PAGE: #{ev.url}"
		puts "GFILE: #{ev.g.filename}"
		puts "PFILE: #{ev.p.filename}"

		ev.fix_dimension_with_resize
		
		
		svg = SVGPage.new [ev.p.width,ev.g.width].max,[ev.p.height,ev.g.height].max
		d={"points" => ev.p.points, "color" => "#A020F0", "text" => "pdoc "}
		svg.data.push d
		d={"points" => ev.g.points, "color" => "green", "text" => "gdoc "}
		svg.data.push d
		k=0
		ev.g.blocks.each do |b|
			d = {"points" => b.points, "color" => "red", "text" => "g "}
			svg.data.push d
			k+=1
			break if k==100
		end
		k=0
		ev.p.blocks.each do |b|
			d = {"points" => b.points, "color" => "blue", "text" => "p #{b.path}"}
			svg.data.push d
			k+=1
			break if k==1000
		end
		File.open("debug.svg","w") {|f| f.puts svg.parse}
		
		#read manual segmentation into marr

		mt = ev.g.blocks.size
		at = ev.p.blocks.size
		
		
		puts "Manual: #{mt}"
		puts "Auto: #{at}"
		
		gets
		
		bcg = Matrix.new(at+mt,at+mt,0)
		of = Matrix.new(at+mt,at+mt,0)
		bg = "digraph BCG {\n"
		bg+= "rankdir=LR;\n"
		bg+= "splines=false;\n"
		bg+= "node [shape=rectangle];\n"
		
		puts "T:#{mt+at}"
		ng = mt-1
		np = mt+at-1
		
		bg+="subgraph cluster_G {\nlabel = \"G\";\ncolor=blue;\n"
		bg+= "rank=\"same\"\n"
		(0..mt-1).each {|i| bg+="G#{i};\n"}
		bg+="}\n"
		bg+="subgraph cluster_P {\nlabel = \"P\";\ncolor=blue;\n"
		bg+= "rank=\"same\"\n"
		(0..at-1).each {|i| bg+="P#{i};\n"}
		bg+="}\n"
		
		for i in (0..ng)
			for j in ((ng+1)..np)
				g = ev.g.blocks[i]
				p = ev.p.blocks[j-ng-1]
				puts "#{i},#{j} G:#{ev.g.blocks[i]} || P:#{ev.p.blocks[j-ng-1]}"
				if g.equals? p
					bg+="G#{i} -> P#{j-ng-1};\n"
					bg+="P#{i} -> G#{j-ng-1};\n"
					puts "G equals P"
				elsif g.contains? p
					bcg[i,j] = h(p)
					bcg[j,i] = h(p)
					bg+="G#{i} -> P#{j-ng-1};\n"
					puts "P in G"
				elsif p.contains? g
					bcg[j,i] = h(g)
					bcg[i,j] = h(g)
					bg+="P#{i} -> G#{j-ng-1};\n"
					puts "G in P"
				else
					puts "no match"
				end
				
				of[i,j] = bcg[i,j].to_f / h(g)
				of[j,i] = bcg[j,i].to_f / h(p)
			end
		end
		bg+="}"
		File.open("BCG.txt",'w') {|f| f.puts bcg}
		File.open("OF.txt",'w') {|f| f.puts of}
		File.open("BG.dot",'w') {|f| f.puts bg}
		GraphViz.parse("BG.dot") { |g|
			g.output(:svg=>"BG.svg")
		}
	end
end
