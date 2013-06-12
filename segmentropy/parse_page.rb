require 'nokogiri'
require './item.rb'
require './matrix.rb'
require 'fileutils'

def traverse(node,parent,level)
	node.inner_html = node.inner_html.gsub(/\n/,'').strip
	$cont+=1
	current = Item.new(node,level,$cont,parent)
	$struc.push current
	unless node.children.empty?
		node.children.each do |child|
			if child.text?
				if child.content.strip != ""
					$struc.push Item.new(child,level,$cont,current)
				end
			else
				traverse(child,current,level+1) 
			end
		end
	end
end

def getpath(element)
	unless element.parent.nil?
		return getpath(element.parent)+[element.to_vector]
	else
		return [element.to_vector]
	end
end

def parse(cat,input,output_folder)
	input_file = File.open(input)
	
	unless File.exists? output_folder
		FileUtils.mkdir_p output_folder
	end
	
	doc = Nokogiri::HTML(input_file)
	$struc = []
	$cont = 0
	partitions = 6
	fa = 0

	$struc.push Item.new(doc.at("body"),0,nil)
	puts "processing DOM tree"
	traverse(doc.at("body"),nil,0)

	tp = $struc.size.to_f 
	td = $struc.collect{|e| e.level}.max.to_f

	puts "normalizing values for #{tp} elements, #{td} levels"

	$struc.each do |e| 
		unless td==0
			e.nsection = e.level * partitions / td
		else
			e.nsection = 0
		end
	
		unless tp==0
			e.nlevel = e.section * partitions / tp
		else
			e.nlevel = 0
		end


		tags = []
		File.open("taglist.txt").each_line do |tag|
			File.open("#{output_folder}/#{tag.strip.downcase}.csv","w")
			tags.push tag.strip.downcase
		end
	
		acum = 0.0
	
		if e.node.text?
			File.open("#{output_folder}/text.csv","a") {|o|
				o.puts "#{e.nsection},#{e.nlevel}"
			}
		else
			if tags.include? e.node.name
				File.open("#{output_folder}/#{e.node.name.downcase}.csv","a") {|o|
					o.puts "#{e.nsection},#{e.nlevel}"
				}
			end
		end
		
		if File.exists? "data/#{cat}/#{e.node.name.strip.downcase}.prob"
			rfm = Matrix.new(7,7,0)
			rfm.load("data/#{cat}/#{e.node.name.strip.downcase}.prob")
			unless rfm.nil?
				e.prob = rfm[e.nsection.round,e.nlevel.round]
			end
			vxp = getpath(e)
			p = vxp.collect {|x| x[1]}.reduce(0) {|acum,v| acum+=v} / vxp.size
			fa+=p
		end
			
	end
	score =  fa / $struc.size
	input_file.close
	return "#{cat}: #{score}"
end

#parse(ARGV[0],ARGV[1],"output/wp")
