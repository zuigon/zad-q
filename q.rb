
=begin
DB:
create database zadq;
use zadq;
create table q (
	id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	task varchar(50) DEFAULT NULL,
	done tinyint(4) DEFAULT '0',
	created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	completed_at timestamp NULL DEFAULT NULL
);
=end


require "rubygems"
gem "ruby-mysql", "= 2.9.3"
require "mysql"

@debug = 1

MYSQL_C = {
	:host => "192.168.1.250",
	:user => "root",
	:pass => "pw",
	:db   => "zadq"
}

def d(txt)
	puts "DEBUG: #{txt}" if @debug
end

class MyCon
	def initialize() # host, user, passw, db, opts={}
		host, user, passw, db = MYSQL_C[:host], MYSQL_C[:user], MYSQL_C[:pass], MYSQL_C[:db]
		@data = [host, user, passw, db]
		@c = nil
		open()
	end

	def open
		d "Conn open"
		@c = Mysql.real_connect *@data
	end

	def close
		d "Conn close"
		@c.close
	end

	def todo
		@c.query("select id, task from q where done=0 order by created_at").to_a
	end

	def done(id)
		@c.query("update q set done=1, completed_at=CURRENT_TIMESTAMP where id=#{id}").to_a
	end

	def rezultat(id, bodovi)
		# ...
	end
end

def run(tasks)
	t = []
	tasks.each{|task|
		t << Thread.new {
			c = MyCon.new
			# task[]: id, task
			d "Running task '#{task[1]}' with ID: #{task[0]}"
			# bodovi = `php oc.php --zadatak #{task[1]}` ili sl.
			# c.rezultat(task[0], bodovi)
			sleep 1
			d "Task '#{task[1]}' done!"
			c.done(task[0])
			c.close
		}
	}
	# t.each{|x| x.join}
end

while 1
	q = MyCon.new
	t = q.todo
	if !t.empty?
		run t
	else
		d "Prazan queue"
	end
	q.close
	sleep 2
end
