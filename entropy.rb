require 'nokogiri'
require './item.rb'
require './matrix.rb'

def traverse(node,parent,level)
	node.inner_html = node.inner_html.gsub(/\n/,'').strip
	$cont+=1
	current = Item.new(node,level,$cont,parent)
	$struc.push current
	unless node.children.empty? 
		node.children.each do |child|
			ch=nil
			if child.text?
				if child.content.strip != ""
					$cont+=1
					ch = Item.new(child,level,$cont,current)
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

def get_prob(item,cat)
	if File.exists? "data/#{cat}/#{item.node.name}.prob"
		rfm = Matrix.new(7,7,0)
		if item.node.text?
			rfm.load("data/#{cat}/text.prob")
		else
			rfm.load("data/#{cat}/#{item.node.name}.prob")
		end
		return rfm[item.nsection.round,item.nlevel.round].to_f
	else
		return 0
	end

end

def entropy(x)
	if x==0
		return 0
	else
		return -1*x*Math.log2(x)
	end
end

def entropy_inv(x)
	entropy(x)-entropy(1-x)
end

def f(x)
	entropy(x)
end

def dist(item,parent)
	d = item.entropy * $tag_codes[item.tag]
	return d
end

def calc_entropy(item,cat)
	ent = []
	pitem = 0
	if File.exists? "data/#{cat}/#{item.node.name}.prob"
		pitem = get_prob(item,cat)
		item.prob = pitem
		item.node["prob"] = pitem.to_s
		unless item.children==[]
			item.children.each do |child|
				unless child.nil?
					pch = get_prob(child,cat)
					unless pch==0 #remember that 0 log2 0 = 0
						if child.node.text?
							if child.text_size > 5
								ent.push 1
							else
								ent.push f(pch)
							end
						else
							ent.push f(pch)
						end
					else
						ent.push 0
					end
				end
			end
		end
	else
		puts "#{item.node.name}.prob not found"
	end
	
	unless ent==[]
		ve = ent.reduce {|acum,e| acum+=e} / ent.size
	else
		ve = 0
	end
	
	
		if item.node.text? and item.text_size > 5
			centropy =  1
		else
			unless pitem == 0 #idem as above
				eitem = f(pitem)
				centropy =  (eitem + ve) / 2
			else
				centropy = ve
			end
		end
		
	
	return centropy
	
end

def parse(cat,input,output_folder,tags)
	input_file = File.open(input)
	doc = Nokogiri::HTML(input_file)
	$struc = []
	$cont = 0
	partitions = 6

	#$struc.push Item.new(doc.at("body"),0,nil)
	puts "processing DOM tree"
	traverse(doc.at("body"),nil,0)

	tp = $struc.size.to_f 
	td = $struc.collect{|e| e.level}.max.to_f

	puts "normalizing values for #{tp} elements, #{td} levels"

	$struc.each do |e| 
		unless td==0
			e.nlevel = e.level * partitions / td
		else
			e.nlevel = 0
		end
	
		unless tp==0
			e.nsection = e.section * partitions / tp
		else
			e.nsection = 0
		end
		
		unless $tag_codes[e.tag].nil?
			e.entropy = calc_entropy(e,cat)
			e.distance = dist(e,e.parent) unless e.parent.nil?
			e.node["entropy"] = e.entropy.to_s
			e.node["nsection"] = e.nsection.to_s
			e.node["nlevel"] = e.nlevel.to_s
		end
	end

	#normalizing distances
	maxdist = $struc.collect {|e| e.distance}.max
	$struc.each do |e|
		e.distance = e.distance * 10/maxdist
		#if e.distance > 4
		brd = (e.entropy*5).round
		brd = 1 if brd==0
		#e.node["style"] = "border-style:solid;border-width:0px;border-color:red"
		e.node["onmouseover"] = "if (this.type!='') {this.style.borderColor='blue';this.style.borderWidth='thin'}"
		e.node["onmouseout"] = "if (this.type!='') {this.style.borderColor='red';this.style.borderWidth='thin'}"
		e.node["title"] = "E:#{e.entropy.to_s}\nD:#{e.distance.to_s}\nN:#{e.section}"
		e.node["distance"] = e.distance.to_s
		e.node["prob"] = e.prob.to_s
		#end
	end
	

	input_file.close
	File.open("output/wp.xml","w") {|f| f.puts $struc[0].to_xml}
	File.open("output/wp.csv","w") {|f| f.puts $struc[0].to_csv}
	File.open("output/wp.dot","w") {|f| f.puts $struc[0].to_dot}
	File.open("output/wp.html","w") {|f| f.puts doc}
	
end

$tag_codes = {}
File.open("taglist.txt").readlines.collect {|s| s.split(" ")}.each do |e|
	$tag_codes[e[0]] = e[1].to_i
end
parse(ARGV[0],ARGV[1],ARGV[2],"")
