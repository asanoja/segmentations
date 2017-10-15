["bom chrome","bf chrome","jvips cssbox","vips iexplorer"].each do |algo|
	["blog","forum","wiki","picture","enterprise"].each do |cat|
	puts "----- #{algo} #{cat} ------"
		system "java -jar dist/EvaluationGUI.jar gt chrome #{algo} GOSH #{cat} 4 0.95"
	end
end
