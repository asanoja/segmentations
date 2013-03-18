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

def parse1(input,output_folder)
	input_file = File.open(input)
	$doc = Nokogiri::HTML(input_file)
	$struc = []
	$cont=0
	traverse($doc.at("body"),nil,0)
	
	processed = -1
	
	File.open("output/dbg/sv#{$g}.dot","w") {|f| f.puts $struc[0].to_dot}
	system "dot -Tsvg output/dbg/sv#{$g}.dot > output/dbg/sv#{$g}.svg"
	File.open("output/dbg/sv#{$g}.txt","w") {|f| f.puts $struc[0].to_list}
	$g+=1
	pDist=0
	until processed==0
		processed = 0
		0.upto($struc.size-1) do |i|
			if $struc[i].distance <= pDist and !$struc[i].parent.nil? and $struc[i].children==[]
				puts "T:#{$struc[i].tag}(#{$struc[i].section}) ET:#{$struc[i].entropy} P:#{$struc[i].parent.tag} EP:#{$struc[i].parent.entropy} D:#{$struc[i].distance}" 
				unless $struc[i].entropy==0
					$struc[i].parent.entropy = ($struc[i].parent.entropy+$struc[i].entropy) / 2
					$struc[i].parent.distance = dist($struc[i].parent)
				end
				puts "#{$struc[i].parent.entropy} #{$struc[i].parent.distance}" 
				$struc[i].node["style"] = ""
				$struc[i].parent.children.delete($struc[i])
				puts "processed leave T:#{$struc[i].tag} P:#{$struc[i].parent.tag}" 
				$struc[i] = nil
				processed+=1
			end
		end
		$struc.delete(nil)
		puts "#{processed} of #{$struc.size}"
		File.open("output/dbg/sv#{$g}.dot","w") {|f| f.puts $struc[0].to_dot}
		system "dot -Tsvg output/dbg/sv#{$g}.dot > output/dbg/sv#{$g}.svg"
		File.open("output/dbg/sv#{$g}.txt","w") {|f| f.puts $struc[0].to_list}
		$g+=1
	end
	processed
end

def parse2(input,output_folder)
	processed = -1
	
	File.open("output/dbg/sv#{$g}.dot","w") {|f| f.puts $struc[0].to_dot}
	system "dot -Tsvg output/dbg/sv#{$g}.dot > output/dbg/sv#{$g}.svg"
	File.open("output/dbg/sv#{$g}.txt","w") {|f| f.puts $struc[0].to_list}
	$g+=1
	pDist=0
	until processed==0
		processed = 0
		0.upto($struc.size-1) do |i|
		#OJO QUEDE ACA HAY QUE TOMAR EN CUENTA EL CASO DE LOS NODOS ONCHILD CUYA ENTROPIA ES MAYPR QUE CERO Y SU DISTANCIA TAMBIEN
		#VER EN EL BROWSER EL NODO 42,45,46 PARA RECORDARME
			if !$struc[i].parent.nil? and $struc[i].parent.children.size==1 and $struc[i].children==[]
				if $struc[i].entropy >= $struc[i].parent.entropy
					puts "LINEAR REMOVE PARENT"
					puts "T:#{$struc[i].tag}(#{$struc[i].section}) ET:#{$struc[i].entropy} P:#{$struc[i].parent.tag} EP:#{$struc[i].parent.entropy} D:#{$struc[i].distance}" 
					hijo = $struc[i]
					padre = $struc[i].parent
					abuelo = $struc[i].parent.parent
					pind = abuelo.children.index(padre)
					
					unless pind.nil?
						$struc[i].parent.parent.children[pind] = $struc[i]
						$struc[i].parent.children=[] #to be sure
						$struc[i].parent.parent = nil #to be sure
						$struc[i].parent = nil #to be sure
						$struc[i].parent = abuelo
						processed+=1
					end
				else
					puts "LINEAR REMOVE CHILD"
					puts "T:#{$struc[i].tag}(#{$struc[i].section}) ET:#{$struc[i].entropy} P:#{$struc[i].parent.tag} EP:#{$struc[i].parent.entropy} D:#{$struc[i].distance}" 
					$struc[i].parent.children.delete($struc[i])
					$struc[i] = nil
					processed+=1
				end
			else
				unless $struc[i].nil?
					unless $struc[i].parent.nil?
						puts "SKIPPED T:#{$struc[i].tag}(#{$struc[i].section}) ET:#{$struc[i].entropy} D:#{$struc[i].distance}"
					else
						puts "SKIPPED ORPHAN T:#{$struc[i].tag}(#{$struc[i].section}) ET:#{$struc[i].entropy} D:#{$struc[i].distance}"
					end
					if [45,46].include? $struc[i].section
						puts "CASO"
						#exit
					end
				end
			end
		end
		$struc.delete(nil)
		puts "#{processed} of #{$struc.size}"
		File.open("output/dbg/sv#{$g}.dot","w") {|f| f.puts $struc[0].to_dot}
		system "dot -Tsvg output/dbg/sv#{$g}.dot > output/dbg/sv#{$g}.svg"
		File.open("output/dbg/sv#{$g}.txt","w") {|f| f.puts $struc[0].to_list}
		$g+=1
	end
	processed
end

def parse3(input,output_folder)
	processed = -1
	File.open("output/dbg/sv#{$g}.dot","w") {|f| f.puts $struc[0].to_dot}
	system "dot -Tsvg output/dbg/sv#{$g}.dot > output/dbg/sv#{$g}.svg"
	File.open("output/dbg/sv#{$g}.txt","w") {|f| f.puts $struc[0].to_list}
	$g+=1
	pDist=0
	until processed==0
		processed = 0
		0.upto($struc.size-1) do |i|
			unless $struc[i].nil?
				if !$struc[i].parent.nil? and $struc[i].distance == 0
					puts "EMPTY DISTANCE REMOVE NODE"
					puts "T:#{$struc[i].tag}(#{$struc[i].section}) ET:#{$struc[i].entropy} P:#{$struc[i].parent.tag} EP:#{$struc[i].parent.entropy} D:#{$struc[i].distance}" 
					delete_recursive(i)
					processed+=1
				end
			end
		end
		$struc.delete(nil)
		puts "#{processed} of #{$struc.size}"
		File.open("output/dbg/sv#{$g}.dot","w") {|f| f.puts $struc[0].to_dot}
		system "dot -Tsvg output/dbg/sv#{$g}.dot > output/dbg/sv#{$g}.svg"
		File.open("output/dbg/sv#{$g}.txt","w") {|f| f.puts $struc[0].to_list}
		$g+=1
	end
	processed
end

def delete_recursive(i)
	puts $struc[i].tag
	unless $struc[i].children==[]
		$struc[i].children.each do |child|
			k = $struc.index(child)
			delete_recursive(k)
		end
	end
	unless $struc[i].parent.nil?
		$struc[i].parent.children.delete($struc[i])
	end
	$struc[i] = nil
end

$tag_codes = {}
File.open("taglist.txt").readlines.collect {|s| s.split(" ")}.each do |e|
	$tag_codes[e[0]] = e[1].to_i
end

$doc = nil
$g = 1

processed = -1
until processed==0
	processed = 0
	processed += parse1("output/wp.html","output")
	processed += parse2("output/wp.html","output")
	processed += parse3("output/wp.html","output")
end

$struc.each do |e|
	e.node["type"]="candidate"
	e.node["style"] = "border-style:solid;border-width:1px;border-color:red"
end

File.open("output/sv.xml","w") {|f| f.puts $struc[0].to_xml}	
File.open("output/sv.csv","w") {|f| f.puts $struc[0].to_csv}
File.open("output/sv.dot","w") {|f| f.puts $struc[0].to_dot}
system "dot -Tsvg output/sv.dot > output/sv.svg"
File.open("output/sv.html","w") {|f| f.puts $doc}
