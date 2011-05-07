
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
CREATE TABLE `tasks` (
  `id` varchar(40) NOT NULL,
  `zad_id` int(11) NOT NULL,
  `p` tinyint(4) NOT NULL DEFAULT '0',
  `done` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `zad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zad` varchar(30) DEFAULT NULL,
  `tekst` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `zadatci` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kod` text,
  `bodovi` tinyint(4) DEFAULT NULL,
  `zad` int(11) DEFAULT NULL,
  `ucenik` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

=end

require "rubygems"
gem "ruby-mysql", "= 2.9.3"
require "mysql"
require "oc.rb"
require "open3"
require RUBY_VERSION =~ /^1.8/ ? "system_timer" : "timeout"

@tick = 1 # interval update-a
@debug = 1

MYSQL_C = {
	:host => "127.0.0.1",
	:user => "root",
	:pass => "",
	:db   => "zadq"
}

def d(txt)
	puts "DEBUG: #{txt}" if @debug
end

class MyCon
	def initialize() # host, user, passw, db, opts={}
		host, user, passw, db = *%w(host user pass db).collect{|x| MYSQL_C[:"#{x}"]}
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
		# @c.query("select id, task from q where done=0 order by created_at").to_a
		# r = c.query("select id, zad_id, done from tasks where done=0")
		r = @c.query("select * from tasks where done=0 and p=0")
		r.to_a
	end

	def done(id)
		@c.query("update tasks set p=0, done=1 where id='#{@c.escape_string id}'").to_a
	end

	# update-aj bodove zadatka
	def rezultat(id, val)
		@c.query("update zadatci set bodovi=#{val} where id=#{id}")
	end

	def processing(id)
		@c.query("update tasks set p=1 where id='#{id}'")
	end

	# "select zadatci.id, zadatci.kod, zad.zad from zadatci inner join zad on zadatci.zad=zad.id"

	# varti kod zadatka
	def zadatak(id)
		r = @c.query("select zad.zad, zadatci.kod from zadatci inner join zad on zadatci.zad=zad.id where zadatci.id=#{id}")
		return r.to_a.first rescue nil
	end

	def query(q)
		@c.query(q)
	end
end

@threads = []

def run(tasks)
	tasks.each{|task|
		@threads << Thread.new {
			c = MyCon.new
			# task[]: id, zad_id, p, done
			d "Running task: zad_id: '#{task[1]}', ID: #{task[0]}"

			# bodovi = `php oc.rb #{task[1]}`
			# c.rezultat(task[0], bodovi)

			z = c.zadatak(task[1])

			if z.nil? || z.empty?
				c.query "delete from tasks where id='#{task[0]}'"
				puts "Task s nepostojecim zad_id-om!"
				break
			end

			# puts "zad:", z[0]
			# puts "kod:", z[1]
			c.processing(task[0])

			include Oc
			b = ocjeni z[0], z[1]
			# puts "rezultat: #{b}"

			c.rezultat(task[1], b)

			d "Task '#{task[0]}' done!"
			c.done(task[0])
			c.close
		}
	}
	# @threads.each{|x| x.join}
end

q = MyCon.new
while 1
	# puts "tick"
	t = q.todo
	# puts "t: #{t.inspect}"
	if !t.empty?
		run t
	end
	# q.close
	sleep @tick
end
