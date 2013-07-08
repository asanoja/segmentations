#! /usr/bin/ruby1.9.1
#-*- mode: ruby; encoding: utf-8 -*-
require 'cgi'
require 'sanitize'
require	'nokogiri'
require_relative '../pagelyzer/lib/pagelyzer_url_utils.rb'
require_relative '../pagelyzer/lib/pagelyzer_util.rb'
require_relative '../pagelyzer/lib/pagelyzer_dimension.rb'

class Element
	attr_accessor :blocks,:density,:node
	def initialize(elem)
		@words = clean(elem.content).split(/\W+/).collect {|x| x.strip}
		@node = elem
		@blocks = []
		@density = 0
	end
	def parse
		count = 0
		@blocks = []
		line = []
		@words.each do |word|
			if word.strip!=""
				#~ p [word,word.size,count]
				if (count+word.size)>80
					@blocks.push current=TextBlock.new(line,@node)
					current.parse
					line=[]
					count=0
				else
					line.push word
					count += word.size
				end
			end
		end

		#~ p [@node['id'],@density,@node.path,@words.size,@lines.size]
	end
	
end

class Document
	attr_accessor :elements,:type,:window,:document,:source_file,:document_area
	def initialize
		@elements = []
		@window = Dimension.new
		@document = Dimension.new
		@screenshot = Dimension.new
		@type = :file
		@html = nil
		@document_area = 0
	end
	def loadfile(input_file)
		@source_file = input_file
		@html = load(self)
	end
	def parse
		#~ @html.search("*").each do |e|
		#~ @html.traverse do |e|
		#~ @html.search('//text()').each do |e|
		@html.search('//text()').each do |e|
			el = e
			el = e.parent if e.text?
			if el.element?
				if el["visited"].nil?
					unless ['script','style'].include? el.name.downcase 
						if clean(e.content)!=""
							@elements.push current = Element.new(el)
							current.parse
							el["visited"]="true"
						end
					end
				end
			end
		end
	end
end

class InfoPair
	attr_accessor :line,:element
	def initialize(line,element)
		@line = line
		@element = element
	end
end

class TextBlock
	attr_accessor :data,:density

	def initialize(line,element)
		@data = [InfoPair.new(line,element)]
		@words = line.size.to_f
		@density = 0.0
	end
	def parse
	
		@words = count_words
		
		if @words==0
			@density = 0
		else
			#~ @density =  @data.size.to_f * @words
			@density =  @words / @data.size.to_f
		end
	end
	def merge(other_block)
		@data = other_block.data + @data
		parse
	end
	def dif(other_block)
		m = [@density,other_block.density].max
		if m==0
			return 0
		else
			return (@density-other_block.density).abs / m
		end
	end
	private
	def count_words
		w = 0
		@data.each do |ip|
			w += ip.line.size
		end
		w
	end
end

def clean(str)
	#~ elem.content.gsub(/\r\n?/,"").split(/\W+/).collect {|x| x.strip}.join(" ").strip
	str.strip.squeeze(" ").gsub(/\s+/," ").chomp
end

def escape_html(src='')
if src.nil?
	return ""
else
	return CGI::escapeHTML(src) 
end
end

def get_preq(node)
	links = []
	text = []
	images = []
	node.xpath("text()").each do |tt|
		text.push Sanitize.clean(tt.inner_text)
	end
	node.xpath("img").each do |img|
		images.push img
	end
	node.xpath("a").each do |link|
		links.push link
	end
	
		#~ if ['a','img'].include? tag.name.downcase
			#~ if tag.name.downcase == 'a'
				#~ links.push tag 
			#~ end
			#~ if tag.name.downcase == 'img'
				#~ images.push tag 
			#~ end
			#~ text.push Sanitize.clean(tag.inner_text)
		#~ else
			#~ unless undesirable_node?(tag)
				#~ text.push Sanitize.clean(tag.inner_text)
			#~ end
		#~ end
	#end
	[links.uniq,images.uniq,text.uniq]
end

def parse_xml(block,sid)
		src = ""
		i=1
		#~ block = blockpack[:elem]
		weight = 0
		l = block["elem_left"].to_i
		t = block["elem_top"].to_i
		w = block["elem_width"].to_i 
		h = block["elem_height"].to_i
		am = block["childnodes"].to_i
		am=1 if am==0
		
		#p [h,block["elem_height"],block.path] if block.name.downcase=="div"
		
		src+= "<Block Ref=\"Block#{sid}\" internal_id='#{@id}' ID=\"$BLOCK_ID$\" Pos=\"WindowWidth||PageRectLeft:#{l} WindowHeight||PageRectTop:#{t} ObjectRectWidth:#{w} ObjectRectHeight:#{h}\" Doc=\"#{@granularity}\">\n"
			src += "<weight>\n"
			src += "#{weight}\n"
			src += "</weight>\n"
			src += "<Paths>\n"
			
			src += "<path>#{block.path},#{l},#{t},#{w},#{h},#{block["id"]},#{block["uid"]},#{am}</path>\n"
			src += "</Paths>\n"
				src += "<Links ID=\"$LINKS_ID$\" IDList=\"$ID_LIST_LINKS$\">\n"
				lid = []
				sl = ""
				@links,@images,@text = get_preq(block)
				
				@links.each do |link|
					unless malformed?(link)
						iid = crypt(escape_html(link.inner_text.strip) + escape_html(link[:href]))
						lid.push iid
						sl += "<link ID=\"#{iid}\" Name=\"#{escape_html(link.inner_text.strip)}\" Adr=\"#{escape_html(link[:href])}\"/>"
					end
				end
				src.gsub!('$ID_LIST_LINKS$',lid.join(','))
				src.gsub!('$LINKS_ID$',crypt(sl))
				src += sl
				src += "</Links>\n"
				
				src += "<Imgs ID=\"$IMGS_ID$\" IDList=\"$ID_LIST_IMAGES$\">\n"
				lim = []
				si = ""
				@images.each do |image|
					unless malformed?(image)
						iid = crypt(escape_html(image['alt'])+escape_html(image['src']))
						lim.push iid
						si += "<img ID=\"#{iid}\" Name=\"#{escape_html(image[:alt])}\" Src=\"#{escape_html(image[:src])}\"/>"
					end
				end
				src.gsub!('$ID_LIST_IMAGES$',lim.join(','))
				src.gsub!('$IMGS_ID$',crypt(si))
				src += si
				src += "</Imgs>\n"
				
				@text.delete(nil)
				@text.delete('')
				@text.collect! {|t| 
					t.gsub(/(?<!\n)\n(?!\n)/,' ').gsub(/^$\n/,'').gsub(/\s+/,' ').strip
				}
				txt = escape_html(@text.join(","))
				src += "<Txts ID=\"#{crypt(txt)}\" Txt=\"#{txt}\"/>\n"
			#~ unless @children.empty?
				#~ @children.each do |child|
					#~ src += child.to_xml
				#~ end
			#~ end
		src += "</Block>\n"
		src.gsub!('$BLOCK_ID$',crypt(src))
		src
	end

	def to_xml(url,title,width,height,blocks)
	src = ""
	src += "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\" ?>\n"
	src += "<XML>\n"
		src += "<Document url=\"#{escape_html(url.gsub('"',''))}\" algorithm=\"blockfusion\" Title=\"#{escape_html(title)}\" Version=\"1\" Pos=\"WindowWidth||PageRectLeft:0 WindowHeight||PageRectTop:0 ObjectRectWith:#{width} ObjectRectHeight:#{height}\">\n"
			i = 1
			blocks.each do |b|
				src += parse_xml(b,i)
				i+=1
			end
		src += "</Document>\n"
	src += "</XML>\n"
	src 
	end


input_file = ARGV[0] #"chrome_en_wikipedia_org_wiki_Venezuela.dhtml"
output_file = ARGV[1]
K = ARGV[2].to_f / 10

doc = Document.new
doc.loadfile input_file
doc.parse

blocks = []

doc.elements.each do |e|
	blocks += e.blocks
end


paso = 1
#~ K = 0.4

begin
	#~ puts "PASS #{paso} #{blocks.size}"
	#~ gets
	loop = false
	1.upto(blocks.size-1) do |i|
		next if blocks[i-1].nil? || blocks[i].nil? || blocks[i+1].nil?
		#~ p ["(#{(i-1)},#{i})",blocks[i-1].density,blocks[i].density,blocks[i].dif(blocks[i-1]),"<K",blocks[i].dif(blocks[i-1])<K]
		if (blocks[i-1].density == blocks[i].density) || (blocks[i].dif(blocks[i-1]) < K)
			blocks[i].merge(blocks[i-1])
			blocks[i-1]=nil
			loop = true
			#~ p [blocks[i].density]
		end
	end
	blocks.delete(nil)
	
end until !loop


nodes = []
blocks.each do |b|
	b.data.each do |d|
		nodes.push d.element unless nodes.include? d.element
	end
end

File.open(output_file,"w") {|f| 
	f.puts to_xml(doc.document.url,doc.document.title,doc.document.width,doc.document.height,nodes)
}




