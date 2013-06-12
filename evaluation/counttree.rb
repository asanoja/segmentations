require 'nokogiri'
require_relative './item.rb'
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

$struc = []
$cont = 0

input = ARGV[0]
puts xpath = ARGV[1]

input_file = File.open(input)
doc = Nokogiri::HTML(input_file)
traverse(doc.at(xpath),nil,0)
puts "Under #{xpath} there are #{$struc.size} elements"
#puts $struc.collect {|x| x.node.name}
