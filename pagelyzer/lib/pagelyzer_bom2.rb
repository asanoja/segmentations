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


class BlockOMatic

	attr_accessor :type,:document,:window,:source_file,:document_area, :error
	attr_accessor :doc_rel,:doc_proportion, :pdoc,:target_path,:next_block_id,:debug
	
	def initialize
		@window = Dimension.new
		@document = Dimension.new
		@screenshot = Dimension.new
		@max_weight = 0
		@heuristics = []
		@next_block_id = 10000
		@gid = 1
		@block_count = 0
		@job_id = 0
		@browser_id = 0
		@source_file = nil
		@output_file = nil
		@document_area = 0.0
		@debug = false
		@granularity = 0.4
		@doc_proportion = 1
		@target_path = "./"
		@type = :file
		@blocks = []
		@type = :file
		@error = false
		@segmented_page = nil
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
	@granularity = n/10
end

def mark(node,d)
	elem = d.at(node.path)
	unless elem.nil?
		d.xpath(node.path).first['style'] = "border: solid 2px red"
		d.xpath(node.path).first['title'] = "#{node.path} - #{node["id"]}"
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

def evalnode(elem,gratio,body,tr,ta,kl,kr)
	
	return false if elem.is_a? Nokogiri::HTML::Document
	return false if ['html'].include? elem.name.downcase
	return false unless elem['visited'].nil?
	return false if !visible?(elem) and !text?(elem)
	return false if text?(elem) and elem.inner_text.squeeze(" ").gsub("\n","").strip.size==0

	newblock = true

	rdocarea = relative_area(elem,body)
	parent_area = relative_area(elem,elem.parent)
	elem_area = area(elem)
	

	
	lclose = false
	
	if ((elem.parent['elem_left'].to_f - elem['elem_left'].to_f).abs < kl) and 
	   ((elem.parent['elem_width'].to_f - elem['elem_width'].to_f).abs < kr) 
		lclose = true
	end
	
	lelem = elem.path.split("/").size
	telem = elem.inner_text.squeeze(" ").gsub("\n","").strip.size
	ds = ""
	ds += "Element: '#{elem['id']}' at #{elem.path} (#{elem["elem_left"]} #{elem["elem_top"]} #{elem["elem_width"]} #{elem["elem_height"]}), E.area: #{elem_area}, P.area: #{area(elem.parent)}, Rel.area: #{parent_area}, RelDoc.area: #{rdocarea}\n" if @verbose
		
	if ((parent_area>=tr or elem_area>=ta) and lclose) 
		if lclose
			ds+="      NB1: it is at parent limits\n" if @verbose
		else
			ds+="      NB1: it is relevant into parent area or whole length element\n" if @verbose
		end
	else
		ds+="      NB1: not relevant into parent area or whole length element\n" if @verbose
		newblock=false
	end
	if (rdocarea>0.1 or lclose) 
		if lclose
			ds+="      NB2: it is at parent limits\n" if @verbose
		else
			ds+="      NB2: it is a significat block respect page: #{rdocarea}\n" if @verbose
		end
	else
		ds+="      NB2: not significat block respect page\n" if @verbose
		newblock=false
	end
	if lelem <= gratio 
		ds+="      NB3: it is inside the granularity\n" if @verbose
	else
		ds+="      NB3: not into the granularity for\n" if @verbose
		newblock=false
	end
	if telem>0 
		ds+="      NB4: it has siginificant text size\n" if @verbose
	else
		ds+="      NB4: has not siginificant text size\n" if @verbose
		newblock=false if text?(elem)
	end
	if visible?(elem)
		ds+="      NB5: it is visible\n" if @verbose
	else
		ds+="      NB5: not visible\n" if @verbose
		newblock=false
	end
	File.open("debug.txt",'a') {|f| f.puts ds} if @verbose
	newblock
end

def visited?(elem)
	!elem['visited'].nil?
end

def start
	File.open("debug.txt",'w') {|f| f.puts ""} if @verbose
	begin
		doc = load(self,@source_file,:content)
	rescue
		puts "ERROR: There was a problem loading the page #{$!}"
		@error=true
		return self
	end
	#doc = normalize_DOM(self,doc)
	lpath = 0
	
	doc.search("*").each do |elem|
		lpath=elem.path.split("/").size if elem.path.split("/").size > lpath
	end

	gratio = lpath * @granularity

	puts "using #{gratio} is the #{@granularity} of #{lpath} " #if @verbose

	seg = Nokogiri::HTML(File.open(@source_file.gsub(".dhtml",".html")))

	blocks = []
	
	tr = @granularity #relative thrershold for are of elements
	ta = 133000 #absolute thrershold for are of elements
	kl = 1 #threshold of left/top horizonal/vertical limits of elements to parent
	kr = 1 #threshold of right/bottom horizonal/vertical limits of elements to parent
	tt = 20000 #amount of text words considered significative
	tw = 0 #gratio / lpath #threshold for weight of partition

	body = doc.at('body')

	#doc.search("//*[count(child::*) <= 1]").each do |elem|
	
	doc.search("//*[not(child::*)] | //text()").each do |elem|
		if ["head","meta","link","script"].include? elem.name
			puts "SKIPPED TAG #{elem['id']} #{elem.path} (#{elem["elem_left"]} #{elem["elem_top"]} #{elem["elem_width"]} #{elem["elem_height"]})" if @verbose
			next 
		end
		
		if !elem['visited'].nil?
			puts "VISITED TAG #{elem['id']} #{elem.path} (#{elem["elem_left"]} #{elem["elem_top"]} #{elem["elem_width"]} #{elem["elem_height"]})" if @verbose
			next 
		end
		
		puts "="*80 if @verbose
		File.open("debug.txt",'a') {|f| f.puts "="*80} if @verbose
		
		cur = elem
		good_partition = false
		gp_obj = nil
		rooted = false
		partitions = []
		
		while !rooted and !good_partition and !visited?(cur)
			puts "IN #{cur.path} #{cur["id"]} #{cur["class"]}" if @verbose
			er = evalnode(cur,gratio,body,tr,ta,kl,kr)
			File.open("debug.txt",'a') {|f| f.puts "IN #{cur.path} #{er}"} if @verbose
			siblings = cur.xpath('../*')
			if er
				#puts "NEW BLOCK #{elem['id']} #{elem.path} (#{elem["elem_left"]} #{elem["elem_top"]} #{elem["elem_width"]} #{elem["elem_height"]})" if @verbose
				
				invalids = 0
				signodes = 1 #including cur already validated
				text = 0
				partition_quality = 0
				candidates=[]
				rarea = 0
				aarea = 0
				
				siblings.each do |si|
					unless si==cur
						if evalnode(si,gratio,body,tr,ta,kl,kr)
							signodes+=1 
							candidates.push si
						end
						unless visible?(si)
							invalids+=1
						end
						if text?(si) 
							cnt = sanitize_text(si.content)
							words = cnt.split(" ")
							words.delete(nil)
							words.delete("")
							if words.size > tt
								text+=1
							end
						end
						if !text?(si) and visible?(si)
							rarea += relative_area(si,si.parent)
						end
					end
				end
				
				if (siblings.size-invalids)==0
					partition_quality = 0
				else
					partition_quality = signodes.to_f / (siblings.size-invalids)
				end
				
				if siblings.size>0 
					aarea = rarea / siblings.size
				end

				File.open("debug.txt",'a') {|f| f.puts "DD #{cur.path} RA:#{aarea}"}
				if partition_quality>=0.9 or aarea>(1-@granularity)
					good_partition=true
					partitions.push ([{:elem=>cur,:weight=>partition_quality}] + candidates.collect {|si| {:elem=>si,:weight=>partition_quality}}).flatten
				else
					if cur.is_a? Nokogiri::HTML::Document
						rooted = true
					else
						if ['html'].include?(cur.name)
							rooted = true
						else
							partitions.push ([{:elem=>cur,:weight=>partition_quality}] + candidates.collect {|si| {:elem=>si,:weight=>partition_quality}}).flatten
							cur = cur.parent
						end
					end
				end
			else
				if cur.is_a? Nokogiri::HTML::Document
					rooted = true
				else
					if ['html'].include?(cur.name)
						rooted = true
					else
						cur = cur.parent
					end
				end
			end
		end #while
		

		minw = 0
		gp = []
		#puts "part"
		#puts partitions.collect {|x| "#{x[0][:elem].path} #{x[0][:weight]}"}
		
		partitions.each do |p|
			if p[0][:weight].to_f > minw
				min_w = p[0][:weight].to_f
				gp = p
			end
		end
		
		gp.each do |nb|
			puts "NEW SBLOCK #{nb[:elem].path} W:#{nb[:weight]}" if @verbose
			File.open("debug.txt",'a') {|f| f.puts "NEW SBLOCK #{nb[:elem].path} W:#{nb[:weight]} #{cur["id"]} #{cur["class"]}"}
			isin=false
			@blocks.each do |b|
				if b[:elem].path  == nb[:elem].path
					isin=true
					break
				end
			end
			@blocks.push nb unless isin
		end
#~ sleep(1) if partitions.size>0
		elem['visited']=1
	end #each
	
	puts "====  BLOCKS ====" if @verbose
	@blocks = @blocks.uniq
	i=1
	@blocks.each do |nb|
		b = nb[:elem]
		w = nb[:weight]
		puts "Block#{i} #{b.path} #{b["id"]} #{b["class"]} (#{b["elem_left"]} #{b["elem_top"]} #{b["elem_width"]} #{b["elem_height"]}) W:#{w}" if @verbose
		mark(b,seg)
		i+=1
	end

	@segmented_page = seg
	return self
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
		block = blockpack[:elem]
		weight = blockpack[:weight]
		l = block["elem_left"].to_i
		t = block["elem_top"].to_i
		w = block["elem_width"].to_i 
		h = block["elem_height"].to_i
		
		src+= "<Block Ref=\"Block#{sid}\" internal_id='#{@id}' ID=\"$BLOCK_ID$\" Pos=\"WindowWidth||PageRectLeft:#{l} WindowHeight||PageRectTop:#{t} ObjectRectWidth:#{w} ObjectRectHeight:#{h}\" Doc=\"#{@granularity}\">\n"
			src += "<weight>\n"
			src += "#{weight}\n"
			src += "</weight>\n"
			src += "<Paths>\n"
			
			am = 0
			block.traverse {|node| am+=1}
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

	def to_xml
	src = ""
	src += "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\" ?>\n"
	src += "<XML>\n"
		src += "<Document url=\"#{escape_html(@document.url.gsub('"',''))}\" Title=\"#{escape_html(@document.title)}\" Version=\"#{@version}\" Pos=\"WindowWidth||PageRectLeft:#{@document.width} WindowHeight||PageRectTop:#{@document.height} ObjectRectWith:0 ObjectRectHeight:0\">\n"
			i = 1
			@blocks.each do |b|
				src += parse_xml(b,i)
				i+=1
			end
		src += "</Document>\n"
	src += "</XML>\n"
	src 
	end

end
