require 'nokogiri'
require './classifier.rb'


class Item
	attr_accessor :cX, :cY,:node,:level,:k, :cat
	def initialize(node,level,k=0,cat)
		@node = node
		@level = level
		@cX = cX
		@cY = cY
		@k=k
		@cat=cat
	end
	def to_s
	"#{@name};#{@cX};#{@cY};#{@level};#{k};#{@cat}"
	end
end

def traverse(node,parent,level)
	node.inner_html = node.inner_html.gsub(/\n/,'').strip
	node["tag"] = node.name
	node.name = classify(node)
	if node.name != "content" and node.name != "invalid"
		unless node.children.empty?
			$sc += "#{"   "*level}<#{node.name} tag=\"#{node['tag']}\" uid=\"#{node['uid']}\">\n"
			node.children.each do |child|
				unless child.text?
					 traverse(child,node,level+1) 
				end
			end
			$sc += "#{"   "*level}</#{node.name}>\n"
		else
			$sc += "#{"   "*level}<#{node.name} tag=\"#{node['tag']}\"/>\n"
		end
	else
		if node.name == 'content'
		$sc += "#{"   "*level}<#{node.name} tag=\"#{node['tag']}\" uid=\"#{node['uid']}\"/>\n"
		end
	end
end

$taglist, $lnlist, $ctlist, $invlist = init_lists
input_file = File.open(ARGV[0])
output_file = File.open(ARGV[1],"w")
simple_output = File.open(ARGV[1]+".xml","w")
doc = Nokogiri::HTML(input_file)
puts "processing DOM tree"
$sc = "<html>"
html = traverse(doc.at("body"),nil,0)
$sc += "</html>"
xsl = Nokogiri::XSLT(File.read("format.xslt"))
output_file.puts xsl.apply_to(doc).to_s

simple_output.puts $sc

input_file.close
output_file.close
simple_output.close
