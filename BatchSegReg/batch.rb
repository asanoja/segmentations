require 'uri'
require 'domainatrix'
require 'fileutils'

$halt = false

trap("INT") do
  puts "got signal INT. Waiting current process to finish"
  $halt = true
  exit
end

class Numeric
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} days and #{hours % 24} hours"
    elsif hours > 0
      "#{hours} hours and #{mins % 60} minutes"
    elsif mins > 0
      "#{mins} minutes and #{secs % 60} seconds"
    elsif secs >= 0
      "#{secs} seconds"
    end
  end
end



continuar = ""
browsers = ["chrome"]
algorithms = []
#algorithms.push "bom"
algorithms.push "bf"
#algorithms.push "jvips"

category = ARGV[0]
if category.nil?
	puts "Enter category:"
	category = STDIN.gets.chomp.downcase
end

ifile = File.open("final/#{category}.txt")



ifile.each_line do |line|
	unless line.strip.empty?
		if (line.start_with? "http://") || (line.start_with? "https://")
			
			start = Time.now
			
			url = line.chomp.strip.chomp("/")
			#~ url = "http://www.socialgo.com/"
			
			uri = Domainatrix.parse(url)
			
			filename = (url.gsub("https://","").gsub("http://","").gsub("/","_").gsub("?","_").gsub(":","").gsub("__","_").gsub(" ","_")).chomp("_")
			filename.slice!(0) if filename.start_with? "_"
			
			foldername = "/local/sanojaa/archive/#{uri.public_suffix}/#{uri.domain}/#{filename}"
			
			unless File.exists?(foldername)
				FileUtils.mkdir_p foldername
			end
			
		
			browsers.each do |browser|
				unless File.exists? "#{foldername}/#{browser}_snapshot.png"
					system "cd ../../jPagelyzer-standalone-1.0/;java -jar jPagelyzer.jar -get screenshot -url #{url} -browser #{browser} -ofile #{foldername}/#{browser}_snapshot.png -port 8060"
					sleep 1
				end
				unless File.exists? "#{foldername}/#{browser}_render.html"
					system "cd ../../jPagelyzer-standalone-1.0/;java -jar jPagelyzer.jar -get source -url #{url} -browser #{browser} -ofile #{foldername}/#{browser}_render.html -port 8061"
					sleep 1
				end
			
				algorithms.each do |algo|
					cmd = "java -jar SeleniumWrapper.jar #{algo} #{category} #{url} #{browser}"
					puts cmd
					system cmd
					sleep 1
					if continuar!="a"
						puts "Continue? (Y/n/a)"
						continuar = STDIN.gets.chomp.downcase
						if continuar.downcase=="n"
							$halt=true 
							puts "Ending pending before finish"
							break
						end
					end
				end
			end
			
			system "mv chrome_bom.rec #{foldername}/chrome.bom.rec"
		#	system "mv firefox_bom.rec #{foldername}/firefox.bom.rec"
			system "mv chrome_bf.rec #{foldername}/chrome.bf.rec"
		#	system "mv firefox_bf.rec #{foldername}/firefox.bf.rec"
			system "mv jvips.rec #{foldername}/cssbox.jvips.rec"
			system "mv page.png #{foldername}/cssbox_snapshot.png"
			
			puts "Downloading #{url} to #{foldername}"
			#system "wget --quiet --random-wait -E -H -k -K -p -P #{foldername}/source #{url} "
			#for new categories uncomment above

			puts "Creating metadata files"
			File.open("#{foldername}/url.txt","w") { |md|
				md.puts "#{url}"
			}
			File.open("#{foldername}/categories.txt","a") { |md|
				md.puts "#{category}"
			}
			File.open("#{foldername}/timestamp.txt","w") { |md|
				md.puts "#{Time.now.getutc}"
			}
			puts "URL process in #{(Time.now - start).duration}"
			exit if $halt
		end
	end
end
