require 'rubygems'
require 'selenium-webdriver'
require 'pathname'

require_relative './block.rb'
require_relative './document.rb'

Selenium::WebDriver::Firefox::Binary.path='/usr/bin/firefox'

pac = 0.3

br = :firefox

host = "http://localhost:8030"
 
#~ url= "http://research.microsoft.com/en-us/um/people/ryenw/hcir2010/challenge.html"
# url= "http://fr.wikipedia.org/wiki/Salto_Angel"
#~ url= "http://www.upmc.fr"
# url= "http://boilerpipe-web.appspot.com/"
#url= "http://www-poleia.lip6.fr/~sanojaa/dummy.html"

#OPTIONS
# process_blocks.rb <url> <browser> <outputfile> <pac>

url = ARGV[0]
outputfolder = ARGV[2]

if url.nil?
	Kernel.abort("URL not given")
end

unless ARGV[1].nil?
	br = ARGV[1]
end

if ARGV[2].nil?
	Kernel.abort("Output file not specified")
end

unless ARGV[3].nil?
	pac = ARGV[3].to_i
end

outputfolder = outputfolder.chomp("/")

filename = ((url.gsub("__","_").gsub("/","_").gsub("__","_").gsub(":","_")).gsub("http","")) + ".js"

puts "Calling BoilerPipe external utility..."
system "java -jar BoilerPipe.jar #{url} #{outputfolder}/#{filename}"

puts "Opening #{br}"
browser = Selenium::WebDriver.for br.to_sym
browser.manage.window.resize_to(970,728)

puts "Navigating to #{url}"
browser.get url

wait = Selenium::WebDriver::Wait.new(:timeout => 60)

#http://www-poleia.lip6.fr/~sanojaa

load_dump = <<FIN
function func_dump() {
	var script = document.createElement('script');
	script.type = "text/javascript"
	script.setAttribute("id","bfinject1");
	script.setAttribute("src","#{host}/bf_js/#{filename}");
	document.getElementsByTagName('head')[0].appendChild(script);
}

var callback = arguments[arguments.length - 1];
callback(func_dump());
FIN
#~ puts load_dump
load_analyzer = <<FIN
function func_analyzer() {
	var script = document.createElement('script');
	script.type = "text/javascript"
	script.setAttribute("id","bfinject2");
	script.setAttribute("src","#{host}/bfanalyzer.js");
	document.getElementsByTagName('head')[0].appendChild(script);
}

var callback = arguments[arguments.length - 1];
callback(func_analyzer());
FIN

load_rectlib = <<FIN
function func_rectlib() {
	var script = document.createElement('script');
	script.type = "text/javascript"
	script.setAttribute("id","bfinject3");
	script.setAttribute("src","#{host}/rectlib.js");
	document.getElementsByTagName('head')[0].appendChild(script);
}

var callback = arguments[arguments.length - 1];
callback(func_rectlib());
FIN

load_jquery = <<FIN
function func_jquery() {
	var script = document.createElement('script');
	script.type = "text/javascript"
	script.setAttribute("id","bfinject4");
	script.setAttribute("src","#{host}/jquery-min.js");
	document.getElementsByTagName('head')[0].appendChild(script);
}

var callback = arguments[arguments.length - 1];
callback(func_jquery());
FIN
browser.execute_async_script(load_jquery)
browser.execute_async_script(load_rectlib)
browser.execute_async_script(load_dump)
browser.execute_async_script(load_analyzer)

refs =  browser.execute_script("return bfprocess("+(pac.to_s)+");")

document = Document.new
document.parse(refs[0]) 

puts "AC" + pac.to_s

record = ""
prec = ""
refs[1].each do |ref|
	if ref[2]!="DISCARDED" && !ref[2].nil?
		block = Block.new
		block.parse(ref)
		puts prec = "BF,#{br},none,#{url},#{document.to_record},#{pac},#{block.to_record}"
		record += "#{prec}\\n"
	end
end

puts "Sending to server..."
browser.get "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php"
puts browser.execute_script("console.log('#{record}');return document.getElementById('record').value='#{record}';")
fr = browser.find_element(:id,"forma")
fr.submit
puts "Waiting some seconds..."
sleep 5
puts "Press any key to continue..."
STDIN.gets
puts "Closing browser"
browser.quit

