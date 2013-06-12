require 'nokogiri'
require 'cgi'
require 'uri'
File.open("/var/www/rindex.html",'w')

File.open("/var/www/rindex.html",'a') {|a| a.puts "<h1 style='color:red'>Warning: some pages may not be rendered as expected because 'robots.txt' policies</h1>"}

File.open("/var/www/rindex.html",'a') {|a| a.puts "<h1>Categories</h1>"}
File.open("/var/www/rindex.html",'a') {|a| a.puts "<ol>"}

Dir.glob("repository/*").each do |cat|
	File.open("/var/www/rindex.html",'a') {|a| a.puts "<li><a href='##{cat.split("/")[1]}'>#{cat.split("/")[1]}</a></li>"}
end
File.open("/var/www/rindex.html",'a') {|a| a.puts "</ol>"}

File.open("/var/www/rindex.html",'a') {|a| a.puts "<h1>Data</h1>"}
File.open("/var/www/rindex.html",'a') {|a| a.puts "<ol>"}
Dir.glob("repository/*").each do |cat|
	
	File.open("/var/www/rindex.html",'a') {|a| a.puts "<a name='#{cat.split("/")[1]}'></a>"}
	File.open("/var/www/rindex.html",'a') {|a| a.puts "<h1>#{cat}</h1>"}
	
	Dir.glob("#{cat}/*.html").each do |page|
		
		tocheck = "/var/www/plmanual/inbox/#{cat.split("/")[1]}/*,repository_#{cat.split("/")[1]}_#{page.split("/")[2]}"
		if !Dir.glob(tocheck).empty?
			puts "SKIPED ALREADY SCORED #{page}"
			next 
		end

		if !File.exists?("/media/DATA/#{page}")
			puts "HTML FILE NOT FOUND: #{page}"
			next 
		end
		#next if page=="repository/index.html"
		
		doc = Nokogiri::HTML(File.open(page))
		script = doc.at("//script[@id='script-pl-manual']")
		if script.nil?
			script = Nokogiri::XML::Node.new("script",doc) 
			script["id"] = "script-pl-manual"
			script['src'] = "http://www-poleia.lip6.fr/~sanojaa/SCAPE/pmanual.js"
			unless doc.at('head').nil?
				doc.at('head').add_child script
			else
				unless doc.at('html').nil?
					doc.at('html').add_child script
				else
					puts "NILL nothing to do with #{p}"
				end
			end
		else
			script['src'] = "http://www-poleia.lip6.fr/~sanojaa/SCAPE/pmanual.js"
		end
		puts "ADDED #{page}"
		File.open(page,'w') {|f|f.puts doc}
		fs = "%.2f" % (File.size(page) / 1024.0) 
		esc = CGI::escape(page)
		esc = URI::encode(esc)
		fxml = page.gsub(".html",".xml")
		if File.exists?(fxml)
			xml = Nokogiri::XML(File.open(fxml))
			url = xml.at("Document")["url"]
			File.open("/var/www/rindex.html",'a') {|a| a.puts "<li><a href='http://www-poleia.lip6.fr/~sanojaa/SCAPE/get.php?cat=#{cat}&fn=#{esc}'>#{doc.title}</a>&nbsp;(#{fs}KB) <br><span style='color:#C0C0C0'>Local: <a href='http://www-poleia.lip6.fr/~sanojaa/SCAPE/get.php?fn=#{esc}' style='color:#C0C0C0'>#{page}</a></span><br>Original: <a href='#{url}'>#{url}</a></li><br>"}
		end
		
	end
end
File.open("/var/www/rindex.html",'a') {|a| a.puts "</ol>"}
