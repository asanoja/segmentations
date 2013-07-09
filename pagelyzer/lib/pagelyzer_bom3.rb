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
		@root = nil
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

def start
	@doc = load(self,@source_file,:file)
	@root = Block.new
	@root.add_element(@doc.at('body'))
	process(@doc.at('body'),@root)
	@root.children.each do |block|
		block.process_geometry
		puts block
	end
end

def process(node,target_block)
	return if node.comment?
	return unless node["visited"].nil?
	node["visited"] = true
	#~ siblings = node.search("../*")
	#~ return siblings.collect {|x| !x["mark"].nil?}.uniq.include? true
		#~ #add this as block for partition
		#~ puts "rule 10 #{node.path} #{node["id"]}"
		#~ node["mark"]="true"
		#~ nb = Block.new
		#~ nb.rule = 10
		#~ nb.granularity = 6
		#~ nb.add_element(node)
		#~ target_block.add_children(nb)
		#~ return
	#~ end
	
	children = node.search("./*")
	#p [node.path,children.size]
	if children.size == 0
		if text?(node)
			target_block.add_element(node) #????
		end
	elsif children.size == 1 and valid?(children.first) and !text?(children.first)
		puts "rule 2 #{node.path} #{node["id"]}"
		process(children.first,target_block) if children.first["visited"].nil?
		return
	elsif children.size > 1
		vt=0
		ws=0
		txt=0
		bg=false
		bgchild=nil
		vtchild=nil
		areachild=nil
		area=0
		divide = false
		tarea = 0.8
		children.each do |child|
			return unless child["visited"].nil?
			if text?(child)
				if child.content.strip == ""
					ws+=1
				else
					txt+=1
					vtchild = child
				end
			else
				if virtual_text?(child)
					vtchild = child
					vt+=1 
				end
				#~ p [child["background_color"],node["background_color"]]
				#~ $stdin.read
				if bgchild.nil? && (child["background_color"] != node["background_color"]) && (!node["background_color"].nil?)
					bg=true 
					bgchild = child
				end
			end
			if area(child)/area(node) > area
				area = area(child)/area(node)
				areachild = child
			end
		end
		#~ p [vt,txt,children.size,ws]
		if vt+txt == children.size - ws
			puts "rule 4 #{node.path} #{node["id"]}"
			nb = Block.new
			nb.add_element(node)
			nb.rule = 4
			nb.granularity = 10 #9 si hay alguno con letra diferente
			target_block.add_children(nb)
		elsif bg
			puts "rule 7 #{bgchild.path} #{bgchild["id"]}"
			#add node as block and divide
			nb = Block.new
			nb.add_element(node)
			nb.rule = 7
			nb.granularity = 6
			target_block.add_children(nb)
			divide=true
		elsif (txt>0 || vt>0) && !vtchild.nil?
			puts "rule 8 #{vtchild.path} #{vtchild["id"]} #{area(vtchild)} / #{area(node)} = #{relative_area(vtchild,node)}"
			if area(node)/area(node.parent) > tarea
				nb = Block.new
				nb.rule = 8
				nb.granularity = 8
				nb.add_element(node)
				target_block.add_children(nb)
			else
				divide = true
			end
		elsif area < tarea 
			nb = Block.new
			nb.add_element(node)
			nb.rule = 9
			nb.granularity = (area*10).to_i
			target_block.add_children(nb)
		end
		
		if divide
			puts "rule 11 #{node.path} #{node["id"]}"
			children.each do |child|
				process(child,target_block) if child["visited"].nil?
			end
		end
	end
end

def to_xml
	src = ""
	src += "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\" ?>\n"
	src += "<XML>\n"
		src += "<Document url=\"#{escape_html(@document.url.gsub('"',''))}\" algorithm=\"bom3\" Title=\"#{escape_html(@document.title)}\" Version=\"#{@version}\" Pos=\"WindowWidth||PageRectLeft:0 WindowHeight||PageRectTop:0 ObjectRectWith:#{@document.width} ObjectRectHeight:#{@document.height}\">\n"
		src += @root.to_xml
		src += "</Document>\n"
	src += "</XML>\n"
	src 
	end

end


class Block
	attr_accessor :children,:rule,:granularity
	def initialize
		@elements = []
		@children = []
		@sid = ""
		@rule = 0
		@geometry = {:left=>0,:top=>0,:width=>0,:height=>0}
		@granularity = 0
	end
	def add_element(element)
		@elements.push(element)
		element.search("../node()").each do |sibling|
			next if sibling==element
			if text?(sibling)
				if sibling.content.strip==""
					#whitespace
				else
					unless sibling.comment?
						@elements.push sibling
					end
				end
			else
				unless sibling.comment?
					@elements.push sibling
				end
			end
		end
	end
	def add_children(block)
		@children.push block
	end
	def process_geometry
		inf = 1.0/0.0
		 @geometry[:left] = @elements.collect {|x| text?(x) ? inf : x['elem_left'].to_i}.min
		 @geometry[:top] = @elements.collect {|x| text?(x) ? inf : x['elem_top'].to_i}.min
		 @geometry[:width] = @elements.collect {|x| text?(x) ? 0 : x['elem_width'].to_i}.max
		 @geometry[:height] = @elements.collect {|x| text?(x) ? 0 :  x['elem_height'].to_i}.max
	end
	def to_s 
		"#{@rule} : #{@children.size} ; #{@geometry} - #{@elements.collect{|x|(x['id'].nil? ? "" : x['id'])+":"+x.path}.join(",")}"
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
	def to_xml
		src = ""
		src+= "<Block Ref=\"Block#{@sid}\" internal_id='#{@id}' ID=\"$BLOCK_ID$\" Pos=\"WindowWidth||PageRectLeft:#{@geometry[:left]} WindowHeight||PageRectTop:#{@geometry[:top]} ObjectRectWidth:#{@geometry[:width]} ObjectRectHeight:#{@geometry[:height]}\" Doc=\"#{@granularity}\">\n"
			src += "<weight>\n"
			src += "#{@granularity}\n"
			src += "</weight>\n"
			
			src += "<Paths>\n"
			
			@elements.each do |c| 
				cn = c["childnodes"].to_i
				cn=1 if cn==0
				src += "<path>#{c.path.strip},#{c["elem_left"]},#{c["elem_top"]},#{c["elem_width"]},#{c["elem_height"]},#{c["id"]},#{c["uid"]},#{cn}</path>\n"
			end
			src += "</Paths>\n"
			
				@links=[]
				@images=[]
				@text=[]
				#ojo temporal ^^^
				
				src += "<Links ID=\"$LINKS_ID$\" IDList=\"$ID_LIST_LINKS$\">\n"
				lid = []
				sl = ""
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
			unless @children.empty?
				@children.each do |child|
					src += child.to_xml
				end
			end
		src += "</Block>\n"
		src.gsub!('$BLOCK_ID$',crypt(src))
		src
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
	return 0 if area(node2)==0
	a = area(node1)/area(node2)
	a = 1 if a>1
	return a
end
