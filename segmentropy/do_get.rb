require "fileutils"

set = File.readlines('pages.txt').collect {|p| p.split(" ")}
set.delete([])

set.each do |page|
	now = Time.now
	folder = "%04d%02d%02d%02d%02d%02d" % [now.year,now.month,now.mday,now.hour,now.min,now.sec]
	puts "Capture #{page[2]} in #{folder}"
	["firefox","chrome"].each do |browser|
		FileUtils.mkdir_p "hot/#{page[0].downcase}/#{page[1]}/#{folder}/#{browser}/"
		cmd = "/home/scape/src/pagelyzer/standalone/pagelyzer-ruby-0.9-standalone/pagelyzer capture --url=#{page[2]} --browser=#{browser} --output-folder=/media/DATA/crawl/hot/#{page[0].downcase}/#{page[1]}/#{folder}/#{browser} --thumbnail"
		break if system(cmd)
	end
end
