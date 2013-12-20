require 'sqlite3'

db = SQLite3::Database.open "GTdata.db"
datafile = "GTdata.txt"	

File.open(datafile,"r").each_line { |line|
	unless line.strip.empty?
		s = line.split(",")
		browser = s[0].strip
		category = s[1].strip
		url = s[2].strip
		docw = s[3].to_f
		doch = s[4].to_f
		bid = s[5].strip
		block_x = s[6].to_f
		block_y = s[7].to_f
		block_w = s[8].to_f
		block_h  = s[9].to_f
		
		p browser,category,url,docw,doch,bid,block_x,block_y,block_w,block_h
		db.execute "insert into blocks(browser,category,url,doc_w,doc_h,bid,block_x,block_y,block_w,block_h) values('#{browser}','#{category}','#{url}','#{docw}','#{doch}','#{bid}','#{block_x}','#{block_y}','#{block_w}','#{block_h}')"
	end
}
