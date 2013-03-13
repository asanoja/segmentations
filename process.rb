require 'fileutils'
require './parse.rb'
require './matrix.rb'

cat = ARGV[0]

#create output folder
output = "data/#{cat}"
FileUtils.mkdir_p output unless File.exists? output

#get input files
list = []
basepath = "/media/DATA/crawl/hot/#{cat}"
Dir.foreach(basepath) do |site| 
	unless ['.','..'].include?(site)
		found = false
		Dir.foreach("#{basepath}/#{site}") do |version|
			unless ['.','..'].include? version
				if File.exists? "#{basepath}/#{site}/#{version}/firefox/"
					Dir.foreach("#{basepath}/#{site}/#{version}/firefox/") do |deco|
						unless ['.','..'].include? deco
							if deco.split("_").last == "decorated.html"
								list.push "#{basepath}/#{site}/#{version}/firefox/#{deco}"
								found = true
								break
							end
						end
					end
				elsif File.exists? "#{basepath}/#{site}/#{version}/chrome/"
					Dir.foreach("#{basepath}/#{site}/#{version}/chrome/") do |deco|
						unless ['.','..'].include? deco
							if deco.split("_").last == "decorated.html"
								list.push "#{basepath}/#{site}/#{version}/chrome/#{deco}"
								found = true
								break
							end
						end
					end
				end
			end
			break if found
		end
	end
	#break
end

#process input	
$total = Matrix.new(7,7,0)

FileUtils.rm Dir.glob("#{output}/*")


tags = []
File.open("taglist.txt").each_line do |tag|
	rtag = tag.split(" ")[0]
	File.open("#{output}/#{rtag.strip.downcase}.csv","w")
	tags.push rtag.strip.downcase
end
File.open("#{output}/text.csv","w")
	
list.each do |input|
	puts "opening #{input.split("/")[5]}/#{input.split("/")[6]} file"
	parse(cat,input,output,tags.join(" "))
end

puts "\nTags total table in #{cat}"
$total.save_to("#{output}/#{cat}_total.dat")
puts $total.to_s
