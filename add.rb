require "rubygems"
# require "redis"
gem "ruby-mysql", "= 2.9.3"
require "mysql"
require "lib"

MYSQL_C = {
	:host => "127.0.0.1",
	:user => "root",
	:pass => "",
	:db   => "zadq"
}

def randid()
	l = 32
	h = ('0'..'9').to_a + ('a'..'f').to_a
	c = h.count
	(0...l).map{ h.to_a[rand(c)] }.join
end

key = "zadq:tasks"

# r = Redis.new
# while 1
# 	print "Task: ";
# 	inp = gets.chop
# 	exit if inp==""
# 	puts "Task '#{inp}' added to queue"
# 	# zadq:tasks:N => [id, task, done, processing]
# 	rid = r.incr "#{key}last"
# 	id = randid()
# 	rec = TaskRecord.new
# 	rec.set 'id', id
# 	rec.set 'task', inp
# 	rec.set 'done', 0
# 	rec.set 'processing', 0
# 	q = rec.t
# 	r.set "#{key}:#{rid}:#{id}", q
# end

host, user, passw, db = *%w(host user pass db).collect{|x| MYSQL_C[:"#{x}"]}
c = Mysql.real_connect *[host, user, passw, db]

while 1
	print "zad_id: ";
	inp = gets.chop
	exit if inp==""
	id = randid
	puts "Task '#{id}' added to queue"
	c.query("insert into tasks values ('#{id}', #{inp.to_i}, 0, 0, NOW(), null)")
end

