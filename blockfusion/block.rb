class Block
	def initialize
		@bid = ""
		@xpath = "";
		@element = nil
		@rect = {}
		@cover = 0
		@area = 0.0
	end
	def parse(arr)
		@bid = arr[0]
		@xpath = arr[1]
		@element = arr[2]
		@rect = arr[3]
		@cover = arr[4]
		@area = arr[5]
	end
	def to_s
		"[#{@bid} #{@xpath} #{@area} #{@cover}]"
	end
	def to_record
		"#{@bid},#{@rect['x']},#{@rect['y']},#{@rect['w']},#{@rect['h']},#{@cover}"
	end
end
