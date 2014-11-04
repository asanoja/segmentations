#~ require 'rubygems'
require 'mysql'

db = Mysql.new("localhost","bom","DL77ESuQZT2a3q6X","bom")

['gt_blocks','bom_blocks','bf_blocks','jvips_blocks','vips_blocks'].each do |table|
	db.query("select * from segmentation").each_hash do |rseg|
		db.query("select * from #{table} where segmentation_id='#{rseg['id']}'").each_hash do |b|
			db.query("insert into blocks(doc_w,doc_h,bid,x,y,w,h,ts,segmentation_id,ecount,tcount,importance,nx,ny,nw,nh) values('#{b['doc_w']}','#{b['doc_h']}','#{b['bid']}','#{b['x']}','#{b['y']}','#{b['w']}','#{b['h']}','#{b['ts']}','#{b['segmentation_id']}','#{b['ecount']}','#{b['tcount']}','#{b['importance']}','#{b['nx']}','#{b['ny']}','#{b['nw']}','#{b['nh']}')")
			puts "#{rseg['id']} -> #{b['id']}. DONE"
		end
	end
end
db.close
