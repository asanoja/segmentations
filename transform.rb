require 'nokogiri'
require './item.rb'
require './matrix.rb'

def traverse(node,parent,level)
	node.inner_html = node.inner_html.gsub(/\n/,'').strip
	$cont+=1
	current = Item.new(node,level,$cont,parent,true)
	$struc.push current
	unless node.children.empty? 
		node.children.each do |child|
			ch=nil
			if child.text?
				if child.content.strip != ""
					ch = Item.new(child,level,$cont,current,true)
					$cont+=1
					$struc.push ch
					current.children << ch
				end
			else
				current.children << traverse(child,current,level+1) 
			end
		end
	end
	return current
end

def dist(item)
	d = item.entropy * $tag_codes[item.tag]
	return d
end

def parse(input,output_folder)
	input_file = File.open(input)
	doc = Nokogiri::HTML(input_file)
	$struc = []
	$cont=0
	traverse(doc.at("body"),nil,0)
	
	processed = -1
	g=1
	File.open("output/dbg/sv#{g}.dot","w") {|f| f.puts $struc[0].to_dot}
	system "dot -Tsvg output/dbg/sv#{g}.dot > output/dbg/sv#{g}.svg"
	g+=1
	until processed==0
		processed = 0
		1.upto($struc.size-1) do |i|
			if $struc[i].distance == 0 and !$struc[i].parent.nil? and $struc[i].children==[]
				puts "T:#{$struc[i].tag} P:#{$struc[i].parent.tag} D:#{$struc[i].distance}"
				unless $struc[i].entropy==0
					$struc[i].parent.entropy = ($struc[i].parent.entropy+$struc[i].entropy) / 2
					$struc[i].parent.distance = dist($struc[i])
				end
				$struc[i].node["style"] = ""
				$struc[i].parent.children.delete($struc[i])
				puts "processed leave T:#{$struc[i].tag} P:#{$struc[i].parent.tag}"
				$struc[i] = nil
				processed+=1
			elsif $struc[i].children.size==1
				#puts "processed onechild T:#{$struc[i].tag} P:#{$struc[i].parent.tag}"
				#puts "T:#{$struc[i].tag} P:#{$struc[i].parent.tag} D:#{$struc[i].distance}"
			end
			
		end
		puts $struc.size
		$struc.delete(nil)
		puts $struc.size
		puts "#{processed}"
		File.open("output/dbg/sv#{g}.dot","w") {|f| f.puts $struc[0].to_dot}
		system "dot -Tsvg output/dbg/sv#{g}.dot > output/dbg/sv#{g}.svg"
		g+=1
	end
	
	File.open("output/sv.xml","w") {|f| f.puts $struc[0].to_xml}
	File.open("output/sv.csv","w") {|f| f.puts $struc[0].to_csv}
	File.open("output/sv.dot","w") {|f| f.puts $struc[0].to_dot}
	File.open("output/sv.html","w") {|f| f.puts doc}
end

$tag_codes = {}
File.open("taglist.txt").readlines.collect {|s| s.split(" ")}.each do |e|
	$tag_codes[e[0]] = e[1].to_i
end
parse("output/wp.html","output")
