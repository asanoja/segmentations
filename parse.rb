require 'nokogiri'
require './item.rb'

def traverse(node,parent,level)
	node.inner_html = node.inner_html.gsub(/\n/,'').strip
	$cont+=1
	current = Item.new(node,level,$cont,parent)
	$struc.push current
	unless node.children.empty? 
		node.children.each do |child|
			if child.text?
				if child.content.strip != ""
					$cont+=1
					$struc.push Item.new(child,level,$cont,current)
				end
			else
				traverse(child,current,level+1) 
			end
		end
	end
end

def parse(cat,input,output_folder,tags)
	input_file = File.open(input)
	doc = Nokogiri::HTML(input_file)
	$struc = []
	$cont = 0
	partitions = 6

	$struc.push Item.new(doc.at("body"),0,0,nil,false)
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
	
		$total[e.nsection.round,e.nlevel.round]+=1
		
		if e.node.text?
			File.open("#{output_folder}/text.csv","a") {|o|
				o.puts "#{e.nsection},#{e.nlevel}"
			}
		elsif e.node.comment?
			File.open("#{output_folder}/comment.csv","a") {|o|
				o.puts "#{e.nsection},#{e.nlevel}"
			}
		else
			if tags.include? e.node.name
				File.open("#{output_folder}/#{e.node.name.downcase}.csv","a") {|o|
					o.puts "#{e.nsection},#{e.nlevel}"
				}
			end
		end
	end

	input_file.close
	
end
