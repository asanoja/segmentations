while(true)
	delta = 2*3600
	system "ruby do_get.rb"
	puts "Next round at #{Time.now + delta}"
	sleep(delta)
end
