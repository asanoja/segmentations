require 'nokogiri'
Dir.glob("/media/DATA/evaluation/*.html").each do |p|
	doc = Nokogiri::HTML(File.open(p))
	elem = nil
	script = Nokogiri::XML::Node.new("script",doc)
	script['id'] = "script-pl-manual"
	script["src"] = "http://www-poleia.lip6.fr/~sanojaa/SCAPE/pmanual.js"
	
	unless doc.at('head').nil?
		doc.at('head').add_child script
	else
		unless doc.at('html').nil?
			doc.at('html').add_child script
		else
			puts "NILL nothing to do with #{p}"
		end
	end
	File.open(p,'w') {|f| f.puts doc}
end
