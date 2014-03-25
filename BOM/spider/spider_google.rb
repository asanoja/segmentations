require 'nokogiri'
require 'uri'

def to_html(ifname)
str = "<table border='1'>\n" # output string
File.open(ifname).each { |line|
  str += "  <tr><td>" + line.strip.gsub(/\"/,"").gsub(/,$/,"").gsub(/,/,"</td><td>") + "</td>\n"
}
str += "</table>"
str
end

def filename(keyword,pages)
"#{keyword}-#{pages}.csv"
end

def run_spider(keyword,pages)
system "cd google-crawler/;bash executer.sh #{keyword} \"#{pages}\""
puts to_html("./google-crawler/scraped/#{filename(keyword,pages)}")
return "./google-crawler/scraped/#{filename(keyword,pages)}"
end

terms = ["#{ARGV[0]}"]
terms.each do |t|
	puts "Extrating from #{t}"
	File.open("urllist.html",'a') {|g| g.puts "<h1>"+t+"</h1>"} 
	f=run_spider(t,2)
	puts "Converting..."
	inter = to_html(f)
	URI.extract(inter).each do |url|
		frag = "<a href='#{url}' target='_blank'>#{url}</a><br>\n"
		File.open("urllist.html",'a') {|g| g.puts frag} 
		File.open("urllist.txt",'a') {|g| g.puts url} 
	end
	puts "Done."
end


