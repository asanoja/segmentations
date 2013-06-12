require 'nokogiri'

File.open("list.csv",'w')

raw = File.read("bookmarks.html")

raw.gsub!("<DT>","")
raw.gsub!("</DT>","")
raw.gsub!("<DL>","")
raw.gsub!("</DL>","")
raw.gsub!("<p>","")

doc = Nokogiri::HTML(raw)

catname = ""
url =""
title=""

doc.search("*").each do |linea|
	#
	#category = section.parent
	
	if linea.name.downcase=="h3"
		catname = linea.inner_text
	end
	

	if linea.name.downcase=="a"
		title = linea.inner_text
		url = linea['href']
		File.open("list.csv",'a') {|f| f.puts "\"#{catname}\",\"#{title}\",\"#{url}\"" }
	end
	
end


