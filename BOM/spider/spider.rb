require 'nokogiri'
require 'open-uri'

$visited = [];
$taken = 0
$quota = 25

class Entry
	attr_accessor :elem,:value,:href,:name
	def initialize(elem)
	@elem = elem
	@value = elem.children.first.inner_text.gsub("(","").gsub(")","").gsub(",","").to_i
	@name = elem.previous_sibling.previous_sibling.name
	@href = elem.previous_sibling.previous_sibling['href']
	end
end

def parse(url,cat)
	return if $visited.include?(url) 
	return if $taken>25 
	
	arr=[]
	ret=[]
	page = Nokogiri::HTML(open(url))
	
	$visited.push(url)
	
	list = page.search("//ul[@class='directory-url']")
	if list.size>0
		puts "list found for #{url}"
		cand = list.search("//a").collect {|e| e['href'] if (e['href'].start_with?("http://") && (!e['href'].include?("dmoz.org")))}
		cand.delete(nil)
		selected = cand[rand(cand.size).round]
		while $visited.include?(selected)
			selected = cand[rand(cand.size).round]
		end
		$visited.push selected
		$taken+=1
		puts "Taking #{$taken}/#{$quota}: #{selected}"
		ret.push [selected]
	end	
	if $taken<$quota
		#search in subcats with more content
		page.search("//em").each do |elem|
			arr.push Entry.new(elem)
		end
		#~ s = arr.sort {|a,b| a.value <=> b.value}.reverse
		#~ s.delete_at(0)
		
		final = []
		for i in (0..(arr.size-1))
			x = arr[i]
			subcat =  x.elem.previous_sibling.previous_sibling.inner_text
			href = x.elem.previous_sibling.previous_sibling['href']
			unless href.nil?
				if href.start_with?("/#{cat}") && (x.value>0)
					final.push x
				end
			end
		end
		
		final.sort {|a,b| a.value <=> b.value}.reverse.each do |subcat|
			if $taken<$quota
				puts "iterating to #{subcat.name}:#{subcat.value} -> #{subcat.href}"
				ret.push parse("http://www.dmoz.org/#{subcat.href}",cat)
				sleep(2)
			else
				puts "Quota achieved. Waiting to finish #{subcat.href}"
				break
			end
		end
	end
	return ret
end

def crawl(url,cat)
	$taken=0
	parse("#{url}/#{cat}",cat)
end

cats = ["Arts","Games","Kids_and_Teens","Reference","Shopping","World","Business","Health","News","Regional","Society","Computers","Home","Recreation","Science","Sports"]

	cats.each do |c|
		res = crawl("http://www.dmoz.org",c)
		File.open("urllist.txt","a") {|f| f.puts "##{c}";f.puts res.flatten.join("\n")}
	end
