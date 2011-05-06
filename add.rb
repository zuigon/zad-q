require "rubygems"
require "redis"
require "lib"

def randid()
	l = 32
	h = ('0'..'9').to_a + ('a'..'f').to_a
	c = h.count
	(0...l).map{ h.to_a[rand(c)] }.join
end

key = "zadq:tasks"

r = Redis.new
while 1
	print "Task: ";
	inp = gets.chop
	exit if inp==""
	puts "Task '#{inp}' added to queue"
	# zadq:tasks:N => [id, task, done, processing]
	rid = r.incr "#{key}last"
	id = randid()
	rec = TaskRecord.new
	rec.set 'id', id
	rec.set 'task', inp
	rec.set 'done', 0
	rec.set 'processing', 0
	q = rec.t
	r.set "#{key}:#{rid}:#{id}", q
end
