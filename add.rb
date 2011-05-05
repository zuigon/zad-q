require "rubygems"
gem "ruby-mysql", "= 2.9.3"
require "mysql"

c = Mysql.real_connect *%w(192.168.1.250 root pw zadq)
while 1
	print "Task: ";
	inp = gets.chop
	exit if inp==""
	puts "Task '#{inp}' added to queue"
	c.query("insert into q values (null, '#{inp}', 0, null, null)")
end
