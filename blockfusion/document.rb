class Document
	attr_accessor :url
	def initialize
		@w = 0
		@h = 0;
		@url = ""
	end

	def parse(harr)
		@w = harr['w']
		@h = harr['h']
	end
	
	def to_record
		"#{@w},#{@h}"
	end
end
