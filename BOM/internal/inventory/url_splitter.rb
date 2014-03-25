#!/usr/bin/ruby

#~ require 'uri'
#~ require 'domainatrix'
#~ require 'fileutils'
#~ 
#~ class URLSplitter
#~ 
#~ def parse(url)
	#~ url = url.chomp.strip.chomp("/")
#~ 
	#~ uri = Domainatrix.parse(url)
#~ 
	#~ filename = (url.gsub("https://","").gsub("http://","").gsub("/","_").gsub("?","_").gsub(":","").gsub("__","_").gsub(" ","_")).chomp("_")
	#~ filename.slice!(0) if filename.start_with? "_"
#~ 
	#~ foldername = "#{uri.public_suffix}/#{uri.domain}/#{filename}"
	#~ return foldername
#~ end
#~ 
#~ end
#~ 
#~ 
#~ if __FILE__==$0
	#~ puts URLSplitter.new.parse(ARGV[0])
#~ end
puts "OK"

