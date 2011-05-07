
=begin
Instalacija:
gem install ruby-mysql -v=2.9.3

Dodavanje taskova:
ruby add.rb

Pokretanje:
ruby q.rb
=end

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

require "redis"

require "lib"

@debug = 1

MYSQL_C = {
	:host => "127.0.0.1",
	:user => "root",
	:pass => "pw",
	:db   => "zadq"
}

def d(txt)
	puts "DEBUG: #{txt}" if @debug
end

class ReCon
	def initialize()
		@r = nil
		open()
	end

	def open
		d "Conn open"
		@r = Redis.new
	end

	def todo
		return (
			@r.keys('zadq:tasks:*').map{|k| @r.get(k) }.
			map{|k|
				t = TaskRecord.new k
				# [t.get('id'), t.get('task')]
				t
			}
			)
	end

	def done(id)
		# @c.query("update q set done=1, completed_at=CURRENT_TIMESTAMP where id=#{id}").to_a
		q = "zadq:tasks:*:#{id}"
		k = @r.keys(q)
		if k.empty?
			d "Unknown key '#{q}'"
		else
			old = TaskRecord.new @r.get(k.first)
			old.set('done', 1)
			@r.set k.first, old.t
			# @r.del k.first
			puts "DONE #{id}"
		end
	end

	def rezultat(id, bodovi) # update rezultat u MySQL
		# ...
	end
end

def run(tasks)
	t = []
	tasks.each{|task|
		# task = TaskRecord.new(task)
		c = ReCon.new
		r = Redis.new
		key = r.keys("zadq:tasks:*:#{task.get('id')}")
		d "Running task '#{task.get('task')}' with ID: #{task.get('id')} (full key: #{key})"

		zad = task.get 'task'
		out = `cat zad/#{zad}.c | ruby oc.rb prvi | tail -1`
		puts "Bodova: #{out}"

		# sleep 1
		d "Task '#{task.get('task')}' done!"
		c.done(task.get('id'))
	}
end


=begin

Redis:

zadq:tasklast - last ID
zadq:tasks:ID
zadq:tasks:1 => [id, task, done, processing] spojeni sa ":"

=end


q = ReCon.new
while 1
	puts "tick"
	t = q.todo
	if !t.empty?
		run t
	else
		sleep 1
	end
end
