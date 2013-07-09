#! /usr/bin/ruby1.9.1
#-*- mode: ruby; encoding: utf-8 -*-
# Andrés Sanoja
# UPMC - LIP6
#
#
#
# pagelyzer_analyzer
#
# Requires: Ruby 1.9.1+ (1.8.x versions won't work), rubygems 1.3.7+ and Hpricot gem v=0.8.6
#
# Copyright (C) 2011, 2012 Andrés Sanoja, Université Pierre et Marie Curie -
# Laboratoire d'informatique de Paris 6 (LIP6)
#
# Contributors: Stephane Gançarski - LIP6
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# ISSUES:
# 1. For commandline parameters is better to escape them, e.g:
#
# pagelyzer_analyzer --decorated-file=/my/path with/spaces -- only processes /my/path !
# pagelyzer_analyzer --decorated-file=/my/path\ with/spaces -- results in correct behaviour
#

Encoding.default_external = Encoding::UTF_8

require 'nokogiri'
require_relative '../lib/pagelyzer_util.rb'
require_relative '../lib/pagelyzer_dimension.rb'
require_relative '../lib/pagelyzer_url_utils.rb'
require "sanitize"


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


class BlockOMatic

	attr_accessor :type,:document,:window,:source_file,:document_area, :error
	attr_accessor :doc_rel,:doc_proportion, :pdoc,:target_path,:next_block_id,:debug
	
	def initialize
		@window = Dimension.new
		@document = Dimension.new
		@screenshot = Dimension.new
		@max_weight = 0
		@gid = 1
		@source_file = nil
		@output_file = nil
		@document_area = 0.0
		@debug = false
		@granularity = 0.4
		@type = :file
		@blocks = []
		@error = false
		@verbose = false
	end

def set_source_content(dhtml) 
	@source_file = dhtml
	@type = :content
end
def set_source_file(f) 
	@source_file = f
	@type=:file
end
def set_output_file(f) 
	@output_file = f
	@type=:file
end
def set_granularity(n) 
	@granularity = n/10.0
end

def mark(node,d)
	elem = d.at(node.path)
	unless elem.nil?
		d.xpath(node.path).first['style'] = "border: solid 2px red"
		d.xpath(node.path).first['title'] = "#{node.path} - #{node["id"]}"
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

	def parse_xml(blockpack,sid)
		src = ""
		i=1
		block = blockpack
		weight = (block.text_density + block.area_density) / 2
		l = block.left.to_i
		t = block.top.to_i
		w = block.width.to_i 
		h = block.height.to_i
		am = block.childnodes.to_i
		am=1 if am==0
		
		#~ p [h,block["elem_height"],block.path] if block.name.downcase=="div"
		
		src+= "<Block Ref=\"Block#{sid}\" internal_id='#{@id}' ID=\"$BLOCK_ID$\" Pos=\"WindowWidth||PageRectLeft:#{l} WindowHeight||PageRectTop:#{t} ObjectRectWidth:#{w} ObjectRectHeight:#{h}\" Doc=\"#{@granularity}\" childnodes=\"#{block.childnodes}\">\n"
			src += "<weight>\n"
			src += "#{weight}\n"
			src += "</weight>\n"
			src += "<Paths>\n"
			block.elements.each do |e|
				src += "<path>#{e.node.path},#{e.node['elem_left']},#{e.node['elem_top']},#{e.node['elem_width']},#{e.node['elem_height']},#{e.node["id"]},#{e.node["uid"]},#{e.node["childnodes"]}</path>\n"
			end
			src += "</Paths>\n"
				src += "<Links ID=\"$LINKS_ID$\" IDList=\"$ID_LIST_LINKS$\">\n"
				lid = []
				sl = ""
				#~ @links,@images,@text = get_preq(block.elements)
				@links,@images,@text = [],[],[]
				
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

	def to_xml
	src = ""
	src += "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\" ?>\n"
	src += "<XML>\n"
		src += "<Document url=\"#{escape_html(@document.url.gsub('"',''))}\" algorithm=\"bom2.1\" Title=\"#{escape_html(@document.title)}\" Version=\"#{@version}\" Pos=\"WindowWidth||PageRectLeft:0 WindowHeight||PageRectTop:0 ObjectRectWith:#{@document.width} ObjectRectHeight:#{@document.height}\">\n"
			i = 1
			@blocks.each do |b|
				src += parse_xml(b,i)
				i+=1
			end
		src += "</Document>\n"
	src += "</XML>\n"
	src 
	end

def start
	doc = Document.new
	doc.loadfile @source_file
	doc.parse
	@document = doc.document
	@window = doc.window
	maxdepth = 0
	doc.elements.each do |e|
		if (e.node.path != "/html") && !e.node.path.include?("/html/head") && e.node.path != "/html/body"
			bb = Block.new(e)
			@blocks.push bb
			if bb.depth > maxdepth
				maxdepth = bb.depth
			end
			puts bb
		end
	end
	
	paso = 1
	p k_text = @granularity
	p k_area = @granularity

	ant = 0
	begin
		ant = @blocks.size
		puts "PASS #{paso} #{@blocks.size} #{maxdepth}"
		$stdin.read
		1.upto(@blocks.size-1) do |i|
			next if @blocks[i].nil?
			next if @blocks[i].depth < maxdepth
			#~ puts "="*80
			#~ p ["(#{(i-1)},#{i})",@blocks[i-1].text_density,@blocks[i].text_density,@blocks[i].text_dif(@blocks[i-1]),"<Ktext",@blocks[i].text_dif(@blocks[i-1])<k_text]
			#~ p ["(#{(i-1)},#{i})",@blocks[i-1].area_density,@blocks[i].area_density,@blocks[i].area_dif(@blocks[i-1]),"<Karea",@blocks[i].area_dif(@blocks[i-1])<k_area]
			bi = @blocks[i]
			bant = @blocks[i-1]
			if (((bi.text_density == bant.text_density) && (bi.text_dif(bant) < k_text)) || 
			   ((bi.area_density == bant.area_density) && (bi.area_dif(bant) < k_area)) )
				p [@blocks[i].paths,@blocks[i].text_density,@blocks[i].area_density,@blocks[i].depth]
				p "merged #{i} #{i-1} #{@blocks[i-1]} --- #{@blocks[i]}"
				@blocks[i].merge_with(@blocks[i-1])
				@blocks[i-1] = nil
				#~ $stdin.read
			end
		end
		@blocks.delete(nil)
		maxdepth -= 1
		paso+=1
	end until ant==@blocks.size or maxdepth == 0
	
	
	#~ @blocks.each do |b|
		#~ p [b.paths,b.text_density,b.area_density]
	#~ end
	
	
end

end


class Element
	attr_accessor :blocks,:text_density,:area_density,:node
	def initialize(elem)
		@node = elem
		#~ @blocks = []
		@text_density = 0
		@area_density = 0
	end
	def parse
		unless @node.children.nil?
			line_break_elements = 0
			inline_elements = 0
			text_elements = 0
			areacum = 0.0
			if @node.element?
				@node.children.each do |child|
					if child.text?
						@text_density += parse_text(child.content) / @node.children.size.to_f
						text_elements += 1
					else
						if line_break?(child)
							areacum += area(child)
							line_break_elements+=1
						else
							inline_elements+=1
						end
					end
				end
			elsif @node.text?
				@text_density += parse_text(@node.content)
				text_elements += 1
			else
			end
			an = area(@node)
			if line_break_elements != 0 && an!=0
				@area_density = (areacum / an) * line_break_elements.to_f
			end
			if text_elements != 0
				@text_density /= text_elements.to_f
			end
			#~ p [@node.class,@node.path,@text_density,@area_density] if @area_density > 0
		else
			puts "NO CHILDREN"
			raise "stop"
		end

		#~ p [@node['id'],@density,@node.path,@words.size,@lines.size]
	end
	
	def parse_text(string)
		words = clean(string).split(/\W+/).collect {|x| x.strip}
		count = 0
		line = []
		lines = []
		words.each do |word|
			if word.strip!=""
				#~ p [word,word.size,count]
				if (count+word.size)>80
					lines.push current=TextBlock.new(line,@node)
					current.parse
					line=[]
					count=0
				else
					line.push word
					count += word.size
				end
			end
		end
		lines.push current=TextBlock.new(line,@node)
		current.parse

		#~ p lines.size
		#~ pp = lines.size>1
		unless lines.size<1
			1.upto(lines.size-1).each do |k|
				lines[k].merge(lines[k-1])
				lines[k-1]=nil
			end
			lines.delete(nil)
		end
		
		#~ $stdin.read if pp
		return lines.first.density
	end
	
	def merge(other_element)
		#~ @data = other_block.data + @data
		#~ parse
	end
end
class Block
	attr_accessor :elements,:text_density,:area_density,:left,:top,:width,:height,:childnodes,:depth
	def initialize(element)
		@elements = [element]
		@text_density = element.text_density
		@area_density = element.area_density

		@childnodes = element.node["childnodes"].to_i
		
		@left = element.node["elem_left"].to_i
		@top = element.node["elem_top"].to_i
		@width = element.node["elem_width"].to_i
		@height = element.node["elem_height"].to_i
		@depth = element.node.path.split("/").size
	end
	def merge_with(other_block)
		@elements += other_block.elements
		@text_density = (@text_density+other_block.text_density)/2.0
		@area_density = (@area_density+other_block.area_density)/2.0
		
		@left = [@left,other_block.left].min
		@top = [@top,other_block.top].min
		@width = [@width,other_block.width].max
		@height = [@height,other_block.height].max
		
		@childnodes += other_block.childnodes
		@depth = [@depth,other_block.depth].min
		
	end
	def text_dif(other_block)
		m = [@text_density,other_block.text_density].max
		if m==0
			return 0
		else
			return (@text_density-other_block.text_density).abs / m
		end
	end
	def area_dif(other_block)
		m = [@area_density,other_block.area_density].max
		if m==0
			return 0
		else
			return (@area_density-other_block.area_density).abs / m
		end
	end
	def paths
		@elements.collect{|x|x.node.path}
	end
	def to_s
		"AD:#{@area_density} TD:#{@text_density} D:#{@depth} POS:(#{@left},#{@top},#{@width},#{@height}) CN:#{@childnodes} P:#{paths.join(",")}"
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
	def to_s
		"TB:#{@density} W:#{@words}"
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
		@html.search("*").each do |e|
		#~ @html.search("//node()[not(node())] | //text()").each do |e|
			el = e
			#~ el = e.parent if e.text?
			#~ if el.element?
				if el["visited"].nil?
					unless ['script','style','link','meta'].include? el.name.downcase 
						#~ if clean(e.content)!=""
							@elements.push current = Element.new(el)
							current.parse
							#~ puts current.text_density
							el["visited"]="true"
						#~ end
					end
				end
			#~ end
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


def area(node)
cx = node["elem_width"].to_f / 2
cy = node["elem_height"].to_f / 2

r = Math.sqrt(cx**2 + cy**2)

angle = Math.asin(cy/r)

return (4*(r**2)*Math.sin(2*Math::PI/4))/2
end

def relative_area(node1,node2)
	a = area(node1)/area(node2)
	a = 1 if a>1
	return a
end
